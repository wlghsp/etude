import { describe, it, expect, vi, beforeEach } from 'vitest'

// 모듈 수준 pool을 테스트마다 새로 쓰려고 매번 모듈을 다시 읽는다. cleanup이 쓰는 외부 명령·파일 접근은 대체한다.
vi.mock('node:child_process', () => ({
    exec: (_cmd: string, cb: (err: Error | null, out?: unknown) => void) => cb(null, { stdout: '', stderr: '' }),
}))
vi.mock('node:fs/promises', () => ({ rm: vi.fn(async () => {}), readdir: vi.fn(async () => []) }))
vi.mock('node:fs', () => ({ mkdirSync: vi.fn() }))

const v = (id: string) => ({ id, kubeconfigPath: `/k/${id}-kubeconfig.yaml` })

async function load() {
    vi.resetModules()
    return await import('./vcluster-pool.js')
}

describe('initPool', () => {
    beforeEach(() => { vi.spyOn(console, 'error').mockImplementation(() => {}) })

    it('모두 성공하면 POOL_SIZE만큼 채운다', async () => {
        const { initPool, getPoolSize } = await load()
        let n = 0

        await initPool(async () => v(`pool-${++n}`))

        expect(getPoolSize()).toBe(2)
    })

    it('처음 동시 생성에서 하나가 실패해도(helm 내려받기 경쟁) 한 번 더 시도해 pool을 채우고 예외 없이 끝난다', async () => {
        const { initPool, getPoolSize } = await load()
        let calls = 0
        const create = vi.fn(async () => {
            calls++
            if (calls === 2) throw new Error('fork/exec /root/.vcluster/bin/helm: permission denied')
            return v(`pool-${calls}`)
        })

        await expect(initPool(create)).resolves.toBeUndefined()

        expect(create).toHaveBeenCalledTimes(3) // 동시 2개 + 실패분 재시도 1개
        expect(getPoolSize()).toBe(2)
    })

    it('계속 실패해도 예외를 던지지 않고(프로세스를 죽이지 않고) 실패를 로그로 남긴다', async () => {
        const { initPool, getPoolSize } = await load()
        const create = vi.fn(async () => { throw new Error('vcluster unavailable') })

        await expect(initPool(create)).resolves.toBeUndefined()

        expect(getPoolSize()).toBe(0) // pool이 비어도 assignFromPool이 요청 시 생성으로 대체한다
        expect(console.error).toHaveBeenCalled()
    })

    it('실패한 개수만큼만 재시도한다', async () => {
        const { initPool } = await load()
        let calls = 0
        const create = vi.fn(async () => { calls++; return v(`pool-${calls}`) })

        await initPool(create)

        expect(create).toHaveBeenCalledTimes(2) // 모두 성공하면 재시도 없음
    })
})
