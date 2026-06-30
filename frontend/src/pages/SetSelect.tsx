import { useEffect, useState } from "react";
import type { QuestSet } from "../types";
import { fetchQuestSets } from "../api";

interface Props {
    onSelect: (setId: number, sandboxType: string) => void
    onLogout: () => void
}

const CATEGORY_META: Record<string, { icon: string; color: string }> = {
    '리눅스': { icon: '🐧', color: '#4a9eff' },
    '도커':   { icon: '🐳', color: '#2496ed' },
    'k8s':    { icon: '☸️',  color: '#326ce5' },
}

export function SetSelect({ onSelect, onLogout }: Props) {
    const [sets, setSets] = useState<QuestSet[]>([])
    const [openCategories, setOpenCategories] = useState<Set<string>>(new Set())

    useEffect(() => {
        fetchQuestSets().then(setSets)
    }, [])

    const grouped = sets.reduce<Record<string, QuestSet[]>>((acc, s) => {
        if (!acc[s.category]) acc[s.category] = []
        acc[s.category].push(s)
        return acc
    }, {})

    function toggleCategory(category: string) {
        setOpenCategories((prev) => {
            const next = new Set(prev)
            if (next.has(category)) next.delete(category)
            else next.add(category)
            return next
        })
    }

    return (
        <div style={{
            minHeight: '100vh',
            background: '#111',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '2rem',
        }}>
            <div style={{ width: '100%', maxWidth: '520px' }}>
                {/* 헤더 */}
                <div style={{ marginBottom: '2.5rem', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                    <div>
                        <div style={{ fontSize: '11px', letterSpacing: '0.15em', color: '#555', marginBottom: '8px' }}>
                            OKESTRO TRAINING
                        </div>
                        <h1 style={{ fontSize: '32px', fontWeight: 700, color: '#f0f0f0', margin: 0, letterSpacing: '-0.5px' }}>
                            Etude
                        </h1>
                        <p style={{ color: '#555', fontSize: '14px', marginTop: '8px', marginBottom: 0 }}>
                            실습할 트레이닝 세트를 선택하세요.
                        </p>
                    </div>
                    <button
                        onClick={onLogout}
                        style={{
                            background: 'none',
                            border: '1px solid #333',
                            color: '#666',
                            fontSize: '13px',
                            padding: '6px 14px',
                            borderRadius: '6px',
                            cursor: 'pointer',
                        }}
                    >
                        로그아웃
                    </button>
                </div>

                {/* 카테고리 목록 */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                    {Object.entries(grouped).map(([category, items]) => {
                        const isOpen = openCategories.has(category)
                        const meta = CATEGORY_META[category] ?? { icon: '📁', color: '#888' }
                        return (
                            <div key={category} style={{
                                borderRadius: '10px',
                                overflow: 'hidden',
                                border: `1px solid ${isOpen ? meta.color + '44' : '#222'}`,
                                transition: 'border-color 0.15s',
                            }}>
                                {/* 카테고리 헤더 */}
                                <button
                                    onClick={() => toggleCategory(category)}
                                    style={{
                                        width: '100%',
                                        padding: '16px 20px',
                                        background: isOpen ? '#1a1a1a' : '#161616',
                                        border: 'none',
                                        color: '#f0f0f0',
                                        textAlign: 'left',
                                        cursor: 'pointer',
                                        display: 'flex',
                                        alignItems: 'center',
                                        gap: '12px',
                                    }}
                                >
                                    <span style={{ fontSize: '20px', lineHeight: 1 }}>{meta.icon}</span>
                                    <span style={{ fontSize: '15px', fontWeight: 600, flex: 1 }}>{category}</span>
                                    <span style={{ fontSize: '12px', color: '#444' }}>
                                        {items.length}개
                                    </span>
                                    <span style={{
                                        fontSize: '10px',
                                        color: isOpen ? meta.color : '#444',
                                        transition: 'color 0.15s',
                                    }}>
                                        {isOpen ? '▲' : '▼'}
                                    </span>
                                </button>

                                {/* 세트 목록 */}
                                {isOpen && (
                                    <div style={{ borderTop: `1px solid #1e1e1e` }}>
                                        {items.map((s, i) => (
                                            <button
                                                key={s.id}
                                                onClick={() => onSelect(s.id, s.sandbox_type)}
                                                style={{
                                                    width: '100%',
                                                    padding: '14px 20px 14px 52px',
                                                    background: '#141414',
                                                    border: 'none',
                                                    borderTop: i > 0 ? '1px solid #1e1e1e' : 'none',
                                                    color: '#f0f0f0',
                                                    textAlign: 'left',
                                                    cursor: 'pointer',
                                                    display: 'block',
                                                    transition: 'background 0.1s',
                                                }}
                                                onMouseEnter={(e) => (e.currentTarget.style.background = '#1c1c1c')}
                                                onMouseLeave={(e) => (e.currentTarget.style.background = '#141414')}
                                            >
                                                <div style={{ fontSize: '14px', fontWeight: 500, marginBottom: '3px', color: '#e0e0e0' }}>
                                                    {s.title}
                                                </div>
                                                <div style={{ fontSize: '12px', color: '#555', lineHeight: 1.5 }}>
                                                    {s.description}
                                                </div>
                                            </button>
                                        ))}
                                    </div>
                                )}
                            </div>
                        )
                    })}
                </div>
            </div>
        </div>
    )
}
