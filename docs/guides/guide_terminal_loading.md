# 구현 가이드 — 터미널 로딩 오버레이

## 목표

터미널 WebSocket 연결 + `setup_cmd` 실행이 완료되기 전까지 로딩 오버레이를 표시한다.  
`connected` 메시지를 수신하면 오버레이가 사라지고 터미널이 활성화된다.

## 변경 파일

| 파일 | 변경 내용 |
|------|-----------|
| `frontend/src/components/Terminal.tsx` | 로딩 오버레이 UI 추가 |

---

## 현재 상태

`Terminal.tsx`에 이미 `loading` state와 기본 처리가 있다.

```tsx
const [loading, setLoading] = useState(true)
// ...
if (msg.type === 'connected') {
    onConnected(msg.containerId)
    setLoading(false)   // 이미 있음
}
```

return 부분만 교체하면 된다.

---

## Step 1. return 교체

기존:

```tsx
return (
    <div style={{ height: '100vh', background: '#000' }}>
        {loading && (
            <div style={{ color: '#666', padding: '1rem', fontSize: '13px' }}>
                환경 준비 중...
            </div>
        )}
        <div ref={containerRef} style={{ height: '100%', padding: '4px', display: loading ? 'none' : 'block' }} />
    </div>
)
```

교체:

```tsx
return (
    <div className="relative" style={{ height: '100vh', background: '#000' }}>
        <div ref={containerRef} style={{ height: '100%', padding: '4px' }} />
        {loading && (
            <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/80 gap-3">
                <div className="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin" />
                <span className="font-mono text-label-caps text-on-surface-variant">환경 준비 중...</span>
            </div>
        )}
    </div>
)
```

### 변경 포인트

- `containerRef` div에서 `display: loading ? 'none' : 'block'` 제거 — xterm이 숨겨진 상태에서 `fitAddon.fit()`을 호출하면 크기를 0으로 잡아 레이아웃이 깨짐. 항상 렌더링 유지.
- 오버레이를 `absolute inset-0`으로 터미널 전체를 덮도록 변경.
- `border-t-transparent`로 CSS 스피너 구현 — 별도 라이브러리 불필요.

---

## 검증

1. 퀘스트 세트 진입 → 로딩 오버레이(스피너 + "환경 준비 중...") 표시
2. `connected` 수신 → 오버레이 사라지고 터미널 활성화
3. 환경 초기화 버튼 → Terminal 재마운트 → 오버레이 다시 표시 → 완료 시 사라짐
4. 퀘스트 이동 (docker-persistent) → Terminal 재마운트 없음 → 오버레이 표시 없음
