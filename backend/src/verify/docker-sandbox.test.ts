import { describe, it, expect, vi } from 'vitest'
import { dockerSandboxFactory } from './docker-sandbox.js'

function fakeDocker(inspectResults: Array<{ Running: boolean; ExitCode: number }>) {
    const container = {
        start: vi.fn(async () => {}),
        stop: vi.fn(async () => {}),
        remove: vi.fn(async () => {}),
        exec: vi.fn(async () => {
            let i = 0
            return {
                start: vi.fn(async () => ({ resume() {} })),
                inspect: vi.fn(async () => inspectResults[Math.min(i++, inspectResults.length - 1)]),
            }
        }),
    }
    const docker = { createContainer: vi.fn(async () => container) }
    return { docker: docker as any, container }
}

describe('dockerSandboxFactory', () => {
    it('실제 앱과 같은 이미지·binds로 만들되 etude=verify 라벨을 붙인다 (기동 정리가 지우지 않게)', async () => {
        const { docker } = fakeDocker([{ Running: false, ExitCode: 0 }])

        await dockerSandboxFactory(docker, { image: 'etude-linux', binds: ['/a:/b'] })()

        const opts = docker.createContainer.mock.calls[0][0]
        expect(opts.Image).toBe('etude-linux')
        expect(opts.Labels).toEqual({ etude: 'verify' })
        expect(opts.HostConfig.Binds).toEqual(['/a:/b'])
    })

    it('실행이 끝나면 종료 코드를 돌려준다', async () => {
        const { docker } = fakeDocker([{ Running: true, ExitCode: 0 }, { Running: false, ExitCode: 3 }])
        const sandbox = await dockerSandboxFactory(docker, { image: 'x', binds: null })()

        expect(await sandbox.exec(['sh', '-c', 'false'])).toBe(3)
    })

    it('타임아웃 안에 끝나지 않으면 0이 아닌 값으로 실패 처리한다', async () => {
        const { docker } = fakeDocker([{ Running: true, ExitCode: 0 }])
        const sandbox = await dockerSandboxFactory(docker, { image: 'x', binds: null })()

        expect(await sandbox.exec(['sleep', '999'], 250)).not.toBe(0)
    })

    it('dispose는 중지가 실패해도 삭제한다', async () => {
        const { docker, container } = fakeDocker([{ Running: false, ExitCode: 0 }])
        container.stop.mockRejectedValue(new Error('not running'))
        const sandbox = await dockerSandboxFactory(docker, { image: 'x', binds: null })()

        await sandbox.dispose()

        expect(container.remove).toHaveBeenCalled()
    })

    it('dind 프로필: Privileged로 만들고 기본 Cmd를 덮어쓰지 않으며, docker info가 성공할 때까지 기다린다', async () => {
        // docker info: 처음 두 번은 실패(1), 세 번째 성공(0)
        const results = [
            { Running: false, ExitCode: 1 }, { Running: false, ExitCode: 1 }, { Running: false, ExitCode: 0 },
        ]
        let call = 0
        const container = {
            start: vi.fn(async () => {}),
            stop: vi.fn(async () => {}),
            remove: vi.fn(async () => {}),
            exec: vi.fn(async () => ({
                start: vi.fn(async () => ({ resume() {} })),
                inspect: vi.fn(async () => results[Math.min(call++, results.length - 1)]),
            })),
        }
        const docker = { createContainer: vi.fn(async () => container) } as any

        await dockerSandboxFactory(docker, { image: 'docker:dind', binds: null }, { privileged: true, readyCmd: ['docker', 'info'], readyTimeoutMs: 5000, readyIntervalMs: 10 })()

        const opts = docker.createContainer.mock.calls[0][0]
        expect(opts.HostConfig.Privileged).toBe(true)
        expect(opts.Cmd).toBeUndefined() // dind 이미지의 기본 entrypoint(dockerd)를 그대로 쓴다
        expect(container.exec).toHaveBeenCalledTimes(3)
        expect(container.exec.mock.calls[0][0]).toEqual({ Cmd: ['docker', 'info'] })
    })

    it('준비가 끝나지 않으면 컨테이너를 정리하고 실패한다', async () => {
        const container = {
            start: vi.fn(async () => {}),
            stop: vi.fn(async () => {}),
            remove: vi.fn(async () => {}),
            exec: vi.fn(async () => ({
                start: vi.fn(async () => ({ resume() {} })),
                inspect: vi.fn(async () => ({ Running: false, ExitCode: 1 })),
            })),
        }
        const docker = { createContainer: vi.fn(async () => container) } as any

        await expect(
            dockerSandboxFactory(docker, { image: 'docker:dind', binds: null }, { privileged: true, readyCmd: ['docker', 'info'], readyTimeoutMs: 100, readyIntervalMs: 10 })(),
        ).rejects.toThrow(/준비/)
        expect(container.remove).toHaveBeenCalled()
    })

    it('systemd 프로필: cgroup 바인드와 CgroupnsMode host, Privileged로 만들고 기본 Cmd를 유지한다', async () => {
        const container = {
            start: vi.fn(async () => {}),
            stop: vi.fn(async () => {}),
            remove: vi.fn(async () => {}),
            exec: vi.fn(async () => ({
                start: vi.fn(async () => ({ resume() {} })),
                inspect: vi.fn(async () => ({ Running: false, ExitCode: 0 })),
            })),
        }
        const docker = { createContainer: vi.fn(async () => container) } as any

        await dockerSandboxFactory(docker, { image: 'rockylinux/rockylinux:9-ubi-init', binds: ['/a:/b'] }, {
            privileged: true,
            extraBinds: ['/sys/fs/cgroup:/sys/fs/cgroup:rw'],
            cgroupnsHost: true,
            readyCmd: ['sh', '-c', 'systemctl is-system-running'],
            readyIntervalMs: 10,
        })()

        const opts = docker.createContainer.mock.calls[0][0]
        expect(opts.HostConfig.Privileged).toBe(true)
        expect(opts.HostConfig.CgroupnsMode).toBe('host')
        expect(opts.HostConfig.Binds).toEqual(['/a:/b', '/sys/fs/cgroup:/sys/fs/cgroup:rw'])
        expect(opts.Cmd).toBeUndefined()
    })

    describe('k8s 프로필', () => {
        function fakeK8sDocker() {
            const execCalls: string[][] = []
            const container = {
                id: 'abcdef1234567890',
                start: vi.fn(async () => {}),
                stop: vi.fn(async () => {}),
                remove: vi.fn(async () => {}),
                exec: vi.fn(async (o: { Cmd: string[] }) => {
                    execCalls.push(o.Cmd)
                    return {
                        start: vi.fn(async () => ({ resume() {} })),
                        inspect: vi.fn(async () => ({ Running: false, ExitCode: 0 })),
                    }
                }),
            }
            const docker = { createContainer: vi.fn(async () => container) } as any
            return { docker, container, execCalls }
        }
        const profile = { networkMode: 'k3d-etude', namespacePrefix: 'verify' }

        it('k3d 네트워크로 만들고 컨테이너마다 네임스페이스를 먼저 만든다', async () => {
            const { docker, execCalls } = fakeK8sDocker()

            await dockerSandboxFactory(docker, { image: 'etude-k8s', binds: ['/k:/root/.kube/config:ro'] }, profile)()

            expect(docker.createContainer.mock.calls[0][0].HostConfig.NetworkMode).toBe('k3d-etude')
            expect(execCalls[0]).toEqual(['kubectl', 'create', 'namespace', 'verify-abcdef12'])
        })

        it('이후 모든 명령의 $NS를 그 네임스페이스로 치환한다 (앱이 setup·채점에서 하는 것과 같다)', async () => {
            const { docker, execCalls } = fakeK8sDocker()
            const sandbox = await dockerSandboxFactory(docker, { image: 'etude-k8s', binds: null }, profile)()

            await sandbox.exec(['sh', '-c', 'kubectl get pods -n $NS | grep nginx'])

            expect(execCalls.at(-1)).toEqual(['sh', '-c', 'kubectl get pods -n verify-abcdef12 | grep nginx'])
        })

        it('정리할 때 네임스페이스를 지운 뒤 컨테이너를 삭제한다', async () => {
            const { docker, container, execCalls } = fakeK8sDocker()
            const sandbox = await dockerSandboxFactory(docker, { image: 'etude-k8s', binds: null }, profile)()

            await sandbox.dispose()

            expect(execCalls.at(-1)).toEqual(['kubectl', 'delete', 'namespace', 'verify-abcdef12', '--ignore-not-found', '--wait=false'])
            expect(container.remove).toHaveBeenCalled()
        })

        it('정리할 때 이 네임스페이스의 claimRef를 가진 PersistentVolume(클러스터 범위)도 지운다', async () => {
            const { docker, execCalls } = fakeK8sDocker()
            const sandbox = await dockerSandboxFactory(docker, { image: 'etude-k8s', binds: null }, profile)()

            await sandbox.dispose()

            const pvCleanup = execCalls.find((c) => c[0] === 'sh' && c[2]?.includes('kubectl delete pv'))
            expect(pvCleanup).toBeDefined()
            expect(pvCleanup![2]).toContain('verify-abcdef12')
            expect(pvCleanup![2]).toContain('claimRef.namespace')
            // 네임스페이스 삭제보다 먼저 한다 (claimRef를 찾으려면 PV가 아직 있어야 하고, 컨테이너도 살아 있어야 한다)
            expect(execCalls.indexOf(pvCleanup!)).toBeLessThan(execCalls.findIndex((c) => c[1] === 'delete' && c[2] === 'namespace'))
        })

        it('네임스페이스를 만들지 못하면 컨테이너를 정리하고 실패한다', async () => {
            const { docker, container } = fakeK8sDocker()
            container.exec.mockImplementation(async () => ({
                start: vi.fn(async () => ({ resume() {} })),
                inspect: vi.fn(async () => ({ Running: false, ExitCode: 1 })),
            }) as any)

            await expect(dockerSandboxFactory(docker, { image: 'etude-k8s', binds: null }, profile)()).rejects.toThrow(/네임스페이스/)
            expect(container.remove).toHaveBeenCalled()
        })
    })
})
