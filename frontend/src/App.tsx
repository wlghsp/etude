import { useState, useEffect } from 'react'
import { Terminal } from './components/Terminal'
import { FeedbackButton } from './components/FeedbackButton'
import { QuestPanel } from './components/QuestPanel'
import { SetSelect } from './pages/SetSelect'
import { Progress } from './pages/Progress'
import { Leaderboard } from './pages/Leaderboard'
import { Admin } from './pages/Admin'
import type { Quest } from './types'
import { fetchQuests } from './api/quest'
import { fetchMe, token } from './api/auth'
import { Login } from './pages/Login'
import { ChangePasswordModal } from './components/ChangePasswordModal'



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
  const [changePasswordOpen, setChangePasswordOpen] = useState(false)
  const openChangePassword = () => setChangePasswordOpen(true)

  useEffect(() => {
    fetchMe()
      .then(setUser)
      .catch(() => {})
      .finally(() => setAuthChecked(true))
  }, [])
  
  useEffect(() => {
    if (selectedSetId === null) return
    let cancelled = false
    fetchQuests(selectedSetId)
      .then((data: Quest[]) => {
        if (cancelled) return
        setQuests(data)
        setQuestIndex(0)
        setCompletedIndices(new Set())
        setSessionId(`${Date.now()}-${Math.random().toString(36).slice(2)}`)
      })
    return () => { cancelled = true }
  }, [selectedSetId])

  // 토큰 검증 전 - 빈 화면 (깜박임 방지)
  if (!authChecked) return null

  // 비로그인 - 로그인 화면
  if (!user) return <Login onLogin={(u) => setUser(u)} />

  const handleLogout = () => { token.clear(); setUser(null) }

  if (page === 'progress') return <>
    <Progress onBack={() => setPage('home')} onLeaderboard={() => setPage('leaderboard')} onAdmin={() => setPage('admin')} onLogout={handleLogout} onChangePassword={openChangePassword} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="progress" />
    <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
  </>
  if (page === 'leaderboard') return <>
    <Leaderboard onBack={() => setPage('home')} onProgress={() => setPage('progress')} onAdmin={() => setPage('admin')} onLogout={handleLogout} onChangePassword={openChangePassword} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="leaderboard" />
    <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
  </>
  if (page === 'admin') {
    if (user.role !== 'admin') { setPage('home'); return null }
    return <>
      <Admin
        onHome={() => setPage('home')}
        onProgress={() => setPage('progress')}
        onLeaderboard={() => setPage('leaderboard')}
        onLogout={handleLogout}
        onChangePassword={openChangePassword}
        userName={user.name}
        userEmail={user.email}
        userRole={user.role}
      />
      <FeedbackButton page="admin" />
      <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
    </>
  }

  if (selectedSetId === null) {
    function handleSetSelect(id: number, sandboxType: string) {
      setSelectedSetId(id)
      // 이전 세트의 퀘스트로 터미널이 마운트되면 서버가 잘못된 세트로 세션을 만든다. 새 목록이 올 때까지 비운다.
      setQuests([])
      setQuestIndex(0)
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
          onChangePassword={openChangePassword}
          userName={user.name}
          userEmail={user.email}
          userRole={user.role}
      />
      <FeedbackButton page="home" />
      <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
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
              sessionId={sessionId}
              total={quests.length}
              index={questIndex}
              completedIndices={completedIndices}
              onPrev={() => setQuestIndex((i) => i - 1)}
              onNext={() => setQuestIndex((i) => i + 1)}
              onHome={() => setSelectedSetId(null)}
              onReset={() => {
                setPreparing(true)
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
                questId={quest.id}
                onConnected={(id) => { setContainerId(id); setPreparing(false) }}
                onEnded={() => setPreparing(false)}
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
