import { useEffect, useState } from "react"
import { fetchProgess } from "../api/user"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

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
    onLogout: () => void
    userName: string
    userEmail: string
}

export function Progress({ onBack, onLeaderboard, onLogout, userName, userEmail }: Props) {
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
            <TopNav onHome={onBack} />
            <div className="flex flex-1 pt-14">
                <SideNav activePage="progress" userName={userName} userEmail={userEmail} onHome={onBack} onProgress={() => {}} onLeaderboard={onLeaderboard} onLogout={onLogout} />

                <main className="flex-1 md:ml-60 flex flex-col items-center px-gutter py-8 bg-surface">
                    <div className="w-full max-w-[800px] flex flex-col gap-8">
                        <div className="flex flex-col gap-2">
                            <div className="flex items-center gap-2 text-on-surface-variant font-mono text-label-caps">
                                <span className="text-primary">root</span>
                                <span>/</span>
                                <span>workspace</span>
                                <span>/</span>
                                <span className="text-on-surface">내 진행현황</span>
                            </div>
                            <h1 className="font-mono text-headline-lg text-on-surface">내 진행현황</h1>
                        </div>

                        <section className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div className="bg-surface-container border border-outline-variant p-4 flex flex-col gap-4 relative overflow-hidden">
                                <div className="flex items-center gap-2">
                                    <span className="material-symbols-outlined text-primary text-[18px]">database</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">전체 퀘스트</span>
                                </div>
                                <div className="flex items-baseline gap-2">
                                    <span className="font-mono text-headline-lg">{totalQuests}</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">개</span>
                                </div>
                            </div>
                            <div className="bg-surface-container border border-outline-variant p-4 flex flex-col gap-4 relative overflow-hidden">
                                <div className="flex items-center gap-2">
                                    <span className="material-symbols-outlined text-on-surface-variant text-[18px]">task_alt</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">완료한 퀘스트</span>
                                </div>
                                <div className="flex items-baseline gap-2">
                                    <span className="font-mono text-headline-lg">{totalCompleted}</span>
                                    <span className="font-mono text-label-caps text-on-surface-variant">완료</span>
                                </div>
                            </div>
                            <div className="bg-surface-container border border-outline-variant p-4 flex flex-col gap-4 relative overflow-hidden">
                                <div className="flex items-center gap-2 text-success">
                                    <span className="material-symbols-outlined text-[18px]">query_stats</span>
                                    <span className="font-mono text-label-caps opacity-80">완료율</span>
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

                        <section className="bg-surface-container border border-outline-variant overflow-hidden">
                            <div className="px-4 py-3 border-b border-outline-variant flex justify-between items-center bg-surface-container-high">
                                <span className="font-mono text-label-caps">트레이닝 세트 현황</span>
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
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">세트명</th>
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">카테고리</th>
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">진행률</th>
                                            <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">상태</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-outline-variant">
                                        {rows.map(r => {
                                            const pct = r.total > 0 ? Math.round((r.completed / r.total) * 100) : 0
                                            const isComplete = r.completed === r.total && r.total > 0
                                            const isStarted = r.completed > 0
                                            return (
                                                <tr key={r.quest_set_id} className="hover:bg-surface-container-highest/50 transition-colors">
                                                    <td className="px-6 py-4 font-mono text-body-md">
                                                        <div className="flex items-center gap-2">
                                                            {isComplete
                                                                ? <span className="material-symbols-outlined text-[18px] text-success">check_circle</span>
                                                                : isStarted
                                                                    ? <span className="material-symbols-outlined text-[18px] text-primary">sync</span>
                                                                    : <span className="material-symbols-outlined text-[18px] text-on-surface-variant">circle</span>
                                                            }
                                                            {r.title}
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4">
                                                        <span className="px-2 py-1 bg-surface border border-outline-variant font-mono text-code-sm text-on-surface-variant">
                                                            {r.category}
                                                        </span>
                                                    </td>
                                                    <td className="px-6 py-4">
                                                        <div className="flex flex-col gap-1 w-32">
                                                            <div className="flex justify-between font-mono text-code-sm">
                                                                <span>{r.completed}/{r.total}</span>
                                                                <span>{pct}%</span>
                                                            </div>
                                                            <div className="h-1 bg-surface border border-outline-variant">
                                                                <div className={`h-full ${isComplete ? 'bg-success' : 'bg-primary'}`} style={{ width: `${pct}%` }} />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td className="px-6 py-4">
                                                        {isComplete
                                                            ? <span className="font-mono text-code-sm text-success border border-success/30 px-2 py-1 bg-success/5">완료</span>
                                                            : isStarted
                                                                ? <span className="font-mono text-code-sm text-primary border border-primary/30 px-2 py-1 bg-primary/5">진행 중</span>
                                                                : <span className="font-mono text-code-sm text-on-surface-variant border border-outline-variant px-2 py-1">미시작</span>
                                                        }
                                                    </td>
                                                </tr>
                                            )
                                        })}
                                    </tbody>
                                </table>
                            </div>
                        </section>


                    </div>
                </main>
            </div>
        </div>
    )
}
