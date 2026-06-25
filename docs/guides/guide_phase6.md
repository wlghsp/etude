# Phase 6 구현 가이드 — k8s 기초 실습 세트

명세: [specs/spec_phase6_k8s.md](../specs/spec_phase6_k8s.md)

---

## 전체 흐름

```
Step 1. k3d 설치 + 클러스터 기동 (로컬 환경 준비)
Step 2. Dockerfile.k8s 작성 + 이미지 빌드
Step 3. 수동 연결 테스트 (컨테이너에서 kubectl 동작 확인)
Step 4. sandbox.ts — binds 플레이스홀더 치환
Step 5. terminal.ts — k8s namespace 생성/삭제
Step 6. init.sql — sandbox + 퀘스트 세트 6 추가
Step 7. 전체 사이클 검증
```

---

## Step 1. k3d 설치 + 클러스터 기동

```bash
# kubectl 설치
brew install kubectl

# k3d 설치
brew install k3d

# 클러스터 생성
k3d cluster create etude --api-port 127.0.0.1:6443

# 확인
kubectl get nodes
# 출력 예: etude-server-0   Ready   ...
```

kubeconfig는 `~/.kube/config`에 자동 병합된다.

---

## Step 2. Dockerfile.k8s 작성

`backend/docker/Dockerfile.k8s` 파일 생성:

```dockerfile
FROM alpine:3.19

RUN apk add --no-cache curl bash && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl

WORKDIR /root
CMD ["bash"]
```

빌드:

```bash
cd backend
docker build -f docker/Dockerfile.k8s -t etude-k8s .
```

빌드 성공 확인:

```bash
docker images | grep etude-k8s
```

---

## Step 3. 수동 연결 테스트

### 문제: 컨테이너에서 k3d API server에 접근이 안 됨

kubeconfig의 server 주소는 기본적으로 `127.0.0.1:6443`으로 저장된다.
`127.0.0.1`은 "자기 자신"을 가리키는 주소라, 컨테이너 안에서 이 주소로 요청하면 컨테이너 자신에게 요청이 가고 k3d에 도달하지 못한다.

`host.docker.internal`(Docker가 제공하는 호스트 접근 주소)로 교체하면 연결은 되지만, k3d 인증서의 TLS SAN(Subject Alternative Name)에 `host.docker.internal`이 없어서 인증서 검증에 실패한다.

### 해결: k3d 내부 네트워크 사용

k3d는 클러스터 생성 시 `k3d-etude`라는 Docker 네트워크를 만들고, API server 컨테이너(`k3d-etude-server-0`)를 그 안에 띄운다.
etude-k8s 컨테이너를 같은 네트워크(`--network k3d-etude`)에 붙이면 컨테이너끼리 직접 통신이 가능하고, `k3d-etude-server-0`이라는 hostname으로 API server에 접근할 수 있다.
이 hostname은 k3d가 발급한 인증서 SAN에 포함되어 있어 TLS 검증도 통과한다.

```
etude-k8s 컨테이너 ──(k3d-etude 네트워크)──▶ k3d-etude-server-0:6443
```

### 실행

```bash
# server 주소를 k3d 내부 hostname으로 바꾼 kubeconfig 생성 (최초 1회)
kubectl config view --raw | \
  sed 's|https://127.0.0.1:6443|https://k3d-etude-server-0:6443|g' \
  > ~/.kube/config-etude
```

연결 테스트:

```bash
docker run -it --rm \
  --network k3d-etude \
  -v ~/.kube/config-etude:/root/.kube/config:ro \
  etude-k8s \
  kubectl get nodes
```

`Ready` 상태 노드가 보이면 성공.

> k3d 클러스터를 재생성하면 `config-etude` 재생성 + etude 서버 재시작이 필요하다.
> 단순 stop/start는 네트워크와 hostname이 유지되므로 재생성 불필요.

---

## Step 4. sandbox.ts — binds 플레이스홀더 치환

`backend/.env`에 추가:

```
KUBECONFIG_PATH=/Users/{본인계정}/.kube/config-etude
K3D_NETWORK=k3d-etude
```

dotenv 설치 (tsx는 `.env`를 자동으로 로드하지 않음):

```bash
npm install dotenv
```

`backend/src/index.ts` 최상단에 추가:

```typescript
import 'dotenv/config'  // 반드시 다른 import보다 먼저
```

`backend/src/sandbox.ts` — `getSandboxConfig()` 함수 return 직전에 치환 로직 추가:

```typescript
export async function getSandboxConfig(sandboxType: string) {
    const [rows] = await db.query<any[]>(
        'SELECT image, binds FROM sandbox WHERE type = ?',
        [sandboxType]
    )
    const row = rows[0] ?? { image: 'ubuntu', binds: null }
    const config = {
        image: row.image,
        binds: typeof row.binds === 'string' ? JSON.parse(row.binds) : row.binds,
    }

    // ↓ 여기 추가
    if (config.binds) {
        const kubeconfig = process.env.KUBECONFIG_PATH ?? `${process.env.HOME}/.kube/config`
        config.binds = config.binds.map((b: string) =>
            b.replace('{KUBECONFIG_HOST_PATH}', kubeconfig)
        )
    }

    return config
}
```

검증: k8s 세트 선택 시 서버 로그에서 binds가 실제 경로로 출력되는지 확인.

---

## Step 5. terminal.ts + quest.ts — k8s 분기 처리

### 5-1. terminal.ts — SandboxType 타입 제거

`sandbox.type`은 `quest_set.sandbox_type`의 FK로 이미 DB에서 검증된다.
코드에서 같은 검증을 중복으로 유지할 이유가 없으므로 타입 선언 자체를 삭제하고, 사용하는 곳에서 `string`으로 교체:

```typescript
// 삭제
export type SandboxType = 'linux' | 'linux-ssh' | 'docker'
```

`SandboxType`을 참조하는 곳을 모두 `string`으로 교체:

`backend/src/terminal.ts` — `handleTerminal()` 시그니처:
```typescript
// 수정 전
export async function handleTerminal(
    socket: WebSocket,
    docker: Docker,
    sandboxType: SandboxType,   // ← 변경
    questId: number | null
)

// 수정 후
export async function handleTerminal(
    socket: WebSocket,
    docker: Docker,
    sandboxType: string,
    questId: number | null
)
```

`backend/src/index.ts` — import 제거 + 타입 캐스팅 제거:
```typescript
// 삭제
import type { SandboxType } from './terminal.js'

// 수정 전
handleTerminal(socket, docker, sandboxType as SandboxType, questId)

// 수정 후
handleTerminal(socket, docker, sandboxType, questId)
```

### 5-2. terminal.ts — handleTerminal()에 k8s 분기 추가

`handleTerminal()` 함수의 분기에 k8s 케이스 추가:

```typescript
export async function handleTerminal(
    socket: WebSocket,
    docker: Docker,
    sandboxType: SandboxType,
    questId: number | null
) {
    const config = await getSandboxConfig(sandboxType)

    if (sandboxType == 'docker') {
        await handleDockerTerminal(socket, docker, config, questId)
    } else if (sandboxType == 'k8s') {          // ← 추가
        await handleK8sTerminal(socket, docker, config, questId)
    } else {
        await handleDefaultTerminal(socket, docker, config, questId)
    }
}
```

### 5-3. terminal.ts — handleK8sTerminal() 함수 추가

파일 끝에 새 함수 추가. k3d 네트워크에 붙이고, 컨테이너 시작 후 namespace를 생성, 종료 시 삭제한다:

```typescript
async function handleK8sTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    HostConfig: {
      Binds: config.binds ?? [],
      NetworkMode: process.env.K3D_NETWORK ?? 'k3d-etude',
    },
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

  // namespace 생성
  const ns = `quest-${container.id.slice(0, 8)}`
  const nsExec = await container.exec({
    Cmd: ['kubectl', 'create', 'namespace', ns],
    AttachStdout: false,
    AttachStderr: false,
  })
  await nsExec.start({})

  await runSetupCmd(container, questId)

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', async () => {
    // namespace 삭제 후 컨테이너 제거
    const delExec = await container.exec({
      Cmd: ['kubectl', 'delete', 'namespace', ns, '--ignore-not-found'],
      AttachStdout: false,
      AttachStderr: false,
    })
    await delExec.start({})
    container.stop().then(() => container.remove()).catch(() => {})
  })
}
```

### 5-4. quest.ts — gradeQuest()에 $NS 치환 추가

`gradeQuest()` 함수에서 cmd 실행 전에 `$NS`를 실제 namespace로 치환:

```typescript
export async function gradeQuest(
  containerId: string,
  questId: number,
  docker: Docker
): Promise<boolean> {
  const [rows] = await db.query<any[]>(
    'SELECT grade_cmd FROM quest WHERE id = ?',
    [questId]
  )
  if (!rows.length) return false
  const cmd: string[] = JSON.parse(rows[0].grade_cmd)

  // ↓ 여기 추가 ($NS 없는 cmd는 replace 후에도 원본과 동일)
  const ns = `quest-${containerId.slice(0, 8)}`
  const resolvedCmd = cmd.map((s: string) => s.replace(/\$NS/g, ns))

  return execCheck(docker.getContainer(containerId), resolvedCmd)  // cmd → resolvedCmd
}
```

### 5-5. terminal.ts — runSetupCmd()에 $NS 치환 추가

`runSetupCmd()` 함수에서 setup_cmd 실행 전에 `$NS` 치환. containerId를 인자로 추가:

```typescript
// 함수 시그니처 변경: containerId 추가
async function runSetupCmd(container: Docker.Container, questId: number | null, containerId?: string): Promise<void> {
    if (questId === null) return
    let setupCmd = await getSetupCmd(questId)
    if (!setupCmd) return

    // ↓ 여기 추가
    if (containerId) {
        const ns = `quest-${containerId.slice(0, 8)}`
        setupCmd = setupCmd.map((s: string) => s.replace(/\$NS/g, ns))
    }

    const exec = await container.exec({ Cmd: setupCmd, AttachStdout: false, AttachStderr: false })
    await exec.start({})
    while (true) {
        const info = await exec.inspect()
        if (!info.Running) break
        await new Promise((r) => setTimeout(r, 100))
    }
}
```

k8s 터미널에서 호출 시 containerId 전달:

```typescript
// handleK8sTerminal() 안에서
await runSetupCmd(container, questId, container.id)  // 세 번째 인자 추가
```

### 5-6. QuestPanel.tsx — 지문/힌트/풀이의 $NS 치환

`containerId`는 이미 props로 받고 있다. 텍스트 렌더링 전에 `$NS`를 실제 namespace로 치환:

```typescript
// QuestPanel 함수 내부 상단에 추가
const ns = containerId ? `quest-${containerId.slice(0, 8)}` : '$NS'
const resolve = (text: string) => text.replace(/\$NS/g, ns)
```

`description`, `hint`, `solution` 렌더링 시 `resolve()` 적용:

```tsx
<p ...>{resolve(quest.description)}</p>

<p ...>{resolve(quest.hint ?? '')}</p>

<p ...>{resolve(quest.solution ?? '')}</p>
```

### 5-7. App.tsx — k8s 세트는 터미널 재마운트 방지

k8s 세트는 퀘스트 이동 시에도 같은 컨테이너(namespace)를 유지해야 한다.
`key={questIndex}`를 그대로 두면 퀘스트 이동마다 Terminal이 언마운트/재마운트되어 새 컨테이너가 생긴다.

`frontend/src/App.tsx` — Terminal의 `key` prop 수정:

```tsx
// 수정 전
<Terminal key={questIndex} sandboxType={sandboxType} questId={quest?.id ?? null} onConnected={setContainerId} />

// 수정 후
<Terminal key={sandboxType === 'k8s' ? 'k8s' : questIndex} sandboxType={sandboxType} questId={quest?.id ?? null} onConnected={setContainerId} />
```

k8s 세트는 `key`가 `'k8s'`로 고정되어 퀘스트를 이동해도 Terminal이 유지된다.
다른 세트는 `questIndex`가 `key`라 기존대로 퀘스트마다 새 컨테이너가 생성된다.

### 5-8. SetSelect.tsx — k8s 세트 안내 문구 추가

k8s 세트 선택 화면에서 터미널 환경 유지 여부를 미리 안내한다.

`frontend/src/pages/SetSelect.tsx` — 카드 렌더링 부분에 추가:

```tsx
<div style={{ fontSize: '16px', fontWeight: 600, marginBottom: '4px' }}>{s.title}</div>
<div style={{ fontSize: '13px', color: '#888' }}>{s.description}</div>
{s.sandbox_type === 'k8s' && (
    <div style={{ fontSize: '12px', color: '#555', marginTop: '8px' }}>
        퀘스트를 이동해도 터미널 환경(네임스페이스)이 유지됩니다.
    </div>
)}

---

## Step 6. init.sql 반영

퀘스트 데이터는 `backend/db/init.sql`에 이미 작성되어 있다.

```bash
docker-compose down -v && docker-compose up -d
```

---

## Step 7. 전체 사이클 검증

```
1. 세트 선택 화면에서 "k8s 기초" 세트 선택
2. 터미널 연결 — kubectl get nodes 실행해서 노드 보이는지 확인
3. 퀘스트 1번부터 순서대로 진행
4. 각 퀘스트 채점 버튼으로 grade_cmd 실행 확인
5. 세션 종료 후 kubectl get ns | grep quest- 로 namespace 삭제 확인
```

---

## k3d 클러스터 관리

평소에 쓰지 않을 때는 클러스터를 중지해두면 메모리를 돌려받을 수 있다.
k3d stop/start는 컨테이너를 내렸다 올리는 것이라 데이터는 유지된다.

```bash
# 중지 (메모리 해제, ~500MB 회수)
k3d cluster stop etude

# 재시작 (etude 서버 기동 전에 실행)
k3d cluster start etude

# 상태 확인
k3d cluster list

# 완전 삭제 후 재생성
k3d cluster delete etude
k3d cluster create etude --api-port 127.0.0.1:6443

# 재생성 후 config-etude 다시 생성 필요 (Step 3 참고)
kubectl config view --raw | \
  sed 's|https://127.0.0.1:6443|https://k3d-etude-server-0:6443|g' \
  > ~/.kube/config-etude

# etude 서버 재시작
```

클러스터가 내려간 상태에서 etude 서버를 기동하면 k8s 세트 선택 시 터미널 연결이 실패한다. 다른 세트(linux, docker)는 영향 없음.

---

## 주의사항

- kubeconfig의 server 주소가 `127.0.0.1`이면 컨테이너 내부에서 접근 불가. Step 3에서 먼저 검증할 것.
- k3d 클러스터가 내려가 있으면 etude 서버 기동 전에 `k3d cluster start etude` 실행.
- `$NS` 치환은 grade_cmd와 setup_cmd 둘 다 적용해야 함.
- Pod가 Running 상태가 되기까지 수 초 소요. grade_cmd 실행 타이밍에 따라 채점 실패할 수 있음 — `kubectl wait --for=condition=ready pod` 를 setup_cmd에 추가하거나, grade_cmd에 재시도 로직 검토.
