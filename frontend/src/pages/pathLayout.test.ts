// 단원 길 배치 계산 테스트. node 내장 테스트 실행기로 돌린다:
//   backend/node_modules/.bin/tsx --test frontend/src/pages/pathLayout.test.ts
import test from 'node:test'
import assert from 'node:assert/strict'
import { pathLayout, OFFSETS } from './pathLayout.ts'

test('넓은 화면은 기존 배치(폭 520, 중심 200, 굽이침 100%)를 그대로 쓴다', () => {
    const l = pathLayout(900)
    assert.deepEqual([l.width, l.baseX, l.swing, l.nodeNext, l.nodeNormal, l.compact], [520, 200, 1, 84, 68, false])
})

test('좁은 화면은 폭을 컨테이너에 맞추고 좁은 배치로 바꾼다', () => {
    const l = pathLayout(311)
    assert.equal(l.width, 311)
    assert.equal(l.compact, true)
})

test('어떤 폭에서도 노드가 길 영역 밖으로 나가지 않는다', () => {
    for (let avail = 260; avail <= 900; avail += 10) {
        const l = pathLayout(avail)
        for (const o of OFFSETS) {
            for (const size of [l.nodeNext, l.nodeNormal]) {
                const x = l.baseX + o * l.swing
                assert.ok(x - size / 2 >= 0, `왼쪽 넘침 avail=${avail} offset=${o}`)
                assert.ok(x + size / 2 <= l.width, `오른쪽 넘침 avail=${avail} offset=${o}`)
            }
        }
    }
})

test('좁은 화면에서도 제목 칸이 최소 폭(90px) 이상 남는다', () => {
    for (let avail = 280; avail < 480; avail += 10) {
        const l = pathLayout(avail)
        const maxX = Math.max(...OFFSETS.map((o) => l.baseX + o * l.swing))
        assert.ok(l.width - 10 - (maxX + l.nodeNext / 2 + 12) >= 90, `제목 칸 부족 avail=${avail}`)
    }
})
