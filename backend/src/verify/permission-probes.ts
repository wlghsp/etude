import type { VerifySandbox } from './verify-quest.js'

// 제한된 k8s 세션 kubeconfig로 무엇이 허용되고 무엇이 거부되는지 실제 클러스터에서 확인하는 프로브.
// 거부 확인은 가능한 한 `kubectl auth can-i`(아무것도 바꾸지 않음)로 하고, 실제 생성 시도는 자기 네임스페이스($NS)에만 한다.
// 어떤 프로브도 delete를 실행하지 않는다 (권한이 잘못 열려 있어도 다른 자원을 지우지 않게).

export interface Probe {
    name: string
    cmd: string[]
    expect: 'allow' | 'deny' // allow: 종료 코드 0, deny: 0이 아님
}

export interface ProbeResult {
    name: string
    expect: 'allow' | 'deny'
    exitCode: number
    ok: boolean
}

// podSpec은 spec 아래(들여쓰기 2칸), containerExtra는 컨테이너 아래(들여쓰기 4칸)에 들어간다
const podManifest = (podSpec: string, containerExtra = '') =>
    `kubectl apply -n $NS -f - <<'EOF'\napiVersion: v1\nkind: Pod\nmetadata:\n  name: probe-pod\nspec:\n${podSpec}  containers:\n  - name: c\n    image: nginx\n${containerExtra}EOF`

export function buildProbes(): Probe[] {
    return [
        // --- 허용: 퀘스트가 실제로 쓰는 동작
        { name: '자기 네임스페이스의 파드를 조회할 수 있다', cmd: ['kubectl', 'get', 'pods', '-n', '$NS'], expect: 'allow' },
        { name: '자기 네임스페이스에 디플로이먼트를 만들 수 있다', cmd: ['kubectl', 'auth', 'can-i', 'create', 'deployments', '-n', '$NS'], expect: 'allow' },
        { name: '자기 네임스페이스에 ConfigMap을 만들 수 있다', cmd: ['kubectl', 'create', 'configmap', 'probe-cm', '--from-literal=a=b', '-n', '$NS'], expect: 'allow' },
        { name: 'baseline을 통과하는 파드(nginx)를 만들 수 있다', cmd: ['kubectl', 'run', 'probe-ok', '--image=nginx', '-n', '$NS'], expect: 'allow' },
        { name: '노드 목록을 읽을 수 있다', cmd: ['kubectl', 'get', 'nodes'], expect: 'allow' },
        { name: '네임스페이스 목록을 읽을 수 있다', cmd: ['kubectl', 'get', 'namespaces'], expect: 'allow' },
        { name: '자기 네임스페이스의 쿼터를 조회할 수 있다', cmd: ['kubectl', 'get', 'resourcequota', '-n', '$NS'], expect: 'allow' },

        // --- 거부: can-i(변경 없음)
        { name: '전체 관리자 권한이 없다', cmd: ['kubectl', 'auth', 'can-i', '*', '*', '--all-namespaces'], expect: 'deny' },
        { name: 'kube-system의 secret을 읽을 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'get', 'secrets', '-n', 'kube-system'], expect: 'deny' },
        { name: '모든 네임스페이스의 secret을 읽을 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'get', 'secrets', '--all-namespaces'], expect: 'deny' },
        { name: 'default 네임스페이스의 파드를 볼 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'list', 'pods', '-n', 'default'], expect: 'deny' },
        { name: '노드를 수정할 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'delete', 'nodes'], expect: 'deny' },
        { name: 'PersistentVolume을 만들 수 없다 (hostPath로 노드에 닿는 경로)', cmd: ['kubectl', 'auth', 'can-i', 'create', 'persistentvolumes'], expect: 'deny' },
        { name: 'ClusterRole을 만들 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'create', 'clusterroles'], expect: 'deny' },
        { name: 'ClusterRoleBinding을 만들 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'create', 'clusterrolebindings'], expect: 'deny' },

        // --- 거부: 자원 상한을 학습자가 풀 수 없다
        { name: '쿼터를 삭제할 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'delete', 'resourcequotas', '-n', '$NS'], expect: 'deny' },
        { name: 'LimitRange를 수정할 수 없다', cmd: ['kubectl', 'auth', 'can-i', 'update', 'limitranges', '-n', '$NS'], expect: 'deny' },
        { name: '컨테이너 상한을 넘는 요청(cpu 100)이 거부된다', cmd: ['sh', '-c', podManifest('', '    resources:\n      requests:\n        cpu: "100"\n')], expect: 'deny' },

        // --- 거부: Pod Security baseline이 막아야 하는 파드 (자기 네임스페이스에서 시도하고 거부되어야 한다)
        { name: 'hostPath 볼륨 파드가 거부된다', cmd: ['sh', '-c', podManifest('  volumes:\n  - name: h\n    hostPath:\n      path: /\n')], expect: 'deny' },
        { name: 'privileged 파드가 거부된다', cmd: ['sh', '-c', podManifest('', '    securityContext:\n      privileged: true\n')], expect: 'deny' },
        { name: 'hostNetwork 파드가 거부된다', cmd: ['sh', '-c', podManifest('  hostNetwork: true\n')], expect: 'deny' },

        // --- 거부: 컨테이너 안에 관리자 인증서가 없다
        { name: 'kubeconfig에 관리자 인증서가 없다', cmd: ['grep', '-q', 'client-certificate', '/root/.kube/config'], expect: 'deny' },
    ]
}

export async function runPermissionProbes(sandbox: VerifySandbox): Promise<ProbeResult[]> {
    const results: ProbeResult[] = []
    for (const probe of buildProbes()) {
        const exitCode = await sandbox.exec(probe.cmd, 60_000)
        const ok = probe.expect === 'allow' ? exitCode === 0 : exitCode !== 0
        results.push({ name: probe.name, expect: probe.expect, exitCode, ok })
    }
    return results
}
