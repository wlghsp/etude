import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { FeedError, addComment, deleteComment, getFeed, getFeedSummary, markFeedSeen, toggleLike } from './feed.js'

const q = vi.mocked(db.query)
const ok = { affectedRows: 1, insertId: 0 }
const catchErr = async (p: Promise<unknown>) => { try { await p; return null } catch (e) { return e as FeedError } }

describe('toggleLike (반응)', () => {
    beforeEach(() => vi.clearAllMocks())

    it('없는 소식이면 404', async () => {
        q.mockResolvedValueOnce([[]] as any)

        const e = await catchErr(toggleLike(7, 99, 'like'))

        expect(e).toBeInstanceOf(FeedError)
        expect(e!.status).toBe(404)
    })

    it('내 소식에는 반응을 누를 수 없다 (400)', async () => {
        q.mockResolvedValueOnce([[{ user_id: 7 }]] as any)

        const e = await catchErr(toggleLike(7, 5, 'like'))

        expect(e!.status).toBe(400)
        expect(q).toHaveBeenCalledTimes(1)
    })

    it('정해진 반응(like, clap, strong, fire)이 아니면 400 이고 조회하지도 않는다', async () => {
        const e = await catchErr(toggleLike(7, 5, 'angry' as any))

        expect(e!.status).toBe(400)
        expect(q).not.toHaveBeenCalled()
    })

    it('아직 안 눌렀으면 그 반응을 켜고, 내가 단 반응 목록과 종류별 수를 돌려준다', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any) // 소식 주인
            .mockResolvedValueOnce([[]] as any)               // 이 반응은 아직 없음
            .mockResolvedValueOnce([ok] as any)               // INSERT
            .mockResolvedValueOnce([[{ kind: 'clap', n: 2, mine: 1 }, { kind: 'like', n: 1, mine: 1 }]] as any)

        expect(await toggleLike(7, 5, 'clap')).toEqual({ mine: ['like', 'clap'], counts: { like: 1, clap: 2, strong: 0, fire: 0 } })
        expect(String(q.mock.calls[1]![0])).toContain('kind = ?')
        expect(String(q.mock.calls[2]![0])).toContain('INSERT')
    })

    it('같은 반응을 다시 누르면 그 반응만 끈다 (다른 반응은 그대로)', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any)
            .mockResolvedValueOnce([[{ kind: 'clap' }]] as any)
            .mockResolvedValueOnce([ok] as any)
            .mockResolvedValueOnce([[{ kind: 'like', n: 1, mine: 1 }]] as any)

        expect(await toggleLike(7, 5, 'clap')).toEqual({ mine: ['like'], counts: { like: 1, clap: 0, strong: 0, fire: 0 } })
        const del = String(q.mock.calls[2]![0])
        expect(del).toContain('DELETE')
        expect(del).toContain('kind = ?')
    })

    it('다른 반응을 누르면 기존 반응을 지우지 않고 추가한다', async () => {
        q.mockResolvedValueOnce([[{ user_id: 8 }]] as any)
            .mockResolvedValueOnce([[]] as any)
            .mockResolvedValueOnce([ok] as any)
            .mockResolvedValueOnce([[{ kind: 'like', n: 1, mine: 1 }, { kind: 'fire', n: 1, mine: 1 }]] as any)

        expect((await toggleLike(7, 5, 'fire')).mine).toEqual(['like', 'fire'])
        expect(String(q.mock.calls[2]![0])).toContain('INSERT')
        expect(q.mock.calls.some((c) => String(c[0]).includes('UPDATE'))).toBe(false)
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
            .mockResolvedValueOnce([[{ completion_id: 10, kind: 'like', n: 1, mine: 0 }, { completion_id: 10, kind: 'clap', n: 1, mine: 1 }]] as any)
            .mockResolvedValueOnce([[
                { id: 1, completion_id: 10, user_id: 7, user_name: '나', body: '굿', created_at: new Date('2026-10-30T02:00:00Z') },
                { id: 2, completion_id: 10, user_id: 8, user_name: '다', body: '고마워요', created_at: new Date('2026-10-30T03:00:00Z') },
            ]] as any)
            .mockResolvedValueOnce([[{ id: 10, user_id: 8, quest_set_id: 3, day: '2026-10-30', quest_count: 4, hint_free_count: 4, solution_free_count: 4 }]] as any) // 완료 기록
            .mockResolvedValueOnce([[{ id: 3, category: '리눅스', unit_id: 1 }, { id: 4, category: '리눅스', unit_id: 1 }]] as any) // 세트

        const feed = await getFeed(7, 'member', {})

        expect(feed[0]).toMatchObject({ id: 10, userName: '다', perfect: true, isFirst: true, isReview: false, reactions: { like: 1, clap: 1, strong: 0, fire: 0 }, myReactions: ['clap'] })
        expect(feed[0]!.comments.map((c) => [c.userName, c.canDelete])).toEqual([['나', true], ['다', false]]) // 내 댓글만 지울 수 있다
        expect(feed[0]!.cheers.map((c) => c.text)).toContain("'첫 걸음' 배지를 얻었어요") // 첫 세트 완료 축하
        expect(feed[1]).toMatchObject({ id: 9, perfect: false, isFirst: false, isReview: true, reactions: { like: 0, clap: 0, strong: 0, fire: 0 }, myReactions: [], comments: [] })
    })

    it('관리자는 모든 댓글을 지울 수 있다', async () => {
        q.mockResolvedValueOnce([[ev({})]] as any)
            .mockResolvedValueOnce([[]] as any)
            .mockResolvedValueOnce([[{ id: 2, completion_id: 10, user_id: 8, user_name: '다', body: 'x', created_at: new Date() }]] as any)
            .mockResolvedValueOnce([[{ id: 10, user_id: 8, quest_set_id: 3, day: '2026-10-30', quest_count: 4, hint_free_count: 4, solution_free_count: 4 }]] as any) // 완료 기록
            .mockResolvedValueOnce([[{ id: 3, category: '리눅스', unit_id: 1 }, { id: 4, category: '리눅스', unit_id: 1 }]] as any) // 세트

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
