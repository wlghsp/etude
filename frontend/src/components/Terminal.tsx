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
        
        const wsBase = import.meta.env.VITE_WS_BASE ?? ''
        const ws = new WebSocket(`${wsBase}/ws/terminal?${params}`)
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
        <div className="relative" style={{ height: '100vh', background: '#000' }}>
            <div ref={containerRef} style={{ height: '100%', padding: '4px' }} />
            {loading && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/80 gap-3">
                    <div className="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin" />
                    <span className="font-mono text-label-caps text-on-surface-variant">환경 준비 중...</span>
                </div>
            )}
        </div>
    )
}