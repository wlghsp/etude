# Kafka HAProxy 리스너 설정 가이드

> 주센터 ↔ DR센터 간 Kafka 연동 시 HAProxy 포트 구성과 advertised.listeners 설정 이유를 정리한 문서입니다.

---

## 1. advertised.listeners란?

Kafka 브로커가 클라이언트에게 "나한테 이 주소로 연결해" 라고 알려주는 **광고 주소**입니다.

브로커가 실제로 바인딩하는 `listeners`와 다를 수 있습니다. 클라이언트는 bootstrap 연결 후 브로커로부터 메타데이터를 받고, 이후 통신은 `advertised.listeners`에 명시된 주소로 직접 연결합니다.

```properties
# 실제 바인딩 주소 (0.0.0.0 = 모든 인터페이스)
listeners=INTERNAL://0.0.0.0:9092,EXTERNAL://0.0.0.0:29092

# 클라이언트에게 광고하는 주소
advertised.listeners=INTERNAL://10.0.0.45:9092,EXTERNAL://192.168.1.54:29092
```

---

## 2. INTERNAL vs EXTERNAL 리스너

| | INTERNAL | EXTERNAL |
|---|---|---|
| **용도** | 브로커 간 통신, 같은 센터 내부 클라이언트 | 외부 센터 클라이언트 접근 |
| **광고 주소** | 브로커 실제 IP | HAProxy IP |
| **사용 주체** | 브로커 간 replication (`inter.broker.listener.name`) | 상대 센터 Logstash |

```properties
# INTERNAL: 브로커 간 통신에 사용
inter.broker.listener.name=INTERNAL

# advertised.listeners 예시 (DR 브로커1 기준)
advertised.listeners=INTERNAL://10.0.0.45:9092,EXTERNAL://192.168.1.54:29092
#                                 ^^^^^^^^^^           ^^^^^^^^^^^^
#                               DR 브로커 실제 IP      주센터 HAProxy IP
```

EXTERNAL이 없으면 브로커가 내부 IP를 광고하게 되어, 상대 센터 클라이언트가 도달할 수 없는 IP로 연결을 시도해 실패합니다.

---

## 3. 왜 브로커마다 포트가 달라야 하는가

### Kafka 클라이언트 동작 방식

1. 클라이언트가 bootstrap 주소로 최초 연결
2. 브로커로부터 **모든 브로커의 주소 목록(메타데이터)** 수신
3. 이후 파티션별 **리더 브로커에 직접 연결**

```
주센터 Logstash
  → bootstrap: 주센터 HAProxy(192.168.1.54):29092

브로커1이 메타데이터 응답:
  브로커1 = 192.168.1.54:29092
  브로커2 = 192.168.1.54:29093
  브로커3 = 192.168.1.54:29094

이후 Logstash:
  파티션0 리더가 브로커2 → 192.168.1.54:29093 으로 연결
  파티션1 리더가 브로커3 → 192.168.1.54:29094 으로 연결
```

### 포트 1개만 열면 안 되는 이유

HAProxy 1개 포트로 3개 브로커에 라운드로빈 분산은 가능하지만, 클라이언트가 특정 파티션의 **리더 브로커**에 연결해야 할 때 엉뚱한 브로커로 라우팅될 수 있습니다. 해당 브로커가 리더가 아니면 쓰기가 실패합니다.

브로커마다 포트를 분리하면 HAProxy가 **특정 포트 → 특정 브로커**로 1:1 매핑하므로 이 문제가 없습니다.

---

## 4. 전체 연결 흐름 (주센터 ↔ DR센터)

```
[주센터 Logstash]
  ↓ bootstrap (29092)
[주센터 HAProxy :29092-29094]
  ↓ TCP 포워딩
[DR HAProxy :29092-29094]
  ↓ TCP 포워딩
[DR Kafka 브로커1/2/3]
  ↓ 메타데이터 응답 (EXTERNAL advertised = 주센터 HAProxy IP)
[주센터 Logstash] → 이후 192.168.1.54:29092/29093/29094 으로 직접 통신
```

---

## 5. HAProxy 설정 요약

### 주센터 HAProxy (center_haproxy.cfg)
DR 카프카 접근용 — DR HAProxy로 포워딩

```
listen dr-kafka-broker1  bind *:29092  → DR HAProxy:29092
listen dr-kafka-broker2  bind *:29093  → DR HAProxy:29093
listen dr-kafka-broker3  bind *:29094  → DR HAProxy:29094
```

### DR HAProxy (dr_haproxy.cfg)
DR 카프카 브로커와 직접 연결

```
listen dr-kafka-broker1  bind *:29092  → DR 브로커1(10.0.0.45):29092
listen dr-kafka-broker2  bind *:29093  → DR 브로커2(10.0.0.46):29093
listen dr-kafka-broker3  bind *:29094  → DR 브로커3(10.0.0.47):29094
```

---

## 6. 방화벽 허용 포트

양 센터 간 방화벽에서 허용이 필요한 포트 (TCP):

| 포트 | 방향 | 설명 |
|------|------|------|
| 29092 | 주센터 → DR | DR 카프카 브로커1 (센터 간 외부 구간) |
| 29093 | 주센터 → DR | DR 카프카 브로커2 |
| 29094 | 주센터 → DR | DR 카프카 브로커3 |
| 19092 | DR → 주센터 | 주센터 카프카 브로커1 (센터 간 외부 구간) |
| 19093 | DR → 주센터 | 주센터 카프카 브로커2 |
| 19094 | DR → 주센터 | 주센터 카프카 브로커3 |

**포트를 6개 쓰는 이유:** 같은 HAProxy에서 `bind *:29092`를 두 용도(DR 접근용 + 주센터 노출용)로 선언하면 포트 충돌로 HAProxy가 기동 불가합니다. 외부 구간(센터 간) 포트와 내부 접근 포트를 분리해서 사용합니다.

---

## 7. 트러블슈팅

### 증상: Logstash에서 Bootstrap broker disconnected 반복

Kafka 연결 실패 시 TCP 레벨은 성공해도 Kafka 프로토콜 레벨에서 DisconnectException이 발생할 수 있습니다. 경로가 길어서 어느 구간에서 문제인지 단계별로 확인해야 합니다.

**확인 순서:**

```bash
# 1. HAProxy까지 TCP 연결 확인
curl -v telnet://<HAProxy IP>:<포트>

# 2. HAProxy → 백엔드 브로커 연결 확인 (HAProxy stats)
curl http://localhost:9999/

# 3. 브로커가 해당 포트를 실제로 열고 있는지 확인
ss -tlnp | grep <포트>

# 4. Kafka 프로토콜 레벨 연결 확인
kafka-broker-api-versions.sh --bootstrap-server <HAProxy IP>:<포트>
```

---

### 사례 1: HAProxy 백엔드 포트 불일치

**증상:** TCP 연결은 성공하지만 Kafka 프로토콜 레벨에서 DisconnectException

**원인:** HAProxy 백엔드 server 설정의 포트가 브로커가 실제로 열고 있는 포트와 다름

```
# 잘못된 예 — 브로커가 29092를 열지 않음
server dr-kafka1 10.0.0.45:29092

# 올바른 예 — 브로커가 실제로 열고 있는 포트
server dr-kafka1 10.0.0.45:19092
```

**해결:** 브로커 서버에서 `ss -tlnp`로 실제 열린 포트 확인 후 HAProxy 백엔드 포트와 일치시킬 것

---

### 사례 2: advertised.listeners INTERNAL에 외부 접근 가능 IP 설정

**증상:** 외부 클라이언트(상대 센터 Logstash)가 bootstrap은 성공하지만 이후 연결에서 DisconnectException 반복

**원인:** Kafka 클라이언트는 bootstrap 후 메타데이터 응답에서 **모든 리스너 주소**를 받아옵니다. INTERNAL 주소가 외부에서 접근 가능한 IP로 설정되어 있으면, 외부 클라이언트가 INTERNAL 주소로도 접속을 시도합니다.

```properties
# 잘못된 예 — INTERNAL에 HAProxy IP 설정
advertised.listeners=INTERNAL://192.168.1.54:19092,EXTERNAL://172.30.1.223:19092
# DR Logstash가 192.168.1.54:19092 로 접속 시도 → DR에서 접근 불가 → 실패

# 올바른 예 — INTERNAL에 K8s 내부 DNS 설정
advertised.listeners=INTERNAL://svc-kafka-1:9092,EXTERNAL://172.30.1.223:19092
# svc-kafka-1은 외부에서 resolve 불가 → DR Logstash가 EXTERNAL 주소만 사용
```

**해결:** INTERNAL에는 외부 클라이언트가 접근할 수 없는 주소(K8s 내부 DNS, 내부 전용 IP)를 설정할 것. 외부 클라이언트는 resolve 불가한 INTERNAL을 건너뛰고 EXTERNAL 주소만 사용하게 됩니다.

**환경별 INTERNAL 설정 방법:**

| 환경 | INTERNAL 설정 | 이유 |
|------|--------------|------|
| VM (베어메탈) | `10.0.0.45:9092` (센터 내부 IP) | 상대 센터에서 라우팅 불가한 내부 IP |
| K8s (RHOV 등) | `svc-kafka-1:9092` | 클러스터 내부 DNS — 외부에서 resolve 불가 |

두 경우 모두 **외부 클라이언트가 INTERNAL 주소 접속에 실패하거나 resolve 불가로 스킵 → EXTERNAL 주소만 사용**하는 결과가 됩니다.

```properties
# [일반적인 경우] VM 환경 예시 (DR 브로커1: 10.0.0.45)
advertised.listeners=INTERNAL://10.0.0.45:9092,EXTERNAL://192.168.1.54:19092
# 10.0.0.45는 DR 내부 IP → 주센터 Logstash에서 접근 불가 → EXTERNAL로만 연결

# [특수한 경우] K8s 환경 예시 (주센터 브로커1 — RHOV 위 VM pod)
advertised.listeners=INTERNAL://svc-kafka-1:9092,EXTERNAL://172.30.1.223:19092
# svc-kafka-1은 K8s 내부 DNS → 외부에서 resolve 불가 → EXTERNAL로만 연결
```

---

### 사례 3: HAProxy가 INTERNAL 리스너 포트로 포워딩하여 잘못된 메타데이터 반환

**증상:** bootstrap 연결은 성공하지만 이후 클라이언트가 접근 불가한 INTERNAL 주소로 재접속 시도

**원인:** Kafka 브로커는 **연결이 들어온 리스너 포트**를 기준으로 메타데이터 응답을 결정합니다.

```
NodePort 30192 → 브로커 9092 (INTERNAL 리스너) → 메타데이터: INTERNAL advertised 반환
NodePort 30194 → 브로커 9094 (EXTERNAL 리스너) → 메타데이터: EXTERNAL advertised 반환
```

HAProxy 백엔드가 INTERNAL NodePort(30192)로 포워딩하면 브로커가 INTERNAL 리스너로 인식 → INTERNAL 주소(`svc-kafka-1:9092`) 반환 → 외부 클라이언트가 resolve 실패 또는 접근 불가 주소로 재접속 시도.

```
# 잘못된 예 — INTERNAL NodePort로 포워딩
server kafka-1 192.168.1.56:30192   ← 9092(INTERNAL) 포트

# 올바른 예 — EXTERNAL NodePort로 포워딩
server kafka-1 192.168.1.56:30194   ← 9094(EXTERNAL) 포트
```

**해결:** HAProxy 백엔드를 EXTERNAL 리스너에 매핑된 NodePort로 변경. 브로커가 EXTERNAL 리스너로 인식 → EXTERNAL advertised 주소 반환 → 외부 클라이언트가 접근 가능한 주소로 재접속 성공.

**한 마디로:** "어느 문으로 들어왔느냐에 따라 브로커가 다른 주소를 알려준다."
