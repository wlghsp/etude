import type { FastifyPluginAsync } from "fastify";
import { authMiddleware } from "../plugins/auth-guard.js";
import { login } from "../services/auth.js";
import { changeOwnPassword } from "../services/user.js";

export const authRoutes: FastifyPluginAsync = async (app) => {
    app.post('/auth/login', async (request, reply) => {
        const { email, password } = request.body as { email: string; password: string }
        try {
            return await login(email, password)
        } catch (e: any) {
            return reply.code(401).send({ error: e.message })
        }
    })

    app.get('/me', { preHandler: authMiddleware }, async (request: any) => {
        return request.user
    })

     app.patch('/me/password', { preHandler: authMiddleware }, async (request: any, reply) => {
        const { currentPassword, newPassword } = request.body as { currentPassword: string; newPassword: string }
        try {
            await changeOwnPassword(request.user.userId, currentPassword, newPassword)
            return { ok: true }
        } catch (e: any) {
            return reply.code(401).send({ error: e.message })
        }
    })

}