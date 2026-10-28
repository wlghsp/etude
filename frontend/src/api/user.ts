import { BASE, authHeaders } from './base'

export interface QuestSetProgress {
  quest_set_id: number
  title: string
  category: string
  total: number
  completed: number
}

export interface QuestSetProgressDetail {
  questSetId: number
  questSetTitle: string
  category: string
  total: number
  completed: number
}

export interface MemberProgress {
  userId: number
  userName: string
  total: number
  completed: number
  sets: QuestSetProgressDetail[]
}

export async function fetchProgress(): Promise<QuestSetProgress[]> {
  const res = await fetch(`${BASE}/progress`, { headers: authHeaders() })
  return res.json()
}

export async function fetchLeaderboard(): Promise<MemberProgress[]> {
  const res = await fetch(`${BASE}/leaderboard`, { headers: authHeaders() })
  return res.json()
}
