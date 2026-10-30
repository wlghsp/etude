import { db } from '../db.js'
import { DAY_MS, streakFromDays, toDay, toUtc } from './streak.js'

export { streakFromDays }

// 리포트(명예의 전당): 누가 열심히 하는지 칭찬하는 화면이다. 모두 세트 완료와 채점 기록에서 계산하고, 칭찬할 만한 값이 있는 사람만
// 높은 순서로 보여 준다 (낮은 사람은 드러내지 않는다). 랭킹과 같이 회원만 대상이다. docs/specs/spec_report.md

const TOP = 3
const FIRST_TRY_MIN_ATTEMPTS = 10 // 한 번에 맞힌 비율은 시도가 이만큼은 있어야 센다 (우연히 높은 값을 막는다)

export interface ReportEntry { userId: number; userName: string; value: number; display: string }
export interface ReportAward {
    key: string // 큰 상: streak | week | firstTry | perfect | review, 소박한 상: steady | dawn | owl | weekend | grit | cheer | growth | field:{분야}
    icon: string
    title: string
    desc: string
    entries: ReportEntry[]
}
export interface Report {
    awards: ReportAward[]
    minorAwards: ReportAward[] // 소박한 상: 수상자가 있는 상만
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
    prevWeekCounts: Array<{ userId: number; n: number }> // 그 전 7일(8~14일 전) 완료 횟수
    timeSlots: Array<{ userId: number; dawn: number; owl: number; weekend: number }> // 완료 시각: 5~8시 / 22~4시 / 주말
    grit: Array<{ userId: number; n: number }> // 3번 이상 틀리고도 끝까지 푼 문제 수
    fieldSets: Array<{ userId: number; category: string; n: number }> // 분야별 완료한 서로 다른 세트 수
    cheer: Array<{ userId: number; n: number }> // 댓글을 쓴 수 + 좋아요를 누른 수
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

    const rank = (items: Array<{ userId: number; value: number; display: string }>, withTies = false): ReportEntry[] => {
        const sorted = items
            .filter((i) => isMember(i.userId) && i.value > 0)
            .map((i) => ({ userId: i.userId, userName: name.get(i.userId)!, value: i.value, display: i.display }))
            .sort((a, b) => b.value - a.value || a.userName.localeCompare(b.userName))
        const cut = sorted[TOP - 1]
        return withTies && cut ? sorted.filter((e) => e.value >= cut.value) : sorted.slice(0, TOP)
    }

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

    // 소박한 상: 값이 있는 사람만, 한 상에 3명까지 (동점은 같이)
    const weekStart = toDay(toUtc(input.today) - 6 * DAY_MS)
    const minor = (key: string, icon: string, title: string, desc: string, items: Array<{ userId: number; value: number }>, unit: string): ReportAward =>
        ({ key, icon, title, desc, entries: rank(items.map((i) => ({ ...i, display: `${i.value}${unit}` })), true) })
    const prevOf = new Map(input.prevWeekCounts.map((w) => [w.userId, Number(w.n)]))
    const slot = (pick: (t: ReportInput['timeSlots'][number]) => number) => input.timeSlots.map((t) => ({ userId: t.userId, value: Number(pick(t)) }))
    const categories = [...new Set(input.fieldSets.map((f) => f.category))]
    const FIELD_ICON: Record<string, string> = { '리눅스': '🐧', 'k8s': '☸️', '도커': '🐳' }
    const minorAwards = [
        minor('steady', '🌱', '꾸준상', '최근 7일 중 학습한 날이 가장 많아요', input.members.map((m) => ({ userId: m.id, value: [...(daysByUser.get(m.id) ?? [])].filter((d) => d >= weekStart && d <= input.today).length })), '일'),
        minor('dawn', '🌅', '새벽형', '아침 5~8시에 세트를 끝낸 횟수가 가장 많아요', slot((t) => t.dawn), '번'),
        minor('owl', '🦉', '올빼미', '밤 10시~새벽 4시에 세트를 끝낸 횟수가 가장 많아요', slot((t) => t.owl), '번'),
        minor('weekend', '🏖️', '주말 열공', '주말에 세트를 가장 많이 끝냈어요', slot((t) => t.weekend), '번'),
        minor('grit', '🧗', '끈기상', '3번 넘게 틀리고도 끝까지 푼 문제가 가장 많아요', input.grit.map((g) => ({ userId: g.userId, value: Number(g.n) })), '문제'),
        ...categories.map((c) => minor(`field:${c}`, FIELD_ICON[c] ?? '📚', `${c} 박사`, `${c} 세트를 가장 많이 끝냈어요`, input.fieldSets.filter((f) => f.category === c).map((f) => ({ userId: f.userId, value: Number(f.n) })), '세트')),
        minor('cheer', '📣', '응원상', '댓글과 좋아요로 동료를 가장 많이 응원했어요', input.cheer.map((c) => ({ userId: c.userId, value: Number(c.n) })), '번'),
        minor('growth', '🌿', '성장상', '지난주보다 더 많은 세트를 끝냈어요', input.members.map((m) => ({ userId: m.id, value: (weekOf.get(m.id) ?? 0) - (prevOf.get(m.id) ?? 0) })), '세트 늘었어요'),
    ].filter((a) => a.entries.length > 0)

    return { awards, minorAwards, mvp }
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
    const [prevWeek] = await db.query('SELECT user_id, COUNT(*) AS n FROM set_completion WHERE completed_at >= (NOW() - INTERVAL 14 DAY) AND completed_at < (NOW() - INTERVAL 7 DAY) GROUP BY user_id') as any[]
    const [timeSlots] = await db.query(`
        SELECT user_id,
               SUM(HOUR(completed_at) BETWEEN 5 AND 7) AS dawn,
               SUM(HOUR(completed_at) >= 22 OR HOUR(completed_at) < 4) AS owl,
               SUM(DAYOFWEEK(completed_at) IN (1, 7)) AS weekend
        FROM set_completion GROUP BY user_id`) as any[]
    // 문제·세션마다 틀린 횟수가 3번 이상이고 결국 통과한 건수
    const [grit] = await db.query(`
        SELECT user_id, COUNT(*) AS n FROM (
            SELECT user_id FROM quest_attempt GROUP BY user_id, quest_id, session_id
            HAVING SUM(passed = 0) >= 3 AND SUM(passed) >= 1
        ) t GROUP BY user_id`) as any[]
    const [fieldSets] = await db.query(`
        SELECT c.user_id, s.category, COUNT(DISTINCT c.quest_set_id) AS n
        FROM set_completion c JOIN quest_set s ON s.id = c.quest_set_id
        GROUP BY c.user_id, s.category`) as any[]
    const [cheer] = await db.query(`
        SELECT user_id, SUM(n) AS n FROM (
            SELECT user_id, COUNT(*) AS n FROM feed_comment WHERE deleted_at IS NULL GROUP BY user_id
            UNION ALL
            SELECT user_id, COUNT(*) AS n FROM feed_like GROUP BY user_id
        ) t GROUP BY user_id`) as any[]

    return buildReport({
        today: (today as any[])[0].today,
        members: members as any[],
        days: (days as any[]).map((r) => ({ userId: r.user_id, day: r.d })),
        weekCounts: (week as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
        firstTry: (firstTry as any[]).map((r) => ({ userId: r.user_id, total: Number(r.total), passed: Number(r.passed) })),
        perfect: (perfect as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
        review: (review as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
        prevWeekCounts: (prevWeek as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
        timeSlots: (timeSlots as any[]).map((r) => ({ userId: r.user_id, dawn: Number(r.dawn), owl: Number(r.owl), weekend: Number(r.weekend) })),
        grit: (grit as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
        fieldSets: (fieldSets as any[]).map((r) => ({ userId: r.user_id, category: r.category, n: Number(r.n) })),
        cheer: (cheer as any[]).map((r) => ({ userId: r.user_id, n: Number(r.n) })),
    })
}
