import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { levelInfo, BADGES, snapshot, getGamification } from './gamification.js'
import type { CompletionRec } from './xp.js'
import type { SetInfo } from './feed-cheers.js'

const sets: SetInfo[] = [{ id: 1, category: '리눅스', unitId: 1 }, { id: 2, category: '리눅스', unitId: 1 }, { id: 3, category: '도커', unitId: 5 }]
let nid = 1
const rec = (setId: number, day: string, o: Partial<CompletionRec> = {}): CompletionRec =>
    ({ id: nid++, questSetId: setId, day, questCount: 4, hintFree: 0, solutionFree: 0, ...o })

describe('levelInfo', () => {
    it('레벨 2 는 100 XP, 3 은 300 XP, 이번 레벨에서 쌓은 값과 필요한 값과 비율을 돌려준다', () => {
        expect(levelInfo(0)).toMatchObject({ level: 1, title: '새싹', into: 0, need: 100, pct: 0 })
        expect(levelInfo(150)).toMatchObject({ level: 2, title: '견습생', into: 50, need: 200, pct: 25 })
        expect(levelInfo(300).level).toBe(3)
    })

    it('호칭 목록을 넘어서는 레벨은 마지막 호칭을 쓴다', () => {
        expect(levelInfo(50 * 30 * 29).title).toBe('레전드')
    })
})

describe('badges', () => {
    it('배지 10종이 정의돼 있고 id 가 겹치지 않는다', () => {
        expect(BADGES).toHaveLength(10)
        expect(new Set(BADGES.map((b) => b.id)).size).toBe(10)
    })

    it('완료 기록이 없으면 모두 잠겨 있다', () => {
        expect(snapshot([], sets, '2026-10-30').badges.size).toBe(0)
    })

    it('단원을 모두 끝내면 단원 정복, 분야를 모두 끝내면 분야 정복 배지가 열린다', () => {
        nid = 1
        const unit = snapshot([rec(1, '2026-10-30'), rec(2, '2026-10-30')], sets, '2026-10-30')
        expect(unit.badges.has('unit')).toBe(true)
        expect(unit.badges.has('category')).toBe(true) // 리눅스(세트 1·2)를 모두 끝냄
        expect(snapshot([rec(1, '2026-10-30')], sets, '2026-10-30').badges.has('unit')).toBe(false)
    })
})

describe('getGamification', () => {
    beforeEach(() => vi.clearAllMocks())

    it('본인의 완료 기록으로 XP·레벨·배지·연속일을 만든다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ today: '2026-10-30' }]] as any)
            .mockResolvedValueOnce([[
                { id: 1, quest_set_id: 1, day: '2026-10-29', quest_count: 10, hint_free_count: 10, solution_free_count: 10 },
                { id: 2, quest_set_id: 2, day: '2026-10-30', quest_count: 10, hint_free_count: 0, solution_free_count: 0 },
            ]] as any)
            .mockResolvedValueOnce([[{ id: 1, category: '리눅스', unit_id: 1 }, { id: 2, category: '리눅스', unit_id: 1 }]] as any)

        const g = await getGamification(7)

        expect(vi.mocked(db.query).mock.calls[1]![1]).toEqual([7])
        expect(g.xp).toBe(10 * 10 + 10 * 5 + 10 * 10) // 두 세트 처음 끝냄 200 + 퍼펙트 보너스 50
        expect(g.level.level).toBe(2)
        expect(g.streak).toBe(2)
        expect(g.badges.find((b) => b.id === 'first')).toMatchObject({ unlocked: true, title: '첫 걸음' })
        expect(g.badges.find((b) => b.id === 'perfect')!.unlocked).toBe(true)
        expect(g.badges.find((b) => b.id === 'ten')!.unlocked).toBe(false)
        expect(g.badges).toHaveLength(10)
    })
})
