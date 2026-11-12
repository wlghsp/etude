// 홈 "다음 세트" 카드 맨 위 인사 문구. 마지막 학습 시점과 연속 학습일로 고른다. docs/specs/spec_home_greeting.md
// 순수 함수다: 현재 시각은 인자로 받고, 화면·시계를 읽지 않는다.

export interface GreetingInput {
    lastAt: Date | null // 마지막 세트 완료 시각
    streak: number // 연속 학습일 (서버 값)
    completed: number // 완료한 세트 수
    lastSetTitle: string | null // 마지막으로 끝낸 세트 이름
    now: Date
}

// 로컬 달력 날짜 차이 (24시간 단위가 아니다). 시계 오차로 음수가 되면 0 으로 본다.
function daysBetween(from: Date, to: Date): number {
    const a = Date.UTC(from.getFullYear(), from.getMonth(), from.getDate())
    const b = Date.UTC(to.getFullYear(), to.getMonth(), to.getDate())
    return Math.max(0, Math.round((b - a) / 86_400_000))
}

export function homeGreeting({ lastAt, streak, completed, lastSetTitle, now }: GreetingInput): string {
    if (completed === 0 || !lastAt) return '첫 세트를 시작해 볼까요? 🙂'
    const away = daysBetween(lastAt, now)
    if (away === 0) {
        if (streak >= 7 && streak % 7 === 0) return `🎉 ${streak}일째 매일 하고 있어요, 대단해요!`
        if (streak >= 2) return `오늘도 해냈네요! 연속 ${streak}일째예요 🔥`
        return '오늘 한 세트를 끝냈어요. 하나 더 해 볼까요? 🙂'
    }
    if (away === 1) {
        return streak >= 2 ? `어제에 이어 오늘도 해 볼까요? 연속 ${streak}일을 이어 가요 🔥` : '어제 이어서 오늘도 해 볼까요? 🙂'
    }
    if (away <= 13) return `오랜만이에요! ${lastSetTitle ? `지난번엔 "${lastSetTitle}" 를 했어요. ` : ''}오늘은 이거 해 볼까요? 🙂`
    return '다시 와 주셔서 반가워요. 가볍게 한 세트부터 시작해요 🙂'
}
