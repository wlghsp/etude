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
