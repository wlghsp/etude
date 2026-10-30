import type { FastifyPluginAsync } from "fastify";
import { authMiddleware } from "../plugins/auth-guard.js";
import { getLeaderboard, getSetProgress } from "../services/progress.js";
import { getReport } from "../services/report.js";

export const progressRoutes: FastifyPluginAsync = async (app) => {
    app.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
        return getSetProgress(request.user.userId, request.user.role)
    })

    // 명예의 전당: 연속 학습, 이번 주 열공, 정답률 등 칭찬할 사람들 (docs/specs/spec_report.md)
    app.get('/report', { preHandler: authMiddleware }, async () => getReport())

    app.get('/leaderboard', { preHandler: authMiddleware }, async (request: any) => {
        return getLeaderboard()
    })
}