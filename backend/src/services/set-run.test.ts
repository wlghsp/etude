import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { remainingSec, isExpired, startRun, checkRun, EXPIRY_GRACE_SEC } from './set-run.js'

const q = vi.mocked(db.query)

describe('remainingSec / isExpired', () => {
    it('남은 시간은 제한에서 경과를 뺀 값이고 0 아래로 내려가지 않는다', () => {
        expect(remainingSec(600, 100)).toBe(500)
        expect(remainingSec(600, 600)).toBe(0)
        expect(remainingSec(600, 9999)).toBe(0)
    })

    it(`마감은 제한을 넘고 여유 ${EXPIRY_GRACE_SEC}초까지 지난 뒤부터다`, () => {
        expect(isExpired(600, 600)).toBe(false)
        expect(isExpired(600, 600 + EXPIRY_GRACE_SEC)).toBe(false)
        expect(isExpired(600, 600 + EXPIRY_GRACE_SEC + 1)).toBe(true)
    })
})

describe('startRun', () => {
    beforeEach(() => vi.clearAllMocks())

    it('시간 제한이 없는 세트는 아무것도 기록하지 않고 null 을 돌려준다', async () => {
        q.mockResolvedValueOnce([[{ time_limit_sec: null }]] as any)

        expect(await startRun(7, 3, 's1')).toEqual({ limitSec: null, remainingSec: null })
        expect(q).toHaveBeenCalledTimes(1)
    })

    it('시간 제한 세트는 시작 시각을 (이미 있으면 유지하며) 기록하고 DB 시각 기준 남은 시간을 돌려준다', async () => {
        q.mockResolvedValueOnce([[{ time_limit_sec: 600 }]] as any)
            .mockResolvedValueOnce([{}] as any)
            .mockResolvedValueOnce([[{ elapsed: 120 }]] as any)

        expect(await startRun(7, 3, 's1')).toEqual({ limitSec: 600, remainingSec: 480 })
        expect(String(q.mock.calls[1]![0])).toMatch(/INSERT IGNORE INTO set_run/)
        expect(q.mock.calls[1]![1]).toEqual([7, 3, 's1'])
    })

    it('없는 세트는 시간 제한이 없는 것으로 본다', async () => {
        q.mockResolvedValueOnce([[]] as any)

        expect(await startRun(7, 999, 's1')).toEqual({ limitSec: null, remainingSec: null })
    })
})

describe('checkRun', () => {
    beforeEach(() => vi.clearAllMocks())

    it('시간 제한이 없는 세트는 항상 허용한다', async () => {
        q.mockResolvedValueOnce([[{ time_limit_sec: null }]] as any)

        expect(await checkRun(7, 3, 's1')).toEqual({ ok: true })
    })

    it('시간 제한 세트인데 시작 기록이 없으면 not_started 로 거부한다', async () => {
        q.mockResolvedValueOnce([[{ time_limit_sec: 600 }]] as any).mockResolvedValueOnce([[]] as any)

        expect(await checkRun(7, 3, 's1')).toEqual({ ok: false, reason: 'not_started' })
    })

    it('마감이 지났으면 expired, 아니면 허용한다', async () => {
        q.mockResolvedValueOnce([[{ time_limit_sec: 600 }]] as any).mockResolvedValueOnce([[{ elapsed: 700 }]] as any)
        expect(await checkRun(7, 3, 's1')).toEqual({ ok: false, reason: 'expired' })

        q.mockResolvedValueOnce([[{ time_limit_sec: 600 }]] as any).mockResolvedValueOnce([[{ elapsed: 300 }]] as any)
        expect(await checkRun(7, 3, 's1')).toEqual({ ok: true })
    })
})
