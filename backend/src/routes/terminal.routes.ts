import type { FastifyPluginAsync } from "fastify"
import { docker } from "../plugins/docker.js"
import { handleTerminal } from "../services/terminal.js"


export const terminalRoutes: FastifyPluginAsync = async (app) => {
    app.get('/ws/terminal', { websocket: true}, (socket, req) => {
        const params = new URL(req.url, 'http://localhost').searchParams
        const sandboxType = params.get('sandboxType') ?? 'linux'
        const questId = params.get('questId') ? Number(params.get('questId')) : null
        const containerId = params.get('containerId') ?? null
        handleTerminal(socket, docker, sandboxType, questId, containerId).catch((err) => {
            console.error('terminal error:', err)
            socket.close()
        })
    })
}