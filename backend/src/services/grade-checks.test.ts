import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { getQuests, gradeQuest } from './quest.js'

// 명령에 이 글자가 들어 있으면 실패(종료 코드 1), 아니면 성공(0)인 가짜 컨테이너
function fakeDocker(failWhen: string[] = []) {
    const calls: string[][] = []
    const container = {
        exec: vi.fn(async (opts: { Cmd: string[] }) => {
            calls.push(opts.Cmd)
            const fails = failWhen.some((f) => opts.Cmd.join(' ').includes(f))
            return { start: async () => {}, inspect: async () => ({ Running: false, ExitCode: fails ? 1 : 0 }) }
        }),
    }
    return { docker: { getContainer: vi.fn(() => container) } as any, calls }
}

const checksJson = JSON.stringify([
    { label: '이름이 해석된다', cmd: ['sh', '-c', 'check-name $NS'] },
    { label: '파일이 있다', cmd: ['sh', '-c', 'check-file'] },
])

describe('gradeQuest', () => {
    beforeEach(() => vi.clearAllMocks())

    it('조건 목록(checks)이 있으면 조건마다 실행해 통과 여부를 돌려주고, 모두 통과해야 passed 이다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ grade_cmd: '["sh","-c","never-used"]', checks: checksJson }]] as any)
        const { docker, calls } = fakeDocker(['check-file'])

        const r = await gradeQuest('abcdef1234567890', 5, docker)

        expect(r).toEqual({ passed: false, checks: [{ label: '이름이 해석된다', passed: true }, { label: '파일이 있다', passed: false }] })
        expect(calls).toHaveLength(2)
        expect(calls[0]!.join(' ')).toContain('check-name quest-abcdef12') // $NS 가 세션 네임스페이스로 바뀐다
    })

    it('모든 조건이 통과하면 passed 이다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ grade_cmd: '[]', checks: checksJson }]] as any)
        const { docker } = fakeDocker()

        const r = await gradeQuest('abcdef1234567890', 5, docker)

        expect(r.passed).toBe(true)
        expect(r.checks!.every((c) => c.passed)).toBe(true)
    })

    it('checks 가 없으면 기존처럼 grade_cmd 하나로 채점하고 checks 는 null 이다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ grade_cmd: '["sh","-c","only-grade"]', checks: null }]] as any)
        const { docker, calls } = fakeDocker()

        const r = await gradeQuest('abcdef1234567890', 5, docker)

        expect(r).toEqual({ passed: true, checks: null })
        expect(calls).toEqual([['sh', '-c', 'only-grade']])
    })

    it('checks JSON 이 깨져 있으면 grade_cmd 로 채점한다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ grade_cmd: '["sh","-c","only-grade"]', checks: '{깨짐' }]] as any)
        const { docker, calls } = fakeDocker()

        const r = await gradeQuest('abcdef1234567890', 5, docker)

        expect(r.checks).toBeNull()
        expect(calls).toHaveLength(1)
    })

    it('퀘스트가 없으면 실패이다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[]] as any)
        const { docker } = fakeDocker()

        expect(await gradeQuest('abcdef1234567890', 9, docker)).toEqual({ passed: false, checks: null })
    })
})

describe('getQuests 의 조건 목록', () => {
    beforeEach(() => vi.clearAllMocks())

    it('조건의 이름(label)만 내보내고 채점 명령(cmd)은 내보내지 않는다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[
            { id: 1, title: 't', description: 'd', hint: 'h', solution: 's', setup_cmd: null, kind: 'terminal', choices: null, checks: checksJson },
            { id: 2, title: 't2', description: 'd', hint: 'h', solution: 's', setup_cmd: null, kind: 'terminal', choices: null, checks: null },
        ]] as any)

        const quests = await getQuests(3)

        expect(quests[0]).toMatchObject({ check_labels: ['이름이 해석된다', '파일이 있다'] })
        expect(JSON.stringify(quests[0])).not.toContain('check-name')
        expect(Object.keys(quests[0]!)).not.toContain('checks')
        expect(quests[1]).toMatchObject({ check_labels: null })
    })
})
