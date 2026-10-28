import { readFileSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

export interface Fixture {
    setId: number
    // order_index → 그 퀘스트를 풀어 내는 실행 가능한 셸 명령
    answers: Record<string, string>
    // 정답 상태가 초기 상태와 같아 상태 기반 채점으로는 무행동과 구분할 수 없는 퀘스트(order_index → 이유).
    // 이유를 반드시 적게 해서, 예외가 조용히 늘어나지 않게 한다.
    allowTriviallyPasses?: Record<string, string>
}

export const DEFAULT_FIXTURE_DIR = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../verify')

export function loadFixture(setId: number, dir: string = DEFAULT_FIXTURE_DIR): Fixture {
    const file = path.join(dir, `set${String(setId).padStart(2, '0')}.json`)

    let raw: string
    try {
        raw = readFileSync(file, 'utf8')
    } catch {
        throw new Error(`fixture를 읽을 수 없습니다: ${file}`)
    }

    let parsed: any
    try {
        parsed = JSON.parse(raw)
    } catch {
        throw new Error(`fixture가 올바른 JSON이 아닙니다: ${file}`)
    }

    if (parsed?.setId !== setId) throw new Error(`fixture의 setId(${parsed?.setId})가 ${setId}과 다릅니다: ${file}`)
    const answers = parsed.answers
    const valid = answers && typeof answers === 'object' && Object.values(answers).every((v) => typeof v === 'string' && v.trim() !== '')
    if (!valid) throw new Error(`fixture의 answers는 비어 있지 않은 문자열 맵이어야 합니다: ${file}`)

    const allow = parsed.allowTriviallyPasses
    if (allow !== undefined) {
        const validAllow = allow && typeof allow === 'object' && Object.values(allow).every((v) => typeof v === 'string' && v.trim() !== '')
        if (!validAllow) throw new Error(`fixture의 allowTriviallyPasses는 이유가 적힌 문자열 맵이어야 합니다: ${file}`)
    }

    return allow ? { setId, answers, allowTriviallyPasses: allow } : { setId, answers }
}
