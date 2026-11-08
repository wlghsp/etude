import type { FastifyPluginAsync } from "fastify"
import { adminMiddleware } from "../plugins/auth-guard.js";
import { createUser, getAllUsers, resetPassword } from "../services/user.js";
import { getFeedbackList } from "../services/feedback.js";
import { deleteAttachment, deleteFeedbackAttachments, getAttachment } from "../services/feedback-attachments.js";
import { getQuestSetsForAdmin, grantQuestSetAccess, revokeQuestSetAccess, setQuestSetPublic } from "../services/quest.js";


export const adminRoutes: FastifyPluginAsync = async (app) => {
    app.post('/admin/users', { preHandler: adminMiddleware }, async (request) => {
        const { name, email, password } = request.body as { name: string; email: string; password: string }
        return createUser(name, email, password)
    })

    app.patch('/admin/users/:id/password', { preHandler: adminMiddleware }, async (request) => {
        const { id } = request.params as { id: string}
        const { password } = request.body as { password: string}
        await resetPassword(id, password)
        return { ok: true }
    })

    app.get('/admin/feedback', { preHandler: adminMiddleware }, async () => getFeedbackList())

    app.get<{ Params: { id: string } }>('/admin/feedback/attachments/:id', { preHandler: adminMiddleware }, async (request, reply) => {
        const id = Number(request.params.id)
        const attachment = Number.isInteger(id) ? await getAttachment(id) : null
        if (!attachment) return reply.code(404).send({ error: '첨부를 찾을 수 없습니다.' })
        return reply
            .type(attachment.mime)
            .header('X-Content-Type-Options', 'nosniff')
            .header('Content-Disposition', `attachment; filename="feedback-${attachment.feedback_id}-${attachment.id}"`)
            .send(attachment.data)
    })

    app.delete<{ Params: { id: string } }>('/admin/feedback/attachments/:id', { preHandler: adminMiddleware }, async (request, reply) => {
        const id = Number(request.params.id)
        if (!Number.isInteger(id)) return reply.code(400).send({ error: '잘못된 번호입니다.' })
        await deleteAttachment(id)
        return { ok: true }
    })

    app.delete<{ Params: { id: string } }>('/admin/feedback/:id/attachments', { preHandler: adminMiddleware }, async (request, reply) => {
        const id = Number(request.params.id)
        if (!Number.isInteger(id)) return reply.code(400).send({ error: '잘못된 번호입니다.' })
        await deleteFeedbackAttachments(id)
        return { ok: true }
    })

    app.get('/admin/users', { preHandler: adminMiddleware }, async () => getAllUsers())

    app.get('/admin/quest-sets', { preHandler: adminMiddleware }, async () => getQuestSetsForAdmin())

    app.patch<{ Params: { id: string }}>('/admin/quest-sets/:id', { preHandler: adminMiddleware }, async (request) => {
        const { id } = request.params
        const { is_public } = request.body as { is_public: boolean}
        await setQuestSetPublic(Number(id), is_public)
        return { ok: true }
    })

    app.post<{ Params: { id: string }}>('/admin/quest-sets/:id/access', { preHandler: adminMiddleware }, async (request) => {
        const { id } = request.params
        const { userId } = request.body as { userId: number}
        await grantQuestSetAccess(Number(id), userId)
        return { ok: true }
    })

    app.delete<{ Params: { id: string; userId: string }}>('/admin/quest-sets/:id/access/:userId', { preHandler: adminMiddleware }, async (request) => {
        const { id, userId } = request.params
        await revokeQuestSetAccess(Number(id), Number(userId))
        return { ok: true }
    })


}