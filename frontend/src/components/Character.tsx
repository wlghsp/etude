import { stageOf, GEAR } from '../characters'

interface Props {
    level: number
    gear?: string[]   // 정복한 분야 이름들
    size?: number     // 몸 이모지 크기(px)
    showGear?: boolean
}

/** 레벨에 맞는 캐릭터와 정복한 분야의 장비. 모습 정의는 characters.ts 한 곳이다. */
export function Character({ level, gear = [], size = 56, showGear = true }: Props) {
    const stage = stageOf(level)
    const items = gear.map((c) => GEAR[c]).filter((g): g is { icon: string; name: string } => !!g)
    return (
        <span className="inline-flex flex-col items-center" title={`${stage.name}${items.length ? ' · ' + items.map((g) => g.name).join(', ') : ''}`}>
            <span role="img" aria-label={stage.name} className="leading-none" style={{ fontSize: size }}>{stage.body}</span>
            {showGear && items.length > 0 && (
                <span className="mt-1 flex gap-0.5 leading-none" style={{ fontSize: Math.max(12, size / 3.2) }} aria-label={`장비: ${items.map((g) => g.name).join(', ')}`}>
                    {items.map((g) => <span key={g.name}>{g.icon}</span>)}
                </span>
            )}
        </span>
    )
}
