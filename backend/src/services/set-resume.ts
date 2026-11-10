import { db } from '../db.js'
import { summarizeQuestAttempts, type CompletionAttempt } from './set-completion.js'

// 세트 이어 풀기 (docs/specs/spec_resume_set.md): 완료하지 못한 세션을 다음 방문에서 이어 쓰게 한다.
// 새 테이블 없이 quest_attempt(문제별 통과 기록)와 set_completion(완료한 세션)에서 구한다.

export const RESUME_RETENTION_DAYS = 30

// 이어 풀기 대상이 아닌 세트: 시험형(제한 시간이 세션에 묶임), 앞 문제의 컨테이너 상태가 전제인 세트
const NOT_RESUMABLE_SANDBOX = new Set(['docker-persistent'])

// 화면의 문제별 기록(QuestRecord)과 같은 모양 + 문제 번호
export interface PassedQuest { questId: number; seconds: number; hintUsed: boolean; solutionUsed: boolean; attempts: number }
export interface ResumableRun { sessionId: string | null; passed: PassedQuest[] }
const NONE: ResumableRun = { sessionId: null, passed: [] }

/**
 * 이 사람이 이 세트에서 이어 풀 수 있는 가장 최근 세션과, 그 세션에서 통과한 문제의 기록(문제 순서대로, 완료 요약과 같은 규칙).
 * 조건: 통과한 시도가 있고, set_completion 에 없고(아직 완료하지 않음), 마지막 시도가 보관 기간 안.
 */
export async function findResumableRun(userId: number, questSetId: number): Promise<ResumableRun> {
    const [setRows] = await db.query('SELECT sandbox_type, time_limit_sec FROM quest_set WHERE id = ?', [questSetId]) as any[]
    const set = (setRows as any[])[0]
    if (!set || set.time_limit_sec !== null || NOT_RESUMABLE_SANDBOX.has(set.sandbox_type)) return NONE

    const [sessionRows] = await db.query(
        `SELECT a.session_id
         FROM quest_attempt a
         WHERE a.user_id = ? AND a.quest_set_id = ?
           AND NOT EXISTS (SELECT 1 FROM set_completion c
                           WHERE c.user_id = a.user_id AND c.quest_set_id = a.quest_set_id AND c.session_id = a.session_id)
         GROUP BY a.session_id
         HAVING SUM(a.passed) > 0 AND MAX(a.attempted_at) >= NOW() - INTERVAL ? DAY
         ORDER BY MAX(a.attempted_at) DESC LIMIT 1`,
        [userId, questSetId, RESUME_RETENTION_DAYS]) as any[]
    const sessionId = (sessionRows as any[])[0]?.session_id as string | undefined
    if (!sessionId) return NONE

    const [attemptRows] = await db.query(
        `SELECT a.quest_id, a.passed, a.elapsed_sec, a.hint_used, a.solution_used
         FROM quest_attempt a JOIN quest q ON q.id = a.quest_id
         WHERE a.user_id = ? AND a.quest_set_id = ? AND a.session_id = ?
         ORDER BY q.order_index, a.id`,
        [userId, questSetId, sessionId]) as any[]
    const byQuest = new Map<number, CompletionAttempt[]>()
    for (const r of attemptRows as any[]) {
        const list = byQuest.get(Number(r.quest_id)) ?? []
        list.push({
            questId: Number(r.quest_id),
            passed: Boolean(r.passed),
            elapsedSec: r.elapsed_sec === null ? null : Number(r.elapsed_sec),
            hintUsed: Boolean(r.hint_used),
            solutionUsed: Boolean(r.solution_used),
        })
        byQuest.set(Number(r.quest_id), list)
    }
    const passed: PassedQuest[] = []
    for (const [questId, mine] of byQuest) {
        const summary = summarizeQuestAttempts(mine)
        if (summary) passed.push({ questId, ...summary })
    }
    return { sessionId, passed }
}
