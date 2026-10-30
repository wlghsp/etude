import { useEffect, useState } from "react"
import { fetchReport, type Report } from "../api/user"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

interface Props {
    onHome: () => void
    onProgress: () => void
    onLeaderboard: () => void
    onFeed: () => void
    onReview: () => void
    onAdmin?: () => void
    onLogout: () => void
    onChangePassword: () => void
    userName: string
    userEmail: string
    userRole?: string
}

const MEDALS = ['🥇', '🥈', '🥉']

export function Hall({ onHome, onProgress, onLeaderboard, onReview, onFeed, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    const [report, setReport] = useState<Report | null>(null)
    const [reportError, setReportError] = useState(false)

    useEffect(() => { fetchReport().then(setReport).catch(() => setReportError(true)) }, [])

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={onHome} />
            <div className="flex flex-1 pt-14">
                <SideNav activePage="hall" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onHome} onProgress={onProgress} onLeaderboard={onLeaderboard} onHall={() => {}} onReview={onReview} onFeed={onFeed} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />
                <main className="fx-page flex-1 md:ml-60 p-margin-page bg-surface overflow-y-auto">
                    <div className="flex flex-col gap-2 mb-8">
                        <div className="flex items-center gap-2 text-on-surface-variant font-sans text-label-caps">
                            <span className="text-primary">root</span>
                            <span>/</span>
                            <span>workspace</span>
                            <span>/</span>
                            <span className="text-on-surface">명예의 전당</span>
                        </div>
                        <h1 className="font-sans text-headline-lg text-on-surface">명예의 전당</h1>
                    </div>
                        <div className="space-y-6">
                            {reportError && <p className="font-sans text-body-md text-error">명예의 전당을 불러오지 못했어요. 잠시 후 다시 열어 주세요.</p>}
                            {!report && !reportError && <div className="h-28 rounded-xl bg-surface-container animate-pulse" aria-label="불러오는 중" />}
                            {report && (
                                <>
                                    <div className="relative overflow-hidden rounded-xl border border-gold/40 bg-gradient-to-r from-gold/20 via-rose/10 to-accent/10 px-6 py-5">
                                        <span className="fx-sparkle pointer-events-none absolute top-3 right-5 material-symbols-outlined text-[26px] text-gold" style={{ fontVariationSettings: "'FILL' 1" }}>auto_awesome</span>
                                        {report.mvp ? (
                                            <div className="flex items-center gap-4">
                                                <span className="fx-bounce text-[44px] leading-none">🏅</span>
                                                <div className="min-w-0">
                                                    <p className="font-sans text-label-caps text-on-surface-variant">이번 주 MVP</p>
                                                    <p className="font-sans text-headline-lg"><span className="fx-shine-text font-extrabold">{report.mvp.userName}</span> 님{report.mvp.userName === userName && ' (나!)'}</p>
                                                    <p className="font-sans text-body-md text-on-surface-variant">최근 7일 동안 세트 {report.mvp.weekCount}개를 끝냈어요{report.mvp.streak > 0 && ` · 🔥 ${report.mvp.streak}일 연속`}</p>
                                                </div>
                                            </div>
                                        ) : (
                                            <p className="font-sans text-body-lg text-on-surface">🌟 이번 주 첫 MVP 의 주인공이 되어 보세요! 세트 하나를 끝내면 이름이 올라가요.</p>
                                        )}
                                    </div>

                                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                                        {report.awards.map((a) => (
                                            <section key={a.key} className="rounded-xl border border-outline-variant bg-surface-container-low p-5">
                                                <div className="flex items-center gap-3 mb-3">
                                                    <span className="text-[30px] leading-none">{a.icon}</span>
                                                    <div className="min-w-0">
                                                        <h2 className="font-sans text-headline-md text-on-surface">{a.title}</h2>
                                                        <p className="font-sans text-code-sm text-on-surface-variant">{a.desc}</p>
                                                    </div>
                                                </div>
                                                {a.entries.length === 0 ? (
                                                    <p className="rounded-lg border border-dashed border-outline-variant px-4 py-3 font-sans text-body-md text-on-surface-variant">아직 수상자가 없어요. 첫 번째 주인공이 되어 보세요!</p>
                                                ) : (
                                                    <ol className="space-y-2">
                                                        {a.entries.map((e, i) => (
                                                            <li key={e.userId} className={`flex items-center gap-3 rounded-lg px-3 py-2 ${e.userName === userName ? 'bg-info/15 ring-1 ring-info/40' : 'bg-surface-container'}`}>
                                                                <span className="text-[22px] leading-none w-7 text-center">{MEDALS[i]}</span>
                                                                <span className="flex-1 min-w-0 truncate font-sans text-body-md font-semibold text-on-surface">{e.userName}{e.userName === userName && <span className="ml-2 px-1.5 py-0.5 rounded-full bg-info/20 text-info font-sans text-[11px]">나</span>}</span>
                                                                <span className="font-sans text-body-md font-bold text-gold tabular-nums">{e.display}</span>
                                                            </li>
                                                        ))}
                                                    </ol>
                                                )}
                                            </section>
                                        ))}
                                    </div>
                                    {report.minorAwards.length > 0 && (
                                        <section>
                                            <h2 className="mb-3 font-sans text-headline-md text-on-surface">소박한 상 🎈</h2>
                                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                                                {report.minorAwards.map((a) => (
                                                    <div key={a.key} className="rounded-xl border border-outline-variant bg-surface-container-low p-4">
                                                        <div className="flex items-center gap-2 mb-2">
                                                            <span className="text-[24px] leading-none">{a.icon}</span>
                                                            <div className="min-w-0">
                                                                <h3 className="font-sans text-body-lg font-semibold text-on-surface">{a.title}</h3>
                                                                <p className="font-sans text-[12px] text-on-surface-variant">{a.desc}</p>
                                                            </div>
                                                        </div>
                                                        <ul className="space-y-1">
                                                            {a.entries.map((e) => (
                                                                <li key={e.userId} className={`flex items-center gap-2 rounded-md px-2 py-1 ${e.userName === userName ? 'bg-info/15 ring-1 ring-info/40' : 'bg-surface-container'}`}>
                                                                    <span className="flex-1 min-w-0 truncate font-sans text-body-md text-on-surface">{e.userName}{e.userName === userName && <span className="ml-2 px-1.5 py-0.5 rounded-full bg-info/20 text-info font-sans text-[11px]">나</span>}</span>
                                                                    <span className="font-sans text-body-md font-bold text-gold tabular-nums">{e.display}</span>
                                                                </li>
                                                            ))}
                                                        </ul>
                                                    </div>
                                                ))}
                                            </div>
                                        </section>
                                    )}
                                    <p className="font-sans text-code-sm text-on-surface-variant text-center">칭찬하는 화면이에요. 기록이 있는 분만 높은 순서로 보여 드려요. 오늘 한 세트가 내일의 이름이 될 수 있어요 ✨</p>
                                </>
                            )}
                        </div>
                </main>
            </div>
        </div>
    )
}
