import { db } from '../db.js'

// 오늘의 목표와 이달의 도전: 세트 완료 기록(set_completion)에서 계산한다. 본인에게만 보인다. docs/specs/spec_progress_dashboard.md

const DAILY_SETS = 1
const DAILY_QUESTS = 10
const DAILY_REVIEWS = 1
const MONTHLY_SETS = 10

export interface Goal { key: 'sets' | 'quests' | 'review'; title: string; current: number; target: number; done: boolean }
export interface Goals {
    today: { goals: Goal[]; hoursLeft: number }
    month: { label: string; current: number; target: number; done: boolean; daysLeft: number }
}
export interface GoalsInput {
    todaySets: number // 오늘 완료한 세트 수
    todayQuests: number // 오늘 완료한 세트의 문제 수 합계
    todayReviews: number // 오늘 다시 끝낸(이미 끝낸 적 있는) 세트 수
    totalCompleted: number // 지금까지의 완료 횟수
    monthCount: number // 이번 달 완료 횟수 (복습 포함)
    hoursLeft: number // 오늘 남은 시간
    daysLeft: number // 이번 달 남은 일수
    monthLabel: string
}

const goal = (key: Goal['key'], title: string, value: number, target: number): Goal =>
    ({ key, title, current: Math.min(value, target), target, done: value >= target })

export function buildGoals(i: GoalsInput): Goals {
    const goals = [
        goal('sets', '세트 1개 끝내기', i.todaySets, DAILY_SETS),
        goal('quests', '문제 10개 풀기', i.todayQuests, DAILY_QUESTS),
        // 아직 끝낸 세트가 없으면 복습할 것이 없으므로 목표로 보이지 않는다
        ...(i.totalCompleted > 0 ? [goal('review', '복습 1개', i.todayReviews, DAILY_REVIEWS)] : []),
    ]
    return {
        today: { goals, hoursLeft: i.hoursLeft },
        month: { label: i.monthLabel, current: Math.min(i.monthCount, MONTHLY_SETS), target: MONTHLY_SETS, done: i.monthCount >= MONTHLY_SETS, daysLeft: i.daysLeft },
    }
}

export async function getGoals(userId: number): Promise<Goals> {
    const [rows] = await db.query(`
        SELECT
          (SELECT COUNT(*) FROM set_completion WHERE user_id = ? AND DATE(completed_at) = CURDATE()) AS today_sets,
          (SELECT COALESCE(SUM(quest_count), 0) FROM set_completion WHERE user_id = ? AND DATE(completed_at) = CURDATE()) AS today_quests,
          (SELECT COUNT(*) FROM set_completion c WHERE c.user_id = ? AND DATE(c.completed_at) = CURDATE()
             AND EXISTS (SELECT 1 FROM set_completion p WHERE p.user_id = c.user_id AND p.quest_set_id = c.quest_set_id AND p.id < c.id)) AS today_reviews,
          (SELECT COUNT(*) FROM set_completion WHERE user_id = ?) AS total_completed,
          (SELECT COUNT(*) FROM set_completion WHERE user_id = ? AND YEAR(completed_at) = YEAR(CURDATE()) AND MONTH(completed_at) = MONTH(CURDATE())) AS month_count,
          TIMESTAMPDIFF(MINUTE, NOW(), DATE_ADD(CURDATE(), INTERVAL 1 DAY)) AS minutes_left,
          DATEDIFF(LAST_DAY(CURDATE()), CURDATE()) AS days_left,
          MONTH(CURDATE()) AS month`, [userId, userId, userId, userId, userId]) as any[]
    const r = (rows as any[])[0]
    return buildGoals({
        todaySets: Number(r.today_sets),
        todayQuests: Number(r.today_quests),
        todayReviews: Number(r.today_reviews),
        totalCompleted: Number(r.total_completed),
        monthCount: Number(r.month_count),
        hoursLeft: Math.max(1, Math.ceil(Number(r.minutes_left) / 60)),
        daysLeft: Number(r.days_left),
        monthLabel: `${Number(r.month)}월`,
    })
}
