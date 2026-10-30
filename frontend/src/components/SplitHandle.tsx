import { useRef, type RefObject } from 'react'

// 문제 패널과 터미널 사이의 폭 조절 손잡이: 끌거나 방향키로 움직이고, 더블클릭·Home 으로 기본 비율로 되돌린다.
export const SPLIT_MIN = 25
export const SPLIT_MAX = 70
export const SPLIT_DEFAULT = 40

const clamp = (v: number) => Math.min(SPLIT_MAX, Math.max(SPLIT_MIN, v))

interface Props {
    value: number // 문제 패널이 차지하는 비율(%)
    onChange: (pct: number) => void
    containerRef: RefObject<HTMLElement | null> // 두 패널을 담은 영역 (비율 계산의 기준)
}

export function SplitHandle({ value, onChange, containerRef }: Props) {
    const dragging = useRef(false)

    const move = (clientX: number) => {
        const rect = containerRef.current?.getBoundingClientRect()
        if (!rect || rect.width === 0) return
        onChange(clamp(((clientX - rect.left) / rect.width) * 100))
    }

    return (
        <div
            role="separator"
            aria-orientation="vertical"
            aria-label="문제와 터미널의 폭 조절 (방향키로 움직이고 Home 으로 되돌려요)"
            aria-valuemin={SPLIT_MIN}
            aria-valuemax={SPLIT_MAX}
            aria-valuenow={Math.round(value)}
            tabIndex={0}
            title="끌어서 폭 조절 · 더블클릭하면 기본 비율"
            onPointerDown={(e) => { dragging.current = true; e.currentTarget.setPointerCapture(e.pointerId) }}
            onPointerMove={(e) => { if (dragging.current) move(e.clientX) }}
            onPointerUp={(e) => { dragging.current = false; e.currentTarget.releasePointerCapture(e.pointerId) }}
            onDoubleClick={() => onChange(SPLIT_DEFAULT)}
            onKeyDown={(e) => {
                if (e.key === 'ArrowLeft') { e.preventDefault(); onChange(clamp(value - 2)) }
                else if (e.key === 'ArrowRight') { e.preventDefault(); onChange(clamp(value + 2)) }
                else if (e.key === 'Home') { e.preventDefault(); onChange(SPLIT_DEFAULT) }
            }}
            className="group relative w-3 shrink-0 cursor-col-resize touch-none select-none flex items-center justify-center focus:outline-none"
        >
            <span className="h-10 w-1 rounded-full bg-outline-variant transition-colors group-hover:bg-info group-focus-visible:bg-info group-active:bg-info" />
        </div>
    )
}
