import { db } from '../db.js'
import { DAY_MS, toDay, toUtc } from './streak.js'

// 경험치(XP)·레벨 규칙의 기준(서버 한 곳). 화면은 GET /gamification 값을 그대로 보여 준다. 배지·레벨 정보는 gamification.ts.
// docs/specs/spec_report.md "이번 주 XP 순위"

export interface CompletionRec { id: number; questSetId: number; day: string; questCount: number; hintFree: number; solutionFree: number }

const TOP = 10

export const TITLES = ['새싹', '견습생', '실습생', '현장 요원', '숙련자', '베테랑', '엘리트', '마스터', '그랜드마스터', '레전드']

export const isPerfect = (r: CompletionRec) => r.questCount > 0 && r.hintFree === r.questCount && r.solutionFree === r.questCount
const xpFor = (n: number) => 50 * n * (n - 1)
export const levelOf = (xp: number) => { let l = 1; while (xpFor(l + 1) <= xp) l++; return l }

/** 세트마다: 처음 끝내면 문제당 10 XP, 퍼펙트로 끝낸 적이 있으면 문제당 5 XP 보너스, 다시 끝낼 때마다(최대 5번) 5 XP */
export function xpOf(recs: CompletionRec[]): number {
    const bySet = new Map<number, CompletionRec[]>()
    for (const r of recs) bySet.set(r.questSetId, [...(bySet.get(r.questSetId) ?? []), r])
    let xp = 0
    for (const list of bySet.values()) {
        const n = list[0]!.questCount
        xp += n * 10
        if (list.some(isPerfect)) xp += n * 5
        xp += Math.min(list.length - 1, 5) * 5
    }
    return xp
}

/** 최근 7일(오늘 포함)에 끝낸 세트들이 그 시점에 늘린 XP 의 합. recs 는 한 사람의 전체 완료 기록 (id 오름차순). */
export function weeklyXp(recs: CompletionRec[], today: string): number {
    const start = toDay(toUtc(today) - 6 * DAY_MS)
    let total = 0
    recs.forEach((r, i) => {
        if (r.day < start || r.day > today) return
        total += xpOf(recs.slice(0, i + 1)) - xpOf(recs.slice(0, i))
    })
    return total
}

export interface WeeklyEntry { userId: number; userName: string; xp: number }
export interface WeeklyLeaderboard { entries: WeeklyEntry[]; me: { xp: number; rank: number | null } }

export async function getWeeklyLeaderboard(userId: number): Promise<WeeklyLeaderboard> {
    const [members] = await db.query("SELECT id, name FROM user WHERE role = 'member'") as any[]
    const [todayRows] = await db.query("SELECT DATE_FORMAT(CURDATE(), '%Y-%m-%d') AS today") as any[]
    const [rows] = await db.query(`
        SELECT c.id, c.user_id, c.quest_set_id, DATE_FORMAT(c.completed_at, '%Y-%m-%d') AS day, c.quest_count, c.hint_free_count, c.solution_free_count
        FROM set_completion c JOIN user u ON u.id = c.user_id WHERE u.role = 'member' ORDER BY c.id`) as any[]
    const today = (todayRows as any[])[0].today as string

    const byUser = new Map<number, CompletionRec[]>()
    for (const r of rows as any[]) {
        const list = byUser.get(r.user_id) ?? []
        list.push({ id: r.id, questSetId: r.quest_set_id, day: r.day, questCount: Number(r.quest_count), hintFree: Number(r.hint_free_count), solutionFree: Number(r.solution_free_count) })
        byUser.set(r.user_id, list)
    }
    const all = (members as any[])
        .map((m) => ({ userId: m.id as number, userName: m.name as string, xp: weeklyXp(byUser.get(m.id) ?? [], today) }))
        .filter((e) => e.xp > 0)
        .sort((a, b) => b.xp - a.xp || a.userName.localeCompare(b.userName))
    const entries = all.slice(0, TOP)
    const myIndex = entries.findIndex((e) => e.userId === userId)
    return { entries, me: { xp: all.find((e) => e.userId === userId)?.xp ?? 0, rank: myIndex >= 0 ? myIndex + 1 : null } }
}
