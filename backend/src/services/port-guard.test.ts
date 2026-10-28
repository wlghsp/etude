import { describe, it, expect } from 'vitest'
import net from 'node:net'
import { assertPortFree } from './port-guard.js'

function listenOnRandomPort(host = '0.0.0.0'): Promise<net.Server> {
    return new Promise((resolve, reject) => {
        const server = net.createServer()
        server.once('error', reject)
        server.listen(0, host, () => resolve(server))
    })
}

const portOf = (server: net.Server) => (server.address() as net.AddressInfo).port
const close = (server: net.Server) => new Promise<void>((r) => server.close(() => r()))

describe('assertPortFree', () => {
    it('이미 사용 중인 포트면 EADDRINUSE로 거부한다', async () => {
        const busy = await listenOnRandomPort()
        try {
            await expect(assertPortFree(portOf(busy), '0.0.0.0')).rejects.toMatchObject({ code: 'EADDRINUSE' })
        } finally {
            await close(busy)
        }
    })

    it('비어 있는 포트면 통과하고, 확인에 쓴 임시 서버는 닫혀 이후 실제로 listen할 수 있다', async () => {
        const probe = await listenOnRandomPort()
        const port = portOf(probe)
        await close(probe)

        await expect(assertPortFree(port, '0.0.0.0')).resolves.toBeUndefined()

        const real = net.createServer()
        await new Promise<void>((resolve, reject) => {
            real.once('error', reject)
            real.listen(port, '0.0.0.0', () => resolve())
        })
        await close(real)
    })
})
