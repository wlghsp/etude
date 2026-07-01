import type { FastifyPluginAsync } from "fastify";
import { docker } from "../plugins/docker.js";

export const sessionRoutes: FastifyPluginAsync = async (app) => {
    app.post<{ Body: { containerId: string }}>('/session/end', async (req) => {
        const { containerId } = req.body
        const container = docker.getContainer(containerId)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
        return { ok: true }
    })
}