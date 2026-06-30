# 구현 가이드 — elapsed_sec (퀘스트 풀이 시간 기록)

## 목표

퀘스트 진입 → 채점 성공까지 걸린 시간(초)을 `quest_attempt.elapsed_sec`에 기록한다.

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `frontend/src/components/QuestPanel.tsx` | 진입 시각 기록 + 경과 시간 계산 |
| `frontend/src/api.ts` | `gradeQuest`에 `elapsedSec` 파라미터 추가 |

---

## Step 1. `api.ts` — gradeQuest 시그니처 변경

```ts
export async function gradeQuest(
  containerId: string,
  questId: number,
  questSetId: number,
  sessionId: string,
  elapsedSec: number      // 추가
) {
  return fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId, questId, questSetId, sessionId, elapsedSec }),  // 추가
  }).then((r) => r.json())
}
```

---

## Step 2. `QuestPanel.tsx` — 진입 시각 기록 + 전달

### 2-1. import에 `useRef` 추가

```ts
import { useState, useRef } from 'react'
```

### 2-2. 컴포넌트 상단에 startTimeRef 추가

`const [result, setResult] = useState` 바로 위에:

```ts
const startTimeRef = useRef(Date.now())
```

> `key={quest.id}`로 퀘스트가 바뀔 때마다 컴포넌트가 리마운트되므로 자동으로 초기화된다. 별도 useEffect 불필요.

### 2-3. grade 함수에서 경과 시간 계산 후 전달

```ts
const grade = async () => {
    setLoading(true)
    try {
        const elapsedSec = Math.round((Date.now() - startTimeRef.current) / 1000)
        const data = await gradeQuest(containerId, quest.id, questSetId, sessionId, elapsedSec)
        setResult(data.passed)
        if (data.passed) onComplete(index)
    } finally {
        setLoading(false)
    }
}
```

---

## 검증

채점 후 `quest_attempt` 테이블에서 `elapsed_sec` 컬럼에 숫자가 들어오면 완료.
