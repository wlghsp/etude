# Phase 2 명세 — 퀘스트 + 채점

## 목표

퀘스트 지문을 보고 터미널에서 풀고 채점까지 한 사이클이 동작한다.

## 완료 기준

- [x] 브라우저 왼쪽에 퀘스트 지문이 보인다
- [x] 터미널에서 퀘스트를 풀고 [채점하기] 클릭 시 성공/실패가 표시된다
- [x] q1: `mkdir /tmp/hello` 실행 후 채점 → 성공
- [x] q2: `echo done > /tmp/answer.txt` 실행 후 채점 → 성공
- [x] 틀렸을 때 → 실패 메시지 표시
- [x] 이전/다음 버튼으로 퀘스트 이동 가능
- [x] 퀘스트 이동 시 새 컨테이너로 격리된 환경 제공

## 화면 구성

```
┌─────────────────┬─────────────────┐
│  Quest 1 / 2   │    터미널        │
│                 │                 │
│ 미션: /tmp에    │ $ mkdir /tmp/   │
│ hello 디렉토리  │ hello           │
│ 를 만드세요     │ $               │
│                 │                 │
│ [채점하기]      │                 │
│ [이전] [다음]   │                 │
└─────────────────┴─────────────────┘
```

## 구현 범위

### 백엔드 (`backend/src/`)

| 파일 | 역할 |
|------|------|
| `quest.ts` | 퀘스트 데이터 + 채점 로직 (신규) |
| `index.ts` | `/quests`, `/grade` API 추가 + docker 인스턴스 통합 + CORS |
| `terminal.ts` | `containerId` 전송 추가, docker 인자로 받도록 변경 |

### 프론트 (`frontend/src/`)

| 파일 | 역할 |
|------|------|
| `components/QuestPanel.tsx` | 퀘스트 지문 + 채점 버튼 + 이전/다음 (신규) |
| `components/Terminal.tsx` | `onConnected` 콜백 추가 |
| `App.tsx` | 좌우 레이아웃 + 상태 관리 + 퀘스트 인덱스 |

## 인터페이스

### REST API

| 메서드 | 경로 | 응답 |
|--------|------|------|
| `GET` | `/quests` | `Quest[]` |
| `POST` | `/grade` | `{ passed: boolean }` |

### POST /grade 요청 바디

```json
{
  "containerId": "abc123",
  "questId": 1
}
```

### WebSocket 메시지

| 방향 | 형식 | 내용 |
|------|------|------|
| 서버 → 클라이언트 | `string` (JSON) | `{ type: 'connected', containerId: string }` |
| 서버 → 클라이언트 | `Buffer` (binary) | 컨테이너 stdout/stderr |
| 클라이언트 → 서버 | `Buffer` (binary) | 키 입력 |

## 설계 결정

- **퀘스트 ID**: string('q1') 대신 number(1) 사용
- **채점 로직 위치**: `Quest` 인터페이스에 `grade` 함수 포함 → 퀘스트 추가 시 배열에만 추가
- **exec 완료 감지**: stream 이벤트(`end`/`close`) 대신 `exec.inspect()` 폴링 방식 (dockerode 호환성)
- **퀘스트 전환 시 컨테이너 격리**: `Terminal`에 `key={questIndex}` → React 재마운트 → 새 WebSocket + 새 컨테이너 자동 생성
- **CORS**: `@fastify/cors`로 `localhost:5173` 허용

## 범위 밖 (Phase 3에서)

- DB 연동 (하드코딩 유지)
- 로그인/인증
- 퀘스트 목록 페이지

## 참고

- 구현 가이드: `docs/guides/guide_phase2.md`
- 아키텍처: `docs/etude_dev_plan.md`
