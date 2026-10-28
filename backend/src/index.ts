import 'dotenv/config'
import { buildApp } from './app.js'
import { cleanupOrphanContainers, cleanupRunningContainers } from './plugins/docker.js'
import { cleanupOrphanVclusters, initPool } from './services/vcluster-pool.js'
import { cleanupOrphanQuestNamespaces } from './plugins/k8s-namespace.js'
import { assertPortFree } from './services/port-guard.js'

const PORT = 3001
const HOST = '0.0.0.0'

// 이미 실행 중인 backend가 있으면 아래 정리가 그 프로세스의 컨테이너·vcluster를 지우므로 먼저 확인한다.
try {
    await assertPortFree(PORT, HOST)
} catch (err) {
    console.error(`포트 ${PORT}이 이미 사용 중이라 기동을 중단합니다. 정리 작업은 실행하지 않았습니다.`, err)
    process.exit(1)
}

await cleanupOrphanContainers()
await cleanupOrphanQuestNamespaces()
await initPool()

const fastify = await buildApp({ logger: true })

fastify.addHook('onClose', async () => {
    await cleanupRunningContainers()
    await cleanupOrphanVclusters() // pool + 배정 중이던 vcluster 모두 정리
})

const shutdown = async () => {
    await fastify.close()
    process.exit()
}
process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

await fastify.listen({ port: PORT, host: HOST })
