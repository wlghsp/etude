import { db } from '../db.js'

// 세트 완료 기록 (docs/specs/spec_progress_dashboard.md): 한 번 입장해서 세트의 모든 퀘스트를 통과하면 1건을 남긴다.

export interface CompletionQuest { questId: number; orderIndex: number; title: string }
export interface CompletionAttempt {
    questId: number
    passed: boolean
    elapsedSec: number | null
    hintUsed: boolean
    solutionUsed: boolean
}
export interface CompletionQuestDetail {
    questId: number
    orderIndex: number
    title: string
    seconds: number
    hintUsed: boolean
    solutionUsed: boolean
    attempts: number
}
export interface Completion {
    questCount: number
    totalSeconds: number
    hintFreeCount: number
    solutionFreeCount: number
    detail: CompletionQuestDetail[]
}

/**
 * 이 세션의 채점 기록만으로 세트를 완료했는지 판단하고, 완료했으면 요약을 만든다.
 * 세트의 모든 퀘스트에 통과한 시도가 하나라도 있어야 한다. 아니면 null.
 */
export function buildCompletion(quests: CompletionQuest[], attempts: CompletionAttempt[]): Completion | null {
    if (quests.length === 0) return null
    const detail: CompletionQuestDetail[] = []
    for (const q of [...quests].sort((a, b) => a.orderIndex - b.orderIndex)) {
        const mine = attempts.filter((a) => a.questId === q.questId)
        const passed = mine.filter((a) => a.passed)
        if (passed.length === 0) return null
        // 통과한 시도 중 가장 짧은 시간 (시간이 없는 기록은 뒤로)
        const best = [...passed].sort((a, b) => (a.elapsedSec ?? Infinity) - (b.elapsedSec ?? Infinity))[0]
        if (!best) return null
        detail.push({
            questId: q.questId,
            orderIndex: q.orderIndex,
            title: q.title,
            seconds: best.elapsedSec ?? 0,
            hintUsed: best.hintUsed,
            solutionUsed: best.solutionUsed,
            attempts: mine.length,
        })
    }
    return {
        questCount: detail.length,
        totalSeconds: detail.reduce((sum, d) => sum + d.seconds, 0),
        hintFreeCount: detail.filter((d) => !d.hintUsed).length,
        solutionFreeCount: detail.filter((d) => !d.solutionUsed).length,
        detail,
    }
}

export type CompleteResult = { recorded: true; completion: Completion } | { recorded: false }

/** 서버가 quest_attempt 로 직접 확인한 뒤에만 저장한다 (화면의 요청만 믿지 않는다). 같은 세션의 중복 요청은 한 번만 저장된다. */
export async function recordSetCompletion(userId: number, questSetId: number, sessionId: string): Promise<CompleteResult> {
    const [questRows] = await db.query(
        'SELECT id, order_index, title FROM quest WHERE quest_set_id = ? ORDER BY order_index',
        [questSetId]) as any[]
    const quests: CompletionQuest[] = (questRows as any[]).map((q) => ({ questId: q.id, orderIndex: q.order_index, title: q.title }))

    const [attemptRows] = await db.query(
        `SELECT quest_id, passed, elapsed_sec, hint_used, solution_used
         FROM quest_attempt WHERE user_id = ? AND quest_set_id = ? AND session_id = ?`,
        [userId, questSetId, sessionId]) as any[]
    const attempts: CompletionAttempt[] = (attemptRows as any[]).map((a) => ({
        questId: a.quest_id,
        passed: Boolean(a.passed),
        elapsedSec: a.elapsed_sec === null ? null : Number(a.elapsed_sec),
        hintUsed: Boolean(a.hint_used),
        solutionUsed: Boolean(a.solution_used),
    }))

    const completion = buildCompletion(quests, attempts)
    if (!completion) return { recorded: false }

    await db.query(
        `INSERT IGNORE INTO set_completion
           (user_id, quest_set_id, session_id, quest_count, total_seconds, hint_free_count, solution_free_count, detail)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [userId, questSetId, sessionId, completion.questCount, completion.totalSeconds,
         completion.hintFreeCount, completion.solutionFreeCount, JSON.stringify(completion.detail)])
    return { recorded: true, completion }
}
