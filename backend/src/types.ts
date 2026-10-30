export interface QuestSet {
  id: number
  title: string
  description: string
  sandbox_type: string
  category: string
  is_review: boolean
  time_limit_sec: number | null
  icon: string | null // 홈의 세트 길에 보이는 이모지
  unit_id: number | null
  unit_title: string | null
  unit_order: number | null
}

export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
  setup_cmd: string[] | null
  // 객관식이면 'choice' 와 선택지만 내보낸다. 정답과 해설은 서버만 안다 (docs/specs/spec_quiz_sets.md).
  kind: 'terminal' | 'choice'
  choices: string[] | null
  // 조건별 채점 결과를 보여 줄 조건의 이름들 (없으면 null)
  check_labels: string[] | null
}