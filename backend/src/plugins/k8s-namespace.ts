import { exec } from 'node:child_process'
import { promisify } from 'node:util'

const execAsync = promisify(exec)

const SAFE_NAME = /^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$/

export async function cleanupOrphanQuestNamespaces(): Promise<void> {
    const { stdout } = await execAsync(
        `kubectl get ns -o jsonpath='{.items[*].metadata.name}'`
    ).catch(() => ({ stdout: '' }))

    const orphanNamespaces = stdout.split(/\s+/).filter((ns) => ns.startsWith('quest-'))

    await Promise.all(
        orphanNamespaces.map((ns) => 
            execAsync(`kubectl delete namespace ${ns} --ignore-not-found`).catch(() => {})
        )
    )

    await cleanupOrphanQuestVolumes()
}

// PersistentVolume은 클러스터 범위라 네임스페이스를 지워도 남는다 (퀘스트 13.x가 만든다).
// claimRef가 quest-* 네임스페이스를 가리키는 PV를 지운다. 이미 쌓인 Available/Released PV도 이때 걷힌다.
async function cleanupOrphanQuestVolumes(): Promise<void> {
    const { stdout } = await execAsync(
        `kubectl get pv -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.claimRef.namespace}{"\\n"}{end}'`
    ).catch(() => ({ stdout: '' }))

    const names = stdout
        .split('\n')
        .map((line) => line.trim().split(/\s+/))
        .filter(([name, claimNamespace]) => name && claimNamespace?.startsWith('quest-') && SAFE_NAME.test(name))
        .map(([name]) => name)

    if (names.length === 0) return
    await execAsync(`kubectl delete pv ${names.join(' ')} --ignore-not-found`).catch(() => {})
}
