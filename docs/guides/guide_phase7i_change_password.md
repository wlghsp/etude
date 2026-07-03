# Phase 7i 구현 가이드 — 본인 비밀번호 변경

명세: [specs/spec_phase7i_change_password.md](../specs/spec_phase7i_change_password.md)

전제: Phase 7(인증)이 구현되어 있는 상태. `authMiddleware`, `resetPassword()`(관리자용) 등 기존 코드를 재사용/참고한다.

---

## 전체 흐름

```
Step 1. services/auth.ts — changeOwnPassword() 작성
Step 2. routes/auth.routes.ts — PATCH /me/password 라우트 추가
Step 3. frontend/src/api/auth.ts — changePassword() 함수 추가
Step 4. 비밀번호 변경 UI 컴포넌트 작성
Step 5. SideNav.tsx에 진입점 추가
Step 6. 검증
```

---

## Step 1. `services/auth.ts` — 비밀번호 변경 로직

기존 `services/user.ts`의 `resetPassword()`(관리자용, 현재 비밀번호 확인 없음)와는 다르게, 본인 확인이 필요한 버전이다. `services/auth.ts`에 추가한다 — 로그인 검증(`login()`)과 같은 파일에 두는 게 "비밀번호 확인" 로직이 겹친다는 점에서 자연스럽다.

```typescript
export async function changeOwnPassword(userId: number, currentPassword: string, newPassword: string) {
    const [rows] = await db.query(
        'SELECT password FROM user WHERE id = ?',
        [userId]
    ) as any[]

    const user = rows[0]
    if (!user) throw new Error('사용자를 찾을 수 없습니다.')

    const match = await bcrypt.compare(currentPassword, user.password)
    if (!match) throw new Error('현재 비밀번호가 올바르지 않습니다.')

    const hashed = await bcrypt.hash(newPassword, 10)
    await db.query('UPDATE user SET password = ? WHERE id = ?', [hashed, userId])
}
```

`login()`이 이미 `bcrypt`, `db`를 import하고 있으니 추가 import는 불필요.

---

## Step 2. `routes/auth.routes.ts` — 라우트 추가

기존 `/auth/login`, `/me`와 같은 파일에 추가한다.

```typescript
app.patch('/me/password', { preHandler: authMiddleware }, async (request: any, reply) => {
    const { currentPassword, newPassword } = request.body as { currentPassword: string; newPassword: string }
    try {
        await changeOwnPassword(request.user.userId, currentPassword, newPassword)
        return { ok: true }
    } catch (e: any) {
        return reply.code(401).send({ error: e.message })
    }
})
```

`authMiddleware`는 이미 `auth.routes.ts`에서 import되어 있다(`/me` 라우트에서 사용 중). `changeOwnPassword`도 `services/auth.js`에서 함께 import한다.

---

## Step 3. `frontend/src/api/auth.ts` — API 함수 추가

```typescript
export async function changePassword(currentPassword: string, newPassword: string) {
    const res = await fetch(`${BASE}/me/password`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', ...authHeaders() },
        body: JSON.stringify({ currentPassword, newPassword }),
    })
    if (!res.ok) {
        const data = await res.json()
        throw new Error(data.error ?? '비밀번호 변경에 실패했습니다.')
    }
}
```

---

## Step 4. 비밀번호 변경 UI

새 컴포넌트 `frontend/src/components/ChangePasswordModal.tsx`를 만든다. `FeedbackButton.tsx`의 모달 구조(버튼으로 열고, 오버레이 위에 폼, 토스트로 결과 알림)를 그대로 따른다 — 다만 이 컴포넌트는 버튼 자체를 갖지 않고 `open`/`onClose`를 props로 받는다(진입점은 Step 5에서 `SideNav.tsx`가 갖는다).

```tsx
// frontend/src/components/ChangePasswordModal.tsx
import { useState } from 'react'
import { changePassword } from '../api/auth'

interface Props {
    open: boolean
    onClose: () => void
}

export function ChangePasswordModal({ open, onClose }: Props) {
    const [currentPassword, setCurrentPassword] = useState('')
    const [newPassword, setNewPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const [error, setError] = useState('')
    const [loading, setLoading] = useState(false)
    const [toast, setToast] = useState(false)

    function reset() {
        setCurrentPassword('')
        setNewPassword('')
        setConfirmPassword('')
        setError('')
    }

    function handleClose() {
        reset()
        onClose()
    }

    async function handleSubmit() {
        setError('')
        if (!currentPassword || !newPassword || !confirmPassword) {
            setError('모든 항목을 입력하세요.')
            return
        }
        if (newPassword !== confirmPassword) {
            setError('새 비밀번호가 서로 일치하지 않습니다.')
            return
        }

        setLoading(true)
        try {
            await changePassword(currentPassword, newPassword)
            handleClose()
            setToast(true)
            setTimeout(() => setToast(false), 2000)
        } catch (e: any) {
            setError(e.message)
        } finally {
            setLoading(false)
        }
    }

    if (!open) return null

    return (
        <>
            <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
                <div className="bg-surface border border-outline-variant w-[400px] p-6 flex flex-col gap-4">
                    <div className="flex items-center justify-between">
                        <h2 className="font-mono text-body-lg font-bold text-on-surface">비밀번호 변경</h2>
                        <button onClick={handleClose} className="text-on-surface-variant hover:text-on-surface">
                            <span className="material-symbols-outlined text-[20px]">close</span>
                        </button>
                    </div>

                    <input
                        type="password"
                        value={currentPassword}
                        onChange={e => setCurrentPassword(e.target.value)}
                        placeholder="현재 비밀번호"
                        className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface focus:outline-none focus:border-primary"
                    />
                    <input
                        type="password"
                        value={newPassword}
                        onChange={e => setNewPassword(e.target.value)}
                        placeholder="새 비밀번호"
                        className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface focus:outline-none focus:border-primary"
                    />
                    <input
                        type="password"
                        value={confirmPassword}
                        onChange={e => setConfirmPassword(e.target.value)}
                        placeholder="새 비밀번호 확인"
                        className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface focus:outline-none focus:border-primary"
                    />

                    {error && (
                        <p className="font-mono text-body-sm text-error">{error}</p>
                    )}

                    <div className="flex justify-end gap-2">
                        <button
                            onClick={handleClose}
                            className="px-4 py-2 border border-outline-variant font-mono text-label-caps text-on-surface-variant hover:bg-surface-container-high transition-colors"
                        >
                            취소
                        </button>
                        <button
                            onClick={handleSubmit}
                            disabled={loading}
                            className="px-4 py-2 bg-primary font-mono text-label-caps text-on-primary hover:brightness-110 transition-all disabled:opacity-50"
                        >
                            {loading ? '변경 중...' : '변경하기'}
                        </button>
                    </div>
                </div>
            </div>

            {toast && (
                <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 px-4 py-2 bg-surface-container border border-outline-variant font-mono text-label-caps text-on-surface">
                    비밀번호가 변경됐습니다.
                </div>
            )}
        </>
    )
}
```

새 비밀번호와 확인 불일치 등은 API 호출 없이 프론트에서 먼저 걸러지고(`handleSubmit` 상단), 현재 비밀번호 오류 같은 서버 쪽 실패는 `catch`에서 `error` state로 표시된다.

---

## Step 5. `SideNav.tsx`에 진입점 추가

`SideNav`는 모달을 직접 열고 닫는 state 없이 부모로부터 콜백만 받는 순수 표시 컴포넌트다([SideNav.tsx](../../frontend/src/components/SideNav.tsx) 참고 — `onHome`, `onLogout` 같은 콜백 패턴). 모달의 열림 상태는 `SideNav`를 쓰는 부모(`App.tsx`)가 들고, `SideNav`에는 "비밀번호 변경" 버튼과 그걸 눌렀을 때 부를 콜백만 추가한다.

### `SideNav.tsx` — 버튼 추가

유저 이름/이메일 표시 영역([SideNav.tsx:44-47](../../frontend/src/components/SideNav.tsx#L44-L47)) 아래, 로그아웃 버튼 위에 추가한다.

```tsx
interface Props {
    // ...기존 props
    onChangePassword: () => void
}

// ...
<div className="border-t border-outline-variant pt-4 px-2">
    <div className="px-4 py-3 mb-1">
        <div className="font-mono text-body-md font-semibold text-on-surface truncate">{userName}</div>
        <div className="font-mono text-code-sm text-on-surface-variant truncate">{userEmail}</div>
    </div>
    <button onClick={onChangePassword} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-3 hover:text-on-surface transition-all">
        <span className="material-symbols-outlined text-[22px]">lock_reset</span>
        <span className="font-mono text-body-md">비밀번호 변경</span>
    </button>
    <button onClick={onLogout} className="w-full flex items-center gap-3 text-on-surface-variant pl-4 py-3 hover:text-on-surface transition-all">
        <span className="material-symbols-outlined text-[22px]">logout</span>
        <span className="font-mono text-body-md">로그아웃</span>
    </button>
</div>
```

### `SideNav`를 쓰는 4개 페이지 — `onChangePassword` prop 추가

`SideNav`는 `Admin.tsx`, `Leaderboard.tsx`, `SetSelect.tsx`, `Progress.tsx` 4개 페이지에서 각각 렌더링된다(공통 레이아웃이 아니라 페이지마다 직접 씀). `onLogout`이 이미 이 4개 페이지의 `Props`를 거쳐 `SideNav`로 전달되고 있는 것과 완전히 같은 패턴으로 `onChangePassword`도 추가한다.

각 페이지 파일에서 두 곳을 고친다 — `Props` interface에 `onChangePassword: () => void` 추가, `<SideNav ... onLogout={onLogout} />` 호출부에 `onChangePassword={onChangePassword}` 추가. 예시(`SetSelect.tsx`):

```tsx
interface Props {
    // ...기존 props
    onChangePassword: () => void
}

export function SetSelect({ /* ...기존 */ onChangePassword }: Props) {
  // ...
  <SideNav
    // ...기존 props
    onLogout={onLogout}
    onChangePassword={onChangePassword}
  />
}
```

`Admin.tsx`, `Leaderboard.tsx`, `Progress.tsx`도 동일하게 반복한다.

### `App.tsx` — 모달 state + 4개 페이지에 배선

`App.tsx`가 `handleLogout`을 4개 페이지 모두에 내려주는 최상위이므로([App.tsx:67,71,77-81,98-103](../../frontend/src/App.tsx) 참고), `onChangePassword`도 같은 자리에서 배선한다.

```tsx
import { ChangePasswordModal } from './components/ChangePasswordModal'

// App 컴포넌트 안
const [changePasswordOpen, setChangePasswordOpen] = useState(false)
const openChangePassword = () => setChangePasswordOpen(true)

// 4개 페이지 렌더링부 각각에 onChangePassword={openChangePassword} 추가
<Progress ... onLogout={handleLogout} onChangePassword={openChangePassword} ... />
<Leaderboard ... onLogout={handleLogout} onChangePassword={openChangePassword} ... />
<Admin ... onLogout={handleLogout} onChangePassword={openChangePassword} ... />
<SetSelect ... onLogout={handleLogout} onChangePassword={openChangePassword} ... />

// App의 최상위 반환 JSX 아무 곳에나(모달이므로 위치 무관, 페이지 분기 바깥에 한 번만)
<ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
```

---

## Step 6. 검증

- [ ] 현재 비밀번호를 틀리게 입력 → 실패 + 에러 메시지 확인
- [ ] 현재 비밀번호를 올바르게, 새 비밀번호 입력 → 성공
- [ ] 로그아웃 후 새 비밀번호로 재로그인 확인
- [ ] 예전 비밀번호로는 로그인 안 되는지 확인
- [ ] 관리자 강제 리셋(`PATCH /admin/users/:id/password`)이 여전히 정상 동작하는지 회귀 확인 (별개 엔드포인트라 영향 없어야 함)
