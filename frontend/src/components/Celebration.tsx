import { useEffect, useState } from 'react'

const COLORS = ['#facc15', '#f472b6', '#a78bfa', '#38bdf8', '#22c55e', '#f59e0b', '#ef4444', '#e5e2e1']

/** 화면 전체에 색종이가 쏟아지는 축하 연출. 몇 초 뒤 스스로 사라진다. (값은 고정식이라 다시 그려도 모양이 같다) */
export function Celebration({ count = 110, seconds = 6 }: { count?: number; seconds?: number }) {
    const [visible, setVisible] = useState(true)
    useEffect(() => {
        const t = setTimeout(() => setVisible(false), seconds * 1000)
        return () => clearTimeout(t)
    }, [seconds])
    if (!visible) return null
    return (
        <div className="pointer-events-none fixed inset-0 z-[70] overflow-hidden" aria-hidden="true">
            {Array.from({ length: count }, (_, i) => (
                <span
                    key={i}
                    className="fx-fall-piece"
                    style={{
                        '--x': `${(i * 53 + 11) % 100}%`,
                        '--w': `${6 + (i % 4) * 3}px`,
                        '--h': `${10 + (i % 3) * 5}px`,
                        '--c': COLORS[i % COLORS.length],
                        '--t': `${2.6 + (i % 5) * 0.4}s`,
                        '--d': `${(i % 11) * 0.13}s`,
                        '--dx': `${((i * 31) % 220) - 110}px`,
                        '--rot': `${360 + ((i * 47) % 540)}deg`,
                    } as React.CSSProperties}
                />
            ))}
        </div>
    )
}
