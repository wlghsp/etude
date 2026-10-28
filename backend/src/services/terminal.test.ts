import { describe, it, expect, beforeEach, vi } from 'vitest'
import { EventEmitter } from 'node:events'
import { PassThrough } from 'node:stream'

vi.mock('./sandbox.js', () => ({
    getSandboxConfig: vi.fn(async () => ({ image: 'ubuntu', binds: null, persistent: true })),
}))
vi.mock('./quest.js', () => ({ getSetupCmd: vi.fn(async () => null) }))
vi.mock('./vcluster-pool.js', () => ({
    assignFromPool: vi.fn(async () => ({ id: 'pool-1', kubeconfigPath: '/tmp/pool-1-kubeconfig.yaml' })),
    releaseVcluster: vi.fn(async () => {}),
}))

import { handleTerminal } from './terminal.js'
import { getSession } from './session-registry.js'
import { assignFromPool, releaseVcluster } from './vcluster-pool.js'

const info = { userId: 7, questId: 101, questSetId: 11, sandboxType: 'docker-persistent' }

function fakeSocket(readyState = 1) {
    const socket = new EventEmitter() as EventEmitter & { send: any; close: any; readyState: number }
    socket.readyState = readyState
    socket.send = vi.fn()
    socket.close = vi.fn()
    return socket
}

function fakeDocker(id = 'c1', opts: { failStart?: boolean, failStop?: boolean, startGate?: Promise<void>, createGate?: Promise<void> } = {}) {
    const stream = new PassThrough()
    const container = {
        id,
        start: vi.fn(async () => { await opts.startGate; if (opts.failStart) throw new Error('start failed') }),
        stop: vi.fn(async () => { if (opts.failStop) throw new Error('not running') }),
        remove: vi.fn(async () => {}),
        attach: vi.fn(async () => stream),
        exec: vi.fn(async () => ({
            start: vi.fn(async () => stream),
            inspect: vi.fn(async () => ({ Running: false })),
            resize: vi.fn(),
        })),
    }
    const docker = { createContainer: vi.fn(async () => { await opts.createGate; return container }) }
    return { docker: docker as any, container }
}

// 정리는 비동기(stop → remove)라 마이크로태스크가 비워질 때까지 기다린다
const flush = () => new Promise((r) => setTimeout(r, 0))

describe('handleTerminal', () => {
    beforeEach(() => vi.clearAllMocks())

    it('connected를 보내기 전에 세션 레지스트리에 등록한다', async () => {
        const socket = fakeSocket()
        const { docker } = fakeDocker('c-reg')
        let registeredAtConnected: unknown
        socket.send.mockImplementation((msg: unknown) => {
            if (typeof msg === 'string' && msg.includes('"connected"')) registeredAtConnected = getSession('c-reg')
        })

        await handleTerminal(socket as any, docker, info)

        expect(registeredAtConnected).toEqual({ userId: 7, questSetId: 11, sandboxType: 'docker-persistent' })
    })

    it('WebSocket이 닫히면 persistent 컨테이너도 중지·삭제하고 레지스트리에서 제거한다', async () => {
        const socket = fakeSocket()
        const { docker, container } = fakeDocker('c-close')
        await handleTerminal(socket as any, docker, info)

        socket.emit('close')
        await flush()

        expect(getSession('c-close')).toBeUndefined()
        expect(container.stop).toHaveBeenCalled()
        expect(container.remove).toHaveBeenCalled()
    })

    it('k8s-isolated는 close 시 vcluster도 반환한다', async () => {
        const socket = fakeSocket()
        const { docker, container } = fakeDocker('c-k8s')
        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s-isolated' })

        socket.emit('close')
        await flush()

        expect(releaseVcluster).toHaveBeenCalledWith({ id: 'pool-1', kubeconfigPath: '/tmp/pool-1-kubeconfig.yaml' })
        expect(container.remove).toHaveBeenCalled()
    })

    it('컨테이너 시작에 실패하면 등록하지 않고 만든 컨테이너를 정리한 뒤 소켓을 닫는다', async () => {
        const socket = fakeSocket()
        const { docker, container } = fakeDocker('c-fail', { failStart: true })

        await handleTerminal(socket as any, docker, info)
        await flush()

        expect(getSession('c-fail')).toBeUndefined()
        expect(container.remove).toHaveBeenCalled()
        expect(socket.close).toHaveBeenCalled()
        expect(socket.send).not.toHaveBeenCalled()
    })

    it('준비 도중 소켓이 이미 닫혔으면 등록하지 않고 컨테이너를 정리한다', async () => {
        const socket = fakeSocket(3) // CLOSED
        const { docker, container } = fakeDocker('c-late')

        await handleTerminal(socket as any, docker, info)
        await flush()

        expect(getSession('c-late')).toBeUndefined()
        expect(container.remove).toHaveBeenCalled()
        expect(socket.send).not.toHaveBeenCalled()
    })

    it('stop이 실패해도(이미 종료·시작 실패) 컨테이너를 삭제한다', async () => {
        const socket = fakeSocket()
        const { docker, container } = fakeDocker('c-stopfail', { failStop: true })
        await handleTerminal(socket as any, docker, info)

        socket.emit('close')
        await flush()

        expect(container.remove).toHaveBeenCalled()
    })

    it('준비가 끝나기 전에 소켓이 닫히면 그 시점에 만들어진 컨테이너를 바로 정리하고, 준비가 끝나도 등록하지 않는다', async () => {
        const socket = fakeSocket()
        let openGate!: () => void
        const startGate = new Promise<void>((r) => { openGate = r })
        const { docker, container } = fakeDocker('c-hang', { startGate })

        const pending = handleTerminal(socket as any, docker, info)
        await flush() // createContainer까지 진행되고 start에서 멈춘 상태

        socket.readyState = 3
        socket.emit('close')
        await flush()
        expect(container.remove).toHaveBeenCalled() // 준비가 끝나기를 기다리지 않는다

        openGate()
        await pending
        expect(getSession('c-hang')).toBeUndefined()
        expect(socket.send).not.toHaveBeenCalled()
    })

    it('컨테이너 생성 응답 전에 소켓이 닫히면, 늦게 만들어진 컨테이너를 바로 정리하고 준비를 중단한다', async () => {
        const socket = fakeSocket()
        let openGate!: () => void
        const createGate = new Promise<void>((r) => { openGate = r })
        const { docker, container } = fakeDocker('c-late-create', { createGate })

        const pending = handleTerminal(socket as any, docker, info)
        await flush()
        socket.readyState = 3
        socket.emit('close')
        await flush()

        openGate()
        await pending
        await flush()

        expect(container.remove).toHaveBeenCalled()
        expect(container.start).not.toHaveBeenCalled()
        expect(getSession('c-late-create')).toBeUndefined()
    })

    it('vcluster 할당 응답 전에 소켓이 닫히면, 늦게 할당된 vcluster를 반환하고 컨테이너를 만들지 않는다', async () => {
        const socket = fakeSocket()
        let openGate!: () => void
        const gate = new Promise<void>((r) => { openGate = r })
        vi.mocked(assignFromPool).mockImplementationOnce(async () => {
            await gate
            return { id: 'pool-late', kubeconfigPath: '/tmp/pool-late-kubeconfig.yaml' }
        })
        const { docker } = fakeDocker('c-late-pool')

        const pending = handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s-isolated' })
        await flush()
        socket.readyState = 3
        socket.emit('close')
        await flush()

        openGate()
        await pending

        expect(releaseVcluster).toHaveBeenCalledWith({ id: 'pool-late', kubeconfigPath: '/tmp/pool-late-kubeconfig.yaml' })
        expect(docker.createContainer).not.toHaveBeenCalled()
    })
})

describe('k8s 세션 정리', () => {
    // exec 호출과 완료, 컨테이너 중지·삭제의 순서를 한 로그에 기록한다. 각 exec는 두 번째 inspect에서 끝난다.
    function k8sDocker() {
        const events: string[] = []
        const container = {
            id: 'abcdef1234567890',
            start: vi.fn(async () => {}),
            attach: vi.fn(async () => new PassThrough()),
            stop: vi.fn(async () => { events.push('stop') }),
            remove: vi.fn(async () => { events.push('remove') }),
            exec: vi.fn(async (o: { Cmd: string[] }) => {
                const label = o.Cmd[0] === 'sh' ? 'pv-cleanup' : o.Cmd.slice(0, 3).join(' ')
                events.push(`start:${label}`)
                let polls = 0
                return {
                    start: vi.fn(async () => ({ resume() {} })),
                    inspect: vi.fn(async () => {
                        polls++
                        if (polls < 2) return { Running: true, ExitCode: 0 }
                        events.push(`done:${label}`)
                        return { Running: false, ExitCode: 0 }
                    }),
                    resize: vi.fn(),
                }
            }),
        }
        const docker = { createContainer: vi.fn(async () => container) } as any
        return { docker, container, events }
    }

    beforeEach(() => vi.clearAllMocks())

    it('종료 시 PV 삭제와 네임스페이스 삭제가 끝난 뒤에 컨테이너를 중지한다', async () => {
        const socket = fakeSocket()
        const { docker, events } = k8sDocker()
        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })
        events.length = 0 // 준비 단계(네임스페이스 생성)의 기록은 버린다

        socket.emit('close')
        await vi.waitFor(() => expect(events).toContain('remove'))

        expect(events).toEqual([
            'start:pv-cleanup', 'done:pv-cleanup',
            'start:kubectl delete namespace', 'done:kubectl delete namespace',
            'stop', 'remove',
        ])
    })

    it('PV 삭제가 실패해도 네임스페이스 삭제와 컨테이너 삭제는 진행한다', async () => {
        const socket = fakeSocket()
        const { docker, container, events } = k8sDocker()
        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })
        const realExec = container.exec.getMockImplementation()!
        container.exec.mockImplementation(async (o: { Cmd: string[] }) => {
            if (o.Cmd[0] === 'sh') throw new Error('exec failed')
            return realExec(o)
        })
        events.length = 0

        socket.emit('close')
        await vi.waitFor(() => expect(events).toContain('remove'))

        expect(events).toContain('done:kubectl delete namespace')
    })

    it('네임스페이스 삭제는 종료를 기다리지 않는다 (--wait=false)', async () => {
        const socket = fakeSocket()
        const { docker, container } = k8sDocker()
        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })

        socket.emit('close')
        await vi.waitFor(() => expect(container.remove).toHaveBeenCalled())

        const deleteNs = container.exec.mock.calls.map((c) => c[0].Cmd).find((c) => c[0] === 'kubectl' && c[1] === 'delete')
        expect(deleteNs).toEqual(['kubectl', 'delete', 'namespace', 'quest-abcdef12', '--ignore-not-found', '--wait=false'])
    })

    it('정리 명령이 끝나지 않아도 제한 시간(15초) 뒤에 다음 정리와 컨테이너 삭제를 진행한다', async () => {
        const socket = fakeSocket()
        const { docker, container, events } = k8sDocker()
        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })

        // 이후 모든 exec가 영원히 끝나지 않는다 (예: 클러스터에 접속할 수 없음)
        container.exec.mockImplementation(async (o: { Cmd: string[] }) => {
            events.push(`start:${o.Cmd[0] === 'sh' ? 'pv-cleanup' : 'delete-namespace'}`)
            return {
                start: vi.fn(async () => ({ resume() {} })),
                inspect: vi.fn(async () => ({ Running: true, ExitCode: 0 })),
                resize: vi.fn(),
            }
        })
        events.length = 0

        vi.useFakeTimers({ toFake: ['setTimeout', 'Date'] })
        try {
            socket.emit('close')
            await vi.advanceTimersByTimeAsync(14_000)
            expect(events).toEqual(['start:pv-cleanup']) // 아직 제한 시간 전이라 다음 단계로 넘어가지 않는다

            await vi.advanceTimersByTimeAsync(2_000) // PV 정리 15초 경과
            expect(events).toContain('start:delete-namespace')
            expect(container.remove).not.toHaveBeenCalled()

            await vi.advanceTimersByTimeAsync(15_000) // 네임스페이스 삭제도 15초 경과
            expect(container.remove).toHaveBeenCalled()
        } finally {
            vi.useRealTimers()
        }
    })
})
