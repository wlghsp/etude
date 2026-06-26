# HAProxy 설정 가이드

실무에서 HAProxy 설정을 읽고 작성할 때 필요한 개념과 패턴을 정리합니다.  
이 문서의 예시는 현재 운영 중인 `old_dr_haproxy.cfg`를 기반으로 합니다.

---

## 목차

1. [HAProxy 기본 구조](#1-haproxy-기본-구조)
2. [섹션별 상세 설명](#2-섹션별-상세-설명)
3. [listen vs frontend/backend](#3-listen-vs-frontendbackend)
4. [모드: TCP vs HTTP](#4-모드-tcp-vs-http)
5. [SSL/TLS 처리 패턴](#5-ssltls-처리-패턴)
6. [ACL 기반 도메인 라우팅](#6-acl-기반-도메인-라우팅)
7. [실무 패턴 모음](#7-실무-패턴-모음)
8. [네트워크 작업 체크리스트](#8-네트워크-작업-체크리스트)
9. [트러블슈팅](#9-트러블슈팅)

---

## 1. HAProxy 기본 구조

HAProxy 설정 파일은 4개 섹션으로 구성됩니다.

```
global      ← HAProxy 프로세스 전역 설정
defaults    ← 모든 frontend/backend에 적용되는 기본값
frontend    ← 클라이언트 요청을 받는 입구
backend     ← 실제 서버로 요청을 보내는 출구
```

또는 frontend + backend를 하나로 합친:

```
listen      ← frontend + backend 통합 (단순 포워딩에 유용)
```

### 요청 흐름

```
클라이언트
  → [frontend] 포트 수신, ACL 판단, backend 선택
    → [backend] 로드밸런싱, 헬스체크, 서버 전달
      → 실제 서버
```

---

## 2. 섹션별 상세 설명

### 2.1 global

HAProxy 프로세스 자체에 대한 설정입니다.

```haproxy
global
  daemon                              # 백그라운드 프로세스로 실행
  chroot /var/lib/haproxy             # 보안: 루트 디렉터리 제한
  user haproxy
  group haproxy
  master-worker                       # master-worker 모드 (무중단 reload 지원)
  stats socket /var/run/haproxy.sock user haproxy group haproxy mode 660 level admin expose-fd listeners
  stats timeout 30s
  hard-stop-after 300s                # reload 시 기존 프로세스 최대 대기 시간
  log 127.0.0.1 local0 info

  # SSL 설정
  tune.ssl.default-dh-param 2048
  ssl-default-bind-options no-sslv3
  ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:...
  ca-base /etc/haproxy/ssl            # CA 인증서 기본 경로
  crt-base /etc/haproxy/ssl           # 서버 인증서 기본 경로
  mworker-max-reloads 3               # master-worker 모드에서 reload 최대 횟수
```

**`master-worker` 모드가 중요한 이유:**  
`systemctl reload haproxy` 시 기존 연결을 끊지 않고 새 설정을 적용할 수 있습니다. `hard-stop-after 300s`는 기존 연결이 300초 안에 끝나지 않으면 강제 종료하는 시간입니다.

### 2.2 defaults

모든 frontend/backend에 적용되는 기본값입니다. 개별 섹션에서 재정의 가능합니다.

```haproxy
defaults
  mode http
  log global
  option httplog
  option dontlognull
  timeout connect 5000       # 백엔드 서버 연결 타임아웃 (5초)
  timeout client 6000000     # 클라이언트 비활성 타임아웃 (100분)
  timeout server 6000000     # 서버 응답 타임아웃 (100분)
```

**타임아웃 단위**: 숫자만 쓰면 ms, `5s` `1m` 등 단위 지정 가능.  
`timeout client/server`가 큰 이유: Kafka, DB 등 장시간 연결을 유지하는 서비스가 있기 때문.

### 2.3 통계 페이지

```haproxy
listen stats
  bind :9999
  mode http
  stats enable
  stats refresh 10s
  stats hide-version          # HAProxy 버전 숨김 (보안)
  stats show-node             # 노드 이름 표시
  stats realm Haproxy\ Statistics
  stats uri /                 # 접속 경로: http://haproxy-ip:9999/
  errorfile 400 /etc/haproxy/errors/400.http
  ...
```

접속: `http://haproxy-ip:9999/` — 각 서버의 UP/DOWN 상태, 연결 수, 응답 시간을 실시간 확인.

---

## 3. listen vs frontend/backend

### listen (단순 포워딩)

서버 1개 또는 단순 로드밸런싱에 사용합니다.

```haproxy
# TCP 포워딩 예시
listen k8s-api-server
    bind *:6443
    mode tcp
    server egcp4-master1 10.0.0.17:6443 check inter 5000ms fall 3 rise 2
    server okc-master-02 10.0.0.62:6443 check inter 5000ms fall 3 rise 2
    server okc-master-03 10.0.0.63:6443 check inter 5000ms fall 3 rise 2

# Kafka 브로커 포워딩
listen dr-kafka-broker1
    bind *:29092
    mode tcp
    balance source
    server dr-kafka1 10.0.0.45:29092 check inter 10s
```

### frontend + backend (도메인/조건 분기)

하나의 포트(80/443)에서 Host 헤더를 보고 여러 서비스로 분기할 때 사용합니다.  
현재 설정에서 `oc-pipeline` frontend가 이 역할을 합니다.

```haproxy
frontend oc-pipeline
    bind *:80
    bind *:443 ssl crt /etc/haproxy/ssl/cloud.go.kr.pem crt /etc/haproxy/ssl/dev.cloud.go.kr.pem
    # ACL 정의
    acl is-nexus hdr(host) -i nexus.cloud.go.kr
    acl ocp-prometheus hdr(host) -i prometheus-k8s-openshift-monitoring.apps.ocp4.nirs.go.kr
    # backend 분기
    use_backend nexus-registry if is-nexus
    use_backend ocp-prometheus if ocp-prometheus
    default_backend k8s-ingress-https

backend ocp-prometheus
    mode http
    server ocp-prometheus 192.168.1.54:443 check ssl verify none sni str(prometheus-k8s-openshift-monitoring.apps.ocp4.nirs.go.kr)
```

**선택 기준:**

| 상황 | 권장 |
|------|------|
| 포트 1개 → 서버 1~N개 (단순 포워딩) | `listen` |
| 포트 80/443에서 도메인별 분기 | `frontend` + `backend` |
| HTTP 헤더 조작, 리다이렉트 필요 | `frontend` + `backend` |

---

## 4. 모드: TCP vs HTTP

**mode가 다르면 사용할 수 있는 기능이 달라집니다.**

### TCP 모드 (L4)

```haproxy
mode tcp
option tcplog
```

- 패킷을 내용 해석 없이 그대로 전달
- HTTP 헤더 조작 불가
- **사용 케이스**: Kafka, DB(MySQL/MariaDB), k8s API server, Redis, RabbitMQ, 모든 비HTTP 프로토콜

```haproxy
# Kafka — balance source 필수 (세션 고정)
listen dr-kafka-broker1
    bind *:29092
    mode tcp
    balance source          # 클라이언트 IP 기반 고정
    server dr-kafka1 10.0.0.45:29092 check inter 10s

# MariaDB
listen staging-cmp-db
    bind *:11306
    mode tcp
    option tcp-check
    server staging-maria-db 10.0.0.100:3306 check
```

> **Kafka에 `balance source`를 쓰는 이유**: Kafka 클라이언트는 처음 연결한 브로커와 세션을 유지해야 합니다. `roundrobin`이면 요청마다 다른 브로커로 가서 연결이 끊깁니다.

### HTTP 모드 (L7)

```haproxy
mode http
option httplog
```

- HTTP 요청/응답 내용 해석 가능
- 헤더 추가/수정/삭제, URL 기반 라우팅, 리다이렉트 가능
- **사용 케이스**: 웹 서비스, API, Prometheus federate, Nexus, Harbor

```haproxy
backend nexus-web
    mode http
    option forwardfor
    http-request set-header X-Forwarded-Proto https if { ssl_fc }
    server nexus-registry-server 10.0.0.13:8443 check ssl verify none
```

---

## 5. SSL/TLS 처리 패턴

### 패턴 1: SSL 종단 (SSL Termination) ← 현재 운영 방식

```
클라이언트 ──HTTPS──► HAProxy ──HTTP or HTTPS──► 서버
                     (인증서 보유)
```

HAProxy가 HTTPS를 종단하고, 서버로는 HTTP 또는 HTTPS로 전달합니다.

```haproxy
frontend oc-pipeline
    bind *:80
    bind *:443 ssl crt /etc/haproxy/ssl/cloud.go.kr.pem \
                   crt /etc/haproxy/ssl/dev.cloud.go.kr.pem
    # 인증서 2개: 도메인별로 SNI에 맞는 인증서 자동 선택
```

인증서는 `crt-base`에 지정한 `/etc/haproxy/ssl/` 에 위치합니다.

**서버로 전달 시 HTTP vs HTTPS:**

```haproxy
# 서버가 HTTP인 경우
server harbor-server 10.0.0.12:80 check

# 서버도 HTTPS인 경우 (자체 서명 인증서 무시)
server nexus-server 10.0.0.13:8443 check ssl verify none
```

**`X-Forwarded-Proto` 헤더를 붙이는 이유:**

```haproxy
http-request set-header X-Forwarded-Proto https if { ssl_fc }
```

서버 입장에서는 HAProxy로부터 HTTP로 받으므로 원래 요청이 HTTPS였는지 모릅니다.  
`{ ssl_fc }` 조건: 클라이언트가 SSL로 접속한 경우에만 헤더 추가.  
애플리케이션이 이 헤더를 보고 리다이렉트 URL 등을 올바르게 생성합니다.

### 패턴 2: SNI 기반 OCP 라우팅

```
클라이언트 ──HTTPS──► HAProxy ──HTTPS + SNI──► 192.168.1.54:443 (OCP ingress)
                     (종단)                     → OCP가 SNI로 route 판단
```

```haproxy
backend ocp-oauth
    mode http
    server ocp-oauth 192.168.1.54:443 check ssl verify none \
        sni str(oauth-openshift.apps.ocp4.nirs.go.kr)

backend ocp-prometheus
    mode http
    server ocp-prometheus 192.168.1.54:443 check ssl verify none \
        sni str(prometheus-k8s-openshift-monitoring.apps.ocp4.nirs.go.kr)
```

OCP ingress(`192.168.1.54:443`)는 하나의 IP/포트에서 여러 서비스를 처리합니다.  
SNI가 없으면 어떤 서비스로 보낼지 모르므로, HAProxy가 SNI를 명시해야 합니다.

**`verify none` 사용 이유**: OCP 내부 인증서는 자체 서명(self-signed)이거나 사설 CA 발급이라 공개 CA 검증이 안 됩니다.

### 패턴 3: HTTP → HTTPS 브릿지 (주센터 OCP federate)

```
Prometheus ──HTTP:19090──► HAProxy (bastion-2) ──HTTPS:443──► 172.30.1.223 (OCP)
            (인증서 없이)   (헤더 주입)
```

```haproxy
frontend ocp-prometheus-federate-frontend
    bind *:19090
    mode http
    default_backend ocp-prometheus-federate-backend

backend ocp-prometheus-federate-backend
    mode http
    http-request set-header Host prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr
    server ocp-prometheus-federate 172.30.1.223:443 check ssl verify none \
        sni str(prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr)
```

내부 클라이언트(Prometheus)는 인증서 없이 HTTP로 통신하고,  
HAProxy가 대신 HTTPS + SNI + Host 헤더를 붙여서 OCP로 전달합니다.

---

## 6. ACL 기반 도메인 라우팅

현재 설정에서 가장 많이 쓰이는 패턴입니다. 80/443 포트 하나에서 도메인 이름으로 수십 개 서비스를 분기합니다.

### 6.1 ACL 정의

```haproxy
# 형식: acl <이름> <조건>
acl is-nexus          hdr(host) -i nexus.cloud.go.kr
acl ocp-prometheus    hdr(host) -i prometheus-k8s-openshift-monitoring.apps.ocp4.nirs.go.kr
acl dr-prometheus     hdr(host) -i klid-cmp.prometheus.cloud.go.kr
```

`hdr(host) -i`: Host 헤더를 대소문자 구분 없이(`-i`) 비교.

### 6.2 조건부 라우팅

```haproxy
use_backend nexus-registry           if is-nexus
use_backend ocp-prometheus           if ocp-prometheus
use_backend k8s-ingress-http         if dr-prometheus
default_backend k8s-ingress-https    # 조건 미일치 시 기본 backend
```

### 6.3 리다이렉트

```haproxy
# 루트 경로 접근 시 특정 페이지로 리다이렉트
acl is_root path -m str /
http-request redirect location http://app.iaas.cmp.cloud.go.kr/iaas/app if staging-iaas-app is_root
```

### 6.4 ACL 추가 작업 순서

새 서비스를 추가할 때는 항상 이 순서로 작업합니다:

```
1. DNS 또는 /etc/hosts에 도메인 등록
2. frontend에 ACL 정의 추가
3. frontend에 use_backend 추가
4. backend 블록 신규 작성
5. haproxy -c -f /etc/haproxy/haproxy.cfg  ← 문법 검사
6. systemctl reload haproxy
```

---

## 7. 실무 패턴 모음

### 7.1 로드밸런싱 알고리즘

```haproxy
balance roundrobin    # 순서대로 분산 (기본값) → 일반 웹 서버
balance leastconn     # 연결 수가 가장 적은 서버 → DB, 오래 걸리는 요청
balance source        # 클라이언트 IP 기반 고정 → Kafka, 세션 유지 필요
```

### 7.2 헬스체크 옵션

```haproxy
server kafka1 10.0.0.45:29092 check inter 10s
#                              ↑     ↑
#                           활성화  10초 간격

server k8s-master 10.0.0.17:6443 check inter 5000ms fall 3 rise 2
#                                                    ↑        ↑
#                                              3번 실패=DOWN  2번 성공=UP

server backup-worker 10.0.0.23:31000 check inter 5000ms fall 3 rise 2 backup
#                                                                       ↑
#                                                          다른 서버 DOWN 시에만 사용
```

### 7.3 multi-server 고가용성

```haproxy
listen staging-cmp-rabbitmq-ui
    bind *:31000
    mode tcp
    option tcp-check
    server egcp4-worker1 10.0.0.20:31000 check inter 5000ms fall 3 rise 2
    server egcp4-worker2 10.0.0.21:31000 check inter 5000ms fall 3 rise 2
    server egcp4-worker3 10.0.0.22:31000 check inter 5000ms fall 3 rise 2
    server egcp4-worker4 10.0.0.23:31000 check inter 5000ms fall 3 rise 2 backup  # ← backup
    server egcp4-worker5 10.0.0.24:31000 check inter 5000ms fall 3 rise 2 backup  # ← backup
```

worker1~3이 primary, worker4~5는 1~3이 모두 DOWN일 때만 사용.

### 7.4 센터 간 Kafka 연결

DR 센터 HAProxy에서 주센터 Kafka를 중계하는 패턴:

```haproxy
# DR 센터에서 주센터 Kafka 접근 (주센터 HAProxy 경유)
listen primary-kafka-broker1
    bind *:19092
    mode tcp
    balance source
    server primary-haproxy-kafka1 192.168.1.54:19092 check inter 10s
```

주센터 HAProxy(192.168.1.54)의 19092 포트를 통해 주센터 Kafka에 접근.  
이렇게 양 센터 간에 HAProxy를 통해 Kafka 미러링 등을 구성합니다.

---

## 8. 네트워크 작업 체크리스트

### 8.1 설정 전 확인

```bash
# 1. 사용할 포트가 이미 열려 있는지 확인
ss -tlnp | grep <포트번호>

# 2. 대상 서버에 연결이 되는지 확인
nc -zv <target-ip> <port>
curl -v telnet://<target-ip>:<port>

# 3. HTTPS 서버 연결 및 SNI 확인
curl -vk --resolve "도메인:443:IP" https://도메인/path

# 4. 기존 설정 백업
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak.$(date +%Y%m%d)
```

### 8.2 설정 후 검증

```bash
# 1. 문법 검사 (재시작 전 필수)
haproxy -c -f /etc/haproxy/haproxy.cfg

# 2. 무중단 설정 반영
systemctl reload haproxy    # 기존 연결 유지

# 3. 상태 확인
systemctl status haproxy

# 4. 로그 확인
tail -f /var/log/haproxy.log
journalctl -u haproxy -f
```

### 8.3 연결 테스트

```bash
# HTTP 엔드포인트
curl -v http://haproxy-ip:포트/경로

# Bearer 토큰 포함 (Prometheus federate)
curl -v "http://haproxy-ip:19090/federate?match[]={__name__=~'.+'}" \
  -H "Authorization: Bearer $(cat /etc/prometheus/secrets/ocp-prometheus.token)"

# HTTPS (인증서 검증 생략)
curl -vk https://haproxy-ip:443/path \
  -H "Host: 도메인명"

# TCP 포트 연결 확인 (Kafka, DB 등)
nc -zv haproxy-ip 29092
```

### 8.4 런타임 상태 확인 (socat)

```bash
# HAProxy 상태 정보
echo "show info" | socat stdio /var/run/haproxy.sock

# 서버 상태 (UP/DOWN)
echo "show servers state" | socat stdio /var/run/haproxy.sock

# 통계
echo "show stat" | socat stdio /var/run/haproxy.sock | cut -d',' -f1,2,18,19
```

또는 통계 웹 페이지 접속: `http://haproxy-ip:9999/`

---

## 9. 트러블슈팅

### 9.1 자주 나오는 증상

| 증상 | 원인 | 확인 방법 |
|------|------|----------|
| `503 Service Unavailable` | backend 서버 전체 DOWN | 통계 페이지 또는 `show servers state` |
| `502 Bad Gateway` | backend 응답 이상 | 서버 로그, `curl` 직접 테스트 |
| `No route to host` | 네트워크 경로 없음 | `ping`, `traceroute`, 방화벽 확인 |
| `400 Bad Request` | URL 인코딩 오류, Host 헤더 없음 | `curl -v`로 헤더 확인 |
| `403 Forbidden` | 토큰 오류, 파일 권한 문제 | 토큰 파일 소유자/권한 확인 |
| `000` (curl 응답 코드) | HAProxy가 HTTPS인데 HTTP로 요청 | scheme 확인 (`http://` vs `https://`) |

### 9.2 WARNING: `option httplog` in backend

```haproxy
# 잘못된 설정 (backend에 httplog → WARNING)
backend my-backend
    option httplog    ← WARNING 발생, 무시됨

# 올바른 위치: frontend 또는 listen
frontend my-frontend
    option httplog
```

### 9.3 설정 반영이 안 될 때

```bash
# 문법 오류 확인
haproxy -c -f /etc/haproxy/haproxy.cfg

# reload가 안 되면 restart (기존 연결 끊김 주의)
systemctl restart haproxy

# master-worker 모드 확인
ps aux | grep haproxy  # master + worker 프로세스 2개가 보여야 정상
```

### 9.4 포트 충돌

```bash
# 특정 포트를 점유한 프로세스 확인
ss -tlnp | grep 19090
lsof -i :19090
```

같은 서버에서 동일 포트를 두 설정이 쓰려 하면 bind 실패.  
ex) `old_dr_haproxy.cfg`의 `rhov-send-gw`가 `:19090`을 사용 중이면 같은 서버에 OCP federate도 `:19090`으로 추가 불가.

### 9.5 SNI/Host 불일치

OCP 등 가상 호스트 기반 서비스에서 `404` 또는 의도치 않은 응답이 올 때:

```bash
# SNI와 Host 헤더를 명시해서 직접 테스트
curl -vk https://192.168.1.54:443/federate \
  --resolve "prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr:443:192.168.1.54" \
  -H "Host: prometheus-k8s-federate-openshift-monitoring.apps.ocp4.nirs.go.kr" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 현재 설정 포트 맵 (`old_dr_haproxy.cfg`)

| 포트 | 이름 | 모드 | 대상 |
|------|------|------|------|
| 80 / 443 | oc-pipeline (frontend) | HTTP + SSL | 도메인별 ACL 분기 |
| 9999 | stats | HTTP | 통계 페이지 |
| 6443 | k8s-api-server | TCP | 10.0.0.17~19:6443 |
| 55000 | nexus-registry-https | TCP | 10.0.0.13:55000 |
| 18080 | nexus-application-http | TCP | 10.0.0.13:8081 |
| 31000~31003 | staging-cmp-* (rabbitmq/redis/vault) | TCP | 10.0.0.20~24 |
| 11306 | staging-cmp-db | TCP | 10.0.0.100:3306 |
| 32000~32013 | dev-cmp-* / dev-klid-* | TCP | 10.0.0.30~34 |
| 19090 | rhov-send-gw | TCP | 10.0.0.26:19090 |
| 11090/11070 | dj-osp/vmw-broker | TCP | 10.0.0.27 |
| 15080 | iaas-receive-gw | TCP | 10.0.0.27:15080 |
| 18200 / 8200 | vault | TCP | 10.0.0.20~21 |
| 5672 | rabbitmq | TCP | 10.0.0.20~21 |
| 6379 | redis | TCP | 10.0.0.20~21 |
| 3306 / 13306 | db | TCP | 10.0.0.28, 10.0.0.25 |
| 8888 | cicd-jenkins | TCP | 10.0.0.30:8080 |
| 30000 / 40000 | cicd-gitea | TCP | 10.0.0.30~31:3000 |
| 16443 | rhov | TCP | 172.30.3.54:6443 |
| 29092~29094 | dr-kafka-broker (DR) | TCP | 10.0.0.45~47 |
| 19092~19094 | primary-kafka-broker (주센터) | TCP | 192.168.1.54:19092~94 |
