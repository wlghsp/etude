import { useEffect, useState } from "react"
import { fetchLeaderboard } from "../api/user"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

interface SetRow {
    questSetId: number
    questSetTitle: string
    category: string
    total: number
    completed: number
}

interface UserRow {
    userId: number
    userName: string
    total: number
    completed: number
    sets: SetRow[]
}

interface Props {
    onBack: () => void
    onProgress: () => void
    onLogout: () => void
    userName: string
    userEmail: string
}

export function Leaderboard({ onBack, onProgress, onLogout, userName, userEmail }: Props) {
    const [rows, setRows] = useState<UserRow[]>([])
    const [openUsers, setOpenUsers] = useState<Set<number>>(new Set())

    useEffect(() => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fetchLeaderboard().then((data: any[]) =>
            setRows(data.map(u => ({ ...u, total: Number(u.total), completed: Number(u.completed) })))
        )
    }, [])

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
                <SideNav activePage="leaderboard" userName={userName} userEmail={userEmail} onHome={onBack} onProgress={onProgress} onLeaderboard={() => {}} onLogout={onLogout} />

                <main className="flex-1 md:ml-60 p-margin-page bg-surface overflow-y-auto">
                    <div className="flex flex-col gap-2 mb-8">
                        <div className="flex items-center gap-2 text-on-surface-variant font-mono text-label-caps">
                            <span className="text-primary">root</span>
                            <span>/</span>
                            <span>workspace</span>
                            <span>/</span>
                            <span className="text-on-surface">랭킹</span>
                        </div>
                        <h1 className="font-mono text-headline-lg text-on-surface">랭킹</h1>
                    </div>

                    <div className="bg-surface-container border border-outline-variant overflow-hidden">
                        <div className="p-4 border-b border-outline-variant bg-surface-container-high flex justify-between items-center">
                            <h3 className="font-mono text-label-caps uppercase tracking-widest text-on-surface">팀원 랭킹</h3>
                        </div>

                        {rows.map((u, idx) => {
                            const pct = u.total > 0 ? Math.round((u.completed / u.total) * 100) : 0
                            const isOpen = openUsers.has(u.userId)
                            return (
                                <div key={u.userId} className="border-b border-outline-variant last:border-0">
                                    <button
                                        onClick={() => toggleUser(u.userId)}
                                        className="w-full flex items-center gap-4 px-4 py-4 hover:bg-surface-container-high transition-colors text-left"
                                    >
                                        <span className="font-mono text-headline-md text-on-surface-variant w-8 shrink-0">
                                            {idx + 1}
                                        </span>
                                        <span className="font-mono text-body-md font-semibold text-on-surface w-32 shrink-0">
                                            {u.userName}
                                        </span>
                                        <div className="flex-1 h-2 bg-surface-container-highest">
                                            <div
                                                className={`h-full ${pct === 100 ? 'bg-success' : 'bg-primary'}`}
                                                style={{ width: `${pct}%` }}
                                            />
                                        </div>
                                        <span className="font-mono text-code-sm text-on-surface-variant w-20 text-right shrink-0">
                                            {u.completed}/{u.total}
                                        </span>
                                        <span className={`font-mono text-body-md font-bold w-12 text-right shrink-0 ${pct === 100 ? 'text-success' : 'text-primary'}`}>
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
                                                const sPct = s.total > 0 ? Math.round((s.completed / s.total) * 100) : 0
                                                const sComplete = s.completed === s.total && s.total > 0
                                                return (
                                                    <div key={s.questSetId} className="flex items-center gap-4 px-4 py-3 border-b border-outline-variant/50 last:border-0">
                                                        <span className="w-8 shrink-0" />
                                                        <span className="font-mono text-code-sm text-on-surface-variant w-32 shrink-0">{s.category}</span>
                                                        <span className="font-mono text-code-sm text-on-surface flex-1">{s.questSetTitle}</span>
                                                        <div className="w-24 h-1 bg-surface-container-highest shrink-0">
                                                            <div
                                                                className={`h-full ${sComplete ? 'bg-success' : 'bg-primary'}`}
                                                                style={{ width: `${sPct}%` }}
                                                            />
                                                        </div>
                                                        <span className="font-mono text-code-sm text-on-surface-variant w-20 text-right shrink-0">
                                                            {s.completed}/{s.total}
                                                        </span>
                                                        <span className={`font-mono text-code-sm font-bold w-12 text-right shrink-0 ${sComplete ? 'text-success' : sPct > 0 ? 'text-primary' : 'text-on-surface-variant'}`}>
                                                            {sPct}%
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
