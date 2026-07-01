import { Fragment, useEffect, useState } from "react"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"
import {
  fetchAllUsers, fetchAdminQuestSets, setQuestSetPublic, grantAccess, revokeAccess,
  type AdminUser, type AdminQuestSet,
} from "../api/admin"

interface Props {
    onHome: () => void
    onProgress: () => void
    onLeaderboard: () => void
    onLogout: () => void
    userName: string
    userEmail: string
    userRole?: string
}


export function Admin({ onHome, onProgress, onLeaderboard, onLogout, userName, userEmail, userRole }: Props) {
    const [users, setUsers] = useState<AdminUser[]>([])
    const [sets, setSets] = useState<AdminQuestSet[]>([])
    const [selectedSetId, setSelectedSetId] = useState<number | null>(null)

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

    return (
    <div className="dark min-h-screen bg-surface flex flex-col">
      <TopNav onHome={onHome} />
      <div className="flex flex-1 pt-14">
        <SideNav activePage="admin" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onHome} onProgress={onProgress} onLeaderboard={onLeaderboard} onAdmin={onHome} onLogout={onLogout} />

        <main className="flex-1 md:ml-60 flex flex-col items-center px-gutter py-8 bg-surface">
          <div className="w-full max-w-[900px] flex flex-col gap-8">
            <h1 className="font-mono text-headline-lg text-on-surface">퀘스트 세트 접근 관리</h1>

            <section className="bg-surface-container border border-outline-variant overflow-hidden">
              <table className="w-full text-left border-collapse">
                <thead className="bg-surface">
                  <tr>
                    <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">제목</th>
                    <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">공개 여부</th>
                    <th className="px-6 py-3 font-mono text-label-caps text-on-surface-variant border-b border-outline-variant">접근 유저 수</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-outline-variant">
                  {sets.map((s) => (
                    <Fragment key={s.id}>
                      <tr
                        onClick={() => setSelectedSetId(selectedSetId === s.id ? null : s.id)}
                        className={`cursor-pointer hover:bg-surface-container-highest/50 ${selectedSetId === s.id ? 'bg-surface-container-highest' : ''}`}
                      >
                        <td className="px-6 py-4 font-mono text-body-md">{s.title}</td>
                        <td className="px-6 py-4">
                          <button
                            onClick={(e) => { e.stopPropagation(); handleTogglePublic(s) }}
                            className={`font-mono text-code-sm px-2 py-1 border ${s.is_public ? 'text-success border-success/30 bg-success/5' : 'text-on-surface-variant border-outline-variant'}`}
                          >
                            {s.is_public ? '공개' : '비공개'}
                          </button>
                        </td>
                        <td className="px-6 py-4 font-mono text-code-sm text-on-surface-variant">
                          {s.is_public ? '-' : s.accessUsers.length}
                        </td>
                      </tr>
                      {selectedSetId === s.id && !s.is_public && (
                        <tr key={`${s.id}-access`} className="bg-surface-container-lowest">
                          <td colSpan={3} className="px-6 py-4">
                            <span className="font-mono text-label-caps text-on-surface-variant mb-2 block">접근 유저</span>
                            <div className="flex flex-col gap-1 max-h-64 overflow-y-auto">
                              {users.map((u) => {
                                const granted = s.accessUsers.some((a) => a.id === u.id)
                                return (
                                  <label key={u.id} className="flex items-center gap-2 font-mono text-body-md py-1">
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
            </section>
          </div>
        </main>
      </div>
    </div>
  )
}