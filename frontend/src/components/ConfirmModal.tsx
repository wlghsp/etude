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
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm" role="dialog" aria-modal="true" onClick={onCancel}>
            <div className="fx-modal rounded-2xl border border-outline-variant bg-surface-container-low shadow-[0_0_40px_rgba(129,140,248,0.15)] w-full max-w-[420px] p-6 flex flex-col gap-4" onClick={(e) => e.stopPropagation()}>
                <h2 className="font-sans text-body-lg font-bold text-on-surface">{title}</h2>
                <p className="font-sans text-body-md text-on-surface-variant leading-6">{message}</p>
                <div className="flex justify-end gap-2">
                    <button
                        autoFocus
                        onClick={onCancel}
                        className="rounded-lg bg-gradient-to-r from-info to-accent px-4 py-2 font-sans text-label-caps font-semibold text-white shadow-[0_4px_16px_rgba(96,165,250,0.25)] hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-40 disabled:shadow-none disabled:cursor-not-allowed"
                    >{cancelLabel}</button>
                    <button
                        onClick={onConfirm}
                        className="rounded-lg px-4 py-2 border border-outline-variant font-sans text-label-caps text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-colors"
                    >{confirmLabel}</button>
                </div>
            </div>
        </div>
    )
}
