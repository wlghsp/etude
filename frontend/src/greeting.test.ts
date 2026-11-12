// 홈 인사 문구 테스트. 의존성을 늘리지 않으려고 node 내장 테스트 실행기로 돌린다:
//   backend/node_modules/.bin/tsx --test frontend/src/greeting.test.ts   (docs/specs/spec_home_greeting.md)
import test from 'node:test'
import assert from 'node:assert/strict'
import { homeGreeting } from './greeting.ts'

const now = new Date(2026, 10, 12, 15, 0) // 로컬 2026-11-12 15:00
const daysAgo = (n: number, h = 10) => new Date(2026, 10, 12 - n, h, 0)
const base = { completed: 5, streak: 0, lastSetTitle: '도커 볼륨', now }

test('1: 완료 기록이 없으면 첫 세트 안내', () => {
    assert.equal(homeGreeting({ ...base, completed: 0, lastAt: null }), '첫 세트를 시작해 볼까요? 🙂')
    assert.equal(homeGreeting({ ...base, lastAt: null }), '첫 세트를 시작해 볼까요? 🙂')
})
test('2: 오늘 학습, 연속이 7의 배수(7 이상)', () => {
    assert.match(homeGreeting({ ...base, lastAt: daysAgo(0), streak: 7 }), /7일째 매일/)
    assert.match(homeGreeting({ ...base, lastAt: daysAgo(0), streak: 14 }), /14일째 매일/)
})
test('3: 오늘 학습, 연속 2일 이상', () => {
    assert.equal(homeGreeting({ ...base, lastAt: daysAgo(0), streak: 3 }), '오늘도 해냈네요! 연속 3일째예요 🔥')
    assert.match(homeGreeting({ ...base, lastAt: daysAgo(0), streak: 6 }), /연속 6일째/)
})
test('4: 오늘 학습, 연속 1일', () => {
    assert.match(homeGreeting({ ...base, lastAt: daysAgo(0), streak: 1 }), /하나 더/)
})
test('5: 어제 학습, 연속 2일 이상', () => {
    assert.match(homeGreeting({ ...base, lastAt: daysAgo(1), streak: 4 }), /어제에 이어.*연속 4일/)
})
test('6: 어제 학습, 연속 1일', () => {
    assert.match(homeGreeting({ ...base, lastAt: daysAgo(1), streak: 1 }), /어제/)
})
test('7: 2~13일 쉼은 지난 세트 이름을 말한다', () => {
    for (const n of [2, 5, 13]) assert.match(homeGreeting({ ...base, lastAt: daysAgo(n) }), /오랜만이에요.*"도커 볼륨"/)
})
test('7: 세트 이름이 없으면 그 문장을 뺀다', () => {
    const s = homeGreeting({ ...base, lastAt: daysAgo(3), lastSetTitle: null })
    assert.match(s, /오랜만이에요/)
    assert.doesNotMatch(s, /지난번/)
})
test('8: 14일 이상 쉬면 부담 없이 시작하자는 문구', () => {
    for (const n of [14, 40]) assert.match(homeGreeting({ ...base, lastAt: daysAgo(n) }), /가볍게 한 세트/)
})
test('자정 경계: 어제 23:59 완료, 지금 00:01 이면 어제(1일)', () => {
    const justAfterMidnight = new Date(2026, 10, 12, 0, 1)
    const lastNight = new Date(2026, 10, 11, 23, 59)
    assert.match(homeGreeting({ ...base, now: justAfterMidnight, lastAt: lastNight, streak: 2 }), /어제에 이어/)
})
test('시계 오차: 완료 시각이 미래여도 오늘로 본다', () => {
    const future = new Date(2026, 10, 13, 9, 0)
    assert.match(homeGreeting({ ...base, lastAt: future, streak: 3 }), /오늘도 해냈/)
})
test('압박하는 말은 쓰지 않는다', () => {
    for (const n of [0, 1, 3, 20]) assert.doesNotMatch(homeGreeting({ ...base, lastAt: daysAgo(n), streak: 1 }), /안 하|못 했|밀렸|끊/)
})
