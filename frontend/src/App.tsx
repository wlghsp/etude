import { useState, useEffect, useRef } from 'react'
import { Terminal } from './components/Terminal'
import { QuestPanel } from './components/QuestPanel'
import { SetSelect } from './pages/SetSelect'
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

  if (selectedSetId === null) {
    function handleSetSelect(id: number, sandboxType: string) {
      setSelectedSetId(id)
      setSandboxType(sandboxType)
      setContainerId('')
    }
    return <SetSelect onSelect={handleSetSelect} 
        onLogout={() => { token.clear(); setUser(null) }}
    />
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
            onReset={() => setSelectedSetId(null)}
          />
        )}
      </div>
      <div style={{ flex: 1 }}>
        {
          quest && <Terminal
                key={sandboxType === 'docker-persistent' ? `set-${selectedSetId}` : sandboxType === 'k8s' ? 'k8s' : questIndex}
                sandboxType={sandboxType}
                questId={quest?.id ?? null}
                containerId={containerId || null}
                onConnected={setContainerId}
                />
        }
      </div>
    </div>
  )
}

export default App
