import Docker from 'dockerode'
import type { WebSocket } from 'ws'
import { getSandboxConfig } from './sandbox.js'
import { getSetupCmd } from './quest.js'

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

async function runSetupCmd(
  container: Docker.Container, 
  questId: number | null,
  containerId?: string
): Promise<void> {
    if (questId === null) return
    let setupCmd = await getSetupCmd(questId)
    if (!setupCmd) return

    if (containerId) {
      const ns = `quest-${containerId.slice(0, 8)}`
      setupCmd = setupCmd.map((s: string) => s.replace(/\$NS/g, ns))
    }

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
    sandboxType: string,
    questId: number | null,
    existingContainerId: string | null,
) {
    const config = await getSandboxConfig(sandboxType)

    if (sandboxType === 'docker' || sandboxType === 'docker-persistent') {
        await handleDockerTerminal(socket, docker, config, questId, existingContainerId)
    } else if (sandboxType === 'k8s') {
        await handleK8sTerminal(socket, docker, config, questId)
    } else {
        await handleDefaultTerminal(socket, docker, config, questId)
    }
}

async function handleDefaultTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    Labels: { etude: 'sandbox'},
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

async function handleDockerTerminal(
  socket: WebSocket, 
  docker: Docker, 
  config: { image: string, binds: string[] | null, persistent: boolean }, 
  questId: number | null,
  existingContainerId: string | null
) {
  let container: Docker.Container

  if (existingContainerId) {
    // 기존 컨테이너 재사용
    container = docker.getContainer(existingContainerId) 
  } else {
    // 새 컨테이너 생성
    container = await docker.createContainer({
      Image: config.image, 
      Labels: { etude: 'sandbox'},
      OpenStdin: false, Tty: false,
      AttachStdin: false, AttachStdout: false, AttachStderr: false,
      HostConfig: { Binds: config.binds ?? [], Privileged: true },
    })
    await container.start()
    await waitForDocker(container)
  }

  await runSetupCmd(container, questId)

  const exec = await container.exec({
    Cmd: ['/bin/sh'],
    AttachStdin: true, AttachStdout: true, AttachStderr: true, Tty: true,
  })
  const stream = await exec.start({ hijack: true, stdin: true, Tty: true })

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', () => {
    if (!config.persistent) {
      container.stop().then(() => container.remove()).catch(() => {})
    }
  })
}

async function handleK8sTerminal(socket: WebSocket, docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null) {
  const container = await docker.createContainer({
    Image: config.image,
    Labels: { etude: 'sandbox'},
    HostConfig: {
      Binds: config.binds ?? [],
      NetworkMode: process.env.K3D_NETWORK ?? 'k3d-etude',
    },
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

  // namespace 생성
  const ns = `quest-${container.id.slice(0, 8)}`
  const nsExec = await container.exec({
    Cmd: ['kubectl', 'create', 'namespace', ns],
    AttachStdout: false,
    AttachStderr: false,
  })
  await nsExec.start({})
  await runSetupCmd(container, questId, container.id)

  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => stream.write(msg))
  socket.on('close', async () => {
    // namespace 삭제 후 컨테이너 제거
    const delExec = await container.exec({
      Cmd: ['kubectl', 'delete', 'namespace', ns, '--ignore-not-found'],
      AttachStdout: false,
      AttachStderr: false,
    })
    await delExec.start({})
    container.stop().then(() => container.remove()).catch(() => {})
  })

}