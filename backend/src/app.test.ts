import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import type { FastifyInstance } from 'fastify'
import { buildApp } from './app.js'

describe('GET /progress', () => {
    let app: FastifyInstance

    beforeAll(async () => {
        app = await buildApp()
    })

    afterAll(async () => {
        await app.close()
    })

    it('토큰이 없으면 401을 돌려준다', async () => {
        const res = await app.inject({ method: 'GET', url: '/progress' })

        expect(res.statusCode).toBe(401)
        expect(res.json()).toEqual({ error: '인증이 필요합니다.' })
    })
})
