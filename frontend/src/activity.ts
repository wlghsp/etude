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
