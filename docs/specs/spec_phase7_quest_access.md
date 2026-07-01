# Phase 7 명세 — 퀘스트 세트 접근 제어

## 목표

업무 관련(사내 장애/작업 사례 기반) 퀘스트 세트는 전체 공개가 아니라
지정된 팀원만 볼 수 있어야 한다. 관리자가 화면에서 세트별로 공개 여부와
접근 가능 유저를 관리할 수 있다.

## 배경

지금까지 만든 퀘스트 세트는 전부 공개(k8s 기초, 리눅스 기초 등 일반 학습용)였지만,
앞으로 특정 팀의 실제 장애/작업 사례를 퀘스트로 만들면 그 내용이 사내 민감 정보일 수 있다.
전체 공개를 기본값으로 유지하되, 예외적으로 비공개 세트를 만들고 유저를 지정해 할당하는 모델이 필요하다.

---

## 범위

- 접근 제어 단위: **quest_set** (세트 내 개별 퀘스트 단위 제어는 범위 밖)
- 기본값: 모든 세트는 공개(`is_public = true`)
- 비공개 세트(`is_public = false`)는 `quest_set_access`에 등록된 유저 **또는 admin role** 유저만 조회 가능
- 관리자는 화면에서 세트의 공개 여부 토글, 비공개 세트의 접근 유저 할당/해제 가능
- `quest_attempt`, 진행률/리더보드 집계는 접근 제어와 무관 — 한번 쌓인 이력은 할당 해제 후에도 그대로 유지되고 계속 표시됨 (범위 밖 절이 아니라 명시적 비목표)

범위 밖 (이번에 하지 않음):
- 퀘스트 단위 접근 제어
- 팀/그룹 단위 할당 (유저 개별 할당만 지원)
- 비공개 세트 신규 생성 UI (기존 세트의 공개 여부 토글 + 접근 관리만)
- 비공개 전환 시 최소 할당 인원 강제 (0명 할당 상태로 둬도 허용 — 관리자가 순서대로 처리)
- 검색/필터가 있는 유저 선택 UI (현재 유저 수 규모에서는 전체 나열로 충분)

---

## DB 스키마 추가

```sql
ALTER TABLE quest_set
  ADD COLUMN is_public BOOLEAN NOT NULL DEFAULT TRUE;

CREATE TABLE quest_set_access (
  quest_set_id INT NOT NULL,
  user_id      INT NOT NULL,
  granted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (quest_set_id, user_id),
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id),
  FOREIGN KEY (user_id)      REFERENCES user(id)
);
```

`quest_set_access`는 비공개 세트에 대해서만 의미 있는 데이터다.
세트를 다시 공개로 돌려도 기존 할당 행은 남겨둔다 — `is_public`은 순수 플래그이고
`quest_set_access` 데이터에 영향을 주지 않는다. 따라서 공개 → 비공개로 재전환하면
예전에 할당됐던 유저가 자동으로 복원되어 다시 보인다. 별도의 "재비공개 시 초기화" 로직은 두지 않는다.

---

## 백엔드 API 변경

### GET /quest-sets — 인증 필요로 전환 + 접근 필터링

현재는 인증 없이 전체 세트를 반환한다. 접근 제어를 걸려면 "누가 요청했는지"를 알아야 하므로
`authMiddleware`를 추가하고, 공개 세트 + admin + 본인에게 할당된 비공개 세트만 반환한다.

프론트(`frontend/src/api/quest.ts`의 `fetchQuestSets`)는 이미 `authHeaders()`로 토큰을 보내고 있어
프론트 변경 없이 백엔드만 `authMiddleware` 추가로 충분하다 (기존에는 토큰을 보내도 무시되고 있었음).

```sql
SELECT qs.id, qs.title, qs.description, qs.sandbox_type, qs.category
FROM quest_set qs
WHERE qs.is_public = TRUE
   OR ? = 'admin'
   OR EXISTS (
     SELECT 1 FROM quest_set_access qsa
     WHERE qsa.quest_set_id = qs.id AND qsa.user_id = ?
   )
```

admin은 role 검사만으로 모든 세트에 접근 가능 — 관리 목적상 admin이 자기가 관리하는 세트 내용을
못 보면 관리 화면에서 미리보기조차 안 되는 상황이 생기므로, `quest_set_access` 등록 여부와 무관하게 우회한다.

### GET /quest-sets/:id/quests — 접근 권한 확인 후 403

세트 접근 권한이 없는 유저가 URL을 직접 조작해 퀘스트 목록을 요청하면 403을 반환한다.
권한 확인 로직(공개 여부, admin 우회, `quest_set_access` 존재 여부 모두 포함)은 위 쿼리와 동일한 조건으로
`services/quest.ts`에 `canAccessQuestSet(userId, role, questSetId)` 헬퍼로 분리.

### quest_attempt / 진행률 / 리더보드 — 변경 없음

`services/user.ts`의 `getProgress`, `getLeaderboard`는 `quest_set`을 그대로 조인하는 기존 쿼리를 유지한다.
접근 제어는 "지금 볼 수 있는 목록"(`GET /quest-sets`)에만 적용하고, 이미 쌓인 이력을 보여주는 화면은
건드리지 않는다 — 할당 해제된 세트라도 과거에 진행한 기록은 Progress/Leaderboard에 계속 표시된다.

### 관리자 전용 API (신규)

- `GET /admin/users` — 전체 유저 목록 (id, name, email, role). 현재 부재 — 접근 할당 UI에서 유저를 고르려면 필요.
- `GET /admin/quest-sets` — 전체 세트 목록 + `is_public` + 할당된 유저 목록
- `PATCH /admin/quest-sets/:id` — `is_public` 토글 (최소 할당 인원 등 제약 없음, 0명 할당 상태도 허용)
- `POST /admin/quest-sets/:id/access` — `{ userId }` 할당
- `DELETE /admin/quest-sets/:id/access/:userId` — 할당 해제

전부 `adminMiddleware` 적용.

---

## 프론트 변경

### 관리자 화면 (신규)

기존에 관리자 전용 화면이 없으므로 신규 필요. 현재는 세트 접근 관리 목적으로만 사용
(계정 생성/피드백 조회 등 다른 관리 기능은 범위 밖, 후속 과제).

**라우팅**: `App.tsx`는 URL 라우터(react-router 등) 없이 `page` state
(`'home' | 'progress' | 'leaderboard'`)로 화면을 전환하는 구조. 이번에도 같은 패턴을 따라
`page` state에 `'admin'`을 추가한다 — 이 기능 하나 때문에 라우터를 새로 도입하지 않는다.

**진입 경로**: SideNav에 `user.role === 'admin'`일 때만 보이는 메뉴 항목 추가.

**방어**: `member`가 어떤 경로로든 `page === 'admin'`에 진입하면(실질적 보안 경계는 백엔드
`adminMiddleware`가 담당하므로 이건 UX 목적) 프론트에서 즉시 `'home'`으로 리다이렉트한다.

**화면 구성**
- 세트 목록 테이블: 제목, 공개 여부 토글, 접근 유저 수
- 세트 클릭 시 접근 유저 목록 + 유저 추가/삭제 UI — 전체 유저를 체크박스로 나열 (검색/필터 없음, 현재 유저 규모에서는 불필요)

### SetSelect.tsx

변경 없음 — `fetchQuestSets()`가 백엔드에서 이미 필터링된 목록을 반환하므로 프론트 로직은 그대로.

---

## 검증

1. 공개 세트는 로그인한 모든 유저에게 노출
2. 비공개 세트는 미할당 유저에게 `GET /quest-sets` 응답에서 제외
3. 미할당 유저가 `GET /quest-sets/:id/quests`를 직접 호출하면 403
4. 관리자가 세트를 비공개로 전환 후 유저 할당 → 해당 유저에게만 노출
5. 관리자가 할당 해제 → 해당 유저 접근 불가로 전환
6. admin 계정은 `quest_set_access` 등록 여부와 무관하게 모든 세트(공개/비공개) 조회 가능
7. 할당 해제 후에도 해당 유저의 기존 `quest_attempt` 이력은 Progress/Leaderboard에 그대로 표시됨
8. 세트를 비공개 → 공개 → 비공개로 재전환하면 이전 할당 유저가 별도 재할당 없이 자동 복원됨
9. `member` 계정으로 관리자 화면(`page === 'admin'`) 진입 시도 → `home`으로 리다이렉트
10. `GET /admin/users`로 전체 유저 목록(id, name, email, role) 조회 가능
