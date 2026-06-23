# Phase 1 구현 가이드 — 터미널 샌드박스

명세: `docs/spec_phase1_terminal.md`
상태: **완료**

---

## 목표

브라우저에서 터미널 열고 명령어 실행

---

## 1-1. 프로젝트 폴더 생성

```bash
mkdir etude && cd etude
mkdir frontend backend
```

---

## 1-2. 백엔드 초기화

```bash
cd backend
npm init -y
npm install fastify @fastify/websocket dockerode
npm install -D typescript tsx @types/node @types/dockerode @types/ws
npx tsc --init
```

> **현재 설치 버전 기준** (2025-06): fastify ^5, @fastify/websocket ^11, dockerode ^5, typescript ^6, tsx ^4

`package.json` 수정:

```json
{
  "type": "module",
  "scripts": {
    "dev": "tsx src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

> - `"type": "module"` 은 필수다. 없으면 `module: nodenext` 설정임에도 TypeScript가 파일을 CommonJS로 인식해서 `import`/`await` 전부 에러난다.
> - `ts-node --esm`은 TypeScript 6 + ESM 조합에서 `.ts` 확장자를 못 읽는 문제가 있다. `tsx`를 쓰면 별도 플래그 없이 동작한다.

`tsconfig.json` — `npx tsc --init`이 생성한 기본 파일 대신 아래로 교체:

```json
{
  "compilerOptions": {
    "target": "esnext",
    "module": "nodenext",
    "moduleResolution": "nodenext",
    "outDir": "./dist",
    "rootDir": "./src",
    "types": ["node"],
    "strict": true,
    "esModuleInterop": true,
    "sourceMap": true,
    "skipLibCheck": true
  }
}
```

`src/` 폴더 생성:

```bash
mkdir src
```

---

## 1-3. 백엔드 파일 작성

`backend/src/index.ts`:

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

> `module: nodenext` 환경에서는 로컬 파일 import 시 반드시 `.js` 확장자를 붙여야 한다. TypeScript 파일이지만 컴파일 후 `.js`가 되므로 이렇게 쓴다.

검증: `npm run dev` 실행 후

```bash
curl http://localhost:3001/
# {"message":"Route GET:/ not found"} 응답 오면 정상
```

---

`backend/src/terminal.ts`:

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

  const stream = await container.attach({
    stream: true,
    stdin: true,
    stdout: true,
    stderr: true,
    hijack: true,
  })

  await container.start()

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
    container.stop()
      .then(() => container.remove())
      .catch(() => {})
  })
}
```

> - `exec` 방식 대신 `attach` 방식을 쓴다. exec은 컨테이너 시작 직후 bash 프롬프트가 출력되지 않는 문제가 있다.
> - `attach`는 컨테이너 시작 전에 붙어야 시작 시점 출력을 받을 수 있으므로 `attach` → `start` 순서를 지킨다.

---

## 1-4. 프론트엔드 초기화

```bash
cd ../frontend
npm create vite@latest . -- --template react-ts
npm install
npm install @xterm/xterm @xterm/addon-fit
```

> - `@xterm/xterm`은 구 `xterm` 패키지의 scoped 버전이다. `xterm`으로 설치하면 안 된다.
> - Vite 초기화 시 "디렉토리가 비어있지 않다"는 경고가 뜰 수 있다. `y`로 진행하면 된다.

---

## 1-5. 프론트엔드 파일 작성

`frontend/src/main.tsx` — StrictMode 제거:

```typescript
import { createRoot } from 'react-dom/client'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <App />
)
```

> React 18 StrictMode는 개발 모드에서 useEffect를 두 번 실행한다. 이로 인해 WebSocket 연결이 두 번 맺혀 Docker 컨테이너가 2개 생성된다. MVP 단계에서는 제거한다.

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

---

## 1-6. 검증

```bash
# 터미널 1
cd backend && npm run dev

# 터미널 2
cd frontend && npm run dev
```

브라우저 `http://localhost:5173` 접속 후:
- `ls` 실행 → 결과 출력
- `pwd` 실행 → `/` 출력
- `echo hello` 실행 → `hello` 출력

탭 닫은 후 `docker ps -a`로 컨테이너 제거 확인.

**자주 겪는 문제**

| 증상 | 원인 | 해결 |
|------|------|------|
| `Cannot connect` | 백엔드 미실행 또는 포트 충돌 | `lsof -i :3001` 확인 |
| 터미널 아무것도 안 나옴 | ubuntu 이미지 없음 | `docker pull ubuntu` |
| `.ts` 확장자 에러 | `ts-node` ESM 미지원 | `tsx`로 교체 |
| WebSocket 연결 즉시 끊김 | Docker 데몬 미실행 | `docker ps` 확인 |
| Colima 사용 시 소켓 에러 | 소켓 경로 불일치 | `ln -sf ~/.colima/default/docker.sock ~/.docker/run/docker.sock` |

---

## 참고 — 실제 설치 버전 (2025-06 기준)

```
fastify: ^5.8.5
@fastify/websocket: ^11.2.0
dockerode: ^5.0.0
typescript: ^6.0.3
tsx: ^4.22.4
@types/ws: ^8.18.1
@types/node: ^26.0.0
@types/dockerode: ^4.0.1
```
