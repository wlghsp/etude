import { describe, it, expect } from 'vitest'
import { sandboxLimits } from './sandbox-limits.js'

describe('sandboxLimits', () => {
    it('모든 유형에 메모리, CPU, 프로세스 수 상한이 있다', () => {
        for (const kind of ['default', 'k8s', 'dind', 'systemd'] as const) {
            const l = sandboxLimits(kind)
            expect(l.Memory).toBeGreaterThan(0)
            expect(l.NanoCpus).toBeGreaterThan(0)
            expect(l.PidsLimit).toBeGreaterThan(0)
        }
    })

    it('스왑을 허용하지 않는다 (MemorySwap == Memory). 메모리 폭주가 스왑으로 번지지 않게', () => {
        for (const kind of ['default', 'k8s', 'dind', 'systemd'] as const) {
            const l = sandboxLimits(kind)
            expect(l.MemorySwap).toBe(l.Memory)
        }
    })

    it('dind는 중첩 도커(이미지 pull, 빌드) 때문에 기본보다 넉넉하고, 기본은 가장 작다', () => {
        expect(sandboxLimits('dind').Memory).toBeGreaterThan(sandboxLimits('default').Memory)
        expect(sandboxLimits('dind').PidsLimit).toBeGreaterThan(sandboxLimits('default').PidsLimit)
        expect(sandboxLimits('systemd').Memory).toBeGreaterThan(sandboxLimits('default').Memory)
    })

    it('호스트 자원을 한 컨테이너가 다 쓰지 못한다: 4 vCPU·23GB 서버에서 한 컨테이너는 CPU 2개, 메모리 2GiB 이하', () => {
        for (const kind of ['default', 'k8s', 'dind', 'systemd'] as const) {
            const l = sandboxLimits(kind)
            expect(l.NanoCpus).toBeLessThanOrEqual(2e9)
            expect(l.Memory).toBeLessThanOrEqual(2 * 1024 ** 3)
        }
    })

    it('k8s 학습자 컨테이너는 helm(차트 인덱스 파싱)이 512MiB에서 메모리 부족으로 죽기 때문에 기본보다 크다', () => {
        expect(sandboxLimits('k8s').Memory).toBeGreaterThanOrEqual(1024 * 1024 ** 2)
        expect(sandboxLimits('k8s').Memory).toBeGreaterThan(sandboxLimits('default').Memory)
    })
})
