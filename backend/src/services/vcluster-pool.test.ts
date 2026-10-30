import { describe, it, expect, vi, beforeEach } from 'vitest'

const { execMock, rmMock, readdirMock } = vi.hoisted(() => ({
    execMock: vi.fn(),
    rmMock: vi.fn(async () => {}),
    readdirMock: vi.fn(async () => [] as string[]),
}))
vi.mock('node:child_process', () => ({ exec: execMock }))
vi.mock('node:fs/promises', () => ({ rm: rmMock, readdir: readdirMock }))
vi.mock('node:fs', () => ({ mkdirSync: vi.fn() }))

import { releaseVcluster, cleanupOrphanVclusters } from './vcluster-pool.js'

describe('releaseVcluster', () => {
    beforeEach(() => {
        execMock.mockReset()
        rmMock.mockClear()
    })

    it('vcluster를 삭제하고 kubeconfig 파일도 지운다', async () => {
        execMock.mockImplementation((_cmd: string, cb: (err: Error | null, out?: unknown) => void) => cb(null, { stdout: '', stderr: '' }))

        await releaseVcluster({ id: 'pool-1', kubeconfigPath: '/home/u/.etude/vcluster-kubeconfigs/pool-1-kubeconfig.yaml' })

        expect(execMock.mock.calls[0][0]).toContain('vcluster delete pool-1')
        expect(rmMock).toHaveBeenCalledWith('/home/u/.etude/vcluster-kubeconfigs/pool-1-kubeconfig.yaml', { force: true })
    })

    it('vcluster 삭제 명령이 실패해도 kubeconfig 파일 삭제를 시도한다', async () => {
        execMock.mockImplementation((_cmd: string, cb: (err: Error | null) => void) => cb(new Error('vcluster failed')))

        await releaseVcluster({ id: 'pool-2', kubeconfigPath: '/k/pool-2-kubeconfig.yaml' })

        expect(rmMock).toHaveBeenCalledWith('/k/pool-2-kubeconfig.yaml', { force: true })
    })
})

describe('vcluster 가 이미 없어도 네임스페이스는 지운다', () => {
    beforeEach(() => {
        execMock.mockReset()
        rmMock.mockClear()
        readdirMock.mockReset()
        readdirMock.mockResolvedValue([])
    })

    // vcluster 본체(Helm 릴리스)는 없는데 네임스페이스와 PVC 만 남으면 `vcluster delete` 는 "couldn't find" 로 아무것도 지우지 못한다
    it('기동 시 정리: vcluster delete 가 실패해도 남은 vcluster-* 네임스페이스를 kubectl 로 지운다', async () => {
        execMock.mockImplementation((cmd: string, cb: (err: Error | null, out?: unknown) => void) => {
            if (cmd.startsWith('kubectl get ns')) cb(null, { stdout: 'default vcluster-pool-aaa11111 kube-system', stderr: '' })
            else if (cmd.startsWith('vcluster delete')) cb(new Error("couldn't find vcluster"))
            else cb(null, { stdout: '', stderr: '' })
        })

        await cleanupOrphanVclusters()

        const cmds: string[] = execMock.mock.calls.map((c: any[]) => c[0])
        expect(cmds.some((c) => c.startsWith('kubectl delete namespace vcluster-pool-aaa11111') && c.includes('--ignore-not-found'))).toBe(true)
        expect(cmds.some((c) => c.includes('namespace default') || c.includes('namespace kube-system'))).toBe(false)
    })

    it('사용 후 반납: vcluster delete 뒤에 네임스페이스도 지운다', async () => {
        execMock.mockImplementation((_cmd: string, cb: (err: Error | null, out?: unknown) => void) => cb(null, { stdout: '', stderr: '' }))

        await releaseVcluster({ id: 'pool-bbb22222', kubeconfigPath: '/k/pool-bbb22222-kubeconfig.yaml' })

        const cmds: string[] = execMock.mock.calls.map((c: any[]) => c[0])
        expect(cmds.findIndex((c) => c.startsWith('vcluster delete pool-bbb22222'))).toBeGreaterThanOrEqual(0)
        expect(cmds.some((c) => c.startsWith('kubectl delete namespace vcluster-pool-bbb22222'))).toBe(true)
    })

    it('네임스페이스 삭제가 실패하면 로그를 남기고 예외는 던지지 않는다', async () => {
        const err = vi.spyOn(console, 'error').mockImplementation(() => {})
        execMock.mockImplementation((cmd: string, cb: (err: Error | null, out?: unknown) => void) => {
            if (cmd.startsWith('kubectl delete namespace')) cb(new Error('forbidden'))
            else cb(null, { stdout: '', stderr: '' })
        })

        await expect(releaseVcluster({ id: 'pool-ccc33333', kubeconfigPath: '/k/x.yaml' })).resolves.toBeUndefined()

        expect(err).toHaveBeenCalled()
        err.mockRestore()
    })
})

describe('cleanupOrphanVclusters', () => {
    beforeEach(() => {
        execMock.mockReset()
        rmMock.mockClear()
        readdirMock.mockReset()
        execMock.mockImplementation((_cmd: string, cb: (err: Error | null, out?: unknown) => void) => cb(null, { stdout: '', stderr: '' }))
    })

    it('이전 프로세스가 남긴 pool-*-kubeconfig 파일을 지우고 다른 파일은 건드리지 않는다', async () => {
        readdirMock.mockResolvedValue(['pool-abc12345-kubeconfig.yaml', 'pool-def67890-kubeconfig.yaml', 'notes.txt', 'other-kubeconfig.yaml'])

        await cleanupOrphanVclusters()

        const removed = rmMock.mock.calls.map((c: any[]) => String(c[0]))
        expect(removed).toHaveLength(2)
        expect(removed[0]).toMatch(/\.etude\/vcluster-kubeconfigs\/pool-abc12345-kubeconfig\.yaml$/)
        expect(removed[1]).toMatch(/pool-def67890-kubeconfig\.yaml$/)
    })

    it('kubeconfig 디렉터리가 없어도 실패하지 않는다', async () => {
        readdirMock.mockRejectedValue(Object.assign(new Error('ENOENT'), { code: 'ENOENT' }))

        await expect(cleanupOrphanVclusters()).resolves.toBeUndefined()
        expect(rmMock).not.toHaveBeenCalled()
    })

    it('ENOENT가 아닌 조회 오류는 로그를 남기고 실패하지 않는다', async () => {
        const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
        readdirMock.mockRejectedValue(Object.assign(new Error('EACCES'), { code: 'EACCES' }))

        await expect(cleanupOrphanVclusters()).resolves.toBeUndefined()

        expect(errorSpy).toHaveBeenCalledTimes(1)
        errorSpy.mockRestore()
    })

    it('파일 삭제가 실패하면 경로와 함께 로그를 남기고 나머지 파일은 계속 지운다', async () => {
        const errorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
        readdirMock.mockResolvedValue(['pool-aaaa1111-kubeconfig.yaml', 'pool-bbbb2222-kubeconfig.yaml'])
        rmMock.mockRejectedValueOnce(new Error('EPERM'))

        await cleanupOrphanVclusters()

        expect(rmMock).toHaveBeenCalledTimes(2)
        expect(errorSpy).toHaveBeenCalledTimes(1)
        expect(String(errorSpy.mock.calls[0][0])).toContain('pool-aaaa1111-kubeconfig.yaml')
        errorSpy.mockRestore()
    })
})
