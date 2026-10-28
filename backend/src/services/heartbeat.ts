import type { WebSocket } from 'ws'

const INTERVAL_MS = 30_000

// 연결 생존 확인. close 이벤트가 오지 않는 단절(절전, Wi-Fi 끊김)도 최대 약 60초 안에 끊는다.
// terminate() 이후의 정리는 일반 close handler가 한다. 여기서는 정리하지 않는다.
export function startHeartbeat(socket: WebSocket): void {
    let alive = true

    const timer = setInterval(() => {
        if (!alive) {
            socket.terminate()
            clearInterval(timer)
            return
        }
        alive = false
        socket.ping()
    }, INTERVAL_MS)
    // 서버 종료를 이 타이머가 막지 않게 한다
    timer.unref()

    socket.on('pong', () => { alive = true })
    socket.on('close', () => clearInterval(timer))
}
