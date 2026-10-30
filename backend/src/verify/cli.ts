import 'dotenv/config'
import { docker } from '../plugins/docker.js'
import { db } from '../db.js'
import { getSandboxConfig } from '../services/sandbox.js'
import { loadFixture } from './fixtures.js'
import { dockerSandboxFactory, DIND_PROFILE, SYSTEMD_PROFILE, k8sProfile, type SandboxProfile } from './docker-sandbox.js'
import { runPersistentSet, runSet } from './run-set.js'
import { summarize, type QuestResult, type VerifyQuest } from './verify-quest.js'

// 지원하는 샌드박스 타입과 프로필 (명세 조각 V1~). 나머지 타입은 이후 조각에서 추가한다.
// 실제 앱(terminal.ts)의 핸들러와 같은 구성: docker 계열은 Privileged dind이고 데몬이 뜰 때까지 기다린다.
const PROFILES: Record<string, SandboxProfile> = {
    linux: {},
    // MariaDB 가 더 설치된 같은 계열 이미지 (앱은 기본 핸들러로 띄운다)
    'linux-db': {},
    docker: DIND_PROFILE,
    'docker-persistent': DIND_PROFILE,
    // 앱은 linux-ssh에서도 /bin/bash를 띄운다(sshd는 퀘스트 setup이 직접 시작). 그래서 linux와 같다.
    'linux-ssh': {},
    'linux-systemd': SYSTEMD_PROFILE,
    // 컨테이너가 k3d 네트워크에서 클러스터에 닿아야 한다. KUBECONFIG_PATH는 컨테이너 안에서 닿는 서버 주소의 kubeconfig여야 한다 (개발 가이드 참고)
    k8s: k8sProfile(process.env.K3D_NETWORK ?? 'k3d-etude'),
}
const SUPPORTED_TYPES = new Set(Object.keys(PROFILES))

function parseSetIds(argv: string[]): number[] | 'all' {
    if (argv.includes('--all')) return 'all'
    const value = argv[argv.indexOf('--set') + 1]
    if (argv.indexOf('--set') === -1 || !value) throw new Error('사용법: npm run verify:quests -- --set <id[,id...]> | --all')
    return value.split(',').map((s) => {
        const n = Number(s)
        if (!Number.isInteger(n) || n <= 0) throw new Error(`세트 번호가 올바르지 않습니다: ${s}`)
        return n
    })
}

const asArray = (raw: unknown): string[] | null => (raw == null ? null : typeof raw === 'string' ? JSON.parse(raw) : (raw as string[]))

// 조건별 채점(quest.checks): [{label, cmd}]. 없거나 깨졌으면 undefined.
function parseChecks(raw: unknown): VerifyQuest['checks'] {
    if (!raw) return undefined
    try {
        const v = typeof raw === 'string' ? JSON.parse(raw) : raw
        return Array.isArray(v) && v.length > 0 ? v : undefined
    } catch { return undefined }
}

async function loadQuests(setId: number): Promise<VerifyQuest[]> {
    const [rows] = await db.query<any[]>(
        // 객관식(kind='choice')은 grade_cmd 가 없고 정답을 서버가 판정하므로 verify:quiz 가 따로 검증한다
        "SELECT order_index, title, setup_cmd, grade_cmd, checks FROM quest WHERE quest_set_id = ? AND kind = 'terminal' ORDER BY order_index",
        [setId],
    )
    return rows.map((r) => ({ orderIndex: r.order_index, title: r.title, setupCmd: asArray(r.setup_cmd), gradeCmd: asArray(r.grade_cmd)!, checks: parseChecks(r.checks) }))
}

function print(result: QuestResult) {
    console.log(result.ok
        ? `  ${result.note ? '△' : '✓'} ${result.orderIndex}. ${result.title}${result.note ? `  (알려진 예외: ${result.note})` : ''}`
        : `  ✗ ${result.orderIndex}. ${result.title}  [${result.reason}] ${result.detail}`)
}

async function main() {
    const requested = parseSetIds(process.argv.slice(2))
    const [setRows] = await db.query<any[]>('SELECT id, title, sandbox_type FROM quest_set ORDER BY id')
    const targets = requested === 'all'
        ? setRows.filter((s) => SUPPORTED_TYPES.has(s.sandbox_type))
        : requested.map((id) => {
            const row = setRows.find((s) => s.id === id)
            if (!row) throw new Error(`세트 ${id}을(를) 찾을 수 없습니다.`)
            if (!SUPPORTED_TYPES.has(row.sandbox_type)) throw new Error(`세트 ${id}은 아직 지원하지 않는 샌드박스 타입(${row.sandbox_type})입니다.`)
            return row
        })

    const all: QuestResult[] = []
    for (const set of targets) {
        console.log(`\n세트 ${set.id}: ${set.title} (${set.sandbox_type})`)
        const config = await getSandboxConfig(set.sandbox_type)
        const factory = dockerSandboxFactory(docker, config, PROFILES[set.sandbox_type])
        // 퀘스트 사이에 상태가 이어지는 세트는 한 컨테이너에서 순서대로, 그 외는 퀘스트마다 새 컨테이너에서 검증한다
        const run = config.persistent ? runPersistentSet : runSet
        const results = await run(await loadQuests(set.id), loadFixture(set.id), factory)
        results.forEach(print)
        all.push(...results)
    }

    const { passed, failed, exitCode } = summarize(all)
    console.log(`\n통과 ${passed}, 실패 ${failed}`)
    return exitCode
}

main()
    .then((code) => { process.exitCode = code })
    .catch((err) => { console.error(err instanceof Error ? err.message : err); process.exitCode = 2 })
    .finally(() => db.end())
