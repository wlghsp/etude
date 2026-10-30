import { describe, it, expect, vi } from 'vitest'
import { checkCoverage, summarize, verifyQuest, type SandboxFactory, type VerifyQuest } from './verify-quest.js'

// 명령 문자열을 키로 종료 코드를 돌려주는 가짜 샌드박스. 컨테이너가 몇 개 만들어지고 정리되는지도 기록한다.
function fakeFactory(exitCodes: Record<string, number>, log: string[] = []) {
    let created = 0
    const disposed: number[] = []
    const factory: SandboxFactory = async () => {
        const id = ++created
        return {
            exec: async (cmd) => {
                const key = cmd.join(' ')
                log.push(`${id}:${key}`)
                return exitCodes[key] ?? 0
            },
            dispose: async () => { disposed.push(id) },
        }
    }
    return { factory, log, disposed, created: () => created }
}

const quest: VerifyQuest = {
    orderIndex: 1,
    title: '현재 위치 확인하기',
    setupCmd: ['sh', '-c', 'touch /tmp/a'],
    gradeCmd: ['sh', '-c', 'grep -q / /tmp/r'],
}
const answer = 'pwd > /tmp/r'
const ANSWER_KEY = 'sh -c pwd > /tmp/r'
const GRADE_KEY = 'sh -c grep -q / /tmp/r'

describe('checkCoverage', () => {
    it('fixture가 없는 퀘스트와 퀘스트가 없는 fixture를 각각 보고한다', () => {
        const result = checkCoverage([1, 2, 3], { '1': 'a', '3': 'c', '9': 'z' })

        expect(result).toEqual({ missing: [2], extra: [9] })
    })

    it('모두 맞으면 비어 있다', () => {
        expect(checkCoverage([1, 2], { '1': 'a', '2': 'b' })).toEqual({ missing: [], extra: [] })
    })
})

describe('verifyQuest', () => {
    it('정답이 통과하고 무행동이 실패하면 ok이다', async () => {
        // 정답 검사의 grade는 0(통과), 무행동 검사의 grade는 1(실패)이어야 하므로 컨테이너별로 다르게 응답한다
        let n = 0
        const factory: SandboxFactory = async () => {
            const id = ++n
            return {
                exec: async (cmd) => (cmd.join(' ') === GRADE_KEY ? (id === 1 ? 0 : 1) : 0),
                dispose: async () => {},
            }
        }

        const result = await verifyQuest(quest, answer, factory)

        expect(result).toEqual({ orderIndex: 1, title: quest.title, ok: true })
    })

    it('정답을 수행했는데 채점이 실패하면 answer-rejected로 보고한다', async () => {
        const { factory } = fakeFactory({ [GRADE_KEY]: 1 })

        const result = await verifyQuest(quest, answer, factory)

        expect(result).toMatchObject({ ok: false, reason: 'answer-rejected' })
    })

    it('아무것도 안 했는데 채점이 통과하면 trivially-passes로 보고한다', async () => {
        const { factory } = fakeFactory({}) // grade가 항상 0

        const result = await verifyQuest(quest, answer, factory)

        expect(result).toMatchObject({ ok: false, reason: 'trivially-passes' })
    })

    it('setup이 실패하면 setup-failed로 보고하고 정답·채점은 실행하지 않는다', async () => {
        const log: string[] = []
        const { factory } = fakeFactory({ 'sh -c touch /tmp/a': 2 }, log)

        const result = await verifyQuest(quest, answer, factory)

        expect(result).toMatchObject({ ok: false, reason: 'setup-failed' })
        expect(log.some((l) => l.endsWith(ANSWER_KEY))).toBe(false)
        expect(log.some((l) => l.endsWith(GRADE_KEY))).toBe(false)
    })

    it('정답은 sh -c로 실행하고, 검사마다 새 컨테이너를 만들어 모두 정리한다', async () => {
        const { factory, log, disposed, created } = fakeFactory({ [GRADE_KEY]: 0 })

        await verifyQuest(quest, answer, factory)

        expect(log).toContain(`1:${ANSWER_KEY}`)
        expect(created()).toBe(2)
        expect(disposed.sort()).toEqual([1, 2])
    })

    it('중간에 예외가 나도 컨테이너를 정리하고 error로 보고한다', async () => {
        const dispose = vi.fn(async () => {})
        const factory: SandboxFactory = async () => ({
            exec: async () => { throw new Error('docker down') },
            dispose,
        })

        const result = await verifyQuest(quest, answer, factory)

        expect(result).toMatchObject({ ok: false, reason: 'error' })
        expect(dispose).toHaveBeenCalled()
    })

    it('setup이 없는 퀘스트도 검증한다', async () => {
        const { factory, log } = fakeFactory({})

        await verifyQuest({ ...quest, setupCmd: null }, answer, factory)

        expect(log.some((l) => l.includes('touch'))).toBe(false)
    })
})

describe('verifyQuest — 조건별 채점(checks)', () => {
    const checks = [
        { label: '파일이 있다', cmd: ['sh', '-c', 'test -f /tmp/r'] },
        { label: '내용이 맞다', cmd: ['sh', '-c', 'grep -q / /tmp/r'] },
    ]
    const withChecks: VerifyQuest = { ...quest, checks }
    const KEYS = { exists: 'sh -c test -f /tmp/r', content: 'sh -c grep -q / /tmp/r' }

    // 정답을 수행한 첫 컨테이너에서는 모두 통과하고, 무행동 컨테이너에서는 grade 와 조건 하나가 실패하는 샌드박스
    const sandboxes = (answerOverrides: Record<string, number> = {}) => {
        let n = 0
        const factory: SandboxFactory = async () => {
            const id = ++n
            return {
                exec: async (cmd) => {
                    const key = cmd.join(' ')
                    if (id === 1) return answerOverrides[key] ?? 0
                    return key === GRADE_KEY || key === KEYS.content ? 1 : 0
                },
                dispose: async () => {},
            }
        }
        return factory
    }

    it('정답 뒤에 모든 조건이 통과하고 무행동에서는 일부 조건이 실패하면 ok 이다', async () => {
        expect(await verifyQuest(withChecks, answer, sandboxes())).toEqual({ orderIndex: 1, title: quest.title, ok: true })
    })

    it('정답을 수행했는데 조건 하나가 통과하지 않으면 answer-rejected 이고 조건 이름을 알려 준다', async () => {
        const result = await verifyQuest(withChecks, answer, sandboxes({ [KEYS.exists]: 1 }))

        expect(result).toMatchObject({ ok: false, reason: 'answer-rejected' })
        expect((result as { detail: string }).detail).toContain('파일이 있다')
    })

    it('아무것도 안 했는데 모든 조건이 통과하면 trivially-passes 이다 (grade_cmd 가 아니라 조건이 엇나간 경우)', async () => {
        let n = 0
        const factory: SandboxFactory = async () => {
            const id = ++n
            // 무행동 컨테이너에서도 조건은 모두 통과하고 grade_cmd 만 실패한다 → 체크리스트가 비어 보이는 문제
            return { exec: async (cmd) => (id !== 1 && cmd.join(' ') === GRADE_KEY ? 1 : 0), dispose: async () => {} }
        }

        // grade_cmd 와 다른 명령으로 된 조건 (같은 문자열이면 같이 실패해 버린다)
        const distinct: VerifyQuest = { ...quest, checks: [{ label: 'A', cmd: ['sh', '-c', 'test -f /tmp/a'] }, { label: 'B', cmd: ['sh', '-c', 'test -s /tmp/b'] }] }

        const result = await verifyQuest(distinct, answer, factory)

        expect(result).toMatchObject({ ok: false, reason: 'trivially-passes' })
        expect((result as { detail: string }).detail).toContain('조건')
    })

    it('조건이 없는 문제는 기존처럼 검증한다', async () => {
        expect(await verifyQuest({ ...quest, checks: undefined }, answer, sandboxes())).toMatchObject({ ok: true })
    })
})

describe('채점 타임아웃', () => {
    it('grade_cmd는 실제 채점과 같은 15초 타임아웃으로 실행한다', async () => {
        const calls: Array<{ cmd: string; timeoutMs?: number }> = []
        const factory: SandboxFactory = async () => ({
            exec: async (cmd, timeoutMs) => { calls.push({ cmd: cmd.join(' '), timeoutMs }); return 0 },
            dispose: async () => {},
        })

        await verifyQuest(quest, answer, factory)

        const grade = calls.filter((c) => c.cmd === GRADE_KEY)
        expect(grade.length).toBeGreaterThan(0)
        expect(grade.every((c) => c.timeoutMs === 15_000)).toBe(true)
    })
})

describe('summarize', () => {
    it('실패가 하나라도 있으면 종료 코드가 0이 아니다', () => {
        const ok = { orderIndex: 1, title: 'a', ok: true as const }
        const bad = { orderIndex: 2, title: 'b', ok: false as const, reason: 'answer-rejected' as const, detail: 'x' }

        expect(summarize([ok, ok])).toMatchObject({ passed: 2, failed: 0, exitCode: 0 })
        expect(summarize([ok, bad])).toMatchObject({ passed: 1, failed: 1, exitCode: 1 })
    })
})
