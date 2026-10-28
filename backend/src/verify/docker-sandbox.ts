import type Docker from 'dockerode'
import type { SandboxFactory, VerifySandbox } from './verify-quest.js'
import { createSessionAccess, destroySessionAccess } from '../services/k8s-session.js'
import { installKubeconfig } from '../services/container-kubeconfig.js'

const DEFAULT_EXEC_TIMEOUT_MS = 120_000

// 샌드박스 타입별 차이. 기본(plain)은 bash를 띄워 두고, dind 계열은 이미지의 기본 entrypoint(dockerd)를
// 그대로 쓰되 Privileged로 만들고 데몬이 응답할 때까지 기다린다 (실제 앱의 handleDockerTerminal과 같은 구성).
export interface SandboxProfile {
    privileged?: boolean
    extraBinds?: string[]
    cgroupnsHost?: boolean
    // k8s: 컨테이너가 붙을 네트워크와, 컨테이너마다 만들 네임스페이스의 접두어.
    // 앱(handleK8sTerminal)과 같이 관리자 kubeconfig는 주지 않고 세션 전용 제한 권한(k8s-session.ts)으로 실행한다.
    // 앱은 quest-<컨테이너ID 앞 8자>를 쓰지만, 앱 기동 시 quest-* 정리와 겹치지 않게 접두어를 따로 둔다.
    networkMode?: string
    namespacePrefix?: string
    readyCmd?: string[]
    readyTimeoutMs?: number
    readyIntervalMs?: number
}

// 실제 앱의 handleSystemdTerminal과 같은 구성. systemd가 부팅을 마칠 때까지(running/degraded) 기다린다.
export const SYSTEMD_PROFILE: SandboxProfile = {
    privileged: true,
    extraBinds: ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
    cgroupnsHost: true,
    readyCmd: ['sh', '-c', 'systemctl is-system-running 2>/dev/null | grep -qE "running|degraded"'],
    readyTimeoutMs: 90_000,
    readyIntervalMs: 500,
}

export function k8sProfile(networkMode: string): SandboxProfile {
    return { networkMode, namespacePrefix: 'verify' }
}

export const DIND_PROFILE: SandboxProfile = { privileged: true, readyCmd: ['docker', 'info'], readyTimeoutMs: 90_000, readyIntervalMs: 500 }
const TIMEOUT_EXIT_CODE = -1

// 검증용 컨테이너를 만든다. 이미지·binds는 서비스의 샌드박스 설정을 그대로 받는다.
// 라벨은 etude=verify: 실행 중인 backend의 기동·종료 정리(etude=sandbox)가 검증 컨테이너를 지우지 않게 한다.
export function dockerSandboxFactory(docker: Docker, config: { image: string; binds: string[] | null }, profile: SandboxProfile = {}): SandboxFactory {
    return async () => {
        const container = await docker.createContainer({
            Image: config.image,
            Labels: { etude: 'verify' },
            HostConfig: {
                // k8s는 DB의 binds(관리자 kubeconfig 마운트)를 무시한다. 앱과 같다.
                Binds: profile.namespacePrefix ? [] : [...(config.binds ?? []), ...(profile.extraBinds ?? [])],
                ...(profile.privileged ? { Privileged: true } : {}),
                ...(profile.cgroupnsHost ? { CgroupnsMode: 'host' } : {}),
                ...(profile.networkMode ? { NetworkMode: profile.networkMode } : {}),
            } as Docker.ContainerCreateOptions['HostConfig'],
            // dind 같은 서비스형 이미지는 기본 entrypoint가 본체라 Cmd를 덮어쓰지 않는다
            ...(profile.readyCmd ? {} : { Cmd: ['/bin/bash'], OpenStdin: true, Tty: true }),
        })
        // 네임스페이스와 권한은 컨테이너가 시작된 뒤에 만든다. 이름은 컨테이너 ID에서 정한다.
        const ns = profile.namespacePrefix ? `${profile.namespacePrefix}-${container.id.slice(0, 8)}` : null
        let accessStarted = false
        const discard = async () => {
            // 권한(ClusterRoleBinding)과 네임스페이스를 먼저 지운다. 일부만 만들어진 상태에서도 안전하다.
            if (ns && accessStarted) await destroySessionAccess(ns).catch(() => {})
            await container.stop({ t: 0 }).catch(() => {})
            await container.remove({ force: true }).catch(() => {})
        }

        // 실제 채점(execCheck)과 같은 방식: exec를 시작하고 끝날 때까지 inspect로 기다린다
        const rawExec = async (cmd: string[], timeoutMs: number): Promise<number> => {
            const exec = await container.exec({ Cmd: cmd })
            const stream: any = await exec.start({})
            stream?.resume?.()

            const startedAt = Date.now()
            while (true) {
                const info = await exec.inspect()
                if (!info.Running) return info.ExitCode ?? TIMEOUT_EXIT_CODE
                if (Date.now() - startedAt > timeoutMs) return TIMEOUT_EXIT_CODE
                await new Promise((r) => setTimeout(r, 100))
            }
        }

        const sandbox: VerifySandbox = {
            // 앱이 setup·채점에서 $NS를 치환하는 것과 같다. 정답 명령도 같은 환경에서 읽히도록 함께 치환한다.
            exec: (cmd, timeoutMs = DEFAULT_EXEC_TIMEOUT_MS) =>
                rawExec(ns ? cmd.map((a) => a.replace(/\$NS/g, ns)) : cmd, timeoutMs),
            dispose: discard,
        }
        try {
            await container.start()
            if (profile.readyCmd) await waitUntilReady(sandbox, profile)
            if (ns) {
                accessStarted = true // 중간에 실패해도 정리 대상이 되도록 먼저 표시한다
                await installKubeconfig(container, await createSessionAccess(ns))
            }
        } catch (err) {
            await discard()
            throw err
        }
        return sandbox
    }
}

async function waitUntilReady(sandbox: { exec: (cmd: string[], timeoutMs?: number) => Promise<number> }, profile: SandboxProfile) {
    const timeoutMs = profile.readyTimeoutMs ?? 60_000
    const intervalMs = profile.readyIntervalMs ?? 500
    const startedAt = Date.now()
    while (Date.now() - startedAt < timeoutMs) {
        if ((await sandbox.exec(profile.readyCmd!, 10_000)) === 0) return
        await new Promise((r) => setTimeout(r, intervalMs))
    }
    throw new Error(`샌드박스 준비를 기다리다 시간이 초과됐다 (${profile.readyCmd!.join(' ')})`)
}
