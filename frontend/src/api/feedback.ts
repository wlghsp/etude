import { apiFetch } from './base'

export async function submitFeedback(data: {
    page: string
    questId?: number | null
    questSetId?: number | null
    body: string
}) {
    return apiFetch<void>('/feedback', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    })
}
