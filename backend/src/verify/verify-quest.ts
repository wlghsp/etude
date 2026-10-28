// 채점 검증의 코어. Docker를 모르고, 샌드박스는 주입받는다 (docker-sandbox.ts가 실제 구현).

// 실제 채점(quest.ts execCheck)과 같은 값. 이보다 오래 걸리는 grade_cmd는 학습자에게도 실패다.
export const GRADE_TIMEOUT_MS = 15_000

export interface VerifyQuest {
    orderIndex: number
    title: string
    setupCmd: string[] | null
    gradeCmd: string[]
}

export interface VerifySandbox {
    // 명령을 실행하고 종료 코드를 돌려준다 (타임아웃이면 0이 아닌 값)
    exec: (cmd: string[], timeoutMs?: number) => Promise<number>
    dispose: () => Promise<void>
}

export type SandboxFactory = () => Promise<VerifySandbox>

export type FailureReason = 'setup-failed' | 'answer-rejected' | 'trivially-passes' | 'no-fixture' | 'orphan-fixture' | 'stale-allowance' | 'error'

export type QuestResult =
    | { orderIndex: number; title: string; ok: true; note?: string }
    | { orderIndex: number; title: string; ok: false; reason: FailureReason; detail: string }

// 퀘스트(order_index)마다 정답 fixture가 있는지, 퀘스트 없는 fixture가 남아 있지는 않은지 확인한다.
export function checkCoverage(orderIndexes: number[], answers: Record<string, string>) {
    const have = new Set(Object.keys(answers).map(Number))
    const want = new Set(orderIndexes)
    return {
        missing: orderIndexes.filter((i) => !have.has(i)),
        extra: [...have].filter((i) => !want.has(i)),
    }
}

class SetupFailed extends Error {}

async function withSandbox<T>(factory: SandboxFactory, run: (sandbox: VerifySandbox) => Promise<T>): Promise<T> {
    const sandbox = await factory()
    try {
        return await run(sandbox)
    } finally {
        await sandbox.dispose().catch(() => {})
    }
}

async function runSetup(sandbox: VerifySandbox, quest: VerifyQuest) {
    if (!quest.setupCmd) return
    const code = await sandbox.exec(quest.setupCmd)
    if (code !== 0) throw new SetupFailed(`setup_cmd 종료 코드 ${code}`)
}

// 같은 환경에서 두 가지를 확인한다. 검사마다 새 컨테이너를 쓴다.
//  1) 정답: setup → 정답 → grade가 통과해야 한다
//  2) 무행동: setup만 하고 grade가 실패해야 한다
export async function verifyQuest(quest: VerifyQuest, answer: string, factory: SandboxFactory): Promise<QuestResult> {
    const base = { orderIndex: quest.orderIndex, title: quest.title }
    try {
        const answerPassed = await withSandbox(factory, async (sandbox) => {
            await runSetup(sandbox, quest)
            await sandbox.exec(['sh', '-c', answer])
            return (await sandbox.exec(quest.gradeCmd, GRADE_TIMEOUT_MS)) === 0
        })
        if (!answerPassed) {
            return { ...base, ok: false, reason: 'answer-rejected', detail: '정답을 수행했는데 grade_cmd가 통과하지 않았다' }
        }

        const idlePassed = await withSandbox(factory, async (sandbox) => {
            await runSetup(sandbox, quest)
            return (await sandbox.exec(quest.gradeCmd, GRADE_TIMEOUT_MS)) === 0
        })
        if (idlePassed) {
            return { ...base, ok: false, reason: 'trivially-passes', detail: '아무것도 안 했는데 grade_cmd가 통과했다' }
        }

        return { ...base, ok: true }
    } catch (err) {
        if (err instanceof SetupFailed) return { ...base, ok: false, reason: 'setup-failed', detail: err.message }
        return { ...base, ok: false, reason: 'error', detail: err instanceof Error ? err.message : String(err) }
    }
}

export function summarize(results: QuestResult[]) {
    const failed = results.filter((r) => !r.ok).length
    return { passed: results.length - failed, failed, exitCode: failed === 0 ? 0 : 1 }
}
