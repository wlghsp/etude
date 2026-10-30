import { describe, it, expect, vi } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { levelOf, weeklyXp, getWeeklyLeaderboard, type CompletionRec } from './xp.js'

let nid = 1
const rec = (setId: number, day: string, o: Partial<CompletionRec> = {}): CompletionRec =>
    ({ id: nid++, questSetId: setId, day, questCount: 4, hintFree: 0, solutionFree: 0, ...o })

describe('levelOf', () => {
    it('누적 XP 100 에서 Lv.2, 300 에서 Lv.3 이 된다', () => {
        expect([levelOf(0), levelOf(99), levelOf(100), levelOf(299), levelOf(300)]).toEqual([1, 1, 2, 2, 3])
    })
})

describe('weeklyXp', () => {
    it('최근 7일(오늘 포함) 완료가 그때 늘린 XP 만 더하고, 일주일 넘은 완료는 세지 않는다', () => {
        nid = 1
        const recs = [rec(1, '2026-10-20'), rec(2, '2026-10-25'), rec(3, '2026-10-30')]

        // 오늘 포함 7일 = 10-24 ~ 10-30: 세트 2 (40 XP) + 세트 3 (40 XP)
        expect(weeklyXp(recs, '2026-10-30')).toBe(80)
    })

    it('같은 세트를 다시 끝내면 복습 5 XP, 처음 퍼펙트가 되면 퍼펙트 보너스가 늘어난 만큼만 센다', () => {
        nid = 1
        const recs = [rec(1, '2026-10-20'), rec(1, '2026-10-29', { hintFree: 4, solutionFree: 4 })]

        // 두 번째 완료: 복습 5 + 퍼펙트 보너스 4×5 = 25
        expect(weeklyXp(recs, '2026-10-30')).toBe(25)
    })

    it('기록이 없으면 0', () => {
        expect(weeklyXp([], '2026-10-30')).toBe(0)
    })
})

describe('getWeeklyLeaderboard', () => {
    const row = (id: number, user: number, set: number, day: string) => ({ id, user_id: user, quest_set_id: set, day, quest_count: 4, hint_free_count: 0, solution_free_count: 0 })

    it('회원의 이번 주 XP 를 높은 순으로 돌려주고 XP 0 인 사람은 넣지 않는다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ id: 1, name: '가' }, { id: 2, name: '나' }, { id: 3, name: '다' }]] as any) // 회원
            .mockResolvedValueOnce([[{ today: '2026-10-30' }]] as any)
            .mockResolvedValueOnce([[row(1, 1, 1, '2026-10-29'), row(2, 2, 1, '2026-10-30'), row(3, 2, 2, '2026-10-30'), row(4, 3, 1, '2026-10-01')]] as any)

        const r = await getWeeklyLeaderboard(1)

        expect(r.entries.map((e) => [e.userName, e.xp])).toEqual([['나', 80], ['가', 40]])
        expect(r.me).toEqual({ xp: 40, rank: 2 })
    })

    it('내가 상위 10명 밖이면 rank 는 null 이고 XP 만 돌려준다 (낮은 순위는 드러내지 않는다)', async () => {
        const members = Array.from({ length: 12 }, (_, i) => ({ id: i + 1, name: `m${i + 1}` }))
        // 1~11번은 세트 2개(80 XP), 12번(나)은 세트 1개(40 XP)
        const rows = members.flatMap((m, i) => i < 11
            ? [row(i * 2 + 1, m.id, 1, '2026-10-30'), row(i * 2 + 2, m.id, 2, '2026-10-30')]
            : [row(100, m.id, 1, '2026-10-30')])
        vi.mocked(db.query)
            .mockResolvedValueOnce([members] as any)
            .mockResolvedValueOnce([[{ today: '2026-10-30' }]] as any)
            .mockResolvedValueOnce([rows] as any)

        const r = await getWeeklyLeaderboard(12)

        expect(r.entries).toHaveLength(10)
        expect(r.me).toEqual({ xp: 40, rank: null })
    })
})
