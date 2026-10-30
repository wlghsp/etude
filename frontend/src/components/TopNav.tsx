import { SoundToggle } from './SoundToggle'

interface Props {
    onHome: () => void
}

export function TopNav({ onHome }: Props) {
    return (
        <header className="fixed top-0 z-50 w-full h-14 bg-surface border-b border-outline-variant flex items-center px-gutter shrink-0">
            <button onClick={onHome} className="flex items-center gap-2 font-sans text-body-lg font-bold tracking-tighter text-on-surface hover:text-primary transition-colors">
                <span className="w-6 h-6 rounded-md bg-gradient-to-br from-info to-accent flex items-center justify-center text-[13px] font-extrabold text-white">E</span>
                OKESTRO TRAINING | Etude
            </button>
            <div className="ml-auto"><SoundToggle /></div>
        </header>
    )
}
