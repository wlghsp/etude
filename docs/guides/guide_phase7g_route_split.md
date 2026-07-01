# Phase 7g 구현 가이드 — 라우트 분리

명세: 별도 명세 없음 — `index.ts`에 라우트가 모두 나열되며 늘어난 데 대한 구조 리팩터링.

이 문서를 보고 `backend/src/index.ts`의 라우트 등록을 도메인별 파일로 분리합니다.

---

## 배경

`index.ts`는 CLAUDE.md 레이어 원칙상 "요청 파싱/응답만" 담당하는 라우터 레이어다.
서비스 로직(`auth.ts`, `quest.ts`, `user.ts`, `terminal.ts`)은 이미 함수 단위로 분리되어 있으나,
파일이 `backend/src/` 루트에 라우터 파일과 섞여 있고, 라우트 *등록*도 `index.ts` 한 파일에
순서 없이 나열되어 있어 계속 길어지는 문제가 있다.

이번 리팩터링은 로직 변경 없이 라우트 등록만 도메인별 파일로 옮긴다. 동작은 이전과 동일해야 한다.
곁들여 서비스 파일도 `services/`로 모아 `routes/`와 대칭 구조를 맞춘다 — 단순 이동이라 리스크가 낮다.

---

## 구현 순서

```
0. services/ — auth.ts, quest.ts, user.ts, sandbox.ts, terminal.ts 이동 → import 오류 없음 확인
1. plugins/docker.ts — docker 인스턴스 + cleanup 로직 분리   → import 오류 없음 확인
2. plugins/auth-guard.ts — authMiddleware, adminMiddleware 분리 → import 오류 없음 확인
3. routes/*.routes.ts — 도메인별 라우트 파일 6개 작성          → tsc 오류 없음 확인
4. index.ts — 라우트 등록을 register 호출로 교체              → curl로 기존 API 전부 확인
```

최종 디렉터리 구조:

```
backend/src/
  db.ts
  types.ts
  index.ts
  services/
    auth.ts
    quest.ts
    user.ts
    sandbox.ts
    terminal.ts
  plugins/
    docker.ts
    auth-guard.ts
  routes/
    auth.routes.ts
    user.routes.ts
    admin.routes.ts
    quest.routes.ts
    session.routes.ts
    terminal.routes.ts
```

`db.ts`(DB 연결 설정), `types.ts`(타입 정의), `index.ts`(엔트리포인트)는 서비스가 아니므로 루트에 남긴다.

---

## Step 0. services/ — 서비스 파일 이동

`git mv`로 이동 (히스토리 보존):

```bash
cd backend/src
mkdir services
git mv auth.ts quest.ts user.ts sandbox.ts terminal.ts services/
```

파일 내용은 바꾸지 않는다. 다만 서비스 파일끼리의 상대 import가 그대로 유효한지 확인한다 —
같은 디렉터리로 함께 이동하므로 `./db.js`만 `../db.js`로 바뀐다.

```typescript
// services/auth.ts, services/quest.ts, services/user.ts, services/sandbox.ts
import { db } from '../db.js'   // ./db.js → ../db.js
```

`services/terminal.ts`는 같은 디렉터리 내 참조(`./sandbox.js`, `./quest.js`)라 그대로 둔다:

```typescript
// services/terminal.ts — 변경 없음
import { getSandboxConfig } from './sandbox.js'
import { getSetupCmd } from './quest.js'
```

---

## Step 1. plugins/docker.ts — docker 인스턴스 공유

`backend/src/plugins/docker.ts` 신규 작성:

```typescript
import Docker from 'dockerode'

export const docker = new Docker()

export async function cleanupOrphanContainers() {
    const containers = await docker.listContainers({
        all: true,
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
    }
}

export async function cleanupRunningContainers() {
    const containers = await docker.listContainers({
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
    }
}
```

> `cleanupOrphanContainers`(시작 시, `all: true`)와 `cleanupRunningContainers`(종료 시, running만)는
> 기존 `index.ts`에 두 곳에서 거의 같은 코드로 중복되어 있던 것 — 옮기는 김에 이름만 구분해 분리한다.

---

## Step 2. plugins/auth-guard.ts — 인증 미들웨어 공유

`backend/src/plugins/auth-guard.ts` 신규 작성:

```typescript
import { verifyToken } from '../services/auth.js'

export async function authMiddleware(request: any, reply: any) {
    const auth = request.headers['authorization'] ?? ''
    const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
    if (!token) return reply.code(401).send({ error: '인증이 필요합니다.' })
    try {
        request.user = verifyToken(token)
    } catch {
        return reply.code(401).send({ error: '토큰이 유효하지 않습니다.' })
    }
}

export async function adminMiddleware(request: any, reply: any) {
    await authMiddleware(request, reply)
    if (request.user?.role !== 'admin') {
        return reply.code(403).send({ error: '관리자 권한이 필요합니다.' })
    }
}
```

---

## Step 3. routes/*.routes.ts — 도메인별 라우트 파일

각 파일은 `FastifyPluginAsync`로 작성한다. `backend/src/routes/` 디렉터리 신규 생성.

파일명은 `{domain}.routes.ts` 접미사로 통일한다 — 같은 도메인의 서비스 파일(`auth.ts`, `quest.ts`, `user.ts`)과
이름이 겹치면 탭/검색에서 구분하기 번거롭기 때문이다.

### routes/auth.routes.ts

```typescript
import { FastifyPluginAsync } from 'fastify'
import { login } from '../services/auth.js'
import { authMiddleware } from '../plugins/auth-guard.js'

export const authRoutes: FastifyPluginAsync = async (app) => {
    app.post('/auth/login', async (request, reply) => {
        const { email, password } = request.body as { email: string; password: string }
        try {
            return await login(email, password)
        } catch (e: any) {
            return reply.code(401).send({ error: e.message })
        }
    })

    app.get('/me', { preHandler: authMiddleware }, async (request: any) => {
        return request.user
    })
}
```

### routes/user.routes.ts

```typescript
import { FastifyPluginAsync } from 'fastify'
import { getLeaderboard, getProgress } from '../services/user.js'
import { authMiddleware } from '../plugins/auth-guard.js'

export const userRoutes: FastifyPluginAsync = async (app) => {
    app.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
        return getProgress(request.user.userId)
    })

    app.get('/leaderboard', { preHandler: authMiddleware }, async () => {
        return getLeaderboard()
    })
}
```

### routes/admin.routes.ts

```typescript
import { FastifyPluginAsync } from 'fastify'
import { createUser, resetPassword } from '../services/user.js'
import { adminMiddleware } from '../plugins/auth-guard.js'

export const adminRoutes: FastifyPluginAsync = async (app) => {
    app.post('/admin/users', { preHandler: adminMiddleware }, async (request) => {
        const { name, email, password } = request.body as { name: string; email: string; password: string }
        return createUser(name, email, password)
    })

    app.patch('/admin/users/:id/password', { preHandler: adminMiddleware }, async (request) => {
        const { id } = request.params as { id: string }
        const { password } = request.body as { password: string }
        await resetPassword(id, password)
        return { ok: true }
    })
}
```

> 기존 코드에 버그 있음 — `password`를 `request.params`에서 읽고 있어 항상 undefined다.
> 분리하면서 `request.body`로 고친다 (원래 의도대로).

### routes/quest.routes.ts

```typescript
import { FastifyPluginAsync } from 'fastify'
import { gradeQuest, getQuests, getQuestSets } from '../services/quest.js'
import { recordAttempt } from '../services/user.js'
import { verifyToken } from '../services/auth.js'
import { docker } from '../plugins/docker.js'

export const questRoutes: FastifyPluginAsync = async (app) => {
    app.get('/quest-sets', async () => getQuestSets())

    app.get<{ Params: { id: string } }>('/quest-sets/:id/quests', async (req) => {
        return getQuests(Number(req.params.id))
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
    })
}
```

### routes/session.routes.ts

```typescript
import { FastifyPluginAsync } from 'fastify'
import { docker } from '../plugins/docker.js'

export const sessionRoutes: FastifyPluginAsync = async (app) => {
    app.post<{ Body: { containerId: string } }>('/session/end', async (req) => {
        const { containerId } = req.body
        const container = docker.getContainer(containerId)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
        return { ok: true }
    })
}
```

### routes/terminal.routes.ts (WebSocket 라우트)

```typescript
// routes/terminal.routes.ts
import { FastifyPluginAsync } from 'fastify'
import { handleTerminal } from '../services/terminal.js'
import { docker } from '../plugins/docker.js'

export const terminalRoutes: FastifyPluginAsync = async (app) => {
    app.get('/ws/terminal', { websocket: true }, (socket, req) => {
        const params = new URL(req.url, 'http://localhost').searchParams
        const sandboxType = params.get('sandboxType') ?? 'linux'
        const questId = params.get('questId') ? Number(params.get('questId')) : null
        const containerId = params.get('containerId') ?? null
        handleTerminal(socket, docker, sandboxType, questId, containerId).catch((err) => {
            console.error('terminal error:', err)
            socket.close()
        })
    })
}
```

---

## Step 4. index.ts — register 호출로 교체

`index.ts`를 아래 형태로 교체한다:

```typescript
import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import 'dotenv/config'
import { cleanupOrphanContainers, cleanupRunningContainers, docker } from './plugins/docker.js'
import { authRoutes } from './routes/auth.routes.js'
import { userRoutes } from './routes/user.routes.js'
import { adminRoutes } from './routes/admin.routes.js'
import { questRoutes } from './routes/quest.routes.js'
import { sessionRoutes } from './routes/session.routes.js'
import { terminalRoutes } from './routes/terminal.routes.js'

const fastify = Fastify({ logger: true })

await cleanupOrphanContainers()

await fastify.register(cors, { origin: true })
await fastify.register(websocket)

await fastify.register(terminalRoutes)
await fastify.register(authRoutes)
await fastify.register(userRoutes)
await fastify.register(adminRoutes)
await fastify.register(questRoutes)
await fastify.register(sessionRoutes)

fastify.addHook('onClose', async () => {
    await cleanupRunningContainers()
})

const shutdown = async () => {
    await fastify.close()
    process.exit()
}
process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

await fastify.listen({ port: 3001, host: '0.0.0.0' })
```

`docker` import는 더 이상 `index.ts`에서 직접 쓰이지 않으면 지운다 — 각 라우트 파일이 `plugins/docker.js`에서 개별적으로 import한다.

---

## Step 5. feedback 라우트는 새 구조에 맞춰 추가

`guide_phase7f_feedback.md`의 `POST /feedback`, `GET /admin/feedback`은
이 리팩터링 이후에 각각 `routes/feedback.routes.ts`(신규), `routes/admin.routes.ts`(기존 파일에 라우트 추가)로 넣는다.
`index.ts`에 직접 추가하지 않는다.

---

## 검증

```bash
cd backend && git status   # services/ 이동이 rename으로 인식되는지 확인
npx tsc --noEmit           # 타입 오류 없음

npm run dev

# 기존 API 전부 동일하게 동작하는지 확인
curl http://localhost:3001/quest-sets
curl -X POST http://localhost:3001/auth/login -H "Content-Type: application/json" \
  -d '{"email":"test@okestro.com","password":"password123"}'
curl http://localhost:3001/me -H "Authorization: Bearer <토큰>"
curl http://localhost:3001/progress -H "Authorization: Bearer <토큰>"
curl http://localhost:3001/leaderboard -H "Authorization: Bearer <토큰>"

# 터미널 WebSocket 연결 — 브라우저에서 퀘스트 진입해 정상 연결 확인
# 컨테이너 정리 — 서버 종료(Ctrl+C) 후 docker ps -a로 etude=sandbox 컨테이너 안 남았는지 확인
```
