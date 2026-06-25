import { useState, useEffect } from 'react'
import { Terminal } from './components/Terminal'
import { QuestPanel } from './components/QuestPanel'
import { SetSelect } from './pages/SetSelect'
import type { Quest } from './types'
import { fetchQuests } from './api'


function App() {
  const [selectedSetId, setSelectedSetId] = useState<number | null>(null)
  const [quests, setQuests] = useState<Quest[]>([])
  const [questIndex, setQuestIndex] = useState(0)
  const [containerId, setContainerId] = useState('')
  const [sandboxType, setSandboxType] = useState<string>('linux')

  useEffect(() => {
    if (selectedSetId === null) return
    fetchQuests(selectedSetId)
      .then((data: Quest[]) => {
        setQuests(data)
        setQuestIndex(0)
      })
  }, [selectedSetId])

  if (selectedSetId === null) {
    function handleSetSelect(id: number, sandboxType: string) {
      setSelectedSetId(id)
      setSandboxType(sandboxType)
    }
    return <SetSelect onSelect={handleSetSelect} />
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
          quest && <Terminal key={sandboxType === 'k8s' ? 'k8s' : questIndex} sandboxType={sandboxType} questId={quest?.id ?? null}  onConnected={setContainerId} />
        }
      </div>
    </div>
  )
}

export default App
