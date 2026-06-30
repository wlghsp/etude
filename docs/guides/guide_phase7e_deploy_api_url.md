# 구현 가이드 — API URL 환경변수 분리

## 목표

개발 시 `:3001`, 배포 시 포트 없음(nginx 80) — 환경에 따라 API/WebSocket URL이 달라지는 문제를 Vite 환경변수로 해결한다.

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `frontend/.env.development` | 신규 — 로컬 개발용 환경변수 |
| `frontend/.env.production` | 신규 — 프로덕션 환경변수 |
| `frontend/src/api.ts` | BASE URL을 환경변수에서 읽도록 변경 |
| `frontend/src/components/Terminal.tsx` | WebSocket URL을 환경변수에서 읽도록 변경 |
| `frontend/.gitignore` (또는 루트 `.gitignore`) | `.env.development` gitignore 추가 불필요 — 포트 정보만 있어 공개 OK |

---

## Step 1. 환경변수 파일 생성

### `frontend/.env.development`

```
VITE_API_BASE=http://localhost:3001
VITE_WS_BASE=ws://localhost:3001
```

### `frontend/.env.production`

```
VITE_API_BASE=
VITE_WS_BASE=
```

> 프로덕션에서는 빈 문자열 — 같은 origin의 nginx가 `/api/`, `/ws/`로 프록시하므로 호스트 생략.

---

## Step 2. `frontend/src/api.ts` — BASE URL 변경

```ts
const BASE = import.meta.env.VITE_API_BASE ?? ''
```

---

## Step 3. `frontend/src/components/Terminal.tsx` — WebSocket URL 변경

```ts
const wsBase = import.meta.env.VITE_WS_BASE ?? ''
const ws = new WebSocket(`${wsBase}/ws/terminal?${params}`)
```

---

## 검증

### 로컬 개발 (`npm run dev`)

- `VITE_API_BASE=http://localhost:3001` 적용
- API 호출, WebSocket 연결 정상 동작 확인

### 프로덕션 빌드 (`npm run build`)

- `VITE_API_BASE=''` 적용 → URL이 `/quest-sets`, `/ws/terminal?...` 형태
- nginx가 `/api/` → `backend:3001`, `/ws/` → `backend:3001/ws/` 로 프록시

> nginx.conf의 `/api/` location이 `proxy_pass http://backend:3001/` 로 되어 있으므로  
> 프론트 fetch URL은 `/quest-sets` (포트 없음) 형태가 맞다.
