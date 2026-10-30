import { describe, it, expect, vi, beforeEach } from 'vitest'
import Fastify from 'fastify'
import jwt from 'jsonwebtoken'

vi.mock('../services/quest.js', async () => {
    const actual = await vi.importActual<typeof import('../services/quest.js')>('../services/quest.js')
    return {
        canAccessQuestSet: vi.fn(), getChoiceQuest: vi.fn(), getQuestContext: vi.fn(), getQuests: vi.fn(), getQuestSets: vi.fn(), gradeQuest: vi.fn(),
        judgeChoice: actual.judgeChoice,
    }
})
vi.mock('../services/progress.js', () => ({ recordAttempt: vi.fn(async () => {}) }))
vi.mock('../services/set-completion.js', () => ({ recordSetCompletion: vi.fn(async () => ({ recorded: true })) }))
vi.mock('../services/session-registry.js', () => ({ getSession: vi.fn() }))
vi.mock('../services/set-run.js', () => ({ startRun: vi.fn(), checkRun: vi.fn() }))
vi.mock('../plugins/docker.js', () => ({ docker: {} }))

import { canAccessQuestSet, getChoiceQuest, getQuestContext, gradeQuest } from '../services/quest.js'
import { recordAttempt } from '../services/progress.js'
import { recordSetCompletion } from '../services/set-completion.js'
import { getSession } from '../services/session-registry.js'
import { startRun, checkRun } from '../services/set-run.js'
import { questRoutes } from './quest.routes.js'

const token = jwt.sign({ userId: 7, name: 'n', email: 'e', role: 'member' }, 'dev-secret', { expiresIn: '5m' })
const headers = { authorization: `Bearer ${token}` }

async function post(url: string, payload: any) {
    const a = Fastify()
    await a.register(questRoutes)
    return a.inject({ method: 'POST', url, headers, payload })
}

describe('시간 제한 세트', () => {
    beforeEach(() => {
        vi.clearAllMocks()
        vi.mocked(canAccessQuestSet).mockResolvedValue(true)
        vi.mocked(checkRun).mockResolvedValue({ ok: true })
        vi.mocked(getChoiceQuest).mockResolvedValue({ questId: 5, questSetId: 3, kind: 'choice', choiceCount: 4, answerIndex: 2, explanation: 'e' } as any)
        vi.mocked(getSession).mockReturnValue({ userId: 7, questSetId: 3 } as any)
        vi.mocked(getQuestContext).mockResolvedValue({ questSetId: 3, sandboxType: 'docker' } as any)
        vi.mocked(gradeQuest).mockResolvedValue({ passed: true, checks: null } as any)
    })

    describe('POST /quest-sets/:id/start', () => {
        it('시작 시각을 기록하고 제한·남은 시간을 돌려준다', async () => {
            vi.mocked(startRun).mockResolvedValue({ limitSec: 600, remainingSec: 480 })

            const res = await post('/quest-sets/3/start', { sessionId: 's1' })

            expect(res.statusCode).toBe(200)
            expect(res.json()).toEqual({ limitSec: 600, remainingSec: 480 })
            expect(startRun).toHaveBeenCalledWith(7, 3, 's1')
        })

        it('세션 ID 가 없거나 접근 권한이 없으면 거부한다', async () => {
            expect((await post('/quest-sets/3/start', {})).statusCode).toBe(400)
            vi.mocked(canAccessQuestSet).mockResolvedValue(false)
            expect((await post('/quest-sets/3/start', { sessionId: 's1' })).statusCode).toBe(403)
            expect(startRun).not.toHaveBeenCalled()
        })
    })

    describe('마감 뒤 요청', () => {
        beforeEach(() => vi.mocked(checkRun).mockResolvedValue({ ok: false, reason: 'expired' }))

        it('객관식 답 제출은 403 expired 이고 기록하지 않는다', async () => {
            const res = await post('/quest-sets/3/answer', { questId: 5, sessionId: 's1', choiceIndex: 2 })

            expect(res.statusCode).toBe(403)
            expect(res.json()).toMatchObject({ expired: true })
            expect(recordAttempt).not.toHaveBeenCalled()
        })

        it('터미널 채점은 403 expired 이고 채점하지 않는다', async () => {
            const res = await post('/grade', { containerId: 'c', questId: 5, sessionId: 's1' })

            expect(res.statusCode).toBe(403)
            expect(res.json()).toMatchObject({ expired: true })
            expect(gradeQuest).not.toHaveBeenCalled()
        })

        it('세트 완료 기록은 403 expired 이고 저장하지 않는다', async () => {
            const res = await post('/quest-sets/3/complete', { sessionId: 's1' })

            expect(res.statusCode).toBe(403)
            expect(recordSetCompletion).not.toHaveBeenCalled()
        })
    })

    it('시작하지 않은 시험에 낸 답은 거부한다', async () => {
        vi.mocked(checkRun).mockResolvedValue({ ok: false, reason: 'not_started' })

        const res = await post('/quest-sets/3/answer', { questId: 5, sessionId: 's1', choiceIndex: 2 })

        expect(res.statusCode).toBe(403)
        expect(res.json()).toMatchObject({ expired: false })
    })

    it('마감 전이면 평소처럼 처리한다', async () => {
        const res = await post('/quest-sets/3/answer', { questId: 5, sessionId: 's1', choiceIndex: 2 })

        expect(res.statusCode).toBe(200)
        expect(checkRun).toHaveBeenCalledWith(7, 3, 's1')
        expect(recordAttempt).toHaveBeenCalled()
    })
})
