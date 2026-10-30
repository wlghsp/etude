import { db } from '../db.js'

// 리더보드는 "완료한 세트 수"로 순위를 매긴다 (세트 완료가 기록의 단위). 시간은 넣지 않는다.
export async function getLeaderboard() {
    const [sets] = await db.query('SELECT id, title, category FROM quest_set ORDER BY display_order, id') as any[]
    const [members] = await db.query("SELECT id, name FROM user WHERE role = 'member'") as any[]
    const [done] = await db.query(
        'SELECT DISTINCT user_id, quest_set_id FROM set_completion') as any[]

    const doneByUser = new Map<number, Set<number>>()
    for (const d of done as any[]) {
        const set = doneByUser.get(d.user_id) ?? new Set<number>()
        set.add(d.quest_set_id)
        doneByUser.set(d.user_id, set)
    }
    const total = (sets as any[]).length

    return (members as any[])
        .map((u) => {
            const completedSets = doneByUser.get(u.id) ?? new Set<number>()
            return {
                userId: u.id,
                userName: u.name,
                total,
                completed: (sets as any[]).filter((s) => completedSets.has(s.id)).length,
                sets: (sets as any[]).map((s) => ({
                    questSetId: s.id,
                    questSetTitle: s.title,
                    category: s.category,
                    total: 1,
                    completed: completedSets.has(s.id) ? 1 : 0,
                })),
            }
        })
        .sort((a, b) => b.completed - a.completed || a.userName.localeCompare(b.userName))
}

export async function recordAttempt(
    userId: number,
    questId: number,
    questSetId: number,
    sessionId: string,
    passed: boolean,
    elapsedSec?: number,
    hintUsed?: boolean,
    solutionUsed?: boolean
) {
    await db.query(
        `INSERT INTO quest_attempt
            (user_id, quest_id, quest_set_id, session_id, elapsed_sec, hint_used, solution_used, passed)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [userId, questId, questSetId, sessionId, elapsedSec ?? null,
         hintUsed ?? false, solutionUsed ?? false, passed]
    )
}

// ---- 세트 완료 기반 진행현황 (docs/specs/spec_progress_dashboard.md) ----
// 문제 단위가 아니라 "세트를 완료했는가"가 사용자에게 보이는 기록이다. 문제별 채점 기록(quest_attempt)은 계속 쌓지만 화면에는 내보내지 않는다.

export interface CompletionRecord {
    id: number
    completedAt: string
    totalSeconds: number
    questCount: number
    hintFreeCount: number
    solutionFreeCount: number
    detail: Array<{ questId: number; orderIndex: number; title: string; seconds: number; hintUsed: boolean; solutionUsed: boolean; attempts: number }> | null
}

export interface SetProgress {
    questSetId: number
    title: string
    category: string
    completions: CompletionRecord[] // 최근 완료가 먼저
}

function parseDetail(raw: unknown): CompletionRecord['detail'] {
    if (raw == null) return null
    try { return typeof raw === 'string' ? JSON.parse(raw) : (raw as CompletionRecord['detail']) } catch { return null }
}

/** 사용자가 볼 수 있는 세트(공개/관리자/접근 권한)와 각 세트의 완료 기록. */
export async function getSetProgress(userId: number, role: string): Promise<SetProgress[]> {
    const [setRows] = await db.query(`
        SELECT qs.id, qs.title, qs.category
        FROM quest_set qs
        WHERE qs.is_public = TRUE
           OR ? = 'admin'
           OR EXISTS (SELECT 1 FROM quest_set_access qsa WHERE qsa.quest_set_id = qs.id AND qsa.user_id = ?)
        ORDER BY qs.display_order, qs.id
    `, [role, userId]) as any[]
    const [doneRows] = await db.query(`
        SELECT id, quest_set_id, completed_at, total_seconds, quest_count, hint_free_count, solution_free_count, detail
        FROM set_completion WHERE user_id = ? ORDER BY completed_at DESC, id DESC
    `, [userId]) as any[]

    return (setRows as any[]).map((s) => ({
        questSetId: s.id,
        title: s.title,
        category: s.category,
        completions: (doneRows as any[])
            .filter((d) => d.quest_set_id === s.id)
            .map((d) => ({
                id: d.id,
                completedAt: new Date(d.completed_at).toISOString(),
                totalSeconds: Number(d.total_seconds),
                questCount: Number(d.quest_count),
                hintFreeCount: Number(d.hint_free_count),
                solutionFreeCount: Number(d.solution_free_count),
                detail: parseDetail(d.detail),
            })),
    }))
}
