import { useEffect, useState } from 'react'
import type { Quest } from '../types'
import { gradeQuest, answerChoice, GradeRequestError } from '../api/quest'
import { useQuestTimer, formatClock, formatDuration } from './useQuestTimer'
import { useCountdown } from './useCountdown'
import type { QuestRecord } from './SetComplete'
import { ConfirmModal } from './ConfirmModal'
import { markSoundAsked, playFail, playSuccess, setSoundEnabled, soundAsked, soundEnabled } from '../sound'
import { FillQuestion, OrderQuestion } from './PickQuestions'

// `백틱`은 코드 모양으로, **별표 두 개**는 굵게 보여 준다 (명령어·파일 경로·값과 강조를 본문과 구분하기 위해).
function RichText({ text }: { text: string }) {
    return (
        <>
            {text.split(/(`[^`]+`|\*\*[^*]+\*\*)/g).map((part, i) => {
                if (part.length > 2 && part.startsWith('`') && part.endsWith('`'))
                    return <code key={i} className="font-mono text-[0.92em] bg-surface-container-highest text-primary px-1.5 py-0.5 rounded-sm break-all">{part.slice(1, -1)}</code>
                if (part.length > 4 && part.startsWith('**') && part.endsWith('**'))
                    return <strong key={i} className="font-semibold text-on-surface">{part.slice(2, -2)}</strong>
                return <span key={i}>{part}</span>
            })}
        </>
    )
}

// 정답을 맞혔을 때 박스 위에서 한 번 떨어지는 색종이 (고정된 값이라 다시 그려도 모양이 바뀌지 않는다)
const CONFETTI_COLORS = ['bg-success', 'bg-primary', 'bg-info', 'bg-on-surface']
function Confetti() {
    return (
        <div className="pointer-events-none absolute inset-0 overflow-hidden" aria-hidden="true">
            {Array.from({ length: 22 }, (_, i) => (
                <span
                    key={i}
                    className={`fx-confetti-piece ${CONFETTI_COLORS[i % CONFETTI_COLORS.length]}`}
                    style={{ '--x': `${(i * 37 + 7) % 96}%`, '--d': `${(i % 7) * 0.07}s`, '--r': `${(i * 53) % 180}deg` } as React.CSSProperties}
                />
            ))}
        </div>
    )
}

interface Props {
    quest: Quest
    setId: number | null
    containerId: string
    sessionId: string
    total: number
    index: number
    completedIndices: Set<number>
    onPrev: () => void
    onNext: () => void
    onFinish: () => void
    onReset: () => void
    onComplete: (index: number, record: QuestRecord) => void
    // 시간 제한 세트(시험형): 서버가 알려 준 제한과 마감 시각. 없으면 일반 세트. 마감되면 onExpire 를 부른다.
    run?: { limitSec: number; deadlineMs: number } | null
    onExpire?: () => void
}

function gradeErrorMessage(err: unknown): string {
    const status = err instanceof GradeRequestError ? err.status : null
    if (status === 401) return '로그인이 만료되었습니다. 다시 로그인해 주세요.'
    if (status === 403) return '이 환경에서는 채점할 수 없습니다. 환경 초기화 후 다시 시도해 주세요.'
    if (status === 404) return '퀘스트를 찾을 수 없습니다.'
    return '채점 요청에 실패했습니다. 잠시 후 다시 시도해 주세요.'
}

export function QuestPanel({ quest, setId, containerId, sessionId, total, index, completedIndices, onPrev, onNext, onFinish, onReset, onComplete, run = null, onExpire }: Props) {
    const timer = useQuestTimer(sessionId, quest.id)
    const left = useCountdown(run ? run.deadlineMs : null)
    const exam = run !== null
    useEffect(() => { if (exam && left === 0) onExpire?.() }, [exam, left, onExpire])
    const [finalSeconds, setFinalSeconds] = useState<number | null>(null)
    const [failedAttempts, setFailedAttempts] = useState(0)
    const [hintUsed, setHintUsed] = useState(false)
    const [solutionUsed, setSolutionUsed] = useState(false)
    // 문제 / 힌트 / 풀이를 탭으로 나눈다. 힌트·풀이는 탭을 여는 순간 사용으로 기록한다 (풀이는 처음 열 때 한 번 확인).
    const [tab, setTab] = useState<'task' | 'hint' | 'solution'>('task')
    const [solutionConfirmOpen, setSolutionConfirmOpen] = useState(false)
    const hasHint = Boolean(quest.hint?.trim())

    const openTab = (next: 'task' | 'hint' | 'solution') => {
        if (next === 'hint' && hasHint) setHintUsed(true)
        if (next === 'solution' && !solutionUsed) { setSolutionConfirmOpen(true); return }
        setTab(next)
    }
    const confirmSolution = () => {
        setSolutionUsed(true)
        setSolutionConfirmOpen(false)
        setTab('solution')
    }

    // 객관식 상태: 고른 번호, 이미 틀린 번호(다시 고를 수 없게), 정답을 맞힌 뒤에 받는 해설
    const isChoice = quest.kind === 'choice'
    const isOrder = quest.kind === 'order'
    const isFill = quest.kind === 'fill'
    const isPick = quest.kind !== 'terminal' // 컨테이너 없이 보기에서 답을 고르는 형식 (객관식·순서 맞추기·빈칸 채우기)
    const blankCount = isFill ? new Set(quest.template?.match(/\{\d+\}/g) ?? []).size : 0
    // 순서 맞추기: 놓은 카드 번호(놓은 순서), 빈칸 채우기: 빈칸마다 고른 칩 번호. 바꾸면 이전 채점 결과는 지운다.
    const [picks, setPicks] = useState<Array<number | null>>(() => (isFill ? Array(blankCount).fill(null) : []))
    const [pickResults, setPickResults] = useState<boolean[] | null>(null)
    const changePicks = (next: Array<number | null>) => { setPicks(next); setPickResults(null); if (result === false) setResult(null) }
    const pickReady = isOrder ? picks.length === (quest.choices?.length ?? 0) : isFill ? picks.length > 0 && picks.every((p) => p !== null) : false
    const [selected, setSelected] = useState<number | null>(null)
    const [wrongChoices, setWrongChoices] = useState<Set<number>>(new Set())
    const [explanation, setExplanation] = useState<string | null>(null)
    // 처음 정답을 맞혔을 때 효과음을 켜 볼지 한 번만 묻는다 (기본은 꺼짐)
    const [soundOffer, setSoundOffer] = useState(false)
    const offerSoundOnce = () => { if (!soundEnabled() && !soundAsked()) setSoundOffer(true) }
    const [result, setResult] = useState<boolean | null>(null)
    const [loading, setLoading] = useState(false)
    const [gradeError, setGradeError] = useState<string | null>(null)
    // 조건별 채점 결과 (조건 목록이 있는 문제만). 아직 채점하지 않았으면 null, 있으면 조건 순서대로 통과 여부
    const [checkResults, setCheckResults] = useState<boolean[] | null>(null)
    const checkLabels = !isPick ? quest.check_labels : null
    const [resetConfirmOpen, setResetConfirmOpen] = useState(false)
    const ns = containerId ? `quest-${containerId.slice(0, 8)}` : '$NS'
    const resolve = (text: string) => text.replace(/\$NS/g, ns)
    const allDone = completedIndices.size >= total

    const grade = async () => {
        setLoading(true)
        setGradeError(null)
        try {
            if (isPick) {
                if (setId === null || (isChoice && selected === null) || (!isChoice && !pickReady)) return
                const data = await answerChoice(setId, { questId: quest.id, sessionId, ...(isChoice ? { choiceIndex: selected! } : { answer: picks as number[] }), elapsedSec: timer.getSeconds(), hintUsed })
                setResult(data.passed)
                setPickResults(data.results ?? null)
                if (data.passed) playSuccess(); else playFail()
                if (data.passed) {
                    offerSoundOnce()
                    setExplanation(data.explanation ?? null)
                    const seconds = timer.finish()
                    setFinalSeconds(seconds)
                    onComplete(index, { seconds, hintUsed, solutionUsed: false, attempts: failedAttempts + 1 })
                } else {
                    if (isChoice) {
                        setWrongChoices((prev) => new Set(prev).add(selected!))
                        setSelected(null)
                    }
                    setFailedAttempts((n) => n + 1)
                }
                return
            }
            const data = await gradeQuest(containerId, quest.id, sessionId, timer.getSeconds(), hintUsed, solutionUsed)
            setResult(data.passed)
            setCheckResults(Array.isArray(data.checks) ? data.checks.map((c: { passed: boolean }) => c.passed) : null)
            if (data.passed) playSuccess(); else playFail()
            if (data.passed) {
                offerSoundOnce()
                const seconds = timer.finish()
                setFinalSeconds(seconds)
                onComplete(index, { seconds, hintUsed, solutionUsed, attempts: failedAttempts + 1 })
            } else {
                setFailedAttempts((n) => n + 1)
            }
        } catch (err) {
            setResult(null)
            if (err instanceof GradeRequestError && err.expired) { onExpire?.(); return }
            setGradeError(gradeErrorMessage(err))
        } finally {
            setLoading(false)
        }
    }

    function handleReset() {
        setResetConfirmOpen(false)
        onReset()
    }

    function handleNext() {
        onNext()
        setResult(null)
    }

    return (
        <div className="dark h-full flex flex-col bg-surface border-r border-outline-variant">
            {/* 문제 칸 진행 막대: 푼 문제는 초록, 지금 문제는 파랑 */}
            <div className="flex gap-1 px-6 pt-3 shrink-0" role="progressbar" aria-valuemin={0} aria-valuemax={total} aria-valuenow={completedIndices.size} aria-label="문제 진행">
                {Array.from({ length: total }, (_, i) => (
                    <div
                        key={i}
                        className={`h-1.5 flex-1 rounded-full transition-colors duration-300 ${completedIndices.has(i) ? 'bg-success' : i === index ? 'bg-info' : 'bg-surface-container-highest'} ${completedIndices.has(i) ? 'fx-seg-pop' : ''}`}
                    />
                ))}
            </div>

            {/* Header: quest index + title + controls */}
            <div className="px-6 py-4 border-b border-outline-variant shrink-0">
                <div className="flex items-center justify-between gap-4">
                    <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                            <span className="rounded-full border border-sky/40 bg-sky/10 px-2.5 py-0.5 font-sans text-label-caps text-sky tabular-nums">문제 {index + 1} / {total}</span>
                            {completedIndices.size > 0 && <span className="rounded-full border border-success/40 bg-success/10 px-2.5 py-0.5 font-sans text-label-caps text-success tabular-nums">✅ {completedIndices.size}개 해결</span>}
                        </div>
                        <h1 className="font-sans text-headline-lg text-on-surface truncate">{quest.title}</h1>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                        {run && left !== null ? (() => {
                            const ratio = left / run.limitSec
                            const tone = left <= 60 ? 'border-error/60 bg-error/10 text-error' : ratio <= 0.2 ? 'border-warning/60 bg-warning/10 text-warning' : 'border-sky/40 bg-sky/10 text-on-surface'
                            return (
                                <div title="시험 남은 시간 (세트 전체 기준)" role="timer" aria-label={`남은 시간 ${formatClock(left)}`} className={`flex flex-col gap-1 rounded-lg border px-3 py-1.5 ${tone}`}>
                                    <div className="flex items-center gap-2">
                                        <span className={`material-symbols-outlined text-[20px] ${left <= 60 ? 'animate-pulse' : ''}`}>hourglass_top</span>
                                        <span className={`font-mono text-body-lg font-semibold tabular-nums ${left <= 60 ? 'animate-pulse' : ''}`}>{formatClock(left)}</span>
                                    </div>
                                    <div className="h-1 rounded-full bg-black/30 overflow-hidden"><div className="h-full rounded-full bg-current transition-all duration-300" style={{ width: `${Math.round(ratio * 100)}%` }} /></div>
                                </div>
                            )
                        })() : (
                        <div
                            title="이 문제를 푸는 데 쓴 시간 (탭이 보일 때만 셉니다)"
                            className={`flex items-center gap-2 rounded-lg border px-3 py-1.5 ${finalSeconds !== null ? 'border-success/50 bg-success/10 text-success' : 'border-sky/40 bg-sky/10 text-on-surface'}`}
                        >
                            {finalSeconds === null && <span className="w-2 h-2 rounded-full bg-sky animate-pulse" aria-hidden="true" />}
                            <span className={`material-symbols-outlined text-[20px] ${finalSeconds !== null ? 'text-success' : 'text-sky'}`}>{finalSeconds !== null ? 'timer_off' : 'timer'}</span>
                            <span className="font-mono text-body-lg font-semibold tabular-nums">{formatClock(finalSeconds ?? timer.seconds)}</span>
                        </div>
                        )}
                        {!isPick && (
                            <button onClick={() => setResetConfirmOpen(true)} title="환경 초기화 (터미널을 처음 상태로)" className="rounded-lg border border-outline-variant hover:border-warning/60 hover:bg-warning/10 hover:text-warning text-on-surface-variant px-3 py-1.5 flex items-center gap-1 font-sans text-label-caps transition-colors">
                                <span className="material-symbols-outlined text-[18px]">restart_alt</span>초기화
                            </button>
                        )}
                    </div>
                </div>
            </div>

            {/* 탭: 문제 / 힌트 / 풀이 (한 번에 하나만 보여 각 내용이 길어져도 깔끔하다) */}
            <div role="tablist" className="flex gap-1 px-6 border-b border-outline-variant shrink-0">
                {([
                    { id: 'task', label: '문제', icon: 'assignment', show: true },
                    { id: 'hint', label: '힌트', icon: 'lightbulb', show: !exam },
                    { id: 'solution', label: '풀이', icon: 'task_alt', show: !isPick && !exam },
                ] as const).filter((t) => t.show).map((t) => (
                    <button
                        key={t.id}
                        role="tab"
                        aria-selected={tab === t.id}
                        onClick={() => openTab(t.id)}
                        className={`flex items-center gap-1.5 px-4 py-2.5 -mb-px border-b-2 font-sans text-label-caps transition-colors ${tab === t.id ? 'border-info text-on-surface' : 'border-transparent text-on-surface-variant hover:text-on-surface'}`}
                    >
                        <span className={`material-symbols-outlined text-[18px] ${t.id === 'hint' && hintUsed ? 'text-gold' : t.id === 'solution' && solutionUsed ? 'text-warning' : ''}`}>{t.icon}</span>
                        {t.label}
                        {t.id === 'hint' && hintUsed && <span className="w-1.5 h-1.5 rounded-full bg-gold" aria-label="힌트 사용함" />}
                        {t.id === 'solution' && solutionUsed && <span className="w-1.5 h-1.5 rounded-full bg-warning" aria-label="풀이 사용함" />}
                    </button>
                ))}
            </div>

            {/* Scrollable Content */}
            <div className="p-6 flex-1 overflow-y-auto">
                <div className="space-y-4">
                    {tab === 'task' && <>
                    {quest.docs && (
                        <div className="flex flex-wrap items-center gap-2" aria-label="참고 문서">
                            <span className="font-sans text-label-caps text-on-surface-variant">📖 참고 문서</span>
                            {quest.docs.map((d) => (
                                <a key={d.url} href={d.url} target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-1 rounded-full border border-info/40 bg-info/10 px-3 py-1 font-sans text-label-caps text-info hover:bg-info/20 transition-colors">
                                    {d.title}<span className="material-symbols-outlined text-[14px]" aria-hidden="true">open_in_new</span><span className="sr-only"> (새 탭에서 열림)</span>
                                </a>
                            ))}
                        </div>
                    )}
                    <div className="rounded-xl border border-outline-variant bg-surface-container p-4">
                        <p className="font-sans text-body-lg text-on-surface leading-7 break-words whitespace-pre-wrap"><RichText text={resolve(quest.description)} /></p>
                    </div>

                    {isChoice && quest.choices && (
                        <div role="radiogroup" aria-label="선택지" className="space-y-2">
                            {quest.choices.map((choice, i) => {
                                const isWrong = wrongChoices.has(i)
                                const isPicked = selected === i
                                const locked = result === true
                                return (
                                    <button
                                        key={i}
                                        role="radio"
                                        aria-checked={isPicked}
                                        disabled={isWrong || locked}
                                        onClick={() => setSelected(i)}
                                        className={`w-full flex items-start gap-3 text-left rounded-lg border px-4 py-3 transition-colors ${
                                            isPicked ? 'border-primary bg-primary/10'
                                            : isWrong ? 'border-error/40 bg-error/5 opacity-60'
                                            : 'border-outline-variant bg-surface-container hover:border-primary/60 hover:bg-surface-container-high'
                                        } disabled:cursor-default`}
                                    >
                                        <span className={`shrink-0 w-6 h-6 flex items-center justify-center font-sans text-label-caps border ${isPicked ? 'border-primary text-primary' : isWrong ? 'border-error/50 text-error' : 'border-outline-variant text-on-surface-variant'}`}>
                                            {'ABCDEFGH'[i]}
                                        </span>
                                        <span className={`flex-1 font-sans text-body-md leading-6 break-words whitespace-pre-wrap ${isWrong ? 'line-through text-on-surface-variant' : 'text-on-surface'}`}>
                                            <RichText text={resolve(choice)} />
                                        </span>
                                        {isWrong && <span className="material-symbols-outlined text-[18px] text-error shrink-0">close</span>}
                                    </button>
                                )
                            })}
                        </div>
                    )}

                    {isOrder && quest.choices && (
                        <OrderQuestion cards={quest.choices} value={picks as number[]} onChange={changePicks} results={pickResults} locked={result === true} renderText={(t) => <RichText text={resolve(t)} />} />
                    )}
                    {isFill && quest.choices && quest.template && (
                        <FillQuestion template={quest.template} chips={quest.choices} value={picks} onChange={changePicks} results={pickResults} locked={result === true} />
                    )}

                    {allDone && result !== true && (
                        <button onClick={onFinish} className="w-full rounded-lg border border-success/50 bg-success/10 text-success py-3 font-sans font-bold hover:bg-success/20 transition-colors flex items-center justify-center gap-2">
                            <span className="material-symbols-outlined text-[20px]">emoji_events</span>모든 퀘스트 완료 · 결과 보기
                        </button>
                    )}

                    {/* 완료 조건 체크리스트: 채점하면 조건마다 통과(초록)/미통과(빨강)가 표시된다 */}
                    {checkLabels && (
                        <div className="rounded-xl border border-outline-variant bg-surface-container p-4">
                            <div className="flex items-center justify-between mb-3">
                                <span className="font-sans text-label-caps text-on-surface-variant flex items-center gap-1.5"><span className="material-symbols-outlined text-[16px]">fact_check</span>완료 조건</span>
                                {checkResults && <span className="font-sans text-label-caps tabular-nums text-on-surface-variant">{checkResults.filter(Boolean).length}/{checkLabels.length} 통과</span>}
                            </div>
                            <ul className="space-y-2">
                                {checkLabels.map((label, i) => {
                                    const state = checkResults ? (checkResults[i] ? 'pass' : 'fail') : 'idle'
                                    return (
                                        <li key={label} className="flex items-start gap-2.5">
                                            <span
                                                key={`${label}-${state}`}
                                                className={`material-symbols-outlined text-[20px] shrink-0 ${state === 'pass' ? 'text-success fx-pop' : state === 'fail' ? 'text-error fx-pop' : 'text-on-surface-variant'}`}
                                                style={state !== 'idle' ? { fontVariationSettings: "'FILL' 1" } : undefined}
                                            >{state === 'pass' ? 'check_circle' : state === 'fail' ? 'cancel' : 'radio_button_unchecked'}</span>
                                            <span className={`font-sans text-body-md leading-6 ${state === 'fail' ? 'text-error' : state === 'pass' ? 'text-on-surface' : 'text-on-surface-variant'}`}>{label}</span>
                                        </li>
                                    )
                                })}
                            </ul>
                        </div>
                    )}

                    {/* Grade Button */}
                    <button
                        onClick={grade}
                        disabled={loading || result === true || (isChoice && selected === null) || (!isChoice && isPick && !pickReady)}
                        className="w-full py-3 rounded-lg bg-info text-white font-sans text-label-caps hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2"
                    >
                        <span className="material-symbols-outlined text-[16px]">check_circle</span>
                        {loading ? '채점 중...' : isOrder && !pickReady ? `카드를 모두 놓아 주세요 (${picks.length}/${quest.choices?.length ?? 0})` : isFill && !pickReady ? `빈칸을 모두 채워 주세요 (${picks.filter((p) => p !== null).length}/${picks.length})` : isChoice && selected === null ? '보기를 골라 주세요' : isPick ? '정답 확인' : '채점하기'}
                    </button>

                    {/* Result */}
                    {gradeError && (
                        <div className="border border-error/30 bg-error/5 p-4 flex items-center gap-3">
                            <span className="material-symbols-outlined text-error text-[20px]">error</span>
                            <p className="font-sans text-body-md text-error">{gradeError}</p>
                        </div>
                    )}
                    {result === false && (
                        <div key={`fail-${failedAttempts}`} className="fx-shake fx-glow-error rounded-xl border-2 border-error bg-error/10 p-4 flex items-center gap-3">
                            <span className="material-symbols-outlined text-error text-[34px] shrink-0" style={{ fontVariationSettings: "'FILL' 1" }}>cancel</span>
                            <div>
                                <p className="font-sans text-body-lg font-bold text-error">틀렸어요</p>
                                <p className="font-sans text-body-md text-on-surface-variant">
                                    {isChoice ? '틀린 선택지는 지워졌어요. 다른 선택지를 골라 보세요.' : isPick ? '빨간 칸을 눌러 바꾸고 다시 확인해 보세요. 초록 칸은 맞았어요.' : checkLabels ? '빨간 표시가 된 조건을 확인하고 다시 시도해 보세요.' : '문제에 적힌 결과가 만들어졌는지 확인하고 한 번 더 시도해 보세요.'}
                                    {failedAttempts >= 2 && !hintUsed && ' 막히면 힌트를 열어 볼 수 있어요.'}
                                </p>
                            </div>
                        </div>
                    )}
                    {result === true && (
                        <div className="fx-glow-success relative overflow-hidden rounded-xl border border-success/40 bg-success/10 p-4 border-l-4 border-l-success">
                            <Confetti />
                            <div className="relative flex items-center gap-3 mb-3">
                                <span className="fx-pop material-symbols-outlined text-success text-[36px]" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>
                                <div>
                                    <h4 className="font-sans text-body-md font-bold text-success">퀘스트 완료!</h4>
                                    <p className="font-sans text-label-caps text-success/80">
                                        정답입니다{finalSeconds !== null && ` · 걸린 시간 ${formatDuration(finalSeconds)}`}{hintUsed && ' · 힌트 사용'}{solutionUsed && ' · 풀이 사용'}
                                    </p>
                                </div>
                            </div>
                            {soundOffer && (
                                <div className="relative mb-3 flex items-center gap-3 rounded-lg border border-success/30 bg-surface-container px-3 py-2">
                                    <span className="material-symbols-outlined text-gold text-[20px]">volume_up</span>
                                    <p className="flex-1 font-sans text-body-md text-on-surface">정답 효과음(띠링!)이 있어요. 켜 볼까요? 위쪽 스피커 버튼으로 언제든 끌 수 있어요.</p>
                                    <button onClick={() => { setSoundEnabled(true); playSuccess(); markSoundAsked(); setSoundOffer(false) }} className="rounded-md bg-success text-on-primary px-3 py-1 font-sans text-label-caps font-bold hover:brightness-110">켜기</button>
                                    <button onClick={() => { markSoundAsked(); setSoundOffer(false) }} className="rounded-md border border-outline-variant px-3 py-1 font-sans text-label-caps text-on-surface-variant hover:bg-surface-container-high">괜찮아요</button>
                                </div>
                            )}
                            {explanation && (
                                <div className="relative mb-4 border border-success/30 bg-surface-container p-4">
                                    <div className="font-sans text-label-caps text-success mb-2 flex items-center gap-1.5"><span className="material-symbols-outlined text-[16px]">menu_book</span>해설</div>
                                    <p className="font-sans text-body-md text-on-surface leading-7 break-words whitespace-pre-wrap"><RichText text={resolve(explanation)} /></p>
                                </div>
                            )}
                            {index < total - 1 && !allDone
                                ? <button onClick={handleNext} className="w-full rounded-lg bg-success text-on-primary py-3 font-sans font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                                    다음 퀘스트 <span className="material-symbols-outlined">arrow_forward</span>
                                  </button>
                                : <button onClick={onFinish} className="w-full rounded-lg bg-success text-on-primary py-3 font-sans font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                                    결과 보기 <span className="material-symbols-outlined">emoji_events</span>
                                  </button>
                            }
                        </div>
                    )}
                    </>}

                    {tab === 'hint' && (
                        <div className="rounded-xl border border-outline-variant bg-surface-container p-4">
                            <div className="font-sans text-label-caps text-gold mb-3 flex items-center gap-1.5"><span className="material-symbols-outlined text-[16px]">lightbulb</span>힌트</div>
                            {hasHint
                                ? <p className="font-sans text-body-md text-on-surface-variant leading-7 break-words whitespace-pre-wrap"><RichText text={resolve(quest.hint ?? '')} /></p>
                                : <p className="font-sans text-body-md text-on-surface-variant">이 문제에는 힌트가 없어요.</p>}
                            <button onClick={() => setTab('task')} className="mt-4 border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 font-sans text-label-caps text-on-surface transition-colors">문제로 돌아가기</button>
                        </div>
                    )}

                    {tab === 'solution' && !isPick && (
                        <div className="border border-warning/40 bg-surface-container p-4">
                            <div className="font-sans text-label-caps text-warning mb-3 flex items-center gap-1.5"><span className="material-symbols-outlined text-[16px]">task_alt</span>풀이 (풀이 사용으로 기록됐어요)</div>
                            <pre className="font-mono text-code-sm text-on-surface-variant break-words whitespace-pre-wrap">{resolve(quest.solution ?? '')}</pre>
                            <button onClick={() => setTab('task')} className="mt-4 border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 font-sans text-label-caps text-on-surface transition-colors">문제로 돌아가기</button>
                        </div>
                    )}
                </div>
            </div>
            {/* 문제 이동: 풀기 전에는 "건너뛰기", 푼 뒤에는 초록 "다음" */}
            <nav aria-label="문제 이동" className="flex shrink-0 items-center justify-between border-t border-outline-variant px-6 py-3">
                <button onClick={onPrev} disabled={index === 0} className="flex items-center gap-1 font-sans text-label-caps text-info hover:underline disabled:opacity-30 disabled:no-underline disabled:cursor-default">
                    <span className="material-symbols-outlined text-[18px]">arrow_back</span>이전
                </button>
                <button
                    onClick={handleNext}
                    disabled={index === total - 1}
                    className={`flex items-center gap-1 font-sans text-label-caps transition-colors disabled:opacity-30 disabled:cursor-default ${completedIndices.has(index) ? 'rounded-lg bg-success px-4 py-1.5 font-bold text-on-primary hover:brightness-110' : 'text-info hover:underline'}`}
                >
                    {completedIndices.has(index) ? '다음' : '건너뛰기'}<span className="material-symbols-outlined text-[18px]">arrow_forward</span>
                </button>
            </nav>
            <ConfirmModal
                open={solutionConfirmOpen}
                title="풀이를 볼까요?"
                message="풀이를 열면 이 문제가 '풀이 사용'으로 기록돼요. 막혔다면 먼저 힌트를 보는 것도 좋아요."
                confirmLabel="풀이 보기"
                cancelLabel="더 풀어 볼게요"
                onConfirm={confirmSolution}
                onCancel={() => setSolutionConfirmOpen(false)}
            />
            <ConfirmModal
                open={resetConfirmOpen}
                title="환경 초기화"
                message="환경을 초기화하면 터미널이 재시작돼요. 계속할까요?"
                confirmLabel="초기화"
                cancelLabel="취소"
                onConfirm={handleReset}
                onCancel={() => setResetConfirmOpen(false)}
            />
        </div>
    )
}
