import { useEffect, useState } from 'react'
import type { Quest } from '../types'
import { formatDuration } from './useQuestTimer'
import { Celebration } from './Celebration'
import { fetchProgress } from '../api/user'
import { groupByUnit } from '../units'
import { playFanfare } from '../sound'

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
    // 이 세트를 처음 끝냈고 단원의 모든 세트가 완료되면 단원 완료를 축하한다
    const [unitDone, setUnitDone] = useState<{ number: number | null; title: string; category: string } | null>(null)
    const done = quests.map((_, i) => records[i]).filter(Boolean)
    const allDone = done.length === total
    const totalSeconds = done.reduce((sum, r) => sum + r.seconds, 0)
    const noHint = done.filter((r) => !r.hintUsed).length
    const noSolution = done.filter((r) => !r.solutionUsed).length
    const maxSeconds = Math.max(1, ...done.map((r) => r.seconds))
    // 풀이를 봤거나 3번 이상 시도한 문제는 복습하면 좋다
    const perfect = allDone && done.every((r) => !r.hintUsed && !r.solutionUsed)
    const firstTry = allDone && done.every((r) => r.attempts === 1)

    useEffect(() => {
        if (allDone) playFanfare()
    }, [allDone])

    useEffect(() => {
        if (!allDone || saveState !== 'saved' || setId === null) return
        let cancelled = false
        fetchProgress().then((rows) => {
            const me = rows.find((r) => r.questSetId === setId)
            if (cancelled || !me || me.unitId === null || me.completions.length !== 1) return
            const unitSets = rows.filter((r) => r.unitId === me.unitId)
            if (!unitSets.every((r) => r.completions.length > 0)) return
            const groups = groupByUnit(rows.filter((r) => r.category === me.category), (r) => ({ unitId: r.unitId, unitTitle: r.unitTitle, unitOrder: r.unitOrder }))
            const g = groups.find((x) => x.unitId === me.unitId)
            setUnitDone({ number: g?.number ?? null, title: me.unitTitle ?? '', category: me.category })
            playFanfare()
        }).catch(() => { /* 단원 축하가 없어도 세트 완료는 그대로다 */ })
        return () => { cancelled = true }
    }, [allDone, saveState, setId])

    const review = quests
        .map((q, i) => ({ q, i, r: records[i] }))
        .filter(({ r }) => r && (r.solutionUsed || r.attempts >= 3))

    return (
        <div className="dark h-full flex flex-col bg-surface border-r border-outline-variant overflow-y-auto">
            {allDone && <Celebration />}
            {unitDone && <Celebration count={140} seconds={8} />}
            <div className="px-6 py-8 flex flex-col items-center text-center border-b border-outline-variant bg-gradient-to-b from-accent/10 via-transparent to-transparent">
                <div className={`relative w-24 h-24 rounded-full flex items-center justify-center mb-4 ${allDone ? 'fx-bounce bg-gradient-to-br from-gold/30 to-rose/20 ring-4 ring-gold/40' : 'bg-success/15'}`}>
                    <span className={`material-symbols-outlined text-[52px] ${allDone ? 'text-gold fx-pop' : 'text-success'}`} style={{ fontVariationSettings: "'FILL' 1" }}>
                        {allDone ? 'emoji_events' : 'task_alt'}
                    </span>
                    {allDone && <>
                        <span className="fx-sparkle absolute -top-1 -right-2 material-symbols-outlined text-[26px] text-rose" style={{ fontVariationSettings: "'FILL' 1" }}>auto_awesome</span>
                        <span className="fx-sparkle absolute -bottom-1 -left-3 material-symbols-outlined text-[22px] text-sky" style={{ fontVariationSettings: "'FILL' 1", animationDelay: '0.5s' }}>auto_awesome</span>
                    </>}
                </div>
                <h1 className={`font-sans text-[34px] leading-[42px] font-extrabold ${allDone ? 'fx-shine-text' : 'text-on-surface'}`}>{allDone ? '세트 완료!' : '수고하셨어요'}</h1>
                <p className="font-sans text-body-md text-on-surface-variant mt-2">
                    {allDone
                        ? `세트${setId !== null ? ` #${setId}` : ''}의 모든 퀘스트(${total}개)를 끝냈어요.`
                        : `${total}개 중 ${done.length}개를 완료했어요. 건너뛴 문제는 아래에서 다시 풀어 볼 수 있어요.`}
                </p>
                {allDone && (perfect || firstTry) && (
                    <div className="mt-4 flex flex-wrap justify-center gap-2">
                        {perfect && <span className="fx-pop inline-flex items-center gap-1.5 rounded-full border border-gold/50 bg-gold/10 px-3 py-1 font-sans text-label-caps text-gold"><span className="material-symbols-outlined text-[16px]" style={{ fontVariationSettings: "'FILL' 1" }}>workspace_premium</span>퍼펙트 · 힌트·풀이 없이 모두</span>}
                        {firstTry && <span className="fx-pop inline-flex items-center gap-1.5 rounded-full border border-sky/50 bg-sky/10 px-3 py-1 font-sans text-label-caps text-sky" style={{ animationDelay: '0.15s' }}><span className="material-symbols-outlined text-[16px]" style={{ fontVariationSettings: "'FILL' 1" }}>bolt</span>전부 한 번에 성공</span>}
                    </div>
                )}
                {unitDone && (
                    <div className="fx-pop mt-5 w-full max-w-[420px] rounded-md border-2 border-accent bg-accent/10 px-5 py-4" style={{ animationDelay: '0.3s' }}>
                        <p className="font-sans text-label-caps text-accent flex items-center justify-center gap-1.5"><span className="material-symbols-outlined text-[18px]" style={{ fontVariationSettings: "'FILL' 1" }}>military_tech</span>단원 완료!</p>
                        <p className="font-sans text-headline-md text-on-surface mt-1">{unitDone.category} {unitDone.number !== null ? `${unitDone.number}단원 · ` : ''}{unitDone.title}</p>
                        <p className="font-sans text-body-md text-on-surface-variant mt-1">이 단원의 모든 세트를 끝냈어요. 홈에서 다음 단원을 만나 보세요.</p>
                    </div>
                )}
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
