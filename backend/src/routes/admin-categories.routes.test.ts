import { describe, it, expect, beforeAll, afterAll, beforeEach, vi } from 'vitest'
import type { FastifyInstance } from 'fastify'
import jwt from 'jsonwebtoken'

vi.hoisted(() => { process.env.JWT_SECRET = 'test-secret' })

const mem = vi.hoisted(() => ({ calls: [] as Array<[string, any[]]>, known: new Set(['k8s', '리눅스']) }))
vi.mock('../db.js', () => ({
    db: {
        query: vi.fn(async (sql: string, params: any[] = []) => {
            const s = sql.replace(/\s+/g, ' ').trim()
            mem.calls.push([s, params])
            if (s.startsWith('SELECT 1 FROM quest_set WHERE category')) return [mem.known.has(params[0]) ? [{ 1: 1 }] : []]
            return [[]]
        }),
    },
}))

import { buildApp } from '../app.js'

const auth = (role: string) => ({ authorization: `Bearer ${jwt.sign({ userId: 1, name: 't', email: 't@example.com', role }, 'test-secret')}` })
const writes = () => mem.calls.filter(([s]) => /^(INSERT|DELETE|UPDATE)/.test(s))

describe('대분류 공개 제어 API', () => {
    let app: FastifyInstance
    beforeAll(async () => { app = await buildApp() })
    afterAll(async () => { await app.close() })
    beforeEach(() => { mem.calls.length = 0 })

    it('관리자가 아니면 403 이고 아무것도 쓰지 않는다', async () => {
        for (const [method, url, payload] of [
            ['GET', '/admin/categories', undefined],
            ['PATCH', '/admin/categories/k8s', { is_public: false }],
            ['POST', '/admin/categories/k8s/access', { userId: 3 }],
            ['DELETE', '/admin/categories/k8s/access/3', undefined],
        ] as const) {
            const r = await app.inject({ method, url, headers: auth('member'), payload })
            expect(r.statusCode, `${method} ${url}`).toBe(403)
        }
        expect(writes()).toHaveLength(0)
    })

    it('로그인하지 않으면 401 이다', async () => {
        const r = await app.inject({ method: 'PATCH', url: '/admin/categories/k8s', payload: { is_public: false } })
        expect(r.statusCode).toBe(401)
    })

    it('관리자는 대분류를 비공개로 바꿀 수 있다', async () => {
        const r = await app.inject({ method: 'PATCH', url: '/admin/categories/k8s', headers: auth('admin'), payload: { is_public: false } })
        expect(r.statusCode).toBe(200)
        expect(writes()[0]![0]).toContain('INSERT INTO category_setting')
        expect(writes()[0]![1]).toEqual(['k8s', false])
    })

    it('is_public 이 boolean 이 아니면 400, 없는 대분류는 404 (쓰기 없음)', async () => {
        const bad = await app.inject({ method: 'PATCH', url: '/admin/categories/k8s', headers: auth('admin'), payload: { is_public: 'false' } })
        expect(bad.statusCode).toBe(400)
        const none = await app.inject({ method: 'PATCH', url: '/admin/categories/없는분야', headers: auth('admin'), payload: { is_public: false } })
        expect(none.statusCode).toBe(404)
        expect(writes()).toHaveLength(0)
    })

    it('접근 허용은 정수 userId 만 받고, 없는 대분류는 404 이다', async () => {
        const bad = await app.inject({ method: 'POST', url: '/admin/categories/k8s/access', headers: auth('admin'), payload: { userId: '3; DROP' } })
        expect(bad.statusCode).toBe(400)
        const none = await app.inject({ method: 'POST', url: '/admin/categories/없는분야/access', headers: auth('admin'), payload: { userId: 3 } })
        expect(none.statusCode).toBe(404)
        expect(writes()).toHaveLength(0)
        const ok = await app.inject({ method: 'POST', url: '/admin/categories/k8s/access', headers: auth('admin'), payload: { userId: 3 } })
        expect(ok.statusCode).toBe(200)
        expect(writes()[0]![1]).toEqual(['k8s', 3])
    })

    it('접근 회수', async () => {
        const r = await app.inject({ method: 'DELETE', url: '/admin/categories/k8s/access/3', headers: auth('admin') })
        expect(r.statusCode).toBe(200)
        expect(writes()[0]![1]).toEqual(['k8s', 3])
    })
})
