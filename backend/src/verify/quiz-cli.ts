// 퀴즈 정답 검증: verify/quiz-proofs.json 의 증명 명령을 실제 컨테이너에서 실행해, 출력에 기대 문자열이 들어 있는지 확인한다.
// image 가 'host' 이면 컨테이너가 아니라 이 컴퓨터에서 실행한다 (클러스터에 접속하는 kubectl 증명용).
// 사용법: npm run verify:quiz
import { execFile } from 'node:child_process'
import { promisify } from 'node:util'
import { readFileSync } from 'node:fs'

const run = promisify(execFile)
interface Proof { set: number; order: number; image: string; cmd: string; expect: string }
const proofs: Proof[] = JSON.parse(readFileSync(new URL('../../verify/quiz-proofs.json', import.meta.url), 'utf8'))

let failed = 0
for (const p of proofs) {
    try {
        const { stdout, stderr } = p.image === 'host'
            ? await run('sh', ['-c', p.cmd], { timeout: 60_000 })
            : await run('docker', ['run', '--rm', p.image, 'sh', '-c', p.cmd], { timeout: 60_000 })
        const out = stdout + stderr
        const ok = out.includes(p.expect)
        console.log(`${ok ? '✓' : '✗'} 세트 ${p.set} #${p.order}  기대: ${JSON.stringify(p.expect)}${ok ? '' : `  실제: ${JSON.stringify(out.slice(0, 200))}`}`)
        if (!ok) failed++
    } catch (e: any) {
        const out = `${e.stdout ?? ''}${e.stderr ?? ''}`
        const ok = out.includes(p.expect)
        console.log(`${ok ? '✓' : '✗'} 세트 ${p.set} #${p.order}  기대: ${JSON.stringify(p.expect)}${ok ? ' (비정상 종료지만 출력 일치)' : `  실패: ${String(e.message).slice(0, 120)} ${JSON.stringify(out.slice(0, 160))}`}`)
        if (!ok) failed++
    }
}
console.log(failed ? `\n실패 ${failed}개` : `\n증명 ${proofs.length}개 모두 통과`)
process.exit(failed ? 1 : 0)
