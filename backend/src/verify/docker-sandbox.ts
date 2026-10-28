import type Docker from 'dockerode'
import type { SandboxFactory } from './verify-quest.js'

const DEFAULT_EXEC_TIMEOUT_MS = 120_000
const TIMEOUT_EXIT_CODE = -1

// 검증용 컨테이너를 만든다. 이미지·binds는 서비스의 샌드박스 설정을 그대로 받는다.
// 라벨은 etude=verify: 실행 중인 backend의 기동·종료 정리(etude=sandbox)가 검증 컨테이너를 지우지 않게 한다.
export function dockerSandboxFactory(docker: Docker, config: { image: string; binds: string[] | null }): SandboxFactory {
    return async () => {
        const container = await docker.createContainer({
            Image: config.image,
            Labels: { etude: 'verify' },
            HostConfig: { Binds: config.binds ?? [] },
            Cmd: ['/bin/bash'],
            OpenStdin: true,
            Tty: true,
        })
        await container.start().catch(async (err) => {
            await container.remove({ force: true }).catch(() => {})
            throw err
        })

        return {
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
            async dispose() {
                await container.stop({ t: 0 }).catch(() => {})
                await container.remove({ force: true }).catch(() => {})
            },
        }
    }
}
