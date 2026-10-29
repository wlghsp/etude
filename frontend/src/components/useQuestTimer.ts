import { useCallback, useEffect, useRef, useState } from 'react'

const PREFIX = 'etude.questTimer.'
// 세트에 들어올 때마다 새 sessionId 와 새 터미널 환경이 만들어지므로, 시간도 (세션, 문제) 기준으로 저장한다.
const storageKey = (sessionId: string, questId: number) => `${PREFIX}${sessionId}.${questId}`

function load(sessionId: string, questId: number): number {
    try { return Math.max(0, Math.floor(Number(localStorage.getItem(storageKey(sessionId, questId))) || 0)) } catch { return 0 }
}
function save(sessionId: string, questId: number, seconds: number) {
    try { localStorage.setItem(storageKey(sessionId, questId), String(seconds)) } catch { /* 저장 실패는 무시 */ }
}
function clear(sessionId: string, questId: number) {
    try { localStorage.removeItem(storageKey(sessionId, questId)) } catch { /* 저장 실패는 무시 */ }
}
/** 지금 세션이 아닌 저장값(이전 세션, 이전 형식)을 지운다. */
function purgeOtherSessions(sessionId: string) {
    try {
        const keep = `${PREFIX}${sessionId}.`
        Object.keys(localStorage)
            .filter((k) => k.startsWith(PREFIX) && !k.startsWith(keep))
            .forEach((k) => localStorage.removeItem(k))
    } catch { /* 저장 실패는 무시 */ }
}

/** 1:05 → "01:05", 3725 → "1:02:05" */
export function formatClock(totalSeconds: number): string {
    const h = Math.floor(totalSeconds / 3600)
    const m = Math.floor((totalSeconds % 3600) / 60)
    const s = totalSeconds % 60
    const mm = String(m).padStart(2, '0')
    const ss = String(s).padStart(2, '0')
    return h > 0 ? `${h}:${mm}:${ss}` : `${mm}:${ss}`
}

/** 83 → "1분 23초", 45 → "45초" */
export function formatDuration(totalSeconds: number): string {
    const h = Math.floor(totalSeconds / 3600)
    const m = Math.floor((totalSeconds % 3600) / 60)
    const s = totalSeconds % 60
    if (h > 0) return `${h}시간 ${m}분 ${s}초`
    if (m > 0) return `${m}분 ${s}초`
    return `${s}초`
}

/**
 * 문제를 푸는 데 쓴 시간을 센다.
 * - 탭이 보일 때만 센다 (딴 일을 하는 동안 시간이 부풀지 않게).
 * - (세션, 문제)별로 localStorage 에 저장해서, 같은 세트 안에서 다른 문제로 갔다 오거나 새로고침해도 이어서 센다.
 *   세트를 나갔다 다시 들어오면(새 환경) 0부터 센다.
 * - finish() 를 부르면 멈추고 저장값을 지운다.
 */
export function useQuestTimer(sessionId: string, questId: number) {
    const [seconds, setSeconds] = useState(() => { purgeOtherSessions(sessionId); return load(sessionId, questId) })
    const secondsRef = useRef(seconds)
    const finishedRef = useRef(false)

    useEffect(() => {
        const persist = () => { if (!finishedRef.current) save(sessionId, questId, secondsRef.current) }
        const tick = setInterval(() => {
            if (finishedRef.current || document.hidden) return
            secondsRef.current += 1
            setSeconds(secondsRef.current)
            if (secondsRef.current % 5 === 0) persist()
        }, 1000)
        document.addEventListener('visibilitychange', persist)
        window.addEventListener('pagehide', persist)
        return () => {
            clearInterval(tick)
            document.removeEventListener('visibilitychange', persist)
            window.removeEventListener('pagehide', persist)
            persist()
        }
    }, [sessionId, questId])

    const getSeconds = useCallback(() => secondsRef.current, [])

    const finish = useCallback((): number => {
        finishedRef.current = true
        clear(sessionId, questId)
        return secondsRef.current
    }, [sessionId, questId])

    return { seconds, getSeconds, finish }
}
