import { useEffect, useRef, useState } from "react";
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from "@xterm/addon-fit";
import '@xterm/xterm/css/xterm.css'
import { issueTerminalTicket, terminalSocketUrl } from '../api/terminal'
import { ETUDE_BANNER } from '../banner'
import { LoadingScreen } from './LoadingScreen'

export type TerminalStatus = 'connecting' | 'connected' | 'ended'

interface Props {
    questId: number
    fontSize: number
    onConnected: (containerId: string) => void
    // 연결 상태가 바뀔 때 (상위의 로딩·상태 표시용). 연결을 만들지 못했거나 끊기면 'ended'
    onStatus: (status: TerminalStatus) => void
}

export function Terminal({ questId, fontSize, onConnected, onStatus }: Props) {
    const containerRef = useRef<HTMLDivElement>(null)
    const [loading, setLoading] = useState(true)
    // 연결 effect는 한 번만 실행되므로, 글꼴 크기 변경은 ref로 살아 있는 터미널에 전달한다
    const termRef = useRef<XTerm | null>(null)
    const resizeRef = useRef<() => void>(() => {})
    const initialFontSize = useRef(fontSize)

    useEffect(() => {
        if (!termRef.current) return
        termRef.current.options.fontSize = fontSize
        resizeRef.current() // 칸 수가 바뀌므로 맞춰 다시 계산하고 서버에도 알린다
    }, [fontSize])

    useEffect(() => {
        const term = new XTerm({ cursorBlink: true, fontSize: initialFontSize.current, fontFamily: 'monospace', lineHeight: 1.2 })
        const fitAddon = new FitAddon()
        term.loadAddon(fitAddon)
        term.open(containerRef.current!)
        fitAddon.fit()
        term.write(ETUDE_BANNER)

        onStatus('connecting')

        // ticket을 받은 뒤에야 연결하므로 ws는 나중에 생긴다. 그 전에 언마운트되면 연결하지 않는다.
        let ws: WebSocket | null = null
        let cancelled = false

        const sendResize = () => {
            fitAddon.fit()
            if (!ws || ws.readyState !== WebSocket.OPEN) return
            const { cols, rows } = term
            ws.send(JSON.stringify({ type: 'resize', cols, rows }))
        }


        termRef.current = term
        resizeRef.current = sendResize

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
                    onStatus('connected')
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
                onStatus('ended')
                term.write('\r\n\x1b[31m연결이 종료되었습니다. 환경 초기화로 다시 시작하세요.\x1b[0m\r\n')
            }
        }

        issueTerminalTicket(questId)
            .then((ticket) => { if (!cancelled) connect(ticket) })
            .catch(() => {
                if (cancelled) return
                setLoading(false)
                onStatus('ended')
                term.write('\r\n\x1b[31m터미널 연결 준비에 실패했습니다. 다시 로그인하거나 환경 초기화를 시도하세요.\x1b[0m\r\n')
            })

        term.onData((data) => {
            if (ws && ws.readyState === WebSocket.OPEN) ws.send(data)
        })

        // 클립보드 접근은 보안 컨텍스트(https, localhost)에서만 되고 권한이 막힐 수 있어 실패해도 터미널은 계속 쓴다
        const copySelection = () => {
            const text = term.getSelection()
            if (text) navigator.clipboard.writeText(text).catch(() => {})
        }

        // 드래그로 선택하면 바로 복사한다
        term.onSelectionChange(() => { if (term.hasSelection()) copySelection() })

        term.attachCustomKeyEventHandler((e) => {
            if (e.type !== 'keydown' || !e.ctrlKey || e.altKey || e.metaKey) return true
            const key = e.key.toLowerCase()
            // Ctrl+Shift+C: 복사. 브라우저 기본 동작(개발자 도구 선택기)은 막는다
            if (e.shiftKey && key === 'c') {
                e.preventDefault()
                copySelection()
                return false
            }
            // Ctrl+Shift+V: xterm이 제어 문자를 보내지 않게만 하고, 붙여넣기는 브라우저의 paste 이벤트를 xterm이 처리한다
            if (e.shiftKey && key === 'v') return false
            // 선택이 있을 때 Ctrl+C는 복사만 하고 중단 신호(SIGINT)는 보내지 않는다
            if (!e.shiftKey && key === 'c' && term.hasSelection()) {
                copySelection()
                term.clearSelection()
                return false
            }
            return true
        })

        return () => {
            termRef.current = null
            resizeRef.current = () => {}
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
                <div className="absolute inset-0 flex items-center justify-center bg-black/90">
                    <LoadingScreen message="터미널을 연결하고 있어요" />
                </div>
            )}
        </div>
    )
}