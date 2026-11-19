// 한 분야 안의 항목을 단원별로 묶는다. 입력은 이미 서버가 정한 세트 순서(display_order)로 와 있다.
// 같은 단원의 항목은 이어져 있어야 하지만(docs/specs/spec_units.md), 어긋나 있어도 한 단원은 한 묶음으로 모으고 단원 순서대로 놓는다.
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
    const groups: UnitGroup<T>[] = []
    const byUnit = new Map<number | null, UnitGroup<T>>()
    const orderOf = new Map<UnitGroup<T>, number | null>()
    for (const item of items) {
        const u = info(item)
        // 순서(display_order)가 떨어져 있어도 같은 단원은 처음 나온 자리에 한 묶음으로 모은다 (단원 머리글·key 중복 방지).
        const found = byUnit.get(u.unitId)
        if (found) {
            found.items.push(item)
        } else {
            const g: UnitGroup<T> = { unitId: u.unitId, title: u.unitTitle, number: null, items: [item] }
            byUnit.set(u.unitId, g)
            orderOf.set(g, u.unitOrder)
            groups.push(g)
        }
    }
    // 묶음은 단원 순서(unit.display_order)대로 놓는다. 순서가 같으면 처음 나온 세트 순(정렬은 안정적)이고,
    // 단원 없는 묶음은 분야 맨 끝에 둔다. 번호는 단원 있는 묶음에 1부터 연속으로 매긴다 (순서가 같아도 겹치지 않는다).
    const rank = (g: UnitGroup<T>) => orderOf.get(g) ?? Number.POSITIVE_INFINITY
    groups.sort((a, b) => rank(a) - rank(b))
    let n = 0
    for (const g of groups) g.number = orderOf.get(g) === null ? null : ++n
    return groups
}
