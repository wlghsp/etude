import type { FastifyPluginAsync } from "fastify"
import { adminMiddleware } from "../plugins/auth-guard.js";
import { createUser, resetPassword } from "../services/user.js";
import { getFeedbackList } from "../services/feedback.js";


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
}