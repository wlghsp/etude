import { BASE, authHeaders } from './base'

export interface CompletionQuestDetail {
  questId: number
  orderIndex: number
  title: string
  seconds: number
  hintUsed: boolean
  solutionUsed: boolean
  attempts: number
}

// 세트를 한 번 완료한 기록 (사용자에게 보이는 기록의 단위). detail 은 예전에 이전된 기록에는 없다.
export interface CompletionRecord {
  id: number
  completedAt: string
  totalSeconds: number
  questCount: number
  hintFreeCount: number
  solutionFreeCount: number
  detail: CompletionQuestDetail[] | null
}

export interface SetProgress {
  questSetId: number
  title: string
  category: string
  completions: CompletionRecord[] // 최근 완료가 먼저
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

export async function fetchProgress(): Promise<SetProgress[]> {
  const res = await fetch(`${BASE}/progress`, { headers: authHeaders() })
  if (!res.ok) throw new Error('진행현황을 불러오지 못했습니다.')
  return res.json()
}

export async function fetchLeaderboard(): Promise<MemberProgress[]> {
  const res = await fetch(`${BASE}/leaderboard`, { headers: authHeaders() })
  return res.json()
}
