# Phase 7c 구현 가이드 — 진행 추적 + 대시보드

명세: [specs/spec_phase7_auth.md](../specs/spec_phase7_auth.md)  
선행: [guide_phase7b_auth_frontend.md](guide_phase7b_auth_frontend.md) 완료 후 진행

Stitch 참고 화면:
- `docs/stitch_etude_auth_progress_ui/training_sets_etude/screen.png` — 세트 선택 + 진행률
- `docs/stitch_etude_auth_progress_ui/learning_progress_etude/screen.png` — 대시보드 (개인 + 관리자)

---

## 구현 순서

```
1. SetSelect.tsx — 진행률 배지 추가
2. Progress.tsx — 내 진행 현황 대시보드 (신규)
3. Leaderboard.tsx — 전체 팀원 리더보드 (신규, 모든 팀원 접근 가능)
```

---

## Step 1. SetSelect.tsx — 진행률 배지

### 1-1. Props 변경

```typescript
interface Props {
  user: { name: string; role: string }
  onSelect: (setId: number, sandboxType: string) => void
  onProgress: () => void
  onLogout: () => void
}
```

### 1-2. 진행률 데이터 로드

```typescript
import { fetchQuestSets, fetchProgress } from '../api'

// state 추가
const [progressMap, setProgressMap] = useState<Record<number, { total: number; completed: number }>>({})

// useEffect에 추가
fetchProgress().then((rows: any[]) => {
  const map: Record<number, { total: number; completed: number }> = {}
  rows.forEach(r => { map[r.quest_set_id] = { total: Number(r.total), completed: Number(r.completed) } })
  setProgressMap(map)
})
```

### 1-3. 세트 카드에 진행률 표시

각 세트 버튼 안에 추가:

```typescript
const prog = progressMap[s.id]
const isComplete = prog && prog.completed === prog.total && prog.total > 0

// 세트 제목 옆에
{isComplete && <span>✓</span>}

// 카드 하단에
{prog && (
  <div>
    <div>{prog.completed}/{prog.total} 완료</div>
    <div style={{ height: '4px', background: '#333' }}>
      <div style={{ width: `${(prog.completed / prog.total) * 100}%`, height: '100%', background: '#22c55e' }} />
    </div>
  </div>
)}
```

### 1-4. 헤더에 사용자 정보 + 버튼 추가

```typescript
// 헤더 영역에 추가
<div>
  <span>{user.name}</span>
  <button onClick={onProgress}>Progress Status</button>
  <button onClick={onLogout}>Logout</button>
</div>
```

---

## Step 2. Progress.tsx 작성

`frontend/src/pages/Progress.tsx` 신규 작성:

```typescript
import { useEffect, useState } from 'react'
import { fetchProgress } from '../api'

interface ProgressRow {
  quest_set_id: number
  title: string
  category: string
  total: number
  completed: number
}

interface Props {
  onBack: () => void
}

export function Progress({ onBack }: Props) {
  const [rows, setRows] = useState<ProgressRow[]>([])

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    fetchProgress().then((data: any[]) =>
      setRows(data.map((r) => ({ ...r, total: Number(r.total), completed: Number(r.completed) })))
    )
  }, [])

  const totalQuests = rows.reduce((s, r) => s + r.total, 0)
  const totalCompleted = rows.reduce((s, r) => s + r.completed, 0)
  const completionRate = totalQuests > 0 ? Math.round((totalCompleted / totalQuests) * 100) : 0

  return (
    <div>
      {/* 요약 카드 3개 */}
      <div>
        <div>전체 퀘스트: {totalQuests}</div>
        <div>완료: {totalCompleted}</div>
        <div>완료율: {completionRate}%</div>
      </div>

      {/* 세트별 테이블 */}
      <table>
        <thead>
          <tr>
            <th>세트명</th>
            <th>카테고리</th>
            <th>진행률</th>
            <th>상태</th>
          </tr>
        </thead>
        <tbody>
          {rows.map(r => {
            const pct = r.total > 0 ? Math.round((r.completed / r.total) * 100) : 0
            const status = r.completed === 0 ? 'NOT STARTED' : r.completed === r.total ? 'COMPLETED' : 'IN PROGRESS'
            return (
              <tr key={r.quest_set_id}>
                <td>{r.title}</td>
                <td>{r.category}</td>
                <td>{r.completed}/{r.total} ({pct}%)</td>
                <td>{status}</td>
              </tr>
            )
          })}
        </tbody>
      </table>

      <button onClick={onBack}>← 세트 선택으로</button>
    </div>
  )
}
```

---

## Step 3. Leaderboard.tsx 작성

`frontend/src/pages/Leaderboard.tsx` 신규 작성:

```typescript
import { useEffect, useState } from 'react'
import { fetchLeaderboard } from '../api'

interface Row {
  userName: string
  questSetTitle: string
  category: string
  total: number
  completed: number
}

interface Props {
  onBack: () => void
}

export function Leaderboard({ onBack }: Props) {
  const [rows, setRows] = useState<Row[]>([])

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    fetchLeaderboard().then((data: any[]) =>
      setRows(data.map((r) => ({ ...r, total: Number(r.total), completed: Number(r.completed) })))
    )
  }, [])

  return (
    <div>
      <h2>팀 리더보드</h2>
      <table>
        <thead>
          <tr>
            <th>팀원</th>
            <th>세트명</th>
            <th>카테고리</th>
            <th>진행률</th>
            <th>상태</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r, i) => {
            const pct = r.total > 0 ? Math.round((r.completed / r.total) * 100) : 0
            const status = r.completed === 0 ? 'NOT STARTED' : r.completed === r.total ? 'COMPLETED' : 'IN PROGRESS'
            return (
              <tr key={i}>
                <td>{r.userName}</td>
                <td>{r.questSetTitle}</td>
                <td>{r.category}</td>
                <td>{r.completed}/{r.total} ({pct}%)</td>
                <td>{status}</td>
              </tr>
            )
          })}
        </tbody>
      </table>
      <button onClick={onBack}>← 돌아가기</button>
    </div>
  )
}
```

`api.ts`에 추가:
```typescript
export async function fetchLeaderboard() {
  const res = await fetch(`${BASE}/leaderboard`, { headers: authHeaders() })
  return res.json()
}
```

`App.tsx`에서 Leaderboard 버튼 추가 (role 구분 없이 모두 접근):
```typescript
// SetSelect.tsx 헤더에 버튼 추가
<button onClick={onLeaderboard}>🏆 Leaderboard</button>
```

---

## 검증

1. 퀘스트 채점 성공 → `quest_attempt` 테이블에 행 추가 확인
   ```sql
   SELECT * FROM quest_attempt;
   ```
2. 같은 퀘스트 재채점 → `quest_attempt` 행 추가됨 (중복 허용)
3. `/progress` API 응답에서 해당 세트 `completed` 값이 1 이상
4. 세트 선택 화면에서 완료한 퀘스트 수 배지 표시
5. Leaderboard 버튼 클릭 → 전체 팀원 현황 테이블 표시 (admin/member 모두)
