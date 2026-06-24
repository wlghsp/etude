
const BASE = 'http://localhost:3001'

export async function fetchQuestSets() {
  return fetch(`${BASE}/quest-sets`).then((r) => r.json())
}

export async function fetchQuests(setId: number) {
  return fetch(`${BASE}/quest-sets/${setId}/quests`).then((r) => r.json())
}

export async function gradeQuest(containerId: string, questId: number) {
  return fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ containerId, questId }),
  }).then((r) => r.json())
}