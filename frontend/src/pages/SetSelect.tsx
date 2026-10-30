import { useEffect, useState } from "react";
import type { QuestSet } from "../types";
import { fetchQuestSets } from "../api/quest";
import { fetchGamification, fetchGoals, fetchProgress, type Gamification, type Goals, type LevelInfo } from "../api/user";
import { SideNav } from "../components/SideNav";
import { TopNav } from "../components/TopNav";
import { groupByUnit } from "../units";
import { SetPath } from "./SetPath";
import { Logo } from "../components/Logo";
import { ProgressRing } from "../components/ProgressRing";

interface Props {
    onSelect: (setId: number, sandboxType: string) => void
    onProgress: () => void
    onLeaderboard: () => void
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

// 분야마다 포인트 색을 달리해 화면이 한 가지 색(검정·회색)으로만 보이지 않게 한다
const CATEGORY_META: Record<string, { icon: string; text: string; border: string; ring: string; grad: string; bar: string; nodeRing: string }> = {
    '리눅스': { icon: '🐧', text: 'text-warning', border: 'border-warning/60', ring: 'text-warning', grad: 'from-warning/15', bar: 'from-warning/70', nodeRing: 'ring-warning/60' },
    '도커':   { icon: '🐳', text: 'text-sky', border: 'border-sky/60', ring: 'text-sky', grad: 'from-sky/15', bar: 'from-sky/70', nodeRing: 'ring-sky/60' },
    'k8s':    { icon: '☸️', text: 'text-accent', border: 'border-accent/60', ring: 'text-accent', grad: 'from-accent/15', bar: 'from-accent/70', nodeRing: 'ring-accent/60' },
}
const DEFAULT_META = { icon: '📁', text: 'text-info', border: 'border-info/60', ring: 'text-info', grad: 'from-info/15', bar: 'from-info/70', nodeRing: 'ring-info/60' }

interface Stats {
    completed: number // 완료한 세트 수
    total: number
    streak: number // 연속 학습일 (오늘 또는 어제까지 이어진 날 수)
    lastCategory: string | null // 가장 최근에 세트를 끝낸 분야
    lastSetId: number | null // 가장 최근에 끝낸 세트 (추천은 그 다음부터 이어진다)
    level: LevelInfo // 경험치와 레벨
}

export function SetSelect({ onSelect, onProgress, onLeaderboard, onHall, onReview, onFeed, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [sets, setSets] = useState<QuestSet[]>([])
    // 세트별 완료 횟수. 세트 완료만 기록으로 보여 주고, 문제별 진행은 보여 주지 않는다.
    const [completedCount, setCompletedCount] = useState<Record<number, number>>({})
    // 사용자가 직접 펼치거나 접은 분야만 기억하고, 그 밖에는 "이어서 학습할 분야"를 펼쳐 둔다
    const [chosen, setChosen] = useState<string | null>(() => { try { return localStorage.getItem('etude.category') } catch { return null } })
    const [stats, setStats] = useState<Stats | null>(null)
    const [goals, setGoals] = useState<Goals | null>(null)
    const [perfectIds, setPerfectIds] = useState<Set<number>>(new Set()) // 힌트·풀이 없이 끝낸 적이 있는 세트

    useEffect(() => {
        fetchQuestSets().then(setSets)
        fetchGoals().then(setGoals).catch(() => { /* 목표가 없어도 세트는 고를 수 있다 */ })
        const noLevel: Gamification = { xp: 0, level: { level: 1, title: '새싹', xp: 0, into: 0, need: 100, pct: 0 }, streak: 0, badges: [] }
        Promise.all([fetchProgress(), fetchGamification().catch(() => noLevel)]).then(([rows, gami]) => {
            const map: Record<number, number> = {}
            rows.forEach(r => { map[r.questSetId] = r.completions.length })
            setCompletedCount(map)
            setPerfectIds(new Set(rows.filter((r) => r.completions.some((c) => c.questCount > 0 && c.hintFreeCount === c.questCount && c.solutionFreeCount === c.questCount)).map((r) => r.questSetId)))

            // 이번 주 완료·마지막 분야는 완료 기록에서 계산하고, 연속 학습일·레벨은 서버 값을 쓴다 (세트 완료만 센다)
            const all = rows.flatMap((r) => r.completions.map((c) => ({ at: new Date(c.completedAt), category: r.category, setId: r.questSetId })))
            const latest = all.reduce<{ at: Date; category: string; setId: number } | null>((best, c) => (!best || c.at > best.at ? c : best), null)
            setStats({
                completed: rows.filter((r) => r.completions.length > 0).length,
                total: rows.length,
                streak: gami.streak,
                lastCategory: latest?.category ?? null,
                lastSetId: latest?.setId ?? null,
                level: gami.level,
            })
        }).catch(() => { /* 완료 표시가 없어도 세트는 고를 수 있다 */ })
    }, [])

    const grouped = sets.reduce<Record<string, QuestSet[]>>((acc, s) => {
        if (!acc[s.category]) acc[s.category] = []
        acc[s.category].push(s)
        return acc
    }, {})

    // 이어서 학습할 세트: 가장 최근에 끝낸 분야(없으면 첫 분야)에서 아직 안 끝낸 첫 세트, 그 분야가 모두 끝났으면 다른 분야에서
    const categoryOrder = Object.keys(grouped)
    const startCategory = stats?.lastCategory && grouped[stats.lastCategory] ? stats.lastCategory : categoryOrder[0]
    // 추천은 "방금 끝낸 세트 다음"으로 이어진다. 앞쪽에 건너뛴 세트가 있어도 거기로 되돌리지 않는다 (세트는 잠기지 않는다). 뒤에 안 한 세트가 없으면 처음부터 찾는다.
    const nextIn = (category: string) => {
        const list = grouped[category] ?? []
        const notDone = (s: QuestSet) => (completedCount[s.id] ?? 0) === 0
        const afterLast = stats?.lastSetId != null ? list.findIndex((s) => s.id === stats.lastSetId) : -1
        return list.slice(afterLast + 1).find(notDone) ?? list.find(notDone)
    }
    const recommendedCategory = startCategory && nextIn(startCategory) ? startCategory : categoryOrder.find((c) => nextIn(c))
    const nextSet = recommendedCategory ? nextIn(recommendedCategory) : undefined
    // 분야 카드로 고른 분야 (고른 적이 없으면 이어서 학습할 분야). 마지막으로 고른 분야는 기억해 둔다.
    const selectedCategory = chosen && grouped[chosen] ? chosen : (recommendedCategory ?? categoryOrder[0])

    function chooseCategory(category: string) {
        setChosen(category)
        try { localStorage.setItem('etude.category', category) } catch { /* 기억하지 못해도 화면은 그대로다 */ }
    }

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={() => {}} />

            <div className="flex flex-1 pt-14">
                <SideNav activePage="home" userName={userName} userEmail={userEmail} userRole={userRole} onHome={() => {}} onProgress={onProgress} onLeaderboard={onLeaderboard} onHall={onHall} onReview={onReview} onFeed={onFeed} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />

                <main className="fx-page flex-1 md:ml-60 p-8 bg-surface bg-[radial-gradient(ellipse_at_top_right,rgba(167,139,250,0.14),transparent_55%),radial-gradient(ellipse_at_bottom_left,rgba(56,189,248,0.08),transparent_50%)]">
                    <div className="max-w-[1000px] mx-auto space-y-8">
                        {stats && (
                            <section aria-label="내 상태" className="flex flex-wrap items-center gap-x-3 gap-y-2 rounded-xl border border-outline-variant bg-gradient-to-r from-accent/15 via-info/10 to-transparent px-4 py-3">
                                <button onClick={onProgress} title="내 진행현황 보기" className="flex flex-wrap items-center gap-x-3 gap-y-1 text-left min-w-0">
                                    <span className="font-sans text-body-md font-semibold text-on-surface truncate">안녕하세요, {userName}님 👋</span>
                                    <span className="rounded-full border border-gold/40 bg-gold/10 px-2.5 py-0.5 font-sans text-label-caps text-gold">Lv.{stats.level.level} {stats.level.title}</span>
                                    {stats.streak > 0 && <span className="font-sans text-label-caps text-gold">🔥 {stats.streak}일 연속</span>}
                                    {goals && <span className="font-sans text-label-caps text-on-surface-variant tabular-nums">🎁 오늘 {goals.today.goals.filter((g) => g.done).length}/{goals.today.goals.length} · {goals.month.label} {goals.month.current}/{goals.month.target}</span>}
                                </button>
                            </section>
                        )}
                        {stats && (nextSet ? (
                            <section aria-label="다음 세트" className="relative overflow-hidden rounded-3xl border border-info/30 bg-gradient-to-br from-info/25 via-accent/15 to-rose/10 px-6 py-6 md:px-8">
                                <div className="flex flex-col md:flex-row md:items-center gap-5">
                                    <Logo size={64} className="shrink-0 drop-shadow-[0_0_18px_rgba(129,140,248,0.5)]" />
                                    <div className="min-w-0 flex-1">
                                        <p className="font-sans text-label-caps text-on-surface-variant">{stats.completed === 0 ? '첫 세트를 시작해 볼까요? 🙂' : '오늘은 이거 해 볼까요? 🙂'}</p>
                                        <h2 className="mt-1 font-sans text-headline-lg text-on-surface">{nextSet.title}</h2>
                                        <p className="mt-1 line-clamp-2 font-sans text-body-md text-on-surface-variant">{nextSet.description.split(/(?<=[.。])\s/)[0]}</p>
                                    </div>
                                    <button
                                        onClick={() => onSelect(nextSet.id, nextSet.sandbox_type)}
                                        className="shrink-0 rounded-2xl bg-white px-7 py-3.5 font-sans text-body-lg font-extrabold text-[#3b1fa8] shadow-[0_5px_0_0_rgba(0,0,0,0.3)] hover:brightness-95 active:translate-y-[3px] active:shadow-[0_2px_0_0_rgba(0,0,0,0.3)] transition-all"
                                    >{stats.completed === 0 ? '시작하기' : '이어서 하기'} →</button>
                                </div>
                            </section>
                        ) : (
                            <section aria-label="다음 세트" className="rounded-3xl border border-success/40 bg-success/10 px-6 py-6 text-center">
                                <p className="font-sans text-headline-md text-on-surface">🎉 모든 세트를 끝냈어요!</p>
                                <p className="mt-1 font-sans text-body-md text-on-surface-variant">원하면 복습으로 더 단단하게 다져 볼 수 있어요.</p>
                                <button onClick={onReview} className="mt-3 font-sans text-label-caps text-info hover:underline">복습 보러 가기 →</button>
                            </section>
                        ))}
                        <div role="tablist" aria-label="분야" className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                            {Object.entries(grouped).map(([category, items]) => {
                                const meta = CATEGORY_META[category] ?? DEFAULT_META
                                const catDone = items.filter((s) => (completedCount[s.id] ?? 0) > 0).length
                                const catPct = items.length > 0 ? Math.round((catDone / items.length) * 100) : 0
                                const nextHere = nextIn(category)
                                const selected = category === selectedCategory
                                return (
                                    <button
                                        key={category}
                                        role="tab"
                                        aria-selected={selected}
                                        onClick={() => chooseCategory(category)}
                                        className={`flex items-center gap-3 rounded-xl border-2 bg-gradient-to-br ${meta.grad} to-transparent px-4 py-3 text-left transition-all ${selected ? `${meta.border} shadow-[0_0_24px_rgba(129,140,248,0.15)]` : 'border-outline-variant opacity-80 hover:opacity-100 hover:border-outline'}`}
                                    >
                                        <span className="text-[30px] leading-none">{meta.icon}</span>
                                        <div className="min-w-0 flex-1">
                                            <h2 className={`font-sans text-headline-md ${meta.text}`}>{category}</h2>
                                            <p className="font-sans text-code-sm text-on-surface-variant truncate">{nextHere ? `다음: #${nextHere.id} ${nextHere.title}` : '모두 끝냈어요! 🎉'}</p>
                                            <p className="font-sans text-code-sm text-on-surface-variant tabular-nums">완료 {catDone}/{items.length} 세트</p>
                                        </div>
                                        <ProgressRing value={catPct} size={44} stroke={5} className={meta.ring}>
                                            <span className="font-sans text-[11px] font-bold text-on-surface tabular-nums">{catPct}%</span>
                                        </ProgressRing>
                                    </button>
                                )
                            })}
                        </div>
                        {Object.entries(grouped).filter(([category]) => category === selectedCategory).map(([category, items]) => {
                            const meta = CATEGORY_META[category] ?? DEFAULT_META
                            return (
                                <section key={category} role="tabpanel">

                                    {(
                                        <div className="space-y-8">
                                            {groupByUnit(items, (s) => ({ unitId: s.unit_id, unitTitle: s.unit_title, unitOrder: s.unit_order })).map((g) => {
                                                const done = g.items.filter((s) => (completedCount[s.id] ?? 0) > 0).length
                                                return (
                                                    <div key={g.unitId ?? 'none'}>
                                                        {g.title && (
                                                            <div className={`flex items-center gap-3 mb-4 rounded-2xl border border-outline-variant bg-gradient-to-r ${meta.grad} to-transparent px-4 py-3`}>
                                                                <ProgressRing value={Math.round((done / g.items.length) * 100)} size={36} stroke={4} className={done === g.items.length ? 'text-success' : meta.ring}>
                                                                    {done === g.items.length
                                                                        ? <span className="material-symbols-outlined text-[18px] text-success" style={{ fontVariationSettings: "'FILL' 1" }}>check</span>
                                                                        : <span className="font-sans text-[10px] font-bold text-on-surface-variant tabular-nums">{done}/{g.items.length}</span>}
                                                                </ProgressRing>
                                                                <h3 className="font-sans text-body-lg font-semibold text-on-surface">{g.number}단원 · {g.title}</h3>
                                                                {done === g.items.length && <span className="px-2 py-0.5 rounded-full border border-success/50 bg-success/10 font-sans text-label-caps text-success">단원 완료</span>}
                                                            </div>
                                                        )}
                                                        <SetPath items={g.items} completedCount={completedCount} perfectIds={perfectIds} nextId={nextSet?.id ?? null} firstTime={(stats?.completed ?? 0) === 0} tone={meta} onSelect={onSelect} />
                                                    </div>
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
