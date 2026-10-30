import type { SetProgress } from './api/user'

// 경험치(XP)와 레벨, 배지. 모두 세트 완료 기록에서 계산한다 (새로 저장하는 값이 없다).

const isPerfect = (c: SetProgress['completions'][number]) => c.questCount > 0 && c.hintFreeCount === c.questCount && c.solutionFreeCount === c.questCount

/** 세트마다: 처음 끝내면 문제당 10 XP, 퍼펙트로 끝낸 적이 있으면 문제당 5 XP 보너스, 다시 끝낼 때마다(최대 5번) 5 XP — 복습을 격려한다 */
export function computeXp(rows: SetProgress[]): number {
    let xp = 0
    for (const r of rows) {
        if (r.completions.length === 0) continue
        const questCount = r.completions[0]!.questCount
        xp += questCount * 10
        if (r.completions.some(isPerfect)) xp += questCount * 5
        xp += Math.min(r.completions.length - 1, 5) * 5
    }
    return xp
}

const TITLES = ['새싹', '견습생', '실습생', '현장 요원', '숙련자', '베테랑', '엘리트', '마스터', '그랜드마스터', '레전드']

export interface LevelInfo {
    level: number
    title: string
    xp: number
    into: number // 이번 레벨에서 쌓은 XP
    need: number // 다음 레벨까지 필요한 전체 XP
    pct: number
}

// 레벨 n 에 필요한 누적 XP = 50 * n * (n - 1) (레벨 2 는 100, 3 은 300, 4 는 600 ...)
const xpFor = (n: number) => 50 * n * (n - 1)

export function levelInfo(xp: number): LevelInfo {
    let level = 1
    while (xpFor(level + 1) <= xp) level++
    const base = xpFor(level)
    const need = xpFor(level + 1) - base
    const into = xp - base
    return { level, title: TITLES[Math.min(level - 1, TITLES.length - 1)]!, xp, into, need, pct: Math.round((into / need) * 100) }
}

export interface Badge {
    id: string
    icon: string
    title: string
    desc: string
    unlocked: boolean
}

export function computeBadges(rows: SetProgress[], streak: number): Badge[] {
    const done = rows.filter((r) => r.completions.length > 0)
    const byUnit = new Map<number, SetProgress[]>()
    const byCategory = new Map<string, SetProgress[]>()
    for (const r of rows) {
        if (r.unitId !== null) byUnit.set(r.unitId, [...(byUnit.get(r.unitId) ?? []), r])
        byCategory.set(r.category, [...(byCategory.get(r.category) ?? []), r])
    }
    const allDone = (list: SetProgress[]) => list.length > 0 && list.every((r) => r.completions.length > 0)
    const mk = (id: string, icon: string, title: string, desc: string, unlocked: boolean): Badge => ({ id, icon, title, desc, unlocked })
    return [
        mk('first', '🌱', '첫 걸음', '첫 세트를 끝냈어요', done.length >= 1),
        mk('five', '⚡', '다섯 세트', '세트 5개를 끝냈어요', done.length >= 5),
        mk('ten', '🚀', '열 세트', '세트 10개를 끝냈어요', done.length >= 10),
        mk('twenty', '🌟', '스무 세트', '세트 20개를 끝냈어요', done.length >= 20),
        mk('streak3', '🔥', '3일 연속', '3일 연속으로 세트를 끝냈어요', streak >= 3),
        mk('streak7', '☄️', '7일 연속', '7일 연속으로 세트를 끝냈어요', streak >= 7),
        mk('perfect', '💯', '퍼펙트', '힌트와 풀이 없이 세트를 끝냈어요', rows.some((r) => r.completions.some(isPerfect))),
        mk('unit', '🎖️', '단원 정복', '한 단원의 모든 세트를 끝냈어요', [...byUnit.values()].some(allDone)),
        mk('category', '🏆', '분야 정복', '한 분야의 모든 세트를 끝냈어요', [...byCategory.values()].some(allDone)),
        mk('review', '🔁', '복습왕', '같은 세트를 3번 끝냈어요', rows.some((r) => r.completions.length >= 3)),
    ]
}
