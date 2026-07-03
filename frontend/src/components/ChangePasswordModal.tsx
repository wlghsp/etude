import { useState } from "react";
import { changePassword } from "../api/auth";

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

    if (!open) return null

    return (
        <>
            <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
                <div className="bg-surface border border-outline-variant w-[400px] p-6 flex flex-col gap-4">
                    <div className="flex items-center justify-between">
                        <h2 className="font-mono text-body-lg font-bold text-on-surface">비밀번호 변경</h2>
                        <button onClick={handleClose} className="text-on-surface-variant hover:text-on-surface">
                            <span className="material-symbols-outlined text-[20px]">close</span>
                        </button>
                    </div>

                    <input
                        type="password"
                        value={currentPassword}
                        onChange={e => setCurrentPassword(e.target.value)}
                        placeholder="현재 비밀번호"
                        className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface focus:outline-none focus:border-primary"
                    />
                    <input
                        type="password"
                        value={newPassword}
                        onChange={e => setNewPassword(e.target.value)}
                        placeholder="새 비밀번호"
                        className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface focus:outline-none focus:border-primary"
                    />
                    <input
                        type="password"
                        value={confirmPassword}
                        onChange={e => setConfirmPassword(e.target.value)}
                        placeholder="새 비밀번호 확인"
                        className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface focus:outline-none focus:border-primary"
                    />

                    {error && (
                        <p className="font-mono text-body-sm text-error">{error}</p>
                    )}

                    <div className="flex justify-end gap-2">
                        <button
                            onClick={handleClose}
                            className="px-4 py-2 border border-outline-variant font-mono text-label-caps text-on-surface-variant hover:bg-surface-container-high transition-colors"
                        >
                            취소
                        </button>
                        <button
                            onClick={handleSubmit}
                            disabled={loading}
                            className="px-4 py-2 bg-primary font-mono text-label-caps text-on-primary hover:brightness-110 transition-all disabled:opacity-50"
                        >
                            {loading ? '변경 중...' : '변경하기'}
                        </button>
                    </div>
                </div>
            </div>

            {toast && (
                <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 px-4 py-2 bg-surface-container border border-outline-variant font-mono text-label-caps text-on-surface">
                    비밀번호가 변경됐습니다.
                </div>
            )}
        </>
    )
}