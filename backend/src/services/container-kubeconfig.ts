import type Docker from 'dockerode'

// 컨테이너 안에서 명령을 실행하고 끝날 때까지 기다려 종료 코드를 돌려준다. 제한 시간 안에 끝나지 않으면 null.
async function execAndWait(container: Docker.Container, cmd: string[], opts: { timeoutMs?: number; env?: string[] } = {}): Promise<number | null> {
    const exec = await container.exec({ Cmd: cmd, Env: opts.env, AttachStdout: false, AttachStderr: false })
    await exec.start({})
    const startedAt = Date.now()
    while (Date.now() - startedAt < (opts.timeoutMs ?? 15000)) {
        const info = await exec.inspect()
        if (!info.Running) return info.ExitCode ?? 0
        await new Promise((r) => setTimeout(r, 100))
    }
    return null
}

// 제한 kubeconfig를 컨테이너의 /root/.kube/config에 쓴다. 값은 실행 환경 변수(base64)로 넘긴다 (셸 인용 문제를 피한다).
// 앱의 k8s 세션과 채점 검증 러너가 같이 쓴다.
export async function installKubeconfig(container: Docker.Container, kubeconfig: string): Promise<void> {
    const code = await execAndWait(
        container,
        ['sh', '-c', 'mkdir -p /root/.kube && printf %s "$KUBECONFIG_B64" | base64 -d > /root/.kube/config && chmod 600 /root/.kube/config'],
        { env: [`KUBECONFIG_B64=${Buffer.from(kubeconfig).toString('base64')}`] },
    )
    if (code !== 0) throw new Error(`kubeconfig를 컨테이너에 쓰지 못했습니다 (종료 코드 ${code})`)
}
