import { describe, it, expect, vi, beforeEach } from 'vitest'

const { execMock } = vi.hoisted(() => ({ execMock: vi.fn() }))
vi.mock('node:child_process', () => ({ exec: execMock }))
vi.mock('node:fs/promises', () => ({ rm: vi.fn(async () => {}), readdir: vi.fn(async () => []) }))
vi.mock('node:fs', () => ({ mkdirSync: vi.fn() }))

type Cb = (err: Error | null, out?: unknown) => void

// 명령에 이 문자열이 들어 있으면 실패시키고, 나머지는 성공시킨다
function failOn(fragment: string) {
    execMock.mockImplementation((cmd: string, cb: Cb) => {
        if (cmd.includes(fragment)) cb(new Error(`failed: ${fragment}`))
        else cb(null, { stdout: '', stderr: '' })
    })
}

async function load() {
    vi.resetModules()
    return await import('./vcluster-pool.js')
}

describe('createVcluster 실패 처리', () => {
    beforeEach(() => {
        execMock.mockReset()
        delete process.env.VCLUSTER_READY_TIMEOUT_SEC
    })

    it('준비 대기가 실패하면 만들다 만 vcluster 를 지우고 오류를 그대로 던진다', async () => {
        failOn('condition=ready')
        const { createVcluster } = await load()

        await expect(createVcluster()).rejects.toThrow('condition=ready')

        const cmds: string[] = execMock.mock.calls.map((c) => c[0])
        const created = cmds.find((c) => c.startsWith('vcluster create '))!.match(/vcluster create (pool-[0-9a-f]+)/)![1]
        expect(cmds.some((c) => c.startsWith(`vcluster delete ${created} `))).toBe(true)
    })

    it('정리 명령이 실패해도 원래 오류를 던진다', async () => {
        execMock.mockImplementation((cmd: string, cb: Cb) => {
            if (cmd.includes('condition=ready')) cb(new Error('ready timeout'))
            else if (cmd.startsWith('vcluster delete')) cb(new Error('delete failed'))
            else cb(null, { stdout: '', stderr: '' })
        })
        const { createVcluster } = await load()

        await expect(createVcluster()).rejects.toThrow('ready timeout')
    })

    it('준비 대기 시간은 VCLUSTER_READY_TIMEOUT_SEC 로 바꿀 수 있고 기본은 60초다', async () => {
        failOn('condition=ready')
        let { createVcluster } = await load()
        await expect(createVcluster()).rejects.toThrow()
        expect(execMock.mock.calls.map((c) => c[0]).find((c: string) => c.includes('condition=ready'))).toContain('--timeout=60s')

        execMock.mockReset()
        process.env.VCLUSTER_READY_TIMEOUT_SEC = '180'
        failOn('condition=ready')
        ;({ createVcluster } = await load())
        await expect(createVcluster()).rejects.toThrow()
        expect(execMock.mock.calls.map((c) => c[0]).find((c: string) => c.includes('condition=ready'))).toContain('--timeout=180s')
    })
})
