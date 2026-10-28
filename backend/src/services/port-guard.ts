import net from 'node:net'

// 파괴적인 기동 정리 전에 포트가 비어 있는지 확인한다. 사용 중이면 EADDRINUSE로 거부한다.
// 확인과 실제 listen 사이에 짧은 틈이 있지만, 이중 실행으로 기존 프로세스의 자원을 지우는 사고를 막기에는 충분하다.
export function assertPortFree(port: number, host: string): Promise<void> {
    return new Promise((resolve, reject) => {
        const probe = net.createServer()
        probe.once('error', reject)
        probe.listen(port, host, () => probe.close(() => resolve()))
    })
}
