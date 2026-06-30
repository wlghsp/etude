import { useState } from 'react'
import { loginApi, token } from '../api'

interface Props {
  onLogin: (user: { id: number; name: string; email: string; role: string }) => void
}

export function Login({ onLogin }: Props) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.SyntheticEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const data = await loginApi(email, password)
      token.set(data.token)
      onLogin(data.user)
    } catch (e) {
      setError(e instanceof Error ? e.message : '로그인 실패')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="dark min-h-screen bg-surface flex items-center justify-center p-gutter">
      <main className="w-full max-w-[400px]">
        <header className="text-center mb-10 space-y-2">
          <h2 className="text-label-caps font-mono uppercase tracking-[0.3em] text-on-surface-variant opacity-60">
            okestro training
          </h2>
          <h1 className="font-mono text-[32px] font-bold text-on-surface tracking-tighter">
            Etude
          </h1>
        </header>

        <div className="bg-surface-container-low border border-outline-variant p-8">
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div className="space-y-2">
              <label className="text-label-caps font-mono text-on-surface-variant block uppercase tracking-widest">
                Email Address
              </label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="name@okestro.com"
                required
                className="w-full px-4 py-3 bg-surface border border-outline-variant text-on-surface font-mono text-body-md placeholder:text-on-surface-variant/30 focus:outline-none focus:border-info rounded-none"
              />
            </div>

            <div className="space-y-2">
              <label className="text-label-caps font-mono text-on-surface-variant block uppercase tracking-widest">
                Password
              </label>
              <input
                type="password"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
                className="w-full px-4 py-3 bg-surface border border-outline-variant text-on-surface font-mono text-body-md focus:outline-none focus:border-info rounded-none"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-info text-white font-mono text-body-md flex items-center justify-center gap-2 hover:brightness-110 active:scale-[0.98] transition-all disabled:opacity-50"
            >
              <span>{loading ? 'VALIDATING_CREDENTIALS...' : 'LOGIN_TO_WORKSPACE'}</span>
              {!loading && <span className="material-symbols-outlined text-[18px]">arrow_forward</span>}
            </button>
          </form>

          {error && (
            <div className="mt-6 pt-4 border-t border-outline-variant/30">
              <div className="flex gap-3 items-start text-error">
                <span className="material-symbols-outlined text-[18px] mt-0.5">error</span>
                <p className="font-mono text-code-sm">
                  AUTH_FAILURE: {error}
                </p>
              </div>
            </div>
          )}
        </div>

        <footer className="mt-8 flex justify-between items-center px-2">
          <div className="flex items-center gap-4">
            <span className="font-mono text-on-surface-variant/40 text-[10px]">v1.0.4-stable</span>
            <span className="w-[1px] h-3 bg-outline-variant/30"></span>
            <span className="font-mono text-on-surface-variant/40 text-[10px]">OKESTRO TRAINING</span>
          </div>
          <span className="material-symbols-outlined text-on-surface-variant/40 text-[16px]">terminal</span>
        </footer>
      </main>
    </div>
  )
}
