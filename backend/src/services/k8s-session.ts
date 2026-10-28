import { execFile } from 'node:child_process'
import { promisify } from 'node:util'

// k8s 세션 권한. 학습자 컨테이너에는 관리자 kubeconfig를 주지 않고, 세션마다 자기 네임스페이스 안에서만 쓸 수 있는
// ServiceAccount의 제한 kubeconfig를 준다. 아래 모든 kubectl은 backend가 관리자 권한으로 실행한다 (학습자가 아니다).

const execFileAsync = promisify(execFile)

export type Kubectl = (args: string[]) => Promise<string>

// 셸을 거치지 않고 인자 배열로 실행한다 (네임스페이스 이름 등이 명령으로 해석되지 않게)
export const defaultKubectl: Kubectl = async (args) => (await execFileAsync('kubectl', args)).stdout

const SAFE_NAME = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/
export const LEARNER_CLUSTER_ROLE = 'etude-learner-cluster-read'
const SERVICE_ACCOUNT = 'learner'
const TOKEN_DURATION = '8h'
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
