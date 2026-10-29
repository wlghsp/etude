import { describe, it, expect, vi, beforeEach } from 'vitest'
import Fastify from 'fastify'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { healthRoutes } from './health.routes.js'

describe('GET /health', () => {
    async function app() {
        const a = Fastify()
        await a.register(healthRoutes)
        return a
    }

    beforeEach(() => vi.clearAllMocks())

    it('DB에 닿으면 200 ok', async () => {
        vi.mocked(db.query).mockResolvedValue([[{ 1: 1 }]] as any)

        const res = await (await app()).inject({ method: 'GET', url: '/health' })

        expect(res.statusCode).toBe(200)
        expect(res.json()).toEqual({ status: 'ok' })
        expect(db.query).toHaveBeenCalledWith('SELECT 1')
    })

    it('DB에 닿지 못하면 503 (헬스체크가 실패해 nginx가 기다린다)', async () => {
        vi.mocked(db.query).mockRejectedValue(new Error('ECONNREFUSED'))

        const res = await (await app()).inject({ method: 'GET', url: '/health' })

        expect(res.statusCode).toBe(503)
        expect(res.json()).toEqual({ status: 'unavailable' })
    })
})
