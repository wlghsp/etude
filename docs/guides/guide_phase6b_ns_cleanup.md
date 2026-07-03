# Phase 6b 구현 가이드 — k8s namespace 고아 정리

명세: [specs/spec_phase6b_ns_cleanup.md](../specs/spec_phase6b_ns_cleanup.md)

전제: [Phase 6](guide_phase6.md)(k8s 기초 실습 세트)와 [Phase 10](guide_phase10_klid_cmp.md)(vcluster pool)이 구현되어 있는 상태. `cleanupOrphanVclusters()`의 구조를 그대로 참고한다.

---

## 전체 흐름

```
Step 1. plugins/k8s-namespace.ts (신규) — cleanupOrphanQuestNamespaces() 작성
Step 2. index.ts — 서버 기동 시 호출 추가
Step 3. 로컬에서 강제 종료로 재현 + 정리 확인
```

---

## Step 1. `plugins/k8s-namespace.ts` (신규) — 고아 namespace 정리 함수

`docker.ts`(Docker 컨테이너 정리)와 `vcluster-pool.ts`(vcluster 정리)처럼, "이 리소스 종류를 다루는 파일"이 리소스별로 나뉘어 있다. `terminal.ts`는 WebSocket 연결 처리가 본연의 역할이라, 서버 기동 시 1회 실행되는 정리 로직을 거기 얹으면 역할이 섞인다 — `plugins/`에 전담 파일을 새로 만든다.

`k8s` 타입이 만드는 namespace 이름 규칙은 `quest-{containerId 앞 8자리}` ([terminal.ts:174](../../backend/src/services/terminal.ts#L174)의 `handleK8sTerminal` 참고). 이 접두사로 걸러서 지운다.

`vcluster-pool.ts`의 `cleanupOrphanVclusters()`와 완전히 같은 구조다 — `execAsync`로 `kubectl`을 직접 호출하는 점도 동일.

```typescript
// backend/src/plugins/k8s-namespace.ts
import { exec } from 'node:child_process'
import { promisify } from 'node:util'

const execAsync = promisify(exec)

export async function cleanupOrphanQuestNamespaces(): Promise<void> {
  const { stdout } = await execAsync(
    `kubectl get ns -o jsonpath='{.items[*].metadata.name}'`
  ).catch(() => ({ stdout: '' }))

  const orphanNamespaces = stdout.split(/\s+/).filter((ns) => ns.startsWith('quest-'))

  await Promise.all(
    orphanNamespaces.map((ns) =>
      execAsync(`kubectl delete namespace ${ns} --ignore-not-found`).catch(() => {})
    )
  )
}
```

`handleK8sTerminal` 안의 namespace 생성/삭제 로직 자체는 이번 범위에 포함하지 않는다 — `terminal.ts`에 그대로 둔다. 이번 Phase는 "정상 종료 흐름에서 놓친 것을 서버 기동 시 잡아내는 안전망" 추가에만 집중한다.

---

## Step 2. `index.ts` — 서버 기동 시 호출

기존 정리 함수들과 같은 자리(라우트 등록 전, 서버 리슨 전)에 추가한다.

```typescript
import { cleanupOrphanContainers, cleanupRunningContainers } from './plugins/docker.js'
import { cleanupOrphanVclusters, initPool } from './services/vcluster-pool.js'
import { cleanupOrphanQuestNamespaces } from './plugins/k8s-namespace.js'

const fastify = Fastify({ logger: true })

await cleanupOrphanContainers()
await cleanupOrphanQuestNamespaces()
await initPool()
```

`kubectl`이 backend 컨테이너 안에서 실행되는 컨텍스트는 [Phase 10](guide_phase10_klid_cmp.md) Step 1에서 이미 Dockerfile에 설치해뒀으므로 별도 설치는 불필요하다 — `KUBECONFIG` 환경변수도 `docker-compose.prod.yml`에 이미 설정되어 있어 `k8s`/`k8s-isolated` 양쪽에서 공유된다.

---

## Step 3. 재현 + 검증

### 로컬에서 강제 종료로 재현

```bash
# 1. k8s 세트로 터미널을 열어 quest-xxxxxxxx namespace를 하나 생성
# 2. 정상 종료 대신 백엔드 프로세스를 강제 종료
kill -9 {backend 프로세스 PID}

# 3. namespace가 남아있는지 확인
kubectl get ns | grep quest-
```

### 서버 재기동 후 정리 확인

```bash
npm run dev   # 또는 프로덕션이면 docker compose ... up -d --build backend

# 재기동 로그 확인 후
kubectl get ns | grep quest-
# 출력 없어야 정상
```

### 정상 종료 흐름 회귀 확인

k8s 세트를 열고 정상적으로 홈으로 나가거나 브라우저를 닫아 `socket.on('close', ...)` 경로가 여전히 잘 동작하는지(기존 동작이 이 변경으로 깨지지 않았는지) 확인한다.

---

## 주의사항

- `cleanupOrphanQuestNamespaces()`는 `quest-` 접두사만 지운다 — `vcluster-` 접두사(Phase 10)나 `kube-system` 등 시스템 namespace는 건드리지 않는다. 접두사 필터를 실수로 넓히지 않도록 주의.
- 이 정리는 **서버 기동 시 1회**만 실행된다. 서버가 오래 떠 있는 도중 발생하는 고아(네트워크 끊김 등)는 다음 재기동 때까지 남아있을 수 있다 — 실사용 중 문제가 잦다면 주기적 정리(cron 등)를 추가로 검토.
