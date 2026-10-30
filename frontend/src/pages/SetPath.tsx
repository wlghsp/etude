import { useEffect, useState } from 'react'
import type { QuestSet } from '../types'
import { Logo } from '../components/Logo'

// 한 단원의 세트를 구불구불한 길 위의 노드로 보여 준다 (듀오링고식 + 마스코트 + 보물상자).
// 끝낸 노드는 초록색으로 채워지고 길도 초록으로 이어지며, 다음 노드에는 마스코트가 서서 기다린다.
// 단원을 모두 끝내면 길 끝의 보물상자가 열린다. 세트는 잠기지 않는다 (아무 순서로나 해도 된다).

const ROW = 118 // 노드 한 줄의 높이(px)
const WIDTH = 520 // 길 영역의 폭(px)
const BASE_X = 200 // 길의 중심 x
const OFFSETS = [0, 52, 84, 52, 0, -52, -84, -52] // 노드가 좌우로 굽이치는 정도(px)

interface Props {
    items: QuestSet[]
    completedCount: Record<number, number>
    perfectIds: Set<number> // 힌트·풀이 없이 끝낸 적이 있는 세트
    nextId: number | null // 이어서 할 세트 (마스코트가 서 있는 노드)
    firstTime: boolean // 아직 한 세트도 안 끝냈으면 "여기서 시작!", 진행 중이면 "다음은 여기!"
    tone: { nodeRing: string } // 분야 색
    onSelect: (id: number, sandboxType: string) => void
}

const fallbackIcon = (s: QuestSet) => (s.is_review ? '🏆' : s.sandbox_type === 'quiz' ? '📝' : '💻')

export function SetPath({ items, completedCount, perfectIds, nextId, firstTime, tone, onSelect }: Props) {
    const [openId, setOpenId] = useState<number | 'chest' | null>(null)

    // 열린 설명 카드는 다른 곳을 누르거나 Esc 를 누르면 닫는다 (카드와 노드 안을 누를 때는 그대로)
    useEffect(() => {
        if (openId === null) return
        const onDown = (e: PointerEvent) => { if (!(e.target as Element).closest('[data-setpath-card],[data-setpath-node]')) setOpenId(null) }
        const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpenId(null) }
        document.addEventListener('pointerdown', onDown)
        window.addEventListener('keydown', onKey)
        return () => { document.removeEventListener('pointerdown', onDown); window.removeEventListener('keydown', onKey) }
    }, [openId])

    // 길의 점들: 세트마다 하나, 맨 끝에 보물상자 하나
    const n = items.length
    const pts = Array.from({ length: n + 1 }, (_, i) => ({ x: BASE_X + OFFSETS[i % OFFSETS.length]!, y: i * ROW + ROW / 2 }))
    const allDone = n > 0 && items.every((s) => (completedCount[s.id] ?? 0) > 0)
    const lastDone = items.reduce((m, s, i) => ((completedCount[s.id] ?? 0) > 0 ? i : m), -1)
    const curve = (upTo: number) => {
        let d = `M ${pts[0]!.x} ${pts[0]!.y}`
        for (let i = 1; i <= upTo; i++) {
            const a = pts[i - 1]!, b = pts[i]!
            d += ` C ${a.x} ${a.y + ROW * 0.55}, ${b.x} ${b.y - ROW * 0.55}, ${b.x} ${b.y}`
        }
        return d
    }
    const nextIndex = items.findIndex((s) => s.id === nextId)
    const height = (n + 1) * ROW

    return (
        <div className="relative" style={{ width: WIDTH, maxWidth: '100%', height }}>
            <svg className="pointer-events-none absolute left-0 top-0" width={WIDTH} height={height} aria-hidden="true">
                <path d={curve(n)} fill="none" stroke="currentColor" strokeWidth="6" strokeLinecap="round" strokeDasharray="1 14" className="text-outline-variant" />
                {lastDone >= 0 && <path d={curve(Math.min(lastDone + 1, n))} fill="none" stroke="#22c55e" strokeWidth="8" strokeLinecap="round" opacity="0.9" />}
            </svg>

            {items.map((s, i) => {
                const count = completedCount[s.id] ?? 0
                const done = count > 0
                const perfect = perfectIds.has(s.id)
                const isNext = i === nextIndex
                const open = openId === s.id
                const { x, y } = pts[i]!
                const size = isNext ? 84 : 68
                const cardLeft = Math.min(Math.max(8, x - 150), 150)
                return (
                    <div key={s.id}>
                        {isNext && (
                            <div className="pointer-events-none absolute z-10 flex items-center gap-1" style={{ left: x - size / 2 - 96, top: y - 26 }}>
                                <span className="fx-pop relative rounded-xl bg-white px-2.5 py-1 font-sans text-label-caps font-bold text-[#3b1fa8] shadow">
                                    {count > 0 ? '또 해 볼까?' : firstTime ? '여기서 시작!' : '다음은 여기!'}
                                    <span className="absolute -right-1 top-1/2 -translate-y-1/2 rotate-45 h-2 w-2 bg-white" />
                                </span>
                                <span className="fx-bob"><Logo size={40} className="drop-shadow-[0_0_14px_rgba(129,140,248,0.6)]" /></span>
                            </div>
                        )}
                        <button
                            data-setpath-node=""
                            onClick={() => setOpenId(open ? null : s.id)}
                            aria-expanded={open}
                            aria-label={`${s.title}, ${done ? `${count}번 끝냈어요` : '아직 안 했어요'}${perfect ? ', 퍼펙트' : ''}${isNext ? ', 다음 추천' : ''}`}
                            className={`fx-wiggle absolute z-10 flex items-center justify-center rounded-full border-b-[7px] transition-transform active:translate-y-[3px] active:border-b-[3px] ${isNext ? 'border-[#3b1fa8] bg-gradient-to-br from-info to-accent shadow-[0_0_30px_rgba(129,140,248,0.6)] ring-4 ring-white/70' : done ? 'border-[#15803d] bg-gradient-to-br from-success to-[#4ade80]' : `border-black/50 bg-gradient-to-br from-surface-container-highest to-surface-container-high ring-2 ${tone.nodeRing}`}`}
                            style={{ left: x - size / 2, top: y - size / 2, width: size, height: size }}
                        >
                            <span className={`leading-none ${isNext ? 'text-[38px]' : 'text-[30px]'} ${done || isNext ? '' : 'opacity-90'}`}>{s.icon ?? fallbackIcon(s)}</span>
                            {done && <span className={`absolute -right-1 -top-1 flex h-6 min-w-6 items-center justify-center rounded-full px-1 font-sans text-[12px] font-extrabold shadow ${perfect ? 'bg-gold text-black' : 'bg-white text-[#15803d]'}`}>{perfect ? '★' : '✓'}{count > 1 ? <span className="ml-0.5 tabular-nums">{count}</span> : null}</span>}
                        </button>
                        <button
                            data-setpath-node=""
                            tabIndex={-1}
                            aria-hidden="true"
                            onClick={() => setOpenId(open ? null : s.id)}
                            className="absolute z-0 text-left"
                            style={{ left: x + size / 2 + 14, top: y - 18, width: WIDTH - 10 - (x + size / 2 + 14) }}
                        >
                            <span className={`block truncate font-sans text-body-md font-semibold ${done ? 'text-on-surface' : 'text-on-surface-variant'}`}>{s.title}</span>
                            <span className="font-sans text-code-sm text-on-surface-variant/80">{s.is_review ? '복습 · ' : ''}{done ? (perfect ? '퍼펙트 ★' : '끝냈어요') : isNext ? '다음 추천' : '도전해 봐요'}</span>
                        </button>

                        {open && (
                            <div
                                data-setpath-card=""
                                className="fx-pop absolute z-30 w-[300px] max-w-[calc(100vw-4rem)] rounded-2xl border border-outline-variant bg-surface-container-low p-4 shadow-xl"
                                style={{ left: cardLeft, top: y + size / 2 + 8 }}
                            >
                                <p className="font-sans text-body-md font-semibold text-on-surface"><span className="mr-1.5 font-normal text-on-surface-variant">#{s.id}</span>{s.icon} {s.title}</p>
                                <p className="mt-1 font-sans text-code-sm leading-5 text-on-surface-variant">{s.description}</p>
                                <div className="mt-3 flex items-center gap-3">
                                    <button
                                        onClick={() => onSelect(s.id, s.sandbox_type)}
                                        className="rounded-xl bg-gradient-to-r from-info to-accent px-5 py-2 font-sans text-body-md font-bold text-white shadow-[0_4px_0_0_rgba(0,0,0,0.3)] hover:brightness-110 active:translate-y-[2px] active:shadow-none transition-all"
                                    >{done ? '다시 풀기' : '시작하기'}</button>
                                    <span className={`rounded-full px-2.5 py-0.5 font-sans text-label-caps ${done ? 'bg-success/15 text-success' : 'bg-info/15 text-info'}`}>{done ? `✅ ${count}번 끝냈어요` : '✨ 처음 도전이에요'}</span>
                                </div>
                            </div>
                        )}
                    </div>
                )
            })}

            {/* 길 끝의 보물상자: 이 단원의 세트를 모두 끝내면 열린다. 누르면 무슨 상자인지 알려 준다. */}
            {n > 0 && (() => {
                const { x, y } = pts[n]!
                const doneCount = items.filter((s) => (completedCount[s.id] ?? 0) > 0).length
                const open = openId === 'chest'
                return (
                    <>
                        <button
                            data-setpath-node=""
                            onClick={() => setOpenId(open ? null : 'chest')}
                            aria-expanded={open}
                            aria-label={allDone ? '단원 정복! 단원 상자를 열었어요' : `단원 상자: 세트를 모두 끝내면 열려요 (${doneCount}/${n})`}
                            className="fx-wiggle absolute z-10 flex items-center gap-3 text-left"
                            style={{ left: x - 36, top: y - 36 }}
                        >
                            <span className={`flex h-[72px] w-[72px] items-center justify-center rounded-full border-b-[7px] ${allDone ? 'fx-pop border-[#b45309] bg-gradient-to-br from-gold to-warning shadow-[0_0_34px_rgba(250,204,21,0.6)]' : 'border-black/50 bg-surface-container-high grayscale opacity-60'}`}>
                                <span className="text-[36px] leading-none">{allDone ? '🏆' : '🎁'}</span>
                            </span>
                            <span className={`whitespace-nowrap font-sans text-body-md font-bold ${allDone ? 'text-gold' : 'text-on-surface-variant/80'}`}>{allDone ? '단원 정복! 🎉' : `단원 상자 · ${doneCount}/${n}`}</span>
                        </button>
                        {open && (
                            <div data-setpath-card="" className="fx-pop absolute z-30 w-[300px] max-w-[calc(100vw-4rem)] rounded-2xl border border-outline-variant bg-surface-container-low p-4 shadow-xl" style={{ left: Math.min(Math.max(8, x - 150), 150), top: y + 44 }}>
                                <p className="font-sans text-body-md font-semibold text-on-surface">{allDone ? '🏆 단원 정복!' : '🎁 단원 상자'}</p>
                                <p className="mt-1 font-sans text-code-sm leading-5 text-on-surface-variant">
                                    {allDone ? '이 단원의 모든 세트를 끝냈어요. 단원 정복 배지를 받았고, 소식에도 축하가 올라가요.' : `이 단원의 세트를 모두 끝내면 열리는 상자예요. 지금 ${doneCount}/${n}개 끝냈어요. 순서는 상관없어요.`}
                                </p>
                            </div>
                        )}
                    </>
                )
            })()}
        </div>
    )
}
