import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { buildReport, getReport, streakFromDays } from './report.js'

const members = [{ id: 1, name: '가' }, { id: 2, name: '나' }, { id: 3, name: '다' }, { id: 4, name: '라' }]
const empty = { members, days: [], weekCounts: [], firstTry: [], perfect: [], review: [], prevWeekCounts: [], timeSlots: [], grit: [], fieldSets: [], cheer: [] }
const award = (r: ReturnType<typeof buildReport>, key: string) => r.awards.find((a) => a.key === key)!
const minor = (r: ReturnType<typeof buildReport>, key: string) => r.minorAwards.find((a) => a.key === key)!

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

describe('buildReport — 소박한 상', () => {
    const names = (r: ReturnType<typeof buildReport>, key: string) => minor(r, key).entries.map((e) => [e.userName, e.value])

    it('꾸준상: 최근 7일 중 학습한 날 수 (8일 전은 세지 않는다)', () => {
        const r = buildReport({
            ...empty, today: '2026-10-30',
            days: [
                { userId: 1, day: '2026-10-30' }, { userId: 1, day: '2026-10-26' }, { userId: 1, day: '2026-10-24' }, { userId: 1, day: '2026-10-23' },
                { userId: 2, day: '2026-10-29' },
            ],
        })

        expect(names(r, 'steady')).toEqual([['가', 3], ['나', 1]])
    })

    it('새벽형·올빼미·주말 열공: 해당 횟수가 있는 사람만', () => {
        const r = buildReport({ ...empty, today: '2026-10-30', timeSlots: [{ userId: 1, dawn: 2, owl: 0, weekend: 1 }, { userId: 2, dawn: 0, owl: 3, weekend: 0 }] })

        expect(names(r, 'dawn')).toEqual([['가', 2]])
        expect(names(r, 'owl')).toEqual([['나', 3]])
        expect(names(r, 'weekend')).toEqual([['가', 1]])
    })

    it('끈기상과 응원상', () => {
        const r = buildReport({ ...empty, today: '2026-10-30', grit: [{ userId: 3, n: 4 }], cheer: [{ userId: 2, n: 9 }, { userId: 1, n: 2 }] })

        expect(names(r, 'grit')).toEqual([['다', 4]])
        expect(names(r, 'cheer')).toEqual([['나', 9], ['가', 2]])
    })

    it('분야별 박사: 분야마다 하나씩, 완료 세트가 있는 분야만', () => {
        const r = buildReport({ ...empty, today: '2026-10-30', fieldSets: [{ userId: 1, category: '리눅스', n: 5 }, { userId: 2, category: 'k8s', n: 2 }, { userId: 3, category: '리눅스', n: 3 }] })

        expect(names(r, 'field:리눅스')).toEqual([['가', 5], ['다', 3]])
        expect(names(r, 'field:k8s')).toEqual([['나', 2]])
        expect(r.minorAwards.some((a) => a.key === 'field:도커')).toBe(false)
    })

    it('성장상: 이번 7일 − 이전 7일 완료가 늘어난 사람만', () => {
        const r = buildReport({
            ...empty, today: '2026-10-30',
            weekCounts: [{ userId: 1, n: 5 }, { userId: 2, n: 2 }, { userId: 3, n: 1 }],
            prevWeekCounts: [{ userId: 1, n: 1 }, { userId: 2, n: 4 }],
        })

        expect(names(r, 'growth')).toEqual([['가', 4], ['다', 1]])
    })

    it('동점은 3명을 넘어도 같이 보여 준다', () => {
        const r = buildReport({ ...empty, today: '2026-10-30', grit: [{ userId: 1, n: 2 }, { userId: 2, n: 2 }, { userId: 3, n: 2 }, { userId: 4, n: 2 }] })

        expect(names(r, 'grit')).toHaveLength(4)
    })

    it('값이 있는 상만 내려 준다', () => {
        expect(buildReport({ ...empty, today: '2026-10-30' }).minorAwards).toEqual([])
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
            .mockResolvedValueOnce([[{ user_id: 1, n: 1 }]] as any)             // 이전 7일
            .mockResolvedValueOnce([[{ user_id: 1, dawn: 1, owl: 0, weekend: 0 }]] as any) // 시간대
            .mockResolvedValueOnce([[]] as any)                                 // 끈기
            .mockResolvedValueOnce([[{ user_id: 1, category: '리눅스', n: 2 }]] as any) // 분야별 세트
            .mockResolvedValueOnce([[]] as any)                                 // 응원

        const r = await getReport()

        expect(vi.mocked(db.query).mock.calls[0]![0]).toContain("role = 'member'")
        expect(award(r, 'streak').entries[0]).toMatchObject({ userName: '가', value: 1 })
        expect(r.mvp).toMatchObject({ userName: '가', weekCount: 2 })
        expect(minor(r, 'dawn').entries[0]).toMatchObject({ userName: '가', value: 1 })
        expect(minor(r, 'field:리눅스').entries[0]).toMatchObject({ value: 2 })
    })
})
