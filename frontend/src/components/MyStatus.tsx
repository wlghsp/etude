import { ProgressRing } from './ProgressRing'
import { WeekStrip } from './WeekStrip'
import type { DayActivity } from '../activity'
import type { LevelInfo } from '../api/user'

interface Props {
    userName: string
    totalPct: number // 전체 진행(%)
    level: LevelInfo
    streak: number
    week: DayActivity[]
}

/** 내 진행현황 맨 위의 "내 상태" 카드: 전체 진행, 레벨·XP, 연속 학습일, 최근 7일. 홈에서는 한 줄 띠로 줄여 보인다. */
export function MyStatus({ userName, totalPct, level, streak, week }: Props) {
    return (
        <section className="relative overflow-hidden rounded-xl border border-outline-variant bg-gradient-to-br from-accent/20 via-info/10 to-warning/10 p-6">
            <span className="fx-sparkle pointer-events-none absolute top-4 right-6 material-symbols-outlined text-[28px] text-gold" style={{ fontVariationSettings: "'FILL' 1" }}>auto_awesome</span>
            <div className="flex flex-col md:flex-row md:items-center gap-6">
                <ProgressRing value={totalPct} size={104} stroke={9} className="text-gold">
                    <div className="text-center leading-tight">
                        <div className="font-sans text-[24px] font-extrabold text-on-surface tabular-nums">{totalPct}%</div>
                        <div className="font-sans text-[11px] text-on-surface-variant">전체 진행</div>
                    </div>
                </ProgressRing>
                <div className="flex-1 min-w-0">
                    <h2 className="font-sans text-headline-md text-on-surface truncate">{userName}님의 상태 👋</h2>
                    <div className="mt-2 max-w-[420px]">
                        <div className="flex items-baseline justify-between font-sans text-label-caps">
                            <span className="text-gold">Lv.{level.level} {level.title}</span>
                            <span className="text-on-surface-variant tabular-nums">{level.into} / {level.need} XP</span>
                        </div>
                        <div className="mt-1 h-2.5 rounded-full bg-surface-container-highest overflow-hidden" role="progressbar" aria-valuenow={level.pct} aria-valuemin={0} aria-valuemax={100} aria-label="레벨 진행">
                            <div className="h-full rounded-full bg-gradient-to-r from-gold via-rose to-accent transition-all duration-700" style={{ width: `${Math.max(3, level.pct)}%` }} />
                        </div>
                    </div>
                    <p className={`mt-3 inline-flex items-center gap-1.5 rounded-full border px-3 py-1 font-sans text-label-caps ${streak > 0 ? 'border-gold/50 bg-gold/10 text-gold' : 'border-outline-variant text-on-surface-variant'}`}>
                        🔥 {streak > 0 ? `연속 ${streak}일 학습 중` : '오늘 첫 세트를 끝내면 연속 기록이 시작돼요'}
                    </p>
                </div>
                <div className="shrink-0 overflow-x-auto"><WeekStrip days={week} /></div>
            </div>
        </section>
    )
}
