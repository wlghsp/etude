import bcrypt from 'bcrypt'
import { db } from "./db.js";


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
    const [rows] = await db.query(`
      SELECT
        u.name AS userName,
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
      ORDER BY u.name, qs.id
    `) as any[]
    return rows
}

export async function createUser(name: string, email: string, password: string) {
  const hashed = await bcrypt.hash(password, 10)
  const [result] = await db.query(
    'INSERT INTO user (name, email, password, role) VALUES (?, ?, ?, ?)',
    [name, email, hashed, 'member']
  ) as any[]
  return { id: result.insertId, name, email, role: 'member'}
}

export async function resetPassword(id: string, password: string) {
    const hashed = await bcrypt.hash(password, 10)
    await db.query('UPDATE user SET password = ? WHERE id = ?', [hashed, id])
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



