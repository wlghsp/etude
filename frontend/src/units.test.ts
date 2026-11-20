// groupByUnit 테스트. node 내장 테스트 실행기로 돌린다:
//   backend/node_modules/.bin/tsx --test frontend/src/units.test.ts   (docs/specs/spec_units.md)
import test from 'node:test'
import assert from 'node:assert/strict'
import { groupByUnit } from './units.ts'

interface S { id: number; u: number | null; o: number | null }
const info = (s: S) => ({ unitId: s.u, unitTitle: s.u === null ? null : `단원${s.u}`, unitOrder: s.o })

test('같은 단원이 이어져 있으면 한 묶음이다', () => {
    const g = groupByUnit<S>([{ id: 1, u: 1, o: 10 }, { id: 2, u: 1, o: 10 }, { id: 3, u: 2, o: 20 }], info)
    assert.deepEqual(g.map((x) => [x.unitId, x.items.map((i) => i.id)]), [[1, [1, 2]], [2, [3]]])
})

test('같은 단원이 떨어져 있어도 한 묶음이고 첫 위치에 둔다 (중복 key·중복 머리글 방지)', () => {
    const g = groupByUnit<S>([{ id: 1, u: 1, o: 10 }, { id: 2, u: 2, o: 20 }, { id: 3, u: 1, o: 10 }, { id: 4, u: 2, o: 20 }], info)
    assert.deepEqual(g.map((x) => [x.unitId, x.items.map((i) => i.id)]), [[1, [1, 3]], [2, [2, 4]]])
    assert.equal(new Set(g.map((x) => x.unitId)).size, g.length)
})

test('묶음은 단원 순서(unit.display_order)대로 놓고 번호는 1부터 연속으로 매긴다', () => {
    const g = groupByUnit<S>([{ id: 1, u: 5, o: 50 }, { id: 2, u: 3, o: 30 }], info)
    assert.deepEqual(g.map((x) => [x.unitId, x.number]), [[3, 1], [5, 2]])
})

test('세트 순서가 단원 순서와 어긋나도 단원 번호가 순서대로 나온다 (5,7,6 → 5,6,7)', () => {
    const g = groupByUnit<S>([{ id: 1, u: 5, o: 60 }, { id: 2, u: 7, o: 90 }, { id: 3, u: 6, o: 70 }], info)
    assert.deepEqual(g.map((x) => [x.unitId, x.number]), [[5, 1], [6, 2], [7, 3]])
})

test('단원 순서가 같은 단원은 처음 나온 세트 순으로 가르고 번호는 겹치지 않는다', () => {
    const g = groupByUnit<S>([{ id: 1, u: 27, o: 90 }, { id: 2, u: 25, o: 90 }], info)
    assert.deepEqual(g.map((x) => [x.unitId, x.number]), [[27, 1], [25, 2]])
})

test('단원 없는 세트(null)는 한 묶음으로 모아 분야 맨 끝에 둔다 (번호 없음)', () => {
    const g = groupByUnit<S>([{ id: 1, u: null, o: null }, { id: 2, u: 1, o: 10 }, { id: 3, u: null, o: null }], info)
    assert.deepEqual(g.map((x) => [x.unitId, x.items.map((i) => i.id), x.number]), [[1, [2], 1], [null, [1, 3], null]])
})

// --- 기본으로 펼칠 단원 ---
import { defaultOpenGroupIndex } from './units.ts'

const grp = (id: number, u: number, ids: number[]) => ({ unitId: u, title: `단원${u}`, number: id, items: ids.map((i) => ({ id: i })) })
const done = (set: Set<number>) => (i: { id: number }) => set.has(i.id)

test('추천 세트가 있는 단원을 펼친다', () => {
    const g = [grp(1, 1, [1, 2]), grp(2, 2, [3, 4]), grp(3, 3, [5])]
    assert.equal(defaultOpenGroupIndex(g, 4, done(new Set([1, 2, 3]))), 1)
})

test('추천 세트가 이 분야에 없으면 아직 안 끝낸 세트가 있는 첫 단원을 펼친다', () => {
    const g = [grp(1, 1, [1, 2]), grp(2, 2, [3, 4])]
    assert.equal(defaultOpenGroupIndex(g, 99, done(new Set([1, 2]))), 1)
    assert.equal(defaultOpenGroupIndex(g, null, done(new Set())), 0)
})

test('전부 끝냈으면 펼칠 단원이 없다 (-1)', () => {
    const g = [grp(1, 1, [1]), grp(2, 2, [2])]
    assert.equal(defaultOpenGroupIndex(g, null, done(new Set([1, 2]))), -1)
})
