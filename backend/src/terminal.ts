import Docker from 'dockerode'
import type { WebSocket } from 'ws'
import { getSandboxConfig } from './sandbox.js'
import { getSetupCmd } from './quest.js'

export type SandboxType = 'linux' | 'linux-ssh' | 'docker'

async function waitForDocker(container: Docker.Container): Promise<void> {
    const exec = await container.exec({
        Cmd: ['sh', '-c', 'until test -S /var/run/docker.sock; do sleep 0.2; done'],
        AttachStdout: false,
        AttachStderr: false,
    })
    await exec.start({})
    await new Promise<void>((resolve) => {
        const poll = setInterval(async () => {
            const info = await exec.inspect()
            if (!info.Running) {
                clearInterval(poll)
                resolve()
            }
        }, 300)
    })
}

async function runSetupCmd(container: Docker.Container, questId: number | null): Promise<void> {
    if (questId === null) return
    const setupCmd = await getSetupCmd(questId)
    if (!setupCmd) return
    const exec = await container.exec({ Cmd: setupCmd, AttachStdout: false, AttachStderr: false })
    await exec.start({})
    while (true) {
        const info = await exec.inspect()
        if (!info.Running) break
        await new Promise((r) => setTimeout(r, 100))
    }
}

export async function handleTerminal(
    socket: WebSocket,
    docker: Docker,
    sandboxType: SandboxType,
    questId: number | null
) {
    const config = await getSandboxConfig(sandboxType)

    if (sandboxType == 'docker') {
        await handleDockerTerminal(socket, docker, config, questId)
    } else {
        await handleDefaultTerminal(socket, docker, config, questId)
    }
}

async function handleDefaultTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    HostConfig: { Binds: config.binds ?? [] },
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
  await runSetupCmd(container, questId)

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    container.stop().then(() => container.remove()).catch(() => {})
  })
}

async function handleDockerTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    AttachStdin: false,
    AttachStdout: false,
    AttachStderr: false,
    OpenStdin: false,
    Tty: false,
    HostConfig: {
      Binds: config.binds ?? [],
      Privileged: true,
    },
  })

  await container.start()
  await waitForDocker(container)
  await runSetupCmd(container, questId)

  const exec = await container.exec({
    Cmd: ['/bin/sh'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    Tty: true,
  })
  const stream = await exec.start({ hijack: true, stdin: true, Tty: true })

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    container.stop().then(() => container.remove()).catch(() => {})
  })
}