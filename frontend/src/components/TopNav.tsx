import { SoundToggle } from './SoundToggle'
import { Logo } from './Logo'
import { TOGGLE_NAV_EVENT } from './navDrawer'

interface Props {
    onHome: () => void
}

export function TopNav({ onHome }: Props) {
    return (
        <header className="fixed top-0 z-50 w-full h-14 bg-surface border-b border-outline-variant flex items-center px-gutter shrink-0">
            {/* 좁은 화면(md 미만)에서는 사이드바가 숨겨지므로, 이 버튼으로 SideNav 서랍을 연다 */}
            <button
                onClick={() => window.dispatchEvent(new Event(TOGGLE_NAV_EVENT))}
                aria-label="메뉴 열기"
                className="material-symbols-outlined -ml-2 mr-1 flex h-10 w-10 items-center justify-center rounded-lg text-[24px] text-on-surface-variant hover:bg-surface-container-highest hover:text-on-surface md:hidden"
            >menu</button>
            <button onClick={onHome} className="flex items-center gap-2 font-sans text-body-lg font-bold tracking-tighter text-on-surface hover:text-primary transition-colors">
                <Logo size={26} />
                Etude
            </button>
            <div className="ml-auto"><SoundToggle /></div>
        </header>
    )
}
