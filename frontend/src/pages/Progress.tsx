import { useEffect, useMemo, useState } from "react"
import { groupByUnit } from "../units"
import { fetchGamification, fetchGoals, fetchProgress, type CompletionRecord, type Gamification, type Goals, type SetProgress } from "../api/user"
import { weekActivity } from "../activity"
import { MyStatus } from "../components/MyStatus"
import { conqueredCategories } from "../characters"
import { GoalsPanel } from "../components/GoalsPanel"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"
import { formatDuration } from "../components/useQuestTimer"

interface Props {
    onBack: () => void
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

type Filter = { kind: 'all' } | { kind: 'unfinished' } | { kind: 'category'; category: string }

const WEEK_MS = 7 * 24 * 60 * 60 * 1000
const formatDate = (iso: string) => {
    const d = new Date(iso)
    return `${d.getFullYear()}.${String(d.getMonth() + 1).padStart(2, '0')}.${String(d.getDate()).padStart(2, '0')}`
}

// 세트 완료가 기록의 단위다. 문제별 체크나 진행률은 보여 주지 않고, 완료 기록 안에 문제별 내역을 읽기 전용으로 둔다.
export function Progress({ onBack, onLeaderboard, onHall, onReview, onFeed, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [sets, setSets] = useState<SetProgress[] | null>(null)
    const [error, setError] = useState<string | null>(null)
    const [gami, setGami] = useState<Gamification | null>(null)
    const [goals, setGoals] = useState<Goals | null>(null)
    const badges = gami?.badges ?? null
    const level = gami?.level ?? null
    const [filter, setFilter] = useState<Filter>({ kind: 'all' })
    const [openSets, setOpenSets] = useState<Set<number>>(new Set())
    const [openRecords, setOpenRecords] = useState<Set<number>>(new Set())

    useEffect(() => {
        fetchGoals().then(setGoals).catch(() => { /* 목표가 없어도 진행현황은 보인다 */ })
        fetchGamification().then(setGami).catch(() => { /* 배지가 없어도 진행현황은 보인다 */ })
        fetchProgress().then((rows) => { setSets(rows) }).catch((e) => setError(e instanceof Error ? e.message : '진행현황을 불러오지 못했습니다.'))
    }, [])

    const list = sets ?? []
    const completedSets = list.filter((s) => s.completions.length > 0).length
    const allRecords = list.flatMap((s) => s.completions)
    const totalSeconds = allRecords.reduce((sum, r) => sum + r.totalSeconds, 0)
    const weekCount = allRecords.filter((r) => Date.now() - new Date(r.completedAt).getTime() <= WEEK_MS).length
    const rate = list.length > 0 ? Math.round((completedSets / list.length) * 100) : 0
    const categories = useMemo(() => Array.from(new Set(list.map((s) => s.category))), [list])
    const visible = list.filter((s) => {
        if (filter.kind === 'unfinished') return s.completions.length === 0
        if (filter.kind === 'category') return s.category === filter.category
        return true
    })

    const flip = (set: Set<number>, id: number) => {
        const next = new Set(set)
        if (next.has(id)) next.delete(id)
        else next.add(id)
        return next
    }

    const chip = (label: string, active: boolean, onClick: () => void) => (
        <button
            key={label}
            onClick={onClick}
            className={`px-3 py-1.5 font-sans text-label-caps border transition-colors ${active ? 'border-primary text-primary bg-primary/10' : 'border-outline-variant text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high'}`}
        >
            {label}
        </button>
    )

    const card = (icon: string, iconClass: string, label: string, value: string, unit?: string) => (
        <div className="bg-surface-container border border-outline-variant p-4 flex flex-col gap-3">
            <div className="flex items-center gap-2 text-on-surface-variant font-sans text-label-caps"><span className={`material-symbols-outlined text-[18px] ${iconClass}`}>{icon}</span>{label}</div>
            <div className="font-sans text-headline-md text-on-surface tabular-nums">{value}{unit && <span className="text-body-md text-on-surface-variant ml-1">{unit}</span>}</div>
        </div>
    )

    const record = (r: CompletionRecord) => {
        const open = openRecords.has(r.id)
        return (
            <li key={r.id}>
                <button
                    onClick={() => setOpenRecords((prev) => flip(prev, r.id))}
                    aria-expanded={open}
                    disabled={!r.detail}
                    className="w-full flex items-center gap-4 px-5 py-3 text-left hover:bg-surface-container-high disabled:hover:bg-transparent disabled:cursor-default transition-colors"
                >
                    <span className="font-sans text-body-md text-on-surface tabular-nums w-24 shrink-0">{formatDate(r.completedAt)}</span>
                    <span className="font-mono text-code-sm text-on-surface tabular-nums w-28 shrink-0">{formatDuration(r.totalSeconds)}</span>
                    <span className="font-sans text-label-caps text-on-surface-variant flex-1">힌트 없이 {r.hintFreeCount}/{r.questCount} · 풀이 없이 {r.solutionFreeCount}/{r.questCount}</span>
                    {r.detail && <span className="material-symbols-outlined text-[18px] text-on-surface-variant shrink-0">{open ? 'expand_less' : 'expand_more'}</span>}
                </button>
                {open && r.detail && (
                    <ul className="bg-surface border-t border-outline-variant divide-y divide-outline-variant/50">
                        {r.detail.map((d, i) => (
                            <li key={d.questId} className="flex items-center gap-3 px-8 py-2">
                                <span className="font-sans text-body-md text-on-surface flex-1 min-w-0 truncate"><span className="text-on-surface-variant tabular-nums mr-2">{i + 1}.</span>{d.title}</span>
                                {d.hintUsed && <span className="font-sans text-label-caps text-on-surface-variant border border-outline-variant px-1.5 shrink-0">힌트</span>}
                                {d.solutionUsed && <span className="font-sans text-label-caps text-on-surface-variant border border-outline-variant px-1.5 shrink-0">풀이</span>}
                                {d.attempts > 1 && <span className="font-sans text-label-caps text-on-surface-variant border border-outline-variant px-1.5 shrink-0">{d.attempts}번 시도</span>}
                                <span className="font-mono text-code-sm text-on-surface-variant tabular-nums w-20 text-right shrink-0">{formatDuration(d.seconds)}</span>
                            </li>
                        ))}
                    </ul>
                )}
            </li>
        )
    }

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={onBack} />
            <div className="flex flex-1 pt-14">
                <SideNav activePage="progress" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onBack} onProgress={() => {}} onLeaderboard={onLeaderboard} onHall={onHall} onReview={onReview} onFeed={onFeed} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />

                <main className="fx-page flex-1 md:ml-60 flex flex-col items-center px-gutter py-8 bg-surface">
                    <div className="w-full max-w-[900px] flex flex-col gap-8">
                        <div className="flex flex-col gap-2">
                            <div className="flex items-center gap-2 text-on-surface-variant font-sans text-label-caps">
                                <span className="text-primary">root</span><span>/</span><span>workspace</span><span>/</span>
                                <span className="text-on-surface">내 진행현황</span>
                            </div>
                            <h1 className="font-sans text-headline-lg text-on-surface">내 진행현황</h1>
                        </div>

                        {error && <p className="font-sans text-body-md text-error">{error}</p>}
                        {!sets && !error && (
                            <div className="space-y-3 animate-pulse" aria-label="불러오는 중">
                                <div className="h-24 rounded-xl bg-surface-container" />
                                <div className="h-40 rounded-xl bg-surface-container" />
                            </div>
                        )}

                        {sets && <>
                            {gami && <MyStatus userName={userName} totalPct={rate} level={gami.level} streak={gami.streak} week={weekActivity(sets, new Date())} gear={conqueredCategories(sets)} />}
                            {goals && <GoalsPanel goals={goals} />}

                            <section className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                {card('task_alt', 'text-success', '완료한 세트', `${completedSets}`, `/ ${list.length}개 (${rate}%)`)}
                                {card('repeat', 'text-primary', '총 완료 횟수', `${allRecords.length}`, '회')}
                                {card('timer', 'text-primary', '총 학습 시간', totalSeconds > 0 ? formatDuration(totalSeconds) : '-')}
                                {card('calendar_month', 'text-primary', '이번 주 완료', `${weekCount}`, '회')}
                            </section>

                            {badges && (
                                <section className="flex flex-col gap-4">
                                    <div className="flex items-baseline justify-between gap-3">
                                        <h2 className="font-sans text-headline-md text-on-surface">배지 <span className="text-body-md text-on-surface-variant">{badges.filter((b) => b.unlocked).length}/{badges.length}</span></h2>
                                        {level && <span className="font-sans text-label-caps text-gold">Lv.{level.level} {level.title} · {level.xp} XP</span>}
                                    </div>
                                    <ul className="grid grid-cols-2 md:grid-cols-5 gap-3">
                                        {badges.map((b) => (
                                            <li
                                                key={b.id}
                                                title={b.desc}
                                                className={`relative rounded-xl border p-4 text-center transition-all ${b.unlocked ? 'border-gold/50 bg-gradient-to-b from-gold/15 to-transparent hover:-translate-y-0.5' : 'border-outline-variant bg-surface-container-low'}`}
                                            >
                                                <div className={`text-[34px] leading-none ${b.unlocked ? 'fx-pop' : 'grayscale opacity-35'}`}>{b.icon}</div>
                                                <div className={`mt-2 font-sans text-body-md font-bold ${b.unlocked ? 'text-on-surface' : 'text-on-surface-variant'}`}>{b.title}</div>
                                                <div className="mt-0.5 font-sans text-[12px] leading-4 text-on-surface-variant">{b.desc}</div>
                                                {!b.unlocked && <span className="material-symbols-outlined absolute top-2 right-2 text-[16px] text-on-surface-variant/60">lock</span>}
                                            </li>
                                        ))}
                                    </ul>
                                </section>
                            )}

                            <section className="flex flex-col gap-4">
                                <h2 className="font-sans text-headline-md text-on-surface">단원별 진행</h2>
                                {categories.map((c) => (
                                    <div key={c} className="border border-outline-variant bg-surface-container-low p-5 flex flex-col gap-4">
                                        <span className="font-sans text-body-lg font-semibold text-on-surface">{c}</span>
                                        {groupByUnit(list.filter((s) => s.category === c), (s) => ({ unitId: s.unitId, unitTitle: s.unitTitle, unitOrder: s.unitOrder })).map((g) => {
                                            const done = g.items.filter((s) => s.completions.length > 0).length
                                            const pct = Math.round((done / g.items.length) * 100)
                                            return (
                                                <div key={g.unitId ?? 'none'} className="flex flex-col gap-1.5">
                                                    <div className="flex items-baseline justify-between gap-3">
                                                        <span className="font-sans text-body-md text-on-surface">{g.title ? `${g.number}단원 · ${g.title}` : '기타'}</span>
                                                        <span className="font-sans text-code-sm text-on-surface-variant tabular-nums">{done}/{g.items.length} 세트</span>
                                                    </div>
                                                    <div className="h-1.5 bg-surface-container-highest" role="progressbar" aria-valuenow={pct} aria-valuemin={0} aria-valuemax={100}>
                                                        <div className="h-full bg-primary transition-all" style={{ width: `${pct}%` }} />
                                                    </div>
                                                </div>
                                            )
                                        })}
                                    </div>
                                ))}
                            </section>

                            <section className="flex flex-col gap-4">
                                <div className="flex flex-wrap gap-2">
                                    {chip('전체', filter.kind === 'all', () => setFilter({ kind: 'all' }))}
                                    {categories.map((c) => chip(c, filter.kind === 'category' && filter.category === c, () => setFilter({ kind: 'category', category: c })))}
                                    {chip('미완료', filter.kind === 'unfinished', () => setFilter({ kind: 'unfinished' }))}
                                </div>

                                {visible.length === 0 && <p className="font-sans text-body-md text-on-surface-variant">조건에 맞는 세트가 없어요.</p>}

                                <ul className="flex flex-col gap-3">
                                    {visible.map((set) => {
                                        const done = set.completions.length > 0
                                        const open = openSets.has(set.questSetId)
                                        const best = done ? Math.min(...set.completions.map((c) => c.totalSeconds)) : 0
                                        return (
                                            <li key={set.questSetId} className="border border-outline-variant bg-surface-container-low">
                                                <button
                                                    onClick={() => setOpenSets((prev) => flip(prev, set.questSetId))}
                                                    aria-expanded={open}
                                                    disabled={!done}
                                                    className="w-full flex items-center gap-3 px-5 py-4 text-left disabled:cursor-default"
                                                >
                                                    {done
                                                        ? <span className="material-symbols-outlined text-[24px] text-success shrink-0" style={{ fontVariationSettings: "'FILL' 1" }}>check_circle</span>
                                                        : <span className="material-symbols-outlined text-[24px] text-on-surface-variant shrink-0">circle</span>}
                                                    <div className="min-w-0 flex-1">
                                                        <div className="flex items-center gap-2">
                                                            <span className="font-sans text-body-lg text-on-surface truncate"><span className="text-on-surface-variant mr-2">#{set.questSetId}</span>{set.title}</span>
                                                            <span className="px-2 py-0.5 bg-surface border border-outline-variant font-sans text-label-caps text-on-surface-variant shrink-0">{set.category}</span>
                                                        </div>
                                                        <p className={`font-sans text-label-caps mt-1 ${done ? 'text-success' : 'text-on-surface-variant'}`}>
                                                            {done
                                                                ? `완료 ${set.completions.length}회 · 최근 ${formatDate(set.completions[0]!.completedAt)} · 최단 ${formatDuration(best)}`
                                                                : '아직 완료하지 않았어요'}
                                                        </p>
                                                    </div>
                                                    {done && <span className="material-symbols-outlined text-[20px] text-on-surface-variant shrink-0">{open ? 'expand_less' : 'expand_more'}</span>}
                                                </button>
                                                {open && done && (
                                                    <ul className="border-t border-outline-variant divide-y divide-outline-variant">
                                                        {set.completions.map(record)}
                                                    </ul>
                                                )}
                                            </li>
                                        )
                                    })}
                                </ul>
                            </section>
                        </>}
                    </div>
                </main>
            </div>
        </div>
    )
}
