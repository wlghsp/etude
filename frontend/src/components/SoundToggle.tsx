import { useSyncExternalStore } from 'react'
import { setSoundEnabled, soundEnabled, subscribeSound, playSuccess } from '../sound'

export function SoundToggle() {
    const on = useSyncExternalStore(subscribeSound, soundEnabled)
    return (
        <button
            onClick={() => { const next = !on; setSoundEnabled(next); if (next) playSuccess() }}
            aria-pressed={on}
            title={on ? '효과음 끄기' : '효과음 켜기'}
            className="border border-outline-variant hover:bg-surface-container-high px-2.5 py-1.5 flex items-center transition-colors"
        >
            <span className={`material-symbols-outlined text-[20px] ${on ? 'text-gold' : 'text-on-surface-variant'}`}>{on ? 'volume_up' : 'volume_off'}</span>
        </button>
    )
}
