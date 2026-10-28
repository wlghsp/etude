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
