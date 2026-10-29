// 샌드박스 컨테이너 자원 상한. 학습자 한 명의 폭주(포크 폭탄, 메모리 소진)가 서버 전체를 멈추지 못하게 한다.
// 서버는 4 vCPU / 23GB이고 DB, backend, k3d가 같은 호스트에서 돈다. 앱의 컨테이너 생성과 채점 검증 러너가 같은 값을 쓴다.
// 참고: 이 상한은 Privileged 컨테이너의 탈출을 막지 못한다 (그건 spec_privileged_sandbox_isolation.md의 별도 문제).

export type SandboxClass = 'default' | 'k8s' | 'dind' | 'systemd'

const MiB = 1024 ** 2

const LIMITS: Record<SandboxClass, { memoryMiB: number; cpus: number; pids: number }> = {
    default: { memoryMiB: 512, cpus: 1, pids: 512 },
    // kubectl과 helm. helm repo add bitnami(큰 차트 인덱스 파싱)가 512MiB에서 메모리 부족으로 죽는다 (검증 러너로 확인)
    k8s: { memoryMiB: 1024, cpus: 1, pids: 512 },
    // 중첩 도커: 이미지 pull, 빌드, 컨테이너 여러 개
    dind: { memoryMiB: 1536, cpus: 2, pids: 2048 },
    // systemd와 패키지 설치(dnf)
    systemd: { memoryMiB: 1024, cpus: 1, pids: 1024 },
}

export function sandboxLimits(kind: SandboxClass) {
    const l = LIMITS[kind]
    const Memory = l.memoryMiB * MiB
    // MemorySwap == Memory: 스왑을 쓰지 않는다
    return { Memory, MemorySwap: Memory, NanoCpus: l.cpus * 1e9, PidsLimit: l.pids }
}
