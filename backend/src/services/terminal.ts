import Docker from 'dockerode'
import type { WebSocket } from 'ws'
import { getSandboxConfig } from './sandbox.js'
import { getSetupCmd } from './quest.js'
import { assignFromPool, releaseVcluster } from './vcluster-pool.js'
import { registerSession, removeSession } from './session-registry.js'
import { createSessionAccess, destroySessionAccess } from './k8s-session.js'
import { installKubeconfig } from './container-kubeconfig.js'
import type { TerminalTicketInfo } from './terminal-ticket.js'

async function waitForDocker(container: Docker.Container): Promise<void> {
    const exec = await container.exec({
        Cmd: ['sh', '-c', 'until test -S /var/run/docker.sock; do sleep 0.2; done'],
        AttachStdout: false,
        AttachStderr: false,
    })
    await exec.start({})
    await new Promise<void>((resolve, reject) => {
        const poll = setInterval(async () => {
            try {
                const info = await exec.inspect()
                if (!info.Running) {
                    clearInterval(poll)
                    resolve()
                }
            } catch (err) {
                // 준비 중 소켓이 닫혀 컨테이너가 삭제되면 inspect가 실패한다
                clearInterval(poll)
                reject(err)
            }
        }, 300)
    })
}

async function waitForSystemd(container: Docker.Container): Promise<void> {
    const exec = await container.exec({
        Cmd: ['sh', '-c', 'until systemctl is-system-running 2>/dev/null | grep -qE "running|degraded"; do sleep 0.3; done'],
        AttachStdout: false,
        AttachStderr: false,
    })
    await exec.start({})
    await new Promise<void>((resolve, reject) => {
        const poll = setInterval(async () => {
            try {
                const info = await exec.inspect()
                if (!info.Running) {
                    clearInterval(poll)
                    resolve()
                }
            } catch (err) {
                // 준비 중 소켓이 닫혀 컨테이너가 삭제되면 inspect가 실패한다
                clearInterval(poll)
                reject(err)
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

    const exec = await container.exec({ Cmd: setupCmd, AttachStdout: true, AttachStderr: true })
    await new Promise<void>((resolve, reject) => {
        exec.start({ hijack: true, stdin: false }, (err: any, stream: any) => {
            if (err) return reject(err)
            stream.resume()
            stream.on('end', resolve)
            stream.on('error', reject)
        })
    })
}

function attachResizeHandler(
  socket: WebSocket,
  stream: NodeJS.ReadWriteStream,
  resizeTarget: { resize: (opts: { h: number, w: number }) => Promise<void> }
) {
  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => {
    const str = msg.toString()
    if (str.startsWith('{') && str.includes('"type":"resize"')) {
      try {
        const { cols, rows } = JSON.parse(str)
        resizeTarget.resize({ h: rows, w: cols })
        return 
      } catch { /* JSON 파싱 실패 시 일반 입력으로 처리 */}
    }
    stream.write(msg)
  })

}

// 핸들러가 만든 자원을 정리하는 함수. 핸들러는 자원을 만드는 즉시 등록해 두고,
// 준비 도중 실패하거나 소켓이 닫혀도 handleTerminal이 이것 하나로 정리한다.
interface TerminalCtx {
  closed: boolean
  cleanup: () => Promise<void>
  // 자원을 받는 즉시 정리 방법을 등록한다. 이미 소켓이 닫혔다면 그 자원을 바로 정리하고 준비를 중단한다.
  track: (cleanup: () => Promise<void>) => void
}

interface PreparedTerminal {
  containerId: string
  stream: NodeJS.ReadWriteStream
  resizeTarget: { resize: (opts: { h: number, w: number }) => Promise<void> }
}

const OPEN = 1

// stop이 실패해도(이미 종료됨, 시작 실패) 삭제는 시도한다.
async function removeContainer(container: Docker.Container): Promise<void> {
  await container.stop().catch(() => {})
  await container.remove().catch(() => {})
}

// 정리 책임은 이 함수의 close handler 한 곳에만 둔다. 세션 종료 API는 없다.
export async function handleTerminal(
    socket: WebSocket,
    docker: Docker,
    info: TerminalTicketInfo,
) {
    const { sandboxType, questId, userId, questSetId } = info
    const ctx: TerminalCtx = {
        closed: false,
        cleanup: async () => {},
        track(cleanup) {
            ctx.cleanup = cleanup
            if (ctx.closed) {
                cleanup().catch(() => {})
                throw new Error('socket closed during setup')
            }
        },
    }

    // 준비가 오래 걸리거나 멈춰도 소켓이 닫히면 그 시점까지 만든 자원을 바로 정리하도록 먼저 등록한다.
    let registeredId: string | null = null
    socket.on('close', () => {
        ctx.closed = true
        if (registeredId) removeSession(registeredId)
        ctx.cleanup().catch(() => {})
    })

    try {
        const config = await getSandboxConfig(sandboxType)

        let prepared: PreparedTerminal
        if (sandboxType === 'linux-systemd') {
            prepared = await handleSystemdTerminal(docker, config, questId, ctx)
        } else if (sandboxType === 'docker' || sandboxType === 'docker-persistent') {
            prepared = await handleDockerTerminal(docker, config, questId, ctx)
        } else if (sandboxType === 'k8s-isolated') {
            prepared = await handleK8sIsolatedTerminal(docker, questId, ctx)
        } else if (sandboxType === 'k8s') {
            prepared = await handleK8sTerminal(docker, config, questId, ctx)
        } else {
            prepared = await handleDefaultTerminal(docker, config, questId, ctx)
        }

        // 준비하는 동안 소켓이 닫혔다면 등록하지 않는다. close 시점 이후에 만들어진 자원이 있을 수 있어 한 번 더 정리한다.
        if (socket.readyState !== OPEN) {
            await ctx.cleanup()
            return
        }

        registerSession(prepared.containerId, { userId, questSetId, sandboxType })
        registeredId = prepared.containerId
        socket.send(JSON.stringify({ type: 'connected', containerId: prepared.containerId }))
        attachResizeHandler(socket, prepared.stream, prepared.resizeTarget)
    } catch (err) {
        console.error('terminal error:', err)
        await ctx.cleanup().catch(() => {})
        socket.close()
    }
}

async function handleDefaultTerminal(docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null, ctx: TerminalCtx): Promise<PreparedTerminal> {
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
  ctx.track(() => removeContainer(container))

  const stream = await container.attach({
    stream: true,
    stdin: true,
    stdout: true,
    stderr: true,
    hijack: true,
  })

  await container.start()
  await runSetupCmd(container, questId)

  return { containerId: container.id, stream, resizeTarget: container }
}

async function handleDockerTerminal(
  docker: Docker,
  config: { image: string, binds: string[] | null },
  questId: number | null,
  ctx: TerminalCtx,
): Promise<PreparedTerminal> {
  const container = await docker.createContainer({
    Image: config.image,
    Labels: { etude: 'sandbox'},
    OpenStdin: false, Tty: false,
    AttachStdin: false, AttachStdout: false, AttachStderr: false,
    HostConfig: { Binds: config.binds ?? [], Privileged: true },
  })
  ctx.track(() => removeContainer(container))
  await container.start()
  await waitForDocker(container)

  await runSetupCmd(container, questId)

  const exec = await container.exec({
    Cmd: ['/bin/sh'],
    AttachStdin: true, AttachStdout: true, AttachStderr: true, Tty: true,
  })
  const stream = await exec.start({ hijack: true, stdin: true, Tty: true })

  return { containerId: container.id, stream, resizeTarget: exec }
}

async function handleSystemdTerminal(docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null, ctx: TerminalCtx): Promise<PreparedTerminal> {
  const container = await docker.createContainer({
    Image: config.image,
    Labels: { etude: 'sandbox' },
    OpenStdin: false, Tty: false,
    AttachStdin: false, AttachStdout: false, AttachStderr: false,
    HostConfig: {
      Binds: [...(config.binds ?? []), '/sys/fs/cgroup:/sys/fs/cgroup:rw'],
      Privileged: true,
      CgroupnsMode: 'host',
    } as Docker.ContainerCreateOptions['HostConfig'],
  })
  ctx.track(() => removeContainer(container))
  await container.start()
  await waitForSystemd(container)

  await runSetupCmd(container, questId)

  const exec = await container.exec({
    Cmd: ['/bin/bash'],
    AttachStdin: true, AttachStdout: true, AttachStderr: true, Tty: true,
  })
  const stream = await exec.start({ hijack: true, stdin: true, Tty: true })

  return { containerId: container.id, stream, resizeTarget: exec }
}

// k8s 샌드박스. 학습자에게 관리자 kubeconfig를 주지 않는다: DB의 binds(관리자 kubeconfig 마운트)는 무시하고,
// 세션마다 자기 네임스페이스 안에서만 쓸 수 있는 제한 kubeconfig를 만들어 주입한다 (k8s-session.ts).
async function handleK8sTerminal(docker: Docker, config: { image: string, binds: string[] | null }, questId: number | null, ctx: TerminalCtx): Promise<PreparedTerminal> {
  const container = await docker.createContainer({
    Image: config.image,
    Labels: { etude: 'sandbox'},
    HostConfig: {
      NetworkMode: process.env.K3D_NETWORK ?? 'k3d-etude',
    },
    Cmd: ['/bin/bash'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    OpenStdin: true,
    Tty: true,
  })
  const ns = `quest-${container.id.slice(0, 8)}`
  // 권한 삭제 → 컨테이너 삭제 순서. 권한 삭제가 일부만 만들어진 상태에서도 안전하다.
  ctx.track(async () => {
    await destroySessionAccess(ns).catch(() => {})
    await removeContainer(container)
  })

  const stream = await container.attach({
    stream: true,
    stdin: true,
    stdout: true,
    stderr: true,
    hijack: true,
  })

  await container.start()

  await installKubeconfig(container, await createSessionAccess(ns))
  await runSetupCmd(container, questId, container.id)

  return { containerId: container.id, stream, resizeTarget: container }
}


async function handleK8sIsolatedTerminal(docker: Docker, questId: number | null, ctx: TerminalCtx): Promise<PreparedTerminal> {
  const vcluster = await assignFromPool()
  ctx.track(() => releaseVcluster(vcluster))

  const container = await docker.createContainer({
    Image: 'etude-k8s',
    Labels: { etude: 'sandbox' },
    HostConfig: {
      Binds: [`${vcluster.kubeconfigPath}:/root/.kube/config:ro`],
      NetworkMode: process.env.K3D_NETWORK ?? 'k3d-etude',
    },
    Cmd: ['/bin/bash'],
    AttachStdin: true, AttachStdout: true, AttachStderr: true,
    OpenStdin: true, Tty: true,
  })
  ctx.track(async () => {
    await releaseVcluster(vcluster)
    await removeContainer(container)
  })

  const stream = await container.attach({ stream: true, stdin: true, stdout: true, stderr: true, hijack: true })

  await container.start()
  await runSetupCmd(container, questId, container.id)

  return { containerId: container.id, stream, resizeTarget: container }
}
