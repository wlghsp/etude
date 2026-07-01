import { exec } from 'node:child_process'
import { promisify } from 'node:util'
import { mkdirSync } from 'node:fs'
import { homedir } from 'node:os'
import path from 'node:path'

const execAsync = promisify(exec)

const POOL_SIZE = Number(process.env.VCLUSTER_POOL_SIZE ?? 2)
const NODE_NAME = 'k3d-etude-server-0'

// Colima(macOS) 환경에서 /tmp는 VM과 공유되지 않아 dockerode가 마운트할 파일을 찾지 못하고
// 빈 디렉토리를 생성해버린다. $HOME 하위는 Colima 기본 공유 대상이라 여기에 저장한다.
const KUBECONFIG_DIR = path.join(homedir(), '.etude', 'vcluster-kubeconfigs')
mkdirSync(KUBECONFIG_DIR, { recursive: true })

interface PooledVCluster {
    id: string     // vcluster 이름 (pool-{uuid})
    kubeconfigPath: string
}

const pool: PooledVCluster[] = []

async function createVcluster(): Promise<PooledVCluster> {
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

async function deleteVcluster(v: PooledVCluster): Promise<void> {
    const ns = `vcluster-${v.id}`
    await execAsync(`vcluster delete ${v.id} --namespace ${ns}`).catch(() => {})
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

export async function initPool(): Promise<void> {
    await cleanupOrphanVclusters()

    const created = await Promise.all(
        Array.from({ length: POOL_SIZE }, () => createVcluster())
    )
    pool.push(...created)
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