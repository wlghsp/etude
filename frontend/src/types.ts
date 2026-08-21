export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  solution: string
  setupCmd: string[] | null
}

export interface QuestSet {
  id: number
  title: string
  description: string
  sandboxType: string
  category: string
}