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
