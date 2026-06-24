import Docker from 'dockerode'
import type { WebSocket } from 'ws'
import { getSandboxConfig } from './sandbox.js'
import { getSetupCmd } from './quest.js'

export type SandboxType = 'linux' | 'linux-ssh' | 'docker'

export async function handleTerminal(
    socket: WebSocket, 
    docker: Docker, 
    sandboxType: SandboxType,
    questId: number | null
) {
    const { image, binds } = await getSandboxConfig(sandboxType)
    const container = await docker.createContainer({
        Image: image,
        HostConfig: { Binds: binds ?? [] },
        Cmd: sandboxType === 'docker' ?  ['/bin/sh'] : ['/bin/bash'],
        AttachStdin: true,
        AttachStdout: true,
        AttachStderr: true,
        OpenStdin: true,
        Tty: true,
    })

    const stream = await container.attach({
        stream: true,
        stdin: true,
        stdout: true,
        stderr: true,
        hijack: true,
    })

    await container.start()

    // setup_cmd 실행
    if (questId !== null) {
        const setupCmd = await getSetupCmd(questId)
        if (setupCmd) {
            const exec = await container.exec({
                Cmd: setupCmd, AttachStdout: false, AttachStderr: false
            })
            await exec.start({})
            while (true) {
                const info = await exec.inspect()
                if (!info.Running) break
                await new Promise((r) => setTimeout(r, 100))
            }
        }
    }


    // containerId를 브라우저로 전달 (채점에 필요)
    socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

    // 컨테이너 출력 → 브라우저
    stream.on('data', (chunk: Buffer) => {
        socket.send(chunk)
    })

    // 브라우저 입력 → 컨테이너
    socket.on('message', (msg: Buffer) => {
        stream.write(msg)
    })

    // 연결 종료 시 컨테이너 제거
    socket.on('close', () => {
        container.stop()
            .then(() => container.remove())
            .catch(() => {})
    })
}