import { checkCoverage, verifyQuest, type QuestResult, type SandboxFactory, type VerifyQuest } from './verify-quest.js'
import type { Fixture } from './fixtures.js'

// 알려진 예외(무행동 통과 허용)를 적용한다. 예외가 있는데 더 이상 무행동 통과가 아니면 예외가 낡은 것이므로 실패로 알린다.
function applyAllowance(result: QuestResult, reason: string | undefined): QuestResult {
    if (!reason) return result
    const base = { orderIndex: result.orderIndex, title: result.title }
    if (!result.ok && result.reason === 'trivially-passes') return { ...base, ok: true, note: reason }
    if (result.ok) return { ...base, ok: false, reason: 'stale-allowance', detail: '무행동 통과 예외가 있지만 이제 무행동이 실패한다. fixture의 allowTriviallyPasses에서 지워라' }
    return result
}

// 한 세트를 검증한다. fixture 누락과 남은 fixture도 실패 결과로 함께 돌려줘서 종료 코드에 반영된다.
export async function runSet(quests: VerifyQuest[], fixture: Fixture, factory: SandboxFactory): Promise<QuestResult[]> {
    const { missing, extra } = checkCoverage(quests.map((q) => q.orderIndex), fixture.answers)
    const results: QuestResult[] = []

    for (const quest of quests) {
        if (missing.includes(quest.orderIndex)) {
            results.push({ orderIndex: quest.orderIndex, title: quest.title, ok: false, reason: 'no-fixture', detail: '정답 fixture가 없다' })
            continue
        }
        const result = await verifyQuest(quest, fixture.answers[String(quest.orderIndex)]!, factory)
        results.push(applyAllowance(result, fixture.allowTriviallyPasses?.[String(quest.orderIndex)]))
    }
    for (const orderIndex of extra) {
        results.push({ orderIndex, title: '(퀘스트 없음)', ok: false, reason: 'orphan-fixture', detail: '대응하는 퀘스트가 없는 fixture다' })
    }

    return results.sort((a, b) => a.orderIndex - b.orderIndex)
}
