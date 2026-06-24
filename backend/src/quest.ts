import Docker from 'dockerode'
import { db } from './db.js'
import type { Quest, QuestSet } from './types.js'

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

export async function getQuestSets(): Promise<QuestSet[]> {
  const [rows] = await db.query('SELECT id, title, description, sandbox_type FROM quest_set')
  return rows as QuestSet[]
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
  return execCheck(docker.getContainer(containerId), cmd)
}
