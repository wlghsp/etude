import { useEffect, useRef, useState } from "react";
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from "@xterm/addon-fit";
import '@xterm/xterm/css/xterm.css'

interface Props {
    sandboxType: string
    questId: number | null
    containerId: string | null
    onConnected: (containerId: string) => void
}

export function Terminal({ sandboxType, questId, containerId, onConnected }: Props) {
    const containerRef = useRef<HTMLDivElement>(null)
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        const term = new XTerm({ cursorBlink: true, fontSize: 14, fontFamily: 'monospace', lineHeight: 1.2 })
        const fitAddon = new FitAddon()
        term.loadAddon(fitAddon)
        term.open(containerRef.current!)
        fitAddon.fit()

        const params = new URLSearchParams({ sandboxType })
        if (questId !== null) params.set('questId', String(questId))
        if (containerId) params.set('containerId', containerId)  // 추가

        const ws = new WebSocket(`ws://${window.location.hostname}:3001/ws/terminal?${params}`)
        ws.binaryType = 'arraybuffer'

        ws.onopen = () => {}

        ws.onmessage = (e) => {
            // binary면 터미널 출력, string이면 JSON 메시지
            if (e.data instanceof ArrayBuffer) {
                term.write(new Uint8Array(e.data))
                return
            }

            try {
                const msg = JSON.parse(e.data)
                if (msg.type === 'connected') {
                    onConnected(msg.containerId)
                    setLoading(false)
                }
            } catch {
                term.write(e.data)
            }
        }

        term.onData((data) => {
            ws.send(data)
        })

        return () => {
            ws.close()
            term.dispose()
        }
    }, []) // eslint-disable-line react-hooks/exhaustive-deps

    return (
        <div style={{ height: '100vh', background: '#000' }}>
            {loading && (
                <div style={{ color: '#666', padding: '1rem', fontSize: '13px' }}>
                    환경 준비 중...
                </div>
            )}
            <div ref={containerRef} style={{ height: '100%', padding: '4px', display: loading ? 'none' : 'block' }} />
        </div>
    )
}