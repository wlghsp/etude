import { useEffect, useRef } from "react";
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from "@xterm/addon-fit";
import '@xterm/xterm/css/xterm.css'


export function Terminal() {
    const containerRef = useRef<HTMLDivElement>(null)

    useEffect(() => {
        const term = new XTerm({ cursorBlink: true })
        const fitAddon = new FitAddon()
        term.loadAddon(fitAddon)
        term.open(containerRef.current!)
        fitAddon.fit()

        const ws = new WebSocket('ws://localhost:3001/ws/terminal')
        ws.binaryType = 'arraybuffer'

        ws.onopen = () => {
            term.writeln('Connected.')
        }

        ws.onmessage = (e) => {
            const data = e.data instanceof ArrayBuffer
                ? new Uint8Array(e.data)
                : e.data 
            term.write(data)
        }

        term.onData((data) => {
            ws.send(data)
        })

        return () => {
            ws.close()
            term.dispose()
        }
    }, [])

    return <div ref={containerRef} style={{ height: '100vh', background: '#000'}} />
}