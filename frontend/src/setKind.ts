import type { QuestSet } from './types'

// 세트가 터미널 실습인지 문제 풀이(터미널 없음)인지: 기준은 세트의 sandbox_type 한 곳이다.
export function setKind(s: Pick<QuestSet, 'sandbox_type'>) {
  return s.sandbox_type === 'quiz'
    ? { icon: '📝', label: '문제 풀이', hint: '터미널 없이 풀어요' }
    : { icon: '💻', label: '터미널 실습', hint: '터미널에서 직접 해 봐요' }
}
