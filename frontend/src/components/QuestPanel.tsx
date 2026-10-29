import { useState } from 'react'
import type { Quest } from '../types'
import { gradeQuest, answerChoice, GradeRequestError } from '../api/quest'
import { useQuestTimer, formatClock, formatDuration } from './useQuestTimer'
import type { QuestRecord } from './SetComplete'
import { ConfirmModal } from './ConfirmModal'

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
}

function gradeErrorMessage(err: unknown): string {
    const status = err instanceof GradeRequestError ? err.status : null
    if (status === 401) return '로그인이 만료되었습니다. 다시 로그인해 주세요.'
    if (status === 403) return '이 환경에서는 채점할 수 없습니다. 환경 초기화 후 다시 시도해 주세요.'
    if (status === 404) return '퀘스트를 찾을 수 없습니다.'
    return '채점 요청에 실패했습니다. 잠시 후 다시 시도해 주세요.'
}

export function QuestPanel({ quest, setId, containerId, sessionId, total, index, completedIndices, onPrev, onNext, onFinish, onReset, onComplete }: Props) {
    const timer = useQuestTimer(sessionId, quest.id)
    const [finalSeconds, setFinalSeconds] = useState<number | null>(null)
    const [failedAttempts, setFailedAttempts] = useState(0)
    const [hintUsed, setHintUsed] = useState(false)
    const [solutionUsed, setSolutionUsed] = useState(false)
    const [hintOpen, setHintOpen] = useState(false)
    const [solutionOpen, setSolutionOpen] = useState(false)

    const toggleHint = () => {
        setHintOpen(open => !open)
        setHintUsed(true)
    }
    const toggleSolution = () => {
        setSolutionOpen(open => !open)
        setSolutionUsed(true)
    }

    // 객관식 상태: 고른 번호, 이미 틀린 번호(다시 고를 수 없게), 정답을 맞힌 뒤에 받는 해설
    const isChoice = quest.kind === 'choice'
    const [selected, setSelected] = useState<number | null>(null)
    const [wrongChoices, setWrongChoices] = useState<Set<number>>(new Set())
    const [explanation, setExplanation] = useState<string | null>(null)
    const [result, setResult] = useState<boolean | null>(null)
    const [loading, setLoading] = useState(false)
    const [gradeError, setGradeError] = useState<string | null>(null)
    const [resetConfirmOpen, setResetConfirmOpen] = useState(false)
    const ns = containerId ? `quest-${containerId.slice(0, 8)}` : '$NS'
    const resolve = (text: string) => text.replace(/\$NS/g, ns)
    const pct = Math.round(((index + 1) / total) * 100)
    const allDone = completedIndices.size >= total

    const grade = async () => {
        setLoading(true)
        setGradeError(null)
        try {
            if (isChoice) {
                if (selected === null || setId === null) return
                const data = await answerChoice(setId, { questId: quest.id, sessionId, choiceIndex: selected, elapsedSec: timer.getSeconds(), hintUsed })
                setResult(data.passed)
                if (data.passed) {
                    setExplanation(data.explanation ?? null)
                    const seconds = timer.finish()
                    setFinalSeconds(seconds)
                    onComplete(index, { seconds, hintUsed, solutionUsed: false, attempts: failedAttempts + 1 })
                } else {
                    setWrongChoices((prev) => new Set(prev).add(selected))
                    setSelected(null)
                    setFailedAttempts((n) => n + 1)
                }
                return
            }
            const data = await gradeQuest(containerId, quest.id, sessionId, timer.getSeconds(), hintUsed, solutionUsed)
            setResult(data.passed)
            if (data.passed) {
                const seconds = timer.finish()
                setFinalSeconds(seconds)
                onComplete(index, { seconds, hintUsed, solutionUsed, attempts: failedAttempts + 1 })
            } else {
                setFailedAttempts((n) => n + 1)
            }
        } catch (err) {
            setResult(null)
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
            {/* Progress Bar */}
            <div className="w-full h-[3px] bg-surface-container-highest shrink-0">
                <div className="h-full bg-primary transition-all duration-300" style={{ width: `${pct}%` }} />
            </div>

            {/* Header: quest index + title + controls */}
            <div className="px-6 py-4 border-b border-outline-variant shrink-0">
                <div className="flex items-center justify-between gap-4">
                    <div className="flex-1 min-w-0">
                        <span className="font-sans text-label-caps text-on-surface-variant">{index + 1} / {total}</span>
                        <h1 className="font-sans text-headline-lg text-on-surface truncate">{quest.title}</h1>
                    </div>
                    <div className="flex items-center gap-1 shrink-0">
                        <div
                            title="이 문제를 푸는 데 쓴 시간 (탭이 보일 때만 셉니다)"
                            className={`flex items-center gap-1.5 border px-3 py-1.5 mr-2 ${finalSeconds !== null ? 'border-success/50 bg-success/10 text-success' : 'border-outline-variant bg-surface-container text-on-surface'}`}
                        >
                            <span className={`material-symbols-outlined text-[20px] ${finalSeconds !== null ? 'text-success' : 'text-primary'}`}>timer</span>
                            <span className="font-mono text-body-lg font-semibold tabular-nums">{formatClock(finalSeconds ?? timer.seconds)}</span>
                        </div>
                        <button onClick={onPrev} disabled={index === 0} title="이전" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center font-sans text-label-caps transition-colors disabled:opacity-30 disabled:cursor-default">
                            <span className="material-symbols-outlined text-[18px]">chevron_left</span>이전
                        </button>
                        <button onClick={handleNext} disabled={index === total - 1} title="다음" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center font-sans text-label-caps transition-colors disabled:opacity-30 disabled:cursor-default">
                            다음<span className="material-symbols-outlined text-[18px]">chevron_right</span>
                        </button>
                        {!isChoice && (
                            <button onClick={() => setResetConfirmOpen(true)} title="환경 초기화" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center justify-center transition-colors ml-2">
                                <span className="material-symbols-outlined text-[18px] text-on-surface-variant">restart_alt</span>
                            </button>
                        )}
                    </div>
                </div>
            </div>

            {/* Scrollable Content */}
            <div className="p-6 flex-1 overflow-y-auto">
                <div className="space-y-4">
                    {/* 설명은 항상 보이고, 힌트·풀이는 설명 아래에서 접고 펼친다 (읽으면서 함께 볼 수 있게) */}
                    <div className="border border-outline-variant bg-surface-container p-4">
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
                                        className={`w-full flex items-start gap-3 text-left border px-4 py-3 transition-colors ${
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

                    <div className="border border-outline-variant">
                        <button onClick={toggleHint} aria-expanded={hintOpen} className="w-full flex items-center justify-between px-4 py-3 font-sans text-label-caps text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors">
                            <span className="flex items-center gap-2"><span className="material-symbols-outlined text-[18px]">lightbulb</span>힌트 {hintOpen ? '접기' : '보기'}</span>
                            <span className="material-symbols-outlined text-[18px]">{hintOpen ? 'expand_less' : 'expand_more'}</span>
                        </button>
                        {hintOpen && (
                            <div className="border-t border-outline-variant bg-surface-container p-4">
                                <p className="font-sans text-body-md text-on-surface-variant leading-7 break-words whitespace-pre-wrap"><RichText text={resolve(quest.hint ?? '')} /></p>
                            </div>
                        )}
                    </div>

                    {!isChoice && (
                        <div className="border border-outline-variant">
                            <button onClick={toggleSolution} aria-expanded={solutionOpen} className="w-full flex items-center justify-between px-4 py-3 font-sans text-label-caps text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors">
                                <span className="flex items-center gap-2"><span className="material-symbols-outlined text-[18px]">task_alt</span>풀이 {solutionOpen ? '접기' : '보기'}<span className="font-normal text-on-surface-variant/70">(열면 풀이 사용으로 기록됩니다)</span></span>
                                <span className="material-symbols-outlined text-[18px]">{solutionOpen ? 'expand_less' : 'expand_more'}</span>
                            </button>
                            {solutionOpen && (
                                <div className="border-t border-outline-variant bg-surface-container p-4">
                                    <pre className="font-mono text-code-sm text-on-surface-variant break-words whitespace-pre-wrap">{resolve(quest.solution ?? '')}</pre>
                                </div>
                            )}
                        </div>
                    )}

                    {allDone && result !== true && (
                        <button onClick={onFinish} className="w-full border border-success/50 bg-success/10 text-success py-3 font-sans font-bold hover:bg-success/20 transition-colors flex items-center justify-center gap-2">
                            <span className="material-symbols-outlined text-[20px]">emoji_events</span>모든 퀘스트 완료 · 결과 보기
                        </button>
                    )}

                    {/* Grade Button */}
                    <button
                        onClick={grade}
                        disabled={loading || result === true || (isChoice && selected === null)}
                        className="w-full py-3 bg-info text-white font-sans text-label-caps hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2"
                    >
                        <span className="material-symbols-outlined text-[16px]">check_circle</span>
                        {loading ? '채점 중...' : isChoice ? '정답 확인' : '채점하기'}
                    </button>

                    {/* Result */}
                    {gradeError && (
                        <div className="border border-error/30 bg-error/5 p-4 flex items-center gap-3">
                            <span className="material-symbols-outlined text-error text-[20px]">error</span>
                            <p className="font-sans text-body-md text-error">{gradeError}</p>
                        </div>
                    )}
                    {result === false && (
                        <div key={`fail-${failedAttempts}`} className="fx-shake fx-glow-error border-2 border-error bg-error/10 p-4 flex items-center gap-3">
                            <span className="material-symbols-outlined text-error text-[34px] shrink-0" style={{ fontVariationSettings: "'FILL' 1" }}>cancel</span>
                            <div>
                                <p className="font-sans text-body-lg font-bold text-error">틀렸어요</p>
                                <p className="font-sans text-body-md text-on-surface-variant">
                                    {isChoice ? '틀린 선택지는 지워졌어요. 다른 선택지를 골라 보세요.' : '완료 조건을 다시 확인하고 한 번 더 시도해 보세요.'}
                                    {failedAttempts >= 2 && !hintUsed && ' 막히면 힌트를 열어 볼 수 있어요.'}
                                </p>
                            </div>
                        </div>
                    )}
                    {result === true && (
                        <div className="fx-glow-success relative overflow-hidden border border-success/40 bg-success/10 p-4 border-l-4 border-l-success">
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
                            {explanation && (
                                <div className="relative mb-4 border border-success/30 bg-surface-container p-4">
                                    <div className="font-sans text-label-caps text-success mb-2 flex items-center gap-1.5"><span className="material-symbols-outlined text-[16px]">menu_book</span>해설</div>
                                    <p className="font-sans text-body-md text-on-surface leading-7 break-words whitespace-pre-wrap"><RichText text={resolve(explanation)} /></p>
                                </div>
                            )}
                            {index < total - 1 && !allDone
                                ? <button onClick={handleNext} className="w-full bg-success text-on-primary py-3 font-sans font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                                    다음 퀘스트 <span className="material-symbols-outlined">arrow_forward</span>
                                  </button>
                                : <button onClick={onFinish} className="w-full bg-success text-on-primary py-3 font-sans font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                                    결과 보기 <span className="material-symbols-outlined">emoji_events</span>
                                  </button>
                            }
                        </div>
                    )}
                </div>
            </div>
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
