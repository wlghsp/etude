import { describe, it, expect } from 'vitest'
import { runSet } from './run-set.js'
import type { SandboxFactory, VerifyQuest } from './verify-quest.js'

const q = (orderIndex: number): VerifyQuest => ({ orderIndex, title: `q${orderIndex}`, setupCmd: null, gradeCmd: ['grade', String(orderIndex)] })

// grade는 정답 컨테이너(홀수 번째 생성)에서만 통과, 무행동 컨테이너에서는 실패
function goodFactory(): SandboxFactory {
    let n = 0
    return async () => {
        const id = ++n
        return { exec: async (cmd) => (cmd[0] === 'grade' ? (id % 2 === 1 ? 0 : 1) : 0), dispose: async () => {} }
    }
}

describe('runSet', () => {
    it('fixture가 있는 퀘스트는 검증하고, 없는 퀘스트는 no-fixture로 실패시킨다', async () => {
        const results = await runSet([q(1), q(2)], { setId: 1, answers: { '1': 'a' } }, goodFactory())

        expect(results.find((r) => r.orderIndex === 1)).toMatchObject({ ok: true })
        expect(results.find((r) => r.orderIndex === 2)).toMatchObject({ ok: false, reason: 'no-fixture' })
    })

    it('퀘스트가 없는 fixture는 orphan-fixture로 실패시킨다', async () => {
        const results = await runSet([q(1)], { setId: 1, answers: { '1': 'a', '9': 'z' } }, goodFactory())

        expect(results.find((r) => r.orderIndex === 9)).toMatchObject({ ok: false, reason: 'orphan-fixture' })
    })

    it('결과는 order_index 순서로 돌려준다', async () => {
        const results = await runSet([q(2), q(1)], { setId: 1, answers: { '1': 'a', '2': 'b' } }, goodFactory())

        expect(results.map((r) => r.orderIndex)).toEqual([1, 2])
    })
})
