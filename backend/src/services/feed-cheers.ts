import { BADGES, snapshot, type SetInfo } from './gamification.js'
import { TITLES, levelOf, type CompletionRec } from './xp.js'

export type { CompletionRec, SetInfo }

// 소식에 붙는 축하(좋은 소식만). 세트 완료 한 건 시점에 처음 이룬 일을 그 사람의 완료 기록으로 되돌려 계산한다.
// 규칙(XP·레벨·배지)은 gamification.ts·xp.ts 한 곳을 쓴다. docs/specs/spec_activity_feed.md "축하 소식"

export type CheerKind = 'category' | 'unit' | 'challenge' | 'level' | 'streak' | 'badge'
export interface Cheer { kind: CheerKind; icon: string; text: string }

const STREAK_MILESTONES = [14, 30] // 3·7일은 배지로 축하한다
const MONTHLY_TARGET = 10 // 이달의 도전: goals.ts 와 같은 값
const PRIORITY: CheerKind[] = ['category', 'unit', 'challenge', 'level', 'streak', 'badge']

/** completionId 에 해당하는 완료로 처음 이룬 일. recs 는 한 사람의 전체 완료 기록 (id 오름차순). 우선순위 순서로 돌려준다. */
export function cheersFor(recs: CompletionRec[], sets: SetInfo[], completionId: number): Cheer[] {
    const at = recs.find((r) => r.id === completionId)
    if (!at) return []
    const before = snapshot(recs.filter((r) => r.id < completionId), sets, at.day)
    const after = snapshot(recs.filter((r) => r.id <= completionId), sets, at.day)
    const out: Cheer[] = []

    for (const c of after.categories) if (!before.categories.has(c)) out.push({ kind: 'category', icon: '🌟', text: `${c} 분야를 모두 끝냈어요` })
    for (const u of after.units) if (!before.units.has(u)) out.push({ kind: 'unit', icon: '🎖️', text: '한 단원을 모두 끝냈어요' })
    if (after.monthCount >= MONTHLY_TARGET && before.monthCount < MONTHLY_TARGET) out.push({ kind: 'challenge', icon: '🎁', text: `${Number(at.day.slice(5, 7))}월 도전을 완료했어요` })
    const level = levelOf(after.xp)
    if (level > levelOf(before.xp)) out.push({ kind: 'level', icon: '⭐', text: `Lv.${level} ${TITLES[Math.min(level - 1, TITLES.length - 1)]} 레벨이 됐어요` })
    for (const m of STREAK_MILESTONES) if (after.streak >= m && before.streak < m) out.push({ kind: 'streak', icon: '🔥', text: `${m}일 연속 학습!` })
    // 단원·분야 정복 배지는 위의 단원·분야 축하로 따로 알린다
    for (const b of BADGES) if (b.id !== 'unit' && b.id !== 'category' && after.badges.has(b.id) && !before.badges.has(b.id)) out.push({ kind: 'badge', icon: b.icon, text: `'${b.title}' 배지를 얻었어요` })

    return out.sort((a, b) => PRIORITY.indexOf(a.kind) - PRIORITY.indexOf(b.kind))
}
