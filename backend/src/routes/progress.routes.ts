import type { FastifyPluginAsync } from "fastify";
import { authMiddleware } from "../plugins/auth-guard.js";
import { getLeaderboard, getSetProgress } from "../services/progress.js";
import { getReport } from "../services/report.js";
import { getGoals } from "../services/goals.js";
import { getReview } from "../services/review.js";
import { getWeeklyLeaderboard } from "../services/xp.js";
import { getGamification } from "../services/gamification.js";

export const progressRoutes: FastifyPluginAsync = async (app) => {
    app.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
        return getSetProgress(request.user.userId, request.user.role)
    })

    // 명예의 전당: 연속 학습, 이번 주 열공, 정답률 등 칭찬할 사람들 (docs/specs/spec_report.md)
    app.get('/report', { preHandler: authMiddleware }, async () => getReport())

    // 오늘의 목표·이달의 도전 (본인 기록만)
    app.get('/goals', { preHandler: authMiddleware }, async (request: any) => getGoals(request.user.userId))

    // 복습 허브 (본인 기록만)
    app.get('/review', { preHandler: authMiddleware }, async (request: any) => getReview(request.user.userId, request.user.role))

    // 이번 주 XP 순위 (최근 7일, 상위 10명 + 내 XP)
    app.get('/leaderboard/weekly', { preHandler: authMiddleware }, async (request: any) => getWeeklyLeaderboard(request.user.userId))

    // XP·레벨·배지·연속 학습일 (규칙의 기준은 서버)
    app.get('/gamification', { preHandler: authMiddleware }, async (request: any) => getGamification(request.user.userId))

    app.get('/leaderboard', { preHandler: authMiddleware }, async (request: any) => {
        return getLeaderboard()
    })
}