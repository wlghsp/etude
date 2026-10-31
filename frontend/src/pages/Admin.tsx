import { Fragment, useEffect, useState } from "react"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"
import {
  fetchAllUsers, fetchAdminQuestSets, setQuestSetPublic, grantAccess, revokeAccess,
  type AdminUser, type AdminQuestSet,
} from "../api/admin"

const CATEGORY_ORDER = ['리눅스', '도커', 'k8s', 'Git', '미들웨어', '데이터베이스', '인프라']

interface Props {
    onHome: () => void
    onProgress: () => void
    onLeaderboard: () => void
    onHall: () => void
    onReview: () => void
    onFeed: () => void
    onLogout: () => void
    onChangePassword: () => void
    userName: string
    userEmail: string
    userRole?: string
}


export function Admin({ onHome, onProgress, onLeaderboard, onHall, onReview, onFeed, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [users, setUsers] = useState<AdminUser[]>([])
    const [sets, setSets] = useState<AdminQuestSet[]>([])
    const [selectedSetId, setSelectedSetId] = useState<number | null>(null)
    const [query, setQuery] = useState('')
    const [onlyPrivate, setOnlyPrivate] = useState(false)
    // 분야는 접어 두고 필요한 것만 펼친다 (세트가 수십 개라 한 줄 목록은 찾기 어렵다)
    const [open, setOpen] = useState<Record<string, boolean>>({})

    const reload = () => {
        fetchAllUsers().then(setUsers)
        fetchAdminQuestSets().then(setSets)
    }

    useEffect(() => { reload() }, [])

    const handleTogglePublic = async (set: AdminQuestSet) => {
        await setQuestSetPublic(set.id, !set.is_public)
        reload()
    }

    const handleToggleUser = async (setId: number, userId: number, granted: boolean) => {
        if (granted) await revokeAccess(setId, userId)
        else await grantAccess(setId, userId)
        reload()
    }

    const handleBulkPublic = async (category: string, group: AdminQuestSet[], isPublic: boolean) => {
        const targets = group.filter((s) => s.is_public !== isPublic)
        if (targets.length === 0) return
        if (!window.confirm(`'${category}' 분야의 세트 ${targets.length}개를 모두 ${isPublic ? '공개' : '비공개'}로 바꿀까요?`)) return
        for (const s of targets) await setQuestSetPublic(s.id, isPublic)
        reload()
    }

    // 검색어와 "비공개만" 필터를 적용한 뒤 분야별로 묶는다. 분야 순서는 화면 홈과 같게 고정하고, 모르는 분야는 뒤에 붙인다.
    const q = query.trim().toLowerCase()
    const filtered = sets.filter((s) => (!onlyPrivate || !s.is_public) && (!q || `#${s.id} ${s.title}`.toLowerCase().includes(q)))
    const byCategory = new Map<string, AdminQuestSet[]>()
    for (const s of sets) if (!byCategory.has(s.category)) byCategory.set(s.category, [])
    for (const s of filtered) byCategory.get(s.category)!.push(s)
    const categories = [...byCategory.keys()].sort((a, b) => {
        const ia = CATEGORY_ORDER.indexOf(a), ib = CATEGORY_ORDER.indexOf(b)
        return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib)
    })
    const searching = q !== '' || onlyPrivate

    return (
    <div className="dark min-h-screen bg-surface flex flex-col">
      <TopNav onHome={onHome} />
      <div className="flex flex-1 pt-14">
        <SideNav activePage="admin" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onHome} onProgress={onProgress} onLeaderboard={onLeaderboard} onHall={onHall} onReview={onReview} onFeed={onFeed} onAdmin={onHome} onLogout={onLogout} onChangePassword={onChangePassword} />

        <main className="flex-1 md:ml-60 flex flex-col items-center px-gutter py-8 bg-surface">
          <div className="w-full max-w-[900px] flex flex-col gap-8">
            <h1 className="font-sans text-headline-lg text-on-surface">퀘스트 세트 접근 관리</h1>

            <div className="flex flex-wrap items-center gap-3">
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="제목이나 번호로 찾기 (예: grep, #51)"
                className="flex-1 min-w-[220px] bg-surface-container border border-outline-variant px-3 py-2 font-sans text-body-md text-on-surface"
              />
              <label className="flex items-center gap-2 font-sans text-body-md text-on-surface-variant">
                <input type="checkbox" checked={onlyPrivate} onChange={(e) => setOnlyPrivate(e.target.checked)} />
                비공개만 보기
              </label>
            </div>

            {categories.map((category) => {
              const group = byCategory.get(category)!
              const all = sets.filter((s) => s.category === category)
              const publicCount = all.filter((s) => s.is_public).length
              const expanded = searching ? group.length > 0 : !!open[category]
              if (searching && group.length === 0) return null
              return (
                <section key={category} className="bg-surface-container border border-outline-variant overflow-hidden">
                  <div className="flex items-center gap-3 px-6 py-4 bg-surface">
                    <button
                      onClick={() => setOpen({ ...open, [category]: !open[category] })}
                      className="flex-1 flex items-center gap-3 text-left"
                    >
                      <span className="font-sans text-on-surface-variant">{expanded ? '▾' : '▸'}</span>
                      <span className="font-sans text-headline-sm text-on-surface">{category}</span>
                      <span className="font-sans text-code-sm text-on-surface-variant">
                        세트 {all.length}개 · 공개 {publicCount} · 비공개 {all.length - publicCount}
                        {searching ? ` · 검색 결과 ${group.length}` : ''}
                      </span>
                    </button>
                    <button onClick={() => handleBulkPublic(category, all, true)} className="font-sans text-code-sm px-2 py-1 border border-outline-variant text-on-surface-variant hover:text-success">전체 공개</button>
                    <button onClick={() => handleBulkPublic(category, all, false)} className="font-sans text-code-sm px-2 py-1 border border-outline-variant text-on-surface-variant hover:text-error">전체 비공개</button>
                  </div>
                  {expanded && (
                    <table className="w-full text-left border-collapse">
                      <thead className="bg-surface">
                        <tr>
                          <th className="px-6 py-3 font-sans text-label-caps text-on-surface-variant border-y border-outline-variant">제목</th>
                          <th className="px-6 py-3 font-sans text-label-caps text-on-surface-variant border-y border-outline-variant">공개 여부</th>
                          <th className="px-6 py-3 font-sans text-label-caps text-on-surface-variant border-y border-outline-variant">접근 유저 수</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-outline-variant">
                        {group.map((s) => (
                          <Fragment key={s.id}>
                      <tr
                        onClick={() => setSelectedSetId(selectedSetId === s.id ? null : s.id)}
                        className={`cursor-pointer hover:bg-surface-container-highest/50 ${selectedSetId === s.id ? 'bg-surface-container-highest' : ''}`}
                      >
                        <td className="px-6 py-4 font-sans text-body-md"><span className="text-on-surface-variant mr-2">#{s.id}</span>{s.title}</td>
                        <td className="px-6 py-4">
                          <button
                            onClick={(e) => { e.stopPropagation(); handleTogglePublic(s) }}
                            className={`font-sans text-code-sm px-2 py-1 border ${s.is_public ? 'text-success border-success/30 bg-success/5' : 'text-on-surface-variant border-outline-variant'}`}
                          >
                            {s.is_public ? '공개' : '비공개'}
                          </button>
                        </td>
                        <td className="px-6 py-4 font-sans text-code-sm text-on-surface-variant">
                          {s.is_public ? '-' : s.accessUsers.length}
                        </td>
                      </tr>
                      {selectedSetId === s.id && !s.is_public && (
                        <tr key={`${s.id}-access`} className="bg-surface-container-lowest">
                          <td colSpan={3} className="px-6 py-4">
                            <span className="font-sans text-label-caps text-on-surface-variant mb-2 block">접근 유저</span>
                            <div className="flex flex-col gap-1 max-h-64 overflow-y-auto">
                              {users.map((u) => {
                                const granted = s.accessUsers.some((a) => a.id === u.id)
                                return (
                                  <label key={u.id} className="flex items-center gap-2 font-sans text-body-md py-1">
                                    <input type="checkbox" checked={granted} onChange={() => handleToggleUser(s.id, u.id, granted)} />
                                    {u.name} ({u.email})
                                  </label>
                                )
                              })}
                            </div>
                          </td>
                        </tr>
                      )}
                    </Fragment>
                        ))}
                      </tbody>
                    </table>
                  )}
                </section>
              )
            })}
            {categories.every((c) => byCategory.get(c)!.length === 0) && (
              <p className="font-sans text-body-md text-on-surface-variant">조건에 맞는 세트가 없습니다.</p>
            )}
          </div>
        </main>
      </div>
    </div>
  )
}