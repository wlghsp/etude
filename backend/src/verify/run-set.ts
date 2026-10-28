import { checkCoverage, verifyQuest, type QuestResult, type SandboxFactory, type VerifyQuest } from './verify-quest.js'
import type { Fixture } from './fixtures.js'

// 한 세트를 검증한다. fixture 누락과 남은 fixture도 실패 결과로 함께 돌려줘서 종료 코드에 반영된다.
export async function runSet(quests: VerifyQuest[], fixture: Fixture, factory: SandboxFactory): Promise<QuestResult[]> {
    const { missing, extra } = checkCoverage(quests.map((q) => q.orderIndex), fixture.answers)
    const results: QuestResult[] = []

    for (const quest of quests) {
        if (missing.includes(quest.orderIndex)) {
            results.push({ orderIndex: quest.orderIndex, title: quest.title, ok: false, reason: 'no-fixture', detail: '정답 fixture가 없다' })
            continue
        }
        results.push(await verifyQuest(quest, fixture.answers[String(quest.orderIndex)]!, factory))
    }
    for (const orderIndex of extra) {
        results.push({ orderIndex, title: '(퀘스트 없음)', ok: false, reason: 'orphan-fixture', detail: '대응하는 퀘스트가 없는 fixture다' })
    }

    return results.sort((a, b) => a.orderIndex - b.orderIndex)
}
