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

```typescript
// fetchQuests, fetchQuestSets, gradeQuest, endSession 의 fetch 호출에
// headers: { ...authHeaders() } 추가
```

---

## Step 2. App.tsx — 로그인 상태 + 라우팅

현재 App.tsx는 `selectedSetId`로 화면을 전환하는 단순 분기 구조.
여기에 `user` 상태를 추가해서 로그인 여부로 화면을 분기한다.

### 추가할 상태

```typescript
const [user, setUser] = useState<{ id: number; name: string; email: string; role: string } | null>(null)
const [authChecked, setAuthChecked] = useState(false)
```

### 앱 시작 시 토큰 검증

```typescript
useEffect(() => {
  fetchMe()
    .then(setUser)
    .catch(() => {})
    .finally(() => setAuthChecked(true))
}, [])
```

### 화면 분기 로직

```typescript
// 토큰 검증 전 — 빈 화면 (깜빡임 방지)
if (!authChecked) return null

// 비로그인 — 로그인 화면
if (!user) return <Login onLogin={(u) => setUser(u)} />

// 진행 현황 화면
if (showProgress) return <Progress onBack={() => setShowProgress(false)} />

// 세트 선택 화면
if (selectedSetId === null) {
  return <SetSelect
    user={user}
    onSelect={handleSetSelect}
    onProgress={() => setShowProgress(true)}
    onLogout={() => { token.clear(); setUser(null) }}
  />
}

// 실습 화면 (기존)
return ( ... )
```

> `showProgress` 상태도 `useState(false)`로 추가 필요

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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const data = await loginApi(email, password)
      token.set(data.token)
      onLogin(data.user)
    } catch (e: any) {
      setError(e.message)
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
3. `test@okestro.com` / `password123` 로그인 → 세트 선택 화면 진입
4. 브라우저 새로고침 → 로그인 상태 유지 (localStorage 토큰)
5. 로그아웃 → 로그인 화면으로 복귀
