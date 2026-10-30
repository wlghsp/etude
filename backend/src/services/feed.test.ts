import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { FeedError, addComment, deleteComment, getFeed, getFeedSummary, markFeedSeen, toggleLike } from './feed.js'

const q = vi.mocked(db.query)
const ok = { affectedRows: 1, insertId: 0 }
const catchErr = async (p: Promise<unknown>) => { try { await p; return null } catch (e) { return e as FeedError } }

describe('toggleLike', () => {
    beforeEach(() => vi.clearAllMocks())

    it('없는 소식이면 404', async () => {
        q.mockResolvedValueOnce([[]] as any)

        const e = await catchErr(toggleLike(7, 99))

        expect(e).toBeInstanceOf(FeedError)
        expect(e!.status).toBe(404)
    })

    it('내 소식에는 좋아요를 누를 수 없다 (400)', async () => {
        q.mockResolvedValueOnce([[{ user_id: 7 }]] as any)

        const e = await catchErr(toggleLike(7, 5))

        expect(e!.status).toBe(400)
        expect(q).toHaveBeenCalledTimes(1)
    })

    it('아직 안 눌렀으면 좋아요를 켜고 수를 돌려준다', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any) // 소식 주인
            .mockResolvedValueOnce([[]] as any)               // 기존 좋아요 없음
            .mockResolvedValueOnce([ok] as any)               // INSERT
            .mockResolvedValueOnce([[{ n: 3 }]] as any)       // 개수

        expect(await toggleLike(7, 5)).toEqual({ liked: true, likes: 3 })
        expect(String(q.mock.calls[2]![0])).toContain('INSERT')
    })

    it('이미 눌렀으면 취소한다', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any)
            .mockResolvedValueOnce([[{ x: 1 }]] as any)
            .mockResolvedValueOnce([ok] as any)
            .mockResolvedValueOnce([[{ n: 1 }]] as any)

        expect(await toggleLike(7, 5)).toEqual({ liked: false, likes: 1 })
        expect(String(q.mock.calls[2]![0])).toContain('DELETE')
    })
})

describe('addComment', () => {
    beforeEach(() => vi.clearAllMocks())

    it('빈 댓글과 300자를 넘는 댓글은 400 이고 조회하지도 않는다', async () => {
        for (const body of ['', '   ', 'a'.repeat(301), undefined, 123]) {
            const e = await catchErr(addComment(7, 5, body as any))
            expect(e!.status, String(body)).toBe(400)
        }
        expect(q).not.toHaveBeenCalled()
    })

    it('없는 소식이면 404', async () => {
        q.mockResolvedValueOnce([[]] as any)

        expect((await catchErr(addComment(7, 5, '안녕')))!.status).toBe(404)
    })

    it('1분에 10개를 넘으면 429', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any).mockResolvedValueOnce([[{ n: 10 }]] as any)

        expect((await catchErr(addComment(7, 5, '안녕')))!.status).toBe(429)
    })

    it('앞뒤 공백을 지우고 저장한 뒤 만든 댓글을 돌려준다', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any)
            .mockResolvedValueOnce([[{ n: 0 }]] as any)
            .mockResolvedValueOnce([{ insertId: 42 }] as any)
            .mockResolvedValueOnce([[{ id: 42, user_id: 7, user_name: '나', body: '축하해요', created_at: new Date('2026-10-30T01:00:00Z') }]] as any)

        const c = await addComment(7, 5, '  축하해요  ')

        expect(q.mock.calls[2]![1]).toEqual([5, 7, '축하해요'])
        expect(c).toMatchObject({ id: 42, userId: 7, userName: '나', body: '축하해요', canDelete: true })
    })
})

describe('deleteComment', () => {
    beforeEach(() => vi.clearAllMocks())

    it('없는 댓글이면 404', async () => {
        q.mockResolvedValueOnce([[]] as any)

        expect((await catchErr(deleteComment(7, 'member', 3)))!.status).toBe(404)
    })

    it('남의 댓글은 일반 회원이 지울 수 없다 (403)', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any)

        expect((await catchErr(deleteComment(7, 'member', 3)))!.status).toBe(403)
        expect(q).toHaveBeenCalledTimes(1)
    })

    it('쓴 사람과 관리자는 지울 수 있고, 지우기는 숨기기(deleted_at)다', async () => {
        q.mockResolvedValue([[{ user_id: 8 }]] as any)

        await deleteComment(8, 'member', 3)
        await deleteComment(1, 'admin', 3)

        const updates = q.mock.calls.map((c) => String(c[0])).filter((s) => s.includes('UPDATE'))
        expect(updates).toHaveLength(2)
        expect(updates[0]).toContain('deleted_at')
    })
})

describe('getFeed', () => {
    beforeEach(() => vi.clearAllMocks())

    const ev = (o: object) => ({ id: 10, user_id: 8, user_name: '다', quest_set_id: 3, set_title: '세트', category: '리눅스', completed_at: new Date('2026-10-30T01:00:00Z'), quest_count: 4, hint_free_count: 4, solution_free_count: 4, earlier: 0, ...o })

    it('소식이 없으면 빈 목록이고 더 조회하지 않는다', async () => {
        q.mockResolvedValueOnce([[]] as any)

        expect(await getFeed(7, 'member', {})).toEqual([])
        expect(q).toHaveBeenCalledTimes(1)
    })

    it('회원의 공개 세트 완료만, 최신순으로 조회하고 before 와 limit 을 쓴다', async () => {
        q.mockResolvedValueOnce([[]] as any)

        await getFeed(7, 'member', { before: 50, limit: 5 })

        const [sql, params] = q.mock.calls[0] as any
        expect(sql).toContain("role = 'member'")
        expect(sql).toContain('is_public = TRUE')
        expect(sql).toContain('ORDER BY c.id DESC')
        expect(params).toEqual([50, 5])
    })

    it('퍼펙트·첫 완료·복습 표시와 좋아요·댓글을 소식에 붙인다', async () => {
        q.mockResolvedValueOnce([[ev({}), ev({ id: 9, user_id: 7, user_name: '나', hint_free_count: 2, earlier: 2 })]] as any)
            .mockResolvedValueOnce([[{ completion_id: 10, n: 2, mine: 1 }]] as any)
            .mockResolvedValueOnce([[
                { id: 1, completion_id: 10, user_id: 7, user_name: '나', body: '굿', created_at: new Date('2026-10-30T02:00:00Z') },
                { id: 2, completion_id: 10, user_id: 8, user_name: '다', body: '고마워요', created_at: new Date('2026-10-30T03:00:00Z') },
            ]] as any)

        const feed = await getFeed(7, 'member', {})

        expect(feed[0]).toMatchObject({ id: 10, userName: '다', perfect: true, isFirst: true, isReview: false, likes: 2, likedByMe: true })
        expect(feed[0]!.comments.map((c) => [c.userName, c.canDelete])).toEqual([['나', true], ['다', false]]) // 내 댓글만 지울 수 있다
        expect(feed[1]).toMatchObject({ id: 9, perfect: false, isFirst: false, isReview: true, likes: 0, likedByMe: false, comments: [] })
    })

    it('관리자는 모든 댓글을 지울 수 있다', async () => {
        q.mockResolvedValueOnce([[ev({})]] as any)
            .mockResolvedValueOnce([[]] as any)
            .mockResolvedValueOnce([[{ id: 2, completion_id: 10, user_id: 8, user_name: '다', body: 'x', created_at: new Date() }]] as any)

        const feed = await getFeed(1, 'admin', {})

        expect(feed[0]!.comments[0]!.canDelete).toBe(true)
    })
})

describe('알림', () => {
    beforeEach(() => vi.clearAllMocks())

    it('마지막으로 본 뒤의 다른 사람의 좋아요·댓글 수를 센다', async () => {
        q.mockResolvedValueOnce([[{ seen_at: new Date('2026-10-30T00:00:00Z') }]] as any).mockResolvedValueOnce([[{ n: 4 }]] as any)

        expect(await getFeedSummary(7)).toEqual({ newForMe: 4 })
        expect(String(q.mock.calls[1]![0])).toContain('<>')
    })

    it('처음이면 지금까지의 반응을 센다', async () => {
        q.mockResolvedValueOnce([[]] as any).mockResolvedValueOnce([[{ n: 0 }]] as any)

        expect(await getFeedSummary(7)).toEqual({ newForMe: 0 })
    })

    it('읽음 처리는 현재 시각으로 저장한다', async () => {
        q.mockResolvedValueOnce([ok] as any)

        await markFeedSeen(7)

        expect(String(q.mock.calls[0]![0])).toContain('ON DUPLICATE KEY UPDATE')
        expect(q.mock.calls[0]![1]).toEqual([7])
    })
})
