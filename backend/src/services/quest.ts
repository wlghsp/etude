import Docker from 'dockerode'
import { db } from '../db.js'
import type { Quest, QuestSet } from '../types.js'

async function execCheck(container: Docker.Container, cmd: string[]): Promise<boolean> {
  const exec = await container.exec({ Cmd: cmd })
  await exec.start({})
  // exec 완료될 때까지 폴링
  while (true) {
    const info = await exec.inspect()
    if (!info.Running) return info.ExitCode === 0
    await new Promise((r) => setTimeout(r, 100))
  }
}

export async function canAccessQuestSet(userId: number, role: string, questSetId: number) {
  const [rows] = await db.query<any[]>(`
    SELECT 1
    FROM quest_set qs
    WHERE qs.id = ?
      AND (
        qs.is_public = TRUE
        OR ? = 'admin'
        OR EXISTS (
          SELECT 1 FROM quest_set_access qsa
          WHERE qsa.quest_set_id = qs.id AND qsa.user_id = ?
        )
      )`, [questSetId, role, userId])
  return rows.length > 0
}

export async function getQuestSets(userId: number, role: string): Promise<QuestSet[]> {
  const [rows] = await db.query(`
    SELECT qs.id, qs.title, qs.description, qs.sandbox_type, qs.category
    FROM quest_set qs
    WHERE qs.is_public = TRUE
      OR ? = 'admin'
      OR EXISTS (
        SELECT 1 FROM quest_set_access qsa
        WHERE qsa.quest_set_id = qs.id AND qsa.user_id = ?
    )`, [role, userId]
  )
  return rows as QuestSet[]
}

export async function getQuestSetsForAdmin() {
  const [sets] = await db.query<any[]>(
    'SELECT id, title, description, sandbox_type, category, is_public FROM quest_set ORDER BY id'
  )
  const [access] = await db.query<any[]>(`
    SELECT qsa.quest_set_id, u.id AS userId, u.name, u.email
    FROM quest_set_access qsa
    JOIN user u ON u.id = qsa.user_id
  `)
  return sets.map((s) => ({
    ...s,
    is_public: Boolean(s.is_public),
    accessUsers: access
      .filter((a) => a.quest_set_id === s.id)
      .map((a) => ({ id: a.userId, name: a.name, email: a.email }))
  }))
}

export async function setQuestSetPublic(questSetId: number, isPublic: boolean) {
  await db.query('UPDATE quest_set SET is_public = ? WHERE id = ?', [isPublic, questSetId])
}

export async function grantQuestSetAccess(questSetId: number, userId: number) {
  await db.query('INSERT IGNORE INTO quest_set_access (quest_set_id, user_id) VALUES (?, ?)', [questSetId, userId])
}

export async function revokeQuestSetAccess(questSetId: number, userId: number) {
  await db.query('DELETE FROM quest_set_access WHERE quest_set_id = ? AND user_id = ?', [questSetId, userId])
}

export async function getQuests(questSetId: number): Promise<Quest[]> {
  const [rows] = await db.query(
    'SELECT id, title, description, hint, solution, setup_cmd FROM quest WHERE quest_set_id = ? ORDER BY order_index',
    [questSetId]
  )
  return (rows as any[]).map((r) => ({
    ...r,
    setup_cmd: r.setup_cmd ? JSON.parse(r.setup_cmd) : null,
  })) as Quest[]
}

export async function getSetupCmd(questId: number): Promise<string[] | null> {
  const [rows] = await db.query<any[]>(
    'SELECT setup_cmd FROM quest WHERE id = ?',
    [questId]
  )
  if (!rows.length || !rows[0].setup_cmd) return null
  const raw = rows[0].setup_cmd
  return typeof raw === 'string' ? JSON.parse(raw) : raw
}

export async function gradeQuest(
  containerId: string,
  questId: number,
  docker: Docker
): Promise<boolean> {
  const [rows] = await db.query<any[]>(
    'SELECT grade_cmd FROM quest WHERE id = ?',
    [questId]
  )
  if (!rows.length) return false
  const cmd: string[] = JSON.parse(rows[0].grade_cmd)

  const ns = `quest-${containerId.slice(0, 8)}`
  const resolveCmd = cmd.map((s: string) => s.replace(/\$NS/g, ns))

  return execCheck(docker.getContainer(containerId), resolveCmd)
}
