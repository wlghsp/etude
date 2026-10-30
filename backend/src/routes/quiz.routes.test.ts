import { describe, it, expect, vi, beforeEach } from 'vitest'
import Fastify from 'fastify'
import jwt from 'jsonwebtoken'

vi.mock('../services/quest.js', async () => {
    const actual = await vi.importActual<typeof import('../services/quest.js')>('../services/quest.js')
    return {
        canAccessQuestSet: vi.fn(),
        getChoiceQuest: vi.fn(),
        getQuestContext: vi.fn(),
        getQuests: vi.fn(),
        getQuestSets: vi.fn(),
        gradeQuest: vi.fn(),
        judgeChoice: actual.judgeChoice, // 판정 로직은 진짜를 쓴다
    }
})
vi.mock('../services/set-run.js', () => ({ checkRun: vi.fn(async () => ({ ok: true })), startRun: vi.fn() }))
vi.mock('../services/progress.js', () => ({ recordAttempt: vi.fn(async () => {}) }))
vi.mock('../services/set-completion.js', () => ({ recordSetCompletion: vi.fn() }))
vi.mock('../services/session-registry.js', () => ({ getSession: vi.fn() }))
vi.mock('../plugins/docker.js', () => ({ docker: {} }))

import { canAccessQuestSet, getChoiceQuest, getQuestContext } from '../services/quest.js'
import { recordAttempt } from '../services/progress.js'
import { questRoutes } from './quest.routes.js'
import { terminalRoutes } from './terminal.routes.js'

const token = jwt.sign({ userId: 7, name: 'n', email: 'e', role: 'member' }, 'dev-secret', { expiresIn: '5m' })
const headers = { authorization: `Bearer ${token}` }
const quest = { questId: 5, questSetId: 3, kind: 'choice', choiceCount: 4, answerIndex: 2, explanation: '해설: C 가 맞다' }

async function app() {
    const a = Fastify()
    await a.register((await import('@fastify/websocket')).default)
    await a.register(questRoutes)
    await a.register(terminalRoutes)
    return a
}

describe('POST /quest-sets/:id/answer', () => {
    beforeEach(() => {
        vi.clearAllMocks()
        vi.mocked(canAccessQuestSet).mockResolvedValue(true)
        vi.mocked(getChoiceQuest).mockResolvedValue(quest)
    })
    const post = async (body: any, h: any = headers, setId = 3) =>
        (await app()).inject({ method: 'POST', url: `/quest-sets/${setId}/answer`, headers: h, payload: body })

    it('정답이면 passed=true 와 해설을 돌려주고 채점 기록을 남긴다', async () => {
        const res = await post({ questId: 5, sessionId: 's1', choiceIndex: 2, elapsedSec: 30, hintUsed: true })

        expect(res.statusCode).toBe(200)
        expect(res.json()).toEqual({ passed: true, explanation: '해설: C 가 맞다' })
        expect(recordAttempt).toHaveBeenCalledWith(7, 5, 3, 's1', true, 30, true, false)
    })

    it('오답이면 passed=false 만 돌려주고 정답·해설은 드러내지 않는다 (그래도 시도는 기록한다)', async () => {
        const res = await post({ questId: 5, sessionId: 's1', choiceIndex: 0 })

        expect(res.json()).toEqual({ passed: false })
        expect(JSON.stringify(res.json())).not.toContain('해설')
        expect(recordAttempt).toHaveBeenCalledWith(7, 5, 3, 's1', false, undefined, undefined, false)
    })

    it('범위 밖이거나 숫자가 아닌 선택은 400 이고 기록하지 않는다', async () => {
        for (const choiceIndex of [4, -1, 1.5, '2', null]) {
            const res = await post({ questId: 5, sessionId: 's1', choiceIndex })
            expect(res.statusCode, String(choiceIndex)).toBe(400)
        }
        expect(recordAttempt).not.toHaveBeenCalled()
    })

    it('세션 ID 가 없거나 너무 길면 400', async () => {
        expect((await post({ questId: 5, choiceIndex: 2 })).statusCode).toBe(400)
        expect((await post({ questId: 5, sessionId: 'x'.repeat(37), choiceIndex: 2 })).statusCode).toBe(400)
    })

    it('접근 권한이 없으면 403, 토큰이 없으면 401', async () => {
        vi.mocked(canAccessQuestSet).mockResolvedValue(false)
        expect((await post({ questId: 5, sessionId: 's1', choiceIndex: 2 })).statusCode).toBe(403)
        expect((await post({ questId: 5, sessionId: 's1', choiceIndex: 2 }, {})).statusCode).toBe(401)
    })

    it('다른 세트의 퀘스트이거나 객관식이 아니면 404 (그 세트의 객관식만 채점한다)', async () => {
        vi.mocked(getChoiceQuest).mockResolvedValue({ ...quest, questSetId: 99 })
        expect((await post({ questId: 5, sessionId: 's1', choiceIndex: 2 })).statusCode).toBe(404)

        vi.mocked(getChoiceQuest).mockResolvedValue({ ...quest, kind: 'terminal' })
        expect((await post({ questId: 5, sessionId: 's1', choiceIndex: 2 })).statusCode).toBe(404)

        vi.mocked(getChoiceQuest).mockResolvedValue(null)
        expect((await post({ questId: 5, sessionId: 's1', choiceIndex: 2 })).statusCode).toBe(404)
        expect(recordAttempt).not.toHaveBeenCalled()
    })
})

describe('터미널 연결', () => {
    it('퀴즈 세트의 퀘스트는 터미널 ticket 을 발급하지 않는다 (컨테이너가 없는 세트)', async () => {
        vi.mocked(getQuestContext).mockResolvedValue({ questSetId: 3, sandboxType: 'quiz' })
        vi.mocked(canAccessQuestSet).mockResolvedValue(true)

        const res = await (await app()).inject({ method: 'POST', url: '/terminal-sessions', headers, payload: { questId: 5 } })

        expect(res.statusCode).toBe(400)
    })
})
