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

// 무행동 통과를 알려진 예외로 허용하는 fixture 케이스
describe('runSet — allowTriviallyPasses', () => {
    // grade가 항상 통과 → 정답은 통과하지만 무행동도 통과(trivially-passes)
    const alwaysPass: SandboxFactory = async () => ({ exec: async () => 0, dispose: async () => {} })

    it('이유가 적힌 예외는 무행동 통과를 허용하고 이유를 note로 남긴다', async () => {
        const results = await runSet([q(1)], { setId: 1, answers: { '1': 'a' }, allowTriviallyPasses: { '1': '정답 상태가 초기 상태와 같다' } }, alwaysPass)

        expect(results[0]).toMatchObject({ ok: true, note: '정답 상태가 초기 상태와 같다' })
    })

    it('예외가 없으면 같은 상황이 trivially-passes 실패다', async () => {
        const results = await runSet([q(1)], { setId: 1, answers: { '1': 'a' } }, alwaysPass)

        expect(results[0]).toMatchObject({ ok: false, reason: 'trivially-passes' })
    })

    it('예외가 있는데 이제 무행동이 실패하면 stale-allowance로 실패시킨다 (예외가 낡지 않게)', async () => {
        const results = await runSet([q(1)], { setId: 1, answers: { '1': 'a' }, allowTriviallyPasses: { '1': '사유' } }, goodFactory())

        expect(results[0]).toMatchObject({ ok: false, reason: 'stale-allowance' })
    })

    it('예외가 있어도 정답이 거부되면 그대로 실패다', async () => {
        const neverPass: SandboxFactory = async () => ({ exec: async (cmd) => (cmd[0] === 'grade' ? 1 : 0), dispose: async () => {} })

        const results = await runSet([q(1)], { setId: 1, answers: { '1': 'a' }, allowTriviallyPasses: { '1': '사유' } }, neverPass)

        expect(results[0]).toMatchObject({ ok: false, reason: 'answer-rejected' })
    })
})

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
