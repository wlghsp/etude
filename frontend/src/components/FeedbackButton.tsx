import { useEffect, useState } from 'react'
import { FEEDBACK_MAX_IMAGES, submitFeedback } from '../api/feedback'
import { token } from '../api/base'
import { shrinkImage } from './feedbackImage'
import { useModalLock } from './useModalLock'

interface Props {
    page: string
    questId?: number | null
    questSetId?: number | null
    inline?: boolean // true 면 화면에 고정하지 않고 놓은 자리에 그대로 둔다 (문제 풀이 화면 헤더처럼). 아니면 상단 바의 소리 버튼(오른쪽 끝, 폭 42px) 왼쪽에 고정한다
}

export function FeedbackButton({ page, questId, questSetId, inline = false }: Props) {
    const [open, setOpen] = useState(false)
    const [body, setBody] = useState('')
    const [loading, setLoading] = useState(false)
    const [toast, setToast] = useState(false)
    const [images, setImages] = useState<{ file: File; url: string }[]>([])
    const [error, setError] = useState('')
    const loggedIn = !!token.get() // 이미지 첨부는 로그인한 사용자만 (글만 보내는 것은 누구나)
    useModalLock(open)

    function clearImages() { setImages((prev) => { prev.forEach((i) => URL.revokeObjectURL(i.url)); return [] }) }
    function removeImage(url: string) {
        setImages((prev) => { URL.revokeObjectURL(url); return prev.filter((i) => i.url !== url) })
    }
    async function addFiles(list: FileList | File[]) {
        if (!loggedIn) return
        const picked = Array.from(list).filter((f) => /^image\/(png|jpeg|webp)$/.test(f.type))
        if (picked.length < Array.from(list).length) setError('PNG, JPEG, WebP 이미지만 첨부할 수 있어요.')
        else setError('')
        const room = FEEDBACK_MAX_IMAGES - images.length
        if (picked.length > room) setError(`이미지는 최대 ${FEEDBACK_MAX_IMAGES}장까지 첨부할 수 있어요.`)
        const shrunk = await Promise.all(picked.slice(0, Math.max(room, 0)).map(shrinkImage))
        setImages((prev) => [...prev, ...shrunk.map((file) => ({ file, url: URL.createObjectURL(file) }))].slice(0, FEEDBACK_MAX_IMAGES))
    }

    // 닫으면 쓰던 내용도 비운다. 긴 글을 실수로 날리지 않도록 바깥을 눌러서는 글이 없을 때만 닫는다.
    function close() { setOpen(false); setBody(''); setError(''); clearImages() }

    useEffect(() => {
        if (!open) return
        const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') close() }
        window.addEventListener('keydown', onKey)
        return () => window.removeEventListener('keydown', onKey)
    }, [open])

    async function handleSubmit() {
        if (!body.trim() || loading) return
        setLoading(true)
        setError('')
        try {
            await submitFeedback({ page, questId, questSetId, body, images: images.map((i) => i.file) })
            close()
            setToast(true)
            setTimeout(() => setToast(false), 2000)
        } catch (e) {
            setError(e instanceof Error ? e.message : '전송에 실패했어요.') // 쓴 글과 이미지는 그대로 둔다
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
                className={`${inline ? '' : 'fixed top-[11px] right-[72px] z-50'} flex items-center gap-1.5 rounded-lg px-3 py-1.5 border border-outline-variant bg-surface hover:border-rose/60 hover:bg-rose/10 hover:text-rose font-sans text-label-caps text-on-surface-variant transition-colors`}
            >
                <span className="material-symbols-outlined text-[16px]">feedback</span>
                피드백
            </button>

            {/* 모달 */}
            {open && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70" role="dialog" aria-modal="true" onClick={() => { if (!body.trim() && images.length === 0) close() }}>
                    <div className="fx-modal rounded-2xl border border-outline-variant bg-surface-container-low shadow-2xl w-full max-w-[480px] p-6 flex flex-col gap-4" onClick={(e) => e.stopPropagation()}>
                        <div className="flex items-center justify-between">
                            <h2 className="flex items-center gap-2.5 font-sans text-body-lg font-bold text-on-surface"><span className="flex h-8 w-8 items-center justify-center rounded-lg bg-rose/15"><span className="material-symbols-outlined text-[20px] text-rose">rate_review</span></span>피드백 보내기</h2>
                            <button onClick={close} className="rounded-lg p-1 text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-colors" aria-label="닫기">
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
                            onPaste={(e) => {
                                const files = Array.from(e.clipboardData.files).filter((f) => f.type.startsWith('image/'))
                                if (files.length > 0 && loggedIn) { e.preventDefault(); void addFiles(files) }
                            }}
                            onDrop={(e) => { if (e.dataTransfer.files.length > 0) { e.preventDefault(); void addFiles(e.dataTransfer.files) } }}
                            onDragOver={(e) => e.preventDefault()}
                            className="w-full rounded-lg bg-surface border border-outline-variant px-3 py-2.5 font-sans text-body-md text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-info focus:ring-2 focus:ring-info/30 transition-shadow resize-none"
                        />
                        <div className="-mt-2 flex justify-between font-sans text-code-sm text-on-surface-variant">
                            <span>⌘/Ctrl + Enter 로 제출</span>
                            <span className="tabular-nums">{body.length} / 1000</span>
                        </div>
                        {loggedIn ? (
                            <div className="flex flex-col gap-2">
                                <div className="flex flex-wrap items-center gap-2">
                                    {images.map((img) => (
                                        <div key={img.url} className="relative h-16 w-16 overflow-hidden rounded-lg border border-outline-variant">
                                            <img src={img.url} alt="첨부 이미지 미리보기" className="h-full w-full object-cover" />
                                            <button onClick={() => removeImage(img.url)} aria-label="이미지 빼기" className="absolute right-0.5 top-0.5 flex h-5 w-5 items-center justify-center rounded-full bg-black/70 text-white hover:bg-black">
                                                <span className="material-symbols-outlined text-[14px]">close</span>
                                            </button>
                                        </div>
                                    ))}
                                    {images.length < FEEDBACK_MAX_IMAGES && (
                                        <label className="flex cursor-pointer items-center gap-1.5 rounded-lg border border-dashed border-outline-variant px-3 py-2 font-sans text-label-caps text-on-surface-variant hover:border-info hover:text-info transition-colors">
                                            <span className="material-symbols-outlined text-[16px]">add_photo_alternate</span>
                                            이미지 첨부
                                            <input type="file" accept="image/png,image/jpeg,image/webp" multiple className="hidden" onChange={(e) => { void addFiles(e.target.files ?? []); e.target.value = '' }} />
                                        </label>
                                    )}
                                    <span className="font-sans text-code-sm tabular-nums text-on-surface-variant">{images.length} / {FEEDBACK_MAX_IMAGES}</span>
                                </div>
                                <p className="font-sans text-code-sm text-on-surface-variant">붙여넣기(⌘/Ctrl + V)와 끌어놓기도 돼요. 화면에 비밀번호나 개인 정보가 보이면 가려서 올려 주세요.</p>
                            </div>
                        ) : (
                            <p className="font-sans text-code-sm text-on-surface-variant">로그인하면 이미지를 첨부할 수 있어요.</p>
                        )}
                        {error && <p role="alert" className="font-sans text-code-sm text-rose">{error}</p>}
                        <div className="flex justify-end gap-2">
                            <button
                                onClick={close}
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