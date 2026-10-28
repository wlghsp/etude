import { describe, it, expect, vi, beforeEach } from 'vitest'

const { execMock } = vi.hoisted(() => ({ execMock: vi.fn() }))
vi.mock('node:child_process', () => ({ exec: execMock }))

import { cleanupOrphanQuestNamespaces } from './k8s-namespace.js'

// kubectl 호출을 명령 문자열로 구분해 응답하고, 실행된 명령을 기록한다
function stubKubectl(opts: { namespaces: string; pvs: string; failPvList?: boolean }) {
    const commands: string[] = []
    execMock.mockImplementation((cmd: string, cb: (err: Error | null, out?: unknown) => void) => {
        commands.push(cmd)
        if (cmd.startsWith('kubectl get ns')) return cb(null, { stdout: opts.namespaces, stderr: '' })
        if (cmd.startsWith('kubectl get pv')) return opts.failPvList ? cb(new Error('boom')) : cb(null, { stdout: opts.pvs, stderr: '' })
        return cb(null, { stdout: '', stderr: '' })
    })
    return commands
}

describe('cleanupOrphanQuestNamespaces', () => {
    beforeEach(() => { execMock.mockReset() })

    it('quest- 네임스페이스를 지운다 (기존 동작)', async () => {
        const commands = stubKubectl({ namespaces: 'default quest-aaa11111 kube-system', pvs: '' })

        await cleanupOrphanQuestNamespaces()

        expect(commands).toContain('kubectl delete namespace quest-aaa11111 --ignore-not-found')
        expect(commands.some((c) => c.includes('namespace default'))).toBe(false)
    })

    it('claimRef 네임스페이스가 quest-로 시작하는 PV만 지운다', async () => {
        const commands = stubKubectl({
            namespaces: 'default',
            pvs: [
                'pv-local-quest-aaa11111 quest-aaa11111',
                'pv-local-quest-bbb22222 quest-bbb22222',
                'pv-other keep-this-ns',
                'pv-no-claim ',
                'pvc-1db9c833 default',
            ].join('\n'),
        })

        await cleanupOrphanQuestNamespaces()

        const deletes = commands.filter((c) => c.startsWith('kubectl delete pv'))
        expect(deletes.join(' ')).toContain('pv-local-quest-aaa11111')
        expect(deletes.join(' ')).toContain('pv-local-quest-bbb22222')
        expect(deletes.join(' ')).not.toContain('pv-other')
        expect(deletes.join(' ')).not.toContain('pv-no-claim')
        expect(deletes.join(' ')).not.toContain('pvc-1db9c833')
    })

    it('지울 PV가 없으면 delete pv를 실행하지 않는다', async () => {
        const commands = stubKubectl({ namespaces: 'default', pvs: 'pv-x default' })

        await cleanupOrphanQuestNamespaces()

        expect(commands.some((c) => c.startsWith('kubectl delete pv'))).toBe(false)
    })

    it('PV 조회가 실패해도 예외 없이 끝난다 (클러스터가 없는 환경)', async () => {
        stubKubectl({ namespaces: '', pvs: '', failPvList: true })

        await expect(cleanupOrphanQuestNamespaces()).resolves.toBeUndefined()
    })
})
