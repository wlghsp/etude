import { randomBytes } from 'node:crypto'

export interface TerminalTicketInfo {
    userId: number
    questId: number
    questSetId: number
    sandboxType: string
}

const TTL_MS = 30_000

const tickets = new Map<string, TerminalTicketInfo & { expiresAt: number }>()

function purgeExpired(now: number) {
    for (const [ticket, entry] of tickets) {
        if (entry.expiresAt <= now) tickets.delete(ticket)
    }
}

// 일회용 ticket을 발급한다. 만료된 ticket은 이때 함께 정리한다 (별도 타이머 없음).
export function issueTicket(info: TerminalTicketInfo): string {
    const now = Date.now()
    purgeExpired(now)

    const ticket = randomBytes(32).toString('base64url')
    tickets.set(ticket, { ...info, expiresAt: now + TTL_MS })
    return ticket
}

// 조회와 삭제를 같은 동기 구간에서 하므로 같은 ticket은 두 번 소비될 수 없다.
// 만료된 ticket도 조회한 순간 지워진다.
export function consumeTicket(ticket: string): TerminalTicketInfo | null {
    const entry = tickets.get(ticket)
    if (!entry) return null

    tickets.delete(ticket)
    if (entry.expiresAt <= Date.now()) return null

    const { expiresAt: _expiresAt, ...info } = entry
    return info
}

export function pendingTicketCount(): number {
    return tickets.size
}
