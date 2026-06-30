import { useEffect, useState } from "react"
import { fetchProgess } from "../api"

interface ProgressRow {
    quest_set_id: number
    title: string
    category: string
    total: number
    completed: number
}

interface Props {
    onBack: () => void
    onLeaderboard: () => void
}

export function Progress({ onBack, onLeaderboard }: Props) {
    const [rows, setRows] = useState<ProgressRow[]>([])

    useEffect(() => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fetchProgess().then((data: any[]) =>
            setRows(data.map((r) => ({ ...r, total: Number(r.total), completed: Number(r.completed) })))
        )
    }, [])

    const totalQuests = rows.reduce((s, r) => s + r.total, 0)
    const totalCompleted = rows.reduce((s, r) => s + r.completed, 0)
    const completionRate = totalQuests > 0 ? Math.round((totalCompleted / totalQuests) * 100) : 0

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            {/* TopNav */}
            <header className="fixed top-0 z-50 w-full h-14 bg-surface border-b border-outline-variant flex justify-between items-center px-gutter shrink-0">
                <span className="font-mono text-body-lg font-bold tracking-tighter text-on-surface">OKESTRO TRAINING | Etude</span>
                <div className="flex items-center gap-4">
                    <div className="flex items-center gap-2 px-3 py-1 bg-surface-container-low border border-outline-variant">
                        <span className="material-symbols-outlined text-primary text-[16px]">terminal</span>
                        <span className="font-mono text-code-sm text-on-surface-variant">Progress Status</span>
                    </div>
                    <button onClick={onBack} className="font-mono text-body-md text-on-surface-variant hover:text-primary transition-colors">
                        Logout
                    </button>
                </div>
            </header>

            <div className="flex flex-1 pt-14">
                {/* SideNav */}
                <aside className="hidden md:flex flex-col w-60 bg-surface-container border-r border-outline-variant fixed h-[calc(100vh-3.5rem)] py-4">
                    <div className="px-4 mb-6">
                        <div className="font-mono text-headline-md text-on-surface">Etude Workspace</div>
                        <div className="font-mono text-label-caps text-on-surface-variant opacity-60 mt-1">v1.0.4-stable</div>
                    </div>
                    <nav className="flex-1 space-y-1">
                        <button onClick={onBack} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-2 hover:text-on-surface hover:bg-surface-container-highest transition-all">
                            <span className="material-symbols-outlined">dashboard</span>
                            <span className="font-mono text-label-caps">DASHBOARD</span>
                        </button>
                        <div className="flex items-center gap-3 text-primary border-l-2 border-primary pl-3 py-2">
                            <span className="material-symbols-outlined" style={{ fontVariationSettings: "'FILL' 1" }}>assignment</span>
                            <span className="font-mono text-label-caps">QUESTS</span>
                        </div>
                        <button onClick={onLeaderboard} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-2 hover:text-on-surface hover:bg-surface-container-highest transition-all">
                            <span className="material-symbols-outlined">analytics</span>
                            <span className="font-mono text-label-caps">LEADERBOARD</span>
                        </button>
                    </nav>
                </aside>

                {/* Main */}
                <main className="flex-1 md:ml-60 flex flex-col items-center px-gutter py-8 bg-surface">
                    <div className="w-full max-w-[800px] flex flex-col gap-8">
                        {/* Page Header */}
                        <div className="flex flex-col gap-2">
                            <div className="flex items-center gap-2 text-on-surface-variant font-mono text-label-caps">
                                <span className="text-primary">root</span>
                                <span>/</span>
                                <span>workspace</span>
                                <span>/</span>
                                <span className="text-on-surface">progress_dashboard</span>
                            </div>
                            <h1 className="font-mono text-headline-lg text-on-surface">System Progress</h1>
                        </div>

                        {/* Summary Cards */}
                        <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div className="bg-surface-container border border-outline-variant p-4 flex flex-col gap-4 relative overflow-hidden">
                                <div className="flex items-center gap-2">
                                    <span className="material-symbols-outlined text-primary text-[18px]">database</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">Total Quests</span>
                                </div>
                                <div className="flex items-baseline gap-2">
                                    <span className="font-mono text-headline-lg">{totalQuests}</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">Units</span>
                                </div>
                            </div>
                            <div className="bg-surface-container border border-outline-variant p-4 flex flex-col gap-4 relative overflow-hidden">
                                <div className="flex items-center gap-2">
                                    <span className="material-symbols-outlined text-on-surface-variant text-[18px]">task_alt</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">Completed Quests</span>
                                </div>
                                <div className="flex items-baseline gap-2">
                                    <span className="font-mono text-headline-lg">{totalCompleted}</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">Resolved</span>
                                </div>
                            </div>
                            <div className="bg-surface-container border border-outline-variant p-4 flex flex-col gap-4 relative overflow-hidden">
                                <div className="flex items-center gap-2 text-success">
                                    <span className="material-symbols-outlined text-[18px]">query_stats</span>
                                    <span className="font-mono text-label-caps opacity-80">Completion %</span>
                                </div>
                                <div className="flex items-baseline gap-2">
                                    <span className="font-mono text-headline-lg">{completionRate}</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">%</span>
                                </div>
                                <div className="absolute bottom-0 left-0 w-full h-[2px] bg-surface-container-highest">
                                    <div className="h-full bg-success" style={{ width: `${completionRate}%` }} />
                                </div>
                            </div>
                        </section>

                        {/* Training Sets Table */}
                        <section className="bg-surface-container border border-outline-variant overflow-hidden">
                            <div className="px-4 py-3 border-b border-outline-variant flex justify-between items-center bg-surface-container-high">
                                <span className="font-mono text-label-caps">Active Training Sets</span>
                                <div className="flex gap-2">
                                    <div className="w-2 h-2 rounded-full bg-error/40"></div>
                                    <div className="w-2 h-2 rounded-full bg-on-surface-variant/40"></div>
                                    <div className="w-2 h-2 rounded-full bg-success/40"></div>
                                </div>
                            </div>
                            <div className="overflow-x-auto">
                                <table className="w-full text-left border-collapse">
                                    <thead className="bg-surface">
                                        <tr>
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">Set Name</th>
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">Category</th>
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">Progress</th>
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-outline-variant">
                                        {rows.map(r => {
                                            const pct = r.total > 0 ? Math.round((r.completed / r.total) * 100) : 0
                                            const isComplete = r.completed === r.total && r.total > 0
                                            const isStarted = r.completed > 0
                                            return (
                                                <tr key={r.quest_set_id} className="hover:bg-surface-container-highest/50 transition-colors">
                                                    <td className="px-6 py-4 font-mono text-code-sm">
                                                        <div className="flex items-center gap-2">
                                                            {isComplete
                                                                ? <span className="material-symbols-outlined text-[16px] text-success">check_circle</span>
                                                                : isStarted
                                                                    ? <span className="material-symbols-outlined text-[16px] text-primary">sync</span>
                                                                    : <span className="material-symbols-outlined text-[16px] text-on-surface-variant">circle</span>
                                                            }
                                                            {r.title}
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4">
                                                        <span className="px-2 py-0.5 bg-surface border border-outline-variant font-mono text-[10px] uppercase tracking-wider text-on-surface-variant">
                                                            {r.category}
                                                        </span>
                                                    </td>
                                                    <td className="px-6 py-4">
                                                        <div className="flex flex-col gap-1 w-32">
                                                            <div className="flex justify-between font-mono text-[10px]">
                                                                <span>{r.completed}/{r.total}</span>
                                                                <span>{pct}%</span>
                                                            </div>
                                                            <div className="h-1 bg-surface border border-outline-variant">
                                                                <div
                                                                    className={`h-full ${isComplete ? 'bg-success' : 'bg-primary'}`}
                                                                    style={{ width: `${pct}%` }}
                                                                />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4">
                                                        {isComplete
                                                            ? <span className="font-mono text-label-caps text-success border border-success/30 px-2 py-0.5 bg-success/5">COMPLETED</span>
                                                            : isStarted
                                                                ? <span className="font-mono text-label-caps text-primary border border-primary/30 px-2 py-0.5 bg-primary/5">IN PROGRESS</span>
                                                                : <span className="font-mono text-label-caps text-on-surface-variant border border-outline-variant px-2 py-0.5">NOT STARTED</span>
                                                        }
                                                    </td>
                                                </tr>
                                            )
                                        })}
                                    </tbody>
                                </table>
                            </div>
                        </section>

                        {/* Action Bar */}
                        <div className="flex items-center justify-between border-t border-outline-variant pt-6">
                            <button onClick={onBack} className="group flex items-center gap-2 text-on-surface-variant hover:text-on-surface transition-all">
                                <span className="material-symbols-outlined text-[18px] group-hover:-translate-x-1 transition-transform">arrow_back</span>
                                <span className="font-mono text-label-caps">Return to Set Select</span>
                            </button>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    )
}
