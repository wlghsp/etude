import {authHeaders, apiFetch} from './base'

export { token } from './base'

export async function loginApi(email: string, password: string) {
  return apiFetch<{ token: string; user: { id: number; name: string; email: string; role: string } }>(
      '/auth/login',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      }
  )
}

export async function fetchMe() {
  return apiFetch<{ id: number; name: string; email: string; role: string }>(
      '/me',
      {
        headers: authHeaders(),
      }
  )
}


export async function changePassword(currentPassword: string, newPassword: string) {
  await apiFetch<void>('/me/password', {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ currentPassword, newPassword })
  })
}