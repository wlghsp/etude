import { db } from '../db.js'

// 리포트(명예의 전당): 누가 열심히 하는지 칭찬하는 화면이다. 모두 세트 완료와 채점 기록에서 계산하고, 칭찬할 만한 값이 있는 사람만
// 높은 순서로 보여 준다 (낮은 사람은 드러내지 않는다). 랭킹과 같이 회원만 대상이다. docs/specs/spec_report.md

const TOP = 3
const FIRST_TRY_MIN_ATTEMPTS = 10 // 한 번에 맞힌 비율은 시도가 이만큼은 있어야 센다 (우연히 높은 값을 막는다)

export interface ReportEntry { userId: number; userName: string; value: number; display: string }
export interface ReportAward {
    key: 'streak' | 'week' | 'firstTry' | 'perfect' | 'review'
    icon: string
    title: string
    desc: string
    entries: ReportEntry[]
}
export interface Report {
    awards: ReportAward[]
    mvp: { userId: number; userName: string; weekCount: number; streak: number } | null
}

export interface ReportInput {
    today: string // 'YYYY-MM-DD' (DB 기준 오늘)
    members: Array<{ id: number; name: string }>
    days: Array<{ userId: number; day: string }> // 세트를 완료한 날 (사람·날짜마다 한 줄)
    weekCounts: Array<{ userId: number; n: number }> // 최근 7일 완료 횟수
    firstTry: Array<{ userId: number; total: number; passed: number }> // 문제·세션마다 첫 시도의 정답 여부
    perfect: Array<{ userId: number; n: number }> // 힌트·풀이 없이 끝낸 완료 횟수
    review: Array<{ userId: number; n: number }> // 같은 세트를 다시 끝낸 횟수
}

const toUtc = (day: string) => { const [y, m, d] = day.split('-').map(Number); return Date.UTC(y!, m! - 1, d!) }
const DAY_MS = 24 * 60 * 60 * 1000
const toDay = (ms: number) => new Date(ms).toISOString().slice(0, 10)

/** 오늘(없으면 어제)부터 거꾸로 하루도 빠지지 않고 이어진 날 수 */
export function streakFromDays(days: Set<string>, today: string): number {
    let cursor = toUtc(today)
    if (!days.has(toDay(cursor))) cursor -= DAY_MS
    let streak = 0
    while (days.has(toDay(cursor))) { streak++; cursor -= DAY_MS }
    return streak
}

export function buildReport(input: ReportInput): Report {
    const name = new Map(input.members.map((m) => [m.id, m.name]))
    const isMember = (id: number) => name.has(id)

    const daysByUser = new Map<number, Set<string>>()
    for (const d of input.days) {
        if (!isMember(d.userId)) continue
        const set = daysByUser.get(d.userId) ?? new Set<string>()
        set.add(d.day)
        daysByUser.set(d.userId, set)
    }
    const streakOf = (id: number) => streakFromDays(daysByUser.get(id) ?? new Set(), input.today)
    const weekOf = new Map(input.weekCounts.map((w) => [w.userId, Number(w.n)]))

    const rank = (items: Array<{ userId: number; value: number; display: string }>): ReportEntry[] =>
        items
            .filter((i) => isMember(i.userId) && i.value > 0)
            .map((i) => ({ userId: i.userId, userName: name.get(i.userId)!, value: i.value, display: i.display }))
            .sort((a, b) => b.value - a.value || a.userName.localeCompare(b.userName))
            .slice(0, TOP)

    const streaks = input.members.map((m) => ({ userId: m.id, value: streakOf(m.id), display: `${streakOf(m.id)}일 연속` }))
    const awards: ReportAward[] = [
        { key: 'streak', icon: '🔥', title: '연속 학습왕', desc: '지금 가장 오래 연속으로 세트를 끝내고 있어요', entries: rank(streaks) },
        { key: 'week', icon: '💪', title: '이번 주 열공상', desc: '최근 7일에 세트를 가장 많이 끝냈어요', entries: rank(input.members.map((m) => ({ userId: m.id, value: weekOf.get(m.id) ?? 0, display: `${weekOf.get(m.id) ?? 0}세트` }))) },
        {
            key: 'firstTry', icon: '🎯', title: '정답률 왕', desc: `문제를 한 번에 가장 많이 맞혔어요 (시도 ${FIRST_TRY_MIN_ATTEMPTS}개 이상)`,
            entries: rank(input.firstTry.filter((f) => Number(f.total) >= FIRST_TRY_MIN_ATTEMPTS).map((f) => {
                const pct = Math.round((Number(f.passed) / Number(f.total)) * 100)
                return { userId: f.userId, value: pct, display: `${pct}%` }
            })),
        },
        { key: 'perfect', icon: '💯', title: '퍼펙트 달인', desc: '힌트와 풀이 없이 끝낸 세트가 가장 많아요', entries: rank(input.perfect.map((p) => ({ userId: p.userId, value: Number(p.n), display: `${Number(p.n)}번` }))) },
        { key: 'review', icon: '🔁', title: '복습왕', desc: '같은 세트를 다시 끝낸 횟수가 가장 많아요', entries: rank(input.review.map((r) => ({ userId: r.userId, value: Number(r.n), display: `${Number(r.n)}번` }))) },
    ]

    const mvp = input.members
        .map((m) => ({ userId: m.id, userName: m.name, weekCount: weekOf.get(m.id) ?? 0, streak: streakOf(m.id) }))
        .filter((m) => m.weekCount > 0)
        .sort((a, b) => b.weekCount - a.weekCount || b.streak - a.streak || a.userName.localeCompare(b.userName))[0] ?? null

    return { awards, mvp }
}

export async function getReport(): Promise<Report> {
    const [members] = await db.query("SELECT id, name FROM user WHERE role = 'member'") as any[]
    const [days] = await db.query("SELECT DISTINCT user_id, DATE_FORMAT(completed_at, '%Y-%m-%d') AS d FROM set_completion") as any[]
    const [today] = await db.query("SELECT DATE_FORMAT(CURDATE(), '%Y-%m-%d') AS today") as any[]
    const [week] = await db.query('SELECT user_id, COUNT(*) AS n FROM set_completion WHERE completed_at >= (NOW() - INTERVAL 7 DAY) GROUP BY user_id') as any[]
    // 문제·세션마다 가장 처음 시도(가장 작은 id)가 통과였는지
    const [firstTry] = await db.query(`
        SELECT a.user_id, COUNT(*) AS total, SUM(a.passed) AS passed
        FROM quest_attempt a
        JOIN (SELECT MIN(id) AS id FROM quest_attempt GROUP BY user_id, quest_id, session_id) f ON f.id = a.id
        GROUP BY a.user_id`) as any[]
    const [perfect] = await db.query(`
        SELECT user_id, COUNT(*) AS n FROM set_completion
        WHERE quest_count > 0 AND hint_free_count = quest_count AND solution_free_count = quest_count
        GROUP BY user_id`) as any[]
    const [review] = await db.query(`
        SELECT user_id, SUM(GREATEST(c - 1, 0)) AS n
        FROM (SELECT user_id, quest_set_id, COUNT(*) AS c FROM set_completion GROUP BY user_id, quest_set_id) t
        GROUP BY user_id`) as any[]

    return buildReport({
        today: (today as any[])[0].today,
        members: members as any[],
        days: (days as any[]).map((r) => ({ userId: r.user_id, day: r.d })),
        weekCounts: (week as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
        firstTry: (firstTry as any[]).map((r) => ({ userId: r.user_id, total: Number(r.total), passed: Number(r.passed) })),
        perfect: (perfect as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
        review: (review as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
    })
}
