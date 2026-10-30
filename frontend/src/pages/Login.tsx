import { useState } from 'react'
import { loginApi, token } from '../api/auth'
import { Logo } from '../components/Logo'

interface Props {
  onLogin: (user: { id: number; name: string; email: string; role: string }) => void
}

// 아이디(이메일) 저장은 이 브라우저에만 남기는 편의 기능이다. 비밀번호는 저장하지 않는다.
const readStorage = (key: string) => { try { return localStorage.getItem(key) } catch { return null } }
const writeStorage = (key: string, value: string | null) => {
  try { if (value === null) localStorage.removeItem(key); else localStorage.setItem(key, value) } catch { /* 저장 실패는 무시 */ }
}

export function Login({ onLogin }: Props) {
  // 예전에는 항상 저장했으므로, 끄겠다고 고른 적이 없으면 켜 둔다
  const [remember, setRemember] = useState(() => readStorage('rememberEmail') !== 'off')
  const [email, setEmail] = useState(() => (readStorage('rememberEmail') !== 'off' ? readStorage('lastEmail') ?? '' : ''))
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.SyntheticEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const data = await loginApi(email, password)
      writeStorage('rememberEmail', remember ? 'on' : 'off')
      writeStorage('lastEmail', remember ? email : null)
      token.set(data.token)
      onLogin(data.user)
    } catch (e) {
      setError(e instanceof Error ? e.message : '로그인 실패')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="dark relative overflow-hidden min-h-screen bg-surface flex items-center justify-center p-gutter">
      {/* 배경의 은은한 색 빛 */}
      <div className="pointer-events-none absolute -top-40 -left-32 w-[460px] h-[460px] rounded-full bg-accent/20 blur-[110px]" aria-hidden="true" />
      <div className="pointer-events-none absolute -bottom-44 -right-32 w-[480px] h-[480px] rounded-full bg-info/20 blur-[120px]" aria-hidden="true" />
      <div className="pointer-events-none absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[360px] h-[360px] rounded-full bg-rose/10 blur-[110px]" aria-hidden="true" />
      <main className="fx-page relative w-full max-w-[400px]">
        <header className="text-center mb-10 space-y-2">
          <div className="flex justify-center mb-3"><Logo size={56} className="drop-shadow-[0_0_18px_rgba(129,140,248,0.5)]" /></div>
          <h2 className="text-label-caps font-sans uppercase tracking-[0.3em] text-on-surface-variant opacity-60">
            okestro training
          </h2>
          <h1 className="font-sans text-[40px] font-extrabold tracking-tighter fx-shine-text">
            Etude
          </h1>
          <p className="font-mono text-code-sm text-success" aria-hidden="true">$ etude start<span className="fx-blink ml-0.5">▍</span></p>
        </header>

        <div className="rounded-2xl border border-outline-variant bg-surface-container-low/80 backdrop-blur p-8 shadow-[0_0_40px_rgba(129,140,248,0.12)]">
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div className="space-y-2">
              <label className="text-label-caps font-sans text-on-surface-variant block uppercase tracking-widest">
                이메일
              </label>
              <div className="relative">
              <span className="material-symbols-outlined pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-[20px] text-on-surface-variant" aria-hidden="true">mail</span>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="name@okestro.com"
                autoComplete="username"
                required
                className="w-full pl-11 pr-4 py-3 bg-surface border border-outline-variant text-on-surface font-sans text-body-md placeholder:text-on-surface-variant/30 focus:outline-none focus:border-info focus:ring-2 focus:ring-info/30 rounded-lg transition-shadow"
              />
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-label-caps font-sans text-on-surface-variant block uppercase tracking-widest">
                비밀번호
              </label>
              <div className="relative">
              <span className="material-symbols-outlined pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-[20px] text-on-surface-variant" aria-hidden="true">lock</span>
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  autoComplete="current-password"
                  autoFocus={email !== ''}
                  required
                  className="w-full pl-11 pr-12 py-3 bg-surface border border-outline-variant text-on-surface font-sans text-body-md focus:outline-none focus:border-info focus:ring-2 focus:ring-info/30 rounded-lg transition-shadow"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(v => !v)}
                  aria-label={showPassword ? '비밀번호 숨기기' : '비밀번호 보기'}
                  aria-pressed={showPassword}
                  className="absolute inset-y-0 right-0 px-3 rounded-r-lg flex items-center text-on-surface-variant hover:text-on-surface transition-colors"
                >
                  <span className="material-symbols-outlined text-[20px]">{showPassword ? 'visibility_off' : 'visibility'}</span>
                </button>
              </div>
            </div>

            <label className="flex items-center gap-2 cursor-pointer select-none font-sans text-body-md text-on-surface-variant hover:text-on-surface transition-colors">
              <input
                type="checkbox"
                checked={remember}
                onChange={e => setRemember(e.target.checked)}
                className="w-4 h-4 rounded accent-info"
              />
              아이디 저장
            </label>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-lg bg-gradient-to-r from-info to-accent text-white font-sans text-body-md font-semibold shadow-[0_6px_20px_rgba(96,165,250,0.25)] flex items-center justify-center gap-2 hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-50"
            >
              <span>{loading ? '로그인 중...' : '로그인'}</span>
              {!loading && <span className="material-symbols-outlined text-[18px]">arrow_forward</span>}
            </button>
          </form>

          {error && (
            <div className="mt-6 pt-4 border-t border-outline-variant/30">
              <div className="flex gap-3 items-start text-error">
                <span className="material-symbols-outlined text-[18px] mt-0.5">error</span>
                <p className="font-sans text-code-sm">
                  {error}
                </p>
              </div>
            </div>
          )}
        </div>

        <footer className="mt-8 flex justify-between items-center px-2">
          <div className="flex items-center gap-4">
            <span className="w-[1px] h-3 bg-outline-variant/30"></span>
            <span className="font-sans text-on-surface-variant/40 text-[10px]">OKESTRO TRAINING</span>
          </div>
          <span className="material-symbols-outlined text-on-surface-variant/40 text-[16px]">terminal</span>
        </footer>
      </main>
    </div>
  )
}
