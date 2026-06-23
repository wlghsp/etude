import Docker from 'dockerode'
import type { WebSocket } from 'ws'


const docker = new Docker()

export async function handleTerminal(socket: WebSocket, docker: Docker) {
    const container = await docker.createContainer({
        Image: 'ubuntu',
        Cmd: ['/bin/bash'],
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