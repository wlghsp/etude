
const BASE = `http://${window.location.hostname}:3001`

export async function fetchQuestSets() {
  return fetch(`${BASE}/quest-sets`, { headers: authHeaders() }).then((r) => r.json())
}

export async function fetchQuests(setId: number) {
  return fetch(`${BASE}/quest-sets/${setId}/quests`, { headers: authHeaders() }).then((r) => r.json())
}

export async function gradeQuest(containerId: string, questId: number) {
  return fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId, questId }),
  }).then((r) => r.json())
}

export async function endSession(containerId: string) {
  return fetch(`${BASE}/session/end`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId }),
  }).then((r) => r.json())
}

export const token = {
  get: () => localStorage.getItem('token') ?? '',
  set: (t: string) => localStorage.setItem('token', t),
  clear: () => localStorage.removeItem('token'),
}

function authHeaders(): HeadersInit {
  const t = token.get()
  return t ? { 'Authorization': `Bearer ${t}`} : {}
}

export async function loginApi(email: string, password: string) {
  const res = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json'},
    body: JSON.stringify({ email, password })
  })
  const data = await res.json()
  if (!res.ok) throw new Error(data.error)
  return data as { token: string; user: { id: number; name: string; email: string; role: string }}
}

export async function fetchMe() {
  const res = await fetch(`${BASE}/me`, { headers: authHeaders() })
  if (!res.ok) throw new Error('unauthorized')
  return res.json()
}

export async function fetchProgess() {
  const res = await fetch(`${BASE}/progress`, { headers: authHeaders() })
  return res.json()
}

export async function fetchLeaderboard() {
  const res = await fetch(`${BASE}/leaderboard`, { headers: authHeaders() })
  return res.json()
}
