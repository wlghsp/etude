import { db } from '../db.js'

export async function getProgress(userId: number) {
    const [rows] = await db.query(`
      SELECT
        qs.id AS quest_set_id,
        qs.title,
        qs.category,
        COUNT(DISTINCT q.id) AS total,
        COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.quest_id END) AS completed
      FROM quest_set qs
      JOIN quest q ON q.quest_set_id = qs.id
      LEFT JOIN quest_attempt qa ON qa.quest_id = q.id AND qa.user_id = ?
      GROUP BY qs.id
      ORDER BY qs.id
    `, [userId]) as any[]
    return rows
}


export async function getLeaderboard() {
    const [summary] = await db.query(`
        SELECT
            u.id AS userId,
            u.name AS userName,
            COUNT(DISTINCT q.id) AS total,
            COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.quest_id END) AS completed
        FROM user u
        CROSS JOIN quest q
        LEFT JOIN quest_attempt qa ON qa.quest_id = q.id AND qa.user_id = u.id
        WHERE u.role = 'member'
        GROUP BY u.id
        ORDER BY completed DESC, u.name
    `) as any[]

    const [details] = await db.query(`
        SELECT
            u.id AS userId,
            qs.id AS questSetId,
            qs.title AS questSetTitle,
            qs.category,
            COUNT(DISTINCT q.id) AS total,
            COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.quest_id END) AS completed
        FROM user u
        CROSS JOIN quest_set qs
        JOIN quest q ON q.quest_set_id = qs.id
        LEFT JOIN quest_attempt qa ON qa.quest_id = q.id AND qa.user_id = u.id
        WHERE u.role = 'member'
        GROUP BY u.id, qs.id
        ORDER BY u.id, qs.id
    `) as any[]

    return (summary as any[]).map((u: any) => ({
        userId: u.userId,
        userName: u.userName,
        total: Number(u.total),
        completed: Number(u.completed),
        sets: (details as any[])
            .filter((d: any) => d.userId === u.userId)
            .map((d: any) => ({
                questSetId: d.questSetId,
                questSetTitle: d.questSetTitle,
                category: d.category,
                total: Number(d.total),
                completed: Number(d.completed),
            }))
    }))
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
