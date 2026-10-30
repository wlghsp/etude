// 한 분야 안의 항목을 단원별로 묶는다. 입력은 이미 서버가 정한 순서(display_order)로 와 있고,
// 같은 단원의 항목은 서로 이어져 있다고 가정한다 (docs/specs/spec_units.md).
export interface UnitInfo {
    unitId: number | null
    unitTitle: string | null
    unitOrder: number | null
}

export interface UnitGroup<T> {
    unitId: number | null
    title: string | null
    number: number | null // 분야 안에서 몇 번째 단원인지 (단원이 없으면 null)
    items: T[]
}

export function groupByUnit<T>(items: T[], info: (item: T) => UnitInfo): UnitGroup<T>[] {
    const orders = Array.from(new Set(items.map((i) => info(i).unitOrder).filter((o): o is number => o !== null))).sort((a, b) => a - b)
    const groups: UnitGroup<T>[] = []
    for (const item of items) {
        const u = info(item)
        const last = groups[groups.length - 1]
        if (last && last.unitId === u.unitId) {
            last.items.push(item)
        } else {
            groups.push({ unitId: u.unitId, title: u.unitTitle, number: u.unitOrder === null ? null : orders.indexOf(u.unitOrder) + 1, items: [item] })
        }
    }
    return groups
}
