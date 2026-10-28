import type { FastifyPluginAsync } from "fastify";
import { canAccessQuestSet, getQuestContext, getQuests, getQuestSets, gradeQuest } from "../services/quest.js";
import { getSession } from "../services/session-registry.js";
import { recordAttempt } from "../services/progress.js";
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

    // 본인 세션의 컨테이너만, 그 세션의 세트에 속한 퀘스트만 채점한다.
    // questSetId는 body가 아니라 서버가 조회한 값(세션·DB)을 쓴다.
    app.post('/grade', { preHandler: authMiddleware }, async (req: any, reply) => {
        const { containerId, questId, sessionId, elapsedSec, hintUsed, solutionUsed }
            = req.body as {
                containerId: string
                questId: number
                sessionId: string
                elapsedSec?: number
                hintUsed?: boolean
                solutionUsed?: boolean
            }

        const session = getSession(containerId)
        if (!session || session.userId !== req.user.userId) {
            return reply.code(403).send({ error: '이 컨테이너에 대한 권한이 없습니다.' })
        }

        const quest = await getQuestContext(questId)
        if (!quest) return reply.code(404).send({ error: '퀘스트를 찾을 수 없습니다.' })
        if (quest.questSetId !== session.questSetId) {
            return reply.code(403).send({ error: '이 세션의 세트에 속한 퀘스트가 아닙니다.' })
        }

        const passed = await gradeQuest(containerId, questId, docker)

        try {
            await recordAttempt(req.user.userId, questId, session.questSetId, sessionId, passed, elapsedSec, hintUsed, solutionUsed)
        } catch (e) { console.error('[grade] recordAttempt error:', e) }

        return { passed }
    })
}
