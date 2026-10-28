# Persistent Sandbox 구현 가이드

퀘스트를 넘겨도 동일 컨테이너를 유지하는 `persistent` sandbox 지원.
Docker 이미지 오프라인 반입처럼 상태가 이어져야 하는 실습 세트에 사용.

## 변경 범위

| 레이어 | 파일 | 상태 |
|--------|------|------|
| DB | `init.sql` | ✅ 완료 |
| 프론트 | `api.ts` | ✅ 완료 |
| 프론트 | `App.tsx` | ✅ 완료 |
| 프론트 | `Terminal.tsx` | 구현 필요 |
| 백엔드 | `sandbox.ts` | 구현 필요 |
| 백엔드 | `terminal.ts` | 구현 필요 |
| 백엔드 | `index.ts` | 구현 필요 |

---

## 1. DB — `init.sql` ✅

- `sandbox` 테이블에 `persistent BOOLEAN NOT NULL DEFAULT FALSE` 컬럼 추가
- `docker-persistent` sandbox type 추가 (`persistent = TRUE`)

---

## 2. 프론트 — `api.ts` ✅

`endSession` 함수 추가:

```ts
export async function endSession(containerId: string) {
  return fetch(`${BASE}/session/end`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ containerId }),
  }).then((r) => r.json())
}
```

---

## 3. 프론트 — `App.tsx` ✅

변경 내용 두 가지:

**① Terminal key — persistent일 때 세트 단위로 고정**

```tsx
key={sandboxType === 'docker-persistent' ? `set-${selectedSetId}` : sandboxType === 'k8s' ? 'k8s' : questIndex}
```

- `docker-persistent`: `set-{setId}` 고정 → 퀘스트 이동 시 Terminal 재마운트 안 함 → 컨테이너 유지
- `k8s`: 기존과 동일
- 그 외: 기존과 동일 (`questIndex` 변경 시 재마운트)

**② 세트 전환 시 persistent 컨테이너 정리**

`selectedSetId` effect의 cleanup에서 `/session/end` 호출.
cleanup은 세트가 바뀌거나 컴포넌트가 언마운트될 때 실행된다.
effect 클로저에서 최신 state를 읽기 위해 ref 사용:

```tsx
const containerIdRef = useRef(containerId)
const sandboxTypeRef = useRef(sandboxType)

useEffect(() => { containerIdRef.current = containerId }, [containerId])
useEffect(() => { sandboxTypeRef.current = sandboxType }, [sandboxType])

useEffect(() => {
  if (selectedSetId === null) return
  fetchQuests(selectedSetId).then(...)
  return () => {
    if (containerIdRef.current && sandboxTypeRef.current === 'docker-persistent') {
      endSession(containerIdRef.current).catch(() => {})
    }
  }
}, [selectedSetId])
```

---

## 4. 프론트 — `Terminal.tsx`

**Props에 `containerId` 추가:**

```tsx
interface Props {
  sandboxType: string
  questId: number | null
  containerId: string | null  // 추가
  onConnected: (containerId: string) => void
}
```

**WS URL 생성 부분 수정** (`useEffect` 구조는 그대로):

```tsx
// 기존
const ws = new WebSocket(
  `ws://${window.location.hostname}:3001/ws/terminal?sandboxType=${sandboxType}${questId !== null ? `&questId=${questId}` : ''}`
)

// 변경
const params = new URLSearchParams({ sandboxType })
if (questId !== null) params.set('questId', String(questId))
if (containerId) params.set('containerId', containerId)
const ws = new WebSocket(`ws://${window.location.hostname}:3001/ws/terminal?${params}`)
```

---

## 5. 백엔드 — `sandbox.ts`

`persistent` 컬럼 SELECT 추가 및 반환:

```ts
'SELECT image, binds, persistent FROM sandbox WHERE type = ?'  // persistent 추가

const config = {
  image: row.image,
  binds: typeof row.binds === 'string' ? JSON.parse(row.binds) : row.binds,
  persistent: row.persistent === 1,  // 추가
}
```

---

## 6. 백엔드 — `index.ts`

**① WS 핸들러에서 `containerId` 파라미터 파싱 및 전달:**

```ts
app.get('/ws/terminal', { websocket: true }, (socket, req) => {
  const params = new URL(req.url, 'http://localhost').searchParams
  const sandboxType = params.get('sandboxType') ?? 'linux'
  const questId = params.get('questId') ? Number(params.get('questId')) : null
  const containerId = params.get('containerId') ?? null  // 추가

  handleTerminal(socket, docker, sandboxType, questId, containerId).catch(...)
})
```

**② `/session/end` 엔드포인트 추가:**

```ts
fastify.post<{ Body: { containerId: string } }>(
  '/session/end',
  async (req) => {
    const { containerId } = req.body
    const container = docker.getContainer(containerId)
    await container.stop().catch(() => {})
    await container.remove().catch(() => {})
    return { ok: true }
  }
)
```

---

## 7. 백엔드 — `terminal.ts`

**① `handleTerminal` 시그니처에 `existingContainerId` 추가 및 분기:**

`docker`와 `docker-persistent` 둘 다 `handleDockerTerminal`로 보내고, `existingContainerId`를 전달한다.

```ts
export async function handleTerminal(
  socket: WebSocket,
  docker: Docker,
  sandboxType: string,
  questId: number | null,
  existingContainerId: string | null,  // 추가
) {
  const config = await getSandboxConfig(sandboxType)

  if (sandboxType === 'docker' || sandboxType === 'docker-persistent') {
    await handleDockerTerminal(socket, docker, config, questId, existingContainerId)  // existingContainerId 전달
  } else if (sandboxType === 'k8s') {
    await handleK8sTerminal(socket, docker, config, questId)
  } else {
    await handleDefaultTerminal(socket, docker, config, questId)
  }
}
```

**② `handleDockerTerminal` 전체 변경:**

```ts
async function handleDockerTerminal(
  socket: WebSocket,
  docker: Docker,
  config: { image: string; binds: string[] | null; persistent: boolean },
  questId: number | null,
  existingContainerId: string | null,
) {
  let container: Docker.Container

  if (existingContainerId) {
    // persistent: 기존 컨테이너에 재연결
    container = docker.getContainer(existingContainerId)
  } else {
    // 신규 컨테이너 생성 (기존 코드 그대로)
    container = await docker.createContainer({
      Image: config.image,
      HostConfig: { Binds: config.binds ?? [], Privileged: true },
      AttachStdin: false, AttachStdout: false, AttachStderr: false,
      OpenStdin: false, Tty: false,
    })
    await container.start()
    await waitForDocker(container)
    await runSetupCmd(container, questId)
  }

  const exec = await container.exec({
    Cmd: ['/bin/sh'],
    AttachStdin: true, AttachStdout: true, AttachStderr: true, Tty: true,
  })
  const stream = await exec.start({ hijack: true, stdin: true, Tty: true })

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    // persistent면 컨테이너 유지 (/session/end에서 명시적으로 정리)
    if (!config.persistent) {
      container.stop().then(() => container.remove()).catch(() => {})
    }
  })
}
```

---

## 동작 흐름

```
[퀘스트 1 진입]
  Terminal 마운트 (key = "set-7")
  → WS 연결 (containerId 파라미터 없음)
  → 백엔드: 새 컨테이너 생성
  → onConnected(containerId) → App state 저장

[퀘스트 2로 이동]
  Terminal key 동일 ("set-7") → 재마운트 없음 → WS 유지
  → QuestPanel만 교체
  → 채점은 같은 containerId로 → 이전 퀘스트 결과 그대로 사용 ✅

[세트 종료 or 다른 세트 선택]
  selectedSetId effect cleanup 실행
  → endSession(containerId) → 백엔드: stop + remove
```

---

## 주의사항

- persistent 세트의 퀘스트는 `setup_cmd` 없이 설계 (Terminal 재마운트가 없으므로 실행 타이밍이 없음)
- 브라우저를 그냥 닫으면 `/session/end`가 호출 안 됨 → 미사용 컨테이너 GC는 MVP 이후 과제
