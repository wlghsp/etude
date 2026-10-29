import { useState, useEffect } from 'react'
import { Terminal, type TerminalStatus } from './components/Terminal'
import { FeedbackButton } from './components/FeedbackButton'
import { QuestPanel } from './components/QuestPanel'
import { SetComplete, type QuestRecord } from './components/SetComplete'
import { SetSelect } from './pages/SetSelect'
import { Progress } from './pages/Progress'
import { Leaderboard } from './pages/Leaderboard'
import { Admin } from './pages/Admin'
import type { Quest } from './types'
import { fetchQuests, completeSet } from './api/quest'
import { fetchMe, token } from './api/auth'
import { Login } from './pages/Login'
import { ChangePasswordModal } from './components/ChangePasswordModal'



const TERMINAL_STATUS_VIEW: Record<TerminalStatus, { dot: string; label: string }> = {
  connecting: { dot: 'bg-info animate-pulse', label: '연결 중' },
  connected: { dot: 'bg-success', label: '연결됨' },
  ended: { dot: 'bg-error', label: '연결 끊김' },
}

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
  // 이번에 세트에 들어와서 푼 기록 (세트 완료 화면에서 보여 준다). 세트가 바뀌면 비운다.
  const [records, setRecords] = useState<Record<number, QuestRecord>>({})
  const [summaryOpen, setSummaryOpen] = useState(false)
  // 세트 완료 기록 저장 상태 (모든 퀘스트를 통과하면 서버에 한 번 저장한다)
  const [saveState, setSaveState] = useState<'idle' | 'saving' | 'saved' | 'failed'>('idle')
  const [sessionId, setSessionId] = useState('')
  const [resetKey, setResetKey] = useState(0)
  const [preparing, setPreparing] = useState(false)
  const [terminalStatus, setTerminalStatus] = useState<TerminalStatus>('connecting')
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
        setRecords({})
        setSummaryOpen(false)
        setSaveState('idle')
        setSessionId(`${Date.now()}-${Math.random().toString(36).slice(2)}`)
      })
    return () => { cancelled = true }
  }, [selectedSetId])

  function handleSetSelect(id: number, sandboxType: string) {
    setSelectedSetId(id)
    // 이전 세트의 퀘스트로 터미널이 마운트되면 서버가 잘못된 세트로 세션을 만든다. 새 목록이 올 때까지 비운다.
    setQuests([])
    setQuestIndex(0)
    setSandboxType(sandboxType)
    setContainerId('')
    setPreparing(true)
  }

  // 세트의 모든 퀘스트를 통과하면 완료 기록을 저장한다. 서버가 이 세션의 채점 기록으로 확인하고, 같은 세션의 중복 요청은 한 번만 저장된다.
  useEffect(() => {
    if (saveState !== 'idle' || selectedSetId === null || !sessionId) return
    if (quests.length === 0 || completedIndices.size < quests.length) return
    setSaveState('saving')
    completeSet(selectedSetId, sessionId).then(() => setSaveState('saved')).catch(() => setSaveState('failed'))
  }, [saveState, selectedSetId, sessionId, quests.length, completedIndices])

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
        <button onClick={() => setSelectedSetId(null)} className="font-sans text-body-lg font-bold tracking-tighter text-on-surface hover:text-primary transition-colors">
          OKESTRO TRAINING | Etude
        </button>
      </header>
      <main className="flex flex-1 overflow-hidden">
        <section className="w-[40%] flex flex-col">
          {summaryOpen
            ? <SetComplete
                setId={selectedSetId}
                quests={quests}
                records={records}
                saveState={saveState}
                onRetrySave={() => setSaveState('idle')}
                onHome={() => setSelectedSetId(null)}
                onReview={(i) => { setQuestIndex(i); setSummaryOpen(false) }}
              />
            : quest && (
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
              onFinish={() => setSummaryOpen(true)}
              onReset={() => {
                setPreparing(true)
                setContainerId('')
                setResetKey(k => k + 1)
              }}
              onComplete={(i, record) => {
                setCompletedIndices(prev => new Set(prev).add(i))
                setRecords(prev => ({ ...prev, [i]: record }))
              }}
            />
          )}
        </section>
        <section className="w-[60%] flex flex-col bg-surface-container-lowest">
          <div className="h-9 border-b border-outline-variant flex items-center px-4 bg-surface justify-between shrink-0">
            <div className="flex items-center gap-4">
              <span className="font-sans text-label-caps text-on-surface flex items-center gap-2">
                <span className="material-symbols-outlined text-[16px]">terminal</span> 터미널
              </span>
            </div>
            <div className="flex items-center gap-2">
              <span className={`w-2 h-2 rounded-full ${TERMINAL_STATUS_VIEW[terminalStatus].dot}`}></span>
              <span className="font-sans text-label-caps text-on-surface-variant">{TERMINAL_STATUS_VIEW[terminalStatus].label}</span>
            </div>
          </div>
          {quest
            ? <Terminal
                key={`${sandboxType === 'docker-persistent' ? `set-${selectedSetId}` : questIndex}-${resetKey}`}
                questId={quest.id}
                onConnected={(id) => { setContainerId(id); setPreparing(false) }}
                onStatus={(status) => {
                  setTerminalStatus(status)
                  if (status === 'ended') setPreparing(false)
                }}
              />
            : null
          }
          {preparing && (
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 bg-surface/80 z-50">
              <div className="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin" />
              <span className="font-sans text-label-caps text-on-surface-variant">환경 준비 중...</span>
            </div>
          )}
        </section>
      </main>
    </div>
  )
}

export default App
