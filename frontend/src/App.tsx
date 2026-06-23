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
