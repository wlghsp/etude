import { describe, it, expect } from 'vitest'
import { buildProbes, runPermissionProbes } from './permission-probes.js'
import type { VerifySandbox } from './verify-quest.js'

describe('buildProbes', () => {
    const probes = buildProbes()
    const text = (p: { cmd: string[] }) => p.cmd.join(' ')

    it('허용해야 하는 것과 거부해야 하는 것이 모두 있다', () => {
        expect(probes.some((p) => p.expect === 'allow')).toBe(true)
        expect(probes.some((p) => p.expect === 'deny')).toBe(true)
    })

    it('퀘스트가 실제로 쓰는 동작을 허용 검사에 포함한다: 자기 네임스페이스 파드·설정, 노드·네임스페이스 목록', () => {
        const allow = probes.filter((p) => p.expect === 'allow').map(text).join('\n')
        expect(allow).toContain('get nodes')
        expect(allow).toContain('get namespaces')
        expect(allow).toContain('-n $NS')
        expect(allow).toContain('kubectl run')
    })

    it('핵심 거부를 검사한다: 전체 관리자, 다른 네임스페이스 secret, 클러스터 범위 PV·ClusterRole, hostPath·privileged·hostNetwork 파드, 관리자 인증서 부재', () => {
        const deny = probes.filter((p) => p.expect === 'deny').map(text).join('\n')
        expect(deny).toContain("can-i * * --all-namespaces")
        expect(deny).toContain('get secrets -n kube-system')
        expect(deny).toContain('create persistentvolumes')
        expect(deny).toContain('create clusterroles')
        expect(deny).toContain('hostPath')
        expect(deny).toContain('privileged')
        expect(deny).toContain('hostNetwork')
        expect(deny).toContain('client-certificate')
    })

    it('안전성: 어떤 프로브도 delete를 실행하지 않고, 다른 네임스페이스에는 can-i(변경 없음)로만 접근한다', () => {
        for (const p of probes) {
            expect(text(p)).not.toMatch(/kubectl\s+delete/)
            const touchesOtherNs = /-n (kube-system|default|kube-public)/.test(text(p))
            if (touchesOtherNs) expect(text(p)).toContain('auth can-i')
        }
    })

    it('변경하는 시도(생성)는 자기 네임스페이스($NS)에만 한다', () => {
        for (const p of probes.filter((x) => /kubectl (run|create|apply)/.test(text(x)))) {
            expect(text(p)).toContain('$NS')
        }
    })
})

describe('runPermissionProbes', () => {
    // 프로브 이름 → 종료 코드. 지정하지 않은 것은 기대대로 동작하는 값을 돌려준다.
    function sandboxWith(overrides: Record<string, number> = {}) {
        const probes = buildProbes()
        const byCmd = new Map(probes.map((p) => [p.cmd.join('\u0000'), p]))
        const sandbox: VerifySandbox = {
            exec: async (cmd) => {
                const p = byCmd.get(cmd.join('\u0000'))!
                return overrides[p.name] ?? (p.expect === 'allow' ? 0 : 1)
            },
            dispose: async () => {},
        }
        return sandbox
    }

    it('모든 프로브가 기대대로면 전부 통과한다', async () => {
        const results = await runPermissionProbes(sandboxWith())

        expect(results.every((r) => r.ok)).toBe(true)
    })

    it('거부해야 하는데 허용되면(종료 코드 0) 실패로 보고한다', async () => {
        const results = await runPermissionProbes(sandboxWith({ '전체 관리자 권한이 없다': 0 }))

        const failed = results.filter((r) => !r.ok)
        expect(failed.map((r) => r.name)).toEqual(['전체 관리자 권한이 없다'])
    })

    it('허용해야 하는데 거부되면(종료 코드 비정상) 실패로 보고한다', async () => {
        const results = await runPermissionProbes(sandboxWith({ '노드 목록을 읽을 수 있다': 1 }))

        expect(results.filter((r) => !r.ok).map((r) => r.name)).toEqual(['노드 목록을 읽을 수 있다'])
    })
})
