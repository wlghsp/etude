import { useEffect, useState } from 'react'

/** 마감 시각(밀리초)까지 남은 초. 실제 시계로 흐르므로 탭을 가려도 멈추지 않는다. 마감이 없으면 null. */
export function useCountdown(deadlineMs: number | null): number | null {
    const calc = () => (deadlineMs === null ? null : Math.max(0, Math.ceil((deadlineMs - Date.now()) / 1000)))
    const [remaining, setRemaining] = useState<number | null>(calc)
    useEffect(() => {
        if (deadlineMs === null) return
        const tick = () => setRemaining(Math.max(0, Math.ceil((deadlineMs - Date.now()) / 1000)))
        tick()
        const id = setInterval(tick, 250)
        return () => clearInterval(id)
    }, [deadlineMs])
    return deadlineMs === null ? null : remaining
}
