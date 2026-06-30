import { useEffect, useState } from "react"
import { fetchLeaderboard } from "../api"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

interface Row {
  userName: string
  questSetTitle: string
  category: string
  total: number
  completed: number
}

interface Props {
    onBack: () => void
    onProgress: () => void
    onLogout: () => void
}

export function Leaderboard({ onBack, onProgress, onLogout }: Props) {
    const [rows, setRows] = useState<Row[]>([])

    useEffect(() => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fetchLeaderboard().then((data: any[]) =>
            setRows(data.map((r) => ({ ...r, total: Number(r.total), completed: Number(r.completed) })))
        )
    }, [])

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={onBack} />
            <div className="flex flex-1 pt-14">
                <SideNav activePage="leaderboard" onHome={onBack} onProgress={onProgress} onLeaderboard={() => {}} onLogout={onLogout} />

                <main className="flex-1 md:ml-60 p-margin-page bg-surface overflow-y-auto">
                    <div className="flex flex-col gap-2 mb-8">
                        <div className="flex items-center gap-2 text-on-surface-variant font-mono text-label-caps">
                            <span className="text-primary">root</span>
                            <span>/</span>
                            <span>workspace</span>
                            <span>/</span>
                            <span className="text-on-surface">leaderboard</span>
                        </div>
                        <h1 className="font-mono text-headline-lg text-on-surface">Leaderboard</h1>
                    </div>

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
