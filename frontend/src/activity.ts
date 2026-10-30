// 최근 7일의 하루별 세트 완료 횟수. 학습 기록(세트 완료)에서만 계산한다. `now` 를 받아 화면 그리기와 분리한다.
export interface DayActivity {
    label: string // 요일
    count: number
    today: boolean
}

const NAMES = ['일', '월', '화', '수', '목', '금', '토']
const dayKey = (d: Date) => d.toLocaleDateString('sv-SE') // YYYY-MM-DD (내 시간대)

export function weekActivity(rows: Array<{ completions: Array<{ completedAt: string }> }>, now: Date): DayActivity[] {
    const counts = new Map<string, number>()
    for (const r of rows) {
        for (const c of r.completions) {
            const k = dayKey(new Date(c.completedAt))
            counts.set(k, (counts.get(k) ?? 0) + 1)
        }
    }
    return Array.from({ length: 7 }, (_, i) => {
        const d = new Date(now)
        d.setDate(d.getDate() - (6 - i))
        return { label: NAMES[d.getDay()]!, count: counts.get(dayKey(d)) ?? 0, today: i === 6 }
    })
}

/** 연속 학습일: 오늘(없으면 어제)부터 거꾸로 하루도 빠지지 않고 세트를 끝낸 날 수 */
export function currentStreak(rows: Array<{ completions: Array<{ completedAt: string }> }>, now: Date): number {
    const days = new Set<string>()
    for (const r of rows) for (const c of r.completions) days.add(dayKey(new Date(c.completedAt)))
    const cursor = new Date(now)
    if (!days.has(dayKey(cursor))) cursor.setDate(cursor.getDate() - 1) // 오늘 아직 안 했어도 어제까지 이어졌으면 유지
    let streak = 0
    while (days.has(dayKey(cursor))) { streak++; cursor.setDate(cursor.getDate() - 1) }
    return streak
}
