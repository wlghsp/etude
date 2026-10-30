import type { DayActivity } from '../activity'

/** 최근 7일을 요일별 동그라미로 보여 준다. 세트를 끝낸 날은 불꽃으로 채운다. */
export function WeekStrip({ days }: { days: DayActivity[] }) {
    return (
        <div className="flex items-end gap-2" role="list" aria-label="최근 7일 학습 기록">
            {days.map((d, i) => (
                <div key={i} role="listitem" className="flex flex-col items-center gap-1.5" title={`${d.label}요일 ${d.count > 0 ? `${d.count}개 완료` : '쉬었어요'}`}>
                    <div
                        className={`w-9 h-9 rounded-full flex items-center justify-center transition-colors ${
                            d.count > 0 ? 'bg-gradient-to-br from-gold to-warning text-on-primary shadow-[0_0_14px_rgba(250,204,21,0.35)]' : 'bg-surface-container-highest text-on-surface-variant'
                        } ${d.today ? 'ring-2 ring-info ring-offset-2 ring-offset-surface' : ''}`}
                    >
                        {d.count > 0
                            ? <span className="font-sans text-[13px] font-extrabold tabular-nums">{d.count}</span>
                            : <span className="material-symbols-outlined text-[16px] opacity-50">remove</span>}
                    </div>
                    <span className={`font-sans text-[11px] ${d.today ? 'text-info font-bold' : 'text-on-surface-variant'}`}>{d.label}</span>
                </div>
            ))}
        </div>
    )
}
