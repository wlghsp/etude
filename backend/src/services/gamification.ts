import { db } from '../db.js'
import { streakFromDays } from './streak.js'
import { TITLES, isPerfect, levelOf, xpOf, type CompletionRec } from './xp.js'

// 경험치(XP)·레벨·배지 규칙의 기준(서버). 진행현황 화면과 소식 축하가 모두 이 규칙을 쓴다. docs/specs/spec_progress_dashboard.md

export interface SetInfo { id: number; category: string; unitId: number | null }

export interface Badge { id: string; icon: string; title: string; desc: string; unlocked: boolean }
export const BADGES: Array<Omit<Badge, 'unlocked'>> = [
    { id: 'first', icon: '🌱', title: '첫 걸음', desc: '첫 세트를 끝냈어요' },
    { id: 'five', icon: '⚡', title: '다섯 세트', desc: '세트 5개를 끝냈어요' },
    { id: 'ten', icon: '🚀', title: '열 세트', desc: '세트 10개를 끝냈어요' },
    { id: 'twenty', icon: '🌟', title: '스무 세트', desc: '세트 20개를 끝냈어요' },
    { id: 'streak3', icon: '🔥', title: '3일 연속', desc: '3일 연속으로 세트를 끝냈어요' },
    { id: 'streak7', icon: '☄️', title: '7일 연속', desc: '7일 연속으로 세트를 끝냈어요' },
    { id: 'perfect', icon: '💯', title: '퍼펙트', desc: '힌트와 풀이 없이 세트를 끝냈어요' },
    { id: 'unit', icon: '🎖️', title: '단원 정복', desc: '한 단원의 모든 세트를 끝냈어요' },
    { id: 'category', icon: '🏆', title: '분야 정복', desc: '한 분야의 모든 세트를 끝냈어요' },
    { id: 'review', icon: '🔁', title: '복습왕', desc: '같은 세트를 3번 끝냈어요' },
]

export interface LevelInfo { level: number; title: string; xp: number; into: number; need: number; pct: number }

// 레벨 n 에 필요한 누적 XP = 50 * n * (n - 1) (레벨 2 는 100, 3 은 300, 4 는 600 ...)
const xpFor = (n: number) => 50 * n * (n - 1)

export function levelInfo(xp: number): LevelInfo {
    const level = levelOf(xp)
    const base = xpFor(level)
    const need = xpFor(level + 1) - base
    const into = xp - base
    return { level, title: TITLES[Math.min(level - 1, TITLES.length - 1)]!, xp, into, need, pct: Math.round((into / need) * 100) }
}

/** 한 사람의 완료 기록(recs, id 오름차순)을 `today` 기준으로 본 상태: XP, 연속 학습일, 얻은 배지, 끝낸 단원·분야, 이번 달 완료 수 */
export function snapshot(recs: CompletionRec[], sets: SetInfo[], today: string) {
    const monthCount = recs.filter((r) => r.day.slice(0, 7) === today.slice(0, 7)).length
    const doneSets = new Set(recs.map((r) => r.questSetId))
    const streak = streakFromDays(new Set(recs.map((r) => r.day)), today)
    const counts = new Map<number, number>()
    for (const r of recs) counts.set(r.questSetId, (counts.get(r.questSetId) ?? 0) + 1)
    const doneIn = (list: SetInfo[]) => list.length > 0 && list.every((s) => doneSets.has(s.id))
    const units = new Set<number>()
    const categories = new Set<string>()
    for (const u of new Set(sets.map((s) => s.unitId))) if (u !== null && doneIn(sets.filter((s) => s.unitId === u))) units.add(u)
    for (const c of new Set(sets.map((s) => s.category))) if (doneIn(sets.filter((s) => s.category === c))) categories.add(c)

    const badges = new Set<string>()
    if (doneSets.size >= 1) badges.add('first')
    if (doneSets.size >= 5) badges.add('five')
    if (doneSets.size >= 10) badges.add('ten')
    if (doneSets.size >= 20) badges.add('twenty')
    if (streak >= 3) badges.add('streak3')
    if (streak >= 7) badges.add('streak7')
    if (recs.some(isPerfect)) badges.add('perfect')
    if (units.size > 0) badges.add('unit')
    if (categories.size > 0) badges.add('category')
    if ([...counts.values()].some((c) => c >= 3)) badges.add('review')
    return { xp: xpOf(recs), streak, badges, units, categories, monthCount }
}

export interface Gamification { xp: number; level: LevelInfo; streak: number; badges: Badge[] }

export async function getGamification(userId: number): Promise<Gamification> {
    const [todayRows] = await db.query("SELECT DATE_FORMAT(CURDATE(), '%Y-%m-%d') AS today") as any[]
    const [rows] = await db.query(`
        SELECT id, quest_set_id, DATE_FORMAT(completed_at, '%Y-%m-%d') AS day, quest_count, hint_free_count, solution_free_count
        FROM set_completion WHERE user_id = ? ORDER BY id`, [userId]) as any[]
    const [setRows] = await db.query('SELECT id, category, unit_id FROM quest_set WHERE is_public = TRUE') as any[]
    const recs: CompletionRec[] = (rows as any[]).map((r) => ({ id: r.id, questSetId: r.quest_set_id, day: r.day, questCount: Number(r.quest_count), hintFree: Number(r.hint_free_count), solutionFree: Number(r.solution_free_count) }))
    const sets: SetInfo[] = (setRows as any[]).map((s) => ({ id: s.id, category: s.category, unitId: s.unit_id ?? null }))
    const snap = snapshot(recs, sets, (todayRows as any[])[0].today)
    return { xp: snap.xp, level: levelInfo(snap.xp), streak: snap.streak, badges: BADGES.map((b) => ({ ...b, unlocked: snap.badges.has(b.id) })) }
}
