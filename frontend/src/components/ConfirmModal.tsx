import { useEffect } from "react";

interface Props {
    open: boolean
    title: string
    message: string
    confirmLabel: string
    cancelLabel: string
    onConfirm: () => void
    onCancel: () => void
}

export function ConfirmModal({ open, title, message, confirmLabel, cancelLabel, onConfirm, onCancel }: Props) {
    useEffect(() => {
        if (!open) return
        const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onCancel() }
        window.addEventListener('keydown', onKey)
        return () => window.removeEventListener('keydown', onKey)
    }, [open, onCancel])

    if (!open) return null

    return (
        <div className="fixed inset-0 z-[60] flex items-center justify-center bg-black/50" role="dialog" aria-modal="true">
            <div className="bg-surface border border-outline-variant w-[420px] p-6 flex flex-col gap-4">
                <h2 className="font-sans text-body-lg font-bold text-on-surface">{title}</h2>
                <p className="font-sans text-body-sm text-on-surface-variant">{message}</p>
                <div className="flex justify-end gap-2">
                    <button
                        autoFocus
                        onClick={onCancel}
                        className="bg-primary text-on-primary px-4 py-2 font-sans text-label-caps hover:opacity-90"
                    >{cancelLabel}</button>
                    <button
                        onClick={onConfirm}
                        className="border border-outline-variant px-4 py-2 font-sans text-label-caps text-on-surface hover:bg-surface-container-high"
                    >{confirmLabel}</button>
                </div>
            </div>
        </div>
    )
}
