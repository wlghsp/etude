import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { EventEmitter } from 'node:events'
import { PassThrough } from 'node:stream'

vi.mock('./sandbox.js', () => ({
    getSandboxConfig: vi.fn(async () => ({ image: 'ubuntu', binds: null, persistent: true })),
}))
vi.mock('./quest.js', () => ({ getSetupCmd: vi.fn(async () => null) }))
vi.mock('./k8s-session.js', () => ({
    createSessionAccess: vi.fn(async () => 'apiVersion: v1\nkind: Config\n# limited-learner-kubeconfig\n'),
    destroySessionAccess: vi.fn(async () => {}),
}))
vi.mock('./vcluster-pool.js', () => ({
    assignFromPool: vi.fn(async () => ({ id: 'pool-1', kubeconfigPath: '/tmp/pool-1-kubeconfig.yaml' })),
    releaseVcluster: vi.fn(async () => {}),
}))

import { handleTerminal } from './terminal.js'
import { getSession } from './session-registry.js'
import { getSandboxConfig } from './sandbox.js'
import { sandboxLimits } from './sandbox-limits.js'
import { createSessionAccess, destroySessionAccess } from './k8s-session.js'
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

describe('k8s 세션 (제한 권한)', () => {
    function k8sDocker() {
        const events: string[] = []
        const execs: Array<{ Cmd: string[]; Env?: string[] }> = []
        const container = {
            id: 'abcdef1234567890',
            start: vi.fn(async () => { events.push('start') }),
            attach: vi.fn(async () => new PassThrough()),
            stop: vi.fn(async () => { events.push('stop') }),
            remove: vi.fn(async () => { events.push('remove') }),
            exec: vi.fn(async (o: { Cmd: string[]; Env?: string[] }) => {
                execs.push(o)
                events.push(`exec:${o.Cmd[0]}`)
                return {
                    start: vi.fn(async () => ({ resume() {} })),
                    inspect: vi.fn(async () => ({ Running: false, ExitCode: 0 })),
                    resize: vi.fn(),
                }
            }),
        }
        const docker = { createContainer: vi.fn(async () => container) } as any
        return { docker, container, events, execs }
    }

    // 세션 레지스트리는 모듈 전역이라, 테스트가 끝날 때 열어 둔 소켓을 닫아 등록을 해제한다 (같은 컨테이너 ID를 재사용하므로)
    const sockets: Array<ReturnType<typeof fakeSocket>> = []
    const openSocket = () => { const s = fakeSocket(); sockets.push(s); return s }
    afterEach(() => { sockets.splice(0).forEach((s) => s.emit('close')) })

    beforeEach(() => {
        vi.clearAllMocks()
        vi.mocked(getSandboxConfig).mockResolvedValue({ image: 'etude-k8s', binds: ['/home/u/.kube/config-etude:/root/.kube/config:ro'], persistent: false })
    })

    it('DB의 binds에 관리자 kubeconfig 마운트가 있어도 무시하고 바인드 없이 컨테이너를 만든다', async () => {
        const { docker } = k8sDocker()

        await handleTerminal(openSocket() as any, docker, { ...info, sandboxType: 'k8s' })

        const opts = docker.createContainer.mock.calls[0][0]
        expect(opts.HostConfig.Binds ?? []).toEqual([])
        expect(JSON.stringify(opts)).not.toContain('.kube')
    })

    it('컨테이너 ID로 정한 네임스페이스의 제한 권한을 만들고 kubeconfig를 컨테이너에 주입한 뒤에 connected를 보낸다', async () => {
        const { docker, execs } = k8sDocker()
        const socket = openSocket()
        const order: string[] = []
        vi.mocked(createSessionAccess).mockImplementationOnce(async () => { order.push('access'); return 'LIMITED-KUBECONFIG' })
        socket.send.mockImplementation((m: string) => order.push(`send:${JSON.parse(m).type}`))

        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })

        expect(createSessionAccess).toHaveBeenCalledWith('quest-abcdef12')
        const install = execs.find((e) => e.Env?.some((v) => v.startsWith('KUBECONFIG_B64=')))
        expect(install).toBeDefined()
        const b64 = install!.Env!.find((v) => v.startsWith('KUBECONFIG_B64='))!.slice('KUBECONFIG_B64='.length)
        expect(Buffer.from(b64, 'base64').toString()).toBe('LIMITED-KUBECONFIG')
        expect(install!.Cmd.join(' ')).toContain('/root/.kube/config')
        expect(order).toEqual(['access', 'send:connected'])
    })

    it('세션 종료 시 제한 권한과 네임스페이스를 지운 뒤 컨테이너를 삭제한다', async () => {
        const { docker, events } = k8sDocker()
        const socket = openSocket()
        vi.mocked(destroySessionAccess).mockImplementationOnce(async () => { events.push('destroy-access') })
        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })
        events.length = 0

        socket.emit('close')
        await vi.waitFor(() => expect(events).toContain('remove'))

        expect(destroySessionAccess).toHaveBeenCalledWith('quest-abcdef12')
        expect(events.indexOf('destroy-access')).toBeLessThan(events.indexOf('stop'))
    })

    it('정리 중 권한 삭제가 실패해도 컨테이너는 삭제한다', async () => {
        const { docker, container } = k8sDocker()
        const socket = openSocket()
        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })
        vi.mocked(destroySessionAccess).mockRejectedValueOnce(new Error('cluster unreachable'))

        socket.emit('close')
        await vi.waitFor(() => expect(container.remove).toHaveBeenCalled())
    })

    it('제한 권한을 만들지 못하면 연결하지 않고 만든 자원을 정리한 뒤 소켓을 닫는다', async () => {
        const { docker, container } = k8sDocker()
        const socket = openSocket()
        vi.mocked(createSessionAccess).mockRejectedValueOnce(new Error('token failed'))

        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })

        expect(socket.send).not.toHaveBeenCalled()
        expect(socket.close).toHaveBeenCalled()
        expect(destroySessionAccess).toHaveBeenCalledWith('quest-abcdef12') // 일부만 만들어졌을 수 있어 정리한다
        expect(container.remove).toHaveBeenCalled()
    })

    it('kubeconfig 주입 명령이 실패하면(종료 코드 비정상) 연결하지 않는다', async () => {
        const { docker, container } = k8sDocker()
        const socket = openSocket()
        container.exec.mockImplementation(async () => ({
            start: vi.fn(async () => ({ resume() {} })),
            inspect: vi.fn(async () => ({ Running: false, ExitCode: 1 })),
            resize: vi.fn(),
        }) as any)

        await handleTerminal(socket as any, docker, { ...info, sandboxType: 'k8s' })

        expect(socket.send).not.toHaveBeenCalled()
        expect(socket.close).toHaveBeenCalled()
    })
})

describe('샌드박스 자원 상한', () => {
    const limitsOf = (docker: any) => docker.createContainer.mock.calls[0][0].HostConfig
    const sockets: Array<ReturnType<typeof fakeSocket>> = []
    afterEach(() => { sockets.splice(0).forEach((s) => s.emit('close')) })

    beforeEach(() => {
        vi.clearAllMocks()
        vi.mocked(getSandboxConfig).mockResolvedValue({ image: 'ubuntu', binds: null, persistent: false })
    })

    async function connect(sandboxType: string) {
        const socket = fakeSocket()
        sockets.push(socket)
        const { docker } = fakeDocker(`limit-${sandboxType}`)
        await handleTerminal(socket as any, docker, { ...info, sandboxType })
        return docker
    }

    it('기본 샌드박스(linux)에 메모리·CPU·프로세스 상한을 건다', async () => {
        const host = limitsOf(await connect('linux'))

        expect(host.Memory).toBeGreaterThan(0)
        expect(host.NanoCpus).toBeGreaterThan(0)
        expect(host.PidsLimit).toBeGreaterThan(0)
        expect(host.MemorySwap).toBe(host.Memory)
    })

    it('docker, docker-persistent는 dind 상한을 건다 (Privileged여도 자원은 제한한다)', async () => {
        for (const type of ['docker', 'docker-persistent']) {
            vi.clearAllMocks()
            const host = limitsOf(await connect(type))

            expect(host.Privileged).toBe(true)
            expect(host.Memory).toBe(sandboxLimits('dind').Memory)
            expect(host.PidsLimit).toBe(sandboxLimits('dind').PidsLimit)
        }
    })

    it('linux-systemd는 systemd 상한을 건다', async () => {
        const host = limitsOf(await connect('linux-systemd'))

        expect(host.Memory).toBe(sandboxLimits('systemd').Memory)
        expect(host.PidsLimit).toBe(sandboxLimits('systemd').PidsLimit)
    })

    it('SANDBOX_RUNTIME이 있으면 docker·systemd 컨테이너를 Privileged 없이 그 런타임으로 만든다', async () => {
        vi.stubEnv('SANDBOX_RUNTIME', 'sysbox-runc')
        try {
            for (const type of ['docker', 'docker-persistent', 'linux-systemd']) {
                vi.clearAllMocks()
                const host = limitsOf(await connect(type))

                expect(host.Runtime).toBe('sysbox-runc')
                expect(host.Privileged).toBeUndefined()
                expect(host.CgroupnsMode).toBeUndefined()
                expect(host.Binds).not.toContain('/sys/fs/cgroup:/sys/fs/cgroup:rw')
            }
        } finally {
            vi.unstubAllEnvs()
        }
    })

    it('k8s 학습자 컨테이너에는 k8s 상한을 건다 (helm이 기본 상한에서는 메모리 부족으로 죽는다)', async () => {
        const host = limitsOf(await connect('k8s'))

        expect(host.Memory).toBe(sandboxLimits('k8s').Memory)
    })
})
