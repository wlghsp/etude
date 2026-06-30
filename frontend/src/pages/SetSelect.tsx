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

const CATEGORY_META: Record<string, { icon: string; color: string }> = {
    '리눅스': { icon: '🐧', color: '#4a9eff' },
    '도커':   { icon: '🐳', color: '#2496ed' },
    'k8s':    { icon: '☸️',  color: '#326ce5' },
}

export function SetSelect({ onSelect, onProgress, onLeaderboard, onLogout }: Props) {
    const [sets, setSets] = useState<QuestSet[]>([])
    const [openCategories, setOpenCategories] = useState<Set<string>>(new Set())
    const [progressMap, setProgressMap] = useState<Record<number, { total: number; completed: number }>>({})

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
        setOpenCategories((prev) => {
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

                {/* Main */}
                <main className="flex-1 md:ml-60 flex flex-col items-center py-12 px-6">
                    <div className="w-full max-w-[520px] space-y-4">
                        {Object.entries(grouped).map(([category, items]) => {
                            const isOpen = openCategories.has(category)
                            const meta = CATEGORY_META[category] ?? { icon: '📁', color: '#888' }
                            return (
                                <div key={category} className="border border-outline-variant bg-surface-container-low overflow-hidden">
                                    <button
                                        onClick={() => toggleCategory(category)}
                                        className="w-full flex items-center justify-between p-4 bg-surface-container-low hover:bg-surface-container-high transition-colors"
                                    >
                                        <div className="flex items-center gap-3">
                                            <span className="text-xl">{meta.icon}</span>
                                            <span className="font-mono text-headline-md">{category}</span>
                                        </div>
                                        <span className="material-symbols-outlined text-on-surface-variant transition-transform" style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)' }}>
                                            expand_more
                                        </span>
                                    </button>

                                    {isOpen && (
                                        <div className="border-t border-outline-variant divide-y divide-outline-variant">
                                            {items.map((s) => {
                                                const p = progressMap[s.id]
                                                const pct = p ? Math.round((p.completed / p.total) * 100) : 0
                                                const isComplete = p && p.completed === p.total && p.total > 0
                                                return (
                                                    <button
                                                        key={s.id}
                                                        onClick={() => onSelect(s.id, s.sandbox_type)}
                                                        className="w-full text-left p-4 bg-surface hover:border-primary border border-transparent transition-all group"
                                                    >
                                                        <div className="flex justify-between items-start mb-4">
                                                            <div className="flex flex-col gap-1">
                                                                <h3 className="font-mono text-headline-md group-hover:text-primary transition-colors">
                                                                    {s.title}
                                                                </h3>
                                                                <p className="font-mono text-code-sm text-on-surface-variant">{s.description}</p>
                                                            </div>
                                                            {isComplete && (
                                                                <span className="material-symbols-outlined text-success" style={{ fontVariationSettings: "'FILL' 1" }}>
                                                                    check_circle
                                                                </span>
                                                            )}
                                                        </div>
                                                        {p && (
                                                            <>
                                                                <div className="flex justify-between items-center mb-1">
                                                                    <span className="font-mono text-code-sm text-on-surface-variant">{p.completed}/{p.total} 완료</span>
                                                                    <span className={`font-mono text-code-sm ${isComplete ? 'text-success' : 'text-primary'}`}>{pct}%</span>
                                                                </div>
                                                                <div className="w-full h-1 bg-surface-container-highest">
                                                                    <div
                                                                        className={`h-full ${isComplete ? 'bg-success' : 'bg-primary'}`}
                                                                        style={{ width: `${pct}%` }}
                                                                    />
                                                                </div>
                                                            </>
                                                        )}
                                                    </button>
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
