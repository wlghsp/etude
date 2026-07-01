import type { FastifyPluginAsync } from "fastify";
import { getQuests, getQuestSets, gradeQuest } from "../services/quest.js";
import { verifyToken } from "../services/auth.js";
import { recordAttempt } from "../services/user.js";
import { docker } from '../plugins/docker.js'

export const questRoutes: FastifyPluginAsync = async (app) => {
    app.get('/quest-sets', async () => getQuestSets())

    app.get<{ Params: { id: string }}>('/quest-sets/:id/quests', async (req) => {
        return getQuests(Number(req.params.id))
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