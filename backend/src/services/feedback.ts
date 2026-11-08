import { db } from "../db.js";
import { listAttachments } from "./feedback-attachments.js";

export async function createFeedback(
    userId: number | null,
    page: string | null,
    questId: number | null,
    questSetId: number | null,
    body: string,
): Promise<number> {
    const [result] = await db.query(
        'INSERT INTO feedback (user_id, page, quest_id, quest_set_id, body) VALUES (?, ?, ?, ?, ?)',
        [userId, page, questId, questSetId, body]
    )
    return (result as { insertId: number }).insertId
}

// 저장 중 실패해 첨부가 없는 글만 남는 상태를 막는다.
export async function deleteFeedback(id: number) {
    await db.query('DELETE FROM feedback WHERE id = ?', [id])
}

export async function getFeedbackList() {
    const [rows] = await db.query(`
        SELECT
            f.id,
            u.name AS userName,
            f.page,
            qs.title AS questSetTitle,
            q.title AS questTitle,
            f.body,
            f.created_at AS createdAt
        FROM feedback f
        LEFT JOIN user u ON f.user_id = u.id
        LEFT JOIN quest_set qs ON f.quest_set_id = qs.id
        LEFT JOIN quest q ON f.quest_id = q.id
        ORDER BY f.created_at DESC
    `)
    const byFeedback = new Map<number, { id: number; mime: string; sizeBytes: number }[]>()
    for (const a of await listAttachments()) {
        const list = byFeedback.get(a.feedback_id) ?? []
        list.push({ id: a.id, mime: a.mime, sizeBytes: a.size_bytes })
        byFeedback.set(a.feedback_id, list)
    }
    return (rows as { id: number }[]).map((r) => ({ ...r, attachments: byFeedback.get(r.id) ?? [] }))
}
