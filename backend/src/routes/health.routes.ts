import type { FastifyInstance } from 'fastify'
import { db } from '../db.js'

// 컨테이너 헬스체크와 배포 대기(--wait)가 쓰는 상태 확인. DB까지 닿는지 본다.
export async function healthRoutes(app: FastifyInstance) {
    app.get('/health', async (_req, reply) => {
        try {
            await db.query('SELECT 1')
            return { status: 'ok' }
        } catch {
            return reply.code(503).send({ status: 'unavailable' })
        }
    })
}
