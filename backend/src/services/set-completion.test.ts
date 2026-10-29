import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { buildCompletion, recordSetCompletion, type CompletionQuest, type CompletionAttempt } from './set-completion.js'

const quests: CompletionQuest[] = [
    { questId: 12, orderIndex: 2, title: '두번째' },
    { questId: 11, orderIndex: 1, title: '첫번째' },
]
const att = (o: Partial<CompletionAttempt> & { questId: number }): CompletionAttempt =>
    ({ passed: false, elapsedSec: null, hintUsed: false, solutionUsed: false, ...o })

describe('buildCompletion', () => {
    it('모든 퀘스트에 통과한 시도가 있으면 order_index 순으로 문제별 내역과 합계를 만든다', () => {
        const c = buildCompletion(quests, [
            att({ questId: 12, passed: true, elapsedSec: 50, hintUsed: true }),
            att({ questId: 11, passed: true, elapsedSec: 30 }),
        ])

        expect(c).toMatchObject({ questCount: 2, totalSeconds: 80, hintFreeCount: 1, solutionFreeCount: 2 })
        expect(c!.detail.map((d) => d.questId)).toEqual([11, 12])
    })

    it('통과한 시도 중 가장 짧은 시간과 그 시도의 힌트·풀이를 쓰고, 시도 횟수는 그 세션의 전체 채점 수다', () => {
        const c = buildCompletion([quests[1]!], [
            att({ questId: 11, passed: false, elapsedSec: 5 }),
            att({ questId: 11, passed: true, elapsedSec: 90, solutionUsed: true }),
            att({ questId: 11, passed: true, elapsedSec: 40, hintUsed: true }),
        ])

        expect(c!.detail[0]).toMatchObject({ seconds: 40, hintUsed: true, solutionUsed: false, attempts: 3 })
    })

    it('통과하지 못한 퀘스트가 하나라도 있으면 완료가 아니다 (null)', () => {
        expect(buildCompletion(quests, [att({ questId: 11, passed: true, elapsedSec: 1 }), att({ questId: 12, passed: false })])).toBeNull()
        expect(buildCompletion(quests, [att({ questId: 11, passed: true, elapsedSec: 1 })])).toBeNull()
    })

    it('퀘스트가 없는 세트는 완료로 보지 않는다', () => {
        expect(buildCompletion([], [])).toBeNull()
    })

    it('시간이 기록되지 않은 통과 기록은 0초로 센다', () => {
        const c = buildCompletion([quests[1]!], [att({ questId: 11, passed: true, elapsedSec: null })])

        expect(c!.totalSeconds).toBe(0)
    })
})

describe('recordSetCompletion', () => {
    beforeEach(() => vi.clearAllMocks())

    it('이 세션(사용자, 세트, 세션 ID)의 채점 기록으로 확인하고, 완료면 문제별 내역과 함께 저장한다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ id: 11, order_index: 1, title: 'q1' }]] as any)
            .mockResolvedValueOnce([[{ quest_id: 11, passed: 1, elapsed_sec: 30, hint_used: 0, solution_used: 0 }]] as any)
            .mockResolvedValueOnce([{}] as any)

        const r = await recordSetCompletion(7, 3, 'sess-1')

        expect(r.recorded).toBe(true)
        expect(vi.mocked(db.query).mock.calls[1]![1]).toEqual([7, 3, 'sess-1'])
        const [insertSql, params] = vi.mocked(db.query).mock.calls[2] as any
        expect(insertSql).toContain('INSERT IGNORE INTO set_completion')
        expect(params.slice(0, 7)).toEqual([7, 3, 'sess-1', 1, 30, 1, 1])
        expect(JSON.parse(params[7])[0]).toMatchObject({ questId: 11, seconds: 30 })
    })

    it('통과하지 못한 퀘스트가 있으면 저장하지 않는다', async () => {
        vi.mocked(db.query)
            .mockResolvedValueOnce([[{ id: 11, order_index: 1, title: 'q1' }, { id: 12, order_index: 2, title: 'q2' }]] as any)
            .mockResolvedValueOnce([[{ quest_id: 11, passed: 1, elapsed_sec: 30, hint_used: 0, solution_used: 0 }]] as any)

        const r = await recordSetCompletion(7, 3, 'sess-1')

        expect(r).toEqual({ recorded: false })
        expect(db.query).toHaveBeenCalledTimes(2)
    })
})
