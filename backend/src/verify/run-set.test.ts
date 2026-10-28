import { describe, it, expect } from 'vitest'
import { runSet, runPersistentSet } from './run-set.js'
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


// 한 컨테이너 안에서 상태가 이어지는 세트. "상태"는 통과한 grade 번호의 집합으로 흉내 낸다.
describe('runPersistentSet', () => {
    function statefulFactory(log: string[] = []) {
        let created = 0
        const disposed: number[] = []
        const solved = new Set<string>() // 정답 명령('answer N')이 실행된 퀘스트
        const factory: SandboxFactory = async () => {
            const id = ++created
            return {
                exec: async (cmd) => {
                    const key = cmd.join(' ')
                    log.push(key)
                    if (cmd[0] === 'sh' && cmd[2]?.startsWith('answer ')) { solved.add(cmd[2].slice(7)); return 0 }
                    if (cmd[0] === 'grade') return solved.has(cmd[1]!) ? 0 : 1
                    return 0
                },
                dispose: async () => { disposed.push(id) },
            }
        }
        return { factory, log, created: () => created, disposed, solved }
    }
    const answers = { '1': 'answer 1', '2': 'answer 2' }

    it('한 컨테이너에서 퀘스트 순서대로 풀기 전 채점 → 정답 → 채점을 진행하고 마지막에 한 번 정리한다', async () => {
        const { factory, log, created, disposed } = statefulFactory()

        const results = await runPersistentSet([q(2), q(1)], { setId: 8, answers }, factory)

        expect(results.map((r) => r.ok)).toEqual([true, true])
        expect(created()).toBe(1)
        expect(disposed).toEqual([1])
        expect(log).toEqual(['grade 1', 'sh -c answer 1', 'grade 1', 'grade 2', 'sh -c answer 2', 'grade 2'])
    })

    it('앞 퀘스트가 이미 만든 상태 때문에 풀기 전부터 통과하면 trivially-passes다', async () => {
        const { factory, solved } = statefulFactory()
        solved.add('2') // 앞 퀘스트를 풀며 2번 채점 조건이 이미 만들어진 상황

        const results = await runPersistentSet([q(1), q(2)], { setId: 8, answers }, factory)

        expect(results[0]).toMatchObject({ ok: true })
        expect(results[1]).toMatchObject({ ok: false, reason: 'trivially-passes' })
    })

    it('정답을 수행했는데 채점이 실패하면 answer-rejected이고, 다음 퀘스트는 계속 진행한다', async () => {
        const { factory } = statefulFactory()
        const noop: Record<string, string> = { '1': 'true', '2': 'answer 2' } // 1번 정답이 상태를 만들지 못함

        const results = await runPersistentSet([q(1), q(2)], { setId: 8, answers: noop }, factory)

        expect(results[0]).toMatchObject({ ok: false, reason: 'answer-rejected' })
        expect(results[1]).toMatchObject({ ok: true })
    })

    it('fixture 누락은 no-fixture로 실패시키고 알려진 예외는 그대로 적용한다', async () => {
        const { factory, solved } = statefulFactory()
        solved.add('1')

        const results = await runPersistentSet([q(1), q(2)], { setId: 8, answers: { '1': 'answer 1' }, allowTriviallyPasses: { '1': '사유' } }, factory)

        expect(results[0]).toMatchObject({ ok: true, note: '사유' })
        expect(results[1]).toMatchObject({ ok: false, reason: 'no-fixture' })
    })

    it('setup이 실패하면 setup-failed로 보고한다', async () => {
        const factory: SandboxFactory = async () => ({ exec: async (cmd) => (cmd[0] === 'prep' ? 3 : 1), dispose: async () => {} })
        const withSetup: VerifyQuest = { ...q(1), setupCmd: ['prep'] }

        const results = await runPersistentSet([withSetup], { setId: 8, answers: { '1': 'answer 1' } }, factory)

        expect(results[0]).toMatchObject({ ok: false, reason: 'setup-failed' })
    })
})
