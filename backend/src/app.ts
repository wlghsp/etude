import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import { terminalRoutes } from './routes/terminal.routes.js'
import { authRoutes } from './routes/auth.routes.js'
import { progressRoutes } from './routes/progress.routes.js'
import { adminRoutes } from './routes/admin.routes.js'
import { questRoutes } from './routes/quest.routes.js'
import { feedbackRoutes } from './routes/feedback.routes.js'

// 앱 구성만 한다. 기동 정리·종료 훅·listen 같은 인프라 작업은 index.ts가 맡는다.
export async function buildApp(options: { logger?: boolean } = {}) {
    const app = Fastify({ logger: options.logger ?? false })

    await app.register(cors, { origin: true, methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'] })
    await app.register(websocket)

    await app.register(terminalRoutes)
    await app.register(authRoutes)
    await app.register(progressRoutes)
    await app.register(adminRoutes)
    await app.register(questRoutes)
    await app.register(feedbackRoutes)

    return app
}
