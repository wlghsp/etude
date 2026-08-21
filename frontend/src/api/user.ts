import { apiFetch, authHeaders } from './base'

export interface QuestSetProgress {
  questSetId: number
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

export async function fetchProgress() {
  return apiFetch<QuestSetProgress[]>('/progress', { headers: authHeaders() })
}

export async function fetchLeaderboard() {
  return apiFetch<MemberProgress[]>('/leaderboard', { headers: authHeaders() })
}