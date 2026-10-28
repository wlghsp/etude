import { describe, it, expect, vi } from 'vitest'
import { createSessionAccess, destroySessionAccess, LEARNER_CLUSTER_ROLE, type Kubectl } from './k8s-session.js'

const NS = 'quest-abcdef12'
const API = 'https://k3d-etude-server-0:6443'

// kubectl 호출을 기록하고, 명령별로 응답을 정해 둔 가짜. 응답이 없으면 빈 문자열.
function fakeKubectl(responses: Record<string, string | Error> = {}) {
    const calls: string[][] = []
    const kubectl: Kubectl = async (args) => {
        calls.push(args)
        const key = args.slice(0, 2).join(' ')
        const r = responses[key]
        if (r instanceof Error) throw r
        return r ?? ''
    }
    return { kubectl, calls }
}

const defaults = { 'create token': 'TOKEN-123\n', 'config view': 'Q0EtREFUQQ==' }

describe('createSessionAccess', () => {
    it('네임스페이스를 만들고 etude=session, Pod Security baseline 강제 라벨을 붙인다', async () => {
        const { kubectl, calls } = fakeKubectl(defaults)

        await createSessionAccess(NS, { kubectl, apiServer: API })

        expect(calls).toContainEqual(['create', 'namespace', NS])
        expect(calls).toContainEqual(['label', 'namespace', NS, 'etude=session', 'pod-security.kubernetes.io/enforce=baseline', '--overwrite'])
    })

    it('ServiceAccount와, 네임스페이스에 한정된 edit RoleBinding을 만든다 (ClusterRoleBinding으로 edit를 주지 않는다)', async () => {
        const { kubectl, calls } = fakeKubectl(defaults)

        await createSessionAccess(NS, { kubectl, apiServer: API })

        expect(calls).toContainEqual(['create', 'serviceaccount', 'learner', '-n', NS])
        expect(calls).toContainEqual(['create', 'rolebinding', 'learner-edit', '-n', NS, '--clusterrole=edit', `--serviceaccount=${NS}:learner`])
        const clusterBindings = calls.filter((c) => c[1] === 'clusterrolebinding')
        expect(clusterBindings.every((c) => !c.includes('--clusterrole=edit'))).toBe(true)
    })

    it('노드·네임스페이스 읽기 전용 ClusterRole만 클러스터 범위로 바인딩하고, 바인딩에 etude=session 라벨을 붙인다', async () => {
        const { kubectl, calls } = fakeKubectl(defaults)

        await createSessionAccess(NS, { kubectl, apiServer: API })

        const binding = `etude-learner-${NS}`
        expect(calls).toContainEqual(['create', 'clusterrolebinding', binding, `--clusterrole=${LEARNER_CLUSTER_ROLE}`, `--serviceaccount=${NS}:learner`])
        expect(calls).toContainEqual(['label', 'clusterrolebinding', binding, 'etude=session'])
    })

    it('읽기 전용 ClusterRole이 없으면 만들고(nodes, namespaces의 get/list/watch만), 있으면 만들지 않는다', async () => {
        const missing = fakeKubectl({ ...defaults, 'get clusterrole': new Error('NotFound') })
        await createSessionAccess(NS, { kubectl: missing.kubectl, apiServer: API })
        expect(missing.calls).toContainEqual(['create', 'clusterrole', LEARNER_CLUSTER_ROLE, '--verb=get,list,watch', '--resource=nodes,namespaces'])

        const present = fakeKubectl(defaults)
        await createSessionAccess(NS, { kubectl: present.kubectl, apiServer: API })
        expect(present.calls.some((c) => c[1] === 'clusterrole' && c[0] === 'create')).toBe(false)
    })

    it('토큰을 8시간 유효기간으로 발급한다', async () => {
        const { kubectl, calls } = fakeKubectl(defaults)

        await createSessionAccess(NS, { kubectl, apiServer: API })

        expect(calls).toContainEqual(['create', 'token', 'learner', '-n', NS, '--duration=8h'])
    })

    it('제한 kubeconfig를 돌려준다: 서버 주소, CA, 토큰, 기본 네임스페이스. 관리자 인증서는 없다', async () => {
        const { kubectl } = fakeKubectl(defaults)

        const kubeconfig = await createSessionAccess(NS, { kubectl, apiServer: API })

        expect(kubeconfig).toContain(`server: ${API}`)
        expect(kubeconfig).toContain('certificate-authority-data: Q0EtREFUQQ==')
        expect(kubeconfig).toContain('token: TOKEN-123')
        expect(kubeconfig).toContain(`namespace: ${NS}`)
        expect(kubeconfig).not.toContain('client-certificate')
        expect(kubeconfig).not.toContain('client-key')
    })

    it('CA 데이터를 읽지 못하면 실패한다 (인증서 파일 경로 방식 kubeconfig 등)', async () => {
        const { kubectl } = fakeKubectl({ ...defaults, 'config view': '' })

        await expect(createSessionAccess(NS, { kubectl, apiServer: API })).rejects.toThrow(/CA/)
    })

    it('토큰 발급이 실패하면 실패한다', async () => {
        const { kubectl } = fakeKubectl({ ...defaults, 'create token': new Error('forbidden') })

        await expect(createSessionAccess(NS, { kubectl, apiServer: API })).rejects.toThrow()
    })

    it('네임스페이스 이름에 허용되지 않은 문자가 있으면 어떤 명령도 실행하지 않고 거부한다', async () => {
        const { kubectl, calls } = fakeKubectl(defaults)

        await expect(createSessionAccess('x; rm -rf /', { kubectl, apiServer: API })).rejects.toThrow()
        await expect(createSessionAccess('Quest_Upper', { kubectl, apiServer: API })).rejects.toThrow()
        expect(calls).toHaveLength(0)
    })
})

describe('destroySessionAccess', () => {
    it('ClusterRoleBinding을 지운 뒤 네임스페이스를 지운다 (종료를 기다리지 않음)', async () => {
        const { kubectl, calls } = fakeKubectl()

        await destroySessionAccess(NS, { kubectl })

        expect(calls).toEqual([
            ['delete', 'clusterrolebinding', `etude-learner-${NS}`, '--ignore-not-found'],
            ['delete', 'namespace', NS, '--ignore-not-found', '--wait=false'],
        ])
    })

    it('앞 단계가 실패해도 네임스페이스 삭제는 시도하고, 예외를 던지지 않는다', async () => {
        const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
        const { kubectl, calls } = fakeKubectl({ 'delete clusterrolebinding': new Error('unreachable') })

        await expect(destroySessionAccess(NS, { kubectl })).resolves.toBeUndefined()

        expect(calls.some((c) => c[1] === 'namespace')).toBe(true)
        expect(errorSpy).toHaveBeenCalled()
        errorSpy.mockRestore()
    })

    it('이름이 올바르지 않으면 거부한다', async () => {
        const { kubectl, calls } = fakeKubectl()

        await expect(destroySessionAccess('bad name', { kubectl })).rejects.toThrow()
        expect(calls).toHaveLength(0)
    })
})
