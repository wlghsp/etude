interface Props {
    value: number // 0~100
    size?: number
    stroke?: number
    className?: string // 링 색은 text-* 로 정한다
    children?: React.ReactNode
}

/** 둥근 진행률 표시. 가운데에 글자나 아이콘을 넣을 수 있다. */
export function ProgressRing({ value, size = 44, stroke = 4, className = 'text-info', children }: Props) {
    const r = (size - stroke) / 2
    const c = 2 * Math.PI * r
    const v = Math.max(0, Math.min(100, value))
    return (
        <div className="relative shrink-0" style={{ width: size, height: size }} role="progressbar" aria-valuenow={Math.round(v)} aria-valuemin={0} aria-valuemax={100}>
            <svg width={size} height={size} className="-rotate-90">
                <circle cx={size / 2} cy={size / 2} r={r} fill="none" strokeWidth={stroke} className="stroke-surface-container-highest" />
                <circle
                    cx={size / 2} cy={size / 2} r={r} fill="none" strokeWidth={stroke} strokeLinecap="round"
                    stroke="currentColor" className={`${className} transition-all duration-700`}
                    strokeDasharray={c} strokeDashoffset={c * (1 - v / 100)}
                />
            </svg>
            <div className="absolute inset-0 flex items-center justify-center">{children}</div>
        </div>
    )
}
