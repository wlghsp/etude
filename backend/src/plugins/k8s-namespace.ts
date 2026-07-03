import { exec } from 'node:child_process'
import { promisify } from 'node:util'

const execAsync = promisify(exec)

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
}