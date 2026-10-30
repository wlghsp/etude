// 연속 학습일 계산 (명예의 전당·소식 축하가 함께 쓴다)

export const toUtc = (day: string) => { const [y, m, d] = day.split('-').map(Number); return Date.UTC(y!, m! - 1, d!) }
export const DAY_MS = 24 * 60 * 60 * 1000
export const toDay = (ms: number) => new Date(ms).toISOString().slice(0, 10)

/** 오늘(없으면 어제)부터 거꾸로 하루도 빠지지 않고 이어진 날 수 */
export function streakFromDays(days: Set<string>, today: string): number {
    let cursor = toUtc(today)
    if (!days.has(toDay(cursor))) cursor -= DAY_MS
    let streak = 0
    while (days.has(toDay(cursor))) { streak++; cursor -= DAY_MS }
    return streak
}
