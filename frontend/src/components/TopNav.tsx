interface Props {
    onHome: () => void
}

export function TopNav({ onHome }: Props) {
    return (
        <header className="fixed top-0 z-50 w-full h-14 bg-surface border-b border-outline-variant flex items-center px-gutter shrink-0">
            <button onClick={onHome} className="font-mono text-body-lg font-bold tracking-tighter text-on-surface hover:text-primary transition-colors">
                OKESTRO TRAINING | Etude
            </button>
        </header>
    )
}
