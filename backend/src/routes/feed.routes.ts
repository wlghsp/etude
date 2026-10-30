import type { FastifyPluginAsync } from "fastify";
import { authMiddleware } from "../plugins/auth-guard.js";
import { FeedError, addComment, deleteComment, getFeed, getFeedSummary, markFeedSeen, toggleLike } from "../services/feed.js";

// 활동 피드 (docs/specs/spec_activity_feed.md). 서비스의 FeedError 는 그 상태 코드와 메시지로, 그 밖의 오류는 500 으로 보낸다.
const parseId = (v: unknown): number | null => {
    const n = Number(v)
    return Number.isInteger(n) && n > 0 ? n : null
}

export const feedRoutes: FastifyPluginAsync = async (app) => {
    app.setErrorHandler(async (err: any, _req, reply) => {
        if (err instanceof FeedError) return reply.code(err.status).send({ error: err.message })
        console.error('[feed]', err)
        return reply.code(err.statusCode ?? 500).send({ error: '요청을 처리하지 못했어요.' })
    })

    app.get('/feed', { preHandler: authMiddleware }, async (req: any) => {
        const before = parseId(req.query?.before)
        const limit = Number(req.query?.limit)
        return getFeed(req.user.userId, req.user.role, { before: before ?? undefined, limit: Number.isFinite(limit) ? limit : undefined })
    })

    app.get('/feed/summary', { preHandler: authMiddleware }, async (req: any) => getFeedSummary(req.user.userId))

    app.post('/feed/seen', { preHandler: authMiddleware }, async (req: any) => {
        await markFeedSeen(req.user.userId)
        return { ok: true }
    })

    app.post('/feed/:id/like', { preHandler: authMiddleware }, async (req: any, reply) => {
        const id = parseId(req.params.id)
        if (id === null) return reply.code(400).send({ error: '소식 번호가 올바르지 않아요.' })
        return toggleLike(req.user.userId, id)
    })

    app.post('/feed/:id/comments', { preHandler: authMiddleware }, async (req: any, reply) => {
        const id = parseId(req.params.id)
        if (id === null) return reply.code(400).send({ error: '소식 번호가 올바르지 않아요.' })
        return addComment(req.user.userId, id, req.body?.body)
    })

    app.delete('/feed/comments/:id', { preHandler: authMiddleware }, async (req: any, reply) => {
        const id = parseId(req.params.id)
        if (id === null) return reply.code(400).send({ error: '댓글 번호가 올바르지 않아요.' })
        await deleteComment(req.user.userId, req.user.role, id)
        return { ok: true }
    })
}
