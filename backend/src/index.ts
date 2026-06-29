import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import Docker from 'dockerode'
import 'dotenv/config'
import { handleTerminal } from './terminal.js'
import { gradeQuest, getQuests, getQuestSets } from './quest.js'
import { login, verifyToken } from './auth.js'
import { createUser, getLeaderboard, getProgress, recordAttempt, resetPassword } from './user.js'

const fastify = Fastify({ logger: true })
const docker = new Docker()

async function authMiddleware(request: any, reply: any) {
    const auth = request.headers['authorization'] ?? ''
    const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
    if (!token) return reply.code(401).send({ error: '인증이 필요합니다.'})
    try {
        request.user = verifyToken(token)
    } catch {
        return reply.code(401).send({ error: '토큰이 유효하지 않습니다.'})
    }
}

async function adminMiddleware(request: any, reply: any) {
    await authMiddleware(request, reply)
    if (request.user?.role !== 'admin') {
        return reply.code(403).send({ error: '관리자 권한이 필요합니다.'})
    }
}

async function cleanupOrphanContainers() {
    const containers = await docker.listContainers({
        all: true,
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
    }
}

await cleanupOrphanContainers()

await fastify.register(cors, { origin: true })
await fastify.register(websocket)

await fastify.register(async function (app){
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
})

fastify.post('/auth/login', async (request, reply) => {
    const { email, password } = request.body as  { email: string; password: string }
    try {
        return await login(email, password)
    } catch (e: any) {
        return reply.code(401).send({ error: e.message })
    }
})

fastify.get('/me', { preHandler: authMiddleware }, async (request: any) => {
    return request.user
})

fastify.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
    return getProgress(request.user.userId)
})

fastify.get('/leaderboard', { preHandler: authMiddleware }, async () => {
    return getLeaderboard()
})

fastify.post('/admin/users', { preHandler: adminMiddleware }, async (request) => {
    const { name, email, password } = request.body as { name: string; email: string; password: string }
    return createUser(name, email, password)
})

fastify.patch('/admin/users/:id/password', { preHandler: adminMiddleware }, async (request) => {
    const { id } = request.params as { id: string}
    const { password } = request.params as { password: string}
    await resetPassword(id, password)
    return { ok: true }
})

fastify.get('/quest-sets', async () => getQuestSets())

fastify.get<{ Params: { id: string }}>('/quest-sets/:id/quests', async (req) => {
    return getQuests(Number(req.params.id))
})

fastify.post('/grade', async (req) => {
    const { containerId, questId, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed }
        = req.body as {
            containerId: string
            questId: number
            questSetId: number
            sessionId: string
            elapsedSec?: number
            hintUsed?: boolean
            solutionUsed?: boolean
        }
        const passed = await gradeQuest(containerId, questId, docker)

        const auth = req.headers['authorization'] ?? ''
        const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
        if (token) {
            try {
                const payload = verifyToken(token)
                await recordAttempt(payload.userId, questId, questSetId, sessionId, passed, elapsedSec, hintUsed, solutionUsed)
            } catch {} // 토큰 없거나 만료돼도 채점 결과는 정상 반환
        }

        return { passed }
    }
)

fastify.post<{ Body: { containerId: string } }>(
    '/session/end',
    async (req) => {
        const { containerId } = req.body
        const container = docker.getContainer(containerId)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
        return { ok: true }
    }
)

fastify.addHook('onClose', async () => {
    const containers = await docker.listContainers({
        filters: JSON.stringify({ label: ['etude=sandbox'] }),
    })
    for (const c of containers) {
        const container = docker.getContainer(c.Id)
        await container.stop().catch(() => {})
        await container.remove().catch(() => {})
    }
})

const shutdown = async () => {
    await fastify.close()
    process.exit()
}
process.on('SIGTERM', shutdown)
process.on('SIGINT', shutdown)

await fastify.listen({ port: 3001, host:'0.0.0.0'})