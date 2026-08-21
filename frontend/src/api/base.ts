export const BASE = import.meta.env.VITE_API_BASE ?? ''

export const token = {
  get: () => localStorage.getItem('token') ?? '',
  set: (t: string) => localStorage.setItem('token', t),
  clear: () => localStorage.removeItem('token'),
}

export function authHeaders(): HeadersInit {
  const t = token.get()
  return t ? { 'Authorization': `Bearer ${t}`} : {}
}

interface ApiResponse<T> {
  meta: { result: 'SUCCESS' | 'FAIL'; errorCode: string | null; message: string | null }
  data: T
}

export async function apiFetch<T>(path: string, options?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, options)
  const body: ApiResponse<T> = await res.json()
  if (body.meta.result !== 'SUCCESS') {
    throw new Error(body.meta.message ?? '요청에 실패했습니다.')
  }
  return body.data
}
