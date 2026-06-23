# Phase 4 구현 가이드 — MariaDB 연동 + 퀘스트 세트 구조

명세: `docs/specs/spec_phase4_db.md`
상태: **대기**

---

## 목표

하드코딩된 퀘스트를 MariaDB로 이전한다. 기존 채점/터미널 흐름은 그대로 유지.

---

## 4-1. 사전 준비

Docker로 MariaDB 실행 (개발용):

```bash
docker run -d \
  --name etude-db \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=etude \
  -p 3306:3306 \
  mariadb:11
```

패키지 설치:

```bash
cd backend
npm install mysql2
```

---

## 4-2. DB 연결

`backend/src/db.ts` 신규 생성:

```typescript
import mysql from 'mysql2/promise'

export const db = mysql.createPool({
  host: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? 3306),
  user: process.env.DB_USER ?? 'root',
  password: process.env.DB_PASSWORD ?? 'root',
  database: process.env.DB_NAME ?? 'etude',
})
```

---

## 4-3. 스키마 + Seed 실행

```sql
CREATE TABLE quest_set (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(100) NOT NULL,
  description TEXT
);

CREATE TABLE quest (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  quest_set_id INT NOT NULL,
  order_index  INT NOT NULL DEFAULT 0,
  title        VARCHAR(200) NOT NULL,
  description  TEXT NOT NULL,
  hint         TEXT,
  grade_cmd    JSON NOT NULL,
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);

INSERT INTO quest_set (title, description) VALUES
  ('리눅스 기초', '기본적인 리눅스 명령어를 실습합니다.');

INSERT INTO quest (quest_set_id, order_index, title, description, hint, grade_cmd) VALUES
  (1, 1, '/tmp/hello 디렉토리 만들기',
   '/tmp 경로 안에 hello라는 이름의 디렉토리를 만드세요.',
   'mkdir 명령어를 사용하세요.',
   '["test", "-d", "/tmp/hello"]'),
  (1, 2, '파일에 내용 쓰기',
   '/tmp/answer.txt 파일을 만들고 첫 줄에 "done"을 입력하세요.',
   'echo 명령어와 리다이렉션(>)을 사용하세요.',
   '["grep", "-q", "done", "/tmp/answer.txt"]');
```

---

## 4-4. 백엔드 수정

`backend/src/quest.ts` 전체 교체 — 하드코딩 제거, DB 조회로 변경:

```typescript
import Docker from 'dockerode'
import { db } from './db.js'

async function execCheck(container: Docker.Container, cmd: string[]): Promise<boolean> {
  const exec = await container.exec({ Cmd: cmd })
  await exec.start({})
  while (true) {
    const info = await exec.inspect()
    if (!info.Running) return info.ExitCode === 0
    await new Promise((r) => setTimeout(r, 100))
  }
}

export async function getQuestSets() {
  const [rows] = await db.query('SELECT id, title, description FROM quest_set')
  return rows
}

export async function getQuests(questSetId: number) {
  const [rows] = await db.query(
    'SELECT id, title, description, hint FROM quest WHERE quest_set_id = ? ORDER BY order_index',
    [questSetId]
  )
  return rows
}

export async function gradeQuest(containerId: string, questId: number, docker: Docker): Promise<boolean> {
  const [rows] = await db.query<any[]>(
    'SELECT grade_cmd FROM quest WHERE id = ?',
    [questId]
  )
  if (!rows.length) return false
  const cmd: string[] = JSON.parse(rows[0].grade_cmd)
  return execCheck(docker.getContainer(containerId), cmd)
}
```

`backend/src/index.ts` — API 추가:

```typescript
import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import Docker from 'dockerode'
import { handleTerminal } from './terminal.js'
import { getQuestSets, getQuests, gradeQuest } from './quest.js'

const fastify = Fastify({ logger: true })
const docker = new Docker()

await fastify.register(cors, { origin: 'http://localhost:5173' })
await fastify.register(websocket)

await fastify.register(async function (app) {
  app.get('/ws/terminal', { websocket: true }, (socket, _req) => {
    handleTerminal(socket, docker).catch((err) => {
      console.error('terminal error:', err)
      socket.close()
    })
  })
})

fastify.get('/quest-sets', async () => getQuestSets())

fastify.get<{ Params: { id: string } }>('/quest-sets/:id/quests', async (req) => {
  return getQuests(Number(req.params.id))
})

fastify.post<{ Body: { containerId: string; questId: number } }>('/grade', async (req) => {
  const { containerId, questId } = req.body
  const passed = await gradeQuest(containerId, questId, docker)
  return { passed }
})

await fastify.listen({ port: 3001, host: '0.0.0.0' })
```

---

## 4-5. 프론트엔드 수정

`frontend/src/pages/SetSelect.tsx` 신규 생성 — 세트 선택 화면:

```typescript
import { useEffect, useState } from 'react'

interface QuestSet {
  id: number
  title: string
  description: string
}

interface Props {
  onSelect: (setId: number) => void
}

export function SetSelect({ onSelect }: Props) {
  const [sets, setSets] = useState<QuestSet[]>([])

  useEffect(() => {
    fetch('http://localhost:3001/quest-sets')
      .then((r) => r.json())
      .then(setSets)
  }, [])

  return (
    <div style={{ padding: '3rem', maxWidth: '600px', margin: '0 auto' }}>
      <h1 style={{ fontSize: '24px', color: '#f0f0f0', marginBottom: '8px' }}>Etude</h1>
      <p style={{ color: '#666', fontSize: '14px', marginBottom: '2rem' }}>트레이닝 세트를 선택하세요.</p>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        {sets.map((s) => (
          <button
            key={s.id}
            onClick={() => onSelect(s.id)}
            style={{
              padding: '20px 24px',
              background: '#1e1e1e',
              border: '1px solid #2a2a2a',
              borderRadius: '8px',
              color: '#f0f0f0',
              textAlign: 'left',
              cursor: 'pointer',
            }}
          >
            <div style={{ fontSize: '16px', fontWeight: 600, marginBottom: '4px' }}>{s.title}</div>
            <div style={{ fontSize: '13px', color: '#888' }}>{s.description}</div>
          </button>
        ))}
      </div>
    </div>
  )
}
```

`frontend/src/App.tsx` 전체 교체 — 세트 선택 → 퀘스트 진행 흐름:

```typescript
import { useState, useEffect } from 'react'
import { Terminal } from './components/Terminal'
import { QuestPanel } from './components/QuestPanel'
import { SetSelect } from './pages/SetSelect'

interface Quest {
  id: number
  title: string
  description: string
  hint: string
}

function App() {
  const [selectedSetId, setSelectedSetId] = useState<number | null>(null)
  const [quests, setQuests] = useState<Quest[]>([])
  const [questIndex, setQuestIndex] = useState(0)
  const [containerId, setContainerId] = useState('')

  useEffect(() => {
    if (selectedSetId === null) return
    fetch(`http://localhost:3001/quest-sets/${selectedSetId}/quests`)
      .then((r) => r.json())
      .then((data: Quest[]) => {
        setQuests(data)
        setQuestIndex(0)
      })
  }, [selectedSetId])

  if (selectedSetId === null) {
    return <SetSelect onSelect={setSelectedSetId} />
  }

  const quest = quests[questIndex] ?? null

  return (
    <div style={{ display: 'flex', height: '100vh' }}>
      <div style={{ width: '40%', borderRight: '1px solid #2a2a2a', overflowY: 'auto' }}>
        {quest && (
          <QuestPanel
            key={quest.id}
            quest={quest}
            containerId={containerId}
            total={quests.length}
            index={questIndex}
            onPrev={() => setQuestIndex((i) => i - 1)}
            onNext={() => setQuestIndex((i) => i + 1)}
          />
        )}
      </div>
      <div style={{ flex: 1 }}>
        <Terminal key={questIndex} onConnected={setContainerId} />
      </div>
    </div>
  )
}

export default App
```

---

## 4-6. 검증

- [ ] 세트 선택 화면에서 "리눅스 기초" 세트가 표시됨
- [ ] 세트 클릭 → 퀘스트 진행 화면으로 이동
- [ ] 터미널에서 퀘스트 풀고 채점까지 한 사이클 완료
- [ ] DB에 퀘스트 1개 추가 후 코드 수정 없이 화면에 반영됨
