# Phase 10 구현 가이드 — vcluster 전환 + KLID CMP 현장실습

명세: [specs/spec_phase10_klid_cmp.md](../specs/spec_phase10_klid_cmp.md)

전제: [Phase 6](guide_phase6.md)(k8s 기초, `k8s` sandbox 타입)이 이미 구현되어 있고 로컬/서버에 k3d 클러스터(`etude`)가 떠 있는 상태.

---

## 전체 흐름

```
Step 1. vcluster CLI 설치 (로컬 + 서버)
Step 2. vcluster 1개 생성해서 네트워크 경로 확인 (로컬 검증 — 이미 완료, 재현 절차만 기록)
Step 3. sandbox 테이블에 k8s-isolated 타입 추가
Step 4. services/vcluster-pool.ts — pool 관리 로직
Step 5. sandbox.ts — k8s-isolated kubeconfig 처리
Step 6. terminal.ts — k8s-isolated 분기 (pool에서 배정, 세션 종료 시 삭제)
Step 7. KLID CMP 퀘스트 세트 seed SQL
Step 8. 검증
```

---

## Step 1. vcluster CLI 설치

### 로컬 (macOS)

```bash
brew install vcluster
```

### 서버 (`infra/scripts/setup.sh`에 이미 반영됨)

```bash
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-arm64"
chmod +x vcluster
sudo mv vcluster /usr/local/bin/vcluster

docker pull ghcr.io/loft-sh/vcluster-pro:0.35.1
```

---

## Step 2. 네트워크 경로 확인 (2026-07-01 로컬 검증 완료)

`etude-k8s` 컨테이너는 Docker 브리지 네트워크(`k3d-etude`)에 있고, vcluster API 서버는 k3s **Pod 내부**에서 뜬다. 기본 kubeconfig(`server: https://localhost:8443` 등 ClusterIP 기반)는 이 네트워크에서 라우팅되지 않아 컨테이너에서 접속할 수 없다.

**해결 경로**: 기존 `k8s` 타입(Phase 6)이 API 서버 주소로 호스트 노드 컨테이너 이름(`k3d-etude-server-0`)을 쓰는 것과 동일한 방식을 쓴다.

1. vcluster 생성 시 `--set "controlPlane.proxy.extraSANs={k3d-etude-server-0}"` — 인증서에 호스트 노드 이름을 SAN으로 포함 (없으면 TLS 검증 실패). vcluster 0.35.1부터는 전용 `--tls-san` CLI 플래그가 없고 Helm values 경로로 설정해야 한다 (`unknown flag: --tls-san` 에러로 확인).
2. vcluster의 Service를 **NodePort**로 전환
3. kubeconfig의 `server`를 `https://k3d-etude-server-0:{nodePort}`로 치환

> **실제로 겪은 문제**: NodePort를 30000~32767 범위에서 무작위로 뽑아 쓰는데, `Promise.all`로 여러 vcluster를 동시에 만들면(Step 4) 서로 다른 vcluster가 같은 포트를 뽑아 `kubectl patch svc`가 `provided port is already allocated` 에러로 실패하는 경우가 실제로 발생했다. Step 4의 `createVcluster()`는 patch 실패 시 다른 포트로 재시도(최대 5회)하도록 처리한다.

### 재현 절차 (실제로 동작 확인됨)

```bash
vcluster create vcluster-test --connect=false --set "controlPlane.proxy.extraSANs={k3d-etude-server-0}"

kubectl patch svc vcluster-test -n vcluster-vcluster-test \
  -p '{"spec":{"type":"NodePort","ports":[{"name":"https","port":443,"protocol":"TCP","targetPort":8443,"nodePort":30443}]}}'

kubectl get secret vc-vcluster-test -n vcluster-vcluster-test \
  -o jsonpath='{.data.config}' | base64 -d > kubeconfig.yaml

sed -i '' 's|https://localhost:8443|https://k3d-etude-server-0:30443|' kubeconfig.yaml
# 리눅스 서버에서는 sed -i (macOS의 -i '' 아님)
```

이 kubeconfig를 `etude-k8s` 컨테이너에 마운트하면 별도 옵션 없이 `kubectl get ns` 등이 정상 동작함을 확인했다 (`extraSANs` 적용 시 `--insecure-skip-tls-verify` 불필요).

### 측정된 기동 시간

이미지가 캐시된 상태에서도 vcluster 생성 → Pod `1/1 Running`까지 **약 33초**. 병목은 k3s 컨트롤 플레인 부팅 자체(이미지 pull 아님). 이 대기시간을 없애기 위해 Step 4의 pre-warming pool을 쓴다.

> **주의 1**: `vcluster create --connect=false` 명령 자체는 Pod가 Ready 되는 걸 기다리지 않고 **약 4초 만에 반환**된다(`time` 명령으로 실측). 이 직후 바로 kubeconfig Secret을 조회하면 컨트롤 플레인이 아직 안 떠 있어 빈 값이 나오고, 그 결과로 만들어지는 kubeconfig 파일도 깨진 상태가 된다(실제로 겪은 문제: 컨테이너에서 `read /root/.kube/config: is a directory` 에러 — 1바이트짜리 빈 파일이 마운트되며 발생). Step 4의 `createVcluster()`는 `kubectl wait --for=condition=ready pod -l app=vcluster -n {ns} --timeout=60s`로 Pod ready까지 대기한다.
>
> **주의 2**: Pod가 Ready여도 vcluster 내부적으로 kubeconfig Secret(`vc-{id}`)을 실제로 채우는 데 추가 시간이 걸린다(실측: `kubectl wait` 통과 후에도 최대 4~6초간 Secret 내용이 비어있었음). `kubectl wait --for=condition=ready pod`만으로는 부족하고, Secret 내용에 `server:` 문자열이 실제로 포함될 때까지 별도로 폴링해야 한다(2초 간격, 최대 15회). Step 4의 `createVcluster()`가 이 폴링을 포함한다.

### Colima(macOS 로컬 개발) 전용 함정 — kubeconfig를 `/tmp`에 쓰면 안 됨

로컬(Colima)에서 위 `kubectl wait` 수정 후에도 컨테이너 안에서 여전히 `read /root/.kube/config: is a directory` 에러가 재현됐다. 이번엔 kubeconfig 파일 자체(macOS에서 보면 5000바이트대 정상 내용)는 멀쩡한데도 발생.

**원인**: Colima는 macOS 위에 리눅스 VM을 띄우고 그 안에서 Docker 데몬을 돌린다. VM과 macOS는 원래 별개의 파일시스템이고, Colima는 `$HOME`과 `/tmp/colima`만 VM과 공유하도록 마운트해준다(`~/.colima/default/colima.yaml`의 `mounts` 설정 주석에 명시됨). `/tmp`는 이 공유 대상이 아니다 — 그래서 macOS에서 `/tmp/xxx.yaml`에 파일을 써도 VM 내부의 Docker 데몬은 자기 자신의 (텅 빈) `/tmp`에서 그 경로를 찾고, 없으니 새 디렉토리를 만들어 마운트해버린다.

```bash
# macOS와 Colima VM의 /tmp가 서로 다른 파일시스템임을 확인하는 방법
colima ssh -- ls /tmp/   # VM 내부 /tmp — systemd-private-* 등 리눅스 전용 파일만 보임
ls /tmp/                 # macOS의 /tmp — 전혀 다른 내용
```

**해결**: kubeconfig 저장 경로를 `/tmp` 대신 `$HOME` 하위로 바꾼다. 서버(리눅스 VM에 Docker를 직접 설치하는 환경)에서는 Docker가 VM 경계 없이 같은 파일시스템을 보므로 `/tmp`를 써도 원래 문제가 없다 — 이건 로컬 전용 문제를 우회하는 게 아니라, 로컬/서버 어디서든 통하는 더 안전한 경로로 바꾸는 것뿐이다.

```typescript
import { mkdirSync } from 'node:fs'
import { homedir } from 'node:os'
import path from 'node:path'

const KUBECONFIG_DIR = path.join(homedir(), '.etude', 'vcluster-kubeconfigs')
mkdirSync(KUBECONFIG_DIR, { recursive: true })

// createVcluster() 안에서:
const kubeconfigPath = path.join(KUBECONFIG_DIR, `${id}-kubeconfig.yaml`)
```

---

## Step 3. sandbox 테이블 — k8s-isolated 타입 추가 (완료)

`backend/db/01_sandbox.sql`의 기존 `INSERT INTO ... VALUES` 문에 행 추가 (다른 타입들과 같은 스타일):

```sql
('k8s-isolated', 'etude-k8s', NULL, FALSE, 'kubectl 실습 환경 (vcluster 완전 격리 — KLID CMP 현장실습용). binds는 세션마다 pool에서 동적으로 배정되므로 DB에 고정하지 않음.');
```

`binds`를 `NULL`로 둔 이유: 세션마다 다른 vcluster의 kubeconfig를 마운트해야 하므로 DB에 고정 경로를 넣지 않고, 실제 마운트는 Step 6의 `terminal.ts`에서 세션별로 동적 처리한다.

> 기존 `k8s` 타입의 `binds`는 서버 전역 kubeconfig 경로를 고정 바인드하지만, `k8s-isolated`는 세션마다 다른 vcluster의 kubeconfig를 써야 하므로 바인드 경로가 세션마다 동적으로 결정된다. 실제 바인드 주입은 DB 값이 아니라 Step 6의 `terminal.ts`에서 세션별로 처리한다 — 위 SQL의 binds 값은 sandbox 타입 존재를 위한 placeholder이며 실제로 이 경로가 쓰이지는 않는다.

---

## Step 4. vcluster pool 관리 — `services/vcluster-pool.ts` (신규)

```typescript
import { exec } from 'node:child_process'
import { promisify } from 'node:util'
import { mkdirSync } from 'node:fs'
import { homedir } from 'node:os'
import path from 'node:path'

const execAsync = promisify(exec)

const POOL_SIZE = 2
const NODE_NAME = 'k3d-etude-server-0'

// Colima(macOS) 환경에서 /tmp는 VM과 공유되지 않아 dockerode가 마운트할 파일을 찾지 못하고
// 빈 디렉토리를 생성해버린다. $HOME 하위는 Colima 기본 공유 대상이라 여기에 저장한다.
const KUBECONFIG_DIR = path.join(homedir(), '.etude', 'vcluster-kubeconfigs')
mkdirSync(KUBECONFIG_DIR, { recursive: true })

interface PooledVcluster {
  id: string        // vcluster 이름 (pool-{uuid})
  kubeconfigPath: string
}

const pool: PooledVcluster[] = []

async function createVcluster(): Promise<PooledVcluster> {
  const id = `pool-${crypto.randomUUID().slice(0, 8)}`
  const ns = `vcluster-${id}`

  await execAsync(`vcluster create ${id} --connect=false --set "controlPlane.proxy.extraSANs={${NODE_NAME}}"`)

  // vcluster create --connect=false는 Pod가 Ready 될 때까지 기다리지 않고 바로 반환된다.
  // 컨트롤 플레인이 뜨기 전에 kubeconfig Secret을 조회하면 빈 값이 나오므로, Ready까지 명시적으로 대기한다.
  await execAsync(`kubectl wait --for=condition=ready pod -l app=vcluster -n ${ns} --timeout=60s`)

  // NodePort 전환 - 랜덤 포트가 이미 다른 vcluster에 할당되어 있으면 재시도한다
  // (동시에 여러 vcluster를 생성할 때 겹칠 확률이 있어 재시도가 필요)
  const nodePort = await (async () => {
    for (let attempt = 0; attempt < 5; attempt++) {
      const candidate = 30000 + Math.floor(Math.random() * 2000)
      try {
        await execAsync(
          `kubectl patch svc ${id} -n ${ns} -p '{"spec":{"type":"NodePort","ports":[{"name":"https","port":443,"protocol":"TCP","targetPort":8443,"nodePort":${candidate}}]}}'`
        )
        return candidate
      } catch (err) {
        if (attempt === 4) throw err
      }
    }
    throw new Error('unreachable')
  })()

  // Pod가 Ready여도 vcluster 내부적으로 kubeconfig Secret을 만드는 데 추가 시간이 걸린다.
  // Secret이 생겨도 초반엔 내용이 비어있을 수 있어, 실제로 쓸만한 내용(server: 포함)이 나올 때까지 폴링한다.
  const stdout = await (async () => {
    for (let attempt = 0; attempt < 15; attempt++) {
      const { stdout: out } = await execAsync(
        `kubectl get secret vc-${id} -n ${ns} -o jsonpath='{.data.config}' | base64 -d`
      ).catch(() => ({ stdout: '' }))
      if (out.includes('server:')) return out
      await new Promise((r) => setTimeout(r, 2000))
    }
    throw new Error(`vcluster ${id}: kubeconfig secret not ready after retries`)
  })()

  const kubeconfigPath = path.join(KUBECONFIG_DIR, `${id}-kubeconfig.yaml`)
  const patched = stdout.replace(
    /server: https:\/\/localhost:8443/,
    `server: https://${NODE_NAME}:${nodePort}`
  )
  await execAsync(`cat > ${kubeconfigPath} << 'EOF'\n${patched}\nEOF`)

  return { id, kubeconfigPath }
}

async function deleteVcluster(v: PooledVcluster): Promise<void> {
  const ns = `vcluster-${v.id}`
  await execAsync(`vcluster delete ${v.id} --namespace ${ns}`).catch(() => {})
}

export async function initPool(): Promise<void> {
  while (pool.length < POOL_SIZE) {
    pool.push(await createVcluster())
  }
}

export async function assignFromPool(): Promise<PooledVcluster> {
  const assigned = pool.shift()
  const target = assigned ?? await createVcluster()  // pool이 비어있으면 그 자리에서 생성 (fallback)

  // 비동기 재보충 — 응답을 기다리지 않음
  createVcluster().then((v) => pool.push(v)).catch(console.error)

  return target
}

export async function releaseVcluster(v: PooledVcluster): Promise<void> {
  await deleteVcluster(v)  // 재사용하지 않음 — 항상 삭제
}
```

`initPool()`은 서버 기동 시(`index.ts`) 한 번 호출해 pool을 채워둔다. `cleanupOrphanContainers()`와 같은 자리(라우트 등록 전, 서버 리슨 전)에 추가한다.

```typescript
import { initPool } from './services/vcluster-pool.js'

await cleanupOrphanContainers()
await initPool()
```

이 호출이 빠지면 pool이 비어있는 채로 시작되어, `assignFromPool()`이 매번 fallback(그 자리에서 생성)만 타게 되고 pre-warming의 이점이 사라진다.

### 고아 vcluster 정리

Docker 컨테이너는 `cleanupOrphanContainers()`/`cleanupRunningContainers()`로 서버 기동/종료 시 정리되지만, vcluster pool은 **메모리 배열(`pool`)로만 상태를 추적**하므로 서버가 재시작되면 이전 프로세스가 만든 vcluster들이 실제 클러스터에는 남아있는데도 새 프로세스는 이를 전혀 모르는 채로 또 새로 만든다 — 재시작할 때마다 vcluster가 계속 누적되는 문제.

**실측 확인 (2026-07-01)**: 로컬 개발 서버(`npm run dev`)를 종료해도 `vcluster-pool-*` namespace가 클러스터에 그대로 남는 것을 확인.

```bash
kubectl get ns | grep vcluster-
```

**해결**: `services/vcluster-pool.ts`에 `cleanupOrphanVclusters()`를 추가해, `initPool()` 호출 시 `vcluster-` 접두사를 가진 namespace를 전부 조회해 먼저 삭제한 뒤 pool을 새로 채운다 (Docker의 `cleanupOrphanContainers()`와 동일한 철학 — 서버 기동 시 이전 상태는 무조건 믿지 않고 깨끗이 지우고 시작). 위 `initPool()`은 이 함수를 호출하도록 아래처럼 바뀐다.

```typescript
export async function cleanupOrphanVclusters(): Promise<void> {
  const { stdout } = await execAsync(
    `kubectl get ns -o jsonpath='{.items[*].metadata.name}'`
  ).catch(() => ({ stdout: '' }))

  const orphanNamespaces = stdout.split(/\s+/).filter((ns) => ns.startsWith('vcluster-'))

  for (const ns of orphanNamespaces) {
    const id = ns.replace(/^vcluster-/, '')
    await execAsync(`vcluster delete ${id} --namespace ${ns}`).catch(() => {})
  }
}

export async function initPool(): Promise<void> {
  await cleanupOrphanVclusters()

  while (pool.length < POOL_SIZE) {
    pool.push(await createVcluster())
  }
}
```

**서버 종료 시 정리도 필요** — Docker의 `cleanupRunningContainers()`처럼, `fastify.addHook('onClose', ...)`에 vcluster 정리를 추가해 정상 종료 시점에 남은 vcluster를 지운다. `index.ts`에 아래처럼 추가한다(직접 작성):

```typescript
fastify.addHook('onClose', async () => {
    await cleanupRunningContainers()
    await cleanupOrphanVclusters()  // pool + 배정 중이던 vcluster 모두 정리
})
```

> `cleanupOrphanVclusters()`는 이름 그대로 "고아"를 정리하는 함수지만, 서버 종료 시점에는 pool에 남아있는 것과 세션에 배정되어 아직 안 끝난 것 모두 결국 정리 대상이므로 재사용 가능하다. 비정상 종료(크래시, kill -9)의 경우 이 훅 자체가 안 불리므로, 다음 서버 기동 시 `initPool()`의 `cleanupOrphanVclusters()`가 최종 안전망이 된다.

### 선택 — 기동/종료 시간 줄이기

지금까지의 구현은 전부 순차 처리(`while`, `for...of`)라 이해하기는 쉽지만, vcluster 생성 하나에 33초가 걸리므로(Step 2 "측정된 기동 시간" 참고) `POOL_SIZE`가 커질수록 서버 기동/종료 시간이 그만큼 길어진다. 필요하면 아래 두 가지를 적용할 수 있다.

**1. `initPool()`과 `cleanupOrphanVclusters()`를 `Promise.all`로 병렬화** — pool을 채우거나 고아를 정리할 때 하나씩 순서대로 기다릴 필요가 없다.

```typescript
export async function initPool(): Promise<void> {
  await cleanupOrphanVclusters()

  const created = await Promise.all(
    Array.from({ length: POOL_SIZE }, () => createVcluster())
  )
  pool.push(...created)
}

export async function cleanupOrphanVclusters(): Promise<void> {
  const { stdout } = await execAsync(
    `kubectl get ns -o jsonpath='{.items[*].metadata.name}'`
  ).catch(() => ({ stdout: '' }))

  const orphanNamespaces = stdout.split(/\s+/).filter((ns) => ns.startsWith('vcluster-'))

  await Promise.all(
    orphanNamespaces.map((ns) => {
      const id = ns.replace(/^vcluster-/, '')
      return execAsync(`vcluster delete ${id} --namespace ${ns}`).catch(() => {})
    })
  )
}
```

기동 시(`initPool`)는 사람이 서버가 뜨길 기다리는 시간이라 체감 효과가 크고, 종료 시(`cleanupOrphanVclusters`)는 보통 백그라운드라 체감 효과는 작지만 원리는 동일하다.

**2. `POOL_SIZE`를 환경변수로 분리** — 로컬 개발 중에는 pool 크기를 줄여 기동 시간을 단축할 수 있다.

```typescript
const POOL_SIZE = Number(process.env.VCLUSTER_POOL_SIZE ?? 2)
```

`backend/.env`에 `VCLUSTER_POOL_SIZE=1` 또는 `0`을 넣으면 로컬 개발 시 기동이 빨라진다 (0이면 pool 없이 매번 fallback으로 그 자리에서 생성 — 개발 중 pool 배관 자체를 테스트할 필요가 없을 때 유용).

---

## Step 5. `sandbox.ts` — k8s-isolated 처리

기존 `getSandboxConfig()`는 DB의 고정 binds를 반환하는데, `k8s-isolated`는 세션마다 동적으로 정해지므로 이 함수 바깥(Step 6)에서 처리한다. `sandbox.ts` 자체는 변경 없음 — `k8s-isolated` 타입은 `terminal.ts`에서 `getSandboxConfig()` 호출 없이 별도 분기로 처리.

---

## Step 6. `terminal.ts` — k8s-isolated 분기

기존 `handleK8sTerminal`(namespace 격리)을 참고해 `handleK8sIsolatedTerminal`을 추가한다.

```typescript
import { assignFromPool, releaseVcluster } from './vcluster-pool.js'

async function handleK8sIsolatedTerminal(socket: WebSocket, docker: Docker, questId: number | null) {
  const vcluster = await assignFromPool()

  const container = await docker.createContainer({
    Image: 'etude-k8s',
    Labels: { etude: 'sandbox' },
    HostConfig: {
      Binds: [`${vcluster.kubeconfigPath}:/root/.kube/config:ro`],
      NetworkMode: process.env.K3D_NETWORK ?? 'k3d-etude',
    },
    Cmd: ['/bin/bash'],
    AttachStdin: true, AttachStdout: true, AttachStderr: true,
    OpenStdin: true, Tty: true,
  })

  const stream = await container.attach({ stream: true, stdin: true, stdout: true, stderr: true, hijack: true })
  await container.start()
  await runSetupCmd(container, questId)

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', async () => {
    await releaseVcluster(vcluster)
    container.stop().then(() => container.remove()).catch(() => {})
  })
}
```

`handleTerminal()`의 분기에 추가:

```typescript
} else if (sandboxType === 'k8s-isolated') {
    await handleK8sIsolatedTerminal(socket, docker, questId)
} else if (sandboxType === 'k8s') {
```

---

## Step 7. KLID CMP 퀘스트 세트 — seed SQL

`backend/db/03_quest_set15.sql`(신규, 기존 14개 세트 다음 번호) — [KLID_CMP_deploy_guide.md](../sources/KLID_CMP_deploy_guide.md) 순서를 따른다.

> 패키지(`99.packages/`) 반입 방법이 미확정이라 grade_cmd는 이 문서에서 구체화하지 않는다. 패키지 반입 방법이 정해지면 각 단계의 검증 명령(예: `helm status cmp-gateway -n cmp-gateway`, `kubectl get pod -n cmp-mdware | grep vault`)을 채워 넣는다.

| order | 제목 | 원본 섹션 |
|-------|------|-----------|
| 1 | 레포지토리 이미지 업로드 | 02.images |
| 2 | 인증서 생성 + TLS Secret 생성 | 01.certs |
| 3 | cmp-gateway 생성 (Helm) | 03.cmp-helm/01.cmp-gateway |
| 4 | Redis 배포 | 03.cmp-helm/02.cmp-mdware |
| 5 | RabbitMQ 배포 | 03.cmp-helm/02.cmp-mdware |
| 6 | Vault 배포 + unseal | 03.cmp-helm/02.cmp-mdware |
| 7 | Keycloak 배포 | 03.cmp-helm/02.cmp-mdware |
| 8 | IaaS CMP 배포 | 03.cmp-helm/03.iaas-cmp |
| 9 | PaaS CMP 배포 | 03.cmp-helm/04.paas-cmp |
| 10 | Gateway 및 서비스 브로커 기동 | 04.gateway-broker |

---

## Step 8. 검증

로컬(1세션)에서 가능한 것:
- [ ] `k8s-isolated` sandbox 타입으로 터미널 접속 시 pool에서 즉시 배정되어 대기 없이 연결되는지
- [ ] 접속한 컨테이너 안에서 `kubectl get nodes`, `kubectl get ns` 실행 시 다른 세션/quest-* namespace가 전혀 보이지 않는지
- [ ] 세션 종료 시 vcluster가 삭제되고 pool이 비동기로 재보충되는지 (`kubectl get ns | grep vcluster-`로 잔여 확인)

서버(다중 세션)에서만 가능한 것:
- [ ] 두 세션을 동시에 열어 서로 완전히 격리되는지
- [ ] pool 소진 시 fallback(즉시 생성) 동작 확인
- [ ] KLID CMP 배포 절차 10단계를 실제 vcluster 안에서 순서대로 실행해 전체 스택이 기동되는지
