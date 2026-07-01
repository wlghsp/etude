# Phase 7h 구현 가이드 — 퀘스트 세트 접근 제어

명세: [specs/spec_phase7_quest_access.md](../specs/spec_phase7_quest_access.md)

이 문서를 보고 `spec_phase7_quest_access.md`를 구현합니다.

---

## 구현 순서

```
1. 00_schema.sql — quest_set.is_public, quest_set_access 테이블 추가  → DB 재초기화로 확인
2. services/quest.ts — canAccessQuestSet, getQuestSets 필터링, 관리자용 CRUD 함수 → 단독 호출로 확인
3. services/user.ts — 관리자용 getAllUsers 추가                      → 단독 호출로 확인
4. plugins/auth-guard.ts — 변경 없음 (기존 authMiddleware/adminMiddleware 재사용)
5. routes/quest.routes.ts — GET /quest-sets 인증 적용, :id/quests 403 처리 → curl로 확인
6. routes/admin.routes.ts — 유저 목록 + 세트 접근 관리 API 5종 추가    → curl로 확인
7. frontend/api — quest-set 접근 관리 API 클라이언트 추가             → 타입 확인
8. frontend/pages/Admin.tsx — 관리자 화면 신규 작성                  → 브라우저로 확인
9. App.tsx, SideNav.tsx — 'admin' page 추가 + 진입/방어 로직          → 브라우저로 확인
```

---

## Step 1. DB 스키마 — is_public + quest_set_access

`backend/db/00_schema.sql`의 `quest_set` 테이블 정의를 아래와 같이 수정한다:

```sql
CREATE TABLE quest_set (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(100) NOT NULL,
  description  TEXT,
  sandbox_type VARCHAR(20) NOT NULL DEFAULT 'linux',
  category     VARCHAR(50) NOT NULL DEFAULT '기타',
  is_public    BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (sandbox_type) REFERENCES sandbox(type)
);
```

`user` 테이블 정의 다음에 `quest_set_access` 테이블을 추가한다 (두 테이블을 모두 참조하므로 `user`, `quest_set` 정의 이후 위치):

```sql
CREATE TABLE quest_set_access (
  quest_set_id INT NOT NULL,
  user_id      INT NOT NULL,
  granted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (quest_set_id, user_id),
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id),
  FOREIGN KEY (user_id)      REFERENCES user(id)
);
```

> 이 프로젝트는 아직 마이그레이션 도구 없이 `db/` 초기화 스크립트를 직접 수정하는 방식(Phase 4~6과 동일).
> 기존 `quest_set` 데이터는 전부 공개 학습용 콘텐츠이므로 `DEFAULT TRUE`로 기존 동작을 그대로 유지한다.

재초기화:

```bash
docker-compose down -v && docker-compose up -d
```

---

## Step 2. services/quest.ts — 접근 제어 로직

`backend/src/services/quest.ts`를 수정한다.

### 2-1. getQuestSets — 접근 필터링

기존:

```typescript
export async function getQuestSets(): Promise<QuestSet[]> {
  const [rows] = await db.query('SELECT id, title, description, sandbox_type, category FROM quest_set')
  return rows as QuestSet[]
}
```

변경 — `userId`, `role`을 받아 명세의 필터 쿼리를 적용:

```typescript
export async function getQuestSets(userId: number, role: string): Promise<QuestSet[]> {
  const [rows] = await db.query(
    `SELECT qs.id, qs.title, qs.description, qs.sandbox_type, qs.category
     FROM quest_set qs
     WHERE qs.is_public = TRUE
        OR ? = 'admin'
        OR EXISTS (
          SELECT 1 FROM quest_set_access qsa
          WHERE qsa.quest_set_id = qs.id AND qsa.user_id = ?
        )`,
    [role, userId]
  )
  return rows as QuestSet[]
}
```

### 2-2. canAccessQuestSet — 단건 접근 확인

`GET /quest-sets/:id/quests`에서 재사용할 헬퍼. 위와 동일한 조건을 단일 세트에 대해 확인한다:

```typescript
export async function canAccessQuestSet(userId: number, role: string, questSetId: number): Promise<boolean> {
  const [rows] = await db.query<any[]>(
    `SELECT 1 FROM quest_set qs
     WHERE qs.id = ?
       AND (
         qs.is_public = TRUE
         OR ? = 'admin'
         OR EXISTS (
           SELECT 1 FROM quest_set_access qsa
           WHERE qsa.quest_set_id = qs.id AND qsa.user_id = ?
         )
       )`,
    [questSetId, role, userId]
  )
  return rows.length > 0
}
```

### 2-3. 관리자용 함수 — 세트 목록/토글/접근 관리

`GET /admin/quest-sets`, `PATCH /admin/quest-sets/:id`, `POST/DELETE .../access` 각각에 대응하는 함수 4개를 추가한다:

```typescript
export async function getQuestSetsForAdmin() {
  const [sets] = await db.query<any[]>(
    'SELECT id, title, description, sandbox_type, category, is_public FROM quest_set ORDER BY id'
  )
  const [access] = await db.query<any[]>(
    `SELECT qsa.quest_set_id, u.id AS userId, u.name, u.email
     FROM quest_set_access qsa
     JOIN user u ON u.id = qsa.user_id`
  )
  return sets.map((s) => ({
    ...s,
    is_public: Boolean(s.is_public),
    accessUsers: access
      .filter((a) => a.quest_set_id === s.id)
      .map((a) => ({ id: a.userId, name: a.name, email: a.email })),
  }))
}

export async function setQuestSetPublic(questSetId: number, isPublic: boolean) {
  await db.query('UPDATE quest_set SET is_public = ? WHERE id = ?', [isPublic, questSetId])
}

export async function grantQuestSetAccess(questSetId: number, userId: number) {
  await db.query(
    'INSERT IGNORE INTO quest_set_access (quest_set_id, user_id) VALUES (?, ?)',
    [questSetId, userId]
  )
}

export async function revokeQuestSetAccess(questSetId: number, userId: number) {
  await db.query(
    'DELETE FROM quest_set_access WHERE quest_set_id = ? AND user_id = ?',
    [questSetId, userId]
  )
}
```

> `grantQuestSetAccess`는 `INSERT IGNORE` — 이미 할당된 유저를 중복 할당해도 PK 충돌로 500이 나지 않게 한다.

---

## Step 3. services/user.ts — 전체 유저 목록

`GET /admin/users`(전체 목록 조회, 기존 `POST /admin/users`는 계정 *생성* API라 이름은 같지만 역할이 다름 — 명세대로 GET 메서드로 구분)에서 쓸 함수를 추가한다:

```typescript
export async function getAllUsers() {
  const [rows] = await db.query("SELECT id, name, email, role FROM user WHERE role = 'member' ORDER BY name")
  return rows
}
```

> `role = 'member'`로 제한 — admin은 `canAccessQuestSet`에서 이미 role만으로 모든 세트에 우회 접근하므로 `quest_set_access`로 개별 할당할 대상이 아니다. 필터링 없이 전체를 반환하면 관리자 화면의 접근 유저 체크박스 목록에 admin 계정도 섞여 나와 혼란을 준다.

---

## Step 4. routes/quest.routes.ts — 라우트 변경

`backend/src/routes/quest.routes.ts`를 수정한다.

```typescript
import type { FastifyPluginAsync } from "fastify";
import { getQuests, getQuestSets, gradeQuest, canAccessQuestSet } from "../services/quest.js";
import { verifyToken } from "../services/auth.js";
import { recordAttempt } from "../services/user.js";
import { docker } from '../plugins/docker.js'
import { authMiddleware } from '../plugins/auth-guard.js'

export const questRoutes: FastifyPluginAsync = async (app) => {
    app.get('/quest-sets', { preHandler: authMiddleware }, async (req: any) => {
        return getQuestSets(req.user.userId, req.user.role)
    })

    app.get<{ Params: { id: string }}>('/quest-sets/:id/quests', { preHandler: authMiddleware }, async (req: any, reply) => {
        const questSetId = Number(req.params.id)
        const allowed = await canAccessQuestSet(req.user.userId, req.user.role, questSetId)
        if (!allowed) return reply.code(403).send({ error: '이 세트에 접근할 권한이 없습니다.' })
        return getQuests(questSetId)
    })

    app.post('/grade', async (req) => {
    const { containerId, questId, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed }
        = req.body as {
            containerId: string
            questId: number
            questSetId: number
            sessionId: string
            elapsedSec?: number
            hintUsed?: boolean
            solutionUsed?: boolean
        }
        const passed = await gradeQuest(containerId, questId, docker)

        const auth = req.headers['authorization'] ?? ''
        const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
        if (token) {
            try {
                const payload = verifyToken(token)
                await recordAttempt(payload.userId, questId, questSetId, sessionId, passed, elapsedSec, hintUsed, solutionUsed)
            } catch (e) { console.error('[grade] recordAttempt error:', e) }
        }

        return { passed }
    }
)
}
```

> `/grade`는 명세 범위 밖 — 채점은 접근 제어와 무관하게 기존 그대로 둔다.

프론트(`frontend/src/api/quest.ts`의 `fetchQuestSets`, `fetchQuests`)는 이미 `authHeaders()`로 토큰을 보내고 있어 변경 불필요 — 명세에 명시된 대로 백엔드만 `authMiddleware` 추가로 충분하다.

---

## Step 5. routes/admin.routes.ts — 관리자 API 5종

`backend/src/routes/admin.routes.ts`에 추가한다.

```typescript
import type { FastifyPluginAsync } from "fastify"
import { adminMiddleware } from "../plugins/auth-guard.js";
import { createUser, resetPassword, getAllUsers } from "../services/user.js";
import { getFeedbackList } from "../services/feedback.js";
import { getQuestSetsForAdmin, setQuestSetPublic, grantQuestSetAccess, revokeQuestSetAccess } from "../services/quest.js";


export const adminRoutes: FastifyPluginAsync = async (app) => {
    app.post('/admin/users', { preHandler: adminMiddleware }, async (request) => {
        const { name, email, password } = request.body as { name: string; email: string; password: string }
        return createUser(name, email, password)
    })

    app.patch('/admin/users/:id/password', { preHandler: adminMiddleware }, async (request) => {
        const { id } = request.params as { id: string}
        const { password } = request.body as { password: string}
        await resetPassword(id, password)
        return { ok: true }
    })

    app.get('/admin/feedback', { preHandler: adminMiddleware }, async () => getFeedbackList())

    app.get('/admin/users', { preHandler: adminMiddleware }, async () => getAllUsers())

    app.get('/admin/quest-sets', { preHandler: adminMiddleware }, async () => getQuestSetsForAdmin())

    app.patch<{ Params: { id: string } }>('/admin/quest-sets/:id', { preHandler: adminMiddleware }, async (request) => {
        const { id } = request.params
        const { is_public } = request.body as { is_public: boolean }
        await setQuestSetPublic(Number(id), is_public)
        return { ok: true }
    })

    app.post<{ Params: { id: string } }>('/admin/quest-sets/:id/access', { preHandler: adminMiddleware }, async (request) => {
        const { id } = request.params
        const { userId } = request.body as { userId: number }
        await grantQuestSetAccess(Number(id), userId)
        return { ok: true }
    })

    app.delete<{ Params: { id: string; userId: string } }>('/admin/quest-sets/:id/access/:userId', { preHandler: adminMiddleware }, async (request) => {
        const { id, userId } = request.params
        await revokeQuestSetAccess(Number(id), Number(userId))
        return { ok: true }
    })
}
```

> `GET /admin/users`와 기존 `POST /admin/users`는 같은 경로, 다른 메서드 — 하나는 목록 조회, 하나는 계정 생성이라 충돌 없음.

### CORS 설정 — PATCH/DELETE 메서드 허용

`backend/src/index.ts`의 기존 CORS 등록은 `methods`를 지정하지 않고 있다:

```typescript
await fastify.register(cors, { origin: true })
```

지금까지 API는 GET/POST만 썼기 때문에 드러나지 않았지만, 이번에 추가한 `PATCH /admin/quest-sets/:id`, `DELETE /admin/quest-sets/:id/access/:userId`를 브라우저에서 호출하면
`Access-Control-Allow-Methods in preflight response` 에러로 요청 자체가 막힌다. `methods`를 명시한다:

```typescript
await fastify.register(cors, { origin: true, methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'] })
```

---

## Step 6. frontend/src/api — 관리자 API 클라이언트

`frontend/src/api/admin.ts` 신규 작성 (기존 `api/` 폴더는 도메인별로 파일이 나뉘어 있으므로 관리자 전용 파일로 분리):

```typescript
import { BASE, authHeaders } from './base'

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
  sandbox_type: string
  category: string
  is_public: boolean
  accessUsers: { id: number; name: string; email: string }[]
}

export async function fetchAllUsers(): Promise<AdminUser[]> {
  const res = await fetch(`${BASE}/admin/users`, { headers: authHeaders() })
  return res.json()
}

export async function fetchAdminQuestSets(): Promise<AdminQuestSet[]> {
  const res = await fetch(`${BASE}/admin/quest-sets`, { headers: authHeaders() })
  return res.json()
}

export async function setQuestSetPublic(id: number, isPublic: boolean) {
  await fetch(`${BASE}/admin/quest-sets/${id}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ is_public: isPublic }),
  })
}

export async function grantAccess(questSetId: number, userId: number) {
  await fetch(`${BASE}/admin/quest-sets/${questSetId}/access`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ userId }),
  })
}

export async function revokeAccess(questSetId: number, userId: number) {
  await fetch(`${BASE}/admin/quest-sets/${questSetId}/access/${userId}`, {
    method: 'DELETE',
    headers: authHeaders(),
  })
}
```

---

## Step 7. frontend/src/pages/Admin.tsx — 관리자 화면

기존 `Progress.tsx`, `Leaderboard.tsx`와 같은 레이아웃 패턴(`TopNav` + `SideNav` + `main`)을 따른다.
`SideNav`는 `activePage` 타입에 `'admin'`이 없으므로 Step 8에서 먼저 타입을 확장한다.

`frontend/src/pages/Admin.tsx` 신규 작성:

```typescript
import { useEffect, useState } from "react"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"
import {
  fetchAllUsers, fetchAdminQuestSets, setQuestSetPublic, grantAccess, revokeAccess,
  type AdminUser, type AdminQuestSet,
} from "../api/admin"

interface Props {
  onHome: () => void
  onProgress: () => void
  onLeaderboard: () => void
  onLogout: () => void
  userName: string
  userEmail: string
  userRole?: string
}

export function Admin({ onHome, onProgress, onLeaderboard, onLogout, userName, userEmail, userRole }: Props) {
  const [users, setUsers] = useState<AdminUser[]>([])
  const [sets, setSets] = useState<AdminQuestSet[]>([])
  const [selectedSetId, setSelectedSetId] = useState<number | null>(null)

  const reload = () => {
    fetchAllUsers().then(setUsers)
    fetchAdminQuestSets().then(setSets)
  }

  useEffect(() => { reload() }, [])

  const handleTogglePublic = async (set: AdminQuestSet) => {
    await setQuestSetPublic(set.id, !set.is_public)
    reload()
  }

  const handleToggleUser = async (setId: number, userId: number, granted: boolean) => {
    if (granted) await revokeAccess(setId, userId)
    else await grantAccess(setId, userId)
    reload()
  }

  return (
    <div className="dark min-h-screen bg-surface flex flex-col">
      <TopNav onHome={onHome} />
      <div className="flex flex-1 pt-14">
        <SideNav activePage="admin" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onHome} onProgress={onProgress} onLeaderboard={onLeaderboard} onAdmin={onHome} onLogout={onLogout} />

        <main className="flex-1 md:ml-60 flex flex-col items-center px-gutter py-8 bg-surface">
          <div className="w-full max-w-[900px] flex flex-col gap-8">
            <h1 className="font-mono text-headline-lg text-on-surface">퀘스트 세트 접근 관리</h1>

            <section className="bg-surface-container border border-outline-variant overflow-hidden">
              <table className="w-full text-left border-collapse">
                <thead className="bg-surface">
                  <tr>
                    <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">제목</th>
                    <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">공개 여부</th>
                    <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">접근 유저 수</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-outline-variant">
                  {sets.map((s) => (
                    <>
                      <tr
                        key={s.id}
                        onClick={() => setSelectedSetId(selectedSetId === s.id ? null : s.id)}
                        className={`cursor-pointer hover:bg-surface-container-highest/50 ${selectedSetId === s.id ? 'bg-surface-container-highest' : ''}`}
                      >
                        <td className="px-6 py-4 font-mono text-body-md">{s.title}</td>
                        <td className="px-6 py-4">
                          <button
                            onClick={(e) => { e.stopPropagation(); handleTogglePublic(s) }}
                            className={`font-mono text-code-sm px-2 py-1 border ${s.is_public ? 'text-success border-success/30 bg-success/5' : 'text-on-surface-variant border-outline-variant'}`}
                          >
                            {s.is_public ? '공개' : '비공개'}
                          </button>
                        </td>
                        <td className="px-6 py-4 font-mono text-code-sm text-on-surface-variant">
                          {s.is_public ? '-' : s.accessUsers.length}
                        </td>
                      </tr>
                      {selectedSetId === s.id && !s.is_public && (
                        <tr key={`${s.id}-access`} className="bg-surface-container-lowest">
                          <td colSpan={3} className="px-6 py-4">
                            <span className="font-mono text-label-caps text-on-surface-variant mb-2 block">접근 유저</span>
                            <div className="flex flex-col gap-1 max-h-64 overflow-y-auto">
                              {users.map((u) => {
                                const granted = s.accessUsers.some((a) => a.id === u.id)
                                return (
                                  <label key={u.id} className="flex items-center gap-2 font-mono text-body-md py-1">
                                    <input type="checkbox" checked={granted} onChange={() => handleToggleUser(s.id, u.id, granted)} />
                                    {u.name} ({u.email})
                                  </label>
                                )
                              })}
                            </div>
                          </td>
                        </tr>
                      )}
                    </>
                  ))}
                </tbody>
              </table>
            </section>
          </div>
        </main>
      </div>
    </div>
  )
}
```

> `Admin.tsx`도 다른 페이지들과 동일하게 `userRole`을 받아 `<SideNav>`에 전달해야 한다 — 빠뜨리면 관리자 화면에 진입하는 순간 `SideNav`가 `userRole === undefined`로 렌더링되어 "관리자" 메뉴 자체가 사라진다 (Step 8의 조건부 렌더링 `userRole === 'admin' && ...` 때문). `onAdmin`은 이미 admin 화면이므로 `onHome`을 넘겨도 무방 — `SideNav`의 `item()` 헬퍼가 `activePage === page`일 때는 `onClick`을 쓰지 않는다.
>
> 접근 유저 체크박스는 세트가 많아지면 테이블 아래 스크롤 끝까지 내려가야 보이는 문제가 있어, 별도 섹션 대신 선택한 행 바로 아래에 펼치는 아코디언 구조로 바꿨다 (`<tr key="{id}-access">`를 `colSpan`으로 전체 폭에 펼침). 같은 행을 다시 클릭하면 접힌다.

---

## Step 8. App.tsx, SideNav.tsx — 'admin' page 배선

### 8-1. SideNav.tsx — Page 타입 + 메뉴 항목

```typescript
type Page = 'home' | 'progress' | 'leaderboard' | 'admin'

interface Props {
    activePage: Page
    userName: string
    userEmail: string
    userRole?: string
    onHome: () => void
    onProgress: () => void
    onLeaderboard: () => void
    onAdmin?: () => void
    onLogout: () => void
}
```

`nav` 안에 admin 항목을 role 조건부로 추가:

```typescript
<nav className="flex-1 space-y-1">
    {item('grid_view', '트레이닝 세트', 'home', onHome)}
    {item('assignment', '내 진행현황', 'progress', onProgress)}
    {item('analytics', '랭킹', 'leaderboard', onLeaderboard)}
    {userRole === 'admin' && onAdmin && item('admin_panel_settings', '관리자', 'admin', onAdmin)}
</nav>
```

`Progress.tsx`, `Leaderboard.tsx`, `SetSelect.tsx`에서 `<SideNav>` 호출부에 `userRole={user.role}`과 `onAdmin={...}`을 추가해야 하므로, 각 페이지의 `Props`에도 `userRole`, `onAdmin`을 전달할 수 있게 시그니처를 넓힌다. (기존 페이지들은 `App.tsx`에서 이미 `user` 객체 전체를 들고 있으므로 prop 추가만 하면 된다.)

### 8-2. App.tsx — page state + 라우팅 + 방어

```typescript
import { Admin } from './pages/Admin'
// ...
const [page, setPage] = useState<'home' | 'progress' | 'leaderboard' | 'admin'>('home')
```

```typescript
if (page === 'admin') {
  if (user.role !== 'admin') { setPage('home'); return null }
  return <>
    <Admin
      onHome={() => setPage('home')}
      onProgress={() => setPage('progress')}
      onLeaderboard={() => setPage('leaderboard')}
      onLogout={handleLogout}
      userName={user.name}
      userEmail={user.email}
    />
    <FeedbackButton page="admin" />
  </>
}
```

> 실질적 보안 경계는 백엔드 `adminMiddleware`가 담당 — 이 리다이렉트는 UX 목적일 뿐이다 (명세 118~119행).

각 페이지 진입 지점(`SetSelect`, `Progress`, `Leaderboard` 호출부)에서 `onAdmin={() => setPage('admin')}`과 `userRole={user.role}`을 전달하도록 수정한다. 예:

```typescript
<SetSelect
    onSelect={handleSetSelect}
    onProgress={() => setPage('progress')}
    onLeaderboard={() => setPage('leaderboard')}
    onAdmin={() => setPage('admin')}
    onLogout={handleLogout}
    userName={user.name}
    userEmail={user.email}
    userRole={user.role}
/>
```

`Progress.tsx`, `Leaderboard.tsx`, `SetSelect.tsx`의 `Props` 인터페이스와 `<SideNav>` 호출부에도 동일하게 `userRole`, `onAdmin`을 추가하고 그대로 전달한다.

---

## 검증

```bash
cd backend && npx tsc --noEmit
cd frontend && npx tsc --noEmit
```

### 검증용 계정 / 세트

`backend/db/04_users.sql`에 이번 Phase 검증을 위해 member 계정을 하나 더 추가해뒀다 (기존엔 admin 1개 + member 1개뿐이라 "할당 O 유저 vs 할당 X 유저"를 동시에 비교할 수 없었음):

| 계정 | role | 용도 |
|------|------|------|
| `admin@okestro.com` / `cloud1234!` | admin | admin 우회 확인 |
| `test@okestro.com` / `cloud1234!` | member | 할당 대상 (비공개 세트에 할당) |
| `test2@okestro.com` / `cloud1234!` | member | 미할당 대상 (계속 미할당 상태로 둠) |

DB에 이미 컨테이너가 떠 있다면 재초기화해서 새 계정을 반영한다 (기존 데이터 삭제됨 — 로컬 개발 DB 기준):

```bash
cd backend && docker-compose down -v && docker-compose up -d
```

세트는 `quest_set.id = 1` ("리눅스 기초 1")을 비공개 전환 대상으로 사용한다.

### 브라우저 검증 체크리스트

1. admin으로 로그인 → 사이드바에 "관리자" 메뉴가 보이는지 확인 → 클릭해 관리자 화면 진입, 진입 후에도 "관리자" 메뉴가 계속 보이는지 확인 (Admin.tsx도 SideNav에 userRole을 넘겨야 유지됨)
2. 관리자 화면에서 세트 1의 "공개" 뱃지를 클릭 → "비공개"로 즉시 바뀌는지, 접근 유저 수 칸이 `-`에서 `0`으로 바뀌는지 확인
3. test2로 로그인 → "트레이닝 세트" 목록에서 세트 1이 사라졌는지 확인 (F12 콘솔에 CORS/네트워크 에러가 없는지도 같이 확인)
4. test2로 URL을 직접 조작해 세트 1의 퀘스트 화면 진입 시도 → 접근 불가(에러 또는 리다이렉트) 확인
5. admin으로 재로그인 → 세트 1이 admin 본인에게는 계속 보이는지 확인 (admin 우회)
6. 관리자 화면에서 세트 1 행을 클릭해 펼치고, test 유저 체크박스를 체크 → 접근 유저 수가 1로 바뀌는지 확인
7. test로 로그인 → "트레이닝 세트" 목록에 세트 1이 노출되고 퀘스트 진입까지 되는지 확인
8. 같은 상태에서 test2로 로그인 → 여전히 세트 1이 안 보이는지 확인 (동시 비교 — 이번에 계정을 2개로 늘린 이유)
9. 관리자 화면에서 test 체크박스를 다시 해제 → test로 재로그인해 세트 1이 다시 안 보이는지 확인
10. 할당 해제 후에도 "내 진행현황"/"랭킹" 화면에 test의 기존 이력이 그대로 남아있는지 확인 (세트 1을 한 번이라도 진행해본 뒤 비교 — 쿼리 변경 없음이므로 회귀만 확인하면 충분)
11. 관리자 화면에서 test를 다시 체크 → 세트 1을 공개로 전환했다가 다시 비공개로 전환 → 접근 유저 수가 재할당 없이 1로 유지되는지 확인 (자동 복원)
12. 관리자 화면에서 admin/test/test2 3개 계정이 유저 체크박스 목록에 모두 나오는지 확인
13. test2로 로그인한 상태에서 개발자 도구로 `page` state를 `'admin'`으로 조작 시도 → 즉시 홈으로 리다이렉트되는지 확인 (백엔드 `adminMiddleware`가 실질적 경계이고 이건 UX 방어일 뿐)
