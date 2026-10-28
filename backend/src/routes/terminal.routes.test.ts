import { describe, it, expect, beforeAll, afterAll, beforeEach, vi } from 'vitest'
import type { FastifyInstance } from 'fastify'
import jwt from 'jsonwebtoken'

// authMiddleware가 쓰는 JWT_SECRET은 모듈 import 시점에 읽히므로 import보다 먼저 고정한다
vi.hoisted(() => {
    process.env.JWT_SECRET = 'test-secret'
})

vi.mock('../services/quest.js', async (importOriginal) => ({
    ...(await importOriginal<typeof import('../services/quest.js')>()),
    getQuestContext: vi.fn(),
    canAccessQuestSet: vi.fn(),
}))

import { buildApp } from '../app.js'
import { getQuestContext, canAccessQuestSet } from '../services/quest.js'
import { consumeTicket, pendingTicketCount } from '../services/terminal-ticket.js'

const getQuestContextMock = vi.mocked(getQuestContext)
const canAccessQuestSetMock = vi.mocked(canAccessQuestSet)

function tokenFor(userId: number, role = 'member') {
    return jwt.sign({ userId, name: 'tester', email: 'tester@example.com', role }, 'test-secret')
}

describe('POST /terminal-sessions', () => {
    let app: FastifyInstance

    beforeAll(async () => {
        app = await buildApp()
    })

    afterAll(async () => {
        await app.close()
    })

    beforeEach(() => {
        getQuestContextMock.mockReset()
        canAccessQuestSetMock.mockReset()
    })

    const post = (body: unknown, token?: string) =>
        app.inject({
            method: 'POST',
            url: '/terminal-sessions',
            payload: body as object,
            headers: token ? { authorization: `Bearer ${token}` } : {},
        })

    it('토큰이 없으면 401이고 ticket을 발급하지 않는다', async () => {
        const before = pendingTicketCount()

        const res = await post({ questId: 101 })

        expect(res.statusCode).toBe(401)
        expect(pendingTicketCount()).toBe(before)
        expect(getQuestContextMock).not.toHaveBeenCalled()
    })

    it('유효하지 않은 토큰이면 401', async () => {
        const res = await post({ questId: 101 }, 'not-a-jwt')

        expect(res.statusCode).toBe(401)
    })

    it.each([
        ['questId 없음', {}],
        ['문자열', { questId: '101' }],
        ['소수', { questId: 1.5 }],
        ['0', { questId: 0 }],
        ['음수', { questId: -3 }],
        ['null', { questId: null }],
    ])('questId가 올바르지 않으면(%s) 400이고 DB를 조회하지 않는다', async (_label, body) => {
        const res = await post(body, tokenFor(7))

        expect(res.statusCode).toBe(400)
        expect(getQuestContextMock).not.toHaveBeenCalled()
    })

    it('없는 퀘스트는 404', async () => {
        getQuestContextMock.mockResolvedValue(null)

        const res = await post({ questId: 999 }, tokenFor(7))

        expect(res.statusCode).toBe(404)
        // 라우트가 없어서 나온 404와 구분하기 위해, 실제로 퀘스트를 조회했는지도 확인한다
        expect(getQuestContextMock).toHaveBeenCalledWith(999)
        expect(canAccessQuestSetMock).not.toHaveBeenCalled()
    })

    it('접근 권한이 없으면 403이고 ticket을 발급하지 않는다', async () => {
        getQuestContextMock.mockResolvedValue({ questSetId: 12, sandboxType: 'k8s' })
        canAccessQuestSetMock.mockResolvedValue(false)
        const before = pendingTicketCount()

        const res = await post({ questId: 101 }, tokenFor(7, 'member'))

        expect(res.statusCode).toBe(403)
        expect(pendingTicketCount()).toBe(before)
        // 권한 확인은 토큰의 사용자와, DB에서 조회한 세트 ID로 한다
        expect(canAccessQuestSetMock).toHaveBeenCalledWith(7, 'member', 12)
    })

    it('권한이 있으면 ticket을 돌려주고, 연결된 정보는 서버가 확정한 값이다', async () => {
        getQuestContextMock.mockResolvedValue({ questSetId: 12, sandboxType: 'k8s' })
        canAccessQuestSetMock.mockResolvedValue(true)

        // 클라이언트가 sandboxType, questSetId, userId를 보내도 무시되어야 한다
        const res = await post(
            { questId: 101, sandboxType: 'docker-persistent', questSetId: 1, userId: 999 },
            tokenFor(7),
        )

        expect(res.statusCode).toBe(200)
        const { ticket } = res.json()
        expect(ticket).toMatch(/^[A-Za-z0-9_-]{43,}$/)
        expect(consumeTicket(ticket)).toEqual({
            userId: 7,
            questId: 101,
            questSetId: 12,
            sandboxType: 'k8s',
        })
    })

    it('발급된 ticket은 한 번만 소비된다', async () => {
        getQuestContextMock.mockResolvedValue({ questSetId: 12, sandboxType: 'k8s' })
        canAccessQuestSetMock.mockResolvedValue(true)

        const { ticket } = (await post({ questId: 101 }, tokenFor(7))).json()

        expect(consumeTicket(ticket)).not.toBeNull()
        expect(consumeTicket(ticket)).toBeNull()
    })
})
