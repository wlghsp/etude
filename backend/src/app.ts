import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import multipart from '@fastify/multipart'
import { terminalRoutes } from './routes/terminal.routes.js'
import { authRoutes } from './routes/auth.routes.js'
import { progressRoutes } from './routes/progress.routes.js'
import { adminRoutes } from './routes/admin.routes.js'
import { questRoutes } from './routes/quest.routes.js'
import { feedbackRoutes } from './routes/feedback.routes.js'
import { healthRoutes } from './routes/health.routes.js'
import { feedRoutes } from './routes/feed.routes.js'
import { MAX_FILES, MAX_FILE_BYTES } from './services/feedback-attachments.js'

// 앱 구성만 한다. 기동 정리·종료 훅·listen 같은 인프라 작업은 index.ts가 맡는다.
export async function buildApp(options: { logger?: boolean } = {}) {
    const app = Fastify({ logger: options.logger ?? false })

    await app.register(cors, { origin: true, methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'] })
    await app.register(websocket)
    // 피드백 이미지: 장수·크기 상한은 서버가 마지막으로 막는다 (services/feedback-attachments.ts 와 같은 값).
    await app.register(multipart, { limits: { files: MAX_FILES, fileSize: MAX_FILE_BYTES + 1, fields: 10 } })

    await app.register(terminalRoutes)
    await app.register(authRoutes)
    await app.register(progressRoutes)
    await app.register(adminRoutes)
    await app.register(questRoutes)
    await app.register(feedbackRoutes)
    await app.register(healthRoutes)
    await app.register(feedRoutes)

    return app
}
