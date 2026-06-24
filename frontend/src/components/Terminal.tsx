import { useEffect, useRef } from "react";
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from "@xterm/addon-fit";
import '@xterm/xterm/css/xterm.css'

interface Props {
    sandboxType: string
    questId: number | null
    onConnected: (containerId: string) => void
}

export function Terminal({ sandboxType, questId, onConnected }: Props) {
    const containerRef = useRef<HTMLDivElement>(null)

    useEffect(() => {
        const term = new XTerm({ cursorBlink: true, fontSize: 14, fontFamily: 'monospace', lineHeight: 1.2 })
        const fitAddon = new FitAddon()
        term.loadAddon(fitAddon)
        term.open(containerRef.current!)
        fitAddon.fit()

        const ws = new WebSocket(
            `ws://localhost:3001/ws/terminal?sandboxType=${sandboxType}${questId !== null ? `&questId=${questId}` : ''}`
        )
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

    return <div ref={containerRef} style={{ height: '100vh', background: '#000', padding: '4px' }} />
}