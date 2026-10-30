import { describe, it, expect, vi } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { buildReview } from './review.js'
import type { SetProgress } from './progress.js'

const NOW = new Date('2026-10-30T12:00:00Z')
const daysAgo = (n: number) => new Date(NOW.getTime() - n * 86400000).toISOString()
const comp = (days: number, o: object = {}) => ({ id: 1, completedAt: daysAgo(days), totalSeconds: 60, questCount: 10, hintFreeCount: 10, solutionFreeCount: 10, detail: null, ...o })
const row = (id: number, o: Partial<SetProgress> = {}): SetProgress =>
    ({ questSetId: id, title: `세트${id}`, category: '리눅스', unitId: 1, unitTitle: '기초', unitOrder: 10, isReview: false, completions: [], retry: null, ...o })

describe('buildReview', () => {
    it('다시 풀기: retry 가 있는 세트를 도움을 많이 쓴 순으로, 퍼펙트로 끝낼 때 늘어나는 XP 와 함께 돌려준다', () => {
        const r = buildReview([
            row(1, { completions: [comp(1, { hintFreeCount: 5 })], retry: { assistedPct: 50 } }),
            row(2, { completions: [comp(1, { hintFreeCount: 2 })], retry: { assistedPct: 80 } }),
        ], NOW)

        expect(r.retry.map((i) => i.questSetId)).toEqual([2, 1])
        // 완료 1번: 복습 보너스 5 + 퍼펙트 보너스(한 번도 없었으니) 10문제×5 = 55
        expect(r.retry[0]!.gainXp).toBe(55)
    })

    it('이미 퍼펙트로 끝낸 적이 있으면 퍼펙트 보너스는 더하지 않고, 복습 보너스는 다섯 번까지만 준다', () => {
        const perfectBefore = row(1, { completions: [comp(1, { hintFreeCount: 2 }), comp(5)], retry: { assistedPct: 80 } })
        const many = row(2, { completions: Array.from({ length: 6 }, (_, i) => comp(i + 1, { hintFreeCount: 2 })), retry: { assistedPct: 80 } })

        const r = buildReview([perfectBefore, many], NOW)

        expect(r.retry.find((i) => i.questSetId === 1)!.gainXp).toBe(5)
        expect(r.retry.find((i) => i.questSetId === 2)!.gainXp).toBe(50) // 복습 보너스 한도 지남, 퍼펙트 보너스만
    })

    it('복습 세트: 아직 안 푼 is_review 세트만 모으고 XP 는 모른다 (null)', () => {
        const r = buildReview([row(1, { isReview: true }), row(2, { isReview: true, completions: [comp(1)] }), row(3)], NOW)

        expect(r.reviewSets.map((i) => i.questSetId)).toEqual([1])
        expect(r.reviewSets[0]!.gainXp).toBeNull()
    })

    it('오랜만에: 마지막으로 끝낸 지 14일 이상 지난 세트를 오래된 순으로 최대 5개, 다시 풀기와는 겹치지 않는다', () => {
        const rows = [
            row(1, { completions: [comp(20)] }), row(2, { completions: [comp(30)] }), row(3, { completions: [comp(13)] }),
            row(4, { completions: [comp(40)], retry: { assistedPct: 60 } }),
            ...[5, 6, 7, 8, 9].map((id) => row(id, { completions: [comp(15 + id)] })),
        ]

        const r = buildReview(rows, NOW)

        expect(r.stale.map((i) => i.questSetId)).not.toContain(3) // 13일은 아직
        expect(r.stale.map((i) => i.questSetId)).not.toContain(4) // 다시 풀기에 있다
        expect(r.stale).toHaveLength(5)
        expect(r.stale[0]!.questSetId).toBe(2) // 가장 오래된 30일 (4번은 제외)
    })

    it('오늘의 추천은 다시 풀기 → 복습 세트 → 오랜만에 순서로 첫 번째, 없으면 null', () => {
        expect(buildReview([row(1, { completions: [comp(1)], retry: { assistedPct: 60 } }), row(2, { isReview: true })], NOW).pick!.questSetId).toBe(1)
        expect(buildReview([row(2, { isReview: true }), row(3, { completions: [comp(20)] })], NOW).pick!.questSetId).toBe(2)
        expect(buildReview([row(3, { completions: [comp(20)] })], NOW).pick!.questSetId).toBe(3)
        expect(buildReview([row(3, { completions: [comp(2)] })], NOW).pick).toBeNull()
    })

    it('항목마다 칭찬·도전 중심의 안내 문구(reason)를 붙인다', () => {
        const r = buildReview([row(1, { completions: [comp(1, { hintFreeCount: 2 })], retry: { assistedPct: 80 } })], NOW)

        expect(r.retry[0]!.reason.length).toBeGreaterThan(0)
    })
})
