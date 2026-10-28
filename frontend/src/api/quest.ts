import { BASE, authHeaders } from './base'

export async function fetchQuestSets() {
  return fetch(`${BASE}/quest-sets`, { headers: authHeaders() }).then((r) => r.json())
}

export async function fetchQuests(setId: number) {
  return fetch(`${BASE}/quest-sets/${setId}/quests`, { headers: authHeaders() }).then((r) => r.json())
}

// 채점 요청이 HTTP 오류로 끝났을 때. 화면이 상태 코드별로 안내 문구를 고른다.
export class GradeRequestError extends Error {
  status: number
  constructor(status: number) {
    super(`grade failed: ${status}`)
    this.status = status
  }
}

export async function gradeQuest(
  containerId: string,
  questId: number,
  sessionId: string,
  elapsedSec: number,
  hintUsed: boolean,
  solutionUsed: boolean,
) {
  return fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId, questId, sessionId, elapsedSec, hintUsed, solutionUsed }),
  }).then((r) => {
    if (!r.ok) throw new GradeRequestError(r.status)
    return r.json()
  })
}
