export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
  setup_cmd: string[] | null
  // 객관식이면 'choice' 와 선택지 (정답과 해설은 서버만 안다)
  kind: 'terminal' | 'choice' | 'order' | 'fill' // order: 순서 맞추기(choices=섞인 카드), fill: 빈칸 채우기(choices=칩)
  choices: string[] | null
  docs: Array<{ title: string; url: string }> | null // 참고할 공식 문서 링크 (https)
  template: string | null // 빈칸 채우기의 명령 줄 틀 ({0}, {1} 이 빈칸)
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
  icon: string | null // 홈의 세트 길에 보이는 이모지
  unit_id: number | null
  unit_title: string | null
  unit_order: number | null
  quest_count: number
  first_xp: number // 처음 끝내면 얻는 XP (서버가 계산)
}