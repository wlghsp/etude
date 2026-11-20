// 세트 라벨 테스트. node 내장 테스트 실행기로 돌린다:
//   backend/node_modules/.bin/tsx --test frontend/src/setKind.test.ts
import test from 'node:test'
import assert from 'node:assert/strict'
import { setKind } from './setKind.ts'

const s = (sandbox_type: string, quest_count: number, terminal_count: number) => ({ sandbox_type, quest_count, terminal_count })

test('퀴즈 유형은 문제 풀이다', () => {
    const k = setKind(s('quiz', 12, 0))
    assert.deepEqual([k.icon, k.label, k.hint], ['📝', '문제 풀이', '터미널 없이 풀어요'])
})

test('터미널 문제만 있으면 터미널 실습이다', () => {
    const k = setKind(s('linux', 8, 8))
    assert.deepEqual([k.icon, k.label], ['💻', '터미널 실습'])
})

test('실습 유형이어도 터미널 문제가 하나도 없으면 문제 풀이다 (터미널은 곁에 있다)', () => {
    const k = setKind(s('k8s', 8, 0))
    assert.equal(k.label, '문제 풀이')
    assert.match(k.hint, /터미널/)
})

test('터미널 문제와 다른 문제가 섞이면 혼합이고 개수를 알려 준다', () => {
    const k = setKind(s('linux', 11, 4))
    assert.equal(k.icon, '🧩')
    assert.equal(k.label, '실습 + 문제 풀이')
    assert.match(k.hint, /터미널 4문제/)
    assert.match(k.hint, /문제 풀이 7문제/)
})

test('개수 정보가 없으면(옛 응답) 유형만 보고 기존처럼 표시한다', () => {
    assert.equal(setKind({ sandbox_type: 'linux' }).label, '터미널 실습')
    assert.equal(setKind({ sandbox_type: 'quiz' }).label, '문제 풀이')
})
