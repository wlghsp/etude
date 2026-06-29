# Phase 7 명세 — 사용자 인증 + 진행 추적

## 목표

팀원이 로그인하고, 퀘스트를 풀면 완료 이력이 기록되며, 세트별 진행률을 대시보드에서 확인할 수 있다.
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

CREATE TABLE quest_progress (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  quest_id     INT NOT NULL,
  completed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_user_quest (user_id, quest_id),
  FOREIGN KEY (user_id) REFERENCES user(id),
  FOREIGN KEY (quest_id) REFERENCES quest(id)
);
```

### 설계 결정

- `quest_progress`는 `UNIQUE(user_id, quest_id)` — 같은 퀘스트를 여러 번 풀어도 최초 완료만 기록
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
내 진행 현황 반환. 세트별 완료 퀘스트 수 포함.
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
기존과 동일하지만, 채점 성공 시 `quest_progress`에 기록 추가.
```json
// 요청 (기존과 동일)
{ "containerId": "abc123", "questId": 1 }

// 응답 (기존과 동일)
{ "passed": true }
```

---

## 화면 흐름

```
/login  (신규)
  └─ 로그인 성공
       └─ / (세트 선택 — 진행률 배지 추가)
            ├─ 세트 클릭 → /quest (실습 화면 — 리셋 버튼, 프로그레스 바 추가)
            └─ 상단 Progress Status 클릭 → /progress (신규)
```

---

## 변경/추가 파일

| 파일 | 변경 내용 |
|------|-----------|
| `backend/db/init.sql` | `user`, `quest_progress` 테이블 + 시드 계정 추가 |
| `backend/src/auth.ts` | 신규 — JWT 발급/검증, bcrypt 비교 |
| `backend/src/index.ts` | `/auth/login`, `/me`, `/progress` 라우트 추가. `/grade`에 progress 기록 추가. `authMiddleware` 적용 |
| `frontend/src/api.ts` | 토큰 헤더 자동 첨부, `/auth/login`, `/me`, `/progress` API 함수 추가 |
| `frontend/src/App.tsx` | 로그인 상태 관리, 라우팅 추가 |
| `frontend/src/pages/Login.tsx` | 신규 — 로그인 화면 |
| `frontend/src/pages/Progress.tsx` | 신규 — 진행 현황 대시보드 |
| `frontend/src/pages/SetSelect.tsx` | 진행률 배지 추가 |
| `frontend/src/components/QuestPanel.tsx` | 환경 리셋 버튼, 프로그레스 바, 성공 시 NEXT QUEST 버튼 추가 |

---

## 검증 기준

- [ ] 로그인 성공 → JWT 발급 → 세트 선택 화면 진입
- [ ] 잘못된 이메일/비밀번호 → 에러 메시지 표시
- [ ] 퀘스트 채점 성공 → DB `quest_progress`에 기록
- [ ] `/progress` 에서 세트별 완료 수 확인
- [ ] 로그아웃 → 토큰 삭제 → `/login` 리다이렉트
- [ ] 토큰 없이 인증 필요 API 호출 → 401 반환
