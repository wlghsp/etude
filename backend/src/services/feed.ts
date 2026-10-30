import { db } from '../db.js'
import { cheersFor, type Cheer, type CompletionRec, type SetInfo } from './feed-cheers.js'

// 활동 피드: 세트 완료 한 건이 소식 한 건이다. 좋아요·댓글·새 반응 알림. docs/specs/spec_activity_feed.md

export const COMMENT_MAX = 300
export const REACTIONS = ['like', 'clap', 'strong', 'fire'] as const // ❤️ 👏 💪 🔥
export type Reaction = typeof REACTIONS[number]
const emptyCounts = (): Record<Reaction, number> => ({ like: 0, clap: 0, strong: 0, fire: 0 })
const COMMENTS_PER_MINUTE = 10
const COMMENTS_PER_EVENT = 50
const PAGE_DEFAULT = 20
const PAGE_MAX = 50

/** 화면에 그대로 보여 줄 수 있는 오류 (status 는 HTTP 상태 코드) */
export class FeedError extends Error {
    constructor(public status: number, message: string) { super(message) }
}

export interface FeedComment {
    id: number
    userId: number
    userName: string
    body: string
    createdAt: string
    canDelete: boolean
}

export interface FeedEvent {
    id: number // set_completion.id
    userId: number
    userName: string
    questSetId: number
    setTitle: string
    category: string
    completedAt: string
    questCount: number
    perfect: boolean // 힌트·풀이 없이 모두
    isFirst: boolean // 그 세트를 처음 끝냄
    isReview: boolean // 이미 끝낸 세트를 다시 끝냄
    cheers: Cheer[] // 이 완료로 처음 이룬 일 (좋은 소식만, 우선순위 순)
    reactions: Record<Reaction, number> // 반응 종류별 수
    myReactions: Reaction[] // 내가 남긴 반응들 (한 사람이 여러 종류를 달 수 있다)
    comments: FeedComment[]
}

const iso = (v: unknown) => new Date(v as string).toISOString()

function toComment(r: any, userId: number, role: string): FeedComment {
    return { id: r.id, userId: r.user_id, userName: r.user_name, body: r.body, createdAt: iso(r.created_at), canDelete: r.user_id === userId || role === 'admin' }
}

export async function getFeed(userId: number, role: string, opts: { before?: number | undefined; limit?: number | undefined }): Promise<FeedEvent[]> {
    const limit = Math.min(Math.max(Math.trunc(opts.limit ?? PAGE_DEFAULT) || PAGE_DEFAULT, 1), PAGE_MAX)
    const params: number[] = []
    let beforeSql = ''
    if (opts.before !== undefined && Number.isInteger(opts.before)) { beforeSql = 'AND c.id < ?'; params.push(opts.before) }
    params.push(limit)

    const [events] = await db.query(`
        SELECT c.id, c.user_id, u.name AS user_name, c.quest_set_id, s.title AS set_title, s.category,
               c.completed_at, c.quest_count, c.hint_free_count, c.solution_free_count,
               (SELECT COUNT(*) FROM set_completion p WHERE p.user_id = c.user_id AND p.quest_set_id = c.quest_set_id AND p.id < c.id) AS earlier
        FROM set_completion c
        JOIN user u ON u.id = c.user_id
        JOIN quest_set s ON s.id = c.quest_set_id
        WHERE u.role = 'member' AND s.is_public = TRUE ${beforeSql}
        ORDER BY c.id DESC
        LIMIT ?`, params) as any[]
    const rows = events as any[]
    if (rows.length === 0) return []

    const ids = rows.map((r) => r.id)
    const [likeRows] = await db.query(
        'SELECT completion_id, kind, COUNT(*) AS n, SUM(user_id = ?) AS mine FROM feed_like WHERE completion_id IN (?) GROUP BY completion_id, kind',
        [userId, ids]) as any[]
    const [commentRows] = await db.query(`
        SELECT cm.id, cm.completion_id, cm.user_id, u.name AS user_name, cm.body, cm.created_at
        FROM feed_comment cm JOIN user u ON u.id = cm.user_id
        WHERE cm.completion_id IN (?) AND cm.deleted_at IS NULL
        ORDER BY cm.id`, [ids]) as any[]

    // 축하: 소식 주인들의 전체 완료 기록으로 그 완료 시점에 처음 이룬 일을 계산한다
    const userIds = [...new Set(rows.map((r) => r.user_id))]
    const [historyRows] = await db.query(`
        SELECT id, user_id, quest_set_id, DATE_FORMAT(completed_at, '%Y-%m-%d') AS day, quest_count, hint_free_count, solution_free_count
        FROM set_completion WHERE user_id IN (?) ORDER BY id`, [userIds]) as any[]
    const [setRows] = await db.query('SELECT id, category, unit_id FROM quest_set WHERE is_public = TRUE') as any[]
    const sets: SetInfo[] = (setRows as any[]).map((s) => ({ id: s.id, category: s.category, unitId: s.unit_id ?? null }))
    const history = new Map<number, CompletionRec[]>()
    for (const h of historyRows as any[]) {
        const list = history.get(h.user_id) ?? []
        list.push({ id: h.id, questSetId: h.quest_set_id, day: h.day, questCount: Number(h.quest_count), hintFree: Number(h.hint_free_count), solutionFree: Number(h.solution_free_count) })
        history.set(h.user_id, list)
    }

    const reactionCounts = new Map<number, Record<Reaction, number>>()
    const myReactions = new Map<number, Reaction[]>()
    for (const l of likeRows as any[]) {
        const kind = l.kind as Reaction
        if (!REACTIONS.includes(kind)) continue
        const counts = reactionCounts.get(l.completion_id) ?? emptyCounts()
        counts[kind] = Number(l.n)
        reactionCounts.set(l.completion_id, counts)
        if (Number(l.mine) > 0) myReactions.set(l.completion_id, [...(myReactions.get(l.completion_id) ?? []), kind])
    }
    const comments = new Map<number, FeedComment[]>()
    for (const c of commentRows as any[]) {
        const list = comments.get(c.completion_id) ?? []
        if (list.length < COMMENTS_PER_EVENT) list.push(toComment(c, userId, role))
        comments.set(c.completion_id, list)
    }

    return rows.map((r) => {
        const earlier = Number(r.earlier)
        return {
            id: r.id,
            userId: r.user_id,
            userName: r.user_name,
            questSetId: r.quest_set_id,
            setTitle: r.set_title,
            category: r.category,
            completedAt: iso(r.completed_at),
            questCount: Number(r.quest_count),
            perfect: Number(r.quest_count) > 0 && Number(r.hint_free_count) === Number(r.quest_count) && Number(r.solution_free_count) === Number(r.quest_count),
            isFirst: earlier === 0,
            isReview: earlier > 0,
            reactions: reactionCounts.get(r.id) ?? emptyCounts(),
            myReactions: sortReactions(myReactions.get(r.id) ?? []),
            comments: comments.get(r.id) ?? [],
            cheers: cheersFor(history.get(r.user_id) ?? [], sets, r.id),
        }
    })
}

async function ownerOf(completionId: number): Promise<number> {
    const [rows] = await db.query('SELECT user_id FROM set_completion WHERE id = ?', [completionId]) as any[]
    if (!(rows as any[]).length) throw new FeedError(404, '소식을 찾을 수 없어요.')
    return (rows as any[])[0].user_id
}

// 화면에 늘 같은 순서(like, clap, strong, fire)로 보이게 한다
const sortReactions = (list: Reaction[]) => REACTIONS.filter((k) => list.includes(k))

/** 반응 하나를 켜거나 끈다 (한 사람이 여러 종류를 달 수 있고, 같은 걸 다시 누르면 그 반응만 취소된다). 내 소식에는 남길 수 없다. */
export async function toggleLike(userId: number, completionId: number, kind: Reaction = 'like'): Promise<{ mine: Reaction[]; counts: Record<Reaction, number> }> {
    if (!REACTIONS.includes(kind)) throw new FeedError(400, '알 수 없는 반응이에요.')
    if (await ownerOf(completionId) === userId) throw new FeedError(400, '내 소식에는 반응을 남길 수 없어요.')
    const [existing] = await db.query('SELECT kind FROM feed_like WHERE completion_id = ? AND user_id = ? AND kind = ?', [completionId, userId, kind]) as any[]
    if ((existing as any[]).length === 0) await db.query('INSERT IGNORE INTO feed_like (completion_id, user_id, kind) VALUES (?, ?, ?)', [completionId, userId, kind])
    else await db.query('DELETE FROM feed_like WHERE completion_id = ? AND user_id = ? AND kind = ?', [completionId, userId, kind])
    const [rows] = await db.query('SELECT kind, COUNT(*) AS n, SUM(user_id = ?) AS mine FROM feed_like WHERE completion_id = ? GROUP BY kind', [userId, completionId]) as any[]
    const counts = emptyCounts()
    const mine: Reaction[] = []
    for (const r of rows as any[]) {
        if (!REACTIONS.includes(r.kind)) continue
        counts[r.kind as Reaction] = Number(r.n)
        if (Number(r.mine) > 0) mine.push(r.kind)
    }
    return { mine: sortReactions(mine), counts }
}

export async function addComment(userId: number, completionId: number, body: unknown): Promise<FeedComment> {
    const text = typeof body === 'string' ? body.trim() : ''
    if (text.length === 0) throw new FeedError(400, '댓글 내용을 입력해 주세요.')
    if (text.length > COMMENT_MAX) throw new FeedError(400, `댓글은 ${COMMENT_MAX}자까지 쓸 수 있어요.`)
    await ownerOf(completionId)

    const [recent] = await db.query('SELECT COUNT(*) AS n FROM feed_comment WHERE user_id = ? AND created_at >= (NOW() - INTERVAL 1 MINUTE)', [userId]) as any[]
    if (Number((recent as any[])[0].n) >= COMMENTS_PER_MINUTE) throw new FeedError(429, '댓글을 너무 빨리 쓰고 있어요. 잠시 후 다시 써 주세요.')

    const [result] = await db.query('INSERT INTO feed_comment (completion_id, user_id, body) VALUES (?, ?, ?)', [completionId, userId, text]) as any[]
    const [rows] = await db.query(
        'SELECT cm.id, cm.user_id, u.name AS user_name, cm.body, cm.created_at FROM feed_comment cm JOIN user u ON u.id = cm.user_id WHERE cm.id = ?',
        [(result as any).insertId]) as any[]
    return toComment((rows as any[])[0], userId, 'member')
}

/** 쓴 사람과 관리자만 지울 수 있다. 지우기는 숨기기(deleted_at)다. */
export async function deleteComment(userId: number, role: string, commentId: number): Promise<void> {
    const [rows] = await db.query('SELECT user_id FROM feed_comment WHERE id = ? AND deleted_at IS NULL', [commentId]) as any[]
    if (!(rows as any[]).length) throw new FeedError(404, '댓글을 찾을 수 없어요.')
    if ((rows as any[])[0].user_id !== userId && role !== 'admin') throw new FeedError(403, '내가 쓴 댓글만 지울 수 있어요.')
    await db.query('UPDATE feed_comment SET deleted_at = NOW() WHERE id = ?', [commentId])
}

/** 내 소식에 다른 사람이 남긴 좋아요·댓글 중 마지막으로 소식 탭을 연 뒤의 것 */
export async function getFeedSummary(userId: number): Promise<{ newForMe: number }> {
    const [seen] = await db.query('SELECT seen_at FROM feed_seen WHERE user_id = ?', [userId]) as any[]
    const since = (seen as any[])[0]?.seen_at ?? new Date(0)
    const [rows] = await db.query(`
        SELECT
          (SELECT COUNT(*) FROM feed_like l JOIN set_completion c ON c.id = l.completion_id
            WHERE c.user_id = ? AND l.user_id <> ? AND l.created_at > ?) +
          (SELECT COUNT(*) FROM feed_comment m JOIN set_completion c ON c.id = m.completion_id
            WHERE c.user_id = ? AND m.user_id <> ? AND m.deleted_at IS NULL AND m.created_at > ?) AS n`,
        [userId, userId, since, userId, userId, since]) as any[]
    return { newForMe: Number((rows as any[])[0].n) }
}

export async function markFeedSeen(userId: number): Promise<void> {
    await db.query('INSERT INTO feed_seen (user_id, seen_at) VALUES (?, NOW()) ON DUPLICATE KEY UPDATE seen_at = NOW()', [userId])
}
