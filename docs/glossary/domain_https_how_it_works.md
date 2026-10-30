# 도메인과 HTTPS는 어떻게 동작하나

도메인을 사서 서버에 연결하고, `https://etudequest.com`으로 접속되기까지 **무슨 일이 어디서 일어나는지**를 설명한다. Etude에 실제로 적용한 내용(Phase 8c)을 예로 든다.

## 한눈에 보기

주소창에 도메인을 치고 안전하게 접속되려면 네 가지가 맞아야 한다.

| # | 필요한 것 | 비유 | Etude에서 한 일 |
|---|-----------|------|-----------------|
| 1 | **이름 → 주소** 변환 (DNS) | 전화번호부 | `etudequest.com` → `161.33.45.200` 등록 |
| 2 | 서버로 들어오는 **문** 열기 (포트, 방화벽) | 건물 출입문 | 443번 문을 클라우드 방화벽에 추가 |
| 3 | 서버에서 **그 문을 지키는 프로그램** (nginx) | 문지기 | 443에서 HTTPS를 받도록 nginx 설정 |
| 4 | 이 서버가 진짜라는 **증명서** (TLS 인증서) | 신분증 | Let's Encrypt에서 무료 발급 |

---

## 1. 도메인은 "이름표"일 뿐이다

컴퓨터끼리는 숫자 주소(IP, 예: `161.33.45.200`)로만 통신한다. 사람이 외우기 어려우니 **도메인(이름)** 을 만들었고, 이름을 숫자로 바꿔 주는 시스템이 **DNS**다.

도메인을 "산다"는 것은 서버를 사는 게 아니다. **그 이름을 일정 기간(보통 1년) 내 이름으로 등록할 권리**를 사는 것이다. 이름과 서버는 별개이고, 연결은 내가 직접 해야 한다.

### 도메인 연결 과정

```
① 도메인 구매 (등록기관)
      │  "etudequest.com은 내 거야"
      ▼
② DNS 관리처 지정 (네임서버)
      │  "이 이름의 주소 정보는 여기(예: Cloudflare)에 물어봐"
      ▼
③ DNS 레코드 등록
         A 레코드:  etudequest.com  →  161.33.45.200
```

- **등록기관**: 도메인을 파는 곳. 이름의 소유권을 관리한다.
- **네임서버 / DNS 관리처**: "이 이름은 어느 IP야?"라는 질문에 답해 주는 서버. 등록기관이 직접 맡을 수도 있고 Cloudflare 같은 곳에 맡길 수도 있다.
- **A 레코드**: "이 이름 = 이 IPv4 주소"라는 한 줄짜리 규칙. 지금 쓰는 핵심 설정은 이것 하나다.
- **Cloudflare의 "DNS only"(회색 구름)**: 전화번호부 역할만 하고 트래픽은 거치지 않는다. 주황색 구름(프록시)으로 켜면 Cloudflare가 중간에서 HTTPS를 대신 받아서, 우리 서버의 인증서 구조가 달라진다. 우리는 서버가 직접 HTTPS를 받도록 했으므로 회색이다.

### 변경이 바로 반영되지 않을 수 있다

DNS 응답은 전 세계 여기저기에 **일정 시간(TTL) 동안 기억(캐시)** 된다. 레코드를 바꿔도 몇 분~몇 시간은 예전 값이 보일 수 있다. 확인은 이렇게 한다.

```bash
dig +short etudequest.com     # 161.33.45.200 이 나오면 연결된 것
```

---

## 2. 문(포트)과 방화벽

IP가 "건물 주소"라면 **포트**는 건물 안의 "문 번호"다. 웹은 관례적으로 이렇게 쓴다.

| 포트 | 용도 |
|------|------|
| 80 | HTTP (암호화 없음) |
| 443 | HTTPS (암호화) |
| 22 | SSH (서버 원격 접속) |

문이 열려 있어도 **방화벽이 막으면** 들어올 수 없다. 우리 서버에는 방화벽이 두 겹 있다.

1. **클라우드 방화벽 (OCI 보안 목록)**: 서버 바깥에서 먼저 거른다. Terraform으로 관리하며, 여기에 **443을 추가**하는 것이 HTTPS의 필수 선행 조건이었다. 이 문이 없으면 요청이 서버에 닿지도 못한다.
2. **서버 안의 방화벽 (iptables)**: 서버 안에서 한 번 더 거른다. 단, Docker가 연 포트(80, 443)는 Docker가 만든 별도 경로를 타서 이 규칙을 거치지 않는다. 그래서 여기에 따로 443을 열 필요는 없었다.

---

## 3. HTTP와 HTTPS의 차이

- **HTTP**: 내용을 그대로 보낸다. 중간에 누군가 지켜보면 로그인 비밀번호까지 보인다.
- **HTTPS** = HTTP + **TLS(암호화)**: 내용을 암호화해서 보낸다. 중간에서 봐도 알아볼 수 없다.

HTTPS가 해 주는 일은 두 가지다.

1. **암호화**: 내용을 못 훔쳐보게 한다.
2. **신원 확인**: 지금 연결된 서버가 진짜 `etudequest.com`인지 확인한다. 가짜 서버가 흉내 내는 것을 막는다.

### TLS 인증서가 하는 일

인증서는 **"이 공개키는 etudequest.com의 것이 맞다"라고 믿을 수 있는 기관(CA)이 서명한 증명서**다.

브라우저는 접속할 때 이렇게 확인한다.

```
브라우저                                   서버
   │ ── "안전하게 연결하고 싶어" ───────────▶ │
   │ ◀── 인증서(+공개키) 전달 ─────────────── │
   │
   │ 확인 ① 인증서에 적힌 도메인이 내가 입력한 도메인과 같은가?
   │ 확인 ② 믿는 CA(Let's Encrypt 등)가 서명했나? 만료 안 됐나?
   │
   │ ── 암호화에 쓸 임시 비밀을 서로 합의 ──▶ │
   │ ◀══════ 이후 모든 통신은 암호화 ═══════▶ │
```

- 인증서는 **도메인에 묶여 발급**된다. IP 주소에는 보통 발급되지 않는다. 그래서 도메인이 필요했다.
- 브라우저가 CA를 믿는 이유는 운영체제·브라우저에 **믿을 수 있는 CA 목록이 미리 들어 있기** 때문이다. 직접 만든 인증서(자체 서명)는 이 목록에 없어서 "안전하지 않음" 경고가 뜬다.
- 서버가 가진 파일은 두 개다.
  - `fullchain.pem`: 인증서 (공개해도 되는 것)
  - `privkey.pem`: **개인키 (절대 노출 금지)**. 서버만 가지고 있어야 신분을 증명할 수 있다.

---

## 4. 인증서는 어떻게 받나 (Let's Encrypt)

**Let's Encrypt**는 무료로 인증서를 주는 CA다. 대신 인증서 수명이 **90일**로 짧아서 **자동 갱신**이 전제다. 발급·갱신을 대신해 주는 프로그램이 **certbot**이다.

### "이 도메인 진짜 네 거 맞아?" 검증 (HTTP-01)

CA는 아무에게나 인증서를 줄 수 없으니, **그 도메인을 실제로 통제하고 있는지** 확인한다.

```
① certbot → CA:  "etudequest.com 인증서를 받고 싶어요"
② CA → certbot:  "그럼 http://etudequest.com/.well-known/acme-challenge/<토큰> 에
                  내가 말한 내용의 파일을 올려 봐"
③ certbot:       그 위치에 파일을 놓는다
④ CA:            인터넷에서 그 주소를 열어 본다
                 → 내용이 맞으면 "이 도메인을 통제하고 있구나" 확인 완료
⑤ CA → certbot:  인증서 발급
```

여기서 중요한 점:

- 확인은 **80번 포트(HTTP)** 로 이루어진다. 그래서 80이 인터넷에 열려 있어야 한다.
- 도메인의 DNS가 이 서버 IP를 가리키고 있어야 CA가 이 서버에 도달한다. (그래서 1번 DNS 설정이 먼저다.)
- 서버에서 그 경로(`/.well-known/acme-challenge/`)가 **파일을 내줘야** 한다.

### certbot의 두 가지 방식

| 방식 | 동작 | 장단점 |
|------|------|--------|
| `--standalone` | certbot이 **임시로 80번 포트를 직접 쓴다** | 간단하지만 nginx가 이미 80을 쓰고 있으면 충돌한다. 갱신도 같은 문제가 반복된다. |
| `--webroot` | certbot은 **폴더에 파일만 놓고**, nginx가 그 폴더를 인터넷에 내준다 | nginx를 멈출 필요가 없어 자동 갱신에 적합하다. **Etude가 쓰는 방식.** |

---

## 5. 서버에서 실제로 한 설정

### nginx: HTTPS를 받고 80은 되돌려 보내기

[deploy/nginx.conf](../../deploy/nginx.conf)의 핵심 구조다.

```nginx
# 80번 문: 두 가지만 한다
server {
    listen 80 default_server;

    # ① 인증서 검증용 파일은 그대로 내준다 (certbot webroot)
    location /.well-known/acme-challenge/ { root /var/www/certbot; }

    # ② 나머지는 전부 https 주소로 돌려보낸다 (301 = 영구 이동)
    location / { return 301 https://etudequest.com$request_uri; }
}

# 443번 문: 인증서를 들고 HTTPS를 받는다
server {
    listen 443 ssl;
    server_name etudequest.com;

    ssl_certificate     /etc/letsencrypt/live/etudequest.com/fullchain.pem;  # 인증서
    ssl_certificate_key /etc/letsencrypt/live/etudequest.com/privkey.pem;    # 개인키

    # 화면 파일은 직접, 그 외 요청은 backend로, /ws/ 는 WebSocket으로 넘긴다
}
```

- `listen 443 ssl`: 이 문에서는 TLS 암호화를 처리하겠다는 뜻이다.
- 80번의 301 리다이렉트 덕분에 누가 `http://`로 들어와도, IP 주소로 들어와도 자동으로 `https://etudequest.com`으로 옮겨진다.
- nginx가 TLS를 **끝까지 처리**하고, 뒤의 backend와는 서버 내부에서 평문으로 통신한다. 외부 구간만 암호화하면 되기 때문이다.

### Docker: nginx가 파일을 볼 수 있게 연결(마운트)

[deploy/docker-compose.prod.yml](../../deploy/docker-compose.prod.yml)의 nginx 설정이다. 컨테이너는 기본적으로 서버의 파일을 못 보기 때문에 필요한 폴더를 직접 이어 준다.

```yaml
ports:
  - "80:80"
  - "443:443"            # 443번 문을 컨테이너로 연결
volumes:
  - /var/www/certbot:/var/www/certbot:ro        # 검증용 파일 (certbot이 놓고 nginx가 내줌)
  - /etc/letsencrypt:/etc/letsencrypt:ro        # 인증서 (읽기 전용)
```

`/etc/letsencrypt`는 폴더 **전체**를 연결해야 한다. `live/` 안의 파일들이 실제로는 `archive/`를 가리키는 링크(심볼릭 링크)라서, 일부만 연결하면 링크가 끊긴다.

---

## 6. 요청 하나가 도착하기까지

사용자가 `https://etudequest.com`을 입력했을 때의 전체 흐름이다.

```
① 브라우저가 DNS에 묻는다     "etudequest.com 주소가 뭐야?"  → 161.33.45.200
② 161.33.45.200:443 으로 접속 (클라우드 방화벽이 443을 통과시킴)
③ nginx가 인증서를 보여 준다  → 브라우저가 검증 → 암호화 연결 수립 (TLS)
④ 암호화된 채로 요청을 보낸다  "GET /" 또는 "POST /login ..."
⑤ nginx가 처리
      ├─ 화면 파일(HTML/JS/CSS)이면 직접 응답
      ├─ 그 외(API)면 backend 컨테이너로 전달
      └─ /ws/ 이면 WebSocket 연결을 backend로 연결 (터미널)
⑥ 응답이 같은 암호화 연결을 타고 돌아온다
```

---

## 7. 갱신은 어떻게 되나

- 인증서는 **90일**이고, certbot은 **만료 30일 전부터** 갱신을 시도한다.
- 서버의 `certbot.timer`(systemd 타이머)가 하루 두 번 확인한다.
- 갱신은 처음 발급과 같은 검증(4번)을 다시 한다. 그래서 `--webroot`가 갱신에도 통해야 한다.
- 새 인증서 파일이 생겨도 **nginx는 시작할 때 읽은 인증서를 메모리에 들고 있어서** 모른다. 갱신 직후 `nginx -s reload`로 다시 읽게 해야 한다. 이를 자동화하는 것이 **갱신 후 훅(deploy hook)** 이다.

---

## 8. 이 프로젝트에서 어디를 보면 되나

| 알고 싶은 것 | 위치 |
|--------------|------|
| 80/443 처리, 리다이렉트, 인증서 경로 | [deploy/nginx.conf](../../deploy/nginx.conf) |
| 포트 연결, 인증서 폴더 마운트 | [deploy/docker-compose.prod.yml](../../deploy/docker-compose.prod.yml) |
| 클라우드 방화벽(443 허용) | [infra/terraform/main.tf](../../infra/terraform/main.tf)의 `oci_core_security_list` |
| DNS 레코드 | DNS 관리처(Cloudflare) 대시보드 — 코드로 관리하지 않는다 |
| 인증서 파일 (서버) | `/etc/letsencrypt/live/etudequest.com/` |
| 갱신 설정 (서버) | `/etc/letsencrypt/renewal/etudequest.com.conf` |

## 9. 직접 확인해 보는 명령

```bash
# DNS가 서버 IP를 가리키나 (내 컴퓨터)
dig +short etudequest.com

# HTTPS가 응답하나
curl -I https://etudequest.com

# http가 https로 넘어가나 (301 + Location 헤더가 나와야 함)
curl -I http://etudequest.com

# 서버가 보여 주는 인증서 정보 (만료일 등)
echo | openssl s_client -connect etudequest.com:443 -servername etudequest.com 2>/dev/null | openssl x509 -noout -dates -subject

# 서버에서: 인증서 목록과 남은 기간
sudo certbot certificates
```

## 관련 문서

- [troubleshooting_2026-10-28_https_domain.md](../ops/troubleshooting_2026-10-28_https_domain.md) — Etude에 실제로 적용하면서 겪은 문제와 아직 남은 갱신 검증

## 10. 용어 정리

| 용어 | 뜻 |
|------|-----|
| 도메인 | 사람이 읽는 이름 (`etudequest.com`) |
| DNS | 이름을 IP 주소로 바꿔 주는 전 세계 공용 전화번호부 |
| 네임서버 | 그 이름의 주소 정보를 대답해 주는 서버 |
| A 레코드 | "이름 = IPv4 주소" 한 줄 규칙 |
| TTL | DNS 응답을 캐시해 두는 시간 |
| 포트 | IP 안의 문 번호 (80, 443, 22 ...) |
| TLS | 통신을 암호화하는 규약. HTTPS = HTTP + TLS |
| 인증서 | "이 공개키는 이 도메인의 것"이라는 CA의 서명 증명서 |
| CA | 인증서를 발급해 주는, 브라우저가 믿는 기관 (Let's Encrypt 등) |
| 개인키 | 서버만 가지는 비밀 키. 노출되면 안 된다 |
| certbot | Let's Encrypt 발급·갱신을 자동화하는 프로그램 |
| webroot | 폴더에 검증 파일을 놓고 웹서버가 내주는 방식 |
| 리다이렉트 (301) | "주소가 바뀌었어, 저기로 가"라는 응답 |
