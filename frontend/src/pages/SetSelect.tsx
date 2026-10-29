import { useEffect, useState } from "react";
import type { QuestSet } from "../types";
import { fetchQuestSets } from "../api/quest";
import { fetchProgress } from "../api/user";
import { SideNav } from "../components/SideNav";
import { TopNav } from "../components/TopNav";

interface Props {
    onSelect: (setId: number, sandboxType: string) => void
    onProgress: () => void
    onLeaderboard: () => void
    onAdmin?: () => void
    onLogout: () => void
    onChangePassword: () => void
    userName: string
    userEmail: string
    userRole?: string
}

const CATEGORY_META: Record<string, { icon: string }> = {
    '리눅스': { icon: '🐧' },
    '도커':   { icon: '🐳' },
    'k8s':    { icon: '☸️' },
}

export function SetSelect({ onSelect, onProgress, onLeaderboard, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [sets, setSets] = useState<QuestSet[]>([])
    // 세트별 완료 횟수. 세트 완료만 기록으로 보여 주고, 문제별 진행은 보여 주지 않는다.
    const [completedCount, setCompletedCount] = useState<Record<number, number>>({})
    const [openCategories, setOpenCategories] = useState<Set<string>>(new Set())

    useEffect(() => {
        fetchQuestSets().then(setSets)
        fetchProgress().then((rows) => {
            const map: Record<number, number> = {}
            rows.forEach(r => { map[r.questSetId] = r.completions.length })
            setCompletedCount(map)
        }).catch(() => { /* 완료 표시가 없어도 세트는 고를 수 있다 */ })
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
                <SideNav activePage="home" userName={userName} userEmail={userEmail} userRole={userRole} onHome={() => {}} onProgress={onProgress} onLeaderboard={onLeaderboard} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />

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
                                        <h2 className="font-sans text-headline-md">{category}</h2>
                                        <span className="ml-auto font-sans text-code-sm text-on-surface-variant">{items.length}개 세트</span>
                                        <span className="material-symbols-outlined text-on-surface-variant transition-transform" style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)' }}>
                                            expand_more
                                        </span>
                                    </button>

                                    {isOpen && (
                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
                                            {items.map((s) => {
                                                const doneCount = completedCount[s.id] ?? 0
                                                const isComplete = doneCount > 0
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
                                                                <h3 className="font-sans text-body-lg font-semibold text-on-surface group-hover:text-primary transition-colors">
                                                                    <span className="text-on-surface-variant font-normal mr-2">#{s.id}</span>{s.title}
                                                                </h3>
                                                                <p className="font-sans text-code-sm text-on-surface-variant">{s.description}</p>
                                                            </div>
                                                        </div>
                                                        <div className={`flex items-center gap-1.5 font-sans text-code-sm ${isComplete ? 'text-success font-bold' : 'text-on-surface-variant'}`}>
                                                            {isComplete
                                                                ? <><span className="material-symbols-outlined text-[18px]" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>완료{doneCount > 1 ? ` · ${doneCount}회` : ''}</>
                                                                : '미완료'}
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
