# 운영 가이드 — 유저 관리

가입 화면 없음. 관리자가 API로 직접 생성한다.

```bash
curl -X POST http://localhost:3001/admin/users \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "홍길동", "email": "hong@example.com", "password": "임시비번"}'
```

`<admin-token>`은 관리자 계정으로 로그인해 발급받은 JWT를 사용한다.
