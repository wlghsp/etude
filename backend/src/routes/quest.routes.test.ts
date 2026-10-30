import { describe, it, expect, beforeAll, afterAll, beforeEach, vi } from 'vitest'
import type { FastifyInstance } from 'fastify'
import jwt from 'jsonwebtoken'

vi.hoisted(() => {
    process.env.JWT_SECRET = 'test-secret'
})

vi.mock('../services/quest.js', async (importOriginal) => ({
    ...(await importOriginal<typeof import('../services/quest.js')>()),
    getQuestContext: vi.fn(),
    gradeQuest: vi.fn(),
}))
vi.mock('../services/progress.js', () => ({ recordAttempt: vi.fn(async () => {}) }))

import { buildApp } from '../app.js'
import { getQuestContext, gradeQuest } from '../services/quest.js'
import { recordAttempt } from '../services/progress.js'
import { registerSession, removeSession } from '../services/session-registry.js'

const getQuestContextMock = vi.mocked(getQuestContext)
const gradeQuestMock = vi.mocked(gradeQuest)

const tokenFor = (userId: number) =>
    jwt.sign({ userId, name: 'tester', email: 'tester@example.com', role: 'member' }, 'test-secret')

describe('POST /grade', () => {
    let app: FastifyInstance

    beforeAll(async () => {
        app = await buildApp()
    })

    afterAll(async () => {
        await app.close()
    })

    beforeEach(() => {
        vi.clearAllMocks()
        removeSession('c-mine')
        registerSession('c-mine', { userId: 7, questSetId: 11, sandboxType: 'docker' })
        getQuestContextMock.mockResolvedValue({ questSetId: 11, sandboxType: 'docker' })
        gradeQuestMock.mockResolvedValue({ passed: true, checks: null })
    })

    const grade = (body: object, token?: string) =>
        app.inject({
            method: 'POST',
            url: '/grade',
            payload: body,
            headers: token ? { authorization: `Bearer ${token}` } : {},
        })

    const body = { containerId: 'c-mine', questId: 101, questSetId: 999, sessionId: 'attempt-1', elapsedSec: 30 }

    it('토큰이 없으면 401이고 채점하지 않는다', async () => {
        const res = await grade(body)

        expect(res.statusCode).toBe(401)
        expect(gradeQuestMock).not.toHaveBeenCalled()
    })

    it('남의 컨테이너는 403이고 채점하지 않는다', async () => {
        const res = await grade(body, tokenFor(8))

        expect(res.statusCode).toBe(403)
        expect(gradeQuestMock).not.toHaveBeenCalled()
        expect(recordAttempt).not.toHaveBeenCalled()
    })

    it('레지스트리에 없는 컨테이너도 403이다', async () => {
        const res = await grade({ ...body, containerId: 'unknown' }, tokenFor(7))

        expect(res.statusCode).toBe(403)
        expect(gradeQuestMock).not.toHaveBeenCalled()
    })

    it('세션의 세트에 속하지 않은 퀘스트는 403이다', async () => {
        getQuestContextMock.mockResolvedValue({ questSetId: 22, sandboxType: 'docker' })

        const res = await grade(body, tokenFor(7))

        expect(res.statusCode).toBe(403)
        expect(gradeQuestMock).not.toHaveBeenCalled()
    })

    it('존재하지 않는 퀘스트는 404이다', async () => {
        getQuestContextMock.mockResolvedValue(null)

        const res = await grade(body, tokenFor(7))

        expect(res.statusCode).toBe(404)
        expect(gradeQuestMock).not.toHaveBeenCalled()
    })

    it('조건별 결과가 있으면 함께 돌려주고, 하나라도 실패하면 passed 는 false 로 기록한다', async () => {
        const checks = [{ label: '이름이 해석된다', passed: true }, { label: '파일이 있다', passed: false }]
        gradeQuestMock.mockResolvedValue({ passed: false, checks })

        const res = await grade(body, tokenFor(7))

        expect(res.json()).toEqual({ passed: false, checks })
        expect(recordAttempt).toHaveBeenCalledWith(7, 101, 11, 'attempt-1', false, 30, undefined, undefined)
    })

    it('채점 결과를 돌려주고, 기록에는 body가 아니라 서버가 조회한 questSetId를 쓴다', async () => {
        const res = await grade(body, tokenFor(7))

        expect(res.statusCode).toBe(200)
        expect(res.json()).toEqual({ passed: true })
        expect(gradeQuestMock).toHaveBeenCalledWith('c-mine', 101, expect.anything())
        expect(recordAttempt).toHaveBeenCalledWith(7, 101, 11, 'attempt-1', true, 30, undefined, undefined)
    })
})

describe('POST /session/end', () => {
    it('라우트가 존재하지 않는다', async () => {
        const app = await buildApp()
        const res = await app.inject({ method: 'POST', url: '/session/end', payload: { containerId: 'x' } })
        await app.close()

        expect(res.statusCode).toBe(404)
    })
})
