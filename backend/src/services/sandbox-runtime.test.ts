import { describe, it, expect, afterEach, vi } from 'vitest'
import { privilegedSandboxHost } from './sandbox-runtime.js'

afterEach(() => vi.unstubAllEnvs())

describe('privilegedSandboxHost', () => {
    it('SANDBOX_RUNTIME이 없으면 Privileged로 만든다 (dind)', () => {
        vi.stubEnv('SANDBOX_RUNTIME', '')
        expect(privilegedSandboxHost('dind')).toEqual({ Privileged: true, binds: [] })
    })

    it('SANDBOX_RUNTIME이 없으면 systemd는 호스트 cgroup을 마운트한다', () => {
        vi.stubEnv('SANDBOX_RUNTIME', '')
        expect(privilegedSandboxHost('systemd')).toEqual({
            Privileged: true,
            CgroupnsMode: 'host',
            binds: ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
        })
    })

    it('SANDBOX_RUNTIME이 있으면 Privileged·호스트 cgroup 없이 그 런타임을 쓴다', () => {
        vi.stubEnv('SANDBOX_RUNTIME', 'sysbox-runc')
        expect(privilegedSandboxHost('dind')).toEqual({ Runtime: 'sysbox-runc', binds: [] })
        expect(privilegedSandboxHost('systemd')).toEqual({ Runtime: 'sysbox-runc', binds: [] })
    })
})
