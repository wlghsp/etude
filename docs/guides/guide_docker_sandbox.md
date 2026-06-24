# Docker 샌드박스 구현 가이드

Docker-in-Docker(DinD) 환경에서 docker 명령어를 실습하는 세트 4 구현.

---

## 구조

- `docker:dind` 이미지 + `Privileged: true` 로 컨테이너 생성
- 컨테이너 시작 후 `dockerd` 기동 완료까지 대기
- 대기 완료 후 `connected` 메시지 전송 → 프론트에서 로딩 종료
- 이후 `exec`으로 `/bin/sh` shell 연결

기존 세트(linux, linux-ssh)는 `attach` 방식이지만, docker 세트는 `dockerd`가 `attach` 스트림을 점유하므로 `exec`으로 shell을 별도로 붙여야 한다.

---

## 구현 순서

### 1. terminal.ts — waitForDocker 함수 추가

```typescript
async function waitForDocker(container: Docker.Container): Promise<void> {
  for (let i = 0; i < 20; i++) {
    const exec = await container.exec({
      Cmd: ['docker', 'info'],
      AttachStdout: false,
      AttachStderr: false,
    })
    await exec.start({})
    const info = await exec.inspect()
    if (info.ExitCode === 0) return
    await new Promise((r) => setTimeout(r, 500))
  }
  throw new Error('dockerd startup timeout')
}
```

500ms × 20회 = 최대 10초 대기. `docker info` 성공 시 즉시 반환.

### 2. terminal.ts — runSetupCmd 헬퍼 함수 추가

`waitForDocker` 아래에 추가. `handleDefaultTerminal`과 `handleDockerTerminal` 양쪽에서 공통으로 쓴다:

```typescript
async function runSetupCmd(container: Docker.Container, questId: number | null): Promise<void> {
    if (questId === null) return
    const setupCmd = await getSetupCmd(questId)
    if (!setupCmd) return
    const exec = await container.exec({ Cmd: setupCmd, AttachStdout: false, AttachStderr: false })
    await exec.start({})
    while (true) {
        const info = await exec.inspect()
        if (!info.Running) break
        await new Promise((r) => setTimeout(r, 100))
    }
}
```

### 3. terminal.ts — handleTerminal 분기 처리

docker 타입은 컨테이너 생성/연결 방식이 달라서 분기한다. `questId`를 양쪽에 전달한다:

```typescript
export async function handleTerminal(socket: WebSocket, docker: Docker, sandboxType: SandboxType, questId: number | null) {
  const config = await getSandboxConfig(sandboxType)

  if (sandboxType === 'docker') {
    await handleDockerTerminal(socket, docker, config, questId)
  } else {
    await handleDefaultTerminal(socket, docker, config, questId)
  }
}
```

### 4. terminal.ts — handleDefaultTerminal (기존 로직)

기존 `handleTerminal` 내용을 함수로 분리. `getSandboxConfig`가 `{ image, binds }`를 반환하므로 spread 없이 직접 넣는다. `container.start()` 후 `runSetupCmd` 호출:

```typescript
async function handleDefaultTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    HostConfig: { Binds: config.binds ?? [] },
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
  await runSetupCmd(container, questId)

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    container.stop().then(() => container.remove()).catch(() => {})
  })
}
```

### 5. terminal.ts — handleDockerTerminal (DinD 전용)

`Privileged: true`는 `HostConfig`에 직접 명시. `waitForDocker` 후 `runSetupCmd` 호출:

```typescript
async function handleDockerTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    AttachStdin: false,
    AttachStdout: false,
    AttachStderr: false,
    OpenStdin: false,
    Tty: false,
    HostConfig: {
      Binds: config.binds ?? [],
      Privileged: true,
    },
  })

  await container.start()
  await waitForDocker(container)
  await runSetupCmd(container, questId)

  const exec = await container.exec({
    Cmd: ['/bin/sh'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    Tty: true,
  })
  const stream = await exec.start({ hijack: true, stdin: true })

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    container.stop().then(() => container.remove()).catch(() => {})
  })
}
```

### 5. Terminal.tsx — 로딩 상태 추가

`connected` 메시지가 오기 전까지 로딩을 보여준다:

```typescript
const [loading, setLoading] = useState(true)

// connected 수신 시
setLoading(false)

// 렌더링
return (
  <div style={{ height: '100vh', background: '#000' }}>
    {loading && (
      <div style={{ color: '#666', padding: '1rem', fontSize: '13px' }}>
        환경 준비 중...
      </div>
    )}
    <div ref={containerRef} style={{ height: '100%', padding: '4px', display: loading ? 'none' : 'block' }} />
  </div>
)
```

---

## 검증

1. DB 재초기화: `docker-compose down -v && docker-compose up -d`
2. 세트 4(Docker 기초) 선택
3. "환경 준비 중..." 로딩 후 터미널 열리는지 확인
4. `docker images` 실행 — 호스트 이미지가 아닌 빈 목록이 나와야 성공
