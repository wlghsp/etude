import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { EventEmitter } from 'node:events'
import { startHeartbeat } from './heartbeat.js'

function fakeSocket() {
    const socket = new EventEmitter() as EventEmitter & { ping: any; terminate: any }
    socket.ping = vi.fn()
    socket.terminate = vi.fn()
    return socket
}

describe('startHeartbeat', () => {
    beforeEach(() => vi.useFakeTimers())
    afterEach(() => vi.useRealTimers())

    it('30초마다 ping을 보낸다', () => {
        const socket = fakeSocket()
        startHeartbeat(socket as any)

        vi.advanceTimersByTime(30_000)
        expect(socket.ping).toHaveBeenCalledTimes(1)

        socket.emit('pong')
        vi.advanceTimersByTime(30_000)
        expect(socket.ping).toHaveBeenCalledTimes(2)
        expect(socket.terminate).not.toHaveBeenCalled()
    })

    it('pong이 계속 오면 연결을 끊지 않는다', () => {
        const socket = fakeSocket()
        startHeartbeat(socket as any)

        for (let i = 0; i < 5; i++) {
            vi.advanceTimersByTime(30_000)
            socket.emit('pong')
        }

        expect(socket.terminate).not.toHaveBeenCalled()
    })

    it('직전 주기에 pong이 없으면 다음 주기에 terminate한다 (최대 약 60초)', () => {
        const socket = fakeSocket()
        startHeartbeat(socket as any)

        vi.advanceTimersByTime(30_000) // 첫 ping, pong 없음
        expect(socket.terminate).not.toHaveBeenCalled()

        vi.advanceTimersByTime(30_000) // 직전 주기에 pong이 없었음
        expect(socket.terminate).toHaveBeenCalledTimes(1)
    })

    it('terminate 이후에는 더 이상 ping하지 않는다', () => {
        const socket = fakeSocket()
        startHeartbeat(socket as any)

        vi.advanceTimersByTime(60_000)
        vi.advanceTimersByTime(120_000)

        expect(socket.terminate).toHaveBeenCalledTimes(1)
        expect(socket.ping).toHaveBeenCalledTimes(1)
    })

    it('연결이 닫히면 타이머를 해제한다', () => {
        const socket = fakeSocket()
        startHeartbeat(socket as any)

        socket.emit('close')

        expect(vi.getTimerCount()).toBe(0)
        vi.advanceTimersByTime(120_000)
        expect(socket.ping).not.toHaveBeenCalled()
        expect(socket.terminate).not.toHaveBeenCalled()
    })
})
