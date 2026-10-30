import { useEffect } from "react"
import { FeedTab } from "./FeedTab"
import { markFeedSeen } from "../api/feed"
import { TopNav } from "../components/TopNav"
import { SideNav } from "../components/SideNav"

interface Props {
    onHome: () => void
    onProgress: () => void
    onLeaderboard: () => void
    onHall: () => void
    onReview: () => void
    onAdmin?: () => void
    onLogout: () => void
    onChangePassword: () => void
    userName: string
    userEmail: string
    userRole?: string
}

export function Feed({ onHome, onProgress, onLeaderboard, onHall, onReview, onAdmin, onLogout, onChangePassword, userName, userEmail, userRole }: Props) {
    // 소식을 열면 내 소식에 달린 반응을 본 것으로 기록한다 (사이드바 배지가 사라진다)
    useEffect(() => { markFeedSeen().catch(() => { /* 실패해도 화면은 그대로다 */ }) }, [])

    return (
        <div className="dark min-h-screen bg-surface flex flex-col">
            <TopNav onHome={onHome} />
            <div className="flex flex-1 pt-14">
                <SideNav activePage="feed" userName={userName} userEmail={userEmail} userRole={userRole} onHome={onHome} onProgress={onProgress} onLeaderboard={onLeaderboard} onHall={onHall} onReview={onReview} onFeed={() => {}} onAdmin={onAdmin} onLogout={onLogout} onChangePassword={onChangePassword} />
                <main className="fx-page flex-1 md:ml-60 p-margin-page bg-surface overflow-y-auto">
                    <div className="mx-auto w-full max-w-[760px]">
                        <div className="flex flex-col gap-2 mb-8">
                            <div className="flex items-center gap-2 text-on-surface-variant font-sans text-label-caps">
                                <span className="text-primary">root</span>
                                <span>/</span>
                                <span>workspace</span>
                                <span>/</span>
                                <span className="text-on-surface">소식</span>
                            </div>
                            <h1 className="font-sans text-headline-lg text-on-surface">소식</h1>
                        </div>
                        <FeedTab userName={userName} />
                    </div>
                </main>
            </div>
        </div>
    )
}
