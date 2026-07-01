import { useState, useEffect, useRef } from 'react'
import { Terminal } from './components/Terminal'
import { FeedbackButton } from './components/FeedbackButton'
import { QuestPanel } from './components/QuestPanel'
import { SetSelect } from './pages/SetSelect'
import { Progress } from './pages/Progress'
import { Leaderboard } from './pages/Leaderboard'
import { Admin } from './pages/Admin'
import type { Quest } from './types'
import { fetchQuests, endSession } from './api/quest'
import { fetchMe, token } from './api/auth'
import { Login } from './pages/Login'



function App() {
  const [selectedSetId, setSelectedSetId] = useState<number | null>(null)
  const [quests, setQuests] = useState<Quest[]>([])
  const [questIndex, setQuestIndex] = useState(0)
  const [containerId, setContainerId] = useState('')
  const [sandboxType, setSandboxType] = useState<string>('linux')
  const [user, setUser] = useState<{id: number; name: string; email: string; role: string} | null>(null)
  const [authChecked, setAuthChecked] = useState(false)
  const [page, setPage] = useState<'home' | 'progress' | 'leaderboard' | 'admin'>('home')
  const [completedIndices, setCompletedIndices] = useState<Set<number>>(new Set())
  const [sessionId, setSessionId] = useState('')
  const [resetKey, setResetKey] = useState(0)
  const [preparing, setPreparing] = useState(false)
  const containerIdRef = useRef(containerId)
  const sandboxTypeRef = useRef(sandboxType)

  useEffect(() => { containerIdRef.current = containerId }, [containerId])
  useEffect(() => { sandboxTypeRef.current = sandboxType }, [sandboxType])

  useEffect(() => {
    fetchMe()
      .then(setUser)
      .catch(() => {})
      .finally(() => setAuthChecked(true))
  }, [])
  
  useEffect(() => {
    if (selectedSetId === null) return
    fetchQuests(selectedSetId)
      .then((data: Quest[]) => {
        setQuests(data)
        setQuestIndex(0)
        setCompletedIndices(new Set())
        setSessionId(`${Date.now()}-${Math.random().toString(36).slice(2)}`)
      })
    return () => {
      if (containerIdRef.current && sandboxTypeRef.current === 'docker-persistent') {
        endSession(containerIdRef.current).catch(() => {})
      }
    }
  }, [selectedSetId])

  // 토큰 검증 전 - 빈 화면 (깜박임 방지)
  if (!authChecked) return null

  // 비로그인 - 로그인 화면
  if (!user) return <Login onLogin={(u) => setUser(u)} />

  const handleLogout = () => { token.clear(); setUser(null) }

  if (page === 'progress') return <>
    <Progress onBack={() => setPage('home')} onLeaderboard={() => setPage('leaderboard')} onAdmin={() => setPage('admin')} onLogout={handleLogout} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="progress" />
  </>
  if (page === 'leaderboard') return <>
    <Leaderboard onBack={() => setPage('home')} onProgress={() => setPage('progress')} onAdmin={() => setPage('admin')} onLogout={handleLogout} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="leaderboard" />
  </>
  if (page === 'admin') {
    if (user.role !== 'admin') { setPage('home'); return null }
    return <>
      <Admin
        onHome={() => setPage('home')}
        onProgress={() => setPage('progress')}
        onLeaderboard={() => setPage('leaderboard')}
        onLogout={handleLogout}
        userName={user.name}
        userEmail={user.email}
        userRole={user.role}
      />
      <FeedbackButton page="admin" />
    </>
  }

  if (selectedSetId === null) {
    function handleSetSelect(id: number, sandboxType: string) {
      setSelectedSetId(id)
      setSandboxType(sandboxType)
      setContainerId('')
      setPreparing(true)
    }
    return <>
      <SetSelect
          onSelect={handleSetSelect}
          onProgress={() => setPage('progress')}
          onLeaderboard={() => setPage('leaderboard')}
          onAdmin={() => setPage('admin')}
          onLogout={handleLogout}
          userName={user.name}
          userEmail={user.email}
          userRole={user.role}
      />
      <FeedbackButton page="home" />
    </>
  }

  const quest = quests[questIndex] ?? null

  return (
    <div className="dark h-screen flex flex-col bg-surface overflow-hidden relative">
      <FeedbackButton page="quest" questId={quest?.id} questSetId={selectedSetId} />
      {/* TopNav */}
      <header className="flex items-center w-full px-gutter h-14 bg-surface border-b border-outline-variant shrink-0">
        <button onClick={() => setSelectedSetId(null)} className="font-mono text-body-lg font-bold tracking-tighter text-on-surface hover:text-primary transition-colors">
          OKESTRO TRAINING | Etude
        </button>
      </header>
      <main className="flex flex-1 overflow-hidden">
        <section className="w-[40%] flex flex-col">
          {quest && (
            <QuestPanel
              key={quest.id}
              quest={quest}
              containerId={containerId}
              questSetId={selectedSetId}
              sessionId={sessionId}
              total={quests.length}
              index={questIndex}
              completedIndices={completedIndices}
              onPrev={() => setQuestIndex((i) => i - 1)}
              onNext={() => setQuestIndex((i) => i + 1)}
              onHome={() => setSelectedSetId(null)}
              onReset={async () => {
                setPreparing(true)
                if (containerId) await endSession(containerId).catch(() => {})
                setContainerId('')
                setResetKey(k => k + 1)
              }}
              onComplete={(i) => setCompletedIndices(prev => new Set(prev).add(i))}
            />
          )}
        </section>
        <section className="w-[60%] flex flex-col bg-surface-container-lowest">
          <div className="h-9 border-b border-outline-variant flex items-center px-4 bg-surface justify-between shrink-0">
            <div className="flex items-center gap-4">
              <span className="font-mono text-label-caps text-on-surface flex items-center gap-2">
                <span className="material-symbols-outlined text-[16px]">terminal</span> 터미널
              </span>
            </div>
            <div className="flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-success"></span>
              <span className="font-mono text-label-caps text-on-surface-variant">연결됨</span>
            </div>
          </div>
          {quest
            ? <Terminal
                key={`${sandboxType === 'docker-persistent' ? `set-${selectedSetId}` : questIndex}-${resetKey}`}
                sandboxType={sandboxType}
                questId={quest.id}
                containerId={containerId || null}
                onConnected={(id) => { setContainerId(id); setPreparing(false) }}
              />
            : null
          }
          {preparing && (
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 bg-surface/80 z-50">
              <div className="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin" />
              <span className="font-mono text-label-caps text-on-surface-variant">환경 준비 중...</span>
            </div>
          )}
        </section>
      </main>
    </div>
  )
}

export default App
