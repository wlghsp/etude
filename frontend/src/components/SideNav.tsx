type Page = 'home' | 'progress' | 'leaderboard'

interface Props {
    activePage: Page
    onHome: () => void
    onProgress: () => void
    onLeaderboard: () => void
    onLogout: () => void
}

export function SideNav({ activePage, onHome, onProgress, onLeaderboard, onLogout }: Props) {
    const item = (icon: string, label: string, page: Page, onClick: () => void) => {
        const active = activePage === page
        return active
            ? (
                <div className="flex items-center gap-3 text-primary border-l-2 border-primary pl-3 py-3">
                    <span className="material-symbols-outlined text-[22px]" style={{ fontVariationSettings: "'FILL' 1" }}>{icon}</span>
                    <span className="font-mono text-body-md font-semibold">{label}</span>
                </div>
            ) : (
                <button onClick={onClick} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-3 hover:text-on-surface hover:bg-surface-container-highest transition-all">
                    <span className="material-symbols-outlined text-[22px]">{icon}</span>
                    <span className="font-mono text-body-md">{label}</span>
                </button>
            )
    }

    return (
        <aside className="hidden md:flex flex-col w-60 bg-surface-container border-r border-outline-variant fixed h-[calc(100vh-3.5rem)] py-4">
            <div className="px-4 mb-6">
                <div className="font-mono text-headline-md text-on-surface">Etude Workspace</div>
            </div>
            <nav className="flex-1 space-y-1">
                {item('grid_view', '트레이닝 세트', 'home', onHome)}
                {item('assignment', '내 진행현황', 'progress', onProgress)}
                {item('analytics', '리더보드', 'leaderboard', onLeaderboard)}
            </nav>
            <div className="border-t border-outline-variant pt-4 px-2">
                <button onClick={onLogout} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-3 hover:text-on-surface transition-all">
                    <span className="material-symbols-outlined text-[22px]">logout</span>
                    <span className="font-mono text-body-md">로그아웃</span>
                </button>
            </div>
        </aside>
    )
}
