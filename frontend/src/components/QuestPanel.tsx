import { useState, useRef, useEffect } from 'react'
import type { Quest } from '../types'
import { gradeQuest, GradeRequestError } from '../api/quest'

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

interface Props {
    quest: Quest
    containerId: string
    sessionId: string
    total: number
    index: number
    completedIndices: Set<number>
    onPrev: () => void
    onNext: () => void
    onHome: () => void
    onReset: () => void
    onComplete: (index: number) => void
}

function gradeErrorMessage(err: unknown): string {
    const status = err instanceof GradeRequestError ? err.status : null
    if (status === 401) return '로그인이 만료되었습니다. 다시 로그인해 주세요.'
    if (status === 403) return '이 환경에서는 채점할 수 없습니다. 환경 초기화 후 다시 시도해 주세요.'
    if (status === 404) return '퀘스트를 찾을 수 없습니다.'
    return '채점 요청에 실패했습니다. 잠시 후 다시 시도해 주세요.'
}

export function QuestPanel({ quest, containerId, sessionId, total, index, onPrev, onNext, onHome, onReset, onComplete }: Props) {
    const startTimeRef = useRef(0)
    useEffect(() => { startTimeRef.current = Date.now() }, [])
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

    const [result, setResult] = useState<boolean | null>(null)
    const [loading, setLoading] = useState(false)
    const [gradeError, setGradeError] = useState<string | null>(null)
    const ns = containerId ? `quest-${containerId.slice(0, 8)}` : '$NS'
    const resolve = (text: string) => text.replace(/\$NS/g, ns)
    const pct = Math.round(((index + 1) / total) * 100)

    const grade = async () => {
        setLoading(true)
        setGradeError(null)
        try {
            const elapsedSec = Math.round((Date.now() - startTimeRef.current) / 1000)
            const data = await gradeQuest(containerId, quest.id, sessionId, elapsedSec, hintUsed, solutionUsed)
            setResult(data.passed)
            if (data.passed) onComplete(index)
        } catch (err) {
            setResult(null)
            setGradeError(gradeErrorMessage(err))
        } finally {
            setLoading(false)
        }
    }

    function handleReset() {
        if (window.confirm('환경을 초기화하면 터미널이 재시작됩니다. 계속할까요?')) {
            onReset()
        }
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
                        <button onClick={onPrev} disabled={index === 0} title="이전" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center font-sans text-label-caps transition-colors disabled:opacity-30 disabled:cursor-default">
                            <span className="material-symbols-outlined text-[18px]">chevron_left</span>이전
                        </button>
                        <button onClick={handleNext} disabled={index === total - 1} title="다음" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center font-sans text-label-caps transition-colors disabled:opacity-30 disabled:cursor-default">
                            다음<span className="material-symbols-outlined text-[18px]">chevron_right</span>
                        </button>
                        <button onClick={handleReset} title="환경 초기화" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center justify-center transition-colors ml-2">
                            <span className="material-symbols-outlined text-[18px] text-on-surface-variant">restart_alt</span>
                        </button>
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

                    {/* Grade Button */}
                    <button
                        onClick={grade}
                        disabled={loading || result === true}
                        className="w-full py-3 bg-info text-white font-sans text-label-caps hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2"
                    >
                        <span className="material-symbols-outlined text-[16px]">check_circle</span>
                        {loading ? '채점 중...' : '채점하기'}
                    </button>

                    {/* Result */}
                    {gradeError && (
                        <div className="border border-error/30 bg-error/5 p-4 flex items-center gap-3">
                            <span className="material-symbols-outlined text-error text-[20px]">error</span>
                            <p className="font-sans text-body-md text-error">{gradeError}</p>
                        </div>
                    )}
                    {result === false && (
                        <div className="border border-error/30 bg-error/5 p-4 flex items-center gap-3">
                            <span className="material-symbols-outlined text-error text-[20px]">cancel</span>
                            <p className="font-sans text-body-md text-error">아직이에요. 다시 시도해보세요.</p>
                        </div>
                    )}
                    {result === true && (
                        <div className="border border-success/30 bg-success/5 p-4 border-l-4 border-l-success">
                            <div className="flex items-center gap-3 mb-3">
                                <span className="material-symbols-outlined text-success" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>
                                <div>
                                    <h4 className="font-sans text-body-md font-bold text-success">퀘스트 완료!</h4>
                                    <p className="font-sans text-label-caps text-success/80">정답입니다</p>
                                </div>
                            </div>
                            {index < total - 1
                                ? <button onClick={handleNext} className="w-full bg-success text-on-primary py-3 font-sans font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                                    다음 퀘스트 <span className="material-symbols-outlined">arrow_forward</span>
                                  </button>
                                : <button onClick={onHome} className="w-full bg-success text-on-primary py-3 font-sans font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                                    세트 완료! 홈으로 <span className="material-symbols-outlined">home</span>
                                  </button>
                            }
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}
