import Docker from 'dockerode'
import { db } from './db.js'

export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  grade: (container: Docker.Container) => Promise<boolean>
}

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

export async function getQuestSets() {
  const [rows] = await db.query('SELECT id, title, description FROM quest_set')
  return rows
}

export async function getQuests(questSetId: number) {
  const [rows] = await db.query(
    'SELECT id, title, description, hint, solution FROM quest WHERE quest_set_id = ? ORDER BY order_index',
    [questSetId]
  )
  return rows
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
