import { useState } from 'react'

interface Quest {
    id: number
    title: string
    description: string
    hint: string
}

interface Props {
    quest: Quest
    containerId: string
    total: number
    index: number
    onPrev: () => void
    onNext: () => void
}

export function QuestPanel({ quest, containerId, total, index, onPrev, onNext }: Props) {
    const [result, setResult] = useState<boolean | null>(null)

    const grade = async () => {
        const res = await fetch('http://localhost:3001/grade', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ containerId, questId: quest.id }),
        })
        const data = await res.json()
        setResult(data.passed)
    }

    return (
        <div style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            <div>
                <div style={{ fontSize: '12px', color: '#666', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
                    Quest {index + 1} / {total}
                </div>
                <h2 style={{ fontSize: '20px', color: '#f0f0f0', margin: 0 }}>{quest.title}</h2>
            </div>
            <p style={{ color: '#bbb', lineHeight: '1.6', fontSize: '14px' }}>{quest.description}</p>
            <details>
                <summary style={{ cursor: 'pointer', color: '#666', fontSize: '13px', userSelect: 'none' }}>힌트 보기</summary>
                <p style={{ color: '#888', fontSize: '13px', marginTop: '8px', paddingLeft: '4px' }}>{quest.hint}</p>
            </details>
            <button
                onClick={grade}
                style={{
                    marginTop: '8px',
                    padding: '10px 20px',
                    background: '#7c3aed',
                    color: '#fff',
                    border: 'none',
                    borderRadius: '6px',
                    fontSize: '14px',
                    fontWeight: 600,
                    cursor: 'pointer',
                    alignSelf: 'flex-start',
                }}
            >
                채점하기
            </button>
            {result !== null && (
                <div style={{
                    padding: '12px 16px',
                    borderRadius: '6px',
                    fontSize: '14px',
                    fontWeight: 500,
                    background: result ? 'rgba(34, 197, 94, 0.1)' : 'rgba(239, 68, 68, 0.1)',
                    color: result ? '#4ade80' : '#f87171',
                    border: `1px solid ${result ? 'rgba(34, 197, 94, 0.3)' : 'rgba(239, 68, 68, 0.3)'}`,
                }}>
                    {result ? '✅ 성공!' : '❌ 아직이에요. 다시 시도해보세요.'}
                </div>
            )}
            <div style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                <button
                    onClick={onPrev}
                    disabled={index === 0}
                    style={{
                        padding: '8px 16px',
                        background: 'transparent',
                        color: index === 0 ? '#444' : '#aaa',
                        border: '1px solid',
                        borderColor: index === 0 ? '#333' : '#555',
                        borderRadius: '6px',
                        fontSize: '13px',
                        cursor: index === 0 ? 'default' : 'pointer',
                    }}
                >
                    이전
                </button>
                <button
                    onClick={onNext}
                    disabled={index === total - 1}
                    style={{
                        padding: '8px 16px',
                        background: 'transparent',
                        color: index === total - 1 ? '#444' : '#aaa',
                        border: '1px solid',
                        borderColor: index === total - 1 ? '#333' : '#555',
                        borderRadius: '6px',
                        fontSize: '13px',
                        cursor: index === total - 1 ? 'default' : 'pointer',
                    }}
                >
                    다음
                </button>
            </div>
        </div>
    )
}
