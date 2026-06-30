import { useEffect, useState } from "react";
import type { QuestSet } from "../types";
import { fetchQuestSets, fetchProgess } from "../api";
import { SideNav } from "../components/SideNav";
import { TopNav } from "../components/TopNav";

interface Props {
    onSelect: (setId: number, sandboxType: string) => void
    onProgress: () => void
    onLeaderboard: () => void
    onLogout: () => void
}

const CATEGORY_META: Record<string, { icon: string }> = {
    '리눅스': { icon: '🐧' },
    '도커':   { icon: '🐳' },
    'k8s':    { icon: '☸️' },
}

export function SetSelect({ onSelect, onProgress, onLeaderboard, onLogout }: Props) {
    const [sets, setSets] = useState<QuestSet[]>([])
    const [progressMap, setProgressMap] = useState<Record<number, { total: number; completed: number }>>({})
    const [openCategories, setOpenCategories] = useState<Set<string>>(new Set())

    useEffect(() => {
        fetchQuestSets().then(setSets)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        fetchProgess().then((rows: any[]) => {
            const map: Record<number, { total: number; completed: number }> = {}
            rows.forEach(r => { map[r.quest_set_id] = { total: Number(r.total), completed: Number(r.completed) } })
            setProgressMap(map)
        })
    }, [])

    const grouped = sets.reduce<Record<string, QuestSet[]>>((acc, s) => {
        if (!acc[s.category]) acc[s.category] = []
        acc[s.category].push(s)
        return acc
    }, {})

    function toggleCategory(category: string) {
        setOpenCategories(prev => {
            const next = new Set(prev)
            if (next.has(category)) next.delete(category)
            else next.add(category)
            return next
        })
    }

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={() => {}} />

            <div className="flex flex-1 pt-14">
                <SideNav activePage="home" onHome={() => {}} onProgress={onProgress} onLeaderboard={onLeaderboard} onLogout={onLogout} />

                <main className="flex-1 md:ml-60 p-8 bg-surface">
                    <div className="max-w-[1000px] mx-auto space-y-8">
                        {Object.entries(grouped).map(([category, items]) => {
                            const meta = CATEGORY_META[category] ?? { icon: '📁' }
                            const isOpen = openCategories.has(category)
                            return (
                                <section key={category}>
                                    <button
                                        onClick={() => toggleCategory(category)}
                                        className="w-full flex items-center gap-3 pb-3 border-b border-outline-variant hover:text-primary transition-colors"
                                    >
                                        <span className="text-2xl">{meta.icon}</span>
                                        <h2 className="font-mono text-headline-md">{category}</h2>
                                        <span className="ml-auto font-mono text-code-sm text-on-surface-variant">{items.length}개 세트</span>
                                        <span className="material-symbols-outlined text-on-surface-variant transition-transform" style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)' }}>
                                            expand_more
                                        </span>
                                    </button>

                                    {isOpen && (
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
                                            {items.map((s) => {
                                                const p = progressMap[s.id]
                                                const pct = p ? Math.round((p.completed / p.total) * 100) : 0
                                                const isComplete = p && p.completed === p.total && p.total > 0
                                                return (
                                                    <button
                                                        key={s.id}
                                                        onClick={() => onSelect(s.id, s.sandbox_type)}
                                                        className="text-left p-5 border border-outline-variant bg-surface-container-low hover:border-primary hover:bg-surface-container transition-all group"
                                                        onMouseEnter={e => (e.currentTarget.style.transform = 'translateY(-2px)')}
                                                        onMouseLeave={e => (e.currentTarget.style.transform = 'translateY(0)')}
                                                        style={{ transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)' }}
                                                    >
                                                        <div className="flex justify-between items-start mb-6">
                                                            <div className="flex flex-col gap-1">
                                                                <h3 className="font-mono text-body-lg font-semibold text-on-surface group-hover:text-primary transition-colors">
                                                                    {s.title}
                                                                </h3>
                                                                <p className="font-mono text-code-sm text-on-surface-variant">{s.description}</p>
                                                            </div>
                                                            {isComplete && (
                                                                <span className="material-symbols-outlined text-success text-[24px] shrink-0 ml-2" style={{ fontVariationSettings: "'FILL' 1" }}>
                                                                    check_circle
                                                                </span>
                                                            )}
                                                        </div>
                                                        <div className="flex justify-between items-center mb-1">
                                                            <span className="font-mono text-code-sm text-on-surface-variant">
                                                                {p ? `${p.completed}/${p.total} 완료` : '미시작'}
                                                            </span>
                                                            <span className={`font-mono text-code-sm font-bold ${isComplete ? 'text-success' : p && p.completed > 0 ? 'text-primary' : 'text-on-surface-variant'}`}>
                                                                {pct}%
                                                            </span>
                                                        </div>
                                                        <div className="w-full h-1 bg-surface-container-highest">
                                                            <div
                                                                className={`h-full ${isComplete ? 'bg-success' : 'bg-primary'}`}
                                                                style={{ width: `${pct}%` }}
                                                            />
                                                        </div>
                                                    </button>
                                                )
                                            })}
                                        </div>
                                    )}
                                </section>
                            )
                        })}
                    </div>
                </main>
            </div>
        </div>
    )
}
