# 구현 가이드 — 인앱 피드백

명세: [specs/spec_phase9_feedback.md](../specs/spec_phase9_feedback.md)

선행: [guide_phase7g_route_split.md](guide_phase7g_route_split.md) — 백엔드 라우트가 `routes/` 디렉터리로 분리된 구조를 전제로 한다.

---

## 전체 흐름

```
1. DB — feedback 테이블 추가
2. 백엔드 — services/feedback.ts (쿼리) + 라우트 2개 추가
3. 프론트 — FeedbackButton 컴포넌트 (버튼 + 모달 + 토스트)
4. 프론트 — App.tsx에 FeedbackButton 마운트
```

---

## Step 1. DB — feedback 테이블

`backend/db/00_schema.sql` 하단에 추가:

```sql
CREATE TABLE IF NOT EXISTS feedback (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT,
  page         VARCHAR(100),
  quest_id     INT,
  quest_set_id INT,
  body         TEXT NOT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id)
);
```

로컬 DB에도 적용:

```bash
mysql -u root -p etude -e "
CREATE TABLE IF NOT EXISTS feedback (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  page VARCHAR(100),
  quest_id INT,
  quest_set_id INT,
  body TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(id)
);"
```

---

## Step 2. 백엔드 — 서비스 + 라우트 추가

Phase 7h 라우트 분리 이후 구조 기준. 레이어 원칙(`routes/`는 요청 파싱/응답만, DB 쿼리는 `services/`)을 그대로 따른다.
`index.ts`, 라우트 파일에 직접 `db.query`를 넣지 않는다.

### services/feedback.ts — 쿼리 분리

`backend/src/services/feedback.ts` 신규 작성:

```ts
import { db } from '../db.js'

export async function createFeedback(
    userId: number | null,
    page: string,
    questId: number | null,
    questSetId: number | null,
    body: string,
) {
    await db.query(
        'INSERT INTO feedback (user_id, page, quest_id, quest_set_id, body) VALUES (?, ?, ?, ?, ?)',
        [userId, page, questId, questSetId, body]
    )
}

export async function getFeedbackList() {
    const [rows] = await db.query(`
        SELECT
            f.id,
            u.name AS userName,
            f.page,
            qs.title AS questSetTitle,
            q.title AS questTitle,
            f.body,
            f.created_at AS createdAt
        FROM feedback f
        LEFT JOIN user u ON f.user_id = u.id
        LEFT JOIN quest_set qs ON f.quest_set_id = qs.id
        LEFT JOIN quest q ON f.quest_id = q.id
        ORDER BY f.created_at DESC
    `)
    return rows
}
```

### POST /feedback

`backend/src/routes/feedback.routes.ts` 신규 작성. 인증 불필요 — `user_id`는 토큰이 있으면 추출, 없으면 NULL.

```ts
import { FastifyPluginAsync } from 'fastify'
import { verifyToken } from '../services/auth.js'
import { createFeedback } from '../services/feedback.js'

export const feedbackRoutes: FastifyPluginAsync = async (app) => {
    app.post<{ Body: { page: string; questId?: number; questSetId?: number; body: string } }>(
        '/feedback',
        async (req, reply) => {
            const { page, questId, questSetId, body } = req.body
            if (!body?.trim()) return reply.code(400).send({ error: '내용을 입력해주세요.' })

            let userId: number | null = null
            const authHeader = req.headers['authorization']
            if (authHeader?.startsWith('Bearer ')) {
                try {
                    userId = verifyToken(authHeader.slice(7)).userId
                } catch {}
            }

            await createFeedback(userId, page, questId ?? null, questSetId ?? null, body.trim())
            return { ok: true }
        }
    )
}
```

`index.ts`에 등록 추가:

```ts
import { feedbackRoutes } from './routes/feedback.routes.js'
// ...
await fastify.register(feedbackRoutes)
```

### GET /admin/feedback

`backend/src/routes/admin.routes.ts`(기존 파일)에 라우트 추가. 관리자 전용이므로 `adminMiddleware` 재사용.

```ts
import { getFeedbackList } from '../services/feedback.js'

// adminRoutes 안, 기존 라우트들 옆에 추가
app.get(
    '/admin/feedback',
    { preHandler: adminMiddleware },
    async () => getFeedbackList()
)
```

---

## Step 3. 프론트 — FeedbackButton 컴포넌트

`frontend/src/components/FeedbackButton.tsx` 신규 생성.

```tsx
import { useState } from 'react'
import { submitFeedback } from '../api'

interface Props {
    page: string
    questId?: number | null
    questSetId?: number | null
}

export function FeedbackButton({ page, questId, questSetId }: Props) {
    const [open, setOpen] = useState(false)
    const [body, setBody] = useState('')
    const [loading, setLoading] = useState(false)
    const [toast, setToast] = useState(false)

    async function handleSubmit() {
        if (!body.trim()) return
        setLoading(true)
        try {
            await submitFeedback({ page, questId, questSetId, body })
            setBody('')
            setOpen(false)
            setToast(true)
            setTimeout(() => setToast(false), 2000)
        } finally {
            setLoading(false)
        }
    }

    return (
        <>
            {/* 고정 버튼 */}
            <button
                onClick={() => setOpen(true)}
                title="피드백 보내기"
                className="fixed top-4 right-4 z-50 flex items-center gap-1.5 px-3 py-1.5 border border-outline-variant bg-surface hover:bg-surface-container-high font-mono text-label-caps text-on-surface-variant transition-colors"
            >
                <span className="material-symbols-outlined text-[16px]">feedback</span>
                피드백
            </button>

            {/* 모달 */}
            {open && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
                    <div className="bg-surface border border-outline-variant w-[480px] p-6 flex flex-col gap-4">
                        <div className="flex items-center justify-between">
                            <h2 className="font-mono text-body-lg font-bold text-on-surface">피드백 보내기</h2>
                            <button onClick={() => setOpen(false)} className="text-on-surface-variant hover:text-on-surface">
                                <span className="material-symbols-outlined text-[20px]">close</span>
                            </button>
                        </div>
                        <p className="font-mono text-body-sm text-on-surface-variant">오류나 개선 사항을 자유롭게 남겨주세요.</p>
                        <textarea
                            value={body}
                            onChange={e => setBody(e.target.value)}
                            maxLength={1000}
                            rows={5}
                            placeholder="내용을 입력하세요..."
                            className="w-full bg-surface-container border border-outline-variant p-3 font-mono text-body-sm text-on-surface resize-none focus:outline-none focus:border-primary"
                        />
                        <div className="flex justify-end gap-2">
                            <button
                                onClick={() => setOpen(false)}
                                className="px-4 py-2 border border-outline-variant font-mono text-label-caps text-on-surface-variant hover:bg-surface-container-high transition-colors"
                            >
                                취소
                            </button>
                            <button
                                onClick={handleSubmit}
                                disabled={!body.trim() || loading}
                                className="px-4 py-2 bg-primary font-mono text-label-caps text-on-primary hover:brightness-110 transition-all disabled:opacity-50"
                            >
                                {loading ? '전송 중...' : '제출하기'}
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* 토스트 */}
            {toast && (
                <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 px-4 py-2 bg-surface-container border border-outline-variant font-mono text-label-caps text-on-surface">
                    피드백이 전달됐습니다.
                </div>
            )}
        </>
    )
}
```

---

## Step 4. api.ts — submitFeedback 추가

```ts
export async function submitFeedback(data: {
    page: string
    questId?: number | null
    questSetId?: number | null
    body: string
}) {
    return fetch(`${BASE}/feedback`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', ...authHeaders() },
        body: JSON.stringify(data),
    }).then((r) => r.json())
}
```

---

## Step 5. App.tsx — FeedbackButton 마운트

`FeedbackButton`은 현재 page/questId/questSetId를 알아야 한다.
App.tsx의 각 분기에서 렌더링하거나, 최상단 return에 항상 포함한다.

현재 App.tsx는 화면마다 early return하는 구조라 각 return에 추가하는 방법이 가장 단순하다.

```tsx
import { FeedbackButton } from './components/FeedbackButton'

// 세트 선택 화면
return <>
    <SetSelect ... />
    <FeedbackButton page="home" />
</>

// 퀘스트 화면 return 최상단 div 안에 추가
<FeedbackButton page="quest" questId={quest?.id} questSetId={selectedSetId} />

// progress, leaderboard도 동일하게 각 return에 추가
```

---

## 검증

1. 어느 화면에서나 오른쪽 상단 피드백 버튼 표시
2. 클릭 → 모달 열림
3. 빈 내용 → 제출 버튼 비활성화
4. 제출 → 모달 닫힘 + 토스트 2초
5. DB 확인: `SELECT * FROM feedback ORDER BY created_at DESC LIMIT 5;`
6. `GET /admin/feedback` → 피드백 목록 반환
