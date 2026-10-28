import { describe, it, expect } from 'vitest'
import { pvCleanupCommand } from './k8s-cleanup.js'

describe('pvCleanupCommand', () => {
    it('이 네임스페이스를 claimRef로 가진 PV를 찾아 지우는 셸 명령을 만든다', () => {
        const [sh, flag, script] = pvCleanupCommand('quest-abc12345')

        expect([sh, flag]).toEqual(['sh', '-c'])
        expect(script).toContain('kubectl get pv')
        expect(script).toContain('claimRef.namespace=="quest-abc12345"')
        expect(script).toContain('kubectl delete pv')
        expect(script).toContain('--ignore-not-found')
    })

    it('대상이 없으면 아무것도 지우지 않는다 (xargs -r)', () => {
        expect(pvCleanupCommand('quest-x')[2]).toContain('xargs -r')
    })

    it('네임스페이스 이름에 셸 메타문자가 있으면 거부한다 (명령 삽입 방지)', () => {
        expect(() => pvCleanupCommand('x"; rm -rf /; "')).toThrow()
        expect(() => pvCleanupCommand('quest abc')).toThrow()
    })
})
