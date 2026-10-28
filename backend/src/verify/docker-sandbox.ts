import type Docker from 'dockerode'
import type { SandboxFactory, VerifySandbox } from './verify-quest.js'

const DEFAULT_EXEC_TIMEOUT_MS = 120_000

// 샌드박스 타입별 차이. 기본(plain)은 bash를 띄워 두고, dind 계열은 이미지의 기본 entrypoint(dockerd)를
// 그대로 쓰되 Privileged로 만들고 데몬이 응답할 때까지 기다린다 (실제 앱의 handleDockerTerminal과 같은 구성).
export interface SandboxProfile {
    privileged?: boolean
    readyCmd?: string[]
    readyTimeoutMs?: number
    readyIntervalMs?: number
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
            HostConfig: { Binds: config.binds ?? [], ...(profile.privileged ? { Privileged: true } : {}) },
            // dind 같은 서비스형 이미지는 기본 entrypoint가 본체라 Cmd를 덮어쓰지 않는다
            ...(profile.readyCmd ? {} : { Cmd: ['/bin/bash'], OpenStdin: true, Tty: true }),
        })
        const discard = async () => {
            await container.stop({ t: 0 }).catch(() => {})
            await container.remove({ force: true }).catch(() => {})
        }

        const sandbox: VerifySandbox = {
            // 실제 채점(execCheck)과 같은 방식: exec를 시작하고 끝날 때까지 inspect로 기다린다
            async exec(cmd, timeoutMs = DEFAULT_EXEC_TIMEOUT_MS) {
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
            },
            dispose: discard,
        }

        try {
            await container.start()
            if (profile.readyCmd) await waitUntilReady(sandbox, profile)
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
