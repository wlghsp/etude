import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { visibleSet, publicSet } from './visibility.js'
import { canAccessQuestSet } from './quest.js'

describe('visibleSet (대분류 가시 AND 세트 가시)', () => {
    it('세트 조건과 대분류 조건을 모두 AND 로 묶고 파라미터는 role,userId,role,userId 순서다', () => {
        const v = visibleSet('qs', 7, 'member')
        expect(v.params).toEqual(['member', 7, 'member', 7])
        expect(v.sql).toContain('qs.is_public = TRUE')
        expect(v.sql).toContain('quest_set_access')
        expect(v.sql).toContain('category_setting')
        expect(v.sql).toContain('category_access')
        expect(v.sql).toMatch(/\)\s+AND\s+\(/)
    })

    it('대분류 설정 행이 없으면 공개로 본다 (비공개 행이 있을 때만 막는다)', () => {
        expect(visibleSet('qs', 1, 'member').sql).toContain('cs.is_public = FALSE')
    })

    it('별칭을 바꿔도 컬럼에 반영된다', () => {
        expect(visibleSet('s', 1, 'member').sql).toContain('s.category')
    })
})

describe('publicSet (소식·배지처럼 사용자 무관 집계)', () => {
    it('세트 공개이고 대분류 비공개 행이 없을 때만 통과한다', () => {
        const sql = publicSet('s')
        expect(sql).toContain('s.is_public = TRUE')
        expect(sql).toContain('cs.is_public = FALSE')
    })
})

describe('canAccessQuestSet', () => {
    beforeEach(() => vi.clearAllMocks())
    it('가시성 조각을 쓰고 행이 있으면 허용한다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ 1: 1 }]] as any)
        expect(await canAccessQuestSet(7, 'member', 5)).toBe(true)
        const [sql, params] = vi.mocked(db.query).mock.calls[0] as any[]
        expect(sql).toContain('category_setting')
        expect(params).toEqual([5, 'member', 7, 'member', 7])
    })
})
