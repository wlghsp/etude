import { describe, it, expect, beforeAll, afterAll, beforeEach, vi } from 'vitest'
import type { FastifyInstance } from 'fastify'
import jwt from 'jsonwebtoken'

vi.hoisted(() => { process.env.JWT_SECRET = 'test-secret' })

vi.mock('../services/feed.js', async (importOriginal) => ({
    ...(await importOriginal<typeof import('../services/feed.js')>()),
    getFeed: vi.fn(), toggleLike: vi.fn(), addComment: vi.fn(), deleteComment: vi.fn(), getFeedSummary: vi.fn(), markFeedSeen: vi.fn(),
}))

import { buildApp } from '../app.js'
import { FeedError, addComment, deleteComment, getFeed, getFeedSummary, markFeedSeen, toggleLike } from '../services/feed.js'

const tokenFor = (userId: number, role = 'member') => jwt.sign({ userId, name: 't', email: 't@example.com', role }, 'test-secret')
const auth = (userId = 7, role = 'member') => ({ authorization: `Bearer ${tokenFor(userId, role)}` })

describe('피드 라우트', () => {
    let app: FastifyInstance
    beforeAll(async () => { app = await buildApp() })
    afterAll(async () => { await app.close() })
    beforeEach(() => vi.clearAllMocks())

    it('토큰이 없으면 모두 401 이고 서비스를 부르지 않는다', async () => {
        for (const [method, url] of [['GET', '/feed'], ['POST', '/feed/1/like'], ['POST', '/feed/1/comments'], ['DELETE', '/feed/comments/1'], ['GET', '/feed/summary'], ['POST', '/feed/seen']] as const) {
            const res = await app.inject({ method, url })
            expect(res.statusCode, `${method} ${url}`).toBe(401)
        }
        expect(getFeed).not.toHaveBeenCalled()
        expect(toggleLike).not.toHaveBeenCalled()
    })

    it('GET /feed 는 내 id·역할과 before·limit 으로 조회한다', async () => {
        vi.mocked(getFeed).mockResolvedValue([])

        const res = await app.inject({ method: 'GET', url: '/feed?before=50&limit=10', headers: auth(7, 'admin') })

        expect(res.statusCode).toBe(200)
        expect(getFeed).toHaveBeenCalledWith(7, 'admin', { before: 50, limit: 10 })
    })

    it('POST /feed/:id/like 는 결과를 돌려주고, 서비스 오류는 그 상태 코드로 보낸다', async () => {
        vi.mocked(toggleLike).mockResolvedValueOnce({ mine: ['clap'], counts: { like: 0, clap: 2, strong: 0, fire: 0 } })
        const ok = await app.inject({ method: 'POST', url: '/feed/5/like', headers: auth(), payload: { kind: 'clap' } })
        expect(ok.json()).toEqual({ mine: ['clap'], counts: { like: 0, clap: 2, strong: 0, fire: 0 } })
        expect(toggleLike).toHaveBeenCalledWith(7, 5, 'clap')

        vi.mocked(toggleLike).mockRejectedValueOnce(new FeedError(400, '내 소식에는 좋아요를 누를 수 없어요.'))
        const bad = await app.inject({ method: 'POST', url: '/feed/5/like', headers: auth() })
        expect(toggleLike).toHaveBeenLastCalledWith(7, 5, 'like') // 종류를 안 보내면 기본 좋아요
        expect(bad.statusCode).toBe(400)
        expect(bad.json()).toEqual({ error: '내 소식에는 좋아요를 누를 수 없어요.' })
    })

    it('소식 번호가 숫자가 아니면 400 이다', async () => {
        const res = await app.inject({ method: 'POST', url: '/feed/abc/like', headers: auth() })

        expect(res.statusCode).toBe(400)
        expect(toggleLike).not.toHaveBeenCalled()
    })

    it('POST /feed/:id/comments 는 본문을 서비스로 넘기고 429 같은 오류를 그대로 보낸다', async () => {
        vi.mocked(addComment).mockResolvedValueOnce({ id: 1, userId: 7, userName: '나', body: '굿', createdAt: 'x', canDelete: true })
        const ok = await app.inject({ method: 'POST', url: '/feed/5/comments', payload: { body: '굿' }, headers: auth() })
        expect(ok.statusCode).toBe(200)
        expect(addComment).toHaveBeenCalledWith(7, 5, '굿')

        vi.mocked(addComment).mockRejectedValueOnce(new FeedError(429, '너무 빨라요'))
        const slow = await app.inject({ method: 'POST', url: '/feed/5/comments', payload: { body: '굿' }, headers: auth() })
        expect(slow.statusCode).toBe(429)
    })

    it('DELETE /feed/comments/:id 는 내 id 와 역할로 지운다', async () => {
        vi.mocked(deleteComment).mockResolvedValue()

        const res = await app.inject({ method: 'DELETE', url: '/feed/comments/9', headers: auth(1, 'admin') })

        expect(res.statusCode).toBe(200)
        expect(deleteComment).toHaveBeenCalledWith(1, 'admin', 9)
    })

    it('summary 와 seen', async () => {
        vi.mocked(getFeedSummary).mockResolvedValue({ newForMe: 3 })
        vi.mocked(markFeedSeen).mockResolvedValue()

        expect((await app.inject({ method: 'GET', url: '/feed/summary', headers: auth() })).json()).toEqual({ newForMe: 3 })
        expect((await app.inject({ method: 'POST', url: '/feed/seen', headers: auth() })).statusCode).toBe(200)
        expect(markFeedSeen).toHaveBeenCalledWith(7)
    })

    it('서비스가 예상 못 한 오류를 던지면 500 이다', async () => {
        vi.mocked(getFeed).mockRejectedValueOnce(new Error('db down'))
        vi.spyOn(console, 'error').mockImplementation(() => {})

        const res = await app.inject({ method: 'GET', url: '/feed', headers: auth() })

        expect(res.statusCode).toBe(500)
    })
})
