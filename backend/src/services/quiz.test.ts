import { describe, it, expect, vi, beforeEach } from 'vitest'

vi.mock('../db.js', () => ({ db: { query: vi.fn() } }))
import { db } from '../db.js'
import { getQuests, getChoiceQuest, judgeChoice, type ChoiceQuest } from './quest.js'

const q: ChoiceQuest = { questId: 1, questSetId: 1, kind: 'choice', choiceCount: 4, answerIndex: 1, explanation: 'x' }

describe('judgeChoice', () => {
    it('정답 번호면 true, 다른 번호면 false', () => {
        expect(judgeChoice(q, 1)).toBe(true)
        expect(judgeChoice(q, 0)).toBe(false)
        expect(judgeChoice(q, 3)).toBe(false)
    })

    it('정수가 아니거나 범위를 벗어나면 null (잘못된 요청)', () => {
        for (const v of [4, -1, 1.2, '1', null, undefined, NaN]) expect(judgeChoice(q, v), String(v)).toBeNull()
    })

    it('객관식이 아니거나 정답이 없는 퀘스트는 null', () => {
        expect(judgeChoice({ ...q, kind: 'terminal' }, 1)).toBeNull()
        expect(judgeChoice({ ...q, answerIndex: null }, 1)).toBeNull()
    })
})

describe('문제 목록 조회', () => {
    beforeEach(() => vi.clearAllMocks())

    it('정답(answer_index)과 해설(explanation)을 조회하지도 내보내지도 않는다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[
            { id: 1, title: 't', description: 'd', hint: 'h', solution: null, setup_cmd: null, kind: 'choice', choices: '["가","나","다","라"]' },
        ]] as any)

        const quests = await getQuests(3)

        const sql = vi.mocked(db.query).mock.calls[0]![0] as string
        expect(sql).not.toContain('answer_index')
        expect(sql).not.toContain('explanation')
        expect(quests[0]).toMatchObject({ kind: 'choice', choices: ['가', '나', '다', '라'] })
        expect(Object.keys(quests[0]!)).not.toContain('answer_index')
    })

    it('실습 퀘스트는 choices 가 null 이다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[
            { id: 2, title: 't', description: 'd', hint: 'h', solution: 's', setup_cmd: null, kind: 'terminal', choices: null },
        ]] as any)

        expect((await getQuests(3))[0]).toMatchObject({ kind: 'terminal', choices: null })
    })
})

describe('getChoiceQuest', () => {
    beforeEach(() => vi.clearAllMocks())

    it('판정에 필요한 정답과 선택지 개수를 읽는다', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[{ id: 5, quest_set_id: 3, kind: 'choice', choices: '["a","b","c"]', answer_index: 2, explanation: '해설' }]] as any)

        expect(await getChoiceQuest(5)).toEqual({ questId: 5, questSetId: 3, kind: 'choice', choiceCount: 3, answerIndex: 2, explanation: '해설' })
    })

    it('없는 퀘스트는 null', async () => {
        vi.mocked(db.query).mockResolvedValueOnce([[]] as any)

        expect(await getChoiceQuest(404)).toBeNull()
    })
})
