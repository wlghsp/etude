# Etude 개발 가이드

개발 계획: etude_dev_plan.md

---

## 시작 전 환경 확인

```bash
node --version    # v18 이상
docker --version  # Docker 실행 중인지 확인
```

---

## Phase 1 — 터미널 샌드박스 단독 작동

목표: 브라우저에서 터미널 열고 명령어 실행

### 1-1. 프로젝트 폴더 생성

```bash
mkdir etude && cd etude
mkdir frontend backend
```

### 1-2. 백엔드 초기화

```bash
cd backend
npm init -y
npm install fastify @fastify/websocket dockerode
npm install -D typescript ts-node @types/node @types/dockerode
npx tsc --init
```

> **현재 설치 버전 기준** (2025-06): fastify ^5, @fastify/websocket ^11, dockerode ^5, typescript ^6, ts-node ^10

tsconfig.json — `npx tsc --init`이 생성한 기본 파일 대신 아래로 교체한다.
`module: nodenext`는 Node.js ESM을 완전히 지원하며 `commonjs`보다 권장된다:

```json
{
  "compilerOptions": {
    "target": "esnext",
    "module": "nodenext",
    "moduleResolution": "nodenext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "sourceMap": true,
    "skipLibCheck": true
  }
}
```

> `rootDir`/`outDir` 주석 처리하지 말 것. `ts-node`로 실행할 때도 경로 기준이 된다.

package.json scripts 추가:

```json
"scripts": {
  "dev": "ts-node --esm src/index.ts",
  "build": "tsc",
  "start": "node dist/index.js"
}
```

> `ts-node`에 `--esm` 플래그가 필요하다. `module: nodenext` 설정 시 없으면 import 구문에서 오류 발생.

`src/` 폴더 생성:

```bash
mkdir src
```

### 1-3. 백엔드 파일 작성

`backend/src/index.ts` — Fastify 앱 진입점:

```typescript
import Fastify from 'fastify'
import websocket from '@fastify/websocket'

const fastify = Fastify({ logger: true })
await fastify.register(websocket)

await fastify.register(async function (app) {
  app.get('/ws/terminal', { websocket: true }, (socket, _req) => {
    // terminal.ts에서 로직 분리 예정
    socket.on('message', (msg) => {
      socket.send(`echo: ${msg}`)
    })
  })
})

await fastify.listen({ port: 3001, host: '0.0.0.0' })
```

> - `await` 없이 `fastify.register()` 쓰면 플러그인 등록 전에 라우트가 먼저 실행되는 타이밍 버그가 생긴다.
> - `host: '0.0.0.0'` — localhost만 바인딩하면 Docker 내부에서 접근 불가. 추후 컨테이너 배포 시 필요.
> - Fastify 5부터 콜백 방식 `.listen(port, cb)` 대신 `await` 방식을 권장한다.

검증: `npm run dev` 실행 후 서버 뜨는지 확인

```bash
# 다른 터미널에서
curl http://localhost:3001/
# {"message":"Route GET:/ not found"} 같은 응답 오면 정상
```

---

`backend/src/terminal.ts` — Docker 제어 + WebSocket 연결:

```typescript
import Docker from 'dockerode'
import type { WebSocket } from 'ws'

const docker = new Docker()

export async function handleTerminal(socket: WebSocket) {
  const container = await docker.createContainer({
    Image: 'ubuntu',
    Cmd: ['/bin/bash'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    OpenStdin: true,
    Tty: true,
  })

  await container.start()

  const exec = await container.exec({
    Cmd: ['/bin/bash'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    Tty: true,
  })

  const stream = await exec.start({ hijack: true, stdin: true })

  // 컨테이너 출력 → 브라우저
  stream.on('data', (chunk: Buffer) => {
    socket.send(chunk)
  })

  // 브라우저 입력 → 컨테이너
  socket.on('message', (msg: Buffer) => {
    stream.write(msg)
  })

  // 연결 종료 시 컨테이너 제거
  socket.on('close', () => {
    container.stop().then(() => container.remove()).catch(() => {})
  })
}
```

> - `socket.on('close')` 안에서 `await` 쓰면 에러가 발생한다. Promise 체이닝으로 처리하고 오류는 무시한다 (이미 연결이 끊긴 상태이므로).
> - `ubuntu` 이미지는 최초 실행 시 pull이 필요하다. 로컬에 없으면 `docker pull ubuntu` 먼저 실행.

index.ts에서 handleTerminal 연결 (최종 형태):

```typescript
import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import { handleTerminal } from './terminal.js'

const fastify = Fastify({ logger: true })
await fastify.register(websocket)

await fastify.register(async function (app) {
  app.get('/ws/terminal', { websocket: true }, (socket, _req) => {
    handleTerminal(socket).catch((err) => {
      console.error('terminal error:', err)
      socket.close()
    })
  })
})

await fastify.listen({ port: 3001, host: '0.0.0.0' })
```

> `module: nodenext` 환경에서는 로컬 파일 import 시 반드시 `.js` 확장자를 붙여야 한다 (`./terminal.js`). TypeScript 파일이지만 컴파일 후 `.js`가 되므로 이렇게 쓴다.

### 1-4. 프론트엔드 초기화

```bash
cd ../frontend
npm create vite@latest . -- --template react-ts
npm install
npm install @xterm/xterm @xterm/addon-fit
```

> `@xterm/xterm`은 구 `xterm` 패키지의 scoped 버전이다. `xterm`으로 설치하면 안 된다.

### 1-5. 프론트엔드 파일 작성

`frontend/src/components/Terminal.tsx`:

```typescript
import { useEffect, useRef } from 'react'
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from '@xterm/addon-fit'
import '@xterm/xterm/css/xterm.css'

export function Terminal() {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const term = new XTerm({ cursorBlink: true })
    const fitAddon = new FitAddon()
    term.loadAddon(fitAddon)
    term.open(containerRef.current!)
    fitAddon.fit()

    const ws = new WebSocket('ws://localhost:3001/ws/terminal')
    ws.binaryType = 'arraybuffer'

    ws.onopen = () => {
      term.writeln('Connected.')
    }

    ws.onmessage = (e) => {
      const data = e.data instanceof ArrayBuffer
        ? new Uint8Array(e.data)
        : e.data
      term.write(data)
    }

    term.onData((data) => {
      ws.send(data)
    })

    return () => {
      ws.close()
      term.dispose()
    }
  }, [])

  return <div ref={containerRef} style={{ height: '100vh', background: '#000' }} />
}
```

`frontend/src/App.tsx`:

```typescript
import { Terminal } from './components/Terminal'

function App() {
  return <Terminal />
}

export default App
```

### 1-6. Phase 1 검증

터미널 두 개 열기:

```bash
# 터미널 1
cd backend && npm run dev

# 터미널 2
cd frontend && npm run dev
```

브라우저에서 `http://localhost:5173` 접속 후:
- `ls` 실행 → 결과 출력
- `pwd` 실행 → `/` 출력
- `echo hello` 실행 → `hello` 출력

세 개 다 되면 Phase 1 완료.

**자주 겪는 문제**

| 증상 | 원인 | 해결 |
|------|------|------|
| `Cannot connect` | 백엔드 미실행 또는 포트 충돌 | `lsof -i :3001` 확인 |
| 터미널 아무것도 안 나옴 | ubuntu 이미지 없음 | `docker pull ubuntu` |
| `import` 오류 | `--esm` 플래그 누락 | scripts에 `ts-node --esm` 확인 |
| WebSocket 연결 즉시 끊김 | Docker 데몬 미실행 | `docker ps` 확인 |

---

## Phase 2 — 퀘스트 붙이기

목표: 퀘스트 지문 + 채점

### 2-1. 백엔드 퀘스트 추가

`backend/src/quest.ts`:

```typescript
export interface Quest {
  id: string
  title: string
  description: string
  hint: string
}

export const quests: Quest[] = [
  {
    id: 'q1',
    title: '/tmp/hello 디렉토리 만들기',
    description: '/tmp 경로 안에 hello라는 이름의 디렉토리를 만드세요.',
    hint: 'mkdir 명령어를 사용하세요.',
  },
  {
    id: 'q2',
    title: '파일에 내용 쓰기',
    description: '/tmp/answer.txt 파일을 만들고 첫 줄에 "done"을 입력하세요.',
    hint: 'echo 명령어와 리다이렉션(>)을 사용하세요.',
  },
]

export async function gradeQuest(
  containerId: string,
  questId: string
): Promise<boolean> {
  const Docker = require('dockerode')
  const docker = new Docker()
  const container = docker.getContainer(containerId)

  if (questId === 'q1') {
    const exec = await container.exec({ Cmd: ['test', '-d', '/tmp/hello'] })
    const stream = await exec.start({})
    return new Promise((resolve) => {
      stream.on('end', async () => {
        const info = await exec.inspect()
        resolve(info.ExitCode === 0)
      })
    })
  }

  if (questId === 'q2') {
    const exec = await container.exec({
      Cmd: ['grep', '-q', 'done', '/tmp/answer.txt'],
    })
    const stream = await exec.start({})
    return new Promise((resolve) => {
      stream.on('end', async () => {
        const info = await exec.inspect()
        resolve(info.ExitCode === 0)
      })
    })
  }

  return false
}
```

index.ts에 퀘스트 API 추가:

```typescript
import { quests, gradeQuest } from './quest'

// 퀘스트 목록
fastify.get('/quests', async () => quests)

// 채점
fastify.post<{ Body: { containerId: string; questId: string } }>(
  '/grade',
  async (req) => {
    const { containerId, questId } = req.body
    const passed = await gradeQuest(containerId, questId)
    return { passed }
  }
)
```

terminal.ts에서 containerId를 브라우저로 전달 (연결 직후):

```typescript
// 컨테이너 시작 후
socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))
```

### 2-2. 프론트엔드 퀘스트 패널 추가

`frontend/src/components/QuestPanel.tsx`:

```typescript
interface Quest {
  id: string
  title: string
  description: string
  hint: string
}

interface Props {
  quest: Quest
  containerId: string
  onResult: (passed: boolean) => void
}

export function QuestPanel({ quest, containerId, onResult }: Props) {
  const grade = async () => {
    const res = await fetch('http://localhost:3001/grade', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ containerId, questId: quest.id }),
    })
    const data = await res.json()
    onResult(data.passed)
  }

  return (
    <div style={{ padding: '1rem' }}>
      <h2>{quest.title}</h2>
      <p>{quest.description}</p>
      <small>{quest.hint}</small>
      <br /><br />
      <button onClick={grade}>채점하기</button>
    </div>
  )
}
```

App.tsx에서 레이아웃 구성:

```typescript
import { useState, useEffect } from 'react'
import { Terminal } from './components/Terminal'
import { QuestPanel } from './components/QuestPanel'

function App() {
  const [quest, setQuest] = useState<any>(null)
  const [containerId, setContainerId] = useState('')
  const [result, setResult] = useState<boolean | null>(null)

  useEffect(() => {
    fetch('http://localhost:3001/quests')
      .then((r) => r.json())
      .then((quests) => setQuest(quests[0]))
  }, [])

  return (
    <div style={{ display: 'flex', height: '100vh' }}>
      <div style={{ width: '40%', borderRight: '1px solid #333' }}>
        {quest && (
          <QuestPanel
            quest={quest}
            containerId={containerId}
            onResult={setResult}
          />
        )}
        {result !== null && (
          <p>{result ? '✅ 성공!' : '❌ 아직이에요.'}</p>
        )}
      </div>
      <div style={{ flex: 1 }}>
        <Terminal onConnected={setContainerId} />
      </div>
    </div>
  )
}

export default App
```

Terminal.tsx에서 containerId 콜백 추가:

```typescript
interface Props {
  onConnected: (containerId: string) => void
}

export function Terminal({ onConnected }: Props) {
  // ...
  ws.onmessage = (e) => {
    try {
      const msg = JSON.parse(e.data)
      if (msg.type === 'connected') {
        onConnected(msg.containerId)
        return
      }
    } catch {}
    // 바이너리 터미널 데이터
    term.write(new Uint8Array(e.data))
  }
}
```

### 2-3. Phase 2 검증

- 브라우저 왼쪽에 퀘스트 지문이 보이는지
- 터미널에서 퀘스트 풀기 (`mkdir /tmp/hello`)
- [채점하기] 클릭 → "성공!" 표시되는지

세 가지 다 되면 Phase 2 완료.

---

## Phase 3 — 직접 써보기

목표: 실사용 중 발견되는 UX/버그 수정

체크리스트:
- 퀘스트 지문이 충분히 명확한가
- 터미널 반응 속도가 불편하지 않은가
- 채점 결과 피드백이 충분한가
- 세션 종료 시 컨테이너가 제대로 제거되는가 (`docker ps -a`로 확인)
- 브라우저 새로고침 시 컨테이너 고아(orphan) 발생하지 않는가

---

## 미결 사항 (개발하면서 결정)

- Docker 이미지: ubuntu 기본으로 시작, 필요하면 커스텀
- 컨테이너 고아 처리: 서버 재시작 시 기존 컨테이너 정리 로직 필요할 수 있음
- 바이너리/JSON 메시지 구분: WebSocket 메시지 타입 구분 로직 Phase 2에서 확인

---

## 참고 — 실제 설치 버전 (2025-06 기준)

```
fastify: ^5.8.5
@fastify/websocket: ^11.2.0
dockerode: ^5.0.0
typescript: ^6.0.3
ts-node: ^10.9.2
@types/node: ^26.0.0
@types/dockerode: ^4.0.1
```

메이저 버전이 올라가면 API가 달라질 수 있다. 특히 Fastify 4→5는 플러그인 등록 방식이 변경되었으므로 버전 확인 필수.
