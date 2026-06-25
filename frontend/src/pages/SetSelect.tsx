import { useEffect, useState } from "react";
import type { QuestSet } from "../types";
import { fetchQuestSets } from "../api";

interface Props {
    onSelect: (setId: number, sandboxType: string) => void
}

export function SetSelect({ onSelect }: Props) {
    const [sets, setSets] = useState<QuestSet[]>([])

    useEffect(() => {
        fetchQuestSets()
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
                    onClick={() => onSelect(s.id, s.sandbox_type)}
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
                    {s.sandbox_type === 'k8s' && (
                        <div style={{ fontSize: '12px', color: '#555', marginTop: '8px' }}>
                            퀘스트를 이동해도 터미널 환경(네임스페이스)이 유지됩니다.
                        </div>
                    )}
                </button>
                ))}
            </div>
        </div>
    )

}