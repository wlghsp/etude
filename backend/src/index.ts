import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import Docker from 'dockerode'
import 'dotenv/config'
import { handleTerminal } from './terminal.js'
import { gradeQuest, getQuests, getQuestSets } from './quest.js'

const fastify = Fastify({ logger: true })
const docker = new Docker()

await fastify.register(cors, { origin: true })
await fastify.register(websocket)

await fastify.register(async function (app){
    app.get('/ws/terminal', { websocket: true}, (socket, req) => {
        const params = new URL(req.url, 'http://localhost').searchParams
        const sandboxType = params.get('sandboxType') ?? 'linux'
        const questId = params.get('questId') ? Number(params.get('questId')) : null
        handleTerminal(socket, docker, sandboxType, questId).catch((err) => {
            console.error('terminal error:', err)
            socket.close()
        })
    })
})

fastify.get('/quest-sets', async () => getQuestSets())

fastify.get<{ Params: { id: string }}>('/quest-sets/:id/quests', async (req) => {
    return getQuests(Number(req.params.id))
})

fastify.post<{ Body: { containerId: string; questId: number }}>(
    '/grade',
    async (req) => {
        const { containerId, questId } = req.body
        const passed = await gradeQuest(containerId, questId, docker)
        return { passed }
    }
)

await fastify.listen({ port: 3001, host:'0.0.0.0'})