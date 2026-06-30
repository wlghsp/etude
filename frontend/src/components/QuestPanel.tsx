import { useState } from 'react'
import type { Quest } from '../types'
import { gradeQuest } from '../api'

interface Props {
    quest: Quest
    containerId: string
    total: number
    index: number
    completedIndices: Set<number>
    onPrev: () => void
    onNext: () => void
    onHome: () => void
    onReset: () => void
    onComplete: (index: number) => void
}

export function QuestPanel({ quest, containerId, total, index, onPrev, onNext, onHome, onReset, onComplete }: Props) {
    const [result, setResult] = useState<boolean | null>(null)
    const [loading, setLoading] = useState(false)
    const ns = containerId ? `quest-${containerId.slice(0, 8)}` : '$NS'
    const resolve = (text: string) => text.replace(/\$NS/g, ns)
    const pct = Math.round(((index + 1) / total) * 100)

    const grade = async () => {
        setLoading(true)
        try {
            const data = await gradeQuest(containerId, quest.id)
            setResult(data.passed)
            if (data.passed) onComplete(index)
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
                        <span className="font-mono text-label-caps text-on-surface-variant">{index + 1} / {total}</span>
                        <h1 className="font-mono text-headline-lg text-on-surface truncate">{quest.title}</h1>
                    </div>
                    <div className="flex items-center gap-1 shrink-0">
                        <button onClick={onPrev} disabled={index === 0} title="이전" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center font-mono text-label-caps transition-colors disabled:opacity-30 disabled:cursor-default">
                            <span className="material-symbols-outlined text-[18px]">chevron_left</span>이전
                        </button>
                        <button onClick={handleNext} disabled={index === total - 1} title="다음" className="border border-outline-variant hover:bg-surface-container-high px-3 py-1.5 flex items-center font-mono text-label-caps transition-colors disabled:opacity-30 disabled:cursor-default">
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
                    {/* Description */}
                    <div className="border border-outline-variant bg-surface-container p-4">
                        <h3 className="font-mono text-label-caps text-primary mb-2">설명</h3>
                        <p className="font-mono text-body-md text-on-surface leading-relaxed">{resolve(quest.description)}</p>
                    </div>

                    {/* Hint / Solution */}
                    <div className="flex gap-2">
                        <details className="flex-1">
                            <summary className="border border-outline-variant hover:bg-surface-container-high py-2 px-3 font-mono text-label-caps cursor-pointer text-center transition-all list-none">
                                힌트 보기
                            </summary>
                            <div className="mt-2 border border-outline-variant border-l-4 border-l-primary bg-surface-container-low p-4">
                                <p className="font-mono text-body-md text-on-surface-variant">{resolve(quest.hint ?? '')}</p>
                            </div>
                        </details>
                        <details className="flex-1">
                            <summary className="border border-outline-variant hover:bg-surface-container-high py-2 px-3 font-mono text-label-caps cursor-pointer text-center transition-all list-none">
                                풀이 보기
                            </summary>
                            <div className="mt-2 border border-outline-variant bg-surface-container-low p-4">
                                <p className="font-mono text-code-sm text-on-surface-variant">{resolve(quest.solution ?? '')}</p>
                            </div>
                        </details>
                    </div>

                    {/* Grade Button */}
                    <button
                        onClick={grade}
                        disabled={loading}
                        className="w-full py-3 bg-info text-white font-mono text-label-caps hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2"
                    >
                        <span className="material-symbols-outlined text-[16px]">check_circle</span>
                        {loading ? '채점 중...' : '채점하기'}
                    </button>

                    {/* Result */}
                    {result === false && (
                        <div className="border border-error/30 bg-error/5 p-4 flex items-center gap-3">
                            <span className="material-symbols-outlined text-error text-[20px]">cancel</span>
                            <p className="font-mono text-body-md text-error">아직이에요. 다시 시도해보세요.</p>
                        </div>
                    )}
                    {result === true && (
                        <div className="border border-success/30 bg-success/5 p-4 border-l-4 border-l-success">
                            <div className="flex items-center gap-3 mb-3">
                                <span className="material-symbols-outlined text-success" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>
                                <div>
                                    <h4 className="font-mono text-body-md font-bold text-success">퀘스트 완료!</h4>
                                    <p className="font-mono text-label-caps text-success/80">정답입니다</p>
                                </div>
                            </div>
                            {index < total - 1
                                ? <button onClick={handleNext} className="w-full bg-success text-on-primary py-3 font-mono font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
                                    다음 퀘스트 <span className="material-symbols-outlined">arrow_forward</span>
                                  </button>
                                : <button onClick={onHome} className="w-full bg-success text-on-primary py-3 font-mono font-bold hover:brightness-110 transition-all flex items-center justify-center gap-2">
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
