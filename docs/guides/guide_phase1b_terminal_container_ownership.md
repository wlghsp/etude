# Phase 1b 구현 가이드 — containerId 관리 주체를 Terminal로 이전

명세: [specs/spec_phase1b_terminal_container_ownership.md](../specs/spec_phase1b_terminal_container_ownership.md)

전제: [Phase 1](guide_phase1.md)(터미널 샌드박스)이 구현되어 있는 상태. 임시방편 커밋(`f3d44e8`, `App.tsx`의 `onNext`/`onPrev`에 `containerId` 리셋)을 제거하고 이 가이드의 구조로 대체한다.

---

## 전체 흐름

```
Step 1. Terminal.tsx — sandboxType에 따라 containerId prop 무시 여부 판단
Step 2. App.tsx — onNext/onPrev의 임시 리셋 코드 제거
Step 3. 검증
```

---

## Step 1. `Terminal.tsx` — 재사용 판단을 컴포넌트 내부로 캡슐화

현재 [Terminal.tsx:26](../../frontend/src/components/Terminal.tsx#L26)은 `containerId` prop이 있으면 무조건 URL에 실어 재접속을 시도한다:

```typescript
if (containerId) params.set('containerId', containerId)  // 추가
```

이걸 `sandboxType`을 함께 확인하도록 바꾼다 — `docker-persistent`일 때만 재사용, 그 외에는 prop이 있어도 무시하고 항상 새 컨테이너를 요청한다.

```typescript
const params = new URLSearchParams({ sandboxType })
if (questId !== null) params.set('questId', String(questId))
if (sandboxType === 'docker-persistent' && containerId) {
    params.set('containerId', containerId)
}
```

이 판단이 `Terminal` 안으로 들어오면서, "부모가 언제 `containerId`를 리셋해야 하는가"라는 질문 자체가 사라진다 — 부모는 그냥 마지막으로 연결된 `containerId`를 아무 때나 넘겨줘도 되고, 그걸 실제로 쓸지 말지는 `Terminal`이 `sandboxType`을 보고 스스로 정한다.

---

## Step 2. `App.tsx` — 임시 리셋 코드 제거

[App.tsx](../../frontend/src/App.tsx)의 `onNext`/`onPrev`에 있는 아래 임시 코드를 제거하고 원래 형태로 되돌린다.

```typescript
// 제거 대상
onPrev={() => {
  if (sandboxType !== 'docker-persistent') setContainerId('')
  setQuestIndex((i) => i - 1)
}}
onNext={() => {
  if (sandboxType !== 'docker-persistent') setContainerId('')
  setQuestIndex((i) => i + 1)
}}
```

```typescript
// 원래 형태로 복원
onPrev={() => setQuestIndex((i) => i - 1)}
onNext={() => setQuestIndex((i) => i + 1)}
```

`containerId` state 자체(`useState`, `onConnected`에서의 `setContainerId(id)`, `handleSetSelect`에서의 `setContainerId('')`)는 그대로 둔다 — `QuestPanel`의 채점 호출에 여전히 필요하다.

---

## Step 3. 검증

- [ ] `docker`(비영속) 세트에서 1번 → 2번 → 3번 퀘스트로 넘길 때마다 매번 새 터미널이 "환경 준비 중" 없이(또는 정상적으로 준비 완료 후) 연결되는지 확인
- [ ] `docker-persistent` 세트(예: "Docker 이미지 오프라인 반입")에서 퀘스트를 넘겨도 같은 컨테이너가 유지되는지 — 이전에 만든 파일/이미지가 다음 퀘스트에서도 그대로 보이는지 확인
- [ ] `linux`, `k8s` 세트도 정상적으로 퀘스트 전환되는지 확인 (회귀 없음)
- [ ] "이전" 버튼으로 되돌아갈 때도 동일하게 정상 동작하는지 확인
