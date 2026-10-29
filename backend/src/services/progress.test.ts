import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { getSetProgress, getLeaderboard } from './progress.js'

describe('getSetProgress', () => {
    beforeEach(() => vi.clearAllMocks())

    it('볼 수 있는 세트 규칙(공개/관리자/접근 권한)으로 세트를 조회하고, 세트별 완료 기록을 최근 순으로 붙인다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ id: 1, title: 'A', category: '리눅스' }, { id: 2, title: 'B', category: 'k8s' }]] as any)
            .mockResolvedValueOnce([[
                { id: 9, quest_set_id: 1, completed_at: '2026-10-29 10:00:00', total_seconds: 120, quest_count: 3, hint_free_count: 2, solution_free_count: 3, detail: '[{"questId":1,"orderIndex":1,"title":"q","seconds":40,"hintUsed":false,"solutionUsed":false,"attempts":1}]' },
                { id: 8, quest_set_id: 1, completed_at: '2026-10-28 10:00:00', total_seconds: 200, quest_count: 3, hint_free_count: 0, solution_free_count: 3, detail: null },
            ]] as any)

        const r = await getSetProgress(7, 'member')

        const [setSql, setParams] = vi.mocked(db.query).mock.calls[0] as any
        expect(setSql).toContain('is_public = TRUE')
        expect(setSql).toContain('quest_set_access')
        expect(setParams).toEqual(['member', 7])
        expect(vi.mocked(db.query).mock.calls[1]![1]).toEqual([7])
        expect(r[0]!.completions.map((c) => c.id)).toEqual([9, 8])
        expect(r[0]!.completions[0]!.detail![0]).toMatchObject({ questId: 1, seconds: 40 })
        expect(r[0]!.completions[1]!.detail).toBeNull()
        expect(r[1]!.completions).toEqual([])
    })

    it('문제별 내역 JSON 이 깨져 있어도 목록은 돌려준다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ id: 1, title: 'A', category: '리눅스' }]] as any)
            .mockResolvedValueOnce([[{ id: 1, quest_set_id: 1, completed_at: '2026-10-29 10:00:00', total_seconds: 1, quest_count: 1, hint_free_count: 1, solution_free_count: 1, detail: '{깨짐' }]] as any)

        const r = await getSetProgress(7, 'member')

        expect(r[0]!.completions[0]!.detail).toBeNull()
    })
})

describe('getLeaderboard', () => {
    beforeEach(() => vi.clearAllMocks())

    it('완료한 세트 수로 순위를 매기고, 같은 세트를 여러 번 완료해도 한 번으로 센다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ id: 1, title: 'A', category: '리눅스' }, { id: 2, title: 'B', category: 'k8s' }, { id: 3, title: 'C', category: 'k8s' }]] as any)
            .mockResolvedValueOnce([[{ id: 10, name: '나' }, { id: 11, name: '가' }, { id: 12, name: '다' }]] as any)
            .mockResolvedValueOnce([[
                { user_id: 11, quest_set_id: 1 }, { user_id: 11, quest_set_id: 2 },
                { user_id: 12, quest_set_id: 1 },
            ]] as any)

        const r = await getLeaderboard()

        expect(r.map((u) => [u.userName, u.completed, u.total])).toEqual([['가', 2, 3], ['다', 1, 3], ['나', 0, 3]])
        expect(r[0]!.sets.map((s) => s.completed)).toEqual([1, 1, 0])
    })
})
