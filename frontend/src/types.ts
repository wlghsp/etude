export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
  setup_cmd: string[] | null
  // 객관식이면 'choice' 와 선택지 (정답과 해설은 서버만 안다)
  kind: 'terminal' | 'choice'
  choices: string[] | null
  // 조건별 채점 결과를 보여 줄 조건의 이름들 (없으면 null)
  check_labels: string[] | null
}

export interface QuestSet {
  id: number
  title: string
  description: string
  sandbox_type: string
  category: string
  is_review: boolean
  time_limit_sec: number | null
  unit_id: number | null
  unit_title: string | null
  unit_order: number | null
}