import type { FastifyPluginAsync } from "fastify";
import { authMiddleware } from "../plugins/auth-guard.js";
import { getLeaderboard, getSetProgress } from "../services/progress.js";

export const progressRoutes: FastifyPluginAsync = async (app) => {
    app.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
        return getSetProgress(request.user.userId, request.user.role)
    })

    app.get('/leaderboard', { preHandler: authMiddleware }, async (request: any) => {
        return getLeaderboard()
    })
}