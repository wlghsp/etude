import { describe, it, expect, vi, beforeEach } from 'vitest'

const { execMock, rmMock } = vi.hoisted(() => ({ execMock: vi.fn(), rmMock: vi.fn(async () => {}) }))
vi.mock('node:child_process', () => ({ exec: execMock }))
vi.mock('node:fs/promises', () => ({ rm: rmMock }))
vi.mock('node:fs', () => ({ mkdirSync: vi.fn() }))

import { releaseVcluster } from './vcluster-pool.js'

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
