import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { getQuests, getChoiceQuest, judgeAnswer, type ChoiceQuest } from './quest.js'

const order: ChoiceQuest = { questId: 1, questSetId: 1, kind: 'order', choiceCount: 4, answerIndex: null, answerSpec: [2, 0, 3, 1], explanation: '해설' }
const fill: ChoiceQuest = { questId: 2, questSetId: 1, kind: 'fill', choiceCount: 5, answerIndex: null, answerSpec: [4, 1], explanation: '해설' }
const choice: ChoiceQuest = { questId: 3, questSetId: 1, kind: 'choice', choiceCount: 4, answerIndex: 1, explanation: 'x' }

describe('judgeAnswer — 순서 맞추기', () => {
    it('모든 자리가 맞으면 통과이고 자리마다 true 를 돌려준다', () => {
        expect(judgeAnswer(order, [2, 0, 3, 1])).toEqual({ passed: true, results: [true, true, true, true] })
    })

    it('틀리면 통과가 아니고, 어느 자리가 맞았는지 알려 준다', () => {
        expect(judgeAnswer(order, [2, 0, 1, 3])).toEqual({ passed: false, results: [true, true, false, false] })
    })

    it('길이가 다르거나 범위 밖·정수 아님·중복이면 null (잘못된 요청)', () => {
        for (const a of [[2, 0, 3], [2, 0, 3, 1, 0], [2, 0, 3, 4], [2, 0, 3, -1], [2, 0, 3, 1.5], [2, 0, 3, '1'], [2, 2, 3, 1], 'x', null, undefined, {}]) {
            expect(judgeAnswer(order, a), JSON.stringify(a)).toBeNull()
        }
    })
})

describe('judgeAnswer — 빈칸 채우기', () => {
    it('빈칸마다 맞는 칩이면 통과', () => {
        expect(judgeAnswer(fill, [4, 1])).toEqual({ passed: true, results: [true, true] })
    })

    it('틀린 빈칸을 알려 준다', () => {
        expect(judgeAnswer(fill, [4, 2])).toEqual({ passed: false, results: [true, false] })
    })

    it('같은 칩을 여러 빈칸에 쓸 수 있다 (정답이 같은 칩이면)', () => {
        const same: ChoiceQuest = { ...fill, answerSpec: [3, 3] }

        expect(judgeAnswer(same, [3, 3])).toEqual({ passed: true, results: [true, true] })
    })

    it('길이가 빈칸 수와 다르거나 범위 밖이면 null', () => {
        for (const a of [[4], [4, 1, 0], [4, 5], [4, -1], [4, 0.5], 4, null]) expect(judgeAnswer(fill, a), JSON.stringify(a)).toBeNull()
    })
})

describe('judgeAnswer — 객관식과 그 밖', () => {
    it('객관식은 번호 하나로 판정하고 results 는 없다', () => {
        expect(judgeAnswer(choice, 1)).toEqual({ passed: true })
        expect(judgeAnswer(choice, 0)).toEqual({ passed: false })
        expect(judgeAnswer(choice, 9)).toBeNull()
    })

    it('실습형이거나 정답 정보가 없으면 null', () => {
        expect(judgeAnswer({ ...choice, kind: 'terminal' }, 1)).toBeNull()
        expect(judgeAnswer({ ...order, answerSpec: null }, [0, 1, 2, 3])).toBeNull()
    })
})

describe('참고 문서 링크(docs)', () => {
    beforeEach(() => vi.clearAllMocks())

    it('문제 조회가 공식 문서 링크 목록을 내보낸다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[
            { id: 1, title: 't', description: 'd', kind: 'terminal', choices: null, template: null, checks: null, docs: '[{"title":"Deployment","url":"https://kubernetes.io/docs/concepts/workloads/controllers/deployment/"}]' },
        ]] as any)

        const quests = await getQuests(3)

        expect(String(vi.mocked(db.query).mock.calls[0]![0])).toContain('docs')
        expect(quests[0]).toMatchObject({ docs: [{ title: 'Deployment', url: 'https://kubernetes.io/docs/concepts/workloads/controllers/deployment/' }] })
    })

    it('링크가 없으면 null 이고, https 가 아니거나 모양이 틀린 항목은 걸러낸다 (javascript: 같은 주소가 화면에 나가지 않게)', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[
            { id: 1, title: 't', description: 'd', kind: 'terminal', choices: null, template: null, checks: null, docs: null },
            { id: 2, title: 't', description: 'd', kind: 'terminal', choices: null, template: null, checks: null, docs: '[{"title":"x","url":"javascript:alert(1)"},{"title":"y","url":"http://example.com"},{"url":"https://a.dev"},{"title":"ok","url":"https://docs.docker.com/compose/"}]' },
            { id: 3, title: 't', description: 'd', kind: 'terminal', choices: null, template: null, checks: null, docs: '{깨짐' },
        ]] as any)

        const quests = await getQuests(3)

        expect(quests[0]!.docs).toBeNull()
        expect(quests[1]!.docs).toEqual([{ title: 'ok', url: 'https://docs.docker.com/compose/' }])
        expect(quests[2]!.docs).toBeNull()
    })
})

describe('문제 조회와 판정용 조회', () => {
    beforeEach(() => vi.clearAllMocks())

    it('문제 조회는 template 을 내보내고 answer_spec 은 읽지도 내보내지도 않는다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[
            { id: 2, title: 't', description: 'd', hint: null, solution: null, setup_cmd: null, kind: 'fill', choices: '["scale","get","--replicas"]', template: 'kubectl {0} deployment web {1}=3', checks: null },
        ]] as any)

        const quests = await getQuests(3)

        const sql = vi.mocked(db.query).mock.calls[0]![0] as string
        expect(sql).toContain('template')
        expect(sql).not.toContain('answer_spec')
        expect(quests[0]).toMatchObject({ kind: 'fill', template: 'kubectl {0} deployment web {1}=3', choices: ['scale', 'get', '--replicas'] })
        expect(Object.keys(quests[0]!)).not.toContain('answer_spec')
    })

    it('template 이 없는 문제는 null', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ id: 1, title: 't', description: 'd', kind: 'terminal', choices: null, checks: null }]] as any)

        expect((await getQuests(3))[0]).toMatchObject({ template: null })
    })

    it('판정용 조회는 answer_spec 을 읽는다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ id: 1, quest_set_id: 3, kind: 'order', choices: '["a","b","c","d"]', answer_index: null, answer_spec: '[2,0,3,1]', explanation: '해설' }]] as any)

        const q = await getChoiceQuest(1)

        expect(String(vi.mocked(db.query).mock.calls[0]![0])).toContain('answer_spec')
        expect(q).toMatchObject({ kind: 'order', choiceCount: 4, answerSpec: [2, 0, 3, 1] })
    })
})
