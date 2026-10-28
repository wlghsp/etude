export interface TerminalSession {
    userId: number
    questSetId: number
    sandboxType: string
}

// 터미널 세션 소유권: containerId → 세션. 컨테이너 수명이 WebSocket 연결에 묶여 있어
// 서버 프로세스 수명과 같으므로 DB 없이 메모리로 충분하다.
const sessions = new Map<string, TerminalSession>()

export function registerSession(containerId: string, session: TerminalSession): void {
    if (sessions.has(containerId)) throw new Error(`session already registered: ${containerId}`)
    sessions.set(containerId, session)
}

export function getSession(containerId: string): TerminalSession | undefined {
    return sessions.get(containerId)
}

// 이미 없어도 에러 없이 끝난다.
export function removeSession(containerId: string): void {
    sessions.delete(containerId)
}
