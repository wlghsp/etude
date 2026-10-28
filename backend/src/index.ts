import 'dotenv/config'
import { buildApp } from './app.js'
import { cleanupOrphanContainers, cleanupRunningContainers } from './plugins/docker.js'
import { cleanupOrphanVclusters, initPool } from './services/vcluster-pool.js'
import { cleanupOrphanQuestNamespaces } from './plugins/k8s-namespace.js'

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

await fastify.listen({ port: 3001, host:'0.0.0.0'})
