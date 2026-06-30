# 구현 가이드 — hint_used / solution_used 기록

## 목표

힌트/풀이를 열람한 경우 `quest_attempt.hint_used`, `solution_used`에 `1`로 기록한다.

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `frontend/src/components/QuestPanel.tsx` | 힌트/풀이 열람 감지 + 채점 시 전달 |
| `frontend/src/api.ts` | `gradeQuest`에 `hintUsed`, `solutionUsed` 파라미터 추가 |

---

## Step 1. `api.ts` — gradeQuest 시그니처 변경

```ts
export async function gradeQuest(
  containerId: string,
  questId: number,
  questSetId: number,
  sessionId: string,
  elapsedSec: number,
  hintUsed: boolean,      // 추가
  solutionUsed: boolean   // 추가
) {
  return fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId, questId, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed }),
  }).then((r) => r.json())
}
```

---

## Step 2. `QuestPanel.tsx`

### 2-1. 열람 state 추가

`const [result, setResult]` 근처에:

```ts
const [hintUsed, setHintUsed] = useState(false)
const [solutionUsed, setSolutionUsed] = useState(false)
```

### 2-2. `<details>` → `onToggle`으로 열람 감지

힌트:
```tsx
<details className="flex-1" onToggle={(e) => { if ((e.currentTarget as HTMLDetailsElement).open) setHintUsed(true) }}>
```

풀이:
```tsx
<details className="flex-1" onToggle={(e) => { if ((e.currentTarget as HTMLDetailsElement).open) setSolutionUsed(true) }}>
```

> 한 번 열면 `true`로 고정 — 닫았다가 다시 열어도 이미 봤으므로 `true` 유지.

### 2-3. grade 함수에서 전달

```ts
const grade = async () => {
    setLoading(true)
    try {
        const elapsedSec = Math.round((Date.now() - startTimeRef.current) / 1000)
        const data = await gradeQuest(containerId, quest.id, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed)
        setResult(data.passed)
        if (data.passed) onComplete(index)
    } finally {
        setLoading(false)
    }
}
```

---

## 검증

힌트 열고 채점 후 `quest_attempt` 테이블에서 `hint_used = 1` 확인.  
풀이 열고 채점 후 `solution_used = 1` 확인.
