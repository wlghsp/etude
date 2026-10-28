import type { FastifyPluginAsync } from "fastify"
import { docker } from "../plugins/docker.js"
import { handleTerminal } from "../services/terminal.js"
import { authMiddleware } from "../plugins/auth-guard.js"
import { canAccessQuestSet, getQuestContext } from "../services/quest.js"
import { consumeTicket, issueTicket } from "../services/terminal-ticket.js"


export const terminalRoutes: FastifyPluginAsync = async (app) => {
    // 터미널 연결용 일회용 ticket 발급. 세트와 샌드박스 타입은 클라이언트가 아니라 questId로 DB에서 확정한다.
    app.post<{ Body: { questId?: unknown } | undefined }>('/terminal-sessions', { preHandler: authMiddleware }, async (req: any, reply) => {
        const questId = req.body?.questId
        if (typeof questId !== 'number' || !Number.isInteger(questId) || questId <= 0) {
            return reply.code(400).send({ error: 'questId가 올바르지 않습니다.' })
        }

        const quest = await getQuestContext(questId)
        if (!quest) return reply.code(404).send({ error: '퀘스트를 찾을 수 없습니다.' })

        const allowed = await canAccessQuestSet(req.user.userId, req.user.role, quest.questSetId)
        if (!allowed) return reply.code(403).send({ error: '이 퀘스트에 접근할 권한이 없습니다.' })

        const ticket = issueTicket({
            userId: req.user.userId,
            questId,
            questSetId: quest.questSetId,
            sandboxType: quest.sandboxType,
        })
        return { ticket }
    })

    // ticket만 받는다. 샌드박스 타입·퀘스트는 ticket에 담긴 서버 확정 값을 쓰고, 클라이언트가 컨테이너를 지정할 수 없다.
    app.get('/ws/terminal', { websocket: true }, (socket, req) => {
        const ticket = new URL(req.url, 'http://localhost').searchParams.get('ticket')
        const info = ticket ? consumeTicket(ticket) : null
        if (!info) {
            socket.close(1008, 'invalid or expired ticket')
            return
        }
        handleTerminal(socket, docker, info)
    })
}
