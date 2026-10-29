import { useEffect, useState } from "react";

const FONT_SIZE_KEY = 'etude.terminalFontSize'
const FONT_SIZE_DEFAULT = 14
const FONT_SIZE_MIN = 10
const FONT_SIZE_MAX = 24

function loadFontSize(): number {
    try {
        const saved = Number(localStorage.getItem(FONT_SIZE_KEY))
        if (Number.isInteger(saved) && saved >= FONT_SIZE_MIN && saved <= FONT_SIZE_MAX) return saved
    } catch { /* 저장소를 못 읽어도 기본값으로 쓴다 */ }
    return FONT_SIZE_DEFAULT
}

// 글꼴 크기는 상단 바의 버튼(App)이 바꾸고 터미널이 반영한다
export function useTerminalFontSize() {
    const [fontSize, setFontSize] = useState(loadFontSize)
    useEffect(() => {
        try { localStorage.setItem(FONT_SIZE_KEY, String(fontSize)) } catch { /* 저장 실패는 무시 */ }
    }, [fontSize])
    return {
        fontSize,
        smaller: () => setFontSize((n) => Math.max(FONT_SIZE_MIN, n - 1)),
        larger: () => setFontSize((n) => Math.min(FONT_SIZE_MAX, n + 1)),
        canSmaller: fontSize > FONT_SIZE_MIN,
        canLarger: fontSize < FONT_SIZE_MAX,
    }
}
