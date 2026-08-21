# Phase 12 — 프론트엔드 API 어댑터 (Step 10 조기 적용)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)

## 배경 — 왜 이 문서가 필요한가

명세는 원래 "Step 1~9는 백엔드(Kotlin)만 완성하고 curl/MockMvc/Testcontainers로만 검증한다 —
프론트 코드는 건드리지 않는다. 모든 도메인의 백엔드 전환이 끝난 뒤 Step 10(cutover)에서
프론트엔드 API 모듈(`frontend/src/api/*.ts`) 전체를 `ApiResponse` 포맷에 맞게 한 번에
고친다"는 방침을 세웠다. Step 1에서 응답을 `ApiResponse<T>`(`{ meta, data }`) 공통
래퍼로 감싸기로 결정하면서 Node.js와 Kotlin 백엔드의 응답 포맷이 이미 벌어져 있었기
때문이다.

Step 6-1(터미널)까지 진행하면서 이 트레이드오프가 예상보다 크게 느껴지는 지점이 나왔다 —
브라우저로 실제 로그인부터 확인하는 수동 검증이 Step 10 전까지 아예 불가능하다는 점이다.
프론트가 원본 Node.js 응답 모양(`{ token, user }`, 실패 시 `{ error: "..." }`)을 그대로
기대하는데, Kotlin 백엔드는 `{ meta: { result, errorCode, message }, data: {...} }`로 감싸
보내므로 `loginApi`의 `data.error`, `return data as {...}` 같은 코드가 전부 어긋난다.

## 필드명 표기법 문제 — 왜 "얇은 어댑터"만으로는 안 되는가

여기에 더해 **필드명 표기법도 다르다.** 처음에는 `apiFetch` 안에서 camelCase → snake_case로
일괄 변환하는 방법을 검토했지만, 실제로 원본 Node.js 응답을 전수 조사해보니 **엔드포인트마다
표기법이 제각각**이었다:

- `backend/src/services/progress.ts`의 `getProgress`: SQL에서 `qs.id AS quest_set_id`로
  **snake_case**를 직접 명명
- 같은 파일의 `getLeaderboard`: SQL에서 `u.id AS userId`, `qs.id AS questSetId`로
  **camelCase**를 직접 명명
- `admin.ts`/`quest.ts`의 다른 응답들도 DB 컬럼명을 그대로 흘려보내 `sandboxType`,
  `isPublic`처럼 snake_case가 섞여 있음

즉 원본 자체가 일관된 컨벤션을 따른 게 아니라, 작성 시점마다 SQL alias를 다르게 지은
결과물이다. 전역으로 한쪽 표기법으로 변환하면 표기법이 우연히 일치하는 엔드포인트는
멀쩡하지만 다른 엔드포인트는 깨진다 — 실제로 `/progress`(snake_case)와
`/leaderboard`(camelCase)가 정확히 이 충돌 사례였다.

**정석은 camelCase다.** JSON API에서 camelCase는 사실상 업계 표준이고, Kotlin도 이미
일관되게 camelCase로 직렬화한다. 원본의 snake_case는 "의도된 컨벤션"이 아니라 raw SQL
컬럼명을 그대로 노출한 부산물에 가깝다(`getLeaderboard`가 이미 camelCase로 alias를 준
것도 원 작성자가 실질적으로 camelCase를 선호했다는 방증이다). 그래서 이 문서는 **변환
로직을 두지 않고, 프론트의 snake_case 필드 참조 자체를 camelCase로 통일**하는
방향을 택한다.

이 때문에 이 작업은 `frontend/src/api/` 폴더를 넘어 **`types.ts`와 그 타입을 참조하는
페이지 컴포넌트 몇 곳까지** 함께 수정한다 — 애초에 "API 모듈만 건드리고 컴포넌트는
전혀 안 건드린다"는 순수한 어댑터로는 표기법 문제를 해결할 수 없기 때문이다. 다만
수정 범위는 여전히 작다: 아래 나열된 파일 몇 개의 필드명 표기만 바뀌고, 로직/구조/UI는
그대로다.

## 원칙

- **래퍼(`{meta, data}`) 언래핑은 `frontend/src/api/base.ts`의 공통 헬퍼(`apiFetch`)
  하나로 처리한다** — 이 부분은 API 모듈 밖으로 절대 새지 않는다.
- **필드명은 camelCase로 통일한다** — `sandboxType`→`sandboxType`,
  `setupCmd`→`setupCmd`, `questSetId`→`questSetId`, `isPublic`→`isPublic`.
  변환 로직 없이 Kotlin이 내려주는 그대로 쓴다.
- 수정 대상 파일은 다음으로 한정한다: `frontend/src/api/*.ts`(6개),
  `frontend/src/types.ts`, `frontend/src/pages/SetSelect.tsx`,
  `frontend/src/pages/Progress.tsx`, `frontend/src/pages/Admin.tsx`. 이 목록 밖의
  컴포넌트는 snake_case 필드를 참조하지 않으므로 손대지 않는다(아래 "영향받는 파일
  전수 조사" 참고).
- 각 api 함수의 **에러 처리 방식(실패 시 예외 throw)은 유지**하되, 응답 필드명은
  camelCase로 바뀐다는 점만 호출부에 전파한다.
- 이 작업 이후에도 **Step 10에서 할 일이 사라지는 건 아니다** — Step 10은 여전히
  "백엔드 전체 전환 완료 후 프론트로 전체 시나리오 회귀 검증"을 최종적으로 수행한다.
  이 문서는 그 작업의 일부(응답 포맷·필드명 변환)를 미리 당겨서, Step 6-1 이후
  어느 시점에도 브라우저로 수동 검증할 수 있게 하는 것이 목적이다.

> 변환 책임을 어디에 둘지는 "새로 계약을 바꾼 쪽이 비용을 진다"는 원칙으로 정한다 —
> Node.js는 원본이자 프론트가 원래 맞춰져 있던 기준이므로 건드리지 않는다(애초에 이
> 프로젝트에서 Node.js는 마이그레이션 완료 후 삭제될 예정이라 재사용 계획 자체가
> 없다). 다만 지금은 필드명을 "원본에 맞추는" 변환이 아니라 "더 정석에 가까운 쪽으로
> 프론트를 갱신하는" 작업이므로, 비용은 프론트 쪽 코드(그것도 최소 범위)가 진다.

## 영향받는 파일 전수 조사

`grep -rln "sandbox_type\|setup_cmd\|quest_set_id\|is_public" frontend/src/`로 확인한
결과:

| 파일 | 참조 필드 |
|---|---|
| `types.ts` | `QuestSet.sandbox_type`, `Quest.setup_cmd` |
| `api/admin.ts` | `AdminQuestSet.sandbox_type`, `AdminQuestSet.is_public` |
| `pages/SetSelect.tsx` | `r.quest_set_id`, `s.sandbox_type` |
| `pages/Progress.tsx` | `ProgressRow.quest_set_id` |
| `pages/Admin.tsx` | `set.is_public`, `s.is_public` |

`pages/Leaderboard.tsx`는 애초에 camelCase(`questSetId`, `questSetTitle`, `userId`,
`userName`)를 쓰고 있어 원본 `getLeaderboard`와 이미 일치하므로 수정 대상이 아니다.

## 1. `base.ts`에 `apiFetch` 헬퍼 추가

```ts
export const BASE = import.meta.env.VITE_API_BASE ?? ''

export const token = {
  get: () => localStorage.getItem('token') ?? '',
  set: (t: string) => localStorage.setItem('token', t),
  clear: () => localStorage.removeItem('token'),
}

export function authHeaders(): HeadersInit {
  const t = token.get()
  return t ? { 'Authorization': `Bearer ${t}`} : {}
}

interface ApiResponse<T> {
  meta: { result: 'SUCCESS' | 'FAIL'; errorCode: string | null; message: string | null }
  data: T
}

export async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, options)
  const body: ApiResponse<T> = await res.json()
  if (body.meta.result !== 'SUCCESS') {
    throw new Error(body.meta.message ?? '요청에 실패했습니다.')
  }
  return body.data
}
```

> `ApiResponse<T>`가 Kotlin 쪽 `interfaces/api/ApiResponse.kt`(Step 1)와 필드 이름까지
> 동일한 이유는, 이 타입이 정확히 그 클래스가 JSON으로 직렬화된 모양을 그대로 옮긴
> 것이기 때문이다. Kotlin 쪽 필드명이나 `result` enum 값이 바뀌면 이 인터페이스도
> 함께 바꿔야 한다 — 두 정의가 어긋나면 여기서 파싱은 성공하지만 `body.meta.result`
> 비교가 항상 거짓/참으로 고정되는 조용한 버그가 생긴다.
>
> `res.ok`(HTTP 상태 코드)가 아니라 `body.meta.result`로 성공/실패를 판단하는 이유는,
> `ApiControllerAdvice`(Step 1)가 검증 실패는 400, 인증 실패는 401 등으로 HTTP 상태
> 코드 자체는 다양하게 내려주지만 **본문 포맷은 항상 `{meta, data}` 하나로 통일**되어
> 있기 때문이다 — `res.ok` 체크와 `body.meta.result` 체크가 사실상 항상 같은 결과를
> 주더라도, 명세상 유일한 진실 공급원은 `meta.result`이므로 그쪽을 기준으로 삼는다.
>
> 필드명 변환 로직을 이 헬퍼에 두지 않는 이유는 위 "필드명 표기법 문제" 절에서 설명한
> 대로다 — 전역 변환은 원본이 이미 비일관적이라 오히려 새로운 불일치를 만든다. 대신
> `data`는 Kotlin이 준 camelCase 그대로 통과시키고, 호출부(타입/컴포넌트)를 그
> 표기법에 맞춘다.

## 2. 각 api 파일 수정

패턴은 전부 동일하다: `fetch(...).then(r => r.json())` 또는
`const res = await fetch(...); ...; return res.json()` 형태를
`return apiFetch<T>(path, options)`로 바꾼다. 응답 타입 `T`만 함수마다 다르게 지정한다.

### `auth.ts`

```ts
import { BASE, authHeaders, apiFetch } from './base'

export { token } from './base'

export async function loginApi(email: string, password: string) {
  return apiFetch<{ token: string; user: { id: number; name: string; email: string; role: string } }>(
    '/auth/login',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    }
  )
}

export async function fetchMe() {
  return apiFetch<{ id: number; name: string; email: string; role: string }>(
    '/me',
    { headers: authHeaders() }
  )
}

export async function changePassword(currentPassword: string, newPassword: string) {
  await apiFetch<void>('/me/password', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ currentPassword, newPassword }),
  })
}
```

> `changePassword`가 `apiFetch<void>`를 쓰는 이유는 `ApiResponse<Unit>`이 Kotlin
> 쪽에서 `data: null`로 내려오기 때문이다 — `void`/`null`을 반환값으로 받되 실제로는
> 아무도 그 값을 쓰지 않으므로 문제되지 않는다. `auth.ts`가 참조하는 필드(`token`,
> `user.id/name/email/role`)는 원본부터 camelCase였으므로 이 파일 자체에는 표기법
> 변경이 없다 — 래퍼 언래핑만 적용된다.

### `quest.ts`

```ts
import { apiFetch, authHeaders } from './base'
import type { Quest, QuestSet } from '../types'

export async function fetchQuestSets() {
  return apiFetch<QuestSet[]>('/quest-sets', { headers: authHeaders() })
}

export async function fetchQuests(setId: number) {
  return apiFetch<Quest[]>(`/quest-sets/${setId}/quests`, { headers: authHeaders() })
}

export async function gradeQuest(
  containerId: string,
  questId: number,
  questSetId: number,
  sessionId: string,
  elapsedSec: number,
  hintUsed: boolean,
  solutionUsed: boolean,
) {
  return apiFetch<{ passed: boolean }>('/grade', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId, questId, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed }),
  })
}

export async function endSession(containerId: string) {
  return apiFetch<void>('/session/end', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId }),
  })
}
```

> `Quest`/`QuestSet`은 `frontend/src/types.ts`에 정의돼 있는 타입을 그대로 import해
> 쓴다(아래 3절에서 이 두 타입 자체를 camelCase로 갱신한다). `{ passed: boolean }`
> (`gradeQuest`의 응답)은 실제 호출부가 참조하는 필드에 맞춰 정확한 모양을 확인한
> 뒤 채워 넣는다 — 이 문서는 어댑터 패턴을 보여주는 것이 목적이라 이 타입은 예시다.
> `gradeQuest`/`endSession`은 **Step 7(채점)/Step 9(세션 종료)가 아직 구현되지
> 않았으므로** 이 두 함수는 해당 Step이 끝나기 전까지는 호출해도 404(엔드포인트
> 없음)가 난다 — 이 시점에는 어댑터 계층만 미리 맞춰두고, 실제 동작 확인은 해당
> Step 완료 후로 미룬다.

### `admin.ts`

```ts
import { apiFetch, authHeaders } from './base'

export interface AdminUser {
    id: number
    name: string
    email: string
    role: string
}

export interface AdminQuestSet {
    id: number
    title: string
    description: string
    sandboxType: string
    category: string
    isPublic: boolean
    accessUsers: { id: number; name: string; email: string}[]
}

export async function fetchAllUsers(): Promise<AdminUser[]> {
    return apiFetch<AdminUser[]>('/admin/users', { headers: authHeaders() })
}

export async function fetchAdminQuestSets(): Promise<AdminQuestSet[]> {
    return apiFetch<AdminQuestSet[]>('/admin/quest-sets', { headers: authHeaders() })
}

export async function setQuestSetPublic(id: number, isPublic: boolean) {
    await apiFetch<void>(`/admin/quest-sets/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type' : 'application/json', ...authHeaders() },
        body: JSON.stringify({ isPublic }),
    })
}

export async function grantAccess(questSetId: number, userId: number) {
    await apiFetch<void>(`/admin/quest-sets/${questSetId}/access`, {
        method: 'POST',
        headers: { 'Content-Type' : 'application/json', ...authHeaders() },
        body: JSON.stringify({ userId }),
    })
}

export async function revokeAccess(questSetId: number, userId: number) {
    await apiFetch<void>(`/admin/quest-sets/${questSetId}/access/${userId}`, {
        method: 'DELETE',
        headers: authHeaders(),
    })
}
```

> `AdminQuestSet`의 `sandboxType`→`sandboxType`, `isPublic`→`isPublic`이 이 파일에서
> 실제로 표기법이 바뀌는 지점이다 — 이 인터페이스를 참조하는 `pages/Admin.tsx`도
> 함께 수정한다(4절 참고). `setQuestSetPublic`의 요청 바디도 `is_public: isPublic`
> (원본이 요청 바디는 snake_case로 보내던 것)에서 `{ isPublic }`(camelCase 그대로)로
> 바뀐다 — `PATCH /admin/quest-sets/{id}`의 Kotlin 컨트롤러가 요청 바디를 어떤
> 필드명으로 바인딩하는지(Step 2/3 가이드의 `AdminQuestSetV1Controller` 요청 DTO)
> 확인해 실제 필드명과 일치시킨다.
>
> 원본 `setQuestSetPublic`/`grantAccess`/`revokeAccess`는 `await fetch(...)`만 하고
> 응답을 전혀 확인하지 않아, 요청이 실패해도 호출부에서 조용히 넘어갔다.
> `apiFetch`로 바꾸면 `body.meta.result !== 'SUCCESS'`일 때 예외를 던지므로 이 세
> 함수는 **원본보다 엄격해진다**(실패를 감지할 수 있게 됨) — 이건 어댑터가 만들어낸
> 부수 효과다. 원본과 동작을 한 치도 다르지 않게 맞추고 싶다면 이 세 함수만
> `.catch(() => {})`로 감싸 실패를 다시 무시하게 할 수 있다.

### `user.ts` (progress/leaderboard)

```ts
import { apiFetch, authHeaders } from './base'

export interface QuestSetProgress {
  questSetId: number
  title: string
  category: string
  total: number
  completed: number
}

export interface QuestSetProgressDetail {
  questSetId: number
  questSetTitle: string
  category: string
  total: number
  completed: number
}

export interface MemberProgress {
  userId: number
  userName: string
  total: number
  completed: number
  sets: QuestSetProgressDetail[]
}

export async function fetchProgess() {
  return apiFetch<QuestSetProgress[]>('/progress', { headers: authHeaders() })
}

export async function fetchLeaderboard() {
  return apiFetch<MemberProgress[]>('/leaderboard', { headers: authHeaders() })
}
```

> 이 세 인터페이스는 Step 4의 `domain/progress/ProgressSummary.kt`
> (`QuestSetProgress`/`QuestSetProgressDetail`/`MemberProgress`)가 JSON으로 직렬화된
> 모양을 그대로 옮긴 것이다 — `title`(내 진행률) vs `questSetTitle`(리더보드 세트별
> 상세)처럼 Step 4에서 의도적으로 다르게 둔 필드명 차이를 그대로 반영한다.
> `MemberProgress`는 원본 `getLeaderboard`도 이미 camelCase였으므로
> `pages/Leaderboard.tsx`는 수정하지 않는다. `QuestSetProgress`(원본은
> `questSetId`)만 `pages/Progress.tsx`에서 표기법이 바뀐다(4절 참고).

### `feedback.ts`

```ts
import { apiFetch } from './base'

export async function submitFeedback(data: {
    page: string
    questId?: number | null
    questSetId?: number | null
    body: string
}) {
    return apiFetch<void>('/feedback', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    })
}
```

> 원본이 `authHeaders()`를 붙이지 않은 이유(Step 4 인수 조건 — `/feedback`은 로그인
> 여부와 무관하게 열려 있고, 토큰이 있으면 그 사용자로 기록되지만 없어도 401이
> 아니라 익명으로 등록됨)를 그대로 유지한다. 실제로 로그인한 사용자의 피드백에
> `userId`를 기록하고 싶다면 `authHeaders()`를 추가해야 하는데, 이는 어댑터
> 문제가 아니라 원본 동작 자체에 대한 질문이므로 원본 `feedback.ts`를 다시 확인해
> 결정한다.

## 3. `types.ts` — 필드명 camelCase로 갱신

```ts
export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
  setupCmd: string[] | null
}

export interface QuestSet {
  id: number
  title: string
  description: string
  sandboxType: string
  category: string
}
```

> `setupCmd`→`setupCmd`, `sandboxType`→`sandboxType` 두 필드만 바뀐다. 나머지
> 필드(`id`, `title`, `description`, `hint`, `solution`, `category`)는 원본부터
> camelCase 표기와 충돌하지 않는 단일 단어라 변경이 없다.

## 4. 이 타입을 참조하는 컴포넌트 수정

### `pages/SetSelect.tsx`

```ts
// Before
rows.forEach(r => { map[r.quest_set_id] = { total: Number(r.total), completed: Number(r.completed) } })
// ...
onClick={() => onSelect(s.id, s.sandbox_type)}

// After
rows.forEach(r => { map[r.questSetId] = { total: Number(r.total), completed: Number(r.completed) } })
// ...
onClick={() => onSelect(s.id, s.sandboxType)}
```

> `rows`는 `fetchProgess()`(위 `user.ts`의 `QuestSetProgress[]`)의 결과이므로
> `questSetId`로 바뀐다. `s`는 `fetchQuestSets()`(`QuestSet[]`)의 원소이므로
> `sandboxType`으로 바뀐다.

### `pages/Progress.tsx`

```ts
// Before
interface ProgressRow {
    quest_set_id: number
    title: string
    category: string
    total: number
    completed: number
}
// ...
<tr key={r.quest_set_id} ...>

// After
interface ProgressRow {
    questSetId: number
    title: string
    category: string
    total: number
    completed: number
}
// ...
<tr key={r.questSetId} ...>
```

> `ProgressRow`는 `user.ts`에 새로 정의한 `QuestSetProgress`와 필드가 사실상
> 동일해졌다 — 이 시점에 `ProgressRow`를 지우고 `QuestSetProgress`를 직접 import해
> 쓰도록 통합해도 되지만, 이 문서는 표기법 변경만을 범위로 하므로 로컬 인터페이스는
> 그대로 두고 필드명만 맞춘다. 통합은 별도 리팩터링으로 남겨둔다.

### `pages/Admin.tsx`

```ts
// Before
await setQuestSetPublic(set.id, !set.is_public)
// ...
className={`... ${s.is_public ? '...' : '...'}`}
{s.is_public ? '공개' : '비공개'}
{s.is_public ? '-' : s.accessUsers.length}
{selectedSetId === s.id && !s.is_public && (

// After
await setQuestSetPublic(set.id, !set.isPublic)
// ...
className={`... ${s.isPublic ? '...' : '...'}`}
{s.isPublic ? '공개' : '비공개'}
{s.isPublic ? '-' : s.accessUsers.length}
{selectedSetId === s.id && !s.isPublic && (
```

> `set`/`s`는 `fetchAdminQuestSets()`(`admin.ts`의 `AdminQuestSet[]`)의 원소이므로
> `isPublic`을 전부 `isPublic`으로 바꾼다. `setQuestSetPublic` 호출 자체(함수
> 시그니처)는 이미 `isPublic: boolean` 파라미터였으므로 바뀌지 않는다 — 함수
> 내부에서 요청 바디를 만드는 방식만 2절에서 이미 바뀌었다.

## 검증 방법

1. `frontend/`에서 `npm run dev`로 프론트를 띄우고, `.env` 또는 `VITE_API_BASE`를
   Kotlin 백엔드 주소(`http://localhost:3001`)로 맞춘다.
2. Kotlin 백엔드(`./gradlew bootRun`)와 로컬 MariaDB, Docker 데몬을 띄운다.
3. 브라우저로 로그인 → 퀘스트 목록(공개 여부·sandboxType 배지 정상 표시 확인) →
   내 진행률 페이지(퀘스트셋별 카드 정상 렌더 확인) → (Step 6-1이 지원하는
   `linux`/`docker`/`docker-persistent` 타입 한정) 터미널 열기까지 실제로 확인한다.
4. 관리자 계정으로 로그인해 `Admin.tsx`(공개/비공개 토글, 접근 권한 부여/회수)도
   확인한다.
5. `gradeQuest`/`endSession`처럼 아직 구현되지 않은 Step(7, 9) 대상 엔드포인트는
   404가 나는 것이 정상이다 — 해당 Step 완료 후 다시 확인한다.

## Step 10과의 관계

Step 10(cutover) 문서 작성 시점에 이 문서가 이미 적용돼 있다면, Step 10은 "프론트
API 모듈 전체 전환" 항목을 이 문서로 대체하고 나머지(엔드포인트 URL이 이후 Step에서
바뀐 게 있다면 그 갱신, 전체 시나리오 최종 회귀 검증)만 다루면 된다. 이 문서가 아직
적용되지 않은 채로 Step 10에 도달했다면, Step 10 문서가 이 내용을 그대로 흡수해서
진행한다.
