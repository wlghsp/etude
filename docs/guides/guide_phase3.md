# Phase 3 구현 가이드 — UX 개선

명세: `docs/specs/spec_phase3_ux.md`
상태: **완료**

---

## 목표

직접 써보면서 발견된 UX 문제 3가지 수정. 백엔드 변경 없음.

---

## 변경 파일

### `frontend/src/components/QuestPanel.tsx`

**3-1. 채점 중 로딩 표시**

`loading` 상태 추가 → 채점 요청 중 버튼을 "채점 중..."으로 변경하고 disabled 처리.

```typescript
const [loading, setLoading] = useState(false)

const grade = async () => {
  setLoading(true)
  try {
    // ... fetch
  } finally {
    setLoading(false)
  }
}
```

버튼에 `disabled={loading}` + 텍스트 조건부 렌더링.

**3-2. 퀘스트 완료 후 다음 단계 안내**

채점 성공 메시지를 마지막 퀘스트 여부에 따라 분기:

```typescript
result
  ? index === total - 1
    ? '🎉 모든 퀘스트를 완료했습니다!'
    : '✅ 성공!'
  : '❌ 아직이에요. 다시 시도해보세요.'
```

---

### `frontend/src/components/Terminal.tsx`

**3-3. 터미널 스타일 개선**

xterm 옵션 추가:
```typescript
new XTerm({ cursorBlink: true, fontSize: 14, fontFamily: 'monospace', lineHeight: 1.2 })
```

컨테이너 div에 `padding: '4px'` 추가.

---

## 검증

- 채점하기 클릭 → 버튼이 "채점 중..."으로 바뀌고 disabled
- Quest 1 성공 → "✅ 성공!" 표시
- Quest 2 (마지막) 성공 → "🎉 모든 퀘스트를 완료했습니다!" 표시
- 터미널 텍스트 가독성 향상 육안 확인
