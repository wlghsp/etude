# Phase 7 명세 — 사용자 인증 + 진행 추적

## 목표

팀원이 로그인하고, 퀘스트를 풀면 시도 이력이 기록되며, 세트별 진행률을 대시보드에서 확인할 수 있다.
관리자는 전체 팀원의 진행 현황을 조회할 수 있다.
이게 있어야 팀원들이 실제로 쓸 수 있는 제품이 된다.

---

## DB 스키마 추가

기존 테이블(`sandbox`, `quest_set`, `quest`)은 그대로 유지. 아래 2개 추가.

```sql
CREATE TABLE user (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(200) NOT NULL UNIQUE,
  password   VARCHAR(200) NOT NULL,  -- bcrypt 해시
  role       ENUM('member', 'admin') NOT NULL DEFAULT 'member',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- quest_progress 대신 quest_attempt 사용
-- 반복 시도 이력 전체를 기록 (완료 여부 + 소요 시간 + 힌트 사용 여부)
CREATE TABLE quest_attempt (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  user_id        INT NOT NULL,
  quest_id       INT NOT NULL,
  quest_set_id   INT NOT NULL,
  session_id     VARCHAR(36) NOT NULL,  -- 세트 1회차를 묶는 UUID
  elapsed_sec    INT,                   -- 퀘스트 진입 → 채점 성공까지 소요 시간 (초)
  hint_used      BOOLEAN NOT NULL DEFAULT FALSE,
  solution_used  BOOLEAN NOT NULL DEFAULT FALSE,
  passed         BOOLEAN NOT NULL DEFAULT FALSE,
  attempted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)      REFERENCES user(id),
  FOREIGN KEY (quest_id)     REFERENCES quest(id),
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);
```

### 설계 결정

- `quest_attempt`는 중복 허용 — 같은 퀘스트를 반복해서 풀면 행이 쌓임
- `session_id`: 세트를 처음부터 다시 시작할 때마다 새 UUID 생성 (프론트에서 생성해서 전달)
- `elapsed_sec`: 프론트에서 퀘스트 진입 시각 기록 → 채점 성공 시 서버에 전달
- `hint_used` / `solution_used`: 힌트/풀이 열람 시 프론트에서 플래그 세팅
- **Phase 9에서 활용할 것**: 회차별 비교, 속도 향상 그래프, 관리자 팀원 분석 뷰
- 비밀번호는 bcrypt (cost 10)로 해시 저장
- JWT는 `userId`, `email`, `role`을 payload에 포함, 만료 24시간

---

## 인증 방식

- **JWT (JSON Web Token)** — stateless, 서버 세션 없음
- 토큰을 `localStorage`에 저장
- 모든 인증 필요 API는 `Authorization: Bearer <token>` 헤더로 토큰 전달
- 토큰 만료 시 프론트에서 `/login` 으로 리다이렉트

---

## API

### 인증 불필요

#### POST /auth/login
```json
// 요청
{ "email": "name@okestro.com", "password": "..." }

// 응답 (성공)
{ "token": "eyJ...", "user": { "id": 1, "name": "홍길동", "email": "...", "role": "member" } }

// 응답 (실패)
{ "error": "이메일 또는 비밀번호가 올바르지 않습니다." }
```

---

### 인증 필요 (Authorization 헤더 필수)

#### GET /me
현재 로그인 사용자 정보 반환.
```json
{ "id": 1, "name": "홍길동", "email": "...", "role": "member" }
```

#### GET /progress
내 진행 현황 반환. 세트별 통과한 퀘스트 수 (passed=true인 최신 attempt 기준).
```json
[
  {
    "quest_set_id": 1,
    "title": "리눅스 기초 1",
    "category": "리눅스",
    "total": 10,
    "completed": 7
  }
]
```

#### POST /grade
기존과 동일하지만, 채점 결과를 `quest_attempt`에 기록.
```json
// 요청 (현재 구현)
{
  "containerId": "abc123",
  "questId": 1
}

// 응답 (기존과 동일)
{ "passed": true }
```

> `sessionId`, `elapsedSec`, `hintUsed`, `solutionUsed`는 Phase 9에서 추가 예정. 현재는 `user_id`, `quest_id`, `quest_set_id`, `passed`, `attempted_at`만 기록.

#### GET /leaderboard
인증 필요. 전체 팀원의 세트별 진행 현황 (리더보드 — 모든 팀원 공개).
```json
[
  { "userName": "홍길동", "questSetTitle": "k8s 기초", "completed": 8, "total": 14 },
  { "userName": "김철수", "questSetTitle": "k8s 기초", "completed": 3, "total": 14 }
]
```

> 현재는 로그인한 모든 팀원이 볼 수 있는 공개 리더보드. 향후 필요 시 admin 전용으로 제한 가능.

#### POST /admin/users
관리자 전용. 팀원 계정 생성 (가입 화면 없음, 관리자가 직접 생성).
```json
// 요청
{ "name": "홍길동", "email": "hong@okestro.com", "password": "임시비번" }

// 응답
{ "id": 3, "name": "홍길동", "email": "hong@okestro.com", "role": "member" }
```

#### PATCH /admin/users/:id/password
관리자 전용. 팀원 비밀번호 초기화 (비밀번호 분실 시).
```json
// 요청
{ "password": "새임시비번" }

// 응답
{ "ok": true }
```

---

## 화면 흐름

```
/login  (신규)
  └─ 로그인 성공
       └─ / (세트 선택 — 진행률 배지 추가)
            ├─ 세트 클릭 → /quest (실습 화면 — 리셋 버튼, 프로그레스 바 추가)
            ├─ Progress Status 클릭 → /progress (내 진행 현황)
            └─ Leaderboard 클릭 → /leaderboard (전체 팀원 리더보드, 모두 접근 가능)
```

---

## 변경/추가 파일

| 파일 | 변경 내용 |
|------|-----------|
| `backend/db/init.sql` | `user`, `quest_attempt` 테이블 + 시드 계정 추가 |
| `backend/src/auth.ts` | 신규 — JWT 발급/검증, bcrypt 비교, adminOnly 미들웨어 |
| `backend/src/index.ts` | `/auth/login`, `/me`, `/progress`, `/leaderboard`, `/admin/users` 라우트 추가. `/grade`에 attempt 기록 추가. `authMiddleware` 적용 |
| `frontend/src/api.ts` | 토큰 헤더 자동 첨부, 인증/진행 API 함수 추가 |
| `frontend/src/App.tsx` | 로그인 상태 관리, 라우팅 추가, sessionId 생성 |
| `frontend/src/pages/Login.tsx` | 신규 — 로그인 화면 |
| `frontend/src/pages/Progress.tsx` | 신규 — 내 진행 현황 대시보드 |
| `frontend/src/pages/Leaderboard.tsx` | 신규 — 전체 팀원 리더보드 (모든 팀원 접근 가능) |
| `frontend/src/pages/SetSelect.tsx` | 진행률 배지 추가 |
| `frontend/src/components/QuestPanel.tsx` | 환경 리셋 버튼(confirm), 프로그레스 바, 성공 시 NEXT QUEST 버튼. Props: `onHome`(홈), `onReset`(환경리셋), `onComplete`(채점성공 콜백) |
| `frontend/tailwind.config.js` | Stitch 커스텀 컬러 토큰 (surface, primary, outline-variant 등) |
| `frontend/src/index.css` | JetBrains Mono + Material Symbols 폰트, Tailwind 디렉티브 |

---

## Phase 9 예정 (백로그)

- 회차별 기록 비교 (1회차 vs 2회차 소요 시간)
- 퀘스트별 평균 풀이 시간 / 첫 시도 성공률
- 관리자 팀원별 상세 분석 뷰
- 퀘스트 부여 기능 (특정 팀원에게 세트 할당 + 마감일)
- 첫 로그인 시 비밀번호 변경 강제 (force_password_change 플래그 + 변경 화면)
- **브라우저 미리보기 버튼** — 퀘스트 화면에 "브라우저에서 열기" 버튼 추가. 클릭 시 새 탭으로 `http://localhost:{할당된포트}` 오픈. 채점은 기존 bash 명령 기반 유지, 학습 효과 향상 목적. (iframe 방식은 포트 충돌/HTTP 제한 이슈로 제외)

---

## 검증 기준

- [ ] 로그인 성공 → JWT 발급 → 세트 선택 화면 진입
- [ ] 잘못된 이메일/비밀번호 → 에러 메시지 표시
- [ ] 퀘스트 채점 성공 → `quest_attempt`에 행 추가 (user_id, quest_id, passed 포함)
- [ ] 같은 퀘스트 재채점 → attempt 행 추가 (중복 허용)
- [ ] `/progress` 에서 세트별 완료 수 확인
- [ ] `/leaderboard` 에서 전체 팀원 현황 확인 (member/admin 모두)
- [ ] member 계정 → `/admin/users` 호출 시 403 반환
- [ ] 로그아웃 → 토큰 삭제 → 로그인 화면으로 이동
- [ ] 토큰 없이 인증 필요 API 호출 → 401 반환
- [ ] SetSelect 세트 카드에 진행률 배지 표시
- [ ] 채점 성공 시 NEXT QUEST 버튼 표시, 클릭 시 다음 퀘스트로 이동
- [ ] 환경 리셋 버튼 → confirm 다이얼로그 → 터미널 재연결
