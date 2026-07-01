import { useState } from 'react'
import { submitFeedback } from '../api/feedback'

interface Props {
    page: string
    questId?: number | null
    questSetId?: number | null
}

export function FeedbackButton({ page, questId, questSetId }: Props) {
    const [open, setOpen] = useState(false)
    const [body, setBody] = useState('')
    const [loading, setLoading] = useState(false)
    const [toast, setToast] = useState(false)

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
                className="fixed top-4 right-4 z-50 flex items-center gap-1.5 px-3 py-1.5 border border-outline-variant bg-surface hover:bg-surface-container-high font-mono text-label-caps text-on-surface-variant transition-colors"
            >
                <span className="material-symbols-outlined text-[16px]">feedback</span>
                피드백
            </button>

            {/* 모달 */}
            {open && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
                    <div className="bg-surface border border-outline-variant w-[480px] p-6 flex flex-col gap-4">
                        <div className="flex items-center justify-between">
                            <h2 className="font-mono text-body-lg font-bold text-on-surface">피드백 보내기</h2>
                            <button onClick={() => setOpen(false)} className="text-on-surface-variant hover:text-on-surface">
                                <span className="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <p className="font-mono text-body-sm text-on-surface-variant">오류나 개선 사항을 자유롭게 남겨주세요.</p>
                        <textarea
                            value={body}
                            onChange={e => setBody(e.target.value)}
                            maxLength={1000}
                            rows={5}
                            placeholder="내용을 입력하세요..."
                            className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface resize-none focus:outline-none focus:border-primary"
                        />
                        <div className="flex justify-end gap-2">
                            <button
                                onClick={() => setOpen(false)}
                                className="px-4 py-2 border border-outline-variant font-mono text-label-caps text-on-surface-variant hover:bg-surface-container-high transition-colors"
                            >
                                취소
                            </button>
                            <button
                                onClick={handleSubmit}
                                disabled={!body.trim() || loading}
                                className="px-4 py-2 bg-primary font-mono text-label-caps text-on-primary hover:brightness-110 transition-all disabled:opacity-50"
                            >
                                {loading ? '전송 중...' : '제출하기'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* 토스트 */}
            {toast && (
                <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 px-4 py-2 bg-surface-container border border-outline-variant font-mono text-label-caps text-on-surface">
                    피드백이 전달됐습니다.
                </div>
            )}
        </>
    )
}