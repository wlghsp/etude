import type { Goals } from '../api/user'

// 오늘의 목표와 이달의 도전. 못 채워도 나쁜 표시는 없고, 채우면 막대가 차고 상자가 열린다. docs/specs/spec_progress_dashboard.md

function Bar({ current, target, done, tone }: { current: number; target: number; done: boolean; tone: string }) {
    const pct = target > 0 ? Math.round((current / target) * 100) : 0
    return (
        <div className="relative h-7 flex-1 overflow-hidden rounded-full bg-surface-container-highest" role="progressbar" aria-valuemin={0} aria-valuemax={target} aria-valuenow={current}>
            <div className={`h-full rounded-full transition-all duration-700 ${done ? 'bg-gradient-to-r from-success to-success/70' : tone}`} style={{ width: `${current > 0 ? Math.max(pct, 8) : 0}%` }} />
            <span className="absolute inset-0 flex items-center justify-center font-sans text-label-caps font-bold tabular-nums text-on-surface drop-shadow">{current} / {target}</span>
        </div>
    )
}

export function GoalsPanel({ goals }: { goals: Goals }) {
    const { today, month } = goals
    const allDone = today.goals.every((g) => g.done)
    return (
        <section aria-label="오늘의 목표" className="rounded-xl border border-outline-variant bg-surface-container-low p-5 space-y-5">
            <div>
                <div className="mb-2 flex items-baseline justify-between gap-3">
                    <h2 className="font-sans text-headline-md text-on-surface">🎁 {month.label}의 도전</h2>
                    <span className="font-sans text-code-sm text-on-surface-variant">{month.done ? '도전 완료! 🎉' : `${month.daysLeft}일 남았어요`}</span>
                </div>
                <div className="flex items-center gap-3">
                    <Bar current={month.current} target={month.target} done={month.done} tone="bg-gradient-to-r from-gold to-rose" />
                    <span className={`text-[26px] leading-none ${month.done ? 'fx-pop' : 'opacity-50 grayscale'}`}>{month.done ? '🎁' : '📦'}</span>
                </div>
                <p className="mt-1 font-sans text-code-sm text-on-surface-variant">이번 달 세트를 {month.target}번 끝내면 완료예요 (복습도 세요).</p>
            </div>

            <div className="border-t border-outline-variant/60 pt-4">
                <div className="mb-3 flex items-baseline justify-between gap-3">
                    <h2 className="font-sans text-headline-md text-on-surface">오늘의 목표</h2>
                    <span className="font-sans text-code-sm text-on-surface-variant">{allDone ? '오늘 목표를 모두 이뤘어요! 🎉' : `오늘 ${today.hoursLeft}시간 남았어요`}</span>
                </div>
                <ul className="space-y-3">
                    {today.goals.map((g) => (
                        <li key={g.key}>
                            <p className="mb-1 font-sans text-body-md text-on-surface">{g.title}</p>
                            <div className="flex items-center gap-3">
                                <Bar current={g.current} target={g.target} done={g.done} tone="bg-gradient-to-r from-sky to-info" />
                                <span className={`text-[24px] leading-none ${g.done ? 'fx-pop' : 'opacity-50 grayscale'}`}>{g.done ? '🎁' : '📦'}</span>
                            </div>
                        </li>
                    ))}
                </ul>
            </div>
        </section>
    )
}
