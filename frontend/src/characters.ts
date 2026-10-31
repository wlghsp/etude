// 캐릭터 성장 정의(docs/specs/spec_character_growth.md). 레벨·XP 규칙의 기준은 서버이고, 여기서는 레벨에 맞는 모습만 정한다.
// 나중에 일러스트로 바꿀 때는 이 파일의 body 만 바꾸면 화면 코드는 그대로 쓴다.

export interface Stage { name: string; body: string; desc: string }

// 레벨 1~10 (서버 TITLES 와 같은 단계 수). 마지막 단계를 넘는 레벨은 마지막 모습을 쓴다.
export const STAGES: Stage[] = [
  { name: '알', body: '🥚', desc: '아직 알이에요. 첫 세트를 끝내면 깨어나요!' },
  { name: '아기 전사', body: '🐣', desc: '막 깨어난 아기 전사예요.' },
  { name: '꼬마 전사', body: '🐥', desc: '나무 막대를 들고 연습 중이에요.' },
  { name: '견습 전사', body: '🐤', desc: '첫 검을 손에 쥐었어요.' },
  { name: '전사', body: '🦆', desc: '제법 늠름한 전사가 됐어요.' },
  { name: '중갑 전사', body: '🦅', desc: '단단한 갑옷을 입었어요.' },
  { name: '정예 전사', body: '🦉', desc: '현장에서 믿고 맡길 정예예요.' },
  { name: '대장', body: '🦁', desc: '팀을 이끄는 대장이에요.' },
  { name: '영웅', body: '🐲', desc: '소문이 자자한 영웅이에요.' },
  { name: '전설의 전사', body: '🐉', desc: '전설로 남을 전사예요!' },
]

export const stageOf = (level: number): Stage => STAGES[Math.min(Math.max(level, 1), STAGES.length) - 1]!

// 분야를 정복(그 분야의 세트를 모두 끝냄)하면 붙는 장비. 분야가 늘면 한 줄 추가한다.
export const GEAR: Record<string, { icon: string; name: string }> = {
  '리눅스': { icon: '🗡️', name: '검' },
  '도커': { icon: '🛡️', name: '방패' },
  'k8s': { icon: '⛑️', name: '투구' },
  'Git': { icon: '🧣', name: '망토' },
  '미들웨어': { icon: '🎒', name: '도구 가방' },
  '데이터베이스': { icon: '📚', name: '지식 서고' },
  '인프라': { icon: '🔨', name: '망치' },
}

/** 모든 세트를 한 번 이상 끝낸 분야 이름들 */
export function conqueredCategories(rows: Array<{ category: string; completions: unknown[] }>): string[] {
  const total = new Map<string, { all: number; done: number }>()
  for (const r of rows) {
    const t = total.get(r.category) ?? { all: 0, done: 0 }
    t.all += 1
    if (r.completions.length > 0) t.done += 1
    total.set(r.category, t)
  }
  return [...total].filter(([, t]) => t.all > 0 && t.done === t.all).map(([c]) => c)
}
