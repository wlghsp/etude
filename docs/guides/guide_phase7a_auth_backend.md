# Phase 7a 구현 가이드 — 백엔드 인증

명세: [specs/spec_phase7_auth.md](../specs/spec_phase7_auth.md)

이 문서를 보고 `spec_phase7_auth.md`의 백엔드 부분을 구현합니다.

---

## 구현 순서

```
1. init.sql — user, quest_progress 테이블 추가    → DB 재초기화로 확인
2. 패키지 설치 — bcrypt, jsonwebtoken              → tsc 오류 없음 확인
3. auth.ts — JWT 발급/검증, 로그인 로직            → 단독 함수 호출로 확인
4. index.ts — 라우트 추가, authMiddleware 적용     → curl로 API 확인
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

CREATE TABLE quest_progress (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  quest_id     INT NOT NULL,
  completed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_user_quest (user_id, quest_id),
  FOREIGN KEY (user_id) REFERENCES user(id),
  FOREIGN KEY (quest_id) REFERENCES quest(id)
);
```

시드 계정도 추가 (비밀번호 `password123`의 bcrypt 해시):

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

// 로그인: 이메일/비밀번호 확인 후 JWT 발급
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

// 토큰 검증 — 유효하면 payload 반환, 아니면 throw
export function verifyToken(token: string): JwtPayload {
  return jwt.verify(token, JWT_SECRET) as JwtPayload
}
```

---

## Step 4. index.ts — 라우트 + 미들웨어 추가

### 4-1. authMiddleware 작성

`backend/src/index.ts` 상단 import에 추가:
```typescript
import { login, verifyToken } from './auth'
import type { JwtPayload } from './auth'
```

미들웨어 함수 추가 (fastify 선언 아래):
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
```

### 4-2. 로그인 API 추가

```typescript
fastify.post('/auth/login', async (request, reply) => {
  const { email, password } = request.body as { email: string; password: string }
  try {
    const result = await login(email, password)
    return result
  } catch (e: any) {
    return reply.code(401).send({ error: e.message })
  }
})
```

### 4-3. /me API 추가

```typescript
fastify.get('/me', { preHandler: authMiddleware }, async (request: any) => {
  return request.user
})
```

### 4-4. /progress API 추가

```typescript
fastify.get('/progress', { preHandler: authMiddleware }, async (request: any) => {
  const userId = request.user.userId
  const [rows] = await pool.query(`
    SELECT
      qs.id AS quest_set_id,
      qs.title,
      qs.category,
      COUNT(q.id) AS total,
      COUNT(qp.id) AS completed
    FROM quest_set qs
    JOIN quest q ON q.quest_set_id = qs.id
    LEFT JOIN quest_progress qp ON qp.quest_id = q.id AND qp.user_id = ?
    GROUP BY qs.id
    ORDER BY qs.id
  `, [userId]) as any[]
  return rows
})
```

### 4-5. /grade에 progress 기록 추가

기존 `/grade` 라우트에서 `passed === true`일 때 아래 코드 추가:

```typescript
// 기존 채점 로직 아래에 추가
if (passed) {
  const auth = request.headers['authorization'] ?? ''
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : ''
  if (token) {
    try {
      const payload = verifyToken(token)
      await pool.query(
        'INSERT IGNORE INTO quest_progress (user_id, quest_id) VALUES (?, ?)',
        [payload.userId, questId]
      )
    } catch {}  // 토큰 없거나 만료돼도 채점 결과는 정상 반환
  }
}
```

> `INSERT IGNORE` — 같은 퀘스트를 재채점해도 중복 기록 안 됨

---

## 검증

```bash
# 로그인
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@okestro.com","password":"password123"}'
# → {"token":"eyJ...","user":{...}}

# 내 정보 (토큰 교체)
curl http://localhost:3001/me \
  -H "Authorization: Bearer <토큰>"
# → {"userId":2,"email":"test@okestro.com","role":"member"}

# 진행 현황 (빈 상태)
curl http://localhost:3001/progress \
  -H "Authorization: Bearer <토큰>"
# → [{quest_set_id:1, total:10, completed:0}, ...]

# 토큰 없이 호출
curl http://localhost:3001/me
# → 401 {"error":"인증이 필요합니다."}
```
