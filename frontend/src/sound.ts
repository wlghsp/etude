// 효과음. 기본은 꺼져 있고, 위 막대의 스피커 버튼으로 켠다 (선택은 이 브라우저에 저장).
const KEY = 'etude.sound'
const EVENT = 'etude-sound'

export function soundEnabled(): boolean {
    try { return localStorage.getItem(KEY) === 'on' } catch { return false }
}

export function setSoundEnabled(on: boolean) {
    try { localStorage.setItem(KEY, on ? 'on' : 'off') } catch { /* 저장 실패는 무시 */ }
    window.dispatchEvent(new Event(EVENT))
}

export function subscribeSound(cb: () => void): () => void {
    window.addEventListener(EVENT, cb)
    return () => window.removeEventListener(EVENT, cb)
}

let ctx: AudioContext | null = null
function tone(freq: number, start: number, dur: number, type: OscillatorType = 'triangle', gain = 0.07) {
    const AC = window.AudioContext ?? (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext
    if (!AC) return
    ctx ??= new AC()
    const t0 = ctx.currentTime + start
    const osc = ctx.createOscillator()
    const g = ctx.createGain()
    osc.type = type
    osc.frequency.value = freq
    g.gain.setValueAtTime(0.0001, t0)
    g.gain.exponentialRampToValueAtTime(gain, t0 + 0.02)
    g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur)
    osc.connect(g).connect(ctx.destination)
    osc.start(t0)
    osc.stop(t0 + dur + 0.05)
}

/** 정답: 올라가는 세 음 */
export function playSuccess() {
    if (!soundEnabled()) return
    ;[523.25, 659.25, 783.99].forEach((f, i) => tone(f, i * 0.09, 0.22))
}

/** 오답: 낮게 내려가는 두 음 */
export function playFail() {
    if (!soundEnabled()) return
    ;[220, 164.81].forEach((f, i) => tone(f, i * 0.12, 0.25, 'sawtooth', 0.04))
}

/** 세트·단원 완료: 팡파르 */
export function playFanfare() {
    if (!soundEnabled()) return
    ;[523.25, 659.25, 783.99, 1046.5].forEach((f, i) => tone(f, i * 0.12, 0.28))
    ;[783.99, 1046.5, 1318.5].forEach((f, i) => tone(f, 0.55 + i * 0.1, 0.5, 'triangle', 0.06))
}
