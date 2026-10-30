import { useEffect, useState } from 'react'
import { Logo } from './Logo'
import { fetchFeedSummary } from '../api/feed'

type Page = 'home' | 'review' | 'progress' | 'leaderboard' | 'hall' | 'feed' | 'admin'

interface Props {
    activePage: Page
    userName: string
    userEmail: string
    userRole?: string
    onHome: () => void
    onProgress: () => void
    onLeaderboard: () => void
    onReview: () => void
    onHall: () => void
    onFeed: () => void
    onAdmin?: () => void
    onLogout: () => void
    onChangePassword: () => void
}

// 메뉴마다 색을 달리해 어디가 어딘지 한눈에 보이게 한다 (클래스는 정적 문자열이어야 Tailwind 가 만든다)
const COLORS: Record<Page, { icon: string; iconDim: string; iconHover: string; bar: string; bg: string }> = {
    home:        { icon: 'text-sky',     iconDim: 'text-sky/70', iconHover: 'group-hover:text-sky',     bar: 'border-sky',     bg: 'from-sky/20' },
    review:      { icon: 'text-info',    iconDim: 'text-info/70', iconHover: 'group-hover:text-info',    bar: 'border-info',    bg: 'from-info/20' },
    progress:    { icon: 'text-success', iconDim: 'text-success/70', iconHover: 'group-hover:text-success', bar: 'border-success', bg: 'from-success/20' },
    leaderboard: { icon: 'text-gold',    iconDim: 'text-gold/70', iconHover: 'group-hover:text-gold',    bar: 'border-gold',    bg: 'from-gold/20' },
    hall:        { icon: 'text-warning', iconDim: 'text-warning/70', iconHover: 'group-hover:text-warning', bar: 'border-warning', bg: 'from-warning/20' },
    feed:        { icon: 'text-rose',    iconDim: 'text-rose/70', iconHover: 'group-hover:text-rose',    bar: 'border-rose',    bg: 'from-rose/20' },
    admin:       { icon: 'text-accent',  iconDim: 'text-accent/70', iconHover: 'group-hover:text-accent',  bar: 'border-accent',  bg: 'from-accent/20' },
}

export function SideNav({ activePage, userName, userEmail, userRole, onHome, onProgress, onLeaderboard, onReview, onHall, onFeed, onAdmin, onLogout, onChangePassword }: Props) {
    // 내 소식에 달린 안 본 좋아요·댓글 수 (소식 화면을 열면 서버에서 '본 시각'이 갱신된다)
    const [newForMe, setNewForMe] = useState(0)
    useEffect(() => {
        if (activePage === 'feed') { setNewForMe(0); return }
        fetchFeedSummary().then((r) => setNewForMe(r.newForMe)).catch(() => { /* 알림이 없어도 메뉴는 그대로다 */ })
    }, [activePage])
    const item = (icon: string, label: string, page: Page, onClick: () => void, badge = 0) => {
        const dot = badge > 0 && <span className="fx-pop ml-auto mr-4 rounded-full bg-rose px-1.5 py-0.5 font-sans text-[11px] font-bold text-white tabular-nums" aria-label={`새 반응 ${badge}개`}>{badge}</span>
        const active = activePage === page
        const c = COLORS[page]
        return active
            ? (
                <div className={`flex items-center gap-3 text-on-surface border-l-4 ${c.bar} bg-gradient-to-r ${c.bg} to-transparent pl-3 py-3`}>
                    <span className={`material-symbols-outlined text-[22px] ${c.icon}`} style={{ fontVariationSettings: "'FILL' 1" }}>{icon}</span>
                    <span className="font-sans text-body-md font-bold">{label}</span>
                </div>
            ) : (
                <button onClick={onClick} className="group w-full flex items-center gap-3 text-on-surface-variant pl-4 py-3 hover:text-on-surface hover:bg-surface-container-highest transition-all">
                    <span className={`material-symbols-outlined text-[22px] ${c.iconDim} ${c.iconHover}`}>{icon}</span>
                    <span className="font-sans text-body-md">{label}</span>
                    {dot}
                </button>
            )
    }

    return (
        <aside className="hidden md:flex flex-col w-60 bg-surface-container border-r border-outline-variant fixed h-[calc(100vh-3.5rem)] py-4">
            <div className="px-4 mb-6">
                <div className="flex items-center gap-2.5">
                    <Logo size={36} className="drop-shadow-[0_0_10px_rgba(129,140,248,0.45)]" />
                    <div className="font-sans text-headline-md text-on-surface">Etude Workspace</div>
                </div>
            </div>
            <nav className="flex-1 space-y-1">
                {item('grid_view', '트레이닝 세트', 'home', onHome)}
                {item('assignment', '내 진행현황', 'progress', onProgress)}
                {item('analytics', '랭킹', 'leaderboard', onLeaderboard)}
                {item('workspace_premium', '명예의 전당', 'hall', onHall)}
                {item('forum', '소식', 'feed', onFeed, newForMe)}
                {item('event_repeat', '복습', 'review', onReview)}
                {userRole === 'admin' && onAdmin && item('admin_panel_settings', '관리자', 'admin', onAdmin)}
            </nav>
            <div className="border-t border-outline-variant pt-4 px-2">
                <div className="px-4 py-3 mb-1 flex items-center gap-3">
                    <span className="w-9 h-9 shrink-0 rounded-full bg-gradient-to-br from-rose to-accent flex items-center justify-center font-sans text-body-md font-bold text-white">{userName.slice(0, 1)}</span>
                    <div className="min-w-0">
                        <div className="font-sans text-body-md font-semibold text-on-surface truncate">{userName}</div>
                        <div className="font-sans text-code-sm text-on-surface-variant truncate">{userEmail}</div>
                    </div>
                </div>
                <button onClick={onChangePassword} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-3 hover:text-on-surface transition-all">
                        <span className="material-symbols-outlined text-[22px]">lock_reset</span>
                        <span className="font-sans text-body-md">비밀번호 변경</span>
                </button>
                <button onClick={onLogout} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-3 hover:text-on-surface transition-all">
                    <span className="material-symbols-outlined text-[22px]">logout</span>
                    <span className="font-sans text-body-md">로그아웃</span>
                </button>
            </div>
        </aside>
    )
}
