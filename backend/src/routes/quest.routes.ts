import type { FastifyPluginAsync } from "fastify";
import { canAccessQuestSet, getChoiceQuest, getQuestContext, getQuests, getQuestSets, gradeQuest, judgeAnswer } from "../services/quest.js";
import { getSession } from "../services/session-registry.js";
import { recordAttempt } from "../services/progress.js";
import { recordSetCompletion } from "../services/set-completion.js";
import { checkRun, startRun, type RunCheck } from "../services/set-run.js";
import { docker } from '../plugins/docker.js'
import { authMiddleware } from "../plugins/auth-guard.js";

// 시간 제한 세트에서 마감 뒤(또는 시작 기록 없이) 온 요청을 거부하는 응답
const runRejection = (check: Extract<RunCheck, { ok: false }>) =>
    ({ error: check.reason === 'expired' ? '시간이 끝났어요.' : '시험이 시작되지 않았어요.', expired: check.reason === 'expired' })

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

    // 시간 제한 세트(시험형)의 시작. 시작 시각을 서버가 기록하고 남은 시간을 돌려준다 (제한이 없는 세트는 null).
    app.post<{ Params: { id: string }, Body: { sessionId?: string } }>('/quest-sets/:id/start', { preHandler: authMiddleware }, async (req: any, reply) => {
        const questSetId = Number(req.params.id)
        const sessionId = req.body?.sessionId
        if (!Number.isInteger(questSetId) || typeof sessionId !== 'string' || sessionId.length === 0 || sessionId.length > 36) {
            return reply.code(400).send({ error: '요청이 올바르지 않습니다.' })
        }
        const allowed = await canAccessQuestSet(req.user.userId, req.user.role, questSetId)
        if (!allowed) return reply.code(403).send({ error: '이 세트에 접근할 권한이 없습니다.' })
        return startRun(req.user.userId, questSetId, sessionId)
    })

    // 객관식 답 제출 (docs/specs/spec_quiz_sets.md). 컨테이너 없이 서버가 정답을 판정하고 채점 기록을 남긴다.
    // 정답일 때만 해설을 돌려준다 (오답일 때 정답이 드러나지 않게).
    app.post<{ Params: { id: string }, Body: { questId?: number; sessionId?: string; choiceIndex?: number; answer?: number[]; elapsedSec?: number; hintUsed?: boolean } }>(
        '/quest-sets/:id/answer', { preHandler: authMiddleware }, async (req: any, reply) => {
        const questSetId = Number(req.params.id)
        const { questId, sessionId, choiceIndex, answer, elapsedSec, hintUsed } = req.body ?? {}
        if (!Number.isInteger(questSetId) || !Number.isInteger(questId) || typeof sessionId !== 'string' || sessionId.length === 0 || sessionId.length > 36) {
            return reply.code(400).send({ error: '요청이 올바르지 않습니다.' })
        }
        const allowed = await canAccessQuestSet(req.user.userId, req.user.role, questSetId)
        if (!allowed) return reply.code(403).send({ error: '이 세트에 접근할 권한이 없습니다.' })

        const run = await checkRun(req.user.userId, questSetId, sessionId)
        if (!run.ok) return reply.code(403).send(runRejection(run))

        const quest = await getChoiceQuest(questId as number)
        if (!quest || quest.questSetId !== questSetId || !['choice', 'order', 'fill'].includes(quest.kind)) {
            return reply.code(404).send({ error: '답을 고르는 퀘스트를 찾을 수 없습니다.' })
        }
        // 객관식은 번호 하나(choiceIndex), 순서 맞추기·빈칸 채우기는 번호 배열(answer)
        const judged = judgeAnswer(quest, quest.kind === 'choice' ? choiceIndex : answer)
        if (judged === null) return reply.code(400).send({ error: '선택한 답이 올바르지 않습니다.' })
        const { passed, results } = judged

        try {
            await recordAttempt(req.user.userId, questId as number, questSetId, sessionId, passed, elapsedSec, hintUsed, false)
        } catch (e) { console.error('[answer] recordAttempt error:', e) }

        // 정답일 때만 해설을 준다. 순서·빈칸은 오답에도 자리별 결과를 준다 (어디가 틀렸는지 알려 주기 위해)
        return { passed, ...(results ? { results } : {}), ...(passed ? { explanation: quest.explanation } : {}) }
    })

    // 세트 완료 기록. 이 세션에서 세트의 모든 퀘스트를 통과했는지 서버가 quest_attempt 로 직접 확인한 뒤에만 저장한다.
    app.post<{ Params: { id: string }, Body: { sessionId?: string } }>('/quest-sets/:id/complete', { preHandler: authMiddleware }, async (req: any, reply) => {
        const questSetId = Number(req.params.id)
        const sessionId = req.body?.sessionId
        if (!Number.isInteger(questSetId) || typeof sessionId !== 'string' || sessionId.length === 0 || sessionId.length > 36) {
            return reply.code(400).send({ error: '요청이 올바르지 않습니다.' })
        }
        const allowed = await canAccessQuestSet(req.user.userId, req.user.role, questSetId)
        if (!allowed) return reply.code(403).send({ error: '이 세트에 접근할 권한이 없습니다.' })
        const run = await checkRun(req.user.userId, questSetId, sessionId)
        if (!run.ok) return reply.code(403).send(runRejection(run))
        const result = await recordSetCompletion(req.user.userId, questSetId, sessionId)
        if (!result.recorded) return reply.code(409).send({ error: '이 세션에서 세트의 모든 퀘스트를 통과하지 않았습니다.' })
        return { recorded: true }
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

        const run = await checkRun(req.user.userId, session.questSetId, sessionId)
        if (!run.ok) return reply.code(403).send(runRejection(run))

        const { passed, checks } = await gradeQuest(containerId, questId, docker)

        try {
            await recordAttempt(req.user.userId, questId, session.questSetId, sessionId, passed, elapsedSec, hintUsed, solutionUsed)
        } catch (e) { console.error('[grade] recordAttempt error:', e) }

        return checks ? { passed, checks } : { passed }
    })
}
