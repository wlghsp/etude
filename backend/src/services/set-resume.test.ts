import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { findResumableRun, RESUME_RETENTION_DAYS } from './set-resume.js'

const q = vi.mocked(db.query)
const none = { sessionId: null, passed: [] }

// docs/specs/spec_resume_set.md — 이어 풀 세션의 조건
describe('findResumableRun', () => {
    beforeEach(() => vi.clearAllMocks())

    it('시험형(시간 제한) 세트는 이어 풀 수 없다', async () => {
        q.mockResolvedValueOnce([[{ sandbox_type: 'docker', time_limit_sec: 600 }]] as any)

        expect(await findResumableRun(7, 3)).toEqual(none)
        expect(q).toHaveBeenCalledTimes(1)
    })

    it('docker-persistent 세트는 이어 풀 수 없다 (앞 문제의 컨테이너 상태가 전제라서)', async () => {
        q.mockResolvedValueOnce([[{ sandbox_type: 'docker-persistent', time_limit_sec: null }]] as any)

        expect(await findResumableRun(7, 3)).toEqual(none)
        expect(q).toHaveBeenCalledTimes(1)
    })

    it('없는 세트는 이어 풀 수 없다', async () => {
        q.mockResolvedValueOnce([[]] as any)

        expect(await findResumableRun(7, 999)).toEqual(none)
    })

    it('조건에 맞는 세션이 없으면 null 을 돌려준다', async () => {
        q.mockResolvedValueOnce([[{ sandbox_type: 'quiz', time_limit_sec: null }]] as any)
            .mockResolvedValueOnce([[]] as any)

        expect(await findResumableRun(7, 3)).toEqual(none)
        expect(q).toHaveBeenCalledTimes(2)
    })

    it('세션 조회는 본인 기록만, 완료하지 않은 세션만, 통과가 있는 세션만, 보관 기간 안의 것만 본다', async () => {
        q.mockResolvedValueOnce([[{ sandbox_type: 'quiz', time_limit_sec: null }]] as any)
            .mockResolvedValueOnce([[]] as any)

        await findResumableRun(7, 3)

        const [sql, params] = q.mock.calls[1]!
        const text = String(sql).replace(/\s+/g, ' ')
        expect(text).toMatch(/FROM quest_attempt/)
        expect(text).toMatch(/user_id = \?/)
        expect(text).toMatch(/quest_set_id = \?/)
        expect(text).toMatch(/NOT EXISTS \(SELECT 1 FROM set_completion/)
        expect(text).toMatch(/HAVING SUM\(.*passed.*\) > 0/)
        expect(text).toMatch(/MAX\(.*attempted_at.*\) >= NOW\(\) - INTERVAL \? DAY/)
        expect(text).toMatch(/ORDER BY MAX\(.*attempted_at.*\) DESC LIMIT 1/)
        expect(params).toEqual([7, 3, RESUME_RETENTION_DAYS])
    })

    it('찾은 세션의 통과 문제를 문제 순서대로, 완료 요약과 같은 규칙으로 돌려준다', async () => {
        q.mockResolvedValueOnce([[{ sandbox_type: 'linux', time_limit_sec: null }]] as any)
            .mockResolvedValueOnce([[{ session_id: 's-open' }]] as any)
            .mockResolvedValueOnce([[
                // 41: 두 번 시도해 두 번째에 통과 (시간이 있는 통과 시도가 기록의 기준, 시도 수는 전체)
                { quest_id: 41, passed: 0, elapsed_sec: 30, hint_used: 1, solution_used: 0 },
                { quest_id: 41, passed: 1, elapsed_sec: 50, hint_used: 0, solution_used: 0 },
                // 42: 통과 시도가 둘이면 가장 짧은 시간
                { quest_id: 42, passed: 1, elapsed_sec: 90, hint_used: 1, solution_used: 1 },
                { quest_id: 42, passed: 1, elapsed_sec: 20, hint_used: 0, solution_used: 0 },
                // 43: 통과하지 못한 문제는 담지 않는다
                { quest_id: 43, passed: 0, elapsed_sec: 10, hint_used: 0, solution_used: 0 },
                // 45: 시간 기록이 없는 통과
                { quest_id: 45, passed: 1, elapsed_sec: null, hint_used: 0, solution_used: 1 },
            ]] as any)

        expect(await findResumableRun(7, 3)).toEqual({
            sessionId: 's-open',
            passed: [
                { questId: 41, seconds: 50, hintUsed: false, solutionUsed: false, attempts: 2 },
                { questId: 42, seconds: 20, hintUsed: false, solutionUsed: false, attempts: 2 },
                { questId: 45, seconds: 0, hintUsed: false, solutionUsed: true, attempts: 1 },
            ],
        })

        const [sql, params] = q.mock.calls[2]!
        const text = String(sql).replace(/\s+/g, ' ')
        expect(text).toMatch(/FROM quest_attempt/)
        expect(text).toMatch(/user_id = \? AND .*quest_set_id = \? AND .*session_id = \?/)
        expect(text).toMatch(/ORDER BY q\.order_index/)
        expect(params).toEqual([7, 3, 's-open'])
    })

    it('보관 기간은 30일이다', () => {
        expect(RESUME_RETENTION_DAYS).toBe(30)
    })
})
