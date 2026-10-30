import { useEffect, useState } from 'react'
import { Logo } from './Logo'
import { stageOf } from '../characters'
import { fetchFeedSummary } from '../api/feed'
import { avatarTone } from '../avatar'
import { fetchGamification, type LevelInfo } from '../api/user'

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

// 화면을 옮길 때마다 사이드바가 새로 그려져도 레벨이 깜빡이지 않도록 마지막으로 받은 값을 기억해 둔다
let levelCache: LevelInfo | null = null

export function SideNav({ activePage, userName, userEmail, userRole, onHome, onProgress, onLeaderboard, onReview, onHall, onFeed, onAdmin, onLogout, onChangePassword }: Props) {
    // 내 소식에 달린 안 본 좋아요·댓글 수 (소식 화면을 열면 서버에서 '본 시각'이 갱신된다)
    const [newForMe, setNewForMe] = useState(0)
    // 어느 화면에서나 내 레벨이 보이게 한다 (서버 값)
    const [level, setLevel] = useState<LevelInfo | null>(levelCache)
    useEffect(() => { fetchGamification().then((g) => { levelCache = g.level; setLevel(g.level) }).catch(() => { /* 레벨이 없어도 메뉴는 그대로다 */ }) }, [])
    useEffect(() => {
        if (activePage === 'feed') { setNewForMe(0); return }
        fetchFeedSummary().then((r) => setNewForMe(r.newForMe)).catch(() => { /* 알림이 없어도 메뉴는 그대로다 */ })
    }, [activePage])
    const item = (icon: string, label: string, page: Page, onClick: () => void, badge = 0) => {
        const dot = badge > 0 && <span className="fx-pop ml-auto rounded-full bg-rose px-1.5 py-0.5 font-sans text-[11px] font-bold text-white tabular-nums" aria-label={`새 반응 ${badge}개`}>{badge}</span>
        const active = activePage === page
        const c = COLORS[page]
        return (
            <button
                onClick={active ? undefined : onClick}
                aria-current={active ? 'page' : undefined}
                className={`group mx-3 flex w-[calc(100%-1.5rem)] items-center gap-3 rounded-xl px-3 py-2.5 text-left transition-all ${active ? `bg-gradient-to-r ${c.bg} to-transparent text-on-surface ring-1 ring-white/5 cursor-default` : 'text-on-surface-variant hover:bg-surface-container-highest hover:text-on-surface'}`}
            >
                <span className={`material-symbols-outlined flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-[20px] transition-colors ${active ? `${c.icon} bg-white/10` : `${c.iconDim} ${c.iconHover} bg-white/5 group-hover:bg-white/10`}`} style={active ? { fontVariationSettings: "'FILL' 1" } : undefined}>{icon}</span>
                <span className={`font-sans text-body-md ${active ? 'font-bold' : ''}`}>{label}</span>
                {dot}
            </button>
        )
    }
    const caption = (text: string) => <p className="mx-6 mb-1 mt-4 font-sans text-[11px] font-semibold uppercase tracking-widest text-on-surface-variant/60">{text}</p>

    return (
        <aside className="hidden md:flex flex-col w-60 bg-surface-container border-r border-outline-variant fixed h-[calc(100vh-3.5rem)] py-4">
            <div className="px-4 mb-6">
                <div className="flex items-center gap-2.5">
                    <Logo size={36} className="drop-shadow-[0_0_10px_rgba(129,140,248,0.45)]" />
                    <div className="font-sans text-headline-md text-on-surface">Etude Workspace</div>
                </div>
            </div>
            <nav className="flex-1 space-y-0.5 overflow-y-auto">
                {caption('학습')}
                {item('grid_view', '트레이닝 세트', 'home', onHome)}
                {item('assignment', '내 진행현황', 'progress', onProgress)}
                {caption('함께')}
                {item('analytics', '랭킹', 'leaderboard', onLeaderboard)}
                {item('workspace_premium', '명예의 전당', 'hall', onHall)}
                {item('forum', '소식', 'feed', onFeed, newForMe)}
                {caption('더 연습')}
                {item('event_repeat', '복습', 'review', onReview)}
                {userRole === 'admin' && onAdmin && <>{caption('관리')}{item('admin_panel_settings', '관리자', 'admin', onAdmin)}</>}
            </nav>
            <div className="border-t border-outline-variant pt-4 px-2">
                <button onClick={onProgress} title={`${userEmail} · 내 진행현황 보기`} className="mx-1 mb-1 flex w-[calc(100%-0.5rem)] items-center gap-3 rounded-xl px-3 py-2.5 text-left hover:bg-surface-container-highest transition-colors">
                    <span className={`w-10 h-10 shrink-0 rounded-full ${avatarTone(userName)} flex items-center justify-center font-sans text-body-md font-bold text-white`}>{userName.slice(0, 1)}</span>
                    <div className="min-w-0 flex-1">
                        <div className="font-sans text-body-md font-semibold text-on-surface truncate">{userName}</div>
                        {level ? (
                            <>
                                <div className="font-sans text-code-sm text-gold truncate">{stageOf(level.level).body} Lv.{level.level} {level.title}</div>
                                <div className="mt-1 h-1.5 rounded-full bg-surface-container-highest overflow-hidden" role="progressbar" aria-valuenow={level.pct} aria-valuemin={0} aria-valuemax={100} aria-label="레벨 진행">
                                    <div className="h-full rounded-full bg-gradient-to-r from-gold via-rose to-accent" style={{ width: `${Math.max(4, level.pct)}%` }} />
                                </div>
                            </>
                        ) : (
                            <>
                                <div className="h-4 w-24 rounded bg-surface-container-highest animate-pulse" aria-hidden="true" />
                                <div className="mt-1 h-1.5 rounded-full bg-surface-container-highest" aria-hidden="true" />
                            </>
                        )}
                    </div>
                </button>
                <button onClick={onChangePassword} className="mx-1 flex w-[calc(100%-0.5rem)] items-center gap-3 rounded-xl px-4 py-2.5 text-on-surface-variant hover:bg-surface-container-highest hover:text-on-surface transition-colors">
                        <span className="material-symbols-outlined text-[22px]">lock_reset</span>
                        <span className="font-sans text-body-md">비밀번호 변경</span>
                </button>
                <button onClick={onLogout} className="mx-1 flex w-[calc(100%-0.5rem)] items-center gap-3 rounded-xl px-4 py-2.5 text-on-surface-variant hover:bg-surface-container-highest hover:text-on-surface transition-colors">
                    <span className="material-symbols-outlined text-[22px]">logout</span>
                    <span className="font-sans text-body-md">로그아웃</span>
                </button>
            </div>
        </aside>
    )
}
