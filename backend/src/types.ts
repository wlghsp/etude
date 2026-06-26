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
}