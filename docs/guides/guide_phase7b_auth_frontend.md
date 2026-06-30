# Phase 7b 구현 가이드 — 프론트 인증 + 라우팅

명세: [specs/spec_phase7_auth.md](../specs/spec_phase7_auth.md)  
선행: [guide_phase7a_auth_backend.md](guide_phase7a_auth_backend.md) 완료 후 진행

---

## 구현 순서

```
1. api.ts — 토큰 헤더 자동 첨부, 인증 API 함수 추가
2. App.tsx — 로그인 상태 관리 + 라우팅
3. Login.tsx — 로그인 화면 (신규)
```

디자인 적용(Stitch HTML → React 포팅)은 구현 완료 후 별도 진행.

---

## Step 1. api.ts 수정

`frontend/src/api.ts`에서:

### 1-1. 토큰 관리 함수 추가

```typescript
export const token = {
  get: () => localStorage.getItem('token') ?? '',
  set: (t: string) => localStorage.setItem('token', t),
  clear: () => localStorage.removeItem('token'),
}
```

### 1-2. 공통 헤더 헬퍼 추가

기존 fetch 호출에 토큰을 매번 붙이기 불편하므로 헬퍼 추가:

```typescript
function authHeaders(): HeadersInit {
  const t = token.get()
  return t ? { 'Authorization': `Bearer ${t}` } : {}
}
```

### 1-3. 인증 API 함수 추가

```typescript
export async function loginApi(email: string, password: string) {
  const res = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  })
  const data = await res.json()
  if (!res.ok) throw new Error(data.error)
  return data as { token: string; user: { id: number; name: string; email: string; role: string } }
}

export async function fetchMe() {
  const res = await fetch(`${BASE}/me`, { headers: authHeaders() })
  if (!res.ok) throw new Error('unauthorized')
  return res.json()
}

export async function fetchProgress() {
  const res = await fetch(`${BASE}/progress`, { headers: authHeaders() })
  return res.json()
}
```

### 1-4. 기존 fetchQuests, gradeQuest에 토큰 헤더 추가

`fetchQuestSets`, `fetchQuests` — 두 번째 인자 추가:

```typescript
export async function fetchQuestSets() {
  return fetch(`${BASE}/quest-sets`, { headers: authHeaders() }).then((r) => r.json())
}

export async function fetchQuests(setId: number) {
  return fetch(`${BASE}/quest-sets/${setId}/quests`, { headers: authHeaders() }).then((r) => r.json())
}
```

`gradeQuest`, `endSession` — 기존 `headers`에 스프레드:

```typescript
export async function gradeQuest(containerId: string, questId: number) {
  return fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId, questId }),
  }).then((r) => r.json())
}

export async function endSession(containerId: string) {
  return fetch(`${BASE}/session/end`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify({ containerId }),
  }).then((r) => r.json())
}
```

---

## Step 2. App.tsx — 로그인 상태 + 라우팅

현재 App.tsx는 `selectedSetId`로 화면을 전환하는 단순 분기 구조.
여기에 `user` 상태를 추가해서 로그인 여부로 화면을 분기한다.

### 추가할 상태

기존 `useState` 선언 블록 끝(14번 줄) 바로 다음에 추가:

```typescript
const [user, setUser] = useState<{ id: number; name: string; email: string; role: string } | null>(null)
const [authChecked, setAuthChecked] = useState(false)
const [showProgress, setShowProgress] = useState(false)
```

### 앱 시작 시 토큰 검증

기존 ref sync `useEffect` 두 개(18~19번 줄) 다음, `selectedSetId` `useEffect`(21번 줄) 앞에 추가:

```typescript
useEffect(() => {
  fetchMe()
    .then(setUser)
    .catch(() => {})
    .finally(() => setAuthChecked(true))
}, [])
```

### 화면 분기 로직

기존 35~42번 줄의 `if (selectedSetId === null) { ... return <SetSelect ...> }` 블록 전체를 아래로 교체:

```typescript
// 토큰 검증 전 — 빈 화면 (깜빡임 방지)
if (!authChecked) return null

// 비로그인 — 로그인 화면
if (!user) return <Login onLogin={(u) => setUser(u)} />

// 세트 선택 화면
if (selectedSetId === null) {
  function handleSetSelect(id: number, sandboxType: string) {
    setSelectedSetId(id)
    setSandboxType(sandboxType)
    setContainerId('')
  }
  return <SetSelect
    onSelect={handleSetSelect}
    onLogout={() => { token.clear(); setUser(null) }}
  />
}

// 실습 화면 (기존)
return ( ... )
```

---

## Step 2-1. 로그아웃 — SetSelect에 버튼 추가

로그아웃은 토큰 삭제 + `user` 상태를 `null`로 초기화하는 것이 전부다.  
버튼은 세트 선택 화면(`SetSelect`) 헤더 우상단에 배치한다.

### SetSelect Props 확장

`frontend/src/pages/SetSelect.tsx`의 `Props` 인터페이스에 추가:

```typescript
interface Props {
  onSelect: (setId: number, sandboxType: string) => void
  onLogout: () => void   // 추가
}
```

함수 인자도 구조분해에 추가:

```typescript
export function SetSelect({ onSelect, onLogout }: Props) {
```

### 헤더에 버튼 배치

헤더 `<div>`(48번 줄 `marginBottom: '2.5rem'` 블록)를 flex로 바꿔서 우상단에 버튼을 놓는다:

```tsx
<div style={{ marginBottom: '2.5rem', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
  <div>
    <div style={{ fontSize: '11px', letterSpacing: '0.15em', color: '#555', marginBottom: '8px' }}>
      OKESTRO TRAINING
    </div>
    <h1 style={{ fontSize: '32px', fontWeight: 700, color: '#f0f0f0', margin: 0, letterSpacing: '-0.5px' }}>
      Etude
    </h1>
    <p style={{ color: '#555', fontSize: '14px', marginTop: '8px', marginBottom: 0 }}>
      실습할 트레이닝 세트를 선택하세요.
    </p>
  </div>
  <button
    onClick={onLogout}
    style={{
      background: 'none',
      border: '1px solid #333',
      color: '#666',
      fontSize: '13px',
      padding: '6px 14px',
      borderRadius: '6px',
      cursor: 'pointer',
    }}
  >
    로그아웃
  </button>
</div>
```

### App.tsx import 추가

`token`을 App.tsx에서 사용하므로 import에 추가:

```typescript
import { fetchQuests, endSession, fetchMe, token } from './api'
```

---

## Step 3. Login.tsx 작성

`frontend/src/pages/Login.tsx` 신규 작성:

```typescript
import { useState } from 'react'
import { loginApi, token } from '../api'

interface Props {
  onLogin: (user: { id: number; name: string; email: string; role: string }) => void
}

export function Login({ onLogin }: Props) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.SyntheticEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const data = await loginApi(email, password)
      token.set(data.token)
      onLogin(data.user)
    } catch (e) {
      setError(e instanceof Error ? e.message : '로그인 실패')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      {/* 디자인은 Stitch 적용 단계에서 완성 */}
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="name@okestro.com" />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
      {error && <p>{error}</p>}
      <button type="submit" disabled={loading}>{loading ? '로그인 중...' : '로그인'}</button>
    </form>
  )
}
```

---

## 검증

1. 서버 실행 후 브라우저 진입 → 로그인 화면 표시
2. 잘못된 비밀번호 → 에러 메시지 표시
3. `test@okestro.com` / `password` 로그인 → 세트 선택 화면 진입
4. 브라우저 새로고침 → 로그인 상태 유지 (localStorage 토큰)
5. 세트 선택 화면 우상단 로그아웃 버튼 클릭 → 로그인 화면으로 복귀
6. 로그아웃 후 localStorage에서 `token` 키가 사라졌는지 확인 (DevTools → Application → Local Storage)
