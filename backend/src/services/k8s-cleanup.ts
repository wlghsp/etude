// k8s 세션이 남기는 클러스터 범위 리소스 정리에 쓰는 명령. 앱의 세션 정리와 채점 검증 러너가 함께 쓴다.

const SAFE_NAME = /^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$/

// 이 네임스페이스를 claimRef로 가진 PersistentVolume을 찾아 지운다.
// PV는 네임스페이스에 속하지 않아서 네임스페이스를 지워도 남기 때문이다. 대상이 없으면 아무것도 하지 않는다(xargs -r).
export function pvCleanupCommand(namespace: string): string[] {
    if (!SAFE_NAME.test(namespace)) throw new Error(`네임스페이스 이름이 올바르지 않습니다: ${namespace}`)
    return [
        'sh', '-c',
        `kubectl get pv -o jsonpath='{range .items[?(@.spec.claimRef.namespace=="${namespace}")]}{.metadata.name}{"\\n"}{end}' | xargs -r kubectl delete pv --ignore-not-found`,
    ]
}
