import { BASE, authHeaders } from './base'

export async function submitFeedback(data: {
    page: string
    questId?: number | null
    questSetId?: number | null
    body: string
}) {
    return fetch(`${BASE}/feedback`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...authHeaders() },
        body: JSON.stringify(data),
    }).then((r) => r.json())
}
