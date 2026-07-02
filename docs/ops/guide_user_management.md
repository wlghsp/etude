# 운영 가이드 — 팀원 계정 추가

가입 화면이 없다. 관리자가 API로 직접 계정을 만들어준다. 아래 순서대로 진행한다.

---

## 1. 관리자 토큰 발급받기

관리자 계정(admin role)으로 로그인해 JWT 토큰을 받는다.

```bash
curl -X POST http://161.33.45.200/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@okestro.com", "password": "{관리자 비밀번호}"}'
```

응답 예시:

```json
{"token": "eyJhbGciOiJIUzI1NiIs...", "name": "관리자", "role": "admin"}
```

이 `token` 값을 이후 명령에서 계속 사용한다. 아래에서는 `{ADMIN_TOKEN}`으로 표기한다.

매번 복사하기 번거로우면 셸 변수로 저장해두면 편하다 (아래 코드블록만 복사해서 실행 — `>` 기호는 포함하지 않는다):

```bash
ADMIN_TOKEN=$(curl -s -X POST http://161.33.45.200/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@okestro.com", "password": "{관리자 비밀번호}"}' \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
```

---

## 2. 팀원 계정 생성

```bash
curl -X POST http://161.33.45.200/admin/users \
  -H "Authorization: Bearer {ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"name": "홍길동", "email": "hong@okestro.com", "password": "{임시 비밀번호}"}'
```

- `role`은 별도로 지정하지 않으며 항상 `member`로 생성된다 (관리자 계정은 DB에서 직접 관리).
- 이메일은 로그인 ID로 쓰이므로 중복되지 않게 사내 이메일을 그대로 쓰는 걸 권장.
- 비밀번호는 팀원이 처음 로그인 후 바꿀 방법이 아직 없으므로(비밀번호 변경 화면 미구현), 팀원에게 안전하게 전달하고 필요시 관리자가 재설정(아래 3번)해준다.

여러 명을 한 번에 추가하려면 위 curl 명령을 팀원 수만큼 반복 실행하면 된다. 명단이 많으면 아래처럼 스크립트로 처리해도 된다.

```bash
# users.txt: 한 줄에 "이름,이메일,비밀번호" 형식으로 준비
while IFS=, read -r name email pw; do
  curl -s -X POST http://161.33.45.200/admin/users \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$name\", \"email\": \"$email\", \"password\": \"$pw\"}"
  echo
done < users.txt
```

---

## 3. 비밀번호 재설정 (필요시)

팀원이 비밀번호를 잊었거나, 임시 비밀번호를 관리자가 강제로 바꿔주고 싶을 때.

```bash
curl -X PATCH http://161.33.45.200/admin/users/{userId}/password \
  -H "Authorization: Bearer {ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"password": "{새 비밀번호}"}'
```

`{userId}`는 아래 4번(계정 목록 조회)으로 확인할 수 있다.

---

## 4. 계정 목록 확인

```bash
curl http://161.33.45.200/admin/users \
  -H "Authorization: Bearer {ADMIN_TOKEN}"
```

`member` role인 계정만 반환된다 (admin은 목록에서 제외됨 — role만으로 모든 세트에 접근 가능해 개별 관리 대상이 아니기 때문).

---

## 5. 퀘스트 세트 접근 권한 부여 (필요시)

일부 퀘스트 세트(사내 장애/작업 사례 등)는 기본 비공개이며 관리자가 유저별로 접근을 허용해야 보인다. 브라우저에서 관리자 계정으로 로그인 후 **관리자 화면 → 퀘스트 세트 접근 관리**에서 체크박스로 처리하는 게 curl보다 편하다.

curl로 하려면:

```bash
# 세트 공개 전환
curl -X PATCH http://161.33.45.200/admin/quest-sets/{setId} \
  -H "Authorization: Bearer {ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"is_public": true}'

# 특정 유저에게 비공개 세트 접근 허용
curl -X POST http://161.33.45.200/admin/quest-sets/{setId}/access \
  -H "Authorization: Bearer {ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"userId": {userId}}'
```

---

## 팀원에게 안내할 것

계정 생성 후 팀원에게 아래를 전달한다.

- 접속 주소: `http://161.33.45.200`
- 이메일(로그인 ID)
- 임시 비밀번호
- (선택) 비밀번호를 안전한 경로로 전달했는지 확인 — curl 명령/응답에 평문 비밀번호가 남으므로 터미널 기록 관리에 주의
