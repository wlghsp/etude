import { useId } from 'react'

/** Etude 로고: 터미널 프롬프트(>_)를 그라데이션 둥근 사각형에 얹은 모양. 크기는 px. */
export function Logo({ size = 28, className = '' }: { size?: number; className?: string }) {
    const id = useId()
    return (
        <svg width={size} height={size} viewBox="0 0 32 32" className={className} role="img" aria-label="Etude">
            <defs>
                <linearGradient id={id} x1="0" y1="0" x2="32" y2="32" gradientUnits="userSpaceOnUse">
                    <stop offset="0" stopColor="#38bdf8" />
                    <stop offset="0.55" stopColor="#6366f1" />
                    <stop offset="1" stopColor="#a78bfa" />
                </linearGradient>
            </defs>
            <rect width="32" height="32" rx="8" fill={`url(#${id})`} />
            <path d="M9 10.5 16 16 9 21.5" fill="none" stroke="#fff" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
            <path d="M18.5 22h6" stroke="#fff" strokeWidth="3" strokeLinecap="round" opacity="0.9" />
        </svg>
    )
}
