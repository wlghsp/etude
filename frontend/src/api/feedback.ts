import { BASE, authHeaders } from './base'

export const FEEDBACK_MAX_IMAGES = 3 // 서버(backend/src/services/feedback-attachments.ts)와 같은 값

export async function submitFeedback(data: {
    page: string
    questId?: number | null
    questSetId?: number | null
    body: string
    images?: File[]
}) {
    const { images = [], ...fields } = data
    // 이미지가 없으면 지금까지처럼 JSON, 있으면 multipart (Content-Type 은 브라우저가 boundary 와 함께 정한다)
    let init: RequestInit
    if (images.length === 0) {
        init = { headers: { 'Content-Type': 'application/json', ...authHeaders() }, body: JSON.stringify(fields) }
    } else {
        const form = new FormData()
        form.append('page', fields.page)
        if (fields.questId != null) form.append('questId', String(fields.questId))
        if (fields.questSetId != null) form.append('questSetId', String(fields.questSetId))
        form.append('body', fields.body)
        for (const image of images) form.append('files', image, image.name)
        init = { headers: { ...authHeaders() }, body: form }
    }
    const res = await fetch(`${BASE}/feedback`, { method: 'POST', ...init })
    const json = await res.json().catch(() => ({}))
    if (!res.ok) throw new Error(json.error ?? '전송에 실패했어요. 잠시 후 다시 시도해 주세요.')
    return json
}
