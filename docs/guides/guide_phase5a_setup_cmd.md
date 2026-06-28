# 퀘스트 setup_cmd 구현 가이드

퀘스트 시작 전 컨테이너에 사전 환경을 구성하는 `setup_cmd` 기능 구현.

---

## 흐름

퀘스트 이동 시 `Terminal`이 remount → WebSocket 재연결(`?questId=N`) → 새 컨테이너 생성 → `setup_cmd` exec → 터미널 열림

`key={questIndex}`로 이미 퀘스트 이동마다 `Terminal`이 remount되므로 프론트 변경은 WebSocket URL에 `questId` 추가뿐이다.

---

## 구현 순서

### 1. types.ts — Quest에 setup_cmd 추가

```typescript
// frontend/src/types.ts
export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
  setup_cmd: string[] | null
}
```

백엔드 `backend/src/types.ts`도 동일하게 추가:

```typescript
export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
  setup_cmd: string[] | null
}
```

### 2. quest.ts — getQuests 쿼리에 setup_cmd 추가

```typescript
export async function getQuests(questSetId: number): Promise<Quest[]> {
  const [rows] = await db.query(
    'SELECT id, title, description, hint, solution, setup_cmd FROM quest WHERE quest_set_id = ? ORDER BY order_index',
    [questSetId]
  )
  return (rows as any[]).map((r) => ({
    ...r,
    setup_cmd: r.setup_cmd ? JSON.parse(r.setup_cmd) : null,
  })) as Quest[]
}
```

mysql2는 MariaDB JSON 컬럼을 항상 문자열로 반환한다. `binds`에서 같은 이유로 `JSON.parse`를 했던 것과 동일하다.

### 3. quest.ts — getSetupCmd 함수 추가

`terminal.ts`에서 questId로 setup_cmd를 조회할 수 있도록 별도 함수 추가:

```typescript
export async function getSetupCmd(questId: number): Promise<string[] | null> {
  const [rows] = await db.query<any[]>(
    'SELECT setup_cmd FROM quest WHERE id = ?',
    [questId]
  )
  if (!rows.length || !rows[0].setup_cmd) return null
  const raw = rows[0].setup_cmd
  return typeof raw === 'string' ? JSON.parse(raw) : raw
}
```

### 4. terminal.ts — questId 파라미터 추가 + setup_cmd exec

```typescript
import { getSetupCmd } from './quest.js'

export async function handleTerminal(socket: WebSocket, docker: Docker, sandboxType: SandboxType, questId: number | null) {
  const { image, binds } = await getSandboxConfig(sandboxType)
  const container = await docker.createContainer({
    Image: image,
    HostConfig: { Binds: binds ?? [] },
    Cmd: sandboxType === 'docker' ? ['/bin/sh'] : ['/bin/bash'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    OpenStdin: true,
    Tty: true,
  })

  const stream = await container.attach({ stream: true, stdin: true, stdout: true, stderr: true, hijack: true })
  await container.start()

  // setup_cmd 실행
  if (questId !== null) {
    const setupCmd = await getSetupCmd(questId)
    if (setupCmd) {
      const exec = await container.exec({ Cmd: setupCmd, AttachStdout: false, AttachStderr: false })
      await exec.start({})
      while (true) {
        const info = await exec.inspect()
        if (!info.Running) break
        await new Promise((r) => setTimeout(r, 100))
      }
    }
  }

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    container.stop().then(() => container.remove()).catch(() => {})
  })
}
```

### 5. index.ts — WebSocket에서 questId 파싱

```typescript
app.get('/ws/terminal', { websocket: true }, (socket, req) => {
  const params = new URL(req.url, 'http://localhost').searchParams
  const sandboxType = params.get('sandboxType') ?? 'linux'
  const questId = params.get('questId') ? Number(params.get('questId')) : null
  handleTerminal(socket, docker, sandboxType as SandboxType, questId).catch((err) => {
    console.error('terminal error:', err)
    socket.close()
  })
})
```

### 6. Terminal.tsx — WebSocket URL에 questId 추가

`Terminal`이 `questId` prop을 받아 WebSocket URL에 포함:

```typescript
interface Props {
  sandboxType: string
  questId: number | null
  onConnected: (id: string) => void
}

export function Terminal({ sandboxType, questId, onConnected }: Props) {
  // ...
  const ws = new WebSocket(
    `ws://localhost:3001/ws/terminal?sandboxType=${sandboxType}${questId !== null ? `&questId=${questId}` : ''}`
  )
}
```

### 7. App.tsx — Terminal에 questId 전달

```typescript
const quest = quests[questIndex] ?? null

<Terminal key={questIndex} sandboxType={sandboxType} questId={quest?.id ?? null} onConnected={setContainerId} />
```

---

## 검증

1. DB 재초기화: `docker-compose down -v && docker-compose up -d`
2. 세트 3 → 5번 퀘스트(SSH로 원격 파일 복사하기) 선택
3. 터미널에서 `ls /tmp/index.html` — 파일이 미리 준비되어 있으면 성공
