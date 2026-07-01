import { verifyToken } from "../services/auth.js";

export async function authMiddleware(request: any, reply: any) {
    const auth = request.headers['authorization'] ?? ''
    const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
    if (!token) return reply.code(401).send({ error: '인증이 필요합니다.'})
    try {
        request.user = verifyToken(token)
    } catch {
        return reply.code(401).send({ error: '토큰이 유효하지 않습니다.'})
    }
}

export async function adminMiddleware(request: any, reply: any) {
    await authMiddleware(request, reply)
    if (request.user?.role !== 'admin') {
        return reply.code(403).send({ error: '관리자 권한이 필요합니다.'})
    }
}
