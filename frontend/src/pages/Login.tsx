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
    <form onSubmit={handleSubmit}>
      {/* 디자인은 Stitch 적용 단계에서 완성 */}
      <input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="name@okestro.com" />
      <input type="password" value={password} onChange={e => setPassword(e.target.value)} />
      {error && <p>{error}</p>}
      <button type="submit" disabled={loading}>{loading ? '로그인 중...' : '로그인'}</button>
    </form>
  )
}