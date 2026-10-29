import type { Quest } from '../types'
import { formatDuration } from './useQuestTimer'

/** 한 문제를 푼 기록 (이번에 세트에 들어와서 푼 동안의 값) */
export interface QuestRecord {
    seconds: number
    hintUsed: boolean
    solutionUsed: boolean
    attempts: number
}

interface Props {
    setId: number | null
    quests: Quest[]
    records: Record<number, QuestRecord>
    saveState: 'idle' | 'saving' | 'saved' | 'failed'
    onRetrySave: () => void
    onHome: () => void
    onReview: (index: number) => void
}

function StatCard({ icon, label, value, sub }: { icon: string; label: string; value: string; sub?: string }) {
    return (
        <div className="border border-outline-variant bg-surface-container p-4 flex-1 min-w-0">
            <div className="flex items-center gap-1.5 font-sans text-label-caps text-on-surface-variant mb-2">
                <span className="material-symbols-outlined text-[16px]">{icon}</span>{label}
            </div>
            <div className="font-sans text-headline-md text-on-surface tabular-nums">{value}</div>
            {sub && <div className="font-sans text-label-caps text-on-surface-variant mt-1">{sub}</div>}
        </div>
    )
}

export function SetComplete({ setId, quests, records, saveState, onRetrySave, onHome, onReview }: Props) {
    const total = quests.length
    const done = quests.map((_, i) => records[i]).filter(Boolean)
    const allDone = done.length === total
    const totalSeconds = done.reduce((sum, r) => sum + r.seconds, 0)
    const noHint = done.filter((r) => !r.hintUsed).length
    const noSolution = done.filter((r) => !r.solutionUsed).length
    const maxSeconds = Math.max(1, ...done.map((r) => r.seconds))
    // 풀이를 봤거나 3번 이상 시도한 문제는 복습하면 좋다
    const review = quests
        .map((q, i) => ({ q, i, r: records[i] }))
        .filter(({ r }) => r && (r.solutionUsed || r.attempts >= 3))

    return (
        <div className="dark h-full flex flex-col bg-surface border-r border-outline-variant overflow-y-auto">
            <div className="px-6 py-8 flex flex-col items-center text-center border-b border-outline-variant">
                <div className="w-16 h-16 rounded-full bg-success/15 flex items-center justify-center mb-4">
                    <span className="material-symbols-outlined text-success text-[40px]" style={{ fontVariationSettings: "'FILL' 1" }}>
                        {allDone ? 'celebration' : 'task_alt'}
                    </span>
                </div>
                <h1 className="font-sans text-headline-lg text-on-surface">{allDone ? '축하합니다!' : '수고하셨어요'}</h1>
                <p className="font-sans text-body-md text-on-surface-variant mt-2">
                    {allDone
                        ? `세트${setId !== null ? ` #${setId}` : ''}의 모든 퀘스트(${total}개)를 끝냈어요.`
                        : `${total}개 중 ${done.length}개를 완료했어요. 건너뛴 문제는 아래에서 다시 풀어 볼 수 있어요.`}
                </p>
                {allDone && saveState !== 'idle' && (
                    <p className={`font-sans text-label-caps mt-3 flex items-center gap-1.5 ${saveState === 'failed' ? 'text-error' : 'text-success'}`}>
                        <span className="material-symbols-outlined text-[16px]">{saveState === 'failed' ? 'error' : saveState === 'saving' ? 'sync' : 'check'}</span>
                        {saveState === 'saving' && '완료 기록을 저장하는 중...'}
                        {saveState === 'saved' && '세트 완료 기록이 저장됐어요. 내 진행현황에서 볼 수 있어요.'}
                        {saveState === 'failed' && <>완료 기록을 저장하지 못했어요. <button onClick={onRetrySave} className="underline underline-offset-2">다시 저장</button></>}
                    </p>
                )}
            </div>

            <div className="p-6 space-y-6">
                <div className="flex gap-3">
                    <StatCard icon="timer" label="총 걸린 시간" value={formatDuration(totalSeconds)} sub={done.length > 0 ? `문제당 평균 ${formatDuration(Math.round(totalSeconds / done.length))}` : undefined} />
                    <StatCard icon="lightbulb" label="힌트 없이" value={`${noHint} / ${done.length}`} />
                    <StatCard icon="task_alt" label="풀이 안 보고" value={`${noSolution} / ${done.length}`} />
                </div>

                <section>
                    <h2 className="font-sans text-label-caps text-on-surface-variant mb-3">문제별 기록</h2>
                    <ul className="border border-outline-variant divide-y divide-outline-variant">
                        {quests.map((q, i) => {
                            const r = records[i]
                            return (
                                <li key={q.id} className="px-4 py-3">
                                    <div className="flex items-center justify-between gap-3">
                                        <button onClick={() => onReview(i)} className="font-sans text-body-md text-on-surface hover:text-primary text-left truncate transition-colors">
                                            <span className="text-on-surface-variant tabular-nums mr-2">{i + 1}.</span>{q.title}
                                        </button>
                                        <span className="font-mono text-code-sm text-on-surface-variant tabular-nums shrink-0">
                                            {r ? formatDuration(r.seconds) : '미완료'}
                                        </span>
                                    </div>
                                    {r && (
                                        <div className="mt-2 flex items-center gap-2">
                                            <div className="flex-1 h-1.5 bg-surface-container-highest">
                                                <div className="h-full bg-primary" style={{ width: `${Math.max(4, Math.round((r.seconds / maxSeconds) * 100))}%` }} />
                                            </div>
                                            {r.hintUsed && <span className="font-sans text-label-caps text-on-surface-variant border border-outline-variant px-1.5">힌트</span>}
                                            {r.solutionUsed && <span className="font-sans text-label-caps text-on-surface-variant border border-outline-variant px-1.5">풀이</span>}
                                            {r.attempts > 1 && <span className="font-sans text-label-caps text-on-surface-variant border border-outline-variant px-1.5">{r.attempts}번 시도</span>}
                                        </div>
                                    )}
                                </li>
                            )
                        })}
                    </ul>
                </section>

                {review.length > 0 && (
                    <section>
                        <h2 className="font-sans text-label-caps text-on-surface-variant mb-3">복습하면 좋은 문제</h2>
                        <p className="font-sans text-body-md text-on-surface-variant mb-3">풀이를 봤거나 여러 번 시도한 문제예요. 다시 한 번 직접 풀어 보면 오래 기억에 남아요.</p>
                        <div className="flex flex-wrap gap-2">
                            {review.map(({ q, i }) => (
                                <button key={q.id} onClick={() => onReview(i)} className="border border-outline-variant hover:border-primary hover:text-primary px-3 py-1.5 font-sans text-body-md text-on-surface transition-colors">
                                    {i + 1}. {q.title}
                                </button>
                            ))}
                        </div>
                    </section>
                )}

                <button onClick={onHome} className="w-full bg-success text-on-primary py-3 font-sans font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                    홈으로 <span className="material-symbols-outlined">home</span>
                </button>
            </div>
        </div>
    )
}
