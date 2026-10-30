import { useState, type ReactNode } from 'react'

// 순서 맞추기·빈칸 채우기: 누르기만으로 풀 수 있다 (끌기 없이도 되고 키보드로도 된다). 정답은 서버만 안다. docs/specs/spec_question_types.md
// 카드·칩은 `백틱`(코드)과 **굵게** 표기를 쓸 수 있도록 부모가 넘긴 renderText 로 그린다.

type Render = (text: string) => ReactNode

const slotTone = (result: boolean | undefined) =>
    result === undefined ? 'border-outline-variant bg-surface-container' : result ? 'border-success bg-success/10' : 'border-error bg-error/10'

interface OrderProps {
    cards: string[] // 섞인 순서로 저장된 카드 글
    value: number[] // 지금까지 놓은 카드 번호 (놓은 순서)
    onChange: (next: number[]) => void
    results: boolean[] | null // 틀렸을 때 자리별 정답 여부
    locked: boolean
    renderText: Render
}

export function OrderQuestion({ cards, value, onChange, results, locked, renderText }: OrderProps) {
    const remaining = cards.map((_, i) => i).filter((i) => !value.includes(i))
    const [dragFrom, setDragFrom] = useState<number | null>(null)
    // 놓은 카드끼리 자리를 바꾼다 (위/아래 버튼이나 끌어서 놓기)
    const move = (from: number, to: number) => {
        if (from === to || to < 0 || to >= value.length) return
        const next = [...value]
        const [card] = next.splice(from, 1)
        next.splice(to, 0, card!)
        onChange(next)
    }
    const arrow = (label: string, icon: string, onClick: () => void, disabled: boolean) => (
        <button onClick={onClick} disabled={disabled || locked} aria-label={label} title={label} className="rounded-md p-1 text-on-surface-variant hover:bg-surface-container-highest hover:text-on-surface disabled:opacity-25 disabled:hover:bg-transparent transition-colors">
            <span className="material-symbols-outlined text-[20px]">{icon}</span>
        </button>
    )
    return (
        <div className="space-y-4">
            <ol aria-label="놓은 순서" className="space-y-2">
                {cards.map((_, slot) => {
                    const card = value[slot]
                    return (
                        <li
                            key={slot}
                            className="flex items-center gap-3"
                            onDragOver={(e) => { if (dragFrom !== null && card !== undefined) e.preventDefault() }}
                            onDrop={(e) => { e.preventDefault(); if (dragFrom !== null) move(dragFrom, slot); setDragFrom(null) }}
                        >
                            <span className="w-6 shrink-0 text-center font-sans text-label-caps text-on-surface-variant tabular-nums">{slot + 1}</span>
                            {card === undefined ? (
                                <span className="flex-1 rounded-lg border-2 border-dashed border-outline-variant px-4 py-3 font-sans text-code-sm text-on-surface-variant">여기에 놓아요</span>
                            ) : (
                                <div
                                    draggable={!locked}
                                    onDragStart={() => setDragFrom(slot)}
                                    onDragEnd={() => setDragFrom(null)}
                                    className={`fx-pop flex flex-1 items-center gap-1 rounded-lg border-2 py-1.5 pl-2 pr-1 transition-colors ${slotTone(results?.[slot])} ${dragFrom === slot ? 'opacity-50' : ''} ${locked ? '' : 'cursor-grab active:cursor-grabbing'}`}
                                >
                                    <span className="material-symbols-outlined text-[20px] text-on-surface-variant/60" aria-hidden="true">drag_indicator</span>
                                    <span className="min-w-0 flex-1 px-1 font-sans text-body-md text-on-surface">{renderText(cards[card]!)}</span>
                                    {arrow('위로', 'keyboard_arrow_up', () => move(slot, slot - 1), slot === 0)}
                                    {arrow('아래로', 'keyboard_arrow_down', () => move(slot, slot + 1), slot === value.length - 1)}
                                    {arrow('빼기', 'close', () => onChange(value.filter((_, i) => i !== slot)), false)}
                                </div>
                            )}
                        </li>
                    )
                })}
            </ol>
            {remaining.length > 0 && (
                <div aria-label="카드 묶음" className="flex flex-wrap gap-2 border-t border-outline-variant/60 pt-4">
                    {remaining.map((i) => (
                        <button
                            key={i}
                            onClick={() => onChange([...value, i])}
                            disabled={locked}
                            className="rounded-lg border border-outline-variant bg-surface-container-high px-4 py-2.5 font-sans text-body-md text-on-surface shadow-[0_3px_0_0_rgba(0,0,0,0.3)] hover:border-info/60 active:translate-y-[2px] active:shadow-none transition-all"
                        >{renderText(cards[i]!)}</button>
                    ))}
                </div>
            )}
        </div>
    )
}

interface FillProps {
    template: string // 빈칸이 {0}, {1} … 로 표시된 명령 줄
    chips: string[]
    value: Array<number | null> // 빈칸마다 고른 칩 번호 (아직이면 null)
    onChange: (next: Array<number | null>) => void
    results: boolean[] | null
    locked: boolean
}

export function FillQuestion({ template, chips, value, onChange, results, locked }: FillProps) {
    const used = value.filter((v): v is number => v !== null)
    const place = (chip: number) => {
        const slot = value.indexOf(null)
        if (slot === -1) return
        onChange(value.map((v, i) => (i === slot ? chip : v)))
    }
    return (
        <div className="space-y-4">
            <pre className="overflow-x-auto whitespace-pre-wrap break-words rounded-lg border border-outline-variant bg-surface-container-lowest px-4 py-4 font-mono text-code-sm leading-8 text-on-surface">
                {template.split(/(\{\d+\})/g).map((part, i) => {
                    const m = /^\{(\d+)\}$/.exec(part)
                    if (!m) return <span key={i}>{part}</span>
                    const slot = Number(m[1])
                    const chip = value[slot]
                    return (
                        <button
                            key={i}
                            onClick={() => chip !== null && chip !== undefined && onChange(value.map((v, j) => (j === slot ? null : v)))}
                            disabled={locked || chip === null || chip === undefined}
                            aria-label={chip === null || chip === undefined ? `빈칸 ${slot + 1}` : `빈칸 ${slot + 1}: ${chips[chip]}. 누르면 비워요`}
                            className={`mx-0.5 inline-flex min-w-[64px] justify-center rounded-md border-2 px-2 align-middle font-mono transition-colors ${chip === null || chip === undefined ? 'border-dashed border-outline text-on-surface-variant' : `fx-pop ${slotTone(results?.[slot])}`} disabled:cursor-default`}
                        >{chip === null || chip === undefined ? '＿＿' : chips[chip]}</button>
                    )
                })}
            </pre>
            <div aria-label="보기 칩" className="flex flex-wrap gap-2">
                {chips.map((c, i) => (
                    <button
                        key={i}
                        onClick={() => place(i)}
                        disabled={locked || used.includes(i) || !value.includes(null)}
                        className="rounded-full border border-outline-variant bg-surface-container-high px-4 py-1.5 font-mono text-code-sm text-on-surface shadow-[0_3px_0_0_rgba(0,0,0,0.3)] hover:border-info/60 active:translate-y-[2px] active:shadow-none transition-all disabled:opacity-35 disabled:shadow-none"
                    >{c}</button>
                ))}
            </div>
        </div>
    )
}
