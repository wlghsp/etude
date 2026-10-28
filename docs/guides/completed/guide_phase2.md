# Phase 2 구현 가이드 — 퀘스트 + 채점

명세: `docs/specs/spec_phase2_quest.md`
상태: **완료**

---

## 목표

퀘스트 지문 + 터미널 레이아웃 + 채점 + 퀘스트 이동 + 컨테이너 격리

---

## 2-1. 패키지 추가

```bash
cd backend
npm install @fastify/cors
```

---

## 2-2. 백엔드 퀘스트 추가

`backend/src/quest.ts` 신규 생성:

```typescript
import Docker from 'dockerode'

export interface Quest {
  id: number
  title: string
  description: string
  hint: string
  grade: (container: Docker.Container) => Promise<boolean>
}

async function execCheck(container: Docker.Container, cmd: string[]): Promise<boolean> {
  const exec = await container.exec({ Cmd: cmd })
  await exec.start({})
  // stream 이벤트(end/close)가 dockerode에서 불안정 → 폴링 방식으로 완료 감지
  while (true) {
    const info = await exec.inspect()
    if (!info.Running) return info.ExitCode === 0
    await new Promise((r) => setTimeout(r, 100))
  }
}

export const quests: Quest[] = [
  {
    id: 1,
    title: '/tmp/hello 디렉토리 만들기',
    description: '/tmp 경로 안에 hello라는 이름의 디렉토리를 만드세요.',
    hint: 'mkdir 명령어를 사용하세요.',
    grade: (container) => execCheck(container, ['test', '-d', '/tmp/hello']),
  },
  {
    id: 2,
    title: '파일에 내용 쓰기',
    description: '/tmp/answer.txt 파일을 만들고 첫 줄에 "done"을 입력하세요.',
    hint: 'echo 명령어와 리다이렉션(>)을 사용하세요.',
    grade: (container) => execCheck(container, ['grep', '-q', 'done', '/tmp/answer.txt']),
  },
]

export async function gradeQuest(
  containerId: string,
  questId: number,
  docker: Docker
): Promise<boolean> {
  const quest = quests.find((q) => q.id === questId)
  if (!quest) return false
  return quest.grade(docker.getContainer(containerId))
}
```

> 퀘스트 추가 시 `quests` 배열에 항목 하나만 추가하면 된다. `gradeQuest`는 건드릴 필요 없음.

> `/quests` API 응답에서 `grade` 함수는 JSON 직렬화 불가라 자동으로 제외된다.

---

## 2-3. 백엔드 수정

`backend/src/terminal.ts` — docker 인자 추가 + containerId 전송:

```typescript
import Docker from 'dockerode'
import type { WebSocket } from 'ws'

export async function handleTerminal(socket: WebSocket, docker: Docker) {
  const container = await docker.createContainer({
    Image: 'ubuntu',
    Cmd: ['/bin/bash'],
    AttachStdin: true,
    AttachStdout: true,
    AttachStderr: true,
    OpenStdin: true,
    Tty: true,
  })

  const stream = await container.attach({
    stream: true,
    stdin: true,
    stdout: true,
    stderr: true,
    hijack: true,
  })

  await container.start()

  // containerId를 브라우저로 전달 (채점에 필요)
  socket.send(JSON.stringify({ type: 'connected', containerId: container.id }))

  stream.on('data', (chunk: Buffer) => {
    socket.send(chunk)
  })

  socket.on('message', (msg: Buffer) => {
    stream.write(msg)
  })

  socket.on('close', () => {
    container.stop()
      .then(() => container.remove())
      .catch(() => {})
  })
}
```

`backend/src/index.ts` — CORS + quest/grade API 추가 (전체 교체):

```typescript
import Fastify from 'fastify'
import websocket from '@fastify/websocket'
import cors from '@fastify/cors'
import Docker from 'dockerode'
import { handleTerminal } from './terminal.js'
import { quests, gradeQuest } from './quest.js'

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

fastify.get('/quests', async () => quests)

fastify.post<{ Body: { containerId: string; questId: number } }>(
  '/grade',
  async (req) => {
    const { containerId, questId } = req.body
    const passed = await gradeQuest(containerId, questId, docker)
    return { passed }
  }
)

await fastify.listen({ port: 3001, host: '0.0.0.0' })
```

> `docker` 인스턴스를 index.ts에서 하나만 만들고 인자로 넘긴다.

---

## 2-4. 프론트엔드 수정

`frontend/src/index.css` — Vite 기본 템플릿 스타일 제거 후 전체 교체:

```css
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: system-ui, sans-serif;
  background: #1a1a1a;
  color: #e0e0e0;
}

#root {
  height: 100vh;
  display: flex;
  flex-direction: column;
}
```

`frontend/src/App.css` — 전체 비움 (Vite 기본 스타일 제거)

`frontend/src/components/QuestPanel.tsx` 신규 생성:

```typescript
import { useState } from 'react'

interface Quest {
  id: number
  title: string
  description: string
  hint: string
}

interface Props {
  quest: Quest
  containerId: string
  total: number
  index: number
  onPrev: () => void
  onNext: () => void
}

export function QuestPanel({ quest, containerId, total, index, onPrev, onNext }: Props) {
  const [result, setResult] = useState<boolean | null>(null)

  const grade = async () => {
    const res = await fetch('http://localhost:3001/grade', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ containerId, questId: quest.id }),
    })
    const data = await res.json()
    setResult(data.passed)
  }

  return (
    <div style={{ padding: '1.5rem', display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      <div>
        <div style={{ fontSize: '12px', color: '#666', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.08em' }}>
          Quest {index + 1} / {total}
        </div>
        <h2 style={{ fontSize: '20px', color: '#f0f0f0', margin: 0 }}>{quest.title}</h2>
      </div>
      <p style={{ color: '#bbb', lineHeight: '1.6', fontSize: '14px' }}>{quest.description}</p>
      <details>
        <summary style={{ cursor: 'pointer', color: '#666', fontSize: '13px', userSelect: 'none' }}>힌트 보기</summary>
        <p style={{ color: '#888', fontSize: '13px', marginTop: '8px', paddingLeft: '4px' }}>{quest.hint}</p>
      </details>
      <button
        onClick={grade}
        style={{
          marginTop: '8px',
          padding: '10px 20px',
          background: '#7c3aed',
          color: '#fff',
          border: 'none',
          borderRadius: '6px',
          fontSize: '14px',
          fontWeight: 600,
          cursor: 'pointer',
          alignSelf: 'flex-start',
        }}
      >
        채점하기
      </button>
      {result !== null && (
        <div style={{
          padding: '12px 16px',
          borderRadius: '6px',
          fontSize: '14px',
          fontWeight: 500,
          background: result ? 'rgba(34, 197, 94, 0.1)' : 'rgba(239, 68, 68, 0.1)',
          color: result ? '#4ade80' : '#f87171',
          border: `1px solid ${result ? 'rgba(34, 197, 94, 0.3)' : 'rgba(239, 68, 68, 0.3)'}`,
        }}>
          {result ? '✅ 성공!' : '❌ 아직이에요. 다시 시도해보세요.'}
        </div>
      )}
      <div style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
        <button
          onClick={onPrev}
          disabled={index === 0}
          style={{
            padding: '8px 16px',
            background: 'transparent',
            color: index === 0 ? '#444' : '#aaa',
            border: '1px solid',
            borderColor: index === 0 ? '#333' : '#555',
            borderRadius: '6px',
            fontSize: '13px',
            cursor: index === 0 ? 'default' : 'pointer',
          }}
        >
          이전
        </button>
        <button
          onClick={onNext}
          disabled={index === total - 1}
          style={{
            padding: '8px 16px',
            background: 'transparent',
            color: index === total - 1 ? '#444' : '#aaa',
            border: '1px solid',
            borderColor: index === total - 1 ? '#333' : '#555',
            borderRadius: '6px',
            fontSize: '13px',
            cursor: index === total - 1 ? 'default' : 'pointer',
          }}
        >
          다음
        </button>
      </div>
    </div>
  )
}
```

> 퀘스트 전환 시 채점 결과 초기화는 `key={quest.id}` prop으로 처리 (App.tsx 참고).

`frontend/src/components/Terminal.tsx` — onConnected 콜백 추가:

```typescript
import { useEffect, useRef } from 'react'
import { Terminal as XTerm } from '@xterm/xterm'
import { FitAddon } from '@xterm/addon-fit'
import '@xterm/xterm/css/xterm.css'

interface Props {
  onConnected: (containerId: string) => void
}

export function Terminal({ onConnected }: Props) {
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const term = new XTerm({ cursorBlink: true })
    const fitAddon = new FitAddon()
    term.loadAddon(fitAddon)
    term.open(containerRef.current!)
    fitAddon.fit()

    const ws = new WebSocket('ws://localhost:3001/ws/terminal')
    ws.binaryType = 'arraybuffer'

    ws.onopen = () => {
      term.writeln('Connected.')
    }

    ws.onmessage = (e) => {
      if (e.data instanceof ArrayBuffer) {
        term.write(new Uint8Array(e.data))
        return
      }
      try {
        const msg = JSON.parse(e.data)
        if (msg.type === 'connected') {
          onConnected(msg.containerId)
        }
      } catch {
        term.write(e.data)
      }
    }

    term.onData((data) => {
      ws.send(data)
    })

    return () => {
      ws.close()
      term.dispose()
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  return <div ref={containerRef} style={{ height: '100vh', background: '#000' }} />
}
```

`frontend/src/App.tsx` — 퀘스트 인덱스 관리 + 컨테이너 격리:

```typescript
import { useState, useEffect } from 'react'
import { Terminal } from './components/Terminal'
import { QuestPanel } from './components/QuestPanel'

interface Quest {
  id: number
  title: string
  description: string
  hint: string
}

function App() {
  const [quests, setQuests] = useState<Quest[]>([])
  const [questIndex, setQuestIndex] = useState(0)
  const [containerId, setContainerId] = useState('')

  useEffect(() => {
    fetch('http://localhost:3001/quests')
      .then((r) => r.json())
      .then((data: Quest[]) => setQuests(data))
  }, [])

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

> `Terminal`에 `key={questIndex}`를 주면 퀘스트 전환 시 React가 Terminal을 재마운트 → 새 WebSocket 연결 → 새 컨테이너 자동 생성. 컨테이너가 격리된다.

---

## 2-5. 검증

- 브라우저 왼쪽에 퀘스트 지문이 보이는지 (`Quest 1 / 2`)
- 터미널에서 `mkdir /tmp/hello` 실행 후 [채점하기] → "✅ 성공!" 표시
- [다음] 클릭 → 터미널이 새로 연결되고 `Quest 2 / 2`로 전환
- 터미널에서 `echo done > /tmp/answer.txt` 실행 후 [채점하기] → "✅ 성공!" 표시
- 틀렸을 때 → "❌ 아직이에요." 표시

모두 되면 Phase 2 완료.
