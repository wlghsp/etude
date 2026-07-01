import type { FastifyPluginAsync } from "fastify";
import { canAccessQuestSet, getQuests, getQuestSets, gradeQuest } from "../services/quest.js";
import { verifyToken } from "../services/auth.js";
import { recordAttempt } from "../services/user.js";
import { docker } from '../plugins/docker.js'
import { authMiddleware } from "../plugins/auth-guard.js";

export const questRoutes: FastifyPluginAsync = async (app) => {
    app.get('/quest-sets', { preHandler: authMiddleware }, async (req: any) => {
        return getQuestSets(req.user.userId, req.user.role)
    })

    app.get<{ Params: { id: string }}>('/quest-sets/:id/quests', { preHandler: authMiddleware },async (req: any, reply) => {
        const questSetId = Number(req.params.id)
        const allowed = await canAccessQuestSet(req.user.userId, req.user.role, questSetId)
        if (!allowed) return reply.code(403).send({ error: '이 세트에 접근할 권한이 없습니다.'})
        return getQuests(questSetId)
    })

    app.post('/grade', async (req) => {
    const { containerId, questId, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed }
        = req.body as {
            containerId: string
            questId: number
            questSetId: number
            sessionId: string
            elapsedSec?: number
            hintUsed?: boolean
            solutionUsed?: boolean
        }
        const passed = await gradeQuest(containerId, questId, docker)

        const auth = req.headers['authorization'] ?? ''
        const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
        if (token) {
            try {
                const payload = verifyToken(token)
                await recordAttempt(payload.userId, questId, questSetId, sessionId, passed, elapsedSec, hintUsed, solutionUsed)
            } catch (e) { console.error('[grade] recordAttempt error:', e) }
        }

        return { passed }
    }
)
}