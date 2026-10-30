import { getSetProgress, type CompletionRecord, type SetProgress } from './progress.js'

// 복습 허브: 다시 풀기 추천, 아직 안 푼 복습 세트, 오랜만에 다시 볼 세트와 오늘의 추천 1개. 세트 단위이고 본인에게만 보인다. docs/specs/spec_progress_dashboard.md

const STALE_DAYS = 14
const STALE_MAX = 5
const DAY_MS = 24 * 60 * 60 * 1000

export interface ReviewItem { questSetId: number; title: string; category: string; reason: string; gainXp: number | null }
export interface Review {
    pick: ReviewItem | null
    retry: ReviewItem[]
    reviewSets: ReviewItem[]
    stale: ReviewItem[]
}

const isPerfect = (c: CompletionRecord) => c.questCount > 0 && c.hintFreeCount === c.questCount && c.solutionFreeCount === c.questCount

/** 이 세트를 퍼펙트로 다시 끝낼 때 늘어나는 XP. 규칙은 xp.ts 의 xpOf 와 같다 (복습 5 XP 는 5번까지, 퍼펙트 보너스는 처음 한 번). */
function gainIfPerfect(row: SetProgress): number {
    const n = row.completions.length
    const reviewBonus = n <= 5 ? 5 : 0
    const perfectBonus = row.completions.some(isPerfect) ? 0 : (row.completions[0]?.questCount ?? 0) * 5
    return reviewBonus + perfectBonus
}

const item = (row: SetProgress, reason: string, gainXp: number | null): ReviewItem =>
    ({ questSetId: row.questSetId, title: row.title, category: row.category, reason, gainXp })

export function buildReview(rows: SetProgress[], now: Date): Review {
    const retry = rows
        .filter((r) => r.retry !== null)
        .sort((a, b) => b.retry!.assistedPct - a.retry!.assistedPct)
        .map((r) => item(r, `힌트·풀이의 도움을 ${r.retry!.assistedPct}% 썼어요. 이번엔 퍼펙트에 도전해 봐요!`, gainIfPerfect(r)))

    const reviewSets = rows
        .filter((r) => r.isReview && r.completions.length === 0)
        .map((r) => item(r, '새 개념 없이, 앞에서 배운 것을 섞어서 풀어 봐요', null))

    const inRetry = new Set(retry.map((i) => i.questSetId))
    const stale = rows
        .filter((r) => r.completions.length > 0 && !inRetry.has(r.questSetId))
        .map((r) => ({ r, days: Math.floor((now.getTime() - new Date(r.completions[0]!.completedAt).getTime()) / DAY_MS) }))
        .filter((x) => x.days >= STALE_DAYS)
        .sort((a, b) => b.days - a.days)
        .slice(0, STALE_MAX)
        .map((x) => item(x.r, `${x.days}일 전에 끝낸 세트예요. 잊기 전에 한 번 더 풀어 봐요`, gainIfPerfect(x.r)))

    return { pick: retry[0] ?? reviewSets[0] ?? stale[0] ?? null, retry, reviewSets, stale }
}

export async function getReview(userId: number, role: string): Promise<Review> {
    return buildReview(await getSetProgress(userId, role), new Date())
}
