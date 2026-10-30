import { useEffect, useState } from "react";
import { changePassword } from "../api/auth";
import { useModalLock } from "./useModalLock";

interface Props {
    open: boolean
    onClose: () => void
}

export function ChangePasswordModal({ open, onClose }: Props) {
    const [currentPassword, setCurrentPassword] = useState('')
    const [newPassword, setNewPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const [error, setError] = useState('')
    const [loading, setLoading] = useState(false)
    const [toast, setToast] = useState(false)
    useModalLock(open)

    function reset() {
        setCurrentPassword('')
        setNewPassword('')
        setConfirmPassword('')
        setError('')
    }

    function handleClose() {
        reset()
        onClose()
    }

    async function handleSubmit() {
        setError('')
        if (!currentPassword || !newPassword || !confirmPassword) {
            setError('모든 항목을 입력하세요.')
            return
        }
        if (newPassword !== confirmPassword) {
            setError('새 비밀번호가 서로 일치하지 않습니다.')
            return
        }

        setLoading(true)
        try {
            await changePassword(currentPassword, newPassword)
            handleClose()
            setToast(true)
            setTimeout(() => setToast(false), 2000)
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } catch (e: any) { 
            setError(e.message)
        } finally {
            setLoading(false)
        }
    }

    useEffect(() => {
        if (!open) return
        const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') handleClose() }
        window.addEventListener('keydown', onKey)
        return () => window.removeEventListener('keydown', onKey)
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [open])

    if (!open) return null

    return (
        <>
            <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70" role="dialog" aria-modal="true" onClick={handleClose}>
                <form className="fx-modal rounded-2xl border border-outline-variant bg-surface-container-low shadow-2xl w-full max-w-[400px] p-6 flex flex-col gap-4" onClick={(e) => e.stopPropagation()} onSubmit={(e) => { e.preventDefault(); handleSubmit() }}>
                    <div className="flex items-center justify-between">
                        <h2 className="flex items-center gap-2.5 font-sans text-body-lg font-bold text-on-surface"><span className="flex h-8 w-8 items-center justify-center rounded-lg bg-accent/15"><span className="material-symbols-outlined text-[20px] text-accent">lock_reset</span></span>비밀번호 변경</h2>
                        <button type="button" onClick={handleClose} className="rounded-lg p-1 text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-colors" aria-label="닫기">
                            <span className="material-symbols-outlined text-[20px]">close</span>
                        </button>
                    </div>

                    <input
                        type="password"
                        value={currentPassword}
                        onChange={e => setCurrentPassword(e.target.value)}
                        placeholder="현재 비밀번호"
                        autoComplete="current-password" autoFocus className="w-full rounded-lg bg-surface border border-outline-variant px-3 py-2.5 font-sans text-body-md text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-info focus:ring-2 focus:ring-info/30 transition-shadow"
                    />
                    <input
                        type="password"
                        value={newPassword}
                        onChange={e => setNewPassword(e.target.value)}
                        placeholder="새 비밀번호"
                        autoComplete="new-password" className="w-full rounded-lg bg-surface border border-outline-variant px-3 py-2.5 font-sans text-body-md text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-info focus:ring-2 focus:ring-info/30 transition-shadow"
                    />
                    <input
                        type="password"
                        value={confirmPassword}
                        onChange={e => setConfirmPassword(e.target.value)}
                        placeholder="새 비밀번호 확인"
                        autoComplete="new-password" className="w-full rounded-lg bg-surface border border-outline-variant px-3 py-2.5 font-sans text-body-md text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-info focus:ring-2 focus:ring-info/30 transition-shadow"
                    />

                    {error && (
                        <p className="flex items-center gap-2 rounded-lg border border-error/30 bg-error/5 px-3 py-2 font-sans text-body-md text-error" role="alert"><span className="material-symbols-outlined text-[18px]">error</span>{error}</p>
                    )}

                    <div className="flex justify-end gap-2">
                        <button
                            type="button"
                            onClick={handleClose}
                            className="rounded-lg px-4 py-2 border border-outline-variant font-sans text-label-caps text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-colors"
                        >
                            취소
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="rounded-lg bg-gradient-to-r from-info to-accent px-4 py-2 font-sans text-label-caps font-semibold text-white shadow-[0_4px_16px_rgba(96,165,250,0.25)] hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-40 disabled:shadow-none disabled:cursor-not-allowed"
                        >
                            {loading ? '변경 중...' : '변경하기'}
                        </button>
                    </div>
                </form>
            </div>

            {toast && (
                <div className="fx-pop fixed bottom-6 left-1/2 -translate-x-1/2 z-50 flex items-center gap-2 rounded-lg px-4 py-2.5 bg-surface-container border border-success/40 font-sans text-label-caps text-on-surface shadow-lg" role="status">
                    <span className="material-symbols-outlined text-[18px] text-success" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>비밀번호가 변경됐습니다.
                </div>
            )}
        </>
    )
}