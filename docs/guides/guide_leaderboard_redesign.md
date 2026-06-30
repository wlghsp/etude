# 리더보드 개선 가이드 — 유저 단위 순위표 + 아코디언 세부 현황

## 목표

현재: `유저 × 세트` 조합이 행으로 나열 → 사람이 늘어날수록 읽기 불가능  
개선: **유저별 전체 달성률 순위표** + 클릭 시 세트별 상세 펼치기

```
순위  팀원      완료   전체   달성률   진행 바
 1   홍길동    42    62    68%    ████████░░
 2   김철수    38    62    61%    ███████░░░
 3   테스트    12    62    19%    ██░░░░░░░░
    └─ [펼치면 세트별 상세]
```

---

## 변경 범위

| 파일 | 변경 내용 |
|------|-----------|
| `backend/src/user.ts` | `getLeaderboard` 쿼리 → 유저별 집계로 변경 |
| `backend/src/index.ts` | `/leaderboard` 응답 타입 변경 (쿼리만 바뀌므로 라우트 코드는 그대로) |
| `frontend/src/pages/Leaderboard.tsx` | 순위표 UI + 아코디언 세부 현황 |

---

## Step 1. 백엔드 — `getLeaderboard` 쿼리 변경

`backend/src/user.ts`의 `getLeaderboard` 함수를 아래로 교체한다.

**현재 쿼리 문제:** `유저 × 세트` 행을 반환 → N명 × M세트 행  
**변경 후:** 유저 1명당 1행 (전체 완료수/전체 퀘스트수 집계) + 세트별 상세를 중첩 배열로

쿼리를 두 번 날리는 방식으로 구현한다 (JOIN으로 중첩 배열 만들기보다 단순함):

```typescript
export async function getLeaderboard() {
    // 1. 유저별 전체 집계
    const [summary] = await db.query(`
        SELECT
            u.id AS userId,
            u.name AS userName,
            COUNT(DISTINCT q.id) AS total,
            COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.quest_id END) AS completed
        FROM user u
        CROSS JOIN quest q
        LEFT JOIN quest_attempt qa ON qa.quest_id = q.id AND qa.user_id = u.id
        WHERE u.role = 'member'
        GROUP BY u.id
        ORDER BY completed DESC, u.name
    `) as any[]

    // 2. 세트별 상세 (전체)
    const [details] = await db.query(`
        SELECT
            u.id AS userId,
            qs.id AS questSetId,
            qs.title AS questSetTitle,
            qs.category,
            COUNT(DISTINCT q.id) AS total,
            COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.quest_id END) AS completed
        FROM user u
        CROSS JOIN quest_set qs
        JOIN quest q ON q.quest_set_id = qs.id
        LEFT JOIN quest_attempt qa ON qa.quest_id = q.id AND qa.user_id = u.id
        WHERE u.role = 'member'
        GROUP BY u.id, qs.id
        ORDER BY u.id, qs.id
    `) as any[]

    // 3. 유저별로 세트 상세를 묶어서 반환
    return (summary as any[]).map((u: any) => ({
        userId: u.userId,
        userName: u.userName,
        total: Number(u.total),
        completed: Number(u.completed),
        sets: (details as any[])
            .filter((d: any) => d.userId === u.userId)
            .map((d: any) => ({
                questSetId: d.questSetId,
                questSetTitle: d.questSetTitle,
                category: d.category,
                total: Number(d.total),
                completed: Number(d.completed),
            }))
    }))
}
```

**검증:** 백엔드 재시작 후
```bash
curl -s http://localhost:3001/leaderboard \
  -H "Authorization: Bearer <토큰>" | jq '.[0]'
```
응답에 `userName`, `total`, `completed`, `sets[]` 구조가 나오면 OK.

---

## Step 2. 프론트 — `Leaderboard.tsx` 타입 + UI 교체

### 2-1. 타입 정의 변경

```typescript
interface SetRow {
    questSetId: number
    questSetTitle: string
    category: string
    total: number
    completed: number
}

interface UserRow {
    userId: number
    userName: string
    total: number
    completed: number
    sets: SetRow[]
}
```

### 2-2. state + useEffect

```typescript
const [rows, setRows] = useState<UserRow[]>([])
const [openUsers, setOpenUsers] = useState<Set<number>>(new Set())

useEffect(() => {
    fetchLeaderboard().then((data: any[]) =>
        setRows(data.map(u => ({
            ...u,
            total: Number(u.total),
            completed: Number(u.completed),
        })))
    )
}, [])

function toggleUser(userId: number) {
    setOpenUsers(prev => {
        const next = new Set(prev)
        if (next.has(userId)) next.delete(userId)
        else next.add(userId)
        return next
    })
}
```

### 2-3. 순위표 UI

기존 테이블을 아래 구조로 교체한다:

```tsx
<div className="bg-surface-container border border-outline-variant overflow-hidden">
    <div className="p-4 border-b border-outline-variant bg-surface-container-high">
        <h3 className="font-mono text-label-caps uppercase tracking-widest text-on-surface">팀원 진행현황</h3>
    </div>

    {rows.map((u, idx) => {
        const pct = u.total > 0 ? Math.round((u.completed / u.total) * 100) : 0
        const isOpen = openUsers.has(u.userId)
        return (
            <div key={u.userId} className="border-b border-outline-variant last:border-0">
                {/* 유저 행 */}
                <button
                    onClick={() => toggleUser(u.userId)}
                    className="w-full flex items-center gap-4 px-4 py-4 hover:bg-surface-container-high transition-colors text-left"
                >
                    {/* 순위 */}
                    <span className="font-mono text-headline-md text-on-surface-variant w-8 shrink-0">
                        {idx + 1}
                    </span>

                    {/* 이름 */}
                    <span className="font-mono text-body-md font-semibold text-on-surface w-32 shrink-0">
                        {u.userName}
                    </span>

                    {/* 진행 바 */}
                    <div className="flex-1 flex flex-col gap-1">
                        <div className="w-full h-2 bg-surface-container-highest">
                            <div
                                className={`h-full ${pct === 100 ? 'bg-success' : 'bg-primary'}`}
                                style={{ width: `${pct}%` }}
                            />
                        </div>
                    </div>

                    {/* 수치 */}
                    <span className="font-mono text-code-sm text-on-surface-variant w-20 text-right shrink-0">
                        {u.completed}/{u.total}
                    </span>
                    <span className={`font-mono text-body-md font-bold w-12 text-right shrink-0 ${pct === 100 ? 'text-success' : 'text-primary'}`}>
                        {pct}%
                    </span>

                    {/* 토글 아이콘 */}
                    <span
                        className="material-symbols-outlined text-on-surface-variant text-[20px] shrink-0 transition-transform"
                        style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)' }}
                    >
                        expand_more
                    </span>
                </button>

                {/* 세트별 상세 (펼침) */}
                {isOpen && (
                    <div className="border-t border-outline-variant bg-surface-container-lowest">
                        {u.sets.map(s => {
                            const sPct = s.total > 0 ? Math.round((s.completed / s.total) * 100) : 0
                            const sComplete = s.completed === s.total && s.total > 0
                            return (
                                <div key={s.questSetId} className="flex items-center gap-4 px-4 py-3 border-b border-outline-variant/50 last:border-0">
                                    <span className="w-8 shrink-0" /> {/* 순위 자리 맞춤 */}
                                    <span className="font-mono text-code-sm text-on-surface-variant w-32 shrink-0">
                                        {s.category}
                                    </span>
                                    <span className="font-mono text-code-sm text-on-surface flex-1">
                                        {s.questSetTitle}
                                    </span>
                                    <div className="w-24 h-1 bg-surface-container-highest shrink-0">
                                        <div
                                            className={`h-full ${sComplete ? 'bg-success' : 'bg-primary'}`}
                                            style={{ width: `${sPct}%` }}
                                        />
                                    </div>
                                    <span className="font-mono text-code-sm text-on-surface-variant w-20 text-right shrink-0">
                                        {s.completed}/{s.total}
                                    </span>
                                    <span className={`font-mono text-code-sm font-bold w-12 text-right shrink-0 ${sComplete ? 'text-success' : sPct > 0 ? 'text-primary' : 'text-on-surface-variant'}`}>
                                        {sPct}%
                                    </span>
                                    <span className="w-[20px] shrink-0" /> {/* 토글 아이콘 자리 맞춤 */}
                                </div>
                            )
                        })}
                    </div>
                )}
            </div>
        )
    })}
</div>
```

---

## 검증 기준

- [ ] 리더보드에 유저 1명당 1행으로 표시
- [ ] 달성률 높은 순으로 정렬
- [ ] 행 클릭 시 세트별 상세 펼치기/접기
- [ ] 세트별 상세에 카테고리, 세트명, 진행률 표시
- [ ] 유저가 2명 이상일 때 순위 비교 가능
