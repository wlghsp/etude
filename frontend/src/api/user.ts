import { BASE, authHeaders } from './base'

export async function fetchProgess() {
  const res = await fetch(`${BASE}/progress`, { headers: authHeaders() })
  return res.json()
}

export async function fetchLeaderboard() {
  const res = await fetch(`${BASE}/leaderboard`, { headers: authHeaders() })
  return res.json()
}
