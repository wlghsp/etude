import { BASE, authHeaders } from './base'

// 활동 피드 (docs/specs/spec_activity_feed.md)
export interface FeedComment {
  id: number
  userId: number
  userName: string
  body: string
  createdAt: string
  canDelete: boolean
}

export interface FeedEvent {
  id: number
  userId: number
  userName: string
  questSetId: number
  setTitle: string
  category: string
  completedAt: string
  questCount: number
  perfect: boolean
  isFirst: boolean
  isReview: boolean
  likes: number
  likedByMe: boolean
  comments: FeedComment[]
}

async function parse<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.json().catch(() => ({} as { error?: string }))
    throw new Error(body.error ?? '요청을 처리하지 못했어요.')
  }
  return res.json()
}

const post = (url: string, body?: unknown) => fetch(`${BASE}${url}`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', ...authHeaders() },
  body: body === undefined ? undefined : JSON.stringify(body),
})

export const fetchFeed = (before?: number): Promise<FeedEvent[]> =>
  fetch(`${BASE}/feed${before ? `?before=${before}` : ''}`, { headers: authHeaders() }).then((r) => parse<FeedEvent[]>(r))

export const toggleLike = (id: number) => post(`/feed/${id}/like`).then((r) => parse<{ liked: boolean; likes: number }>(r))
export const postComment = (id: number, body: string) => post(`/feed/${id}/comments`, { body }).then((r) => parse<FeedComment>(r))
export const removeComment = (id: number) => fetch(`${BASE}/feed/comments/${id}`, { method: 'DELETE', headers: authHeaders() }).then((r) => parse<{ ok: boolean }>(r))
export const fetchFeedSummary = () => fetch(`${BASE}/feed/summary`, { headers: authHeaders() }).then((r) => parse<{ newForMe: number }>(r))
export const markFeedSeen = () => post('/feed/seen').then((r) => parse<{ ok: boolean }>(r))
