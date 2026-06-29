# Phase 7d 구현 가이드 — 실습 화면 UX 개선

명세: [specs/spec_phase7_auth.md](../specs/spec_phase7_auth.md)  
선행: [guide_phase7c_progress_tracking.md](guide_phase7c_progress_tracking.md) 완료 후 진행

Stitch 참고 화면:
- `docs/stitch_etude_auth_progress_ui/quest_workspace_etude/screen.png`

---

## 구현 순서

```
1. App.tsx — 환경 리셋 핸들러 추가
2. QuestPanel.tsx — 프로그레스 바, 성공 시 NEXT QUEST 버튼, 리셋 버튼
```

---

## Step 1. App.tsx — 환경 리셋 핸들러

환경 리셋 = 현재 `containerId`를 초기화해서 Terminal 컴포넌트가 새 컨테이너를 생성하도록 유도.

```typescript
function handleReset() {
  setContainerId('')
}
```

`QuestPanel`에 `onReset` prop으로 전달:

```typescript
<QuestPanel
  ...
  onReset={handleReset}   // 기존 onReset(홈으로)과 별개
  onHome={() => setSelectedSetId(null)}
/>
```

> 기존 `onReset`은 `onHome`으로 rename해서 역할을 명확히 구분한다.

---

## Step 2. QuestPanel.tsx 수정

### 2-1. Props 변경

```typescript
interface Props {
  quest: Quest
  containerId: string
  total: number
  index: number
  completedIndices: Set<number>   // 추가 — 완료된 퀘스트 인덱스 목록
  onPrev: () => void
  onNext: () => void
  onHome: () => void              // rename
  onReset: () => void             // 추가 — 환경 리셋
}
```

### 2-2. completedIndices는 App.tsx에서 관리

```typescript
// App.tsx에 추가
const [completedIndices, setCompletedIndices] = useState<Set<number>>(new Set())

// 채점 성공 시 (Terminal → QuestPanel 채점 흐름에서)
// QuestPanel의 grade() 성공 콜백에서 호출
function handleQuestComplete(index: number) {
  setCompletedIndices(prev => new Set(prev).add(index))
}
```

### 2-3. 퀘스트 진행 프로그레스 바

`QuestPanel` 상단에 추가:

```typescript
// "Quest 3 / 12" 텍스트 위에
<div style={{ height: '4px', background: '#333', marginBottom: '12px' }}>
  <div style={{
    width: `${((index + 1) / total) * 100}%`,
    height: '100%',
    background: '#22c55e',
    transition: 'width 0.3s'
  }} />
</div>
```

### 2-4. 채점 성공 시 NEXT QUEST 버튼

기존 채점 결과 표시 블록에서, `result === true`일 때:

```typescript
{result === true && (
  <div>
    <div>✓ QUEST COMPLETE</div>
    {index < total - 1
      ? <button onClick={() => { onNext(); setResult(null) }}>NEXT QUEST →</button>
      : <button onClick={onHome}>세트 완료! 홈으로 →</button>
    }
  </div>
)}
```

> `onNext()` 호출 시 `setResult(null)`도 같이 해서 다음 퀘스트에서 채점 결과가 남지 않도록.

### 2-5. 하단 버튼 영역 — 리셋 버튼 추가

```typescript
<div style={{ display: 'flex', gap: '8px' }}>
  <button onClick={onHome}>🏠</button>
  <button onClick={onReset}>↺</button>   {/* 환경 리셋 */}
  <button onClick={onPrev} disabled={index === 0}>◀ PREV</button>
  <button onClick={onNext} disabled={index === total - 1}>NEXT ▶</button>
</div>
```

리셋 버튼은 실수 방지를 위해 클릭 시 확인:

```typescript
function handleReset() {
  if (window.confirm('환경을 초기화하면 터미널이 재시작됩니다. 계속할까요?')) {
    onReset()
  }
}
```

---

## 검증

1. 퀘스트 채점 성공 → "NEXT QUEST →" 버튼 표시, 클릭 시 다음 퀘스트로 이동
2. 마지막 퀘스트 채점 성공 → "세트 완료! 홈으로 →" 버튼 표시
3. 리셋 버튼 클릭 → 확인 다이얼로그 → 확인 시 터미널 재연결 (새 컨테이너)
4. 프로그레스 바가 퀘스트 이동에 따라 업데이트됨
