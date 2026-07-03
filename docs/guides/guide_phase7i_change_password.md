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

새 컴포넌트(예: `frontend/src/components/ChangePasswordModal.tsx`)를 만들거나, 기존 모달 패턴(`FeedbackButton.tsx`의 버튼+모달 구조 참고)을 따른다.

입력 필드 3개:
- 현재 비밀번호
- 새 비밀번호
- 새 비밀번호 확인

제출 시:
1. 새 비밀번호와 확인이 일치하는지 프론트에서 먼저 검증 (불일치 시 API 호출 없이 에러 표시)
2. 일치하면 `changePassword()` 호출
3. 성공 시 토스트/알림 후 모달 닫기, 실패 시(현재 비밀번호 오류 등) 에러 메시지 표시

---

## Step 5. `SideNav.tsx`에 진입점 추가

`SideNav.tsx`의 유저 이름/이메일 표시 영역([SideNav.tsx:45-46](../../frontend/src/components/SideNav.tsx#L45-L46)) 근처에 "비밀번호 변경" 버튼을 추가하고, 클릭 시 Step 4의 모달을 연다.

---

## Step 6. 검증

- [ ] 현재 비밀번호를 틀리게 입력 → 실패 + 에러 메시지 확인
- [ ] 현재 비밀번호를 올바르게, 새 비밀번호 입력 → 성공
- [ ] 로그아웃 후 새 비밀번호로 재로그인 확인
- [ ] 예전 비밀번호로는 로그인 안 되는지 확인
- [ ] 관리자 강제 리셋(`PATCH /admin/users/:id/password`)이 여전히 정상 동작하는지 회귀 확인 (별개 엔드포인트라 영향 없어야 함)
