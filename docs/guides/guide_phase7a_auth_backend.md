# Phase 7a 구현 가이드 — 백엔드 인증

명세: [specs/spec_phase7_auth.md](../specs/spec_phase7_auth.md)

이 문서를 보고 `spec_phase7_auth.md`의 백엔드 부분을 구현합니다.

---

## 구현 순서

```
1. init.sql — user, quest_attempt 테이블 추가       → DB 재초기화로 확인
2. 패키지 설치 — bcrypt, jsonwebtoken               → tsc 오류 없음 확인
3. auth.ts — JWT 발급/검증, 로그인 로직             → 단독 함수 호출로 확인
4. index.ts — 라우트 추가, 미들웨어 적용            → curl로 API 확인
```

---

## Step 1. init.sql — 테이블 + 시드 추가

`backend/db/init.sql` 파일 맨 끝에 추가:

```sql
CREATE TABLE user (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(200) NOT NULL UNIQUE,
  password   VARCHAR(200) NOT NULL,
  role       ENUM('member', 'admin') NOT NULL DEFAULT 'member',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 중복 허용 — 반복 시도가 쌓이는 구조 (Phase 9 분석의 원본 데이터)
CREATE TABLE quest_attempt (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  user_id        INT NOT NULL,
  quest_id       INT NOT NULL,
  quest_set_id   INT NOT NULL,
  session_id     VARCHAR(36) NOT NULL,
  elapsed_sec    INT,
  hint_used      BOOLEAN NOT NULL DEFAULT FALSE,
  solution_used  BOOLEAN NOT NULL DEFAULT FALSE,
  passed         BOOLEAN NOT NULL DEFAULT FALSE,
  attempted_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)      REFERENCES user(id),
  FOREIGN KEY (quest_id)     REFERENCES quest(id),
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);
```

시드 계정 추가 (비밀번호 `password123`의 bcrypt 해시):

```sql
INSERT INTO user (name, email, password, role) VALUES
  ('관리자', 'admin@okestro.com', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
  ('테스트', 'test@okestro.com',  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member');
```

DB 재초기화:
```bash
docker-compose down -v && docker-compose up -d
```

---

## Step 2. 패키지 설치

```bash
cd backend
npm install bcrypt jsonwebtoken
npm install -D @types/bcrypt @types/jsonwebtoken
```

---

## Step 3. auth.ts 작성

`backend/src/auth.ts` 신규 작성:

```typescript
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { pool } from './db'

const JWT_SECRET = process.env.JWT_SECRET ?? 'dev-secret'
const JWT_EXPIRES = '24h'

export interface JwtPayload {
  userId: number
  email: string
  role: string
}

export async function login(email: string, password: string) {
  const [rows] = await pool.query(
    'SELECT id, name, email, password, role FROM user WHERE email = ?',
    [email]
  ) as any[]

  const user = rows[0]
  if (!user) throw new Error('이메일 또는 비밀번호가 올바르지 않습니다.')

  const match = await bcrypt.compare(password, user.password)
  if (!match) throw new Error('이메일 또는 비밀번호가 올바르지 않습니다.')

  const token = jwt.sign(
    { userId: user.id, email: user.email, role: user.role } satisfies JwtPayload,
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES }
  )

  return {
    token,
    user: { id: user.id, name: user.name, email: user.email, role: user.role }
  }
}

export function verifyToken(token: string): JwtPayload {
  return jwt.verify(token, JWT_SECRET) as JwtPayload
}
```

---

## Step 4. index.ts — 라우트 + 미들웨어 추가

### 4-1. import 추가

```typescript
import { login, verifyToken } from './auth'
import type { JwtPayload } from './auth'
```

### 4-2. 미들웨어 작성 (fastify 선언 아래)

```typescript
async function authMiddleware(request: any, reply: any) {
  const auth = request.headers['authorization'] ?? ''
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
  if (!token) return reply.code(401).send({ error: '인증이 필요합니다.' })
  try {
    request.user = verifyToken(token)
  } catch {
    return reply.code(401).send({ error: '토큰이 유효하지 않습니다.' })
  }
}

async function adminMiddleware(request: any, reply: any) {
  await authMiddleware(request, reply)
  if (request.user?.role !== 'admin') {
    return reply.code(403).send({ error: '관리자 권한이 필요합니다.' })
  }
}
```

### 4-3. 로그인 API

```typescript
fastify.post('/auth/login', async (request, reply) => {
  const { email, password } = request.body as { email: string; password: string }
  try {
    return await login(email, password)
  } catch (e: any) {
    return reply.code(401).send({ error: e.message })
  }
})
```

### 4-4. /me API

```typescript
fastify.get('/me', { preHandler: authMiddleware }, async (request: any) => {
  return request.user
})
```

### 4-5. /progress API

`passed = true`인 attempt 기준으로 세트별 완료 수 집계:

```typescript
fastify.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
  const userId = request.user.userId
  const [rows] = await pool.query(`
    SELECT
      qs.id AS quest_set_id,
      qs.title,
      qs.category,
      COUNT(DISTINCT q.id) AS total,
      COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.quest_id END) AS completed
    FROM quest_set qs
    JOIN quest q ON q.quest_set_id = qs.id
    LEFT JOIN quest_attempt qa ON qa.quest_id = q.id AND qa.user_id = ?
    GROUP BY qs.id
    ORDER BY qs.id
  `, [userId]) as any[]
  return rows
})
```

### 4-6. /leaderboard API

전체 팀원 공개 리더보드 — 로그인한 모든 팀원이 접근 가능.

```typescript
fastify.get('/leaderboard', { preHandler: authMiddleware }, async () => {
  const [rows] = await pool.query(`
    SELECT
      u.name AS userName,
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
    ORDER BY u.name, qs.id
  `) as any[]
  return rows
})
```

### 4-7. /admin/users API (계정 생성)

```typescript
import bcrypt from 'bcrypt'

fastify.post('/admin/users', { preHandler: adminMiddleware }, async (request, reply) => {
  const { name, email, password } = request.body as { name: string; email: string; password: string }
  const hashed = await bcrypt.hash(password, 10)
  const [result] = await pool.query(
    'INSERT INTO user (name, email, password, role) VALUES (?, ?, ?, ?)',
    [name, email, hashed, 'member']
  ) as any[]
  return { id: result.insertId, name, email, role: 'member' }
})
```

### 4-8. /admin/users/:id/password API (비밀번호 초기화)

```typescript
fastify.patch('/admin/users/:id/password', { preHandler: adminMiddleware }, async (request, reply) => {
  const { id } = request.params as { id: string }
  const { password } = request.body as { password: string }
  const hashed = await bcrypt.hash(password, 10)
  await pool.query('UPDATE user SET password = ? WHERE id = ?', [hashed, id])
  return { ok: true }
})
```

### 4-9. /grade에 attempt 기록 추가

기존 `/grade` 라우트의 요청 파싱 부분에 새 필드 추가:

```typescript
const { containerId, questId, questSetId, sessionId, elapsedSec, hintUsed, solutionUsed }
  = request.body as {
    containerId: string
    questId: number
    questSetId: number
    sessionId: string
    elapsedSec?: number
    hintUsed?: boolean
    solutionUsed?: boolean
  }
```

채점 후 항상 attempt 기록 (성공/실패 모두):

```typescript
const auth = request.headers['authorization'] ?? ''
const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
if (token) {
  try {
    const payload = verifyToken(token)
    await pool.query(
      `INSERT INTO quest_attempt
        (user_id, quest_id, quest_set_id, session_id, elapsed_sec, hint_used, solution_used, passed)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [payload.userId, questId, questSetId, sessionId, elapsedSec ?? null,
       hintUsed ?? false, solutionUsed ?? false, passed]
    )
  } catch {}  // 토큰 없거나 만료돼도 채점 결과는 정상 반환
}
```

> 성공/실패 모두 기록 — "몇 번 시도 후 성공했는지"를 Phase 9에서 분석할 수 있어야 하기 때문.

---

## 검증

```bash
# 로그인
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@okestro.com","password":"password123"}'
# → {"token":"eyJ...","user":{...}}

# 내 진행 현황
curl http://localhost:3001/progress \
  -H "Authorization: Bearer <토큰>"
# → [{quest_set_id:1, total:10, completed:0}, ...]

# 전체 팀원 리더보드 (모든 로그인 사용자 접근 가능)
curl http://localhost:3001/leaderboard \
  -H "Authorization: Bearer <토큰>"

# 토큰 없이 → 401
curl http://localhost:3001/me
```
