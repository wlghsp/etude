import { db } from '../db.js'

// 시간 제한 세트(시험형)의 시작 시각을 서버가 기록하고 마감을 판단한다. docs/specs/spec_units.md "시간 제한 세트"
// 시각은 모두 DB 의 NOW() 기준이라 서버 시계·클라이언트 시계와 무관하다.

export const EXPIRY_GRACE_SEC = 5 // 마감 직전에 보낸 요청이 네트워크 지연으로 늦게 닿아도 받아 준다

export const remainingSec = (limitSec: number, elapsedSec: number) => Math.max(0, limitSec - elapsedSec)
export const isExpired = (limitSec: number, elapsedSec: number) => elapsedSec > limitSec + EXPIRY_GRACE_SEC

async function limitOf(questSetId: number): Promise<number | null> {
    const [rows] = await db.query('SELECT time_limit_sec FROM quest_set WHERE id = ?', [questSetId]) as any[]
    const limit = (rows as any[])[0]?.time_limit_sec
    return limit === null || limit === undefined ? null : Number(limit)
}

async function elapsedOf(userId: number, questSetId: number, sessionId: string): Promise<number | null> {
    const [rows] = await db.query(
        `SELECT TIMESTAMPDIFF(SECOND, started_at, NOW()) AS elapsed FROM set_run
         WHERE user_id = ? AND quest_set_id = ? AND session_id = ?`,
        [userId, questSetId, sessionId]) as any[]
    const r = (rows as any[])[0]
    return r ? Number(r.elapsed) : null
}

/** 시험을 시작한다. 같은 세션이 다시 불러도 처음 시작 시각을 유지한다 (새로고침해도 시간이 되돌아가지 않는다). */
export async function startRun(userId: number, questSetId: number, sessionId: string): Promise<{ limitSec: number | null; remainingSec: number | null }> {
    const limit = await limitOf(questSetId)
    if (limit === null) return { limitSec: null, remainingSec: null }
    await db.query('INSERT IGNORE INTO set_run (user_id, quest_set_id, session_id) VALUES (?, ?, ?)', [userId, questSetId, sessionId])
    const elapsed = (await elapsedOf(userId, questSetId, sessionId)) ?? 0
    return { limitSec: limit, remainingSec: remainingSec(limit, elapsed) }
}

export type RunCheck = { ok: true } | { ok: false; reason: 'not_started' | 'expired' }

/** 제출·채점·완료 요청을 받아도 되는지. 시간 제한이 없는 세트는 항상 허용한다. */
export async function checkRun(userId: number, questSetId: number, sessionId: string): Promise<RunCheck> {
    const limit = await limitOf(questSetId)
    if (limit === null) return { ok: true }
    const elapsed = await elapsedOf(userId, questSetId, sessionId)
    if (elapsed === null) return { ok: false, reason: 'not_started' }
    return isExpired(limit, elapsed) ? { ok: false, reason: 'expired' } : { ok: true }
}
