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
            onReset={() => setSelectedSetId(null)}
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
