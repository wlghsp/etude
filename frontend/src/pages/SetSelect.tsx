import { useEffect, useState } from "react";
import type { QuestSet } from "../types";
import { fetchQuestSets } from "../api/quest";
import { fetchProgress } from "../api/user";
import { SideNav } from "../components/SideNav";
import { TopNav } from "../components/TopNav";
import { groupByUnit } from "../units";
import { ProgressRing } from "../components/ProgressRing";
import { WeekStrip } from "../components/WeekStrip";
import { weekActivity, currentStreak, type DayActivity } from "../activity";
import { computeXp, levelInfo, type LevelInfo } from "../gamification";

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

// 분야마다 포인트 색을 달리해 화면이 한 가지 색(검정·회색)으로만 보이지 않게 한다
const CATEGORY_META: Record<string, { icon: string; text: string; border: string; ring: string; grad: string; bar: string }> = {
    '리눅스': { icon: '🐧', text: 'text-warning', border: 'border-warning/60', ring: 'text-warning', grad: 'from-warning/15', bar: 'from-warning/70' },
    '도커':   { icon: '🐳', text: 'text-sky', border: 'border-sky/60', ring: 'text-sky', grad: 'from-sky/15', bar: 'from-sky/70' },
    'k8s':    { icon: '☸️', text: 'text-accent', border: 'border-accent/60', ring: 'text-accent', grad: 'from-accent/15', bar: 'from-accent/70' },
}
const DEFAULT_META = { icon: '📁', text: 'text-info', border: 'border-info/60', ring: 'text-info', grad: 'from-info/15', bar: 'from-info/70' }

interface Stats {
    completed: number // 완료한 세트 수
    total: number
    weekCount: number // 최근 7일 완료 횟수
    streak: number // 연속 학습일 (오늘 또는 어제까지 이어진 날 수)
    lastCategory: string | null // 가장 최근에 세트를 끝낸 분야
    week: DayActivity[] // 최근 7일 하루별 완료 횟수
    level: LevelInfo // 경험치와 레벨
}

export function SetSelect({ onSelect, onProgress, onLeaderboard, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [sets, setSets] = useState<QuestSet[]>([])
    // 세트별 완료 횟수. 세트 완료만 기록으로 보여 주고, 문제별 진행은 보여 주지 않는다.
    const [completedCount, setCompletedCount] = useState<Record<number, number>>({})
    // 사용자가 직접 펼치거나 접은 분야만 기억하고, 그 밖에는 "이어서 학습할 분야"를 펼쳐 둔다
    const [toggled, setToggled] = useState<Record<string, boolean>>({})
    const [stats, setStats] = useState<Stats | null>(null)

    useEffect(() => {
        fetchQuestSets().then(setSets)
        fetchProgress().then((rows) => {
            const map: Record<number, number> = {}
            rows.forEach(r => { map[r.questSetId] = r.completions.length })
            setCompletedCount(map)

            // 연속 학습일·이번 주 완료·마지막 분야는 완료 기록에서 계산한다 (세트 완료만 센다)
            const all = rows.flatMap((r) => r.completions.map((c) => ({ at: new Date(c.completedAt), category: r.category })))
            const now = new Date()
            const streak = currentStreak(rows, now)
            const weekAgo = now.getTime() - 7 * 24 * 60 * 60 * 1000
            const latest = all.reduce<{ at: Date; category: string } | null>((best, c) => (!best || c.at > best.at ? c : best), null)
            setStats({
                completed: rows.filter((r) => r.completions.length > 0).length,
                total: rows.length,
                weekCount: all.filter((c) => c.at.getTime() >= weekAgo).length,
                streak,
                lastCategory: latest?.category ?? null,
                week: weekActivity(rows, now),
                level: levelInfo(computeXp(rows)),
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
    const nextIn = (category: string) => grouped[category]?.find((s) => (completedCount[s.id] ?? 0) === 0)
    const recommendedCategory = startCategory && nextIn(startCategory) ? startCategory : categoryOrder.find((c) => nextIn(c))
    const nextSet = recommendedCategory ? nextIn(recommendedCategory) : undefined
    const isOpenCategory = (category: string) => toggled[category] ?? category === recommendedCategory
    const totalPct = stats && stats.total > 0 ? Math.round((stats.completed / stats.total) * 100) : 0

    function toggleCategory(category: string) {
        setToggled((prev) => ({ ...prev, [category]: !isOpenCategory(category) }))
    }

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={() => {}} />

            <div className="flex flex-1 pt-14">
                <SideNav activePage="home" userName={userName} userEmail={userEmail} userRole={userRole} onHome={() => {}} onProgress={onProgress} onLeaderboard={onLeaderboard} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />

                <main className="fx-page flex-1 md:ml-60 p-8 bg-surface bg-[radial-gradient(ellipse_at_top_right,rgba(167,139,250,0.14),transparent_55%),radial-gradient(ellipse_at_bottom_left,rgba(56,189,248,0.08),transparent_50%)]">
                    <div className="max-w-[1000px] mx-auto space-y-8">
                        {stats && (
                            <section className="relative overflow-hidden rounded-xl border border-outline-variant bg-gradient-to-br from-accent/20 via-info/10 to-warning/10 p-6 md:p-8">
                                <span className="fx-sparkle pointer-events-none absolute top-4 right-6 material-symbols-outlined text-[28px] text-gold" style={{ fontVariationSettings: "'FILL' 1" }}>auto_awesome</span>
                                <div className="flex flex-col md:flex-row md:items-center gap-6">
                                    <ProgressRing value={totalPct} size={112} stroke={9} className="text-gold">
                                        <div className="text-center leading-tight">
                                            <div className="font-sans text-[26px] font-extrabold text-on-surface tabular-nums">{totalPct}%</div>
                                            <div className="font-sans text-[11px] text-on-surface-variant">전체 진행</div>
                                        </div>
                                    </ProgressRing>
                                    <div className="flex-1 min-w-0">
                                        <p className="font-sans text-label-caps text-on-surface-variant">{stats.completed === 0 ? '첫 세트를 시작해 볼까요?' : '오늘도 한 걸음 더'}</p>
                                        <h1 className="font-sans text-headline-lg text-on-surface truncate">안녕하세요, {userName}님 👋</h1>
                                        <div className="mt-3 max-w-[460px]">
                                            <div className="flex items-baseline justify-between font-sans text-label-caps">
                                                <span className="text-gold">Lv.{stats.level.level} {stats.level.title}</span>
                                                <span className="text-on-surface-variant tabular-nums">{stats.level.into} / {stats.level.need} XP</span>
                                            </div>
                                            <div className="mt-1 h-2.5 rounded-full bg-surface-container-highest overflow-hidden" role="progressbar" aria-valuenow={stats.level.pct} aria-valuemin={0} aria-valuemax={100} aria-label="레벨 진행">
                                                <div className="h-full rounded-full bg-gradient-to-r from-gold via-rose to-accent transition-all duration-700" style={{ width: `${Math.max(3, stats.level.pct)}%` }} />
                                            </div>
                                        </div>
                                        <div className="mt-3 flex flex-wrap gap-2">
                                            <span className={`inline-flex items-center gap-1.5 rounded-full border px-3 py-1 font-sans text-label-caps ${stats.streak > 0 ? 'border-gold/50 bg-gold/10 text-gold' : 'border-outline-variant text-on-surface-variant'}`}>
                                                🔥 {stats.streak > 0 ? `연속 ${stats.streak}일 학습 중` : '오늘 첫 세트를 끝내면 연속 기록이 시작돼요'}
                                            </span>
                                            <span className="inline-flex items-center gap-1.5 rounded-full border border-success/40 bg-success/10 px-3 py-1 font-sans text-label-caps text-success">✅ 완료 {stats.completed}/{stats.total} 세트</span>
                                            <span className="inline-flex items-center gap-1.5 rounded-full border border-sky/40 bg-sky/10 px-3 py-1 font-sans text-label-caps text-sky">📅 최근 7일 {stats.weekCount}회 완료</span>
                                        </div>
                                    </div>
                                    <div className="hidden lg:block shrink-0"><WeekStrip days={stats.week} /></div>
                                    {nextSet && (
                                        <button
                                            onClick={() => onSelect(nextSet.id, nextSet.sandbox_type)}
                                            className="shrink-0 md:max-w-[260px] text-left rounded-lg bg-gradient-to-r from-info to-accent px-5 py-4 font-sans text-white hover:brightness-110 active:scale-[0.98] transition-all"
                                        >
                                            <span className="block text-label-caps opacity-90">{stats.completed === 0 ? '시작하기' : '이어서 학습하기'} →</span>
                                            <span className="block text-body-md font-bold truncate">#{nextSet.id} {nextSet.title}</span>
                                        </button>
                                    )}
                                </div>
                            </section>
                        )}
                        {Object.entries(grouped).map(([category, items]) => {
                            const meta = CATEGORY_META[category] ?? DEFAULT_META
                            const catDone = items.filter((s) => (completedCount[s.id] ?? 0) > 0).length
                            const catPct = items.length > 0 ? Math.round((catDone / items.length) * 100) : 0
                            const isOpen = isOpenCategory(category)
                            const nextHere = nextIn(category)
                            return (
                                <section key={category}>
                                    <button
                                        onClick={() => toggleCategory(category)}
                                        aria-expanded={isOpen}
                                        className={`w-full flex items-center gap-4 rounded-lg border border-outline-variant bg-gradient-to-r ${meta.grad} to-transparent px-5 py-4 text-left hover:border-primary/50 transition-colors`}
                                    >
                                        <span className="text-[34px] leading-none">{meta.icon}</span>
                                        <div className="min-w-0">
                                            <h2 className={`font-sans text-headline-md ${meta.text}`}>{category}</h2>
                                            <p className="font-sans text-code-sm text-on-surface-variant truncate">{nextHere ? `다음: #${nextHere.id} ${nextHere.title}` : '모든 세트를 끝냈어요! 🎉'}</p>
                                        </div>
                                        <span className="ml-auto font-sans text-code-sm text-on-surface-variant shrink-0">완료 {catDone}/{items.length} 세트</span>
                                        <ProgressRing value={catPct} size={48} stroke={5} className={meta.ring}>
                                            <span className="font-sans text-[11px] font-bold text-on-surface tabular-nums">{catPct}%</span>
                                        </ProgressRing>
                                        <span className="material-symbols-outlined text-on-surface-variant transition-transform" style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)' }}>
                                            expand_more
                                        </span>
                                    </button>

                                    {isOpen && (
                                        <div className="mt-6 space-y-8">
                                            {groupByUnit(items, (s) => ({ unitId: s.unit_id, unitTitle: s.unit_title, unitOrder: s.unit_order })).map((g) => {
                                                const done = g.items.filter((s) => (completedCount[s.id] ?? 0) > 0).length
                                                return (
                                                    <div key={g.unitId ?? 'none'}>
                                                        {g.title && (
                                                            <div className={`flex items-center gap-3 mb-3 pl-3 border-l-4 ${meta.border}`}>
                                                                <ProgressRing value={Math.round((done / g.items.length) * 100)} size={36} stroke={4} className={done === g.items.length ? 'text-success' : meta.ring}>
                                                                    {done === g.items.length
                                                                        ? <span className="material-symbols-outlined text-[18px] text-success" style={{ fontVariationSettings: "'FILL' 1" }}>check</span>
                                                                        : <span className="font-sans text-[10px] font-bold text-on-surface-variant tabular-nums">{done}/{g.items.length}</span>}
                                                                </ProgressRing>
                                                                <h3 className="font-sans text-body-lg font-semibold text-on-surface">{g.number}단원 · {g.title}</h3>
                                                                {done === g.items.length && <span className="px-2 py-0.5 rounded-full border border-success/50 bg-success/10 font-sans text-label-caps text-success">단원 완료</span>}
                                                            </div>
                                                        )}
                                                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                                            {g.items.map((s, cardIndex) => {
                                                                const doneCount = completedCount[s.id] ?? 0
                                                                const isComplete = doneCount > 0
                                                                return (
                                                                    <button
                                                                        key={s.id}
                                                                        onClick={() => onSelect(s.id, s.sandbox_type)}
                                                                        className={`fx-page relative overflow-hidden text-left p-5 border border-outline-variant bg-surface-container-low hover:border-primary hover:bg-surface-container hover:shadow-[0_6px_24px_rgba(0,0,0,0.35)] transition-all group ${isComplete ? 'border-success/40' : ''}`}
                                                                        onMouseEnter={e => (e.currentTarget.style.transform = 'translateY(-2px)')}
                                                                        onMouseLeave={e => (e.currentTarget.style.transform = 'translateY(0)')}
                                                                        style={{ transition: 'all 0.2s cubic-bezier(0.4, 0, 0.2, 1)', animationDelay: `${Math.min(cardIndex, 8) * 45}ms` }}
                                                                    >
                                                                        <span className={`absolute inset-x-0 top-0 h-1 bg-gradient-to-r ${isComplete ? 'from-success to-gold' : `${meta.bar} to-transparent`}`} aria-hidden="true" />
                                                                        <div className="flex justify-between items-start mb-6">
                                                                            <div className="flex flex-col gap-1">
                                                                                <h3 className="font-sans text-body-lg font-semibold text-on-surface group-hover:text-primary transition-colors">
                                                                                    <span className="text-on-surface-variant font-normal mr-2">#{s.id}</span>{s.title}
                                                                                    {s.sandbox_type === 'quiz' && <span className="ml-2 px-1.5 py-0.5 align-middle border border-primary/50 text-primary font-sans text-label-caps font-normal">퀴즈</span>}
                                                                                    {s.is_review && <span className="ml-2 px-1.5 py-0.5 align-middle border border-primary/50 text-primary font-sans text-label-caps font-normal">복습</span>}
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
