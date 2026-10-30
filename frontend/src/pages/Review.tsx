import { useEffect, useState } from "react"
import { fetchReview, type Review as ReviewData, type ReviewItem } from "../api/user"
import { fetchQuestSets } from "../api/quest"
import type { QuestSet } from "../types"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

interface Props {
    onHome: () => void
    onSelect: (id: number, sandboxType: string) => void
    onProgress: () => void
    onLeaderboard: () => void
    onHall: () => void
    onFeed: () => void
    onAdmin?: () => void
    onLogout: () => void
    onChangePassword: () => void
    userName: string
    userEmail: string
    userRole?: string
}

const CATEGORY_ICON: Record<string, string> = { '리눅스': '🐧', '도커': '🐳', 'k8s': '☸️' }

export function Review({ onHome, onSelect, onProgress, onLeaderboard, onHall, onFeed, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [data, setData] = useState<ReviewData | null>(null)
    const [error, setError] = useState(false)
    const [sets, setSets] = useState<QuestSet[]>([])

    useEffect(() => {
        fetchReview().then(setData).catch(() => setError(true))
        fetchQuestSets().then(setSets).catch(() => { /* 세트를 못 불러오면 시작 버튼만 막힌다 */ })
    }, [])

    const start = (item: ReviewItem) => {
        const s = sets.find((x) => x.id === item.questSetId)
        if (s) onSelect(s.id, s.sandbox_type)
    }
    const xp = (item: ReviewItem) => item.gainXp !== null && item.gainXp > 0 ? <span className="rounded-full border border-gold/50 bg-gold/10 px-2.5 py-0.5 font-sans text-label-caps text-gold tabular-nums">최대 +{item.gainXp} XP</span> : null

    const row = (item: ReviewItem) => (
        <li key={item.questSetId}>
            <button
                onClick={() => start(item)}
                disabled={sets.length === 0}
                className="w-full flex items-center gap-3 rounded-xl border border-outline-variant bg-surface-container-low px-4 py-3 text-left hover:border-info/60 hover:bg-surface-container transition-colors disabled:opacity-50"
            >
                <span className="text-[26px] leading-none">{CATEGORY_ICON[item.category] ?? '📁'}</span>
                <div className="min-w-0 flex-1">
                    <p className="truncate font-sans text-body-md font-semibold text-on-surface">#{item.questSetId} {item.title}</p>
                    <p className="font-sans text-code-sm text-on-surface-variant">{item.reason}</p>
                </div>
                {xp(item)}
                <span className="material-symbols-outlined text-on-surface-variant">chevron_right</span>
            </button>
        </li>
    )

    const section = (title: string, desc: string, list: ReviewItem[]) => list.length > 0 && (
        <section>
            <h2 className="font-sans text-headline-md text-on-surface">{title} <span className="text-body-md text-on-surface-variant">{list.length}</span></h2>
            <p className="mb-3 font-sans text-code-sm text-on-surface-variant">{desc}</p>
            <ul className="space-y-2">{list.map(row)}</ul>
        </section>
    )

    const empty = data && !data.pick

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={onHome} />
            <div className="flex flex-1 pt-14">
                <SideNav activePage="review" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onHome} onProgress={onProgress} onLeaderboard={onLeaderboard} onReview={() => {}} onHall={onHall} onFeed={onFeed} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />
                <main className="fx-page flex-1 md:ml-60 p-margin-page bg-surface overflow-y-auto">
                    <div className="max-w-[820px] space-y-8">
                        <div className="flex flex-col gap-2">
                            <div className="flex items-center gap-2 text-on-surface-variant font-sans text-label-caps">
                                <span className="text-primary">root</span><span>/</span><span>workspace</span><span>/</span><span className="text-on-surface">복습</span>
                            </div>
                            <h1 className="font-sans text-headline-lg text-on-surface">오늘의 복습</h1>
                        </div>

                        {error && <p className="font-sans text-body-md text-error">복습 목록을 불러오지 못했어요. 잠시 후 다시 열어 주세요.</p>}
                        {!data && !error && <div className="h-40 rounded-xl bg-surface-container animate-pulse" aria-label="불러오는 중" />}

                        {data?.pick && (
                            <section className="relative overflow-hidden rounded-2xl border border-info/40 bg-gradient-to-br from-info/25 via-accent/15 to-rose/10 p-6">
                                <p className="font-sans text-label-caps text-on-surface-variant">오늘의 추천</p>
                                <h2 className="mt-1 font-sans text-headline-lg text-on-surface">#{data.pick.questSetId} {data.pick.title}</h2>
                                <p className="mt-2 max-w-[520px] font-sans text-body-lg text-on-surface-variant">{data.pick.reason}</p>
                                <button
                                    onClick={() => start(data.pick!)}
                                    disabled={sets.length === 0}
                                    className="mt-5 inline-flex items-center gap-2 rounded-xl bg-white px-6 py-3 font-sans text-body-md font-bold text-[#3b1fa8] shadow-[0_4px_0_0_rgba(0,0,0,0.25)] hover:brightness-95 active:translate-y-[2px] active:shadow-[0_2px_0_0_rgba(0,0,0,0.25)] transition-all disabled:opacity-50"
                                >
                                    시작{data.pick.gainXp ? ` +${data.pick.gainXp} XP` : ''}<span className="material-symbols-outlined text-[20px]">arrow_forward</span>
                                </button>
                            </section>
                        )}

                        {empty && (
                            <p className="rounded-xl border border-dashed border-outline-variant px-5 py-6 font-sans text-body-lg text-on-surface">
                                🌟 지금 복습할 세트가 없어요. 잘하고 있어요! 새로운 세트를 하나 더 끝내면 여기에 복습거리가 생겨요.
                            </p>
                        )}

                        {data && <>
                            {section('다시 풀기', '도움을 받고 끝낸 세트예요. 퍼펙트에 도전해 봐요.', data.retry)}
                            {section('복습 세트', '단원 끝에서 배운 것을 섞어 풀어요.', data.reviewSets)}
                            {section('오랜만에', '잊기 전에 한 번 더 풀어 보면 오래 기억에 남아요.', data.stale)}
                        </>}
                    </div>
                </main>
            </div>
        </div>
    )
}
