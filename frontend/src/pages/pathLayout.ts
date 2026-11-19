// 단원 길(SetPath)의 배치 계산. 컨테이너 폭에 맞춰 길 폭·중심·굽이침·노드 크기를 정한다.
// 480px 이상이면 기존 배치 그대로, 그보다 좁으면(휴대폰) 좁은 배치를 쓴다.

export const MAX_WIDTH = 520 // 길 영역의 최대 폭(px)
export const OFFSETS = [0, 52, 84, 52, 0, -52, -84, -52] // 노드가 좌우로 굽이치는 정도(px, 넓은 배치 기준)
const COMPACT_BELOW = 480

export interface PathLayout {
    width: number // 길 영역의 폭
    baseX: number // 길의 중심 x
    swing: number // 굽이침 배율 (OFFSETS 에 곱한다)
    nodeNext: number // 다음 추천 노드 지름
    nodeNormal: number // 일반 노드 지름
    compact: boolean
}

export function pathLayout(available: number): PathLayout {
    const width = Math.min(MAX_WIDTH, Math.max(0, available))
    if (width >= COMPACT_BELOW) return { width: MAX_WIDTH, baseX: 200, swing: 1, nodeNext: 84, nodeNormal: 68, compact: false }
    return { width, baseX: 84, swing: 0.55, nodeNext: 72, nodeNormal: 58, compact: true }
}
