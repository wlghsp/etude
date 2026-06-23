import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import Docker from 'dockerode'
import { handleTerminal } from './terminal.js'
import { gradeQuest, getQuests, getQuestSets } from './quest.js'

const fastify = Fastify({ logger: true })
const docker = new Docker()

await fastify.register(cors, { origin: 'http://localhost:5173' })
await fastify.register(websocket)

await fastify.register(async function (app){
    app.get('/ws/terminal', { websocket: true}, (socket, _req) => {
        handleTerminal(socket, docker).catch((err) => {
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