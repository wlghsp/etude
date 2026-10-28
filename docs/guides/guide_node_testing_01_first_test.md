# Node 백엔드 테스트 기반 Step 1 — 첫 테스트와 `buildApp()`

Node 백엔드(`backend/`)에는 자동 테스트가 없다. 이 Step에서는 **테스트가 한 개 돌아가는 최소 기반**을 만든다.
테스트를 처음 써 보는 사람을 기준으로, 개념 → 실패하는 테스트 → 통과시키기 순서로 진행한다.

> 이 문서의 6단계를 보고 `backend/`에 Vitest 테스트 1개와 `buildApp()`을 구현합니다.

## 목표와 완료 기준

`GET /progress`를 **토큰 없이** 호출하면 `401`이 나오는 것을, 서버를 실제로 띄우지 않고 DB·Docker 없이 자동으로 검증한다.

- [ ] `npm test`가 통과한다
- [ ] DB와 Docker가 꺼져 있어도 통과한다
- [ ] `npm run build`(tsc)가 여전히 통과하고, `dist/`에 테스트 파일이 생기지 않는다
- [ ] `npm run dev`로 서버가 예전처럼 뜬다 (기능 변화 없음)
- [ ] 테스트를 **먼저** 쓰고 실패(RED)하는 것을 눈으로 확인했다

## 준비가 끝난 것

Vitest 3.2.7이 `backend/`에 설치돼 있다. (최신 vitest 5는 Node 22 이상이 필요한데 이 프로젝트는 Node 20이라, 3 버전을 쓴다. Node를 22로 올릴 때 같이 올린다.)

## 개념 4가지

### 1. 테스트는 이런 모양이다

```ts
import { describe, it, expect } from 'vitest'

describe('묶음 이름', () => {
    it('이럴 때 이렇게 동작한다', () => {
        expect(1 + 1).toBe(2)   // 실제 값 vs 기대값
    })
})
```

`expect(실제값).toBe(기대값)`이 맞으면 통과, 틀리면 실패한다. 나머지는 이 모양의 반복이다.

### 2. `inject()` — 포트 없이 요청 보내기

Fastify에는 서버를 `listen`하지 않고도 요청을 흘려 넣는 `app.inject()`가 있다. 네트워크도 포트도 쓰지 않아
빠르고, 포트 충돌이 없다. 라우터·미들웨어·응답 코드까지 **실제 코드가 그대로** 실행된다.

```ts
const res = await app.inject({ method: 'GET', url: '/progress' })
res.statusCode   // 401
res.json()       // { error: '인증이 필요합니다.' }
```

### 3. RED → GREEN

1. 아직 없는 기능을 쓰는 테스트를 먼저 쓴다 → **실패(RED)** 확인
2. 테스트를 통과시킬 최소한의 코드를 쓴다 → **통과(GREEN)** 확인

RED를 건너뛰면 "처음부터 항상 통과하는, 아무것도 검증하지 않는 테스트"를 만들 위험이 있다.
실패하는 것을 한 번 봐야 이 테스트가 정말 무언가를 지키고 있다는 증거가 된다.

### 4. 왜 `buildApp()`이 필요한가

지금 `src/index.ts`는 **import하는 순간** 다음을 한다: Docker 고아 컨테이너 정리, k8s namespace 정리,
vcluster 풀 생성, 3001 포트 `listen`. 테스트에서 이 파일을 import하면 테스트가 서버 기동과 인프라 정리를
같이 일으킨다.

그래서 **"라우트를 등록해서 앱을 만드는 일"과 "인프라를 건드리는 일(기동·정리·종료)"을 나눈다.**

| 파일 | 하는 일 |
|---|---|
| `src/app.ts` (새로 만듦) | Fastify 앱을 만들고 플러그인·라우트를 등록해서 **돌려주기만** 한다 |
| `src/index.ts` | `buildApp()`을 호출하고, 시작 정리·종료 훅·`listen`을 한다 |

테스트는 `app.ts`만 쓴다. 이 분리는 CLAUDE.md의 "`index.ts`는 요청 파싱/응답만" 원칙과도 맞는다.

> 확인된 사실: 라우트 파일들을 import하는 것만으로는 DB 연결이나 Docker 호출이 일어나지 않는다
> (`mysql2` 풀은 첫 쿼리 때 연결하고, `new Docker()`는 연결하지 않는다). 그래서 `app.ts`는 DB·Docker 없이도 만들어진다.

---

## Step 1. `npm test` 스크립트 추가

`backend/package.json`의 `scripts`에 추가한다.

```json
"scripts": {
    "dev": "tsx src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest run",
    "test:watch": "vitest"
}
```

- `npm test` — 한 번 돌리고 끝 (CI·커밋 전 확인용)
- `npm run test:watch` — 파일을 저장할 때마다 자동 재실행 (작성 중에 켜 두기)

## Step 2. 테스트 파일이 빌드에 섞이지 않게 하기

지금 `tsconfig.json`에는 `include`/`exclude`가 없어서 `src/` 아래의 모든 `.ts`를 컴파일해 `dist/`에 내보낸다.
테스트 파일이 운영 이미지(`dist/`)에 들어가지 않도록 `compilerOptions` **바깥**(마지막 `}` 앞)에 추가한다.

```json
{
  "compilerOptions": { ... },
  "exclude": ["src/**/*.test.ts"]
}
```

> `exclude`는 `compilerOptions`와 같은 단계(최상위)에 둔다. `compilerOptions` 안에 넣으면 동작하지 않는다.

## Step 3. 실패하는 테스트 쓰기 (RED)

`backend/src/app.test.ts`를 만든다. 테스트 파일은 테스트할 코드 옆에 둔다 (`*.test.ts` 이름이어야 Vitest가 찾는다).

```ts
import { afterAll, beforeAll, describe, expect, it } from 'vitest'
import type { FastifyInstance } from 'fastify'
import { buildApp } from './app.js'

describe('GET /progress', () => {
    let app: FastifyInstance

    beforeAll(async () => {
        app = await buildApp()
    })

    afterAll(async () => {
        await app.close()
    })

    it('토큰이 없으면 401을 돌려준다', async () => {
        const res = await app.inject({ method: 'GET', url: '/progress' })

        expect(res.statusCode).toBe(401)
        expect(res.json()).toEqual({ error: '인증이 필요합니다.' })
    })
})
```

짚고 갈 점:

- import 경로가 `./app.js`다. 파일은 `.ts`인데 `.js`로 쓴다 — 이 프로젝트가 ESM(`"type": "module"`, `module: nodenext`)이라 기존 코드와 같은 규칙이다. 다른 파일들의 import를 보고 맞춘다.
- `beforeAll`은 이 묶음의 테스트들이 시작하기 전에 한 번, `afterAll`은 끝난 뒤 한 번 실행된다. 앱을 케이스마다 새로 만들지 않고 공유한다.
- `afterAll`에서 `app.close()`를 빼먹으면 Fastify가 열려 있어 Vitest가 종료되지 않거나 경고를 낼 수 있다.

**실행해서 RED 확인:**

```bash
cd backend
npm test
```

`./app.js`가 없어서 `Failed to load url ./app.js` 같은 오류로 **실패해야 한다.** 이게 RED다. 통과한다면 뭔가 이상한 것이니 멈추고 확인한다.

## Step 4. `src/app.ts` 만들기 (GREEN)

`index.ts`에서 "라우트 등록" 부분만 옮겨 온다. 옮기는 대상과 남기는 대상은 다음과 같다.

| 옮긴다 → `app.ts` | 남긴다 `index.ts` |
|---|---|
| `Fastify(...)` 생성 | `import 'dotenv/config'` |
| `cors`, `websocket` 등록 | `cleanupOrphanContainers()` 등 시작 정리 |
| 7개 라우트 `register` | `initPool()` |
| | `addHook('onClose', ...)` 종료 정리 |
| | `shutdown`, SIGTERM/SIGINT |
| | `listen` |

`backend/src/app.ts`:

```ts
import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import { terminalRoutes } from './routes/terminal.routes.js'
import { authRoutes } from './routes/auth.routes.js'
import { progressRoutes } from './routes/progress.routes.js'
import { adminRoutes } from './routes/admin.routes.js'
import { questRoutes } from './routes/quest.routes.js'
import { sessionRoutes } from './routes/session.routes.js'
import { feedbackRoutes } from './routes/feedback.routes.js'

export async function buildApp(opts: { logger?: boolean } = {}) {
    const app = Fastify({ logger: opts.logger ?? false })

    await app.register(cors, { origin: true, methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'] })
    await app.register(websocket)

    await app.register(terminalRoutes)
    await app.register(authRoutes)
    await app.register(progressRoutes)
    await app.register(adminRoutes)
    await app.register(questRoutes)
    await app.register(sessionRoutes)
    await app.register(feedbackRoutes)

    return app
}
```

- 기본값 `logger: false`: 테스트 출력이 로그로 어지러워지지 않게 한다. 운영에서는 `index.ts`가 `logger: true`를 넘긴다.
- 라우트 등록 **순서는 그대로** 유지한다 (기존 동작을 바꾸지 않는 이동이다).
- `dotenv/config`는 `app.ts`에 넣지 않는다. 환경변수 로드는 서버를 띄우는 쪽(`index.ts`)의 일이다. 테스트는 `JWT_SECRET` 등이 없으면 코드 안의 기본값(`dev-secret`)으로 동작한다.

## Step 5. `index.ts`를 `buildApp()` 사용으로 바꾸기

`index.ts`의 `Fastify` 생성과 `cors`/`websocket`/라우트 7개 `register` 부분을 `buildApp` 호출 한 줄로 바꾼다.
시작 정리·종료 훅·`listen`은 그대로 둔다. 바뀐 뒤 모양은 이렇다.

```ts
import 'dotenv/config'
import { buildApp } from './app.js'
import { cleanupOrphanContainers, cleanupRunningContainers } from './plugins/docker.js'
import { cleanupOrphanVclusters, initPool } from './services/vcluster-pool.js'
import { cleanupOrphanQuestNamespaces } from './plugins/k8s-namespace.js'

const fastify = await buildApp({ logger: true })

await cleanupOrphanContainers()
await cleanupOrphanQuestNamespaces()
await initPool()

fastify.addHook('onClose', async () => {
    await cleanupRunningContainers()
    await cleanupOrphanVclusters() // pool + 배정 중이던 vcluster 모두 정리
})

const shutdown = async () => {
    await fastify.close()
    process.exit()
}
process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

await fastify.listen({ port: 3001, host: '0.0.0.0' })
```

> 순서 주의: 원래는 정리(`cleanup*`, `initPool`)가 **먼저** 실행되고 그다음 라우트가 등록됐다.
> 위 모양은 앱을 먼저 만들고(등록만, 외부 호출 없음) 정리를 하므로 결과는 같다.
> 단, 정리 → `listen` 순서는 지켜야 한다. 정리가 끝나기 전에 요청을 받으면 안 된다.

## Step 6. 확인

```bash
cd backend
npm test            # GREEN: 1 passed
npm run build       # tsc 통과
ls dist | grep test # 아무것도 안 나와야 한다 (테스트가 dist에 없음)
```

그리고 서버가 예전처럼 뜨는지 확인한다.

```bash
scripts/dev-up.sh --no-k8s   # DB만
cd backend && npm run dev    # "Server listening at ..." 가 보이면 정상
```

마지막으로 **DB와 Docker가 꺼진 상태**에서도 `npm test`가 통과하는지 본다. 이 테스트의 가치는
"인프라 없이 돌아간다"는 점이다.

---

## 직접 해 볼 확장 (선택)

같은 `describe` 안에 케이스를 더 추가해 본다. 패턴은 같다 — 요청을 보내고, 상태 코드와 본문을 확인한다.

1. 잘못된 토큰이면 401: `headers: { authorization: 'Bearer garbage' }` → `{ error: '토큰이 유효하지 않습니다.' }`
2. `GET /me` 토큰 없이 → 401
3. 유효한 토큰이면 통과: `jsonwebtoken`으로 직접 서명한 토큰을 `Authorization` 헤더에 넣고 `GET /me`가 사용자 정보를 돌려주는지.
   서명 키는 `process.env.JWT_SECRET ?? 'dev-secret'` — `src/services/auth.ts`와 같은 값을 쓴다.
   (`/progress`는 DB를 쓰므로 이 단계에서는 `/me`로 확인한다. DB가 필요한 테스트는 다음 Step에서 다룬다.)

## 자주 막히는 곳

| 증상 | 원인 |
|---|---|
| `Failed to load url ./app.js` (Step 3 직후) | 정상. `app.ts`를 아직 안 만든 상태 = RED |
| `Cannot find module './app.js'` (Step 4 후에도) | `app.ts` 위치가 `src/`가 아니다 |
| 테스트가 끝났는데 프로세스가 안 끝남 | `afterAll`에서 `app.close()` 누락 |
| `npm run build`에서 `app.test.ts` 오류 | `tsconfig.json`의 `exclude`가 `compilerOptions` 안에 들어갔거나 오타 |
| 서버가 뜨는데 CORS/WebSocket이 안 됨 | `buildApp`에서 등록 순서가 바뀌었거나 `websocket` 등록 누락 |

## 다음 Step 예고

- Step 2: DB가 필요한 API(로그인·진행률)를 Testcontainers MariaDB로 테스트
- Step 3: Docker가 필요한 터미널·채점을 스모크 테스트로 (Kotlin 쪽에서 검증한 시나리오 이식: 채점 성공/실패/없는 퀘스트, 토큰 없음/무효)
