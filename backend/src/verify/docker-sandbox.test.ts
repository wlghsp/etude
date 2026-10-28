import { describe, it, expect, vi } from 'vitest'
import { dockerSandboxFactory } from './docker-sandbox.js'

function fakeDocker(inspectResults: Array<{ Running: boolean; ExitCode: number }>) {
    const container = {
        start: vi.fn(async () => {}),
        stop: vi.fn(async () => {}),
        remove: vi.fn(async () => {}),
        exec: vi.fn(async () => {
            let i = 0
            return {
                start: vi.fn(async () => ({ resume() {} })),
                inspect: vi.fn(async () => inspectResults[Math.min(i++, inspectResults.length - 1)]),
            }
        }),
    }
    const docker = { createContainer: vi.fn(async () => container) }
    return { docker: docker as any, container }
}

describe('dockerSandboxFactory', () => {
    it('실제 앱과 같은 이미지·binds로 만들되 etude=verify 라벨을 붙인다 (기동 정리가 지우지 않게)', async () => {
        const { docker } = fakeDocker([{ Running: false, ExitCode: 0 }])

        await dockerSandboxFactory(docker, { image: 'etude-linux', binds: ['/a:/b'] })()

        const opts = docker.createContainer.mock.calls[0][0]
        expect(opts.Image).toBe('etude-linux')
        expect(opts.Labels).toEqual({ etude: 'verify' })
        expect(opts.HostConfig.Binds).toEqual(['/a:/b'])
    })

    it('실행이 끝나면 종료 코드를 돌려준다', async () => {
        const { docker } = fakeDocker([{ Running: true, ExitCode: 0 }, { Running: false, ExitCode: 3 }])
        const sandbox = await dockerSandboxFactory(docker, { image: 'x', binds: null })()

        expect(await sandbox.exec(['sh', '-c', 'false'])).toBe(3)
    })

    it('타임아웃 안에 끝나지 않으면 0이 아닌 값으로 실패 처리한다', async () => {
        const { docker } = fakeDocker([{ Running: true, ExitCode: 0 }])
        const sandbox = await dockerSandboxFactory(docker, { image: 'x', binds: null })()

        expect(await sandbox.exec(['sleep', '999'], 250)).not.toBe(0)
    })

    it('dispose는 중지가 실패해도 삭제한다', async () => {
        const { docker, container } = fakeDocker([{ Running: false, ExitCode: 0 }])
        container.stop.mockRejectedValue(new Error('not running'))
        const sandbox = await dockerSandboxFactory(docker, { image: 'x', binds: null })()

        await sandbox.dispose()

        expect(container.remove).toHaveBeenCalled()
    })
})
