# Phase 8c 구현 가이드 — 도메인 + HTTPS 전환 + 보안 점검

명세: [specs/spec_phase8c_https.md](../specs/spec_phase8c_https.md)

전제: [Phase 8 서버 배포](guide_phase8_deploy.md)가 완료되어 `http://{공인IP}`로 접속 가능한 상태.

---

## 전체 흐름

```
Step 1. 도메인 구매 (직접 진행)
Step 2. Cloudflare 연결 + DNS 설정
Step 3. Terraform — 443 포트 보안그룹 추가
Step 4. 서버 — certbot으로 Let's Encrypt 인증서 발급
Step 5. nginx HTTPS 설정
Step 6. 인증서 자동 갱신 설정
Step 7. 검증
Step 8. 보안 점검 (범위 B)
```

---

## Step 1. 도메인 구매

Namecheap, 가비아, Cloudflare Registrar 등 원하는 등록기관에서 도메인을 구매한다. 이 단계는 결제/계정 등록이 걸린 작업이라 직접 진행한다.

---

## Step 2. Cloudflare 연결 + DNS 설정

### 2-1. Cloudflare에 사이트 추가

1. [Cloudflare](https://dash.cloudflare.com) 가입 (무료 플랜으로 충분)
2. "Add a site" → 구매한 도메인 입력
3. 무료 플랜 선택
4. Cloudflare가 제시하는 네임서버 2개를 도메인 등록기관의 네임서버 설정에 등록 (등록기관 콘솔에서 진행)
5. 네임서버 전파까지 몇 분~몇 시간 소요될 수 있음

### 2-2. A 레코드 설정

Cloudflare DNS 탭에서:

| Type | Name | Content | Proxy status |
|------|------|---------|--------------|
| A | `@` (루트) 또는 원하는 서브도메인(예: `etude`) | `161.33.45.200` | DNS only (회색 구름) |

> **주의**: 처음에는 Proxy(주황 구름)를 끄고 "DNS only"로 설정한다. Cloudflare 프록시를 켠 상태로 Let's Encrypt 인증을 시도하면 도메인 소유권 검증이 Cloudflare IP를 거치게 되어 실패할 수 있다. 인증서 발급이 끝난 뒤 Step 6에서 필요시 다시 켠다.

DNS 전파 확인:

```bash
dig {도메인} +short
# 161.33.45.200 이 나오면 전파 완료
```

---

## Step 3. Terraform — 443 포트 보안그룹 추가

`infra/terraform/main.tf`의 `oci_core_security_list.etude`에 HTTPS 규칙 추가.

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

기존 SSH(22), HTTP(80) 규칙 사이 또는 뒤에 추가하면 된다. 로컬에서 적용:

```bash
cd infra/terraform
terraform plan
terraform apply
```

---

## Step 4. 서버 — certbot으로 인증서 발급

서버 SSH 접속 후:

```bash
sudo apt-get update
sudo apt-get install -y certbot

# nginx가 80 포트를 이미 쓰고 있으므로 standalone 모드는 충돌한다.
# certbot의 webroot 모드로 발급하거나, 잠시 nginx를 내리고 standalone으로 받는다.

# 방법 A — nginx 잠시 중지 후 발급 (간단, 짧은 다운타임 발생)
docker compose -f deploy/docker-compose.prod.yml --project-directory . stop nginx
sudo certbot certonly --standalone -d {도메인}
docker compose -f deploy/docker-compose.prod.yml --project-directory . start nginx
```

성공하면 인증서가 `/etc/letsencrypt/live/{도메인}/`에 생성된다 (`fullchain.pem`, `privkey.pem`).

---

## Step 5. nginx HTTPS 설정

### 5-1. `deploy/nginx.conf` 수정 (로컬에서)

```nginx
server {
    listen 80;
    server_name {도메인};
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name {도메인};
    root /usr/share/nginx/html;

    ssl_certificate     /etc/letsencrypt/live/{도메인}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{도메인}/privkey.pem;

    # WebSocket
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

### 5-2. `docker-compose.prod.yml`에 인증서 볼륨 마운트 + 443 포트 추가

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
    depends_on:
      - backend
    networks:
      - etude
```

### 5-3. 반영

```bash
git add deploy/nginx.conf deploy/docker-compose.prod.yml
git commit -m "..."
git push
```

서버에서:

```bash
git pull
docker compose -f deploy/docker-compose.prod.yml --project-directory . up -d --force-recreate nginx
```

---

## Step 6. 인증서 자동 갱신

certbot이 설치하는 systemd timer가 보통 자동으로 등록되지만, nginx가 Docker 컨테이너로 떠 있어 갱신 후 컨테이너 재시작이 별도로 필요할 수 있다.

```bash
# 갱신 시뮬레이션 (실제 갱신 안 함)
sudo certbot renew --dry-run
```

갱신 후 nginx 재시작 훅 추가:

```bash
sudo tee /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh > /dev/null << 'EOF'
#!/bin/bash
cd ~/etude
docker compose -f deploy/docker-compose.prod.yml --project-directory . restart nginx
EOF
sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh
```

---

## Step 7. 검증

- [ ] `https://{도메인}` 접속 시 인증서 경고 없이 정상 로드
- [ ] `http://{도메인}` 접속 시 자동으로 `https://`로 리다이렉트되는지 확인
- [ ] 로그인 등 API 호출이 HTTPS로 정상 동작하는지 확인
- [ ] `curl -I https://{도메인}`으로 응답 헤더 확인

---

## Step 8. 보안 점검 (범위 B)

명세의 "점검 항목" 표를 하나씩 확인한다.

### SSH 비밀번호 로그인 비활성화

```bash
sudo vi /etc/ssh/sshd_config
# PasswordAuthentication no 로 설정되어 있는지 확인, 아니면 수정
sudo systemctl restart sshd
```

### 방화벽 — 불필요한 포트 노출 확인

```bash
# OCI 보안 그룹 규칙과 무관하게, 서버 자체에서도 어떤 포트가 열려있는지 확인
sudo ss -tlnp
```

`3306`(DB)이 `0.0.0.0`이 아니라 `127.0.0.1`에만 바인딩되어 있는지 확인 — Phase 8에서 이미 `127.0.0.1:3306:3306`으로 설정했는지 [docker-compose.prod.yml](../../deploy/docker-compose.prod.yml) 재확인.

### OS 자동 업데이트

```bash
sudo apt list --upgradable
# 보안 업데이트 자동 적용 원하면
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 비밀 파일 노출 재확인

```bash
git ls-files | grep -E "\.env\.prod$|terraform\.tfvars$"
# 아무 결과도 나오지 않아야 정상 (git 추적 대상이 아님)
```

### Docker 소켓 마운트 위험

`backend` 컨테이너에 `/var/run/docker.sock`이 마운트되어 있어 샌드박스 컨테이너를 제어한다. 이 구조상 backend 자체가 뚫리면 호스트 전체 권한을 얻을 수 있다 — 근본적으로 없앨 수는 없는 설계(퀘스트 실습 컨테이너 생성/삭제가 핵심 기능이므로)지만, 최소한 backend 애플리케이션 자체의 보안(의존성 취약점, 인증 우회 등)에 더 신경 써야 한다는 점을 인지한다.

### JWT_SECRET / bcrypt 강도

```bash
# .env.prod의 JWT_SECRET이 openssl rand -base64 32 같은 충분히 긴 랜덤 값인지 확인
cat ~/etude/backend/.env.prod | grep JWT_SECRET
```

---

## 주의사항

- Cloudflare 프록시(주황 구름)를 켜면 실제 서버 IP가 숨겨져 방어에 도움이 되지만, WebSocket이나 특정 헤더 처리에 추가 설정이 필요할 수 있다 — 켤 경우 WebSocket(`/ws/`) 동작을 반드시 재검증한다.
- 인증서 발급/갱신 시 nginx를 잠시 내리는 방식(Step 4)은 짧은 다운타임이 생긴다. 트래픽이 늘면 webroot 모드로 전환을 고려한다.
