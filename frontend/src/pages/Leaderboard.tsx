import { useEffect, useState } from "react"
import { fetchLeaderboard, fetchWeeklyLeaderboard, type MemberProgress, type WeeklyLeaderboard } from "../api/user"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

interface Props {
    onBack: () => void
    onProgress: () => void
    onHall: () => void
    onReview: () => void
    onFeed: () => void
    onAdmin?: () => void
    onLogout: () => void
    onChangePassword: () => void
    userName: string
    userEmail: string
    userRole?: string
}

export function Leaderboard({ onBack, onProgress, onHall, onReview, onFeed, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [rows, setRows] = useState<MemberProgress[]>([])
    const [openUsers, setOpenUsers] = useState<Set<number>>(new Set())
    const [tab, setTab] = useState<'total' | 'weekly'>('total')
    const [weekly, setWeekly] = useState<WeeklyLeaderboard | null>(null)
    const [weeklyError, setWeeklyError] = useState(false)


    // 이번 주 XP 는 탭을 처음 열 때 불러온다
    useEffect(() => {
        if (tab !== 'weekly' || weekly) return
        fetchWeeklyLeaderboard().then(setWeekly).catch(() => setWeeklyError(true))
    }, [tab, weekly])

    useEffect(() => {
        fetchLeaderboard().then((data) =>
            setRows(data.map(u => ({ ...u, total: Number(u.total), completed: Number(u.completed) })))
        )
    }, [])

    // 내 줄은 이름으로 찾는다 (랭킹 응답에는 이름만 있다)
    const meIndex = rows.findIndex((u) => u.userName === userName)
    const pctOf = (u: MemberProgress) => (u.total > 0 ? Math.round((u.completed / u.total) * 100) : 0)
    const MEDALS = ['🥇', '🥈', '🥉']
    // 시상대는 2등 · 1등 · 3등 순서로 놓고, 1등을 가장 높게 세운다
    const podium = [1, 0, 2].map((i) => ({ u: rows[i], rank: i })).filter((p) => p.u && p.u.completed > 0) // 기록이 있는 사람만 시상대에 오른다
    const podiumStyle = [
        { h: 'h-28', text: 'text-gold', ring: 'border-gold/60', bg: 'from-gold/25 to-gold/5' },
        { h: 'h-20', text: 'text-on-surface', ring: 'border-outline', bg: 'from-on-surface/15 to-on-surface/5' },
        { h: 'h-16', text: 'text-warning', ring: 'border-warning/60', bg: 'from-warning/25 to-warning/5' },
    ]

    function toggleUser(userId: number) {
        setOpenUsers(prev => {
            const next = new Set(prev)
            if (next.has(userId)) next.delete(userId)
            else next.add(userId)
            return next
        })
    }

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={onBack} />
            <div className="flex flex-1 pt-14">
                <SideNav activePage="leaderboard" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onBack} onProgress={onProgress} onLeaderboard={() => {}} onHall={onHall} onReview={onReview} onFeed={onFeed} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />

                <main className="fx-page flex-1 md:ml-60 p-margin-page bg-surface overflow-y-auto">
                    <div className="flex flex-col gap-2 mb-8">
                        <div className="flex items-center gap-2 text-on-surface-variant font-sans text-label-caps">
                            <span className="text-primary">root</span>
                            <span>/</span>
                            <span>workspace</span>
                            <span>/</span>
                            <span className="text-on-surface">랭킹</span>
                        </div>
                        <h1 className="font-sans text-headline-lg text-on-surface">랭킹</h1>
                    </div>

                    <div role="tablist" className="flex gap-1 border-b border-outline-variant mb-6">
                        {([['total', '누적 세트', 'leaderboard'], ['weekly', '이번 주 XP', 'bolt']] as const).map(([id, label, icon]) => (
                            <button
                                key={id}
                                role="tab"
                                aria-selected={tab === id}
                                onClick={() => setTab(id)}
                                className={`flex items-center gap-1.5 px-5 py-2.5 -mb-px border-b-2 font-sans text-label-caps transition-colors ${tab === id ? 'border-gold text-on-surface' : 'border-transparent text-on-surface-variant hover:text-on-surface'}`}
                            >
                                <span className={`material-symbols-outlined text-[18px] ${tab === id ? 'text-gold' : ''}`} style={tab === id ? { fontVariationSettings: "'FILL' 1" } : undefined}>{icon}</span>{label}
                            </button>
                        ))}
                    </div>

                    {tab === 'weekly' && (
                        <div className="max-w-[640px] space-y-4">
                            <p className="font-sans text-body-md text-on-surface-variant">최근 7일 동안 얻은 XP예요. 이번 주에 열심히 한 사람이 앞서요 ⚡</p>
                            {weeklyError && <p className="font-sans text-body-md text-error">이번 주 순위를 불러오지 못했어요. 잠시 후 다시 열어 주세요.</p>}
                            {!weekly && !weeklyError && <div className="h-32 rounded-xl bg-surface-container animate-pulse" aria-label="불러오는 중" />}
                            {weekly && weekly.entries.length === 0 && (
                                <p className="rounded-xl border border-dashed border-outline-variant px-5 py-6 font-sans text-body-lg text-on-surface">🌟 이번 주 첫 주인공이 되어 보세요! 세트를 끝내면 XP가 쌓여요.</p>
                            )}
                            {weekly && weekly.entries.length > 0 && (
                                <ol className="space-y-2">
                                    {weekly.entries.map((e, i) => (
                                        <li key={e.userId} className={`flex items-center gap-3 rounded-xl px-4 py-3 ${e.userName === userName ? 'bg-info/15 ring-1 ring-info/40' : 'bg-surface-container-low border border-outline-variant'}`}>
                                            <span className="w-8 text-center text-[22px] leading-none">{MEDALS[i] ?? <span className="font-sans text-body-md text-on-surface-variant tabular-nums">{i + 1}</span>}</span>
                                            <span className="flex-1 min-w-0 truncate font-sans text-body-md font-semibold text-on-surface">{e.userName}{e.userName === userName && <span className="ml-2 px-1.5 py-0.5 rounded-full bg-info/20 text-info font-sans text-[11px]">나</span>}</span>
                                            <span className="font-sans text-body-md font-bold text-gold tabular-nums">{e.xp} XP</span>
                                        </li>
                                    ))}
                                </ol>
                            )}
                            {weekly && weekly.me.rank === null && (
                                <p className="rounded-xl bg-info/10 px-4 py-3 font-sans text-body-md text-on-surface">
                                    {weekly.me.xp > 0 ? `나는 이번 주 ${weekly.me.xp} XP를 얻었어요. 조금만 더 하면 상위권이에요! 💪` : '이번 주에는 아직 XP가 없어요. 세트 하나로 시작해 볼까요?'}
                                </p>
                            )}
                        </div>
                    )}

                    {tab === 'total' && <>
                    {meIndex >= 0 && (
                        <div className="mb-6 flex items-center gap-4 rounded-xl border border-info/40 bg-gradient-to-r from-info/15 via-accent/10 to-transparent px-6 py-4">
                            <span className="text-[34px] leading-none">{rows[meIndex]!.completed > 0 ? (MEDALS[meIndex] ?? '🏃') : '🌱'}</span>
                            <div className="min-w-0">
                                <p className="font-sans text-label-caps text-on-surface-variant">내 순위</p>
                                <p className="font-sans text-headline-md text-on-surface">{rows[meIndex]!.completed > 0 ? `${rows.length}명 중 ${meIndex + 1}위 · 완료 ${rows[meIndex]!.completed}/${rows[meIndex]!.total} 세트` : '아직 시작 전이에요'}</p>
                            </div>
                            <p className="ml-auto hidden md:block font-sans text-body-md text-on-surface-variant">{rows[meIndex]!.completed === 0 ? '첫 세트를 끝내면 순위에 이름이 올라가요' : meIndex === 0 ? '1등이에요! 👑' : '한 세트만 더 끝내면 순위가 올라가요'}</p>
                        </div>
                    )}

                    {podium.length > 0 && (
                        <div className="mb-8 flex items-end justify-center gap-4" aria-label="상위 3명">
                            {podium.map(({ u, rank }) => (
                                <div key={u!.userId} className="flex flex-col items-center w-40">
                                    <span className={`fx-pop text-[34px] leading-none mb-1 ${rank === 0 ? 'fx-bounce' : ''}`}>{MEDALS[rank]}</span>
                                    <span className={`font-sans text-body-md font-bold truncate max-w-full ${podiumStyle[rank]!.text}`}>{u!.userName}</span>
                                    <span className="font-sans text-code-sm text-on-surface-variant mb-2">{u!.completed}세트 · {pctOf(u!)}%</span>
                                    <div className={`w-full ${podiumStyle[rank]!.h} rounded-t-lg border border-b-0 ${podiumStyle[rank]!.ring} bg-gradient-to-b ${podiumStyle[rank]!.bg} flex items-start justify-center pt-2`}>
                                        <span className={`font-sans text-headline-lg font-extrabold ${podiumStyle[rank]!.text}`}>{rank + 1}</span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}

                    <div className="bg-surface-container border border-outline-variant overflow-hidden">
                        <div className="p-4 border-b border-outline-variant bg-surface-container-high flex justify-between items-center">
                            <h3 className="font-sans text-label-caps uppercase tracking-widest text-on-surface">팀원 랭킹</h3>
                        </div>

                        {rows.map((u, idx) => {
                            const pct = u.total > 0 ? Math.round((u.completed / u.total) * 100) : 0
                            const isOpen = openUsers.has(u.userId)
                            return (
                                <div key={u.userId} className={`border-b border-outline-variant last:border-0 ${idx === meIndex ? 'bg-info/10 border-l-4 border-l-info' : ''}`}>
                                    <button
                                        onClick={() => toggleUser(u.userId)}
                                        className="w-full flex items-center gap-4 px-4 py-4 hover:bg-surface-container-high transition-colors text-left"
                                    >
                                        <span className="font-sans text-headline-md text-on-surface-variant w-8 shrink-0">
                                            {u.completed > 0 ? (MEDALS[idx] ?? idx + 1) : '–'}
                                        </span>
                                        <span className="font-sans text-body-md font-semibold text-on-surface w-32 shrink-0">
                                            {u.userName}{idx === meIndex && <span className="ml-2 px-1.5 py-0.5 rounded-full bg-info/20 text-info font-sans text-[11px]">나</span>}
                                        </span>
                                        <div className="flex-1 h-2 bg-surface-container-highest">
                                            <div
                                                className={`h-full bg-gradient-to-r ${pct === 100 ? 'from-success to-gold' : 'from-info to-accent'} transition-all duration-700`}
                                                style={{ width: `${pct}%` }}
                                            />
                                        </div>
                                        <span className="font-sans text-code-sm text-on-surface-variant w-20 text-right shrink-0">
                                            {u.completed}/{u.total} 세트
                                        </span>
                                        <span className={`font-sans text-body-md font-bold w-12 text-right shrink-0 ${pct === 100 ? 'text-success' : 'text-primary'}`}>
                                            {pct}%
                                        </span>
                                        <span
                                            className="material-symbols-outlined text-on-surface-variant text-[20px] shrink-0 transition-transform"
                                            style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)' }}
                                        >
                                            expand_more
                                        </span>
                                    </button>

                                    {isOpen && (
                                        <div className="border-t border-outline-variant bg-surface-container-lowest">
                                            {u.sets.map(s => {
                                                const sComplete = s.completed > 0
                                                return (
                                                    <div key={s.questSetId} className="flex items-center gap-4 px-4 py-3 border-b border-outline-variant/50 last:border-0">
                                                        <span className="w-8 shrink-0" />
                                                        <span className="font-sans text-code-sm text-on-surface-variant w-32 shrink-0">{s.category}</span>
                                                        <span className="font-sans text-code-sm text-on-surface flex-1">{s.questSetTitle}</span>
                                                        <span className={`font-sans text-code-sm w-24 text-right shrink-0 flex items-center justify-end gap-1 ${sComplete ? 'text-success font-bold' : 'text-on-surface-variant'}`}>
                                                            {sComplete && <span className="material-symbols-outlined text-[16px]" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>}
                                                            {sComplete ? '완료' : '미완료'}
                                                        </span>
                                                        <span className="w-[20px] shrink-0" />
                                                    </div>
                                                )
                                            })}
                                        </div>
                                    )}
                                </div>
                            )
                        })}
                    </div>

                    </>}
                </main>
            </div>
        </div>
    )
}
