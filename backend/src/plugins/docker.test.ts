import { describe, it, expect, vi, beforeEach } from 'vitest'

const { listContainers, getContainer } = vi.hoisted(() => ({ listContainers: vi.fn(), getContainer: vi.fn() }))
vi.mock('dockerode', () => ({
    default: class {
        listContainers = listContainers
        getContainer = getContainer
    },
}))

import { cleanupOrphanContainers, cleanupRunningContainers } from './docker.js'

function fakeContainer(opts: { failStop?: boolean } = {}) {
    return {
        stop: vi.fn(async () => { if (opts.failStop) throw new Error('already stopped') }),
        remove: vi.fn(async () => {}),
    }
}

describe('컨테이너 정리 (기동·종료 시)', () => {
    beforeEach(() => {
        listContainers.mockReset()
        getContainer.mockReset()
    })

    it('기동 정리: etude=sandbox 라벨의 컨테이너를 중지된 것까지 모두 삭제한다', async () => {
        const a = fakeContainer()
        const b = fakeContainer({ failStop: true }) // 이미 중지된 컨테이너
        listContainers.mockResolvedValue([{ Id: 'a' }, { Id: 'b' }])
        getContainer.mockImplementation((id: string) => (id === 'a' ? a : b))

        await cleanupOrphanContainers()

        const opts = listContainers.mock.calls[0][0]
        expect(opts.all).toBe(true)
        expect(JSON.parse(opts.filters)).toEqual({ label: ['etude=sandbox'] })
        expect(a.remove).toHaveBeenCalled()
        expect(b.remove).toHaveBeenCalled() // stop 실패와 무관하게 삭제한다
    })

    it('종료 정리: 실행 중인 etude=sandbox 컨테이너를 중지·삭제하고 다른 라벨은 대상으로 삼지 않는다', async () => {
        const a = fakeContainer()
        listContainers.mockResolvedValue([{ Id: 'a' }])
        getContainer.mockReturnValue(a)

        await cleanupRunningContainers()

        const opts = listContainers.mock.calls[0][0]
        expect(opts.all).toBeUndefined()
        expect(JSON.parse(opts.filters)).toEqual({ label: ['etude=sandbox'] })
        expect(a.stop).toHaveBeenCalled()
        expect(a.remove).toHaveBeenCalled()
    })
})
