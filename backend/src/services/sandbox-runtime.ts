// docker·systemd 샌드박스의 격리 방식. 앱의 컨테이너 생성과 검증 러너가 같은 값을 쓴다.
// SANDBOX_RUNTIME(예: sysbox-runc)이 없으면 지금처럼 Privileged로 만든다. 있으면 Privileged 없이 그 런타임으로 만든다
// (spec_privileged_sandbox_isolation.md 조각 A). 호스트에 런타임을 설치한 뒤에만 설정한다.

export function privilegedSandboxHost(kind: 'dind' | 'systemd') {
    const runtime = process.env.SANDBOX_RUNTIME
    if (runtime) return { Runtime: runtime, binds: [] as string[] }
    return kind === 'systemd'
        ? { Privileged: true, CgroupnsMode: 'host', binds: ['/sys/fs/cgroup:/sys/fs/cgroup:rw'] }
        : { Privileged: true, binds: [] as string[] }
}

// dind 컨테이너 안쪽 도커(dockerd)가 Docker Hub 대신 쓸 미러. 환경변수 DOCKER_REGISTRY_MIRROR (예: http://172.17.0.1:5000).
// Docker Hub 는 같은 IP 에서 익명으로 받는 횟수를 제한(429)해서, 세션마다 이미지를 받는 실습이 한도에 걸린다. 미러는 한 번 받아 두고 나눠 준다.
// 없으면 빈 배열(= Hub 를 직접 쓴다). docker:dind 는 '-' 로 시작하는 인자를 dockerd 에 그대로 넘긴다. 명세: docs/specs/spec_registry_mirror.md
export function dindMirrorCmd(): string[] {
    const url = process.env.DOCKER_REGISTRY_MIRROR
    if (!url) return []
    const cmd = [`--registry-mirror=${url}`]
    // http 미러는 TLS 가 없으므로 안전하지 않은 레지스트리로도 허용해야 dockerd 가 붙는다
    if (url.startsWith('http://')) cmd.push(`--insecure-registry=${url.replace(/^http:\/\//, '').replace(/\/.*$/, '')}`)
    return cmd
}
