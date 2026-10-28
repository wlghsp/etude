import { useEffect, useRef, useState } from "react";
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from "@xterm/addon-fit";
import '@xterm/xterm/css/xterm.css'
import { issueTerminalTicket, terminalSocketUrl } from '../api/terminal'

interface Props {
    questId: number
    onConnected: (containerId: string) => void
    // 연결을 만들지 못했거나 끊겼을 때 (상위의 로딩 표시를 풀기 위해)
    onEnded: () => void
}

export function Terminal({ questId, onConnected, onEnded }: Props) {
    const containerRef = useRef<HTMLDivElement>(null)
    const [loading, setLoading] = useState(true)

    useEffect(() => {
        const term = new XTerm({ cursorBlink: true, fontSize: 14, fontFamily: 'monospace', lineHeight: 1.2 })
        const fitAddon = new FitAddon()
        term.loadAddon(fitAddon)
        term.open(containerRef.current!)
        fitAddon.fit()

        // ticket을 받은 뒤에야 연결하므로 ws는 나중에 생긴다. 그 전에 언마운트되면 연결하지 않는다.
        let ws: WebSocket | null = null
        let cancelled = false

        const sendResize = () => {
            fitAddon.fit()
            if (!ws || ws.readyState !== WebSocket.OPEN) return
            const { cols, rows } = term
            ws.send(JSON.stringify({ type: 'resize', cols, rows }))
        }


        // 브라우저 창 크기 변경 대응
        const resizeObserver = new ResizeObserver(() => sendResize())
        resizeObserver.observe(containerRef.current!)

        const connect = (ticket: string) => {
            const socket = new WebSocket(terminalSocketUrl(ticket))
            ws = socket
            socket.binaryType = 'arraybuffer'

            // WebSocket 연결 성공 시 최소 1회
            socket.onopen = () => sendResize()

            socket.onmessage = (e) => {
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
                        // onopen 시점의 resize는 백엔드 핸들러 등록 전이라 유실될 수 있어 다시 보낸다
                        sendResize()
                    }
                } catch {
                    term.write(e.data)
                }
            }

            // 서버가 연결을 거부하거나 끊으면(무효 ticket, heartbeat 실패 등) 스피너를 계속 돌리지 않는다
            socket.onclose = () => {
                if (cancelled) return
                setLoading(false)
                onEnded()
                term.write('\r\n\x1b[31m연결이 종료되었습니다. 환경 초기화로 다시 시작하세요.\x1b[0m\r\n')
            }
        }

        issueTerminalTicket(questId)
            .then((ticket) => { if (!cancelled) connect(ticket) })
            .catch(() => {
                if (cancelled) return
                setLoading(false)
                onEnded()
                term.write('\r\n\x1b[31m터미널 연결 준비에 실패했습니다. 다시 로그인하거나 환경 초기화를 시도하세요.\x1b[0m\r\n')
            })

        term.onData((data) => {
            if (ws && ws.readyState === WebSocket.OPEN) ws.send(data)
        })

        return () => {
            cancelled = true
            ws?.close()
            term.dispose()
            resizeObserver.disconnect()
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