import type { FastifyPluginAsync } from "fastify";
import { authMiddleware } from "../plugins/auth-guard.js";
import { getLeaderboard, getProgress } from "../services/progress.js";

export const progressRoutes: FastifyPluginAsync = async (app) => {
    app.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
        return getProgress(request.user.userId)
    })

    app.get('/leaderboard', { preHandler: authMiddleware }, async (request: any) => {
        return getLeaderboard()
    })
}