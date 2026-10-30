import { useEffect, useState } from "react"
import { fetchLeaderboard, type MemberProgress } from "../api/user"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

interface Props {
    onBack: () => void
    onProgress: () => void
    onAdmin?: () => void
    onLogout: () => void
    onChangePassword: () => void
    userName: string
    userEmail: string
    userRole?: string
}

export function Leaderboard({ onBack, onProgress, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [rows, setRows] = useState<MemberProgress[]>([])
    const [openUsers, setOpenUsers] = useState<Set<number>>(new Set())

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
    const podium = [1, 0, 2].map((i) => ({ u: rows[i], rank: i })).filter((p) => p.u)
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
                <SideNav activePage="leaderboard" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onBack} onProgress={onProgress} onLeaderboard={() => {}} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />

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

                    {meIndex >= 0 && (
                        <div className="mb-6 flex items-center gap-4 rounded-xl border border-info/40 bg-gradient-to-r from-info/15 via-accent/10 to-transparent px-6 py-4">
                            <span className="text-[34px] leading-none">{MEDALS[meIndex] ?? '🏃'}</span>
                            <div className="min-w-0">
                                <p className="font-sans text-label-caps text-on-surface-variant">내 순위</p>
                                <p className="font-sans text-headline-md text-on-surface">{rows.length}명 중 {meIndex + 1}위 · 완료 {rows[meIndex]!.completed}/{rows[meIndex]!.total} 세트</p>
                            </div>
                            <p className="ml-auto hidden md:block font-sans text-body-md text-on-surface-variant">{meIndex === 0 ? '1등이에요! 👑' : '한 세트만 더 끝내면 순위가 올라가요'}</p>
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
                                            {MEDALS[idx] ?? idx + 1}
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
                </main>
            </div>
        </div>
    )
}
