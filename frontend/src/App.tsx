import { useState, useEffect, useRef } from 'react'
import { Terminal } from './components/Terminal'
import { QuestPanel } from './components/QuestPanel'
import { SetSelect } from './pages/SetSelect'
import { Progress } from './pages/Progress'
import { Leaderboard } from './pages/Leaderboard'
import type { Quest } from './types'
import { fetchQuests, endSession, fetchMe, token } from './api'
import { Login } from './pages/Login'


function App() {
  const [selectedSetId, setSelectedSetId] = useState<number | null>(null)
  const [quests, setQuests] = useState<Quest[]>([])
  const [questIndex, setQuestIndex] = useState(0)
  const [containerId, setContainerId] = useState('')
  const [sandboxType, setSandboxType] = useState<string>('linux')
  const [user, setUser] = useState<{id: number; name: string; email: string; role: string} | null>(null)
  const [authChecked, setAuthChecked] = useState(false)
  const [page, setPage] = useState<'home' | 'progress' | 'leaderboard'>('home')
  const [completedIndices, setCompletedIndices] = useState<Set<number>>(new Set())
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

  if (page === 'progress') return <Progress onBack={() => setPage('home')} onLeaderboard={() => setPage('leaderboard')} onLogout={handleLogout} userName={user.name} userEmail={user.email} />
  if (page === 'leaderboard') return <Leaderboard onBack={() => setPage('home')} onProgress={() => setPage('progress')} onLogout={handleLogout} userName={user.name} userEmail={user.email} />

  if (selectedSetId === null) {
    function handleSetSelect(id: number, sandboxType: string) {
      setSelectedSetId(id)
      setSandboxType(sandboxType)
      setContainerId('')
    }
    return <SetSelect
        onSelect={handleSetSelect}
        onProgress={() => setPage('progress')}
        onLeaderboard={() => setPage('leaderboard')}
        onLogout={handleLogout}
        userName={user.name}
        userEmail={user.email}
    />
  }

  const quest = quests[questIndex] ?? null

  return (
    <div className="dark h-screen flex flex-col bg-surface overflow-hidden">
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
              total={quests.length}
              index={questIndex}
              completedIndices={completedIndices}
              onPrev={() => setQuestIndex((i) => i - 1)}
              onNext={() => setQuestIndex((i) => i + 1)}
              onHome={() => setSelectedSetId(null)}
              onReset={() => setContainerId('')}
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
          {quest && (
            <Terminal
              key={sandboxType === 'docker-persistent' ? `set-${selectedSetId}` : sandboxType === 'k8s' ? 'k8s' : questIndex}
              sandboxType={sandboxType}
              questId={quest?.id ?? null}
              containerId={containerId || null}
              onConnected={setContainerId}
            />
          )}
        </section>
      </main>
    </div>
  )
}

export default App
