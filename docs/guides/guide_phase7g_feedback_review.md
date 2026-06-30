# 운영 가이드 — 피드백 수집 및 반영 사이클

## 목적

배포 후 팀원들이 남긴 피드백을 로컬에서 꺼내와 Claude Code와 함께 분석하고 개선 작업으로 연결하는 흐름을 정리한다.

---

## 전체 흐름

```
1. 서버에서 피드백 가져오기  →  feedback.json (로컬)
2. Claude Code와 함께 분석  →  개선 항목 정리
3. 코드 수정 + 재배포
```

---

## Step 1. 관리자 토큰 발급

```bash
curl -s http://{서버IP}/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "{관리자이메일}", "password": "{비밀번호}"}' \
  | jq -r '.token'
```

출력된 토큰을 복사해둔다.

---

## Step 2. 피드백 가져오기

```bash
curl -s http://{서버IP}/admin/feedback \
  -H "Authorization: Bearer {토큰}" \
  | jq '.' > feedback.json
```

`feedback.json`이 로컬에 생성된다.

---

## Step 3. Claude Code와 분석

`feedback.json`을 열고 Claude Code에게 요청한다:

```
feedback.json 읽고 자주 언급된 불편함과 개선 우선순위 정리해줘
```

또는 특정 페이지/퀘스트에 집중할 경우:

```
feedback.json에서 page가 "quest"인 항목만 정리해줘
```

---

## Step 4. 코드 수정 후 재배포

개선 작업 완료 후 서버에 반영한다.

```bash
# 서버에서
cd ~/etude
git pull

# 프론트 변경 시
cd frontend && npm run build && cd ..

# 재시작
docker compose -f deploy/docker-compose.prod.yml up -d --build backend
```

---

## 편의 스크립트 (선택)

매번 토큰 발급 + curl을 합친 스크립트. `backend/http/fetch-feedback.sh`로 저장해두면 편하다.

```bash
#!/bin/bash
# 사용법: bash http/fetch-feedback.sh {서버IP} {이메일} {비밀번호}

SERVER="${1:?'서버 IP를 입력하세요'}"
EMAIL="${2:?'이메일을 입력하세요'}"
PASSWORD="${3:?'비밀번호를 입력하세요'}"

TOKEN=$(curl -s "http://${SERVER}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"${EMAIL}\", \"password\": \"${PASSWORD}\"}" \
  | jq -r '.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
  echo "로그인 실패. 이메일/비밀번호를 확인하세요."
  exit 1
fi

curl -s "http://${SERVER}/admin/feedback" \
  -H "Authorization: Bearer ${TOKEN}" \
  | jq '.' > feedback.json

echo "저장 완료: feedback.json ($(jq length feedback.json)건)"
```

실행:

```bash
bash http/fetch-feedback.sh {서버IP} admin@company.com {비밀번호}
# 저장 완료: feedback.json (12건)
```

---

## 주의사항

- `feedback.json`은 `.gitignore`에 추가해서 git에 올라가지 않도록 한다.
- 비밀번호를 스크립트 인자로 넘기므로 터미널 히스토리에 남을 수 있다. 민감한 환경이면 `read -s PASSWORD`로 대화형 입력을 받는 것이 낫다.
