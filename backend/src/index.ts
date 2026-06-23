import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import { handleTerminal } from './terminal.js'


const fastify = Fastify({ logger: true })
await fastify.register(websocket)

await fastify.register(async function (app){
    app.get('/ws/terminal', { websocket: true}, (socket, _req) => {
        handleTerminal(socket).catch((err) => {
            console.error('terminal error:', err)
            socket.close()
        })
    })
})

await fastify.listen({ port: 3001, host:'0.0.0.0'})