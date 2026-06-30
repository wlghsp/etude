import { useEffect, useState } from "react"
import { fetchLeaderboard } from "../api"

interface Row {
  userName: string
  questSetTitle: string
  category: string
  total: number
  completed: number
}

interface Props {
    onBack: () => void
}

export function Leaderboard({ onBack }: Props) {
    const [rows, setRows] = useState<Row[]>([])

    useEffect(() => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fetchLeaderboard().then((data: any[]) =>
            setRows(data.map((r) => ({ ...r, total: Number(r.total), completed: Number(r.completed) })))
        )
    }, [])

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            {/* TopNav */}
            <header className="fixed top-0 z-50 w-full h-14 bg-surface border-b border-outline-variant flex justify-between items-center px-gutter shrink-0">
                <span className="font-mono text-body-lg font-bold tracking-tighter text-on-surface">OKESTRO TRAINING | Etude</span>
                <div className="flex items-center gap-6">
                    <span className="font-mono text-code-sm text-primary">Progress Status</span>
                    <button onClick={onBack} className="font-mono text-body-md text-on-surface-variant hover:text-primary transition-colors">
                        Logout
                    </button>
                </div>
            </header>

            <div className="flex flex-1 pt-14">
                {/* SideNav */}
                <aside className="hidden md:flex flex-col w-60 bg-surface-container border-r border-outline-variant fixed h-[calc(100vh-3.5rem)] py-4">
                    <div className="px-4 mb-6">
                        <div className="flex items-center gap-3">
                            <div className="w-8 h-8 bg-primary flex items-center justify-center">
                                <span className="material-symbols-outlined text-surface" style={{ fontVariationSettings: "'FILL' 1" }}>terminal</span>
                            </div>
                            <div>
                                <div className="font-mono text-headline-md text-on-surface leading-none">Etude</div>
                                <div className="font-mono text-label-caps text-on-surface-variant mt-1">v1.0.4-stable</div>
                            </div>
                        </div>
                    </div>
                    <nav className="flex-1 space-y-1">
                        <button onClick={onBack} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-2 hover:text-on-surface hover:bg-surface-container-highest transition-all">
                            <span className="material-symbols-outlined">dashboard</span>
                            <span className="font-mono text-label-caps uppercase">Dashboard</span>
                        </button>
                        <div className="flex items-center gap-3 text-primary border-l-2 border-primary pl-3 py-2">
                            <span className="material-symbols-outlined" style={{ fontVariationSettings: "'FILL' 1" }}>analytics</span>
                            <span className="font-mono text-label-caps uppercase">Leaderboard</span>
                        </div>
                    </nav>
                </aside>

                {/* Main */}
                <main className="flex-1 md:ml-60 p-margin-page bg-surface overflow-y-auto">
                    {/* Page Header */}
                    <div className="flex justify-between items-end mb-8">
                        <div>
                            <nav className="flex gap-2 font-mono text-label-caps text-on-surface-variant mb-2 uppercase tracking-widest">
                                <span>Etude</span>
                                <span>/</span>
                                <span className="text-primary">Team Leaderboard</span>
                            </nav>
                            <h1 className="font-mono text-headline-lg text-on-surface border-l-4 border-primary pl-4">Team Leaderboard</h1>
                        </div>
                        <button onClick={onBack} className="flex items-center gap-2 px-4 py-2 border border-outline-variant font-mono text-body-md hover:bg-surface-container transition-colors">
                            <span className="material-symbols-outlined">arrow_back</span>
                            Back
                        </button>
                    </div>

                    {/* Table */}
                    <div className="bg-surface-container border border-outline-variant overflow-hidden">
                        <div className="p-4 border-b border-outline-variant bg-surface-container-high flex justify-between items-center">
                            <h3 className="font-mono text-label-caps uppercase tracking-widest text-on-surface">Member Progress Matrix</h3>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full text-left border-collapse">
                                <thead>
                                    <tr className="border-b border-outline-variant bg-surface-container-lowest">
                                        <th className="p-4 font-mono text-label-caps uppercase text-on-surface-variant border-r border-outline-variant w-48">Member</th>
                                        <th className="p-4 font-mono text-label-caps uppercase text-on-surface-variant">Training Set Name</th>
                                        <th className="p-4 font-mono text-label-caps uppercase text-on-surface-variant">Category</th>
                                        <th className="p-4 font-mono text-label-caps uppercase text-on-surface-variant w-64">Progress</th>
                                        <th className="p-4 font-mono text-label-caps uppercase text-on-surface-variant text-right">Status</th>
                                    </tr>
                                </thead>
                                <tbody className="font-mono text-body-md">
                                    {rows.map((r, i) => {
                                        const pct = r.total > 0 ? Math.round((r.completed / r.total) * 100) : 0
                                        const isComplete = r.completed === r.total && r.total > 0
                                        const isStarted = r.completed > 0
                                        return (
                                            <tr key={i} className="border-b border-outline-variant hover:bg-surface-container-high transition-colors">
                                                <td className="p-4 border-r border-outline-variant bg-surface-container-lowest">
                                                    <span className="font-bold text-on-surface">{r.userName}</span>
                                                </td>
                                                <td className="p-4 text-on-surface">{r.questSetTitle}</td>
                                                <td className="p-4">
                                                    <div className="inline-flex items-center gap-2 px-2 py-1 bg-surface-container-highest border border-outline-variant">
                                                        <span className="font-mono text-label-caps">{r.category}</span>
                                                    </div>
                                                </td>
                                                <td className="p-4">
                                                    <div className="flex flex-col gap-1">
                                                        <div className="flex justify-between font-mono text-code-sm">
                                                            <span>{r.completed}/{r.total}</span>
                                                            <span>{pct}%</span>
                                                        </div>
                                                        <div className="h-1 bg-surface-variant w-full overflow-hidden">
                                                            <div
                                                                className={`h-full ${isComplete ? 'bg-success' : 'bg-info'}`}
                                                                style={{ width: `${pct}%` }}
                                                            />
                                                        </div>
                                                    </div>
                                                </td>
                                                <td className="p-4 text-right">
                                                    {isComplete
                                                        ? <span className="font-mono text-label-caps text-success border border-success px-2 py-0.5 bg-success/10">COMPLETED</span>
                                                        : isStarted
                                                            ? <span className="font-mono text-label-caps text-info border border-info px-2 py-0.5 bg-info/10">IN PROGRESS</span>
                                                            : <span className="font-mono text-label-caps text-on-surface-variant border border-outline-variant px-2 py-0.5 bg-surface-variant/5">NOT STARTED</span>
                                                    }
                                                </td>
                                            </tr>
                                        )
                                    })}
                                </tbody>
                            </table>
                        </div>
                    </div>

                    {/* Footer */}
                    <div className="mt-8 pt-4 border-t border-outline-variant">
                        <div className="flex items-center gap-4 font-mono text-label-caps text-on-surface-variant">
                            <span className="flex items-center gap-1">
                                <span className="w-1.5 h-1.5 rounded-full bg-success"></span> System Online
                            </span>
                        </div>
                    </div>
                </main>
            </div>
        </div>
    )
}
