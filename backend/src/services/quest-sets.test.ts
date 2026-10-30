import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { getQuestSets } from './quest.js'

describe('getQuestSets', () => {
    beforeEach(() => vi.clearAllMocks())

    it('세트마다 문제 수(quest_count)를 숫자로 돌려준다 (화면의 "첫 완료 시 +N XP" 계산용)', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ id: 1, title: 'a', is_review: 0, quest_count: '12' }]] as any)

        const [s] = await getQuestSets(7, 'member')

        expect(s).toMatchObject({ id: 1, is_review: false, quest_count: 12, first_xp: 120 }) // 처음 끝내면 문제당 10 XP
        expect(String(vi.mocked(db.query).mock.calls[0]![0])).toContain('quest_count')
    })
})
