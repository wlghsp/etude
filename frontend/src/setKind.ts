import type { QuestSet } from './types'

// 세트가 터미널 실습인지 문제 풀이인지: 기준은 세트의 실제 구성(터미널 문제 수)이다. sandbox_type 만 보면
// 터미널 문제가 일부뿐인 세트도 "실습"으로 보여 학습자가 속는다. 개수 정보가 없으면 유형만 본다.
export function setKind(s: Pick<QuestSet, 'sandbox_type'> & Partial<Pick<QuestSet, 'quest_count' | 'terminal_count'>>) {
  const quiz = { icon: '📝', label: '문제 풀이', hint: '터미널 없이 풀어요' }
  const practice = { icon: '💻', label: '터미널 실습', hint: '터미널에서 직접 해 봐요' }
  if (s.sandbox_type === 'quiz') return quiz
  const total = s.quest_count
  const term = s.terminal_count
  if (total === undefined || term === undefined || total <= 0) return practice
  if (term === 0) return { icon: '📝', label: '문제 풀이', hint: '터미널을 곁에 두고 풀어요' }
  if (term >= total) return practice
  return { icon: '🧩', label: '실습 + 문제 풀이', hint: `터미널 ${term}문제 · 문제 풀이 ${total - term}문제` }
}

// 아직 끝내지 않은 세트에 붙이는 "첫 완료 시 +N XP" 문구. 값의 기준은 서버(first_xp)다.
export const firstXpLabel = (s: Pick<QuestSet, 'first_xp'>) => (s.first_xp > 0 ? `+${s.first_xp} XP` : '')
