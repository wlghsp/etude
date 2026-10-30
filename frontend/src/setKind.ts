import type { QuestSet } from './types'

// 세트가 터미널 실습인지 문제 풀이(터미널 없음)인지: 기준은 세트의 sandbox_type 한 곳이다.
export function setKind(s: Pick<QuestSet, 'sandbox_type'>) {
  return s.sandbox_type === 'quiz'
    ? { icon: '📝', label: '문제 풀이', hint: '터미널 없이 풀어요' }
    : { icon: '💻', label: '터미널 실습', hint: '터미널에서 직접 해 봐요' }
}

// 아직 끝내지 않은 세트에 붙이는 "첫 완료 시 +N XP" 문구. 값의 기준은 서버(first_xp)다.
export const firstXpLabel = (s: Pick<QuestSet, 'first_xp'>) => (s.first_xp > 0 ? `+${s.first_xp} XP` : '')
