import { describe, it, expect, vi, beforeEach } from 'vitest'
import Fastify from 'fastify'
import jwt from 'jsonwebtoken'

vi.mock('../services/quest.js', async () => {
    const actual = await vi.importActual<typeof import('../services/quest.js')>('../services/quest.js')
    return {
        canAccessQuestSet: vi.fn(), getChoiceQuest: vi.fn(), getQuestContext: vi.fn(), getQuests: vi.fn(), getQuestSets: vi.fn(), gradeQuest: vi.fn(),
        judgeChoice: actual.judgeChoice,
        judgeAnswer: actual.judgeAnswer,
    }
})
vi.mock('../services/progress.js', () => ({ recordAttempt: vi.fn(async () => {}) }))
vi.mock('../services/set-completion.js', () => ({ recordSetCompletion: vi.fn() }))
vi.mock('../services/session-registry.js', () => ({ getSession: vi.fn() }))
vi.mock('../services/set-run.js', () => ({ startRun: vi.fn(), checkRun: vi.fn() }))
vi.mock('../services/set-resume.js', () => ({ findResumableRun: vi.fn() }))
vi.mock('../plugins/docker.js', () => ({ docker: {} }))

import { canAccessQuestSet } from '../services/quest.js'
import { findResumableRun } from '../services/set-resume.js'
import { questRoutes } from './quest.routes.js'

const token = jwt.sign({ userId: 7, name: 'n', email: 'e', role: 'member' }, 'dev-secret', { expiresIn: '5m' })
const headers = { authorization: `Bearer ${token}` }

async function get(url: string, withAuth = true) {
    const a = Fastify()
    await a.register(questRoutes)
    return a.inject({ method: 'GET', url, headers: withAuth ? headers : {} })
}

describe('GET /quest-sets/:id/resume', () => {
    beforeEach(() => {
        vi.clearAllMocks()
        vi.mocked(canAccessQuestSet).mockResolvedValue(true)
    })

    it('요청한 사람의 이어 풀 세션과 푼 문제 목록을 돌려준다', async () => {
        vi.mocked(findResumableRun).mockResolvedValue({ sessionId: 's-open', passed: [{ questId: 41, seconds: 50, hintUsed: false, solutionUsed: false, attempts: 1 }] })

        const res = await get('/quest-sets/3/resume')

        expect(res.statusCode).toBe(200)
        expect(res.json()).toEqual({ sessionId: 's-open', passed: [{ questId: 41, seconds: 50, hintUsed: false, solutionUsed: false, attempts: 1 }] })
        expect(findResumableRun).toHaveBeenCalledWith(7, 3)
    })

    it('이어 풀 세션이 없으면 sessionId 가 null 이다', async () => {
        vi.mocked(findResumableRun).mockResolvedValue({ sessionId: null, passed: [] })

        const res = await get('/quest-sets/3/resume')

        expect(res.json()).toEqual({ sessionId: null, passed: [] })
    })

    it('접근 권한이 없는 세트는 조회하지 않고 거부한다', async () => {
        vi.mocked(canAccessQuestSet).mockResolvedValue(false)

        const res = await get('/quest-sets/3/resume')

        expect(res.statusCode).toBe(403)
        expect(findResumableRun).not.toHaveBeenCalled()
    })

    it('로그인하지 않으면 거부한다', async () => {
        const res = await get('/quest-sets/3/resume', false)

        expect(res.statusCode).toBe(401)
        expect(findResumableRun).not.toHaveBeenCalled()
    })

    it('세트 번호가 숫자가 아니면 400 이다', async () => {
        const res = await get('/quest-sets/abc/resume')

        expect(res.statusCode).toBe(400)
        expect(findResumableRun).not.toHaveBeenCalled()
    })
})
