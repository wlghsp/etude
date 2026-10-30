import { describe, it, expect } from 'vitest'
import { cheersFor, type CompletionRec, type SetInfo } from './feed-cheers.js'

const sets: SetInfo[] = [
    { id: 1, category: '리눅스', unitId: 1 }, { id: 2, category: '리눅스', unitId: 1 }, { id: 3, category: '리눅스', unitId: 2 },
    { id: 4, category: '도커', unitId: 9 }, { id: 5, category: '도커', unitId: 9 },
]
let nextId = 1
const rec = (setId: number, day: string, o: Partial<CompletionRec> = {}): CompletionRec =>
    ({ id: nextId++, questSetId: setId, day, questCount: 4, hintFree: 0, solutionFree: 0, ...o })
const kinds = (r: ReturnType<typeof cheersFor>) => r.map((c) => c.kind)

describe('cheersFor', () => {
    it('첫 세트를 끝내면 첫 걸음 배지를 축하한다', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-30')]

        const c = cheersFor(recs, sets, recs[0]!.id)

        expect(c.map((x) => x.text)).toEqual([expect.stringContaining('첫 걸음')])
        expect(kinds(c)).toEqual(['badge'])
    })

    it('이미 얻은 배지는 다시 축하하지 않는다 (같은 세트를 또 끝내도)', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-29'), rec(1, '2026-10-30')]

        expect(cheersFor(recs, sets, recs[1]!.id).filter((c) => c.text.includes('첫 걸음'))).toEqual([])
    })

    it('레벨이 오르면 레벨 업을 축하한다 (4문제 세트 = 40 XP, 3개째에 100 XP 를 넘어 Lv.2)', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-28'), rec(2, '2026-10-29'), rec(3, '2026-10-30')]

        expect(kinds(cheersFor(recs, sets, recs[1]!.id))).not.toContain('level')
        const third = cheersFor(recs, sets, recs[2]!.id)
        expect(third.find((c) => c.kind === 'level')!.text).toContain('Lv.2')
    })

    it('연속 학습 3일에 처음 닿으면 축하하고, 같은 날 또 끝내도 다시 축하하지 않는다', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-28'), rec(2, '2026-10-29'), rec(3, '2026-10-30'), rec(4, '2026-10-30')]

        expect(cheersFor(recs, sets, recs[2]!.id).some((c) => c.kind === 'streak' || c.text.includes('3일 연속'))).toBe(true)
        expect(cheersFor(recs, sets, recs[3]!.id).some((c) => c.text.includes('3일 연속'))).toBe(false)
    })

    it('14일 연속에 닿으면 연속 학습을 축하한다', () => {
        nextId = 1
        const recs = Array.from({ length: 14 }, (_, i) => rec(1, `2026-10-${String(i + 1).padStart(2, '0')}`))

        const c = cheersFor(recs, sets, recs[13]!.id)

        expect(c.find((x) => x.kind === 'streak')!.text).toContain('14일')
    })

    it('한 단원의 마지막 세트를 끝내면 단원 정복, 분야의 마지막이면 분야 정복이 되고 우선순위가 앞선다', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-30'), rec(2, '2026-10-30')]
        expect(kinds(cheersFor(recs, sets, recs[1]!.id))[0]).toBe('unit')

        nextId = 1
        const all = [rec(1, '2026-10-30'), rec(2, '2026-10-30'), rec(3, '2026-10-30')]
        const c = cheersFor(all, sets, all[2]!.id)
        expect(kinds(c)[0]).toBe('category')
        expect(c[0]!.text).toContain('리눅스')
        expect(kinds(c)).toContain('unit') // 3번 세트가 단원 2 의 유일한 세트라서 단원 정복도 함께
    })

    it('퍼펙트(힌트·풀이 없이)로 끝내면 퍼펙트 배지를 축하한다', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-30', { hintFree: 4, solutionFree: 4 })]

        expect(cheersFor(recs, sets, recs[0]!.id).some((c) => c.text.includes('퍼펙트'))).toBe(true)
    })

    it('같은 세트를 3번째 끝내면 복습왕 배지를 축하한다', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-20'), rec(1, '2026-10-25'), rec(1, '2026-10-30')]

        expect(cheersFor(recs, sets, recs[2]!.id).some((c) => c.text.includes('복습왕'))).toBe(true)
    })

    it('이번 달 열 번째 완료에서 이달의 도전 완료를 축하하고, 달이 바뀌면 다시 센다', () => {
        nextId = 1
        const recs = [...Array.from({ length: 10 }, (_, i) => rec(1, `2026-10-${String(i + 1).padStart(2, '0')}`)), rec(1, '2026-11-01')]

        expect(cheersFor(recs, sets, recs[9]!.id).find((c) => c.kind === 'challenge')!.text).toContain('10월')
        expect(cheersFor(recs, sets, recs[8]!.id).some((c) => c.kind === 'challenge')).toBe(false)
        expect(cheersFor(recs, sets, recs[10]!.id).some((c) => c.kind === 'challenge')).toBe(false) // 11월 첫 완료
    })

    it('축하마다 고유 키를 내려 준다 (화면이 종류 안에서도 색을 달리 쓰게): 배지는 badge:<id>, 연속은 streak<일수>', () => {
        nextId = 1
        const first = [rec(1, '2026-10-30', { hintFree: 4, solutionFree: 4 })]
        expect(cheersFor(first, sets, first[0]!.id).map((c) => c.key).sort()).toEqual(['badge:first', 'badge:perfect'])

        nextId = 1
        const streak = Array.from({ length: 14 }, (_, i) => rec(1, `2026-10-${String(i + 1).padStart(2, '0')}`))
        expect(cheersFor(streak, sets, streak[13]!.id).find((c) => c.kind === 'streak')!.key).toBe('streak14')

        nextId = 1
        const unit = [rec(1, '2026-10-30'), rec(2, '2026-10-30')]
        expect(cheersFor(unit, sets, unit[1]!.id).map((c) => c.key)).toContain('unit')
    })

    it('축하할 일이 없으면 빈 목록이다', () => {
        nextId = 1
        const recs = [rec(1, '2026-10-20'), rec(4, '2026-10-22')]

        expect(cheersFor(recs, sets, recs[1]!.id)).toEqual([])
    })
})
