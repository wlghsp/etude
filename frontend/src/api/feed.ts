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

export type Reaction = 'like' | 'clap' | 'strong' | 'fire' // ❤️ 👏 💪 🔥
export const REACTIONS: Array<{ kind: Reaction; icon: string; label: string }> = [
  { kind: 'like', icon: '❤️', label: '좋아요' },
  { kind: 'clap', icon: '👏', label: '박수' },
  { kind: 'strong', icon: '💪', label: '힘내요' },
  { kind: 'fire', icon: '🔥', label: '대단해요' },
]

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
  cheers: Array<{ kind: 'category' | 'unit' | 'challenge' | 'level' | 'streak' | 'badge'; key: string; icon: string; text: string }> // 이 완료로 처음 이룬 일 (우선순위 순)
  reactions: Record<Reaction, number> // 반응 종류별 수
  myReaction: Reaction | null // 내가 남긴 반응 (한 사람 한 반응)
  comments: FeedComment[]
}

async function parse<T>(res: Response): Promise<T> {
  if (!res.ok) {
    const body = await res.json().catch(() => ({} as { error?: string }))
    throw new Error(body.error ?? '요청을 처리하지 못했어요.')
  }
  return res.json()
}

// 본문이 없는 요청(좋아요, 본 시각 기록)에 JSON 헤더를 붙이면 서버가 "빈 JSON 본문"으로 400 을 돌려주므로, 본문이 있을 때만 붙인다.
const post = (url: string, body?: unknown) => fetch(`${BASE}${url}`, {
  method: 'POST',
  headers: body === undefined ? authHeaders() : { 'Content-Type': 'application/json', ...authHeaders() },
  body: body === undefined ? undefined : JSON.stringify(body),
})

export const fetchFeed = (before?: number): Promise<FeedEvent[]> =>
  fetch(`${BASE}/feed${before ? `?before=${before}` : ''}`, { headers: authHeaders() }).then((r) => parse<FeedEvent[]>(r))

// 반응을 남기거나(같은 걸 다시 누르면 취소, 다른 걸 누르면 바꿈) 서버가 돌려준 종류별 수로 맞춘다
export const toggleLike = (id: number, kind: Reaction) => post(`/feed/${id}/like`, { kind }).then((r) => parse<{ reaction: Reaction | null; counts: Record<Reaction, number> }>(r))
export const postComment = (id: number, body: string) => post(`/feed/${id}/comments`, { body }).then((r) => parse<FeedComment>(r))
export const removeComment = (id: number) => fetch(`${BASE}/feed/comments/${id}`, { method: 'DELETE', headers: authHeaders() }).then((r) => parse<{ ok: boolean }>(r))
export const fetchFeedSummary = () => fetch(`${BASE}/feed/summary`, { headers: authHeaders() }).then((r) => parse<{ newForMe: number }>(r))
export const markFeedSeen = () => post('/feed/seen').then((r) => parse<{ ok: boolean }>(r))
