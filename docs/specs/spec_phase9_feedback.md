# Phase 9 명세 — 인앱 피드백

## 목표

어느 화면에서나 오른쪽 상단 버튼으로 피드백을 제출할 수 있다.
제출된 피드백은 DB에 저장되고, 관리자가 API로 조회해 개선/오류 수정에 활용한다.

---

## DB 스키마

```sql
CREATE TABLE feedback (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT,                          -- 로그인 상태면 기록, 아니면 NULL
  page         VARCHAR(100),                 -- 제출 시점 화면 (예: 'quest', 'home', 'progress')
  quest_id     INT,                          -- 퀘스트 화면이면 기록, 아니면 NULL
  quest_set_id INT,                          -- 퀘스트 화면이면 기록, 아니면 NULL
  body         TEXT NOT NULL,               -- 피드백 본문
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id)
);
```

---

## API

### POST /feedback
인증 불필요 (비로그인 피드백도 수용).

```json
// 요청
{
  "page": "quest",
  "questId": 3,
  "questSetId": 1,
  "body": "힌트가 너무 어렵습니다."
}

// 응답
{ "ok": true }
```

### GET /admin/feedback
관리자 전용. 최신순 정렬.

```json
[
  {
    "id": 1,
    "userName": "홍길동",
    "page": "quest",
    "questSetTitle": "리눅스 기초 1",
    "questTitle": "현재 위치 확인하기",
    "body": "힌트가 너무 어렵습니다.",
    "createdAt": "2026-06-30T10:00:00"
  }
]
```

---

## UI

### 피드백 버튼
- 위치: 화면 오른쪽 상단 고정 (`fixed top-4 right-4 z-50`)
- 아이콘: `feedback` (Material Symbols)
- 모든 화면에서 표시

### 피드백 모달
버튼 클릭 시 모달 열림.

```
┌─────────────────────────────┐
│ 피드백 보내기          [×]  │
│                             │
│ 오류나 개선 사항을          │
│ 자유롭게 남겨주세요.        │
│                             │
│ ┌─────────────────────────┐ │
│ │                         │ │
│ │  (textarea)             │ │
│ │                         │ │
│ └─────────────────────────┘ │
│                             │
│           [취소] [제출하기] │
└─────────────────────────────┘
```

- textarea: 최소 4줄, 최대 1000자
- 제출 후: 모달 닫힘 + "피드백이 전달됐습니다." 토스트 (2초)
- 빈 내용 제출 불가

---

## 변경/추가 파일

| 파일 | 변경 내용 |
|------|-----------|
| `backend/db/00_schema.sql` | `feedback` 테이블 추가 |
| `backend/src/index.ts` | `POST /feedback`, `GET /admin/feedback` 라우트 추가 |
| `frontend/src/components/FeedbackButton.tsx` | 신규 — 버튼 + 모달 + 토스트 |
| `frontend/src/App.tsx` | `<FeedbackButton>` 마운트, 현재 page/questId/questSetId 전달 |

---

## 검증 기준

- [ ] 어느 화면에서나 오른쪽 상단에 피드백 버튼 표시
- [ ] 버튼 클릭 → 모달 열림
- [ ] 빈 내용 제출 시 버튼 비활성화
- [ ] 제출 성공 → 모달 닫힘 + 토스트 표시
- [ ] DB `feedback` 테이블에 행 추가 확인
- [ ] `GET /admin/feedback` → 제출된 피드백 목록 반환
- [ ] 비로그인 상태 제출 → `user_id = NULL` 로 저장
