# Phase 1 명세 — 터미널 샌드박스

## 목표

브라우저에서 터미널을 열고 Docker 컨테이너 안에서 명령어를 실행할 수 있다.

## 완료 기준

- [x] `npm run dev` (백엔드) 실행 후 서버가 뜬다
- [x] `npm run dev` (프론트) 실행 후 브라우저에서 터미널이 보인다
- [x] 터미널에서 `ls` 실행 → 결과 출력
- [x] 터미널에서 `pwd` 실행 → `/` 출력
- [x] 터미널에서 `echo hello` 실행 → `hello` 출력
- [x] 브라우저 탭을 닫으면 Docker 컨테이너가 제거된다 (`docker ps -a`로 확인)

## 구현 범위

### 백엔드 (`backend/src/`)

| 파일 | 역할 |
|------|------|
| `index.ts` | Fastify 앱 진입점, WebSocket 엔드포인트 등록 |
| `terminal.ts` | Docker 컨테이너 생성/실행/제거 + WebSocket 스트리밍 |

### 프론트 (`frontend/src/`)

| 파일 | 역할 |
|------|------|
| `components/Terminal.tsx` | xterm.js 터미널 컴포넌트, WebSocket 연결 |
| `App.tsx` | Terminal 렌더링 |

## 인터페이스

### WebSocket: `ws://localhost:3001/ws/terminal`

| 방향 | 형식 | 내용 |
|------|------|------|
| 서버 → 클라이언트 | `Buffer` (binary) | 컨테이너 stdout/stderr |
| 클라이언트 → 서버 | `Buffer` (binary) | 키 입력 |

## 범위 밖 (Phase 1에서 하지 않는 것)

- 퀘스트 지문, 채점 — Phase 2
- 인증/세션 관리
- 컨테이너 타임아웃 처리
- 여러 사용자 동시 접속

## 참고

- 구현 코드: `docs/etude_dev_guide.md` Phase 1 섹션
- 아키텍처: `docs/etude_dev_plan.md`
