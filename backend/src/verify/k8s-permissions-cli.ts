import 'dotenv/config'
import { docker } from '../plugins/docker.js'
import { db } from '../db.js'
import { getSandboxConfig } from '../services/sandbox.js'
import { dockerSandboxFactory, k8sProfile } from './docker-sandbox.js'
import { runPermissionProbes } from './permission-probes.js'

// k8s 세션의 제한 권한을 실제 클러스터에서 확인한다: 허용해야 할 것은 되고, 거부해야 할 것은 거부되는지.
// 앱과 같은 방식으로 세션 권한을 만들어 쓰고(verify-<id> 네임스페이스) 끝나면 지운다.
async function main() {
    const config = await getSandboxConfig('k8s')
    const sandbox = await dockerSandboxFactory(docker, config, k8sProfile(process.env.K3D_NETWORK ?? 'k3d-etude'))()
    try {
        const results = await runPermissionProbes(sandbox)
        for (const r of results) {
            const want = r.expect === 'allow' ? '허용' : '거부'
            console.log(`  ${r.ok ? '✓' : '✗'} [${want} 기대] ${r.name}${r.ok ? '' : `  (종료 코드 ${r.exitCode})`}`)
        }
        const failed = results.filter((r) => !r.ok).length
        console.log(`\n통과 ${results.length - failed}, 실패 ${failed}`)
        return failed === 0 ? 0 : 1
    } finally {
        await sandbox.dispose()
    }
}

main()
    .then((code) => { process.exitCode = code })
    .catch((err) => { console.error(err instanceof Error ? err.message : err); process.exitCode = 2 })
    .finally(() => db.end())
