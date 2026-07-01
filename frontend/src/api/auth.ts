import { BASE, authHeaders } from './base'

export { token } from './base'

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
