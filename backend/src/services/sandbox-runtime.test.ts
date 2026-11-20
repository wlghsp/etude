import { describe, it, expect, afterEach, vi } from 'vitest'
import { dindMirrorCmd, privilegedSandboxHost } from './sandbox-runtime.js'

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

describe('dindMirrorCmd', () => {
    const OLD = process.env.DOCKER_REGISTRY_MIRROR
    afterEach(() => { if (OLD === undefined) delete process.env.DOCKER_REGISTRY_MIRROR; else process.env.DOCKER_REGISTRY_MIRROR = OLD })

    it('미러 환경변수가 없으면 dockerd 에 아무 옵션도 주지 않는다 (Docker Hub 직접 사용)', () => {
        delete process.env.DOCKER_REGISTRY_MIRROR
        expect(dindMirrorCmd()).toEqual([])
    })

    it('http 미러는 --registry-mirror 와 --insecure-registry 를 함께 준다', () => {
        process.env.DOCKER_REGISTRY_MIRROR = 'http://172.17.0.1:5000'
        expect(dindMirrorCmd()).toEqual(['--registry-mirror=http://172.17.0.1:5000', '--insecure-registry=172.17.0.1:5000'])
    })

    it('https 미러는 --registry-mirror 만 준다', () => {
        process.env.DOCKER_REGISTRY_MIRROR = 'https://mirror.example.com'
        expect(dindMirrorCmd()).toEqual(['--registry-mirror=https://mirror.example.com'])
    })
})
