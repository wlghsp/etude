import Docker from 'dockerode'
import { db } from '../db.js'
import type { Quest, QuestSet } from '../types.js'

async function execCheck(container: Docker.Container, cmd: string[], timeoutMs = 15000): Promise<boolean> {
  const exec = await container.exec({ Cmd: cmd })
  await exec.start({})
  const start = Date.now()
  while (true) {
    const info = await exec.inspect()
    if (!info.Running) return info.ExitCode === 0
    if (Date.now() - start > timeoutMs) return false
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

// 퀘스트가 속한 세트와 샌드박스 타입을 DB에서 확정한다. 터미널 접근 권한과 컨테이너 종류의 기준이 된다.
export async function getQuestContext(questId: number): Promise<{ questSetId: number; sandboxType: string } | null> {
  const [rows] = await db.query<any[]>(`
    SELECT q.quest_set_id, qs.sandbox_type
    FROM quest q
    JOIN quest_set qs ON qs.id = q.quest_set_id
    WHERE q.id = ?`, [questId])
  const row = rows[0]
  return row ? { questSetId: row.quest_set_id, sandboxType: row.sandbox_type } : null
}

export async function getQuestSets(userId: number, role: string): Promise<QuestSet[]> {
  const [rows] = await db.query(`
    SELECT qs.id, qs.title, qs.description, qs.sandbox_type, qs.category, qs.is_review, qs.time_limit_sec, qs.unit_id, u.title AS unit_title, u.display_order AS unit_order
    FROM quest_set qs
    LEFT JOIN unit u ON u.id = qs.unit_id
    WHERE qs.is_public = TRUE
      OR ? = 'admin'
      OR EXISTS (
        SELECT 1 FROM quest_set_access qsa
        WHERE qsa.quest_set_id = qs.id AND qsa.user_id = ?
    )
    ORDER BY qs.display_order, qs.id`, [role, userId]
  )
  // MariaDB 의 BOOLEAN 은 0/1 로 오므로 화면이 쓰기 쉽게 boolean 으로 바꾼다
  return (rows as any[]).map((r) => ({ ...r, is_review: Boolean(r.is_review) })) as QuestSet[]
}

export async function getQuestSetsForAdmin() {
  const [sets] = await db.query<any[]>(
    'SELECT id, title, description, sandbox_type, category, is_public FROM quest_set ORDER BY display_order, id'
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
  // answer_index, explanation 은 일부러 조회하지 않는다 (정답이 화면으로 나가면 안 된다)
  const [rows] = await db.query(
    'SELECT id, title, description, hint, solution, setup_cmd, kind, choices, checks FROM quest WHERE quest_set_id = ? ORDER BY order_index',
    [questSetId]
  )
  return (rows as any[]).map(({ checks, ...r }) => ({
    ...r,
    setup_cmd: r.setup_cmd ? JSON.parse(r.setup_cmd) : null,
    choices: r.choices ? (typeof r.choices === 'string' ? JSON.parse(r.choices) : r.choices) : null,
    // 조건의 이름만 내보낸다. 채점 명령(cmd)은 학습자에게 보내지 않는다.
    check_labels: parseChecks(checks)?.map((c) => c.label) ?? null,
  })) as Quest[]
}

export interface ChoiceQuest {
  questId: number
  questSetId: number
  kind: string
  choiceCount: number
  answerIndex: number | null
  explanation: string | null
}

/** 객관식 판정에 필요한 값을 DB에서 읽는다 (정답과 해설 포함 — 서버 안에서만 쓴다). */
export async function getChoiceQuest(questId: number): Promise<ChoiceQuest | null> {
  const [rows] = await db.query<any[]>(
    'SELECT id, quest_set_id, kind, choices, answer_index, explanation FROM quest WHERE id = ?',
    [questId]
  )
  const r = rows[0]
  if (!r) return null
  const choices = r.choices ? (typeof r.choices === 'string' ? JSON.parse(r.choices) : r.choices) : []
  return {
    questId: r.id,
    questSetId: r.quest_set_id,
    kind: r.kind,
    choiceCount: Array.isArray(choices) ? choices.length : 0,
    answerIndex: r.answer_index === null ? null : Number(r.answer_index),
    explanation: r.explanation ?? null,
  }
}

/** 선택한 번호가 정답인지 판정한다. 객관식이 아니거나 정답이 없거나 번호가 범위 밖이면 null (잘못된 요청). */
export function judgeChoice(quest: ChoiceQuest, choiceIndex: unknown): boolean | null {
  if (quest.kind !== 'choice' || quest.answerIndex === null) return null
  if (typeof choiceIndex !== 'number' || !Number.isInteger(choiceIndex) || choiceIndex < 0 || choiceIndex >= quest.choiceCount) return null
  return choiceIndex === quest.answerIndex
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

export interface GradeCheck { label: string; passed: boolean }
export interface GradeResult {
  passed: boolean
  checks: GradeCheck[] | null // 조건별 결과. 조건 목록이 없는 문제는 null
}

interface QuestCheck { label: string; cmd: string[] }

// quest.checks: [{ label, cmd }] 형태의 JSON. 형식이 맞지 않으면 없는 것으로 보고 grade_cmd 로 채점한다.
function parseChecks(raw: unknown): QuestCheck[] | null {
  if (raw == null) return null
  let value: unknown
  try { value = typeof raw === 'string' ? JSON.parse(raw) : raw } catch { return null }
  if (!Array.isArray(value) || value.length === 0) return null
  const ok = value.every((c) => c && typeof c.label === 'string' && Array.isArray(c.cmd) && c.cmd.every((x: unknown) => typeof x === 'string'))
  return ok ? (value as QuestCheck[]) : null
}

/** 채점한다. 조건 목록(checks)이 있으면 조건마다 실행해 결과를 함께 돌려주고(모두 통과해야 passed), 없으면 grade_cmd 하나로 채점한다. */
export async function gradeQuest(
  containerId: string,
  questId: number,
  docker: Docker
): Promise<GradeResult> {
  const [rows] = await db.query<any[]>(
    'SELECT grade_cmd, checks FROM quest WHERE id = ?',
    [questId]
  )
  if (!rows.length) return { passed: false, checks: null }

  const ns = `quest-${containerId.slice(0, 8)}`
  const resolveCmd = (cmd: string[]) => cmd.map((s: string) => s.replace(/\$NS/g, ns))
  const container = docker.getContainer(containerId)

  const checks = parseChecks(rows[0].checks)
  if (!checks) {
    const cmd: string[] = JSON.parse(rows[0].grade_cmd)
    return { passed: await execCheck(container, resolveCmd(cmd)), checks: null }
  }

  const results: GradeCheck[] = []
  for (const c of checks) results.push({ label: c.label, passed: await execCheck(container, resolveCmd(c.cmd)) })
  return { passed: results.every((r) => r.passed), checks: results }
}
