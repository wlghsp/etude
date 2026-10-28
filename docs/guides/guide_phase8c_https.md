# Phase 8c 구현 가이드 — 도메인 + HTTPS 전환 + 보안 점검

명세: [specs/spec_phase8c_https.md](../specs/spec_phase8c_https.md)

전제: [Phase 8 서버 배포](completed/guide_phase8_deploy.md)가 완료되어 `http://{공인IP}`로 접속 가능한 상태.

> 이 문서의 8단계를 보고 도메인을 연결하고 HTTPS로 전환합니다.

## 왜 하는가

- 지금은 `http://{공인IP}`로만 서비스 중이라 **로그인 비밀번호가 평문으로 오간다.**
- 브라우저(HTTPS 우선 모드, 주소 자동 전환)가 자꾸 `https://`로 접속을 시도하는데 서버가 443을 열지 않아
  "연결 안 됨"이 된다. 실제로 2026-10-28에 서버는 정상이었는데 접속이 안 되는 것처럼 보인 원인이 이것이었다.
- 팀원에게 IP 대신 바뀌지 않는 주소를 줄 수 있다.

---

## 전체 흐름

```
Step 1. 도메인 구매 (직접 진행)
Step 2. DNS 설정 (Cloudflare)
Step 3. 방화벽 — OCI 보안 목록에 443 열기 (서버 iptables는 확인만)
Step 4. 인증서 발급 준비 — nginx에 ACME 경로 열기 → certbot(webroot)
Step 5. nginx HTTPS 설정
Step 6. 인증서 자동 갱신 설정
Step 7. 검증
Step 8. 보안 점검 (범위 B)
```

> 순서가 중요하다. 인증서가 생기기 **전에** nginx에 `ssl_certificate` 설정을 넣으면 파일이 없어서 nginx가
> 기동하지 못하고, 서비스 전체가 멈춘다. 그래서 먼저 HTTP만으로 인증서를 받고(Step 4), 그다음 HTTPS를
> 켠다(Step 5).

---

## Step 1. 도메인 구매

**Cloudflare Registrar**에서 구매하는 것을 추천한다.

- 원가(도매가)로 판매해서 갱신 때 가격이 오르지 않고, WHOIS 개인정보 보호가 기본이다.
- DNS도 같은 곳에 생기므로 **네임서버 변경 작업이 필요 없다** (Step 2-1 건너뜀).
- 다른 등록기관(Namecheap, 가비아)에서 사도 된다. 그 경우 Step 2-1의 네임서버 변경이 필요하다.

선택 기준:

- 확장자는 `.dev` 또는 `.com`. `.dev`는 브라우저에서 HTTPS가 강제되는 도메인이다.
- 이름에 회사명(`okestro` 등)은 넣지 않는다.
- `.xyz`, `.top`처럼 아주 싼 확장자는 스팸 평판이 나빠 피한다.
- **자동 갱신을 켠다.** 도메인이 만료되면 서비스가 통째로 사라진다.

결제와 계정 등록이 걸린 단계라 직접 진행한다. 후보 이름이 정해지면 구매 화면에서 한 번 더 사용 가능 여부를 확인한다.

---

## Step 2. DNS 설정 (Cloudflare)

### 2-1. Cloudflare에 사이트 추가 (Cloudflare 외 등록기관에서 샀을 때만)

1. [Cloudflare](https://dash.cloudflare.com) 가입 (무료 플랜으로 충분)
2. "Add a site" → 구매한 도메인 입력 → 무료 플랜 선택
3. Cloudflare가 제시하는 네임서버 2개를 도메인 등록기관의 네임서버 설정에 등록
4. 전파까지 몇 분~몇 시간 소요

### 2-2. A 레코드 설정

Cloudflare DNS 탭에서:

| Type | Name | Content | Proxy status |
|------|------|---------|--------------|
| A | `@` (루트) 또는 서브도메인(예: `app`) | `161.33.45.200` | DNS only (회색 구름) |

> **주의**: 처음에는 Proxy(주황 구름)를 끄고 "DNS only"로 둔다. 프록시를 켠 상태에서 인증서를 받으면 도메인 검증
> 요청이 Cloudflare를 거치게 되어 실패할 수 있다. 프록시는 모든 것이 동작한 뒤에 켤지 판단한다("주의사항" 참고).

DNS 전파 확인:

```bash
dig {도메인} +short
# 161.33.45.200 이 나오면 전파 완료
```

---

## Step 3. 방화벽 — 443 열기

443은 **두 군데**에서 열어야 한다. 하나라도 막혀 있으면 접속이 안 된다.

### 3-1. OCI 보안 목록 (Terraform)

`infra/terraform/main.tf`의 `oci_core_security_list.etude`에 HTTPS 규칙을 추가한다 (기존 80 규칙 뒤에).

```hcl
  # HTTPS
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
```

```bash
cd infra/terraform
terraform plan     # 변경 내용 확인
terraform apply
```

> **`terraform plan` 결과를 꼭 읽는다.** 보안 목록만 `update in-place`로 바뀌어야 한다. 인스턴스가
> `must be replaced`(재생성)로 나오면 **apply 하지 말고 멈춘다.** 서버 전체가 새로 만들어진다는 뜻이다.

### 3-2. 서버 자체 방화벽 (iptables) — 확인만 한다

서버 안의 iptables 상태를 확인한다.

```bash
sudo iptables -L INPUT -n --line-numbers
```

OCI Ubuntu 이미지의 INPUT 체인은 보통 `22(SSH)`만 허용하고 나머지를 `REJECT`한다. 그런데도 80이 접속되는 이유는
**Docker가 `ports:`로 게시한 포트는 INPUT 체인을 거치지 않기 때문이다.** 외부 패킷이 nat 테이블에서 컨테이너로 바로
전달(FORWARD)된다. 그래서 nginx에 `"443:443"`을 게시하면(Step 5-2) **iptables 규칙을 추가하지 않아도 443이 통과한다.**

- 80 허용 규칙이 없는데 80이 접속되고 있다면 → **이 단계에서 할 일은 없다.** 규칙을 건드리지 않는다
  (잘못 넣으면 SSH가 막힐 수 있다).
- 이 구조 때문에 INPUT 규칙으로는 Docker 게시 포트를 막을 수 없다. DB(3306)를 외부에서 막는 것은 INPUT이 아니라
  compose의 `127.0.0.1:3306:3306` 바인딩이다 (Step 8 참고).

443이 열렸는지는 Step 5 이후 외부에서 `nc -vz {도메인} 443`으로 확인한다.

---

## Step 4. 인증서 발급 (webroot 방식)

### 왜 webroot인가

`certbot --standalone`은 인증 때 80 포트를 직접 열기 때문에 nginx가 80을 쓰는 동안은 쓸 수 없다. 처음 발급은
nginx를 잠깐 내리면 되지만, **90일마다 하는 자동 갱신도 같은 방식으로 80을 열려고 해서 실패한다.** 그러면 석 달 뒤
인증서가 만료되어 접속이 안 된다. 그래서 nginx가 계속 80을 쓰면서 인증용 파일을 내주는 `webroot` 방식을 쓴다.

### 4-1. nginx가 인증용 경로를 내주도록 준비

서버에서 인증용 폴더를 만든다.

```bash
sudo mkdir -p /var/www/certbot
```

`deploy/docker-compose.prod.yml`의 nginx 볼륨에 한 줄을 추가한다 (포트 443과 `/etc/letsencrypt` 마운트는
Step 5에서 같이 넣는다).

```yaml
    volumes:
      - ./frontend/dist:/usr/share/nginx/html:ro
      - ./deploy/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /var/www/certbot:/var/www/certbot:ro       # 추가
```

`deploy/nginx.conf`의 `server` 블록 맨 위에 인증용 경로를 추가한다 (기존 내용은 그대로).

```nginx
server {
    listen 80;
    root /usr/share/nginx/html;

    # Let's Encrypt 도메인 검증용 (인증서 발급/갱신)
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # ... (기존 location 블록들 그대로)
}
```

반영한다.

```bash
# 로컬에서 커밋·푸시 후 서버에서
cd ~/etude && git pull
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --force-recreate nginx
```

### 4-2. 인증서 발급

```bash
sudo apt-get update
sudo apt-get install -y certbot

sudo certbot certonly --webroot -w /var/www/certbot -d {도메인}
```

성공하면 `/etc/letsencrypt/live/{도메인}/`에 `fullchain.pem`, `privkey.pem`이 생긴다.

> 실패하면 `curl -I http://{도메인}/.well-known/acme-challenge/test`를 해 본다. 404여도 nginx까지 도착한 것이니
> 정상이고, 연결이 안 되면 DNS(Step 2)나 80 포트 쪽 문제다.

---

## Step 5. nginx HTTPS 설정

### 5-1. `deploy/nginx.conf` 수정 (로컬에서)

80 포트는 모든 요청을 **도메인의 HTTPS로 보낸다.** `http://{공인IP}`로 들어와도 도메인으로 넘어가므로, 사용자가 IP
주소를 신경 쓸 필요가 없어진다.

```nginx
server {
    listen 80 default_server;
    server_name _;

    # 인증서 갱신용 (webroot) — 리다이렉트보다 먼저 매칭된다
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://{도메인}$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name {도메인};
    root /usr/share/nginx/html;

    ssl_certificate     /etc/letsencrypt/live/{도메인}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{도메인}/privkey.pem;

    # WebSocket (백엔드 라우트가 /api 접두사 없이 등록되어 있으므로 먼저 매칭)
    location /ws/ {
        proxy_pass http://backend:3001/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 3600s;
    }

    location = / {
        try_files /index.html @backend;
    }

    location / {
        try_files $uri @backend;
    }

    location @backend {
        proxy_pass http://backend:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 5-2. `deploy/docker-compose.prod.yml`

```yaml
  nginx:
    image: nginx:alpine
    container_name: etude-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./frontend/dist:/usr/share/nginx/html:ro
      - ./deploy/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - /var/www/certbot:/var/www/certbot:ro
    depends_on:
      - backend
    networks:
      - etude
```

`/etc/letsencrypt` 전체를 마운트해야 한다. `live/` 안의 파일은 `archive/`로 가는 심볼릭 링크라서 `live/`만 마운트하면
링크가 끊어진다.

### 5-3. 반영

```bash
# 서버에서
cd ~/etude && git pull
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --force-recreate nginx
docker logs --tail 20 etude-nginx     # emerg 같은 오류가 없어야 함
```

---

## Step 6. 인증서 자동 갱신

certbot 패키지가 systemd 타이머를 자동으로 등록한다. 타이머가 있는지, 갱신 시뮬레이션이 되는지 확인한다.

```bash
systemctl list-timers | grep certbot
sudo certbot renew --dry-run          # 실제 갱신은 하지 않는 시뮬레이션
```

`dry-run`이 `Congratulations, all simulated renewals succeeded`로 끝나야 한다. 이게 실패하면 90일 뒤 같은 이유로
실제 갱신도 실패한다.

갱신된 인증서를 nginx가 읽으려면 reload가 필요하다. 갱신 직후 자동으로 하도록 훅을 건다.

```bash
sudo tee /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh > /dev/null << 'EOF'
#!/bin/bash
docker exec etude-nginx nginx -s reload
EOF
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
```

- `docker exec ... nginx -s reload`는 **컨테이너를 재시작하지 않고 설정과 인증서만 다시 읽는다** (다운타임 없음).
- 훅은 root로 실행되므로 `cd ~/etude` 같은 홈 경로를 쓰지 않는다 (`~`가 `/root`가 되어 경로를 못 찾는다).

---

## Step 7. 검증

```bash
curl -I https://{도메인}
curl -I http://{도메인}        # 301 → https://{도메인}
curl -I http://161.33.45.200    # 301 → https://{도메인}
nc -vz {도메인} 443
```

- [ ] `https://{도메인}` 접속 시 인증서 경고 없이 정상 로드
- [ ] `http://{도메인}`, `http://{공인IP}` 접속 시 `https://{도메인}`으로 리다이렉트
- [ ] 로그인과 퀘스트 터미널(**WebSocket**)이 HTTPS에서 동작 (`wss://`로 연결됨)
- [ ] `sudo certbot renew --dry-run` 성공
- [ ] 인증서 만료일 확인: `sudo certbot certificates`

---

## Step 8. 보안 점검 (범위 B)

명세의 "점검 항목" 표를 하나씩 확인한다.

### SSH 비밀번호 로그인 비활성화

```bash
sudo grep -E "^PasswordAuthentication" /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf
# PasswordAuthentication no 여야 한다. 아니면 수정 후
sudo systemctl restart ssh
```

> 설정 변경 전에 **현재 SSH 세션을 열어 둔 채** 다른 터미널에서 키로 새로 접속되는지 확인한다.
> 잘못 바꾸면 서버에 못 들어간다.

### 방화벽 — 불필요한 포트 노출 확인

```bash
sudo ss -tlnp
```

`3306`(DB)이 `0.0.0.0`이 아니라 `127.0.0.1`에만 바인딩되어 있는지 확인한다.
[docker-compose.prod.yml](../../deploy/docker-compose.prod.yml)에 `127.0.0.1:3306:3306`으로 설정돼 있다.

### OS 자동 업데이트

```bash
sudo apt list --upgradable
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 비밀 파일 노출 재확인

```bash
git ls-files | grep -E "\.env\.prod$|terraform\.tfvars$|terraform\.tfstate"
# 아무 결과도 나오지 않아야 정상 (git 추적 대상이 아님)
```

### Docker 소켓 마운트 위험

`backend` 컨테이너에 `/var/run/docker.sock`이 마운트되어 있어 샌드박스 컨테이너를 제어한다. backend가 뚫리면 호스트
전체 권한을 얻을 수 있는 구조다. 샌드박스 생성이 핵심 기능이라 없앨 수는 없으므로, backend 자체의 보안(의존성
취약점, 인증 우회)에 더 신경 쓴다는 점을 인지한다. 의존성 점검은 `npm audit`로 한다.

### JWT_SECRET / bcrypt 강도

```bash
grep JWT_SECRET ~/etude/backend/.env.prod
# openssl rand -base64 32 같은 충분히 긴 랜덤 값이어야 한다 (코드의 기본값 'dev-secret'이면 위험)
```

---

## 주의사항

- **Cloudflare 프록시(주황 구름)**를 켜면 서버 IP가 숨겨져 방어에 도움이 되지만, 켜기 전에 다음을 지킨다.
  - Cloudflare의 SSL/TLS 모드를 **Full (strict)**으로 설정한다. `Flexible`은 Cloudflare와 서버 사이가 HTTP라서
    비밀번호 보호가 반쪽이다.
  - 켠 뒤에 **WebSocket(`/ws/`) 터미널이 동작하는지** 반드시 다시 확인한다.
  - 프록시를 켜면 `webroot` 갱신도 Cloudflare를 거치므로, 켠 뒤에도 `certbot renew --dry-run`을 다시 돌려 본다.
- **갱신 실패는 조용히 일어난다.** 모니터링 도구를 붙일 때 인증서 만료일 감시를 함께 넣는다.
- HSTS(`Strict-Transport-Security`) 헤더는 한 번 브라우저에 기억되면 되돌리기 어렵다. 모든 것이 안정된 뒤에
  `max-age`를 짧게(예: 300초) 시작해서 늘려 간다. 이번 단계에서는 넣지 않는다.
