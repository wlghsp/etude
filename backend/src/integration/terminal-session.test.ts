import { describe, it, expect, beforeAll, afterAll, beforeEach, vi } from 'vitest'
import type { FastifyInstance } from 'fastify'
import { PassThrough } from 'node:stream'
import jwt from 'jsonwebtoken'

vi.hoisted(() => {
    process.env.JWT_SECRET = 'test-secret'
})

// 경계 밖(Docker, DB)만 대체하고 라우트·ticket·handleTerminal·heartbeat·세션 레지스트리는 실제 코드를 쓴다.
const { containers, fakeDocker } = vi.hoisted(() => {
    const containers: Array<{ id: string; remove: ReturnType<typeof vi.fn> }> = []
    let seq = 0 // 테스트 사이에 ID가 겹치지 않게 리셋하지 않는다
    const fakeDocker = {
        createContainer: async () => {
            const stream = new PassThrough()
            const container = {
                id: `container-${++seq}`,
                start: async () => {},
                stop: async () => {},
                remove: vi.fn(async () => {}),
                attach: async () => stream,
                exec: async () => ({
                    start: async () => stream,
                    inspect: async () => ({ Running: false }),
                    resize: async () => {},
                }),
            }
            containers.push(container)
            return container
        },
        getContainer: () => ({}),
    }
    return { containers, fakeDocker }
})

vi.mock('../plugins/docker.js', () => ({ docker: fakeDocker }))
vi.mock('../services/sandbox.js', () => ({
    getSandboxConfig: async () => ({ image: 'ubuntu', binds: null, persistent: true }),
}))
vi.mock('../services/quest.js', async (importOriginal) => ({
    ...(await importOriginal<typeof import('../services/quest.js')>()),
    getQuestContext: vi.fn(),
    canAccessQuestSet: vi.fn(async () => true),
    getSetupCmd: vi.fn(async () => null),
    gradeQuest: vi.fn(async () => ({ passed: true, checks: null })),
}))
vi.mock('../services/set-run.js', () => ({ checkRun: vi.fn(async () => ({ ok: true })), startRun: vi.fn() }))
vi.mock('../services/progress.js', () => ({ recordAttempt: vi.fn(async () => {}) }))

import { buildApp } from '../app.js'
import { getQuestContext, gradeQuest } from '../services/quest.js'
import { getSession } from '../services/session-registry.js'

const tokenFor = (userId: number) =>
    jwt.sign({ userId, name: 'tester', email: 'tester@example.com', role: 'member' }, 'test-secret')

const flush = () => new Promise((r) => setTimeout(r, 0))

describe('터미널 세션 통합 (ticket → WebSocket → 채점 → 정리)', () => {
    let app: FastifyInstance

    beforeAll(async () => {
        app = await buildApp()
        await app.ready()
    })

    afterAll(async () => {
        await app.close()
    })

    beforeEach(() => {
        containers.length = 0
        vi.mocked(gradeQuest).mockClear()
        vi.mocked(getQuestContext).mockImplementation(async (questId: number) =>
            questId === 101 ? { questSetId: 11, sandboxType: 'docker-persistent' }
                : questId === 201 ? { questSetId: 22, sandboxType: 'docker-persistent' }
                // 준비 단계에 setInterval 폴링이 없는 샌드박스 (fake timers 테스트용)
                : questId === 301 ? { questSetId: 33, sandboxType: 'linux' }
                : null)
    })

    async function connect(userId: number, questId = 101) {
        const res = await app.inject({
            method: 'POST',
            url: '/terminal-sessions',
            payload: { questId },
            headers: { authorization: `Bearer ${tokenFor(userId)}` },
        })
        const { ticket } = res.json()

        const ws = await app.injectWS(`/ws/terminal?ticket=${ticket}`)
        const connected = await new Promise<{ type: string; containerId: string }>((resolve) =>
            ws.once('message', (data: Buffer) => resolve(JSON.parse(data.toString()))))
        return { ws, containerId: connected.containerId, connected }
    }

    async function closeAndWait(ws: { terminate: () => void }, containerId: string) {
        ws.terminate()
        await vi.waitFor(() => expect(getSession(containerId)).toBeUndefined())
    }

    const grade = (userId: number, containerId: string, questId: number) =>
        app.inject({
            method: 'POST',
            url: '/grade',
            payload: { containerId, questId, sessionId: 's-1' },
            headers: { authorization: `Bearer ${tokenFor(userId)}` },
        })

    it('정상 ticket으로 연결하면 connected를 받고 세션이 소유자로 등록된다', async () => {
        const { ws, containerId, connected } = await connect(7)

        expect(connected.type).toBe('connected')
        expect(getSession(containerId)).toEqual({ userId: 7, questSetId: 11, sandboxType: 'docker-persistent' })
        await closeAndWait(ws, containerId)
    })

    it('본인 세션은 채점되고, 다른 사용자의 채점 요청은 403이다', async () => {
        const { ws, containerId } = await connect(7)

        expect((await grade(7, containerId, 101)).statusCode).toBe(200)
        expect(gradeQuest).toHaveBeenCalledTimes(1)

        expect((await grade(8, containerId, 101)).statusCode).toBe(403)
        expect(gradeQuest).toHaveBeenCalledTimes(1)
        await closeAndWait(ws, containerId)
    })

    it('다른 세트의 퀘스트로 채점하면 403이다', async () => {
        const { ws, containerId } = await connect(7, 101)

        expect((await grade(7, containerId, 201)).statusCode).toBe(403)
        expect(gradeQuest).not.toHaveBeenCalled()
        await closeAndWait(ws, containerId)
    })

    it('연결이 닫히면 컨테이너를 삭제하고 세션을 제거한다 (persistent 포함)', async () => {
        const { ws, containerId } = await connect(7)

        ws.terminate() // injectWS의 가상 스트림은 종료되지 않아 정상 close 핸드셰이크가 끝나지 않는다
        await vi.waitFor(() => expect(getSession(containerId)).toBeUndefined())

        expect(containers[0].remove).toHaveBeenCalled()
        expect((await grade(7, containerId, 101)).statusCode).toBe(403)
    })

    // 30초 heartbeat 타이머만 가로채 콜백을 직접 호출한다 (다른 타이머는 실제 동작)
    function captureHeartbeat() {
        const realSetInterval = globalThis.setInterval
        const ticks: Array<() => void> = []
        const spy = vi.spyOn(globalThis, 'setInterval').mockImplementation(((fn: () => void, ms?: number, ...args: unknown[]) => {
            if (ms === 30_000) {
                ticks.push(fn)
                return { unref() {} } as unknown as NodeJS.Timeout
            }
            return realSetInterval(fn, ms, ...args)
        }) as typeof setInterval)
        return { ticks, restore: () => spy.mockRestore() }
    }

    // injectWS 클라이언트는 ping에 pong을 자동으로 응답하지 않으므로, 브라우저처럼 응답하게 하려면 직접 보낸다.
    it('pong을 응답하는 연결은 여러 주기가 지나도 유지된다', async () => {
        const hb = captureHeartbeat()
        try {
            const { ws, containerId } = await connect(7)
            ws.on('ping', () => ws.pong())

            for (let i = 0; i < 3; i++) {
                hb.ticks[0]()
                await flush()
            }

            expect(getSession(containerId)).toBeDefined()
            expect(containers[0].remove).not.toHaveBeenCalled()
            await closeAndWait(ws, containerId)
        } finally {
            hb.restore()
        }
    })

    it('pong을 보내지 않는 연결은 제한 시간 안에 끊기고 같은 경로로 정리된다', async () => {
        const hb = captureHeartbeat()
        try {
            const { containerId } = await connect(7)
            expect(hb.ticks).toHaveLength(1)

            hb.ticks[0]() // 첫 ping: 아직 끊지 않는다
            await flush()
            expect(getSession(containerId)).toBeDefined()

            hb.ticks[0]() // pong 없이 한 주기 경과 → terminate
            await vi.waitFor(() => expect(getSession(containerId)).toBeUndefined())
            expect(containers[0].remove).toHaveBeenCalled()
        } finally {
            hb.restore()
        }
    })
})
