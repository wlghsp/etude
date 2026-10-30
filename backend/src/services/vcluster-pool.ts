import { exec } from 'node:child_process'
import { promisify } from 'node:util'
import { mkdirSync } from 'node:fs'
import { readdir, rm } from 'node:fs/promises'
import { homedir } from 'node:os'
import path from 'node:path'

const execAsync = promisify(exec)

const POOL_SIZE = Number(process.env.VCLUSTER_POOL_SIZE ?? 2)
const NODE_NAME = 'k3d-etude-server-0'
// 느린 서버에서 vcluster 컨트롤 플레인이 뜨는 시간이 60초를 넘길 수 있어 환경변수로 늘릴 수 있게 한다
const READY_TIMEOUT_SEC = Number(process.env.VCLUSTER_READY_TIMEOUT_SEC ?? 60)

// Colima(macOS) 환경에서 /tmp는 VM과 공유되지 않아 dockerode가 마운트할 파일을 찾지 못하고
// 빈 디렉토리를 생성해버린다. $HOME 하위는 Colima 기본 공유 대상이라 여기에 저장한다.
const KUBECONFIG_DIR = path.join(homedir(), '.etude', 'vcluster-kubeconfigs')

interface PooledVCluster {
    id: string     // vcluster 이름 (pool-{uuid})
    kubeconfigPath: string
}

const pool: PooledVCluster[] = []

export async function createVcluster(): Promise<PooledVCluster> {
    const id = `pool-${crypto.randomUUID().slice(0, 8)}`
    const ns = `vcluster-${id}`

    await execAsync(`vcluster create ${id} --connect=false --set "controlPlane.proxy.extraSANs={${NODE_NAME}}"`)

    // 이후 단계(준비 대기, 포트, kubeconfig)에서 실패하면 만들다 만 vcluster 가 남아 자원을 차지하므로 지우고 오류를 그대로 던진다
    try {
        return await finishVcluster(id, ns)
    } catch (err) {
        await execAsync(`vcluster delete ${id} --namespace ${ns}`).catch(() => {})
        throw err
    }
}

async function finishVcluster(id: string, ns: string): Promise<PooledVCluster> {

    // vcluster create --connect=false는 Pod가 Ready 될 때까지 기다리지 않고 바로 반환된다.
    // 컨트롤 플레인이 뜨기 전에 kubeconfig Secret을 조회하면 빈 값이 나오므로, Ready까지 명시적으로 대기한다.
    // 반환 직후에는 Pod 리소스 자체가 아직 없을 수 있어(없으면 wait가 즉시 "no matching resources found"로 실패),
    // 생성을 먼저 기다린 뒤 Ready를 확인한다. 복수 --for 지원 여부에 의존하지 않도록 명령을 나눈다.
    await execAsync(`kubectl wait --for=create pod -l app=vcluster -n ${ns} --timeout=30s`)
    await execAsync(`kubectl wait --for=condition=ready pod -l app=vcluster -n ${ns} --timeout=${READY_TIMEOUT_SEC}s`)

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

    // import 시점이 아니라 실제로 파일을 쓰는 시점에 만든다 (테스트가 buildApp()만 import해도 홈 디렉토리를 건드리지 않게)
    mkdirSync(KUBECONFIG_DIR, { recursive: true })
    const kubeconfigPath = path.join(KUBECONFIG_DIR, `${id}-kubeconfig.yaml`)
    const patched = stdout.replace(
    /server: https:\/\/localhost:8443/,
    `server: https://${NODE_NAME}:${nodePort}`
    )

    await execAsync(`cat > ${kubeconfigPath} << 'EOF'\n${patched}\nEOF`)

    return { id, kubeconfigPath }
}

async function deleteVcluster(v: PooledVCluster): Promise<void> {
    const ns = `vcluster-${v.id}`
    await execAsync(`vcluster delete ${v.id} --namespace ${ns}`).catch(() => {})
    await rm(v.kubeconfigPath, { force: true }).catch(() => {})
}

// 이전 프로세스가 남긴 pool kubeconfig 파일을 지운다. 디렉터리가 없으면 할 일이 없고,
// 그 밖의 오류(권한, I/O)는 정리가 안 됐다는 걸 알 수 있게 로그로 남긴다.
async function cleanupOrphanKubeconfigs(): Promise<void> {
    const files = await readdir(KUBECONFIG_DIR).catch((err) => {
        if (err?.code !== 'ENOENT') console.error(`[vcluster] kubeconfig 디렉터리를 읽지 못했습니다: ${KUBECONFIG_DIR}`, err)
        return [] as string[]
    })
    await Promise.all(
        files
            .filter((f) => /^pool-.+-kubeconfig\.yaml$/.test(f))
            .map((f) => {
                const file = path.join(KUBECONFIG_DIR, f)
                return rm(file, { force: true }).catch((err) => {
                    console.error(`[vcluster] kubeconfig 삭제 실패: ${file}`, err)
                })
            })
    )
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

    await cleanupOrphanKubeconfigs()
}

export function getPoolSize(): number {
    return pool.length
}

// 기동 시 pool을 채운다. 하나가 실패해도 프로세스를 죽이지 않는다 (assignFromPool은 pool이 비면 요청 시 생성한다).
// 컨테이너가 새로 만들어진 첫 기동에서는 vcluster CLI가 helm을 내려받는데, 동시에 만들면 한쪽이 내려받는 중인 파일을 실행해
// "permission denied"로 실패한다. 그래서 실패한 만큼은 순차로 한 번 더 시도한다 (그때는 helm이 이미 있다).
export async function initPool(create: () => Promise<PooledVCluster> = createVcluster): Promise<void> {
    await cleanupOrphanVclusters()

    const results = await Promise.allSettled(Array.from({ length: POOL_SIZE }, () => create()))
    for (const r of results) {
        if (r.status === 'fulfilled') pool.push(r.value)
        else console.error('[vcluster] pool 생성 실패, 순차로 다시 시도합니다:', r.reason)
    }

    while (pool.length < POOL_SIZE) {
        try {
            pool.push(await create())
        } catch (err) {
            console.error('[vcluster] pool 생성 재시도 실패. 요청 시 생성으로 대체됩니다:', err)
            break
        }
    }
}

export async function assignFromPool(): Promise<PooledVCluster> {
    const assigned = pool.shift()
    const target = assigned ?? await createVcluster() // pool이 비어 있으면 그 자리에서 생성 (fallback)

    // 비동기 재보충 - 응답을 기다리지 않음
    createVcluster().then((v) => pool.push(v)).catch(console.error)
 
    return target
}

export async function releaseVcluster(v: PooledVCluster): Promise<void> {
    await deleteVcluster(v) // 재사용하지 않음 - 항상 삭제
}