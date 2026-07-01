import type { FastifyPluginAsync } from "fastify"
import { createFeedback } from "../services/feedback.js";
import { verifyToken } from "../services/auth.js";


export const feedbackRoutes: FastifyPluginAsync = async (app) => {
     app.post<{ Body: { page: string; questId?: number; questSetId?: number; body: string } }>(
        '/feedback',
        async (req, reply) => {
            const { page, questId, questSetId, body } = req.body
            if (!body?.trim()) return reply.code(400).send({ error: '내용을 입력해주세요.' })

            let userId: number | null = null
            const authHeader = req.headers['authorization']
            if (authHeader?.startsWith('Bearer ')) {
                try {
                    userId = verifyToken(authHeader.slice(7)).userId
                } catch {}
            }

            await createFeedback(userId, page, questId ?? null, questSetId ?? null, body.trim())
            return { ok: true }
        }
    )
}