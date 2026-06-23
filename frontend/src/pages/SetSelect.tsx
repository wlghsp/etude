import { useEffect, useState } from "react";

interface QuestSet {
    id: number
    title: string
    description: string
}

interface Props {
    onSelect: (setId: number) => void
}

export function SetSelect({ onSelect }: Props) {
    const [sets, setSets] = useState<QuerySet[]>([])

    useEffect(() => {
        fetch('http://localhost:3001/quest-sets')
          .then((r) => r.json())
          .then(setSets)
    }, [])

    return (
        <div style={{ padding: '3rem', maxWidth: '600px', margin: '0 auto' }}>
            <h1 style={{ fontSize: '24px', color: '#f0f0f0', marginBottom: '8px' }}>Etude</h1>
            <p style={{ color: '#666', fontSize: '14px', marginBottom: '2rem' }}>트레이닝 세트를 선택하세요.</p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {sets.map((s) => (
                <button
                    key={s.id}
                    onClick={() => onSelect(s.id)}
                    style={{
                    padding: '20px 24px',
                    background: '#1e1e1e',
                    border: '1px solid #2a2a2a',
                    borderRadius: '8px',
                    color: '#f0f0f0',
                    textAlign: 'left',
                    cursor: 'pointer',
                    }}
                >
                    <div style={{ fontSize: '16px', fontWeight: 600, marginBottom: '4px' }}>{s.title}</div>
                    <div style={{ fontSize: '13px', color: '#888' }}>{s.description}</div>
                </button>
                ))}
            </div>
        </div>
    )

}