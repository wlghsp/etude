import { useEffect, useState } from 'react'
import { submitFeedback } from '../api/feedback'

interface Props {
    page: string
    questId?: number | null
    questSetId?: number | null
    inline?: boolean // true 면 화면에 고정하지 않고 놓은 자리에 그대로 둔다 (문제 풀이 화면 헤더처럼 다른 버튼과 겹칠 때)
}

export function FeedbackButton({ page, questId, questSetId, inline = false }: Props) {
    const [open, setOpen] = useState(false)
    const [body, setBody] = useState('')
    const [loading, setLoading] = useState(false)
    const [toast, setToast] = useState(false)

    useEffect(() => {
        if (!open) return
        const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpen(false) }
        window.addEventListener('keydown', onKey)
        return () => window.removeEventListener('keydown', onKey)
    }, [open])

    async function handleSubmit() {
        if (!body.trim()) return
        setLoading(true)
        try {
            await submitFeedback({ page, questId, questSetId, body })
            setBody('')
            setOpen(false)
            setToast(true)
            setTimeout(() => setToast(false), 2000)
        } finally {
            setLoading(false)
        }
    }

    return (
        <>
            {/* 고정 버튼 */}
            <button
                onClick={() => setOpen(true)}
                title="피드백 보내기"
                className={`${inline ? '' : 'fixed top-4 right-4 z-50'} flex items-center gap-1.5 rounded-lg px-3 py-1.5 border border-outline-variant bg-surface hover:border-rose/60 hover:bg-rose/10 hover:text-rose font-sans text-label-caps text-on-surface-variant transition-colors`}
            >
                <span className="material-symbols-outlined text-[16px]">feedback</span>
                피드백
            </button>

            {/* 모달 */}
            {open && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm" role="dialog" aria-modal="true" onClick={() => setOpen(false)}>
                    <div className="fx-modal rounded-2xl border border-outline-variant bg-surface-container-low shadow-[0_0_40px_rgba(129,140,248,0.15)] w-full max-w-[480px] p-6 flex flex-col gap-4" onClick={(e) => e.stopPropagation()}>
                        <div className="flex items-center justify-between">
                            <h2 className="flex items-center gap-2.5 font-sans text-body-lg font-bold text-on-surface"><span className="flex h-8 w-8 items-center justify-center rounded-lg bg-rose/15"><span className="material-symbols-outlined text-[20px] text-rose">rate_review</span></span>피드백 보내기</h2>
                            <button onClick={() => setOpen(false)} className="rounded-lg p-1 text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-colors" aria-label="닫기">
                                <span className="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <p className="font-sans text-body-md text-on-surface-variant">오류나 개선 사항을 자유롭게 남겨주세요. 작은 의견도 큰 도움이 돼요 🙌</p>
                        <textarea
                            value={body}
                            onChange={e => setBody(e.target.value)}
                            maxLength={1000}
                            rows={5}
                            autoFocus
                            placeholder="내용을 입력하세요..."
                            onKeyDown={(e) => { if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') handleSubmit() }}
                            className="w-full rounded-lg bg-surface border border-outline-variant px-3 py-2.5 font-sans text-body-md text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-info focus:ring-2 focus:ring-info/30 transition-shadow resize-none"
                        />
                        <div className="-mt-2 flex justify-between font-sans text-code-sm text-on-surface-variant">
                            <span>⌘/Ctrl + Enter 로 제출</span>
                            <span className="tabular-nums">{body.length} / 1000</span>
                        </div>
                        <div className="flex justify-end gap-2">
                            <button
                                onClick={() => setOpen(false)}
                                className="rounded-lg px-4 py-2 border border-outline-variant font-sans text-label-caps text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-colors"
                            >
                                취소
                            </button>
                            <button
                                onClick={handleSubmit}
                                disabled={!body.trim() || loading}
                                className="rounded-lg bg-gradient-to-r from-info to-accent px-4 py-2 font-sans text-label-caps font-semibold text-white shadow-[0_4px_16px_rgba(96,165,250,0.25)] hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-40 disabled:shadow-none disabled:cursor-not-allowed"
                            >
                                {loading ? '전송 중...' : '제출하기'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* 토스트 */}
            {toast && (
                <div className="fx-pop fixed bottom-6 left-1/2 -translate-x-1/2 z-50 flex items-center gap-2 rounded-lg px-4 py-2.5 bg-surface-container border border-success/40 font-sans text-label-caps text-on-surface shadow-lg" role="status">
                    <span className="material-symbols-outlined text-[18px] text-success" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>피드백이 전달됐습니다. 고맙습니다!
                </div>
            )}
        </>
    )
}