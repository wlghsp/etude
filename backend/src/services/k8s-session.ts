import { execFile } from 'node:child_process'

// k8s 세션 권한. 학습자 컨테이너에는 관리자 kubeconfig를 주지 않고, 세션마다 자기 네임스페이스 안에서만 쓸 수 있는
// ServiceAccount의 제한 kubeconfig를 준다. 아래 모든 kubectl은 backend가 관리자 권한으로 실행한다 (학습자가 아니다).

// input이 있으면 표준입력으로 전달한다 (kubectl apply -f - 용)
export type Kubectl = (args: string[], input?: string) => Promise<string>

// 셸을 거치지 않고 인자 배열로 실행한다 (네임스페이스 이름 등이 명령으로 해석되지 않게)
export const defaultKubectl: Kubectl = (args, input) =>
    new Promise((resolve, reject) => {
        const child = execFile('kubectl', args, (err, stdout) => (err ? reject(err) : resolve(stdout)))
        if (input !== undefined) child.stdin?.end(input)
    })

const SAFE_NAME = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/
export const LEARNER_CLUSTER_ROLE = 'etude-learner-cluster-read'
const SERVICE_ACCOUNT = 'learner'
const TOKEN_DURATION = '8h'

// 학습자 한 명이 노드 자원을 독점해 다른 세션이나 vcluster pool에 영향을 주지 못하게 하는 상한.
// 퀘스트의 가장 큰 워크로드(디플로이먼트 3 복제, helm nginx 3 복제, PVC)가 들어가는 크기다.
const QUOTA_HARD = [
    'pods=12',
    'requests.cpu=2', 'requests.memory=2Gi',
    'limits.cpu=4', 'limits.memory=4Gi',
    'persistentvolumeclaims=4', 'requests.storage=5Gi',
    'services=10',
].join(',')

// 요청/제한을 쓰지 않은 파드(퀘스트 대부분)에 기본값을 채운다. 이게 없으면 위 쿼터 때문에 요청/제한 없는 파드가 모두 거부된다.
// max는 컨테이너 하나가 상한을 혼자 쓰는 것을 막는다.
const LIMIT_RANGE = [
    'apiVersion: v1',
    'kind: LimitRange',
    'metadata:',
    '  name: etude-limits',
    'spec:',
    '  limits:',
    '  - type: Container',
    '    defaultRequest: {cpu: 50m, memory: 64Mi}',
    '    default: {cpu: 500m, memory: 256Mi}',
    '    max: {cpu: "1", memory: 1Gi}',
    '',
].join('\n')
// 학습자 컨테이너(k3d 네트워크)에서 API 서버에 닿는 주소. backend 자신의 kubeconfig 주소와 다를 수 있다 (로컬은 127.0.0.1).
const DEFAULT_API_SERVER = process.env.K8S_SESSION_API_SERVER ?? 'https://k3d-etude-server-0:6443'

function assertSafeNamespace(namespace: string) {
    if (!SAFE_NAME.test(namespace)) throw new Error(`네임스페이스 이름이 올바르지 않습니다: ${namespace}`)
}

const bindingName = (namespace: string) => `etude-learner-${namespace}`

// 노드·네임스페이스 목록 읽기만 허용하는 ClusterRole (퀘스트 6.1, 6.2). 없으면 만든다.
async function ensureLearnerClusterRole(kubectl: Kubectl) {
    try {
        await kubectl(['get', 'clusterrole', LEARNER_CLUSTER_ROLE])
    } catch {
        await kubectl(['create', 'clusterrole', LEARNER_CLUSTER_ROLE, '--verb=get,list,watch', '--resource=nodes,namespaces'])
    }
}

function buildKubeconfig(opts: { apiServer: string; ca: string; token: string; namespace: string }) {
    return [
        'apiVersion: v1',
        'kind: Config',
        'clusters:',
        '- name: etude',
        '  cluster:',
        `    server: ${opts.apiServer}`,
        `    certificate-authority-data: ${opts.ca}`,
        'users:',
        '- name: learner',
        '  user:',
        `    token: ${opts.token}`,
        'contexts:',
        '- name: etude',
        '  context:',
        '    cluster: etude',
        '    user: learner',
        `    namespace: ${opts.namespace}`,
        'current-context: etude',
        '',
    ].join('\n')
}

// 세션 시작: 네임스페이스와 권한을 만들고 학습자용 kubeconfig(YAML 문자열)를 돌려준다.
export async function createSessionAccess(
    namespace: string,
    opts: { kubectl?: Kubectl; apiServer?: string } = {},
): Promise<string> {
    assertSafeNamespace(namespace)
    const kubectl = opts.kubectl ?? defaultKubectl
    const sa = `--serviceaccount=${namespace}:${SERVICE_ACCOUNT}`

    await ensureLearnerClusterRole(kubectl)

    await kubectl(['create', 'namespace', namespace])
    // Pod Security baseline: hostPath 볼륨, privileged 등 노드에 닿는 파드를 막는다. 네임스페이스 edit만으로는 노드를 장악할 수 있다.
    await kubectl(['label', 'namespace', namespace, 'etude=session', 'pod-security.kubernetes.io/enforce=baseline', '--overwrite'])
    // 권한을 주기 전에 자원 상한부터 둔다
    await kubectl(['create', 'quota', 'etude-quota', '-n', namespace, `--hard=${QUOTA_HARD}`])
    await kubectl(['apply', '-n', namespace, '-f', '-'], LIMIT_RANGE)
    await kubectl(['create', 'serviceaccount', SERVICE_ACCOUNT, '-n', namespace])
    // 네임스페이스에 한정된 RoleBinding으로만 edit를 준다 (ClusterRoleBinding이 아니다)
    await kubectl(['create', 'rolebinding', 'learner-edit', '-n', namespace, '--clusterrole=edit', sa])
    await kubectl(['create', 'clusterrolebinding', bindingName(namespace), `--clusterrole=${LEARNER_CLUSTER_ROLE}`, sa])
    await kubectl(['label', 'clusterrolebinding', bindingName(namespace), 'etude=session'])

    const token = (await kubectl(['create', 'token', SERVICE_ACCOUNT, '-n', namespace, `--duration=${TOKEN_DURATION}`])).trim()
    if (!token) throw new Error('ServiceAccount 토큰을 발급받지 못했습니다.')

    const ca = (await kubectl(['config', 'view', '--raw', '--minify', '-o', 'jsonpath={.clusters[0].cluster.certificate-authority-data}'])).trim()
    if (!ca) throw new Error('클러스터 CA 데이터를 읽지 못했습니다 (kubeconfig가 certificate-authority-data를 쓰는지 확인하세요).')

    return buildKubeconfig({ apiServer: opts.apiServer ?? DEFAULT_API_SERVER, ca, token, namespace })
}

// 세션 종료: ClusterRoleBinding(클러스터 범위)을 지우고 네임스페이스를 지운다. 한 단계가 실패해도 다음을 시도하고 예외는 던지지 않는다.
export async function destroySessionAccess(namespace: string, opts: { kubectl?: Kubectl } = {}): Promise<void> {
    assertSafeNamespace(namespace)
    const kubectl = opts.kubectl ?? defaultKubectl
    const steps: string[][] = [
        ['delete', 'clusterrolebinding', bindingName(namespace), '--ignore-not-found'],
        ['delete', 'namespace', namespace, '--ignore-not-found', '--wait=false'],
    ]
    for (const step of steps) {
        try {
            await kubectl(step)
        } catch (err) {
            console.error(`[k8s-session] 정리 실패 (${step.slice(0, 3).join(' ')}):`, err)
        }
    }
}
