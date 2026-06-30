// terminal.ts WebSocket 재현 루프
// connected JSON 수신 여부로 연결 성공 판정
// 사용: node http/ws-test.mjs <ws-url>

import { WebSocket } from 'ws'

const url = process.argv[2]
if (!url) {
    console.error('사용법: node ws-test.mjs <ws-url>')
    process.exit(1)
}

console.log(`연결 중: ${url}`)
const ws = new WebSocket(url)
const timeout = setTimeout(() => {
    console.error('FAIL: 10초 내 connected 메시지 없음 (타임아웃)')
    ws.close()
    process.exit(1)
}, 10000)

ws.on('open', () => {
    console.log('WebSocket 핸드셰이크 성공')
})

ws.on('message', (data) => {
    // connected JSON 메시지는 텍스트, 이후 터미널 출력은 바이너리
    try {
        const msg = JSON.parse(data.toString())
        if (msg.type === 'connected') {
            console.log(`OK: connected 수신 — containerId=${msg.containerId}`)
            clearTimeout(timeout)
            ws.close()
            process.exit(0)
        }
    } catch {
        // 바이너리 터미널 데이터 — 무시
    }
})

ws.on('error', (err) => {
    console.error(`FAIL: WebSocket 에러 — ${err.message}`)
    clearTimeout(timeout)
    process.exit(1)
})

ws.on('close', (code) => {
    if (code !== 1000) {
        console.error(`FAIL: 비정상 종료 — code=${code}`)
        clearTimeout(timeout)
        process.exit(1)
    }
})
