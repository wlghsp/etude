import { db } from '../db.js'

// 활동 피드: 세트 완료 한 건이 소식 한 건이다. 좋아요·댓글·새 반응 알림. docs/specs/spec_activity_feed.md

export const COMMENT_MAX = 300
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
    likes: number
    likedByMe: boolean
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
        'SELECT completion_id, COUNT(*) AS n, SUM(user_id = ?) AS mine FROM feed_like WHERE completion_id IN (?) GROUP BY completion_id',
        [userId, ids]) as any[]
    const [commentRows] = await db.query(`
        SELECT cm.id, cm.completion_id, cm.user_id, u.name AS user_name, cm.body, cm.created_at
        FROM feed_comment cm JOIN user u ON u.id = cm.user_id
        WHERE cm.completion_id IN (?) AND cm.deleted_at IS NULL
        ORDER BY cm.id`, [ids]) as any[]

    const likes = new Map((likeRows as any[]).map((l) => [l.completion_id, l]))
    const comments = new Map<number, FeedComment[]>()
    for (const c of commentRows as any[]) {
        const list = comments.get(c.completion_id) ?? []
        if (list.length < COMMENTS_PER_EVENT) list.push(toComment(c, userId, role))
        comments.set(c.completion_id, list)
    }

    return rows.map((r) => {
        const like = likes.get(r.id)
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
            likes: like ? Number(like.n) : 0,
            likedByMe: like ? Number(like.mine) > 0 : false,
            comments: comments.get(r.id) ?? [],
        }
    })
}

async function ownerOf(completionId: number): Promise<number> {
    const [rows] = await db.query('SELECT user_id FROM set_completion WHERE id = ?', [completionId]) as any[]
    if (!(rows as any[]).length) throw new FeedError(404, '소식을 찾을 수 없어요.')
    return (rows as any[])[0].user_id
}

/** 좋아요를 켜거나 끈다. 내 소식에는 누를 수 없다. */
export async function toggleLike(userId: number, completionId: number): Promise<{ liked: boolean; likes: number }> {
    if (await ownerOf(completionId) === userId) throw new FeedError(400, '내 소식에는 좋아요를 누를 수 없어요.')
    const [existing] = await db.query('SELECT 1 AS x FROM feed_like WHERE completion_id = ? AND user_id = ?', [completionId, userId]) as any[]
    const liked = (existing as any[]).length === 0
    if (liked) await db.query('INSERT IGNORE INTO feed_like (completion_id, user_id) VALUES (?, ?)', [completionId, userId])
    else await db.query('DELETE FROM feed_like WHERE completion_id = ? AND user_id = ?', [completionId, userId])
    const [count] = await db.query('SELECT COUNT(*) AS n FROM feed_like WHERE completion_id = ?', [completionId]) as any[]
    return { liked, likes: Number((count as any[])[0].n) }
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
