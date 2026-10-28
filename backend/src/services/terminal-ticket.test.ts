import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { issueTicket, consumeTicket, pendingTicketCount } from './terminal-ticket.js'

const info = { userId: 7, questId: 101, questSetId: 12, sandboxType: 'k8s' }

// 테스트마다 가짜 시계를 앞으로만 보내서, 앞 테스트가 남긴 ticket이 항상 만료된 상태가 되게 한다
let clock = Date.now()

describe('terminal ticket', () => {
    beforeEach(() => {
        vi.useFakeTimers()
        clock += 120_000
        vi.setSystemTime(clock)
        issueTicket(info) // 발급 시 만료된 ticket을 정리한다 → 남는 것은 이 ticket 하나
    })

    afterEach(() => {
        vi.useRealTimers()
    })

    it('256비트 이상의 base64url ticket을 발급하고 매번 다르다', () => {
        const a = issueTicket(info)
        const b = issueTicket(info)

        expect(a).toMatch(/^[A-Za-z0-9_-]{43,}$/)
        expect(a).not.toBe(b)
    })

    it('발급할 때 넣은 정보를 소비할 때 돌려준다 (만료 시각은 노출하지 않는다)', () => {
        const ticket = issueTicket(info)

        expect(consumeTicket(ticket)).toEqual(info)
    })

    it('한 번만 소비된다 (재사용은 null)', () => {
        const ticket = issueTicket(info)

        expect(consumeTicket(ticket)).not.toBeNull()
        expect(consumeTicket(ticket)).toBeNull()
    })

    it('없는 ticket은 null', () => {
        expect(consumeTicket('does-not-exist')).toBeNull()
    })

    it('30초가 지나면 만료되고, 직전까지는 유효하다', () => {
        const valid = issueTicket(info)
        const expired = issueTicket(info)

        vi.advanceTimersByTime(29_999)
        expect(consumeTicket(valid)).toEqual(info)

        vi.advanceTimersByTime(2)
        expect(consumeTicket(expired)).toBeNull()
    })

    it('만료된 ticket을 소비 시도하면 저장소에서도 지워진다', () => {
        const before = pendingTicketCount()
        const ticket = issueTicket(info)
        vi.advanceTimersByTime(30_001)

        expect(consumeTicket(ticket)).toBeNull()
        expect(pendingTicketCount()).toBe(before)
    })

    it('새 ticket을 발급할 때 만료된 ticket을 함께 정리한다', () => {
        issueTicket(info)
        issueTicket(info)
        expect(pendingTicketCount()).toBe(3) // beforeEach의 ticket 포함

        vi.advanceTimersByTime(30_001)
        issueTicket(info)

        expect(pendingTicketCount()).toBe(1) // 만료된 3개는 사라지고 새 ticket만 남는다
    })
})
