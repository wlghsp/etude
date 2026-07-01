import type { FastifyPluginAsync } from "fastify";
import { authMiddleware } from "../plugins/auth-guard.js";
import { getLeaderboard, getProgress } from "../services/user.js";

export const userRoutes: FastifyPluginAsync = async (app) => {
    app.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
        return getProgress(request.user.userId)
    })

    app.get('/leaderboard', { preHandler: authMiddleware }, async (request: any) => {
        return getLeaderboard()
    })
}