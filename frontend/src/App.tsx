import { useState, useEffect, useRef } from 'react'
import { Terminal, type TerminalStatus } from './components/Terminal'
import { useTerminalFontSize } from './components/useTerminalFontSize'
import { FeedbackButton } from './components/FeedbackButton'
import { QuestPanel } from './components/QuestPanel'
import { SetComplete, type QuestRecord } from './components/SetComplete'
import { SetSelect } from './pages/SetSelect'
import { Progress } from './pages/Progress'
import { Leaderboard } from './pages/Leaderboard'
import { Feed } from './pages/Feed'
import { Hall } from './pages/Hall'
import { Review } from './pages/Review'
import { Admin } from './pages/Admin'
import type { Quest } from './types'
import { fetchQuests, completeSet, startSet } from './api/quest'
import { fetchMe, token } from './api/auth'
import { Login } from './pages/Login'
import { ChangePasswordModal } from './components/ChangePasswordModal'
import { ConfirmModal } from './components/ConfirmModal'
import { LoadingScreen } from './components/LoadingScreen'
import { SoundToggle } from './components/SoundToggle'
import { Logo } from './components/Logo'
import { SplitHandle, SPLIT_DEFAULT } from './components/SplitHandle'



const TERMINAL_STATUS_VIEW: Record<TerminalStatus, { dot: string; label: string }> = {
  connecting: { dot: 'bg-info animate-pulse', label: '연결 중' },
  connected: { dot: 'bg-success', label: '연결됨' },
  ended: { dot: 'bg-error', label: '연결 끊김' },
}

type Page = 'home' | 'progress' | 'leaderboard' | 'hall' | 'review' | 'feed' | 'admin'

// 한쪽 패널을 화면 가득 크게 보거나 되돌리는 버튼 (Esc 로도 되돌린다)
function PaneToggle({ active, onClick }: { active: boolean; onClick: () => void }) {
  return (
    <button onClick={onClick} aria-pressed={active} title={active ? '원래 크기로 (Esc)' : '전체보기'} className="rounded p-1 text-on-surface-variant hover:bg-surface-container-high hover:text-on-surface transition-colors">
      <span className="material-symbols-outlined text-[18px]">{active ? 'close_fullscreen' : 'open_in_full'}</span>
    </button>
  )
}

function App() {
  const [selectedSetId, setSelectedSetId] = useState<number | null>(null)
  const [quests, setQuests] = useState<Quest[]>([])
  const [questIndex, setQuestIndex] = useState(0)
  const [containerId, setContainerId] = useState('')
  const [sandboxType, setSandboxType] = useState<string>('linux')
  const [user, setUser] = useState<{id: number; name: string; email: string; role: string} | null>(null)
  const [authChecked, setAuthChecked] = useState(false)
  const [page, setPage] = useState<Page>('home')
  const [completedIndices, setCompletedIndices] = useState<Set<number>>(new Set())
  // 이번에 세트에 들어와서 푼 기록 (세트 완료 화면에서 보여 준다). 세트가 바뀌면 비운다.
  const [records, setRecords] = useState<Record<number, QuestRecord>>({})
  // 문제를 연속으로 한 번에 맞힌 횟수 (틀렸다가 맞히면 끊긴다)
  const [combo, setCombo] = useState(0)
  const [summaryOpen, setSummaryOpen] = useState(false)
  // 시간 제한 세트(시험형): 서버가 기록한 시작 시각 기준의 마감. 없으면 일반 세트. 마감되면 결과 화면으로 넘어간다.
  const [run, setRun] = useState<{ limitSec: number; deadlineMs: number } | null>(null)
  const [expired, setExpired] = useState(false)
  // 문제 풀이 화면의 카드 레이아웃: 문제 패널의 폭 비율(기억해 둔다)과 한쪽만 크게 보는 전체보기
  const [splitPct, setSplitPct] = useState<number>(() => {
    try { const v = Number(localStorage.getItem('etude.split')); return v >= 25 && v <= 70 ? v : SPLIT_DEFAULT } catch { return SPLIT_DEFAULT }
  })
  const [maximized, setMaximized] = useState<null | 'task' | 'terminal'>(null)
  const panesRef = useRef<HTMLElement>(null)
  useEffect(() => { try { localStorage.setItem('etude.split', String(Math.round(splitPct))) } catch { /* 기억하지 못해도 화면은 그대로다 */ } }, [splitPct])
  useEffect(() => {
    if (!maximized) return
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setMaximized(null) }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [maximized])
  // 세트 완료 기록 저장 상태 (모든 퀘스트를 통과하면 서버에 한 번 저장한다)
  const [saveState, setSaveState] = useState<'idle' | 'saving' | 'saved' | 'failed'>('idle')
  const [sessionId, setSessionId] = useState('')
  const [resetKey, setResetKey] = useState(0)
  const [preparing, setPreparing] = useState(false)
  const termFont = useTerminalFontSize()
  const [terminalStatus, setTerminalStatus] = useState<TerminalStatus>('connecting')
  const [changePasswordOpen, setChangePasswordOpen] = useState(false)
  const openChangePassword = () => setChangePasswordOpen(true)

  // 화면 이동을 브라우저 기록에 남긴다 (뒤로가기가 앱을 떠나지 않고 앱 안의 이전 화면으로 가게).
  // 이 앱은 URL 대신 상태로 화면을 바꾸므로, 이동할 때마다 pushState 하고 popstate 에서 상태를 맞춘다.
  const navigate = (nextPage: Page, setId: number | null = null) => {
    // 문제 화면에서 홈으로 나올 때는 새 기록을 쌓지 않고 문제 화면 기록을 되돌린다 (뒤로가기를 눌렀을 때와 같은 흐름).
    // 되돌린 뒤 popstate 에서 상태가 맞춰지고, 일부만 푼 세트라면 거기서 확인을 받는다.
    if (nextPage === 'home' && setId === null && selectedSetId !== null && history.state?.setId != null) {
      history.back()
      return
    }
    history.pushState({ page: nextPage, setId }, '')
    setPage(nextPage)
    setSelectedSetId(setId)
  }
  // 세트 화면에서 나갈 때 확인이 필요한지 (일부만 풀었고 아직 완료 기록이 없는 경우)와 안내 문구
  const leaveGuardRef = useRef<{ inSet: number | null; message: string | null }>({ inSet: null, message: null })
  useEffect(() => {
    const partial = selectedSetId !== null && quests.length > 0 && completedIndices.size > 0 && completedIndices.size < quests.length
    leaveGuardRef.current = {
      inSet: selectedSetId,
      message: partial ? `이 세트에서 나가면 지금까지 푼 ${completedIndices.size}/${quests.length}개가 기록되지 않아요. (세트를 한 번에 끝까지 풀어야 완료로 기록돼요) 나갈까요?` : null,
    }
  }, [selectedSetId, quests.length, completedIndices])
  const leaveBypassRef = useRef(false)
  const [leaveMessage, setLeaveMessage] = useState<string | null>(null)
  useEffect(() => {
    history.replaceState({ page: 'home', setId: null }, '')
    const onPop = (e: PopStateEvent) => {
      const guard = leaveGuardRef.current
      if (leaveBypassRef.current) {
        leaveBypassRef.current = false // 나가기로 확인한 뒤 다시 건 뒤로가기이므로 한 번만 통과시킨다
      } else if (guard.inSet !== null && guard.message) {
        history.pushState({ page: 'home', setId: guard.inSet }, '') // 일단 문제 화면에 머물고, 모달에서 나가기를 고르면 다시 뒤로 간다
        setLeaveMessage(guard.message)
        return
      }
      const st = e.state as { page?: Page; setId?: number | null } | null
      if (st?.setId != null) {
        // 앞으로가기로 문제 화면에 돌아오려는 경우: 터미널 환경은 복원할 수 없으므로 홈으로 보낸다
        history.replaceState({ page: 'home', setId: null }, '')
        setPage('home')
        setSelectedSetId(null)
        return
      }
      setPage(st?.page ?? 'home')
      setSelectedSetId(null)
    }
    window.addEventListener('popstate', onPop)
    return () => window.removeEventListener('popstate', onPop)
  }, [])
  // 새로고침·탭 닫기도 같은 경우에 한 번 물어본다
  useEffect(() => {
    const onBeforeUnload = (e: BeforeUnloadEvent) => {
      if (leaveGuardRef.current.message) { e.preventDefault(); e.returnValue = '' }
    }
    window.addEventListener('beforeunload', onBeforeUnload)
    return () => window.removeEventListener('beforeunload', onBeforeUnload)
  }, [])

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
        const sid = `${Date.now()}-${Math.random().toString(36).slice(2)}`
        setSessionId(sid)
        setMaximized(null)
        setRun(null)
        setExpired(false)
        startSet(selectedSetId, sid)
          .then((r) => { if (!cancelled && r.limitSec !== null && r.remainingSec !== null) setRun({ limitSec: r.limitSec, deadlineMs: Date.now() + r.remainingSec * 1000 }) })
          .catch(() => { /* 시작 기록에 실패하면 일반 세트처럼 둔다 (시험형이면 서버가 제출을 거부한다) */ })
      })
    return () => { cancelled = true }
  }, [selectedSetId])

  function handleExpire() { setExpired(true); setSummaryOpen(true) }

  function handleSetSelect(id: number, sandboxType: string) {
    setCombo(0)
    history.pushState({ page: 'home', setId: id }, '')
    setPage('home') // 복습 같은 다른 화면에서 세트를 고를 때도 문제 화면으로 넘어가도록 (page 가 남아 있으면 그 화면이 계속 그려진다)
    setSelectedSetId(id)
    // 이전 세트의 퀘스트로 터미널이 마운트되면 서버가 잘못된 세트로 세션을 만든다. 새 목록이 올 때까지 비운다.
    setQuests([])
    setQuestIndex(0)
    setSandboxType(sandboxType)
    setContainerId('')
    // 퀴즈 세트는 터미널과 컨테이너가 없어 환경 준비 단계가 없다
    setPreparing(sandboxType !== 'quiz')
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
    <Progress onBack={() => navigate('home')} onLeaderboard={() => navigate('leaderboard')} onHall={() => navigate('hall')} onReview={() => navigate('review')} onFeed={() => navigate('feed')} onAdmin={() => navigate('admin')} onLogout={handleLogout} onChangePassword={openChangePassword} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="progress" />
    <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
  </>
  if (page === 'leaderboard') return <>
    <Leaderboard onBack={() => navigate('home')} onProgress={() => navigate('progress')} onHall={() => navigate('hall')} onReview={() => navigate('review')} onFeed={() => navigate('feed')} onAdmin={() => navigate('admin')} onLogout={handleLogout} onChangePassword={openChangePassword} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="leaderboard" />
    <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
  </>
  if (page === 'review') return <>
    <Review onHome={() => navigate('home')} onSelect={handleSetSelect} onProgress={() => navigate('progress')} onLeaderboard={() => navigate('leaderboard')} onHall={() => navigate('hall')} onFeed={() => navigate('feed')} onAdmin={() => navigate('admin')} onLogout={handleLogout} onChangePassword={openChangePassword} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="review" />
    <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
  </>
  if (page === 'hall') return <>
    <Hall onHome={() => navigate('home')} onProgress={() => navigate('progress')} onLeaderboard={() => navigate('leaderboard')} onReview={() => navigate('review')} onFeed={() => navigate('feed')} onAdmin={() => navigate('admin')} onLogout={handleLogout} onChangePassword={openChangePassword} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="hall" />
    <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
  </>
  if (page === 'feed') return <>
    <Feed onHome={() => navigate('home')} onProgress={() => navigate('progress')} onLeaderboard={() => navigate('leaderboard')} onHall={() => navigate('hall')} onReview={() => navigate('review')} onAdmin={() => navigate('admin')} onLogout={handleLogout} onChangePassword={openChangePassword} userName={user.name} userEmail={user.email} userRole={user.role} />
    <FeedbackButton page="feed" />
    <ChangePasswordModal open={changePasswordOpen} onClose={() => setChangePasswordOpen(false)} />
  </>
  if (page === 'admin') {
    if (user.role !== 'admin') { setPage('home'); return null }
    return <>
      <Admin
        onHome={() => navigate('home')}
        onProgress={() => navigate('progress')}
        onLeaderboard={() => navigate('leaderboard')}
        onHall={() => navigate('hall')} onReview={() => navigate('review')} onFeed={() => navigate('feed')}
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
          onProgress={() => navigate('progress')}
          onLeaderboard={() => navigate('leaderboard')}
          onHall={() => navigate('hall')} onReview={() => navigate('review')} onFeed={() => navigate('feed')}
          onAdmin={() => navigate('admin')}
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
  const isQuiz = sandboxType === 'quiz'

  return (
    <div className="dark h-screen flex flex-col bg-surface overflow-hidden relative">
      {/* TopNav */}
      <header className="flex items-center w-full px-gutter h-14 bg-surface border-b border-outline-variant shrink-0">
        <button onClick={() => navigate('home')} className="flex items-center gap-2 font-sans text-body-lg font-bold tracking-tighter text-on-surface hover:text-primary transition-colors">
          <Logo size={26} />
          OKESTRO TRAINING | Etude
        </button>
        {isQuiz && (
          <span className="ml-4 font-sans text-label-caps text-on-surface-variant border border-outline-variant px-2 py-0.5">개념 퀴즈 · 터미널 없이 푸는 문제예요</span>
        )}
        <div className="ml-auto flex items-center gap-3">
          {combo >= 2 && (
            <span key={combo} className="fx-pop inline-flex items-center gap-1.5 rounded-full border border-gold/50 bg-gradient-to-r from-gold/20 to-warning/10 px-3 py-1 font-sans text-label-caps text-gold" title="문제를 연속으로 한 번에 맞혔어요">
              🔥 {combo}콤보
            </span>
          )}
          <FeedbackButton inline page="quest" questId={quest?.id} questSetId={selectedSetId} />
          <SoundToggle />
        </div>
      </header>
      <main ref={panesRef} className={isQuiz ? 'flex flex-1 overflow-hidden' : `flex flex-1 overflow-hidden bg-surface-container-lowest ${maximized ? 'p-0' : 'p-3'}`}>
        <section
          className={isQuiz
            ? 'w-full max-w-5xl mx-auto flex flex-col bg-gradient-to-b from-accent/10 via-transparent to-transparent'
            : `flex flex-col overflow-hidden border border-outline-variant bg-surface ${maximized ? 'rounded-none' : 'rounded-2xl'} ${maximized === 'terminal' ? 'hidden' : ''}`}
          style={isQuiz ? undefined : { width: maximized === 'task' ? '100%' : `calc(${splitPct}% - 6px)` }}
        >
          {!isQuiz && (
            <div className="h-9 border-b border-outline-variant flex items-center justify-between px-4 bg-surface shrink-0">
              <span className="font-sans text-label-caps text-on-surface flex items-center gap-2"><span className="material-symbols-outlined text-[16px]">assignment</span> 문제</span>
              <PaneToggle active={maximized === 'task'} onClick={() => setMaximized(maximized === 'task' ? null : 'task')} />
            </div>
          )}
          {summaryOpen && expired && (
            <div className="mx-6 mt-4 flex items-center gap-2 rounded-lg border border-warning/50 bg-warning/10 px-4 py-3 font-sans text-body-md text-warning" role="status">
              <span className="material-symbols-outlined text-[20px]">hourglass_bottom</span>시간이 끝났어요. 지금까지 푼 기록이에요.
            </div>
          )}
          {summaryOpen
            ? <SetComplete
                setId={selectedSetId}
                quests={quests}
                records={records}
                saveState={saveState}
                onRetrySave={() => setSaveState('idle')}
                onHome={() => navigate('home')}
                onReview={(i) => { setQuestIndex(i); setSummaryOpen(false) }}
              />
            : quest && (
            <QuestPanel
              key={quest.id}
              quest={quest}
              setId={selectedSetId}
              containerId={containerId}
              sessionId={sessionId}
              total={quests.length}
              index={questIndex}
              completedIndices={completedIndices}
              onPrev={() => setQuestIndex((i) => i - 1)}
              onNext={() => setQuestIndex((i) => i + 1)}
              onFinish={() => setSummaryOpen(true)}
              run={run}
              onExpire={handleExpire}
              onReset={() => {
                setPreparing(true)
                setContainerId('')
                setResetKey(k => k + 1)
              }}
              onComplete={(i, record) => {
                setCompletedIndices(prev => new Set(prev).add(i))
                setRecords(prev => ({ ...prev, [i]: record }))
                setCombo(c => (record.attempts === 1 ? c + 1 : 0))
              }}
            />
          )}
        </section>
        {!isQuiz && !maximized && <SplitHandle value={splitPct} onChange={setSplitPct} containerRef={panesRef} />}
        {!isQuiz && (
          <section className={`relative flex flex-1 min-w-0 flex-col overflow-hidden border border-outline-variant bg-surface-container-lowest ${maximized ? 'rounded-none' : 'rounded-2xl'} ${maximized === 'task' ? 'hidden' : ''}`}>
            <div className="h-9 border-b border-outline-variant flex items-center px-4 bg-surface justify-between shrink-0">
              <div className="flex items-center gap-4">
                <span className="font-sans text-label-caps text-on-surface flex items-center gap-2">
                  <span className="material-symbols-outlined text-[16px]">terminal</span> 터미널
                </span>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-1">
                  <button
                    onClick={termFont.smaller}
                    disabled={!termFont.canSmaller}
                    title="글꼴 작게"
                    className="border border-outline-variant bg-surface px-2 py-0.5 font-sans text-label-caps text-on-surface hover:bg-surface-container-high disabled:opacity-30"
                  >A−</button>
                  <button
                    onClick={termFont.larger}
                    disabled={!termFont.canLarger}
                    title="글꼴 크게"
                    className="border border-outline-variant bg-surface px-2 py-0.5 font-sans text-label-caps text-on-surface hover:bg-surface-container-high disabled:opacity-30"
                  >A+</button>
                </div>
                <span className={`w-2 h-2 rounded-full ${TERMINAL_STATUS_VIEW[terminalStatus].dot}`}></span>
                <span className="font-sans text-label-caps text-on-surface-variant">{TERMINAL_STATUS_VIEW[terminalStatus].label}</span>
                <PaneToggle active={maximized === 'terminal'} onClick={() => setMaximized(maximized === 'terminal' ? null : 'terminal')} />
              </div>
            </div>
            {quest
              ? <Terminal
                  key={`${sandboxType === 'docker-persistent' ? `set-${selectedSetId}` : questIndex}-${resetKey}`}
                  questId={quest.id}
                  fontSize={termFont.fontSize}
                  onConnected={(id) => { setContainerId(id); setPreparing(false) }}
                  onStatus={(status) => {
                    setTerminalStatus(status)
                    if (status === 'ended') setPreparing(false)
                  }}
                />
              : null
            }
            {preparing && (
              <div className="absolute inset-0 flex items-center justify-center bg-surface/90 z-50">
                <LoadingScreen message="실습 환경을 준비하고 있어요" />
              </div>
            )}
          </section>
        )}
      </main>
      <ConfirmModal
        open={leaveMessage !== null}
        title="세트에서 나갈까요?"
        message={leaveMessage ?? ''}
        confirmLabel="나가기"
        cancelLabel="계속 풀기"
        onConfirm={() => { leaveBypassRef.current = true; setLeaveMessage(null); history.back() }}
        onCancel={() => setLeaveMessage(null)}
      />
    </div>
  )
}

export default App
