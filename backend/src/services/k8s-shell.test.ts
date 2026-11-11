import { describe, it, expect } from 'vitest'
import { execFileSync } from 'node:child_process'
import { K8S_BASHRC, K8S_SHELL_CMD } from './terminal.js'

// 피드백 #12: kubectl 별칭은 유지하고, 줄바꿈 없는 출력 뒤에도 프롬프트가 줄 처음에 나오게 한다.
describe('K8S_SHELL_CMD', () => {
    it('별칭 k 와 자동완성을 .bashrc 에 쓰고 그 셸을 exec 한다', () => {
        const script = K8S_SHELL_CMD[2]!
        expect(script).toContain('/root/.bashrc')
        expect(script).toContain('alias k=kubectl')
        expect(script).toContain('complete -o default -F __start_kubectl k')
        expect(script.trim().endsWith('exec /bin/bash')).toBe(true)
    })

    it('프롬프트 직전에 커서 위치를 확인해 줄 중간이면 줄을 바꾼다', () => {
        expect(K8S_BASHRC).toContain('PROMPT_COMMAND=__etude_nl')
        expect(K8S_BASHRC).toContain('\\e[6n')
    })

    it('.bashrc 문법이 올바르다', () => {
        expect(() => execFileSync('bash', ['-n'], { input: K8S_BASHRC })).not.toThrow()
    })
})
