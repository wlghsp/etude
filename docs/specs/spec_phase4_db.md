# Phase 4 명세 — MariaDB 연동 + 퀘스트 세트 구조

## 목표

퀘스트를 하드코딩에서 DB로 이전한다. 기능은 지금과 동일하게 동작하는 것이 목표.
퀘스트 추가/수정 시 코드 수정 없이 DB만 변경하면 반영된다.

---

## DB 스키마

```sql
CREATE TABLE quest_set (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(100) NOT NULL,
  description TEXT
);

CREATE TABLE quest (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  quest_set_id INT NOT NULL,
  order_index  INT NOT NULL DEFAULT 0,
  title        VARCHAR(200) NOT NULL,
  description  TEXT NOT NULL,
  hint         TEXT,
  solution     TEXT,
  grade_cmd    JSON NOT NULL,  -- 채점 명령어 배열 ex) ["test", "-d", "/tmp/hello"]
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);
```

### grade_cmd 설계 결정

채점 함수는 코드에 두지 않고 채점 명령어(`grade_cmd`)를 DB에 저장한다.
`execCheck(container, cmd)` 하나로 모든 퀘스트를 채점할 수 있어 코드 수정 없이 퀘스트 추가가 가능하다.

```json
// 예시
["test", "-d", "/tmp/hello"]         // 디렉토리 존재 확인
["grep", "-q", "done", "/tmp/answer.txt"]  // 파일 내용 확인
```

---

## Seed 데이터

기존 하드코딩 퀘스트 2개를 DB로 이전.

```sql
INSERT INTO quest_set (title, description) VALUES
  ('리눅스 기초', '기본적인 리눅스 명령어를 실습합니다.');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, grade_cmd) VALUES
  (1, 1, '/tmp/hello 디렉토리 만들기',
   '/tmp 경로 안에 hello라는 이름의 디렉토리를 만드세요.',
   'mkdir 명령어를 사용하세요.',
   'mkdir /tmp/hello',
   '["test", "-d", "/tmp/hello"]'),
  (1, 2, '파일에 내용 쓰기',
   '/tmp/answer.txt 파일을 만들고 첫 줄에 "done"을 입력하세요.',
   'echo 명령어와 리다이렉션(>)을 사용하세요.',
   'echo "done" > /tmp/answer.txt',
   '["grep", "-q", "done", "/tmp/answer.txt"]'),
  (1, 3, '숨김 파일 만들기',
   '/tmp 경로에 .hidden 이라는 이름의 빈 파일을 만드세요.',
   'touch 명령어를 사용하세요. 파일명 앞에 .을 붙이면 숨김 파일이 됩니다.',
   'touch /tmp/.hidden',
   '["test", "-f", "/tmp/.hidden"]');
```

---

## API

### GET /quest-sets
퀘스트 세트 목록 반환.

```json
[
  { "id": 1, "title": "리눅스 기초", "description": "기본적인 리눅스 명령어를 실습합니다." }
]
```

### GET /quest-sets/:id/quests
세트별 퀘스트 목록 반환 (order_index 순).

```json
[
  { "id": 1, "title": "/tmp/hello 디렉토리 만들기", "description": "...", "hint": "...", "solution": "..." }
]
```

### POST /grade
기존과 동일. containerId + questId → passed 반환.
채점 명령어는 DB의 grade_cmd에서 읽어서 실행.

```json
// 요청
{ "containerId": "abc123", "questId": 1 }

// 응답
{ "passed": true }
```

---

## 화면 흐름

```
세트 선택 화면 (신규)
  └── 퀘스트 진행 화면 (기존, 재활용)
```

세트 선택 화면: 세트 카드 목록 → 클릭 시 해당 세트의 퀘스트 진행으로 이동.

---

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `backend/src/db.ts` | 신규 — MariaDB 연결 |
| `backend/src/quest.ts` | DB에서 퀘스트 조회 + grade_cmd로 채점 |
| `backend/src/index.ts` | `/quest-sets`, `/quest-sets/:id/quests` API 추가 |
| `frontend/src/pages/SetSelect.tsx` | 신규 — 세트 선택 화면 |
| `frontend/src/App.tsx` | 세트 선택 → 퀘스트 진행 라우팅 |

---

## 검증 기준

- [x] 세트 선택 화면에서 "리눅스 기초" 세트가 표시됨
- [x] 세트 선택 → 퀘스트 진행 화면으로 이동
- [x] 터미널에서 퀘스트 풀고 채점까지 한 사이클 완료
- [x] DB에 퀘스트 1개 추가 후 코드 수정 없이 화면에 반영됨
- [x] 힌트/풀이 보기 토글 표시
- [x] 퀘스트 진행 중 언제든 홈으로 버튼으로 세트 선택 화면 복귀
