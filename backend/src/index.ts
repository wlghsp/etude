import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import 'dotenv/config'
import { cleanupOrphanContainers, cleanupRunningContainers } from './plugins/docker.js'
import { terminalRoutes } from './routes/terminal.routes.js'
import { authRoutes } from './routes/auth.routes.js'
import { userRoutes } from './routes/user.routes.js'
import { adminRoutes } from './routes/admin.routes.js'
import { questRoutes } from './routes/quest.routes.js'
import { sessionRoutes } from './routes/session.routes.js'
import { feedbackRoutes } from './routes/feedback.routes.js'

const fastify = Fastify({ logger: true })

await cleanupOrphanContainers()

await fastify.register(cors, { origin: true })
await fastify.register(websocket)

await fastify.register(terminalRoutes)
await fastify.register(authRoutes)
await fastify.register(userRoutes)
await fastify.register(adminRoutes)
await fastify.register(questRoutes)
await fastify.register(sessionRoutes)
await fastify.register(feedbackRoutes)


fastify.addHook('onClose', async () => {
    await cleanupRunningContainers()
})

const shutdown = async () => {
    await fastify.close()
    process.exit()
}
process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

await fastify.listen({ port: 3001, host:'0.0.0.0'})