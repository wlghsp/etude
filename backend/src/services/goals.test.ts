import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { buildGoals, getGoals, type GoalsInput } from './goals.js'

const base: GoalsInput = { todaySets: 0, todayQuests: 0, todayReviews: 0, totalCompleted: 0, monthCount: 0, hoursLeft: 9, daysLeft: 1, monthLabel: '10월' }
const goal = (g: ReturnType<typeof buildGoals>, key: string) => g.today.goals.find((x) => x.key === key)

describe('buildGoals', () => {
    it('오늘의 목표: 세트 1개와 문제 10개를 진행도·달성 여부로 돌려준다', () => {
        const g = buildGoals({ ...base, todaySets: 1, todayQuests: 7, totalCompleted: 3 })

        expect(goal(g, 'sets')).toMatchObject({ current: 1, target: 1, done: true })
        expect(goal(g, 'quests')).toMatchObject({ current: 7, target: 10, done: false })
    })

    it('진행도는 목표를 넘어도 목표 값까지만 보여 준다', () => {
        const g = buildGoals({ ...base, todaySets: 3, todayQuests: 40, totalCompleted: 5 })

        expect(goal(g, 'sets')).toMatchObject({ current: 1, target: 1 })
        expect(goal(g, 'quests')).toMatchObject({ current: 10, target: 10, done: true })
    })

    it('복습 목표는 완료한 세트가 하나라도 있는 사람에게만 보인다', () => {
        expect(goal(buildGoals({ ...base, totalCompleted: 0 }), 'review')).toBeUndefined()
        expect(goal(buildGoals({ ...base, totalCompleted: 2, todayReviews: 1 }), 'review')).toMatchObject({ current: 1, target: 1, done: true })
    })

    it('이달의 도전: 이번 달 완료 10회가 목표이고 남은 일수와 달 이름을 담는다', () => {
        const g = buildGoals({ ...base, monthCount: 4, daysLeft: 12, monthLabel: '10월' })

        expect(g.month).toMatchObject({ label: '10월', current: 4, target: 10, done: false, daysLeft: 12 })
        expect(buildGoals({ ...base, monthCount: 25 }).month).toMatchObject({ current: 10, done: true })
    })

    it('남은 시간을 그대로 담는다', () => {
        expect(buildGoals({ ...base, hoursLeft: 5 }).today.hoursLeft).toBe(5)
    })
})

describe('getGoals', () => {
    beforeEach(() => vi.clearAllMocks())

    it('본인 완료 기록 하나의 조회 결과로 목표를 만든다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ today_sets: 1, today_quests: 14, today_reviews: 0, total_completed: 6, month_count: 3, minutes_left: 125, days_left: 4, month: 10 }]] as any)

        const g = await getGoals(7)

        expect(vi.mocked(db.query).mock.calls[0]![1]).toEqual(expect.arrayContaining([7]))
        expect(g.today.hoursLeft).toBe(3) // 125분 → 올림해 3시간
        expect(g.month).toMatchObject({ label: '10월', current: 3, daysLeft: 4 })
        expect(goal(g, 'sets')!.done).toBe(true)
    })
})
