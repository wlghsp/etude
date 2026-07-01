import { db } from "../db.js";

export async function createFeedback(
    userId: number | null,
    page: string,
    questId: number | null,
    questSetId: number | null,
    body: string,
) {
    await db.query(
        'INSERT INTO feedback (user_id, page, quest_id, quest_set_id, body) VALUES (?, ?, ?, ?, ?)',
        [userId, page, questId, questSetId, body]
    )
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
    return rows
}