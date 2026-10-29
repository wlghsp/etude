export interface QuestSet {
  id: number
  title: string
  description: string
  sandbox_type: string
  category: string
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
}