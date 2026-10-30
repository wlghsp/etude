import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { buildReport, getReport, streakFromDays } from './report.js'

const members = [{ id: 1, name: '가' }, { id: 2, name: '나' }, { id: 3, name: '다' }, { id: 4, name: '라' }]
const empty = { members, days: [], weekCounts: [], firstTry: [], perfect: [], review: [] }
const award = (r: ReturnType<typeof buildReport>, key: string) => r.awards.find((a) => a.key === key)!

describe('streakFromDays', () => {
    it('오늘(없으면 어제)부터 하루도 빠지지 않은 날 수를 센다', () => {
        expect(streakFromDays(new Set(['2026-10-30', '2026-10-29', '2026-10-28']), '2026-10-30')).toBe(3)
        expect(streakFromDays(new Set(['2026-10-29', '2026-10-28']), '2026-10-30')).toBe(2) // 오늘 아직 안 했어도 어제까지 이어졌으면 유지
        expect(streakFromDays(new Set(['2026-10-30', '2026-10-28']), '2026-10-30')).toBe(1) // 하루 빠지면 끊긴다
        expect(streakFromDays(new Set(['2026-10-27']), '2026-10-30')).toBe(0)
        expect(streakFromDays(new Set(['2026-10-01', '2026-09-30', '2026-09-29']), '2026-10-01')).toBe(3) // 달이 바뀌어도 이어진다
    })
})

describe('buildReport', () => {
    it('연속 학습왕: 현재 연속 학습일이 긴 순서이고 0일인 사람은 넣지 않는다', () => {
        const r = buildReport({
            ...empty, today: '2026-10-30',
            days: [
                { userId: 1, day: '2026-10-30' }, { userId: 1, day: '2026-10-29' }, { userId: 1, day: '2026-10-28' },
                { userId: 2, day: '2026-10-30' },
                { userId: 3, day: '2026-10-20' },
            ],
        })

        expect(award(r, 'streak').entries.map((e) => [e.userName, e.value])).toEqual([['가', 3], ['나', 1]])
    })

    it('이번 주 열공상: 최근 7일 완료 수 순서, 상위 3명까지', () => {
        const r = buildReport({ ...empty, today: '2026-10-30', weekCounts: [{ userId: 1, n: 2 }, { userId: 2, n: 5 }, { userId: 3, n: 4 }, { userId: 4, n: 1 }] })

        expect(award(r, 'week').entries.map((e) => e.userName)).toEqual(['나', '다', '가'])
    })

    it('정답률 왕: 시도(문제·세션 기준 첫 시도)가 10개 미만인 사람은 넣지 않고, 높은 비율부터 보인다', () => {
        const r = buildReport({
            ...empty, today: '2026-10-30',
            firstTry: [{ userId: 1, total: 20, passed: 18 }, { userId: 2, total: 9, passed: 9 }, { userId: 3, total: 10, passed: 10 }, { userId: 4, total: 30, passed: 12 }],
        })

        expect(award(r, 'firstTry').entries.map((e) => [e.userName, e.value])).toEqual([['다', 100], ['가', 90], ['라', 40]])
    })

    it('퍼펙트 달인과 복습왕을 센다', () => {
        const r = buildReport({ ...empty, today: '2026-10-30', perfect: [{ userId: 2, n: 3 }, { userId: 1, n: 1 }], review: [{ userId: 3, n: 4 }] })

        expect(award(r, 'perfect').entries.map((e) => [e.userName, e.value])).toEqual([['나', 3], ['가', 1]])
        expect(award(r, 'review').entries.map((e) => [e.userName, e.value])).toEqual([['다', 4]])
    })

    it('기록이 없으면 상은 있고 수상자는 비어 있다', () => {
        const r = buildReport({ ...empty, today: '2026-10-30' })

        expect(r.awards.map((a) => a.key)).toEqual(['streak', 'week', 'firstTry', 'perfect', 'review'])
        expect(r.awards.every((a) => a.entries.length === 0)).toBe(true)
        expect(r.mvp).toBeNull()
    })

    it('이번 주 MVP 는 최근 7일 완료가 가장 많은 사람이고, 같으면 연속 학습일, 그다음 이름 순이다', () => {
        const r = buildReport({
            ...empty, today: '2026-10-30',
            weekCounts: [{ userId: 1, n: 3 }, { userId: 2, n: 3 }],
            days: [{ userId: 2, day: '2026-10-30' }, { userId: 2, day: '2026-10-29' }, { userId: 1, day: '2026-10-30' }],
        })

        expect(r.mvp).toMatchObject({ userName: '나', weekCount: 3, streak: 2 })
    })
})

describe('getReport', () => {
    beforeEach(() => vi.clearAllMocks())

    it('회원 기록만 조회해 보고서를 만든다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ id: 1, name: '가' }]] as any)          // 회원
            .mockResolvedValueOnce([[{ user_id: 1, d: '2026-10-30' }]] as any) // 완료한 날
            .mockResolvedValueOnce([[{ today: '2026-10-30' }]] as any)          // DB 기준 오늘
            .mockResolvedValueOnce([[{ user_id: 1, n: 2 }]] as any)             // 최근 7일
            .mockResolvedValueOnce([[]] as any)                                 // 첫 시도 정답률
            .mockResolvedValueOnce([[]] as any)                                 // 퍼펙트
            .mockResolvedValueOnce([[]] as any)                                 // 복습

        const r = await getReport()

        expect(vi.mocked(db.query).mock.calls[0]![0]).toContain("role = 'member'")
        expect(award(r, 'streak').entries[0]).toMatchObject({ userName: '가', value: 1 })
        expect(r.mvp).toMatchObject({ userName: '가', weekCount: 2 })
    })
})
