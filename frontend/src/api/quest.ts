import {authHeaders, apiFetch} from './base'
import type {Quest, QuestSet} from "../types.ts";

export async function fetchQuestSets() {
  return apiFetch<QuestSet[]>('/quest-sets', { headers: authHeaders() })
}

export async function fetchQuests(setId: number) {
  return apiFetch<Quest[]>(`/quest-sets/${setId}/quests`, { headers: authHeaders() })
}

export async function gradeQuest(
  containerId: string,
  questId: number,
  questSetId: number,
  sessionId: string,
  elapsedSec: number,
  hintUsed: boolean,
  solutionUsed: boolean,
) {
  return apiFetch<{ passed: boolean }>('/grade', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId, questId, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed })
  })
}

export async function endSession(containerId: string) {
  return apiFetch<void>(`/session/end`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId }),
  })
}
