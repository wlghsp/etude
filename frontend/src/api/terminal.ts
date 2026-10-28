import { BASE, authHeaders } from './base'

// 터미널 WebSocket 연결용 일회용 ticket (30초, 1회 사용). 샌드박스 타입은 서버가 questId로 확정한다.
export async function issueTerminalTicket(questId: number): Promise<string> {
  const res = await fetch(`${BASE}/terminal-sessions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ questId }),
  })
  if (!res.ok) throw new Error(`terminal ticket failed: ${res.status}`)
  const { ticket } = await res.json()
  return ticket
}

export function terminalSocketUrl(ticket: string): string {
  const wsBase = import.meta.env.VITE_WS_BASE ?? ''
  return `${wsBase}/ws/terminal?${new URLSearchParams({ ticket })}`
}
