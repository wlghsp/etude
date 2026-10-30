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
  expired: boolean // 시간 제한 세트에서 마감이 지나 거부됐을 때
  constructor(status: number, expired = false) {
    super(`grade failed: ${status}`)
    this.status = status
    this.expired = expired
  }
}

async function requestError(r: Response) {
  const body = await r.json().catch(() => null)
  return new GradeRequestError(r.status, Boolean(body?.expired))
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
  }).then(async (r) => {
    if (!r.ok) throw await requestError(r)
    return r.json()
  })
}

// 세트 완료 기록을 저장한다. 서버가 이 세션의 채점 기록으로 직접 확인한 뒤에만 저장하고, 같은 세션의 중복 요청은 한 번만 저장된다.
export async function completeSet(setId: number, sessionId: string): Promise<void> {
  const r = await fetch(`${BASE}/quest-sets/${setId}/complete`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ sessionId }),
  })
  if (!r.ok) throw await requestError(r)
}

// 객관식 답 제출. 서버가 정답을 판정하고, 정답일 때만 해설을 돌려준다.
export async function answerChoice(
  setId: number,
  // 객관식은 choiceIndex, 순서 맞추기·빈칸 채우기는 answer(번호 배열)
  body: { questId: number; sessionId: string; choiceIndex?: number; answer?: number[]; elapsedSec: number; hintUsed: boolean },
): Promise<{ passed: boolean; results?: boolean[]; explanation?: string | null }> {
  const r = await fetch(`${BASE}/quest-sets/${setId}/answer`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify(body),
  })
  if (!r.ok) throw await requestError(r)
  return r.json()
}

// 시간 제한 세트(시험형)를 시작한다. 시작 시각은 서버가 기록하고, 제한이 없는 세트는 null 을 돌려준다.
export async function startSet(setId: number, sessionId: string): Promise<{ limitSec: number | null; remainingSec: number | null }> {
  const r = await fetch(`${BASE}/quest-sets/${setId}/start`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ sessionId }),
  })
  if (!r.ok) throw await requestError(r)
  return r.json()
}
