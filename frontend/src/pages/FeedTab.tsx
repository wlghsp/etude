import { useEffect, useState } from 'react'
import { REACTIONS, fetchFeed, postComment, removeComment, toggleLike, type FeedEvent, type Reaction } from '../api/feed'
import { timeAgo } from '../activity'
import { fetchReport, type Report } from '../api/user'
import { ConfirmModal } from '../components/ConfirmModal'

const CATEGORY_TEXT: Record<string, string> = { '리눅스': 'text-warning', '도커': 'text-sky', 'k8s': 'text-accent' }
const COMMENT_MAX = 300

interface Props {
    userName: string
}

/** 활동 피드: 누가 어떤 세트를 끝냈는지 소식으로 보고, 좋아요와 댓글로 응원한다. */
export function FeedTab({ userName }: Props) {
    const [events, setEvents] = useState<FeedEvent[] | null>(null)
    const [now, setNow] = useState<Date>(() => new Date(0))
    const [error, setError] = useState('')
    const [mvp, setMvp] = useState<Report['mvp']>(null) // 이번 주 MVP (명예의 전당과 같은 계산)
    const [hasMore, setHasMore] = useState(false)
    const [moreLoading, setMoreLoading] = useState(false)
    const [openComments, setOpenComments] = useState<Set<number>>(new Set())
    const [drafts, setDrafts] = useState<Record<number, string>>({})
    const [notice, setNotice] = useState<Record<number, string>>({})
    const [deleteTarget, setDeleteTarget] = useState<{ eventId: number; commentId: number } | null>(null)

    useEffect(() => {
        fetchFeed().then((list) => { setEvents(list); setHasMore(list.length >= 20); setNow(new Date()) }).catch((e) => setError(e instanceof Error ? e.message : '소식을 불러오지 못했어요.'))
    }, [])

    useEffect(() => { fetchReport().then((r) => setMvp(r.mvp)).catch(() => { /* MVP 배너가 없어도 소식은 보인다 */ }) }, [])

    const patch = (id: number, fn: (e: FeedEvent) => FeedEvent) => setEvents((list) => list && list.map((e) => (e.id === id ? fn(e) : e)))
    const say = (id: number, text: string) => setNotice((n) => ({ ...n, [id]: text }))

    async function loadMore() {
        if (!events || events.length === 0) return
        setMoreLoading(true)
        try {
            const next = await fetchFeed(events[events.length - 1]!.id)
            setEvents([...events, ...next])
            setHasMore(next.length >= 20)
            setNow(new Date())
        } catch (e) { setError(e instanceof Error ? e.message : '소식을 불러오지 못했어요.') } finally { setMoreLoading(false) }
    }

    async function react(ev: FeedEvent, kind: Reaction) {
        // 먼저 화면을 바꾸고, 실패하면 되돌린다 (같은 반응이면 취소, 다른 반응이면 바꿈)
        patch(ev.id, (e) => {
            const counts = { ...e.reactions }
            if (e.myReaction) counts[e.myReaction] = Math.max(0, counts[e.myReaction] - 1)
            const next = e.myReaction === kind ? null : kind
            if (next) counts[next] += 1
            return { ...e, reactions: counts, myReaction: next }
        })
        try {
            const r = await toggleLike(ev.id, kind)
            patch(ev.id, (e) => ({ ...e, reactions: r.counts, myReaction: r.reaction }))
        } catch (e) {
            patch(ev.id, () => ev)
            say(ev.id, e instanceof Error ? e.message : '반응을 남기지 못했어요.')
        }
    }

    async function send(ev: FeedEvent) {
        const body = (drafts[ev.id] ?? '').trim()
        if (!body) return
        try {
            const c = await postComment(ev.id, body)
            patch(ev.id, (e) => ({ ...e, comments: [...e.comments, c] }))
            setDrafts((d) => ({ ...d, [ev.id]: '' }))
            say(ev.id, '')
        } catch (e) { say(ev.id, e instanceof Error ? e.message : '댓글을 쓰지 못했어요.') }
    }

    async function confirmDelete() {
        if (!deleteTarget) return
        const { eventId, commentId } = deleteTarget
        setDeleteTarget(null)
        try {
            await removeComment(commentId)
            patch(eventId, (e) => ({ ...e, comments: e.comments.filter((c) => c.id !== commentId) }))
        } catch (e) { say(eventId, e instanceof Error ? e.message : '댓글을 지우지 못했어요.') }
    }

    const toggleComments = (id: number) => setOpenComments((s) => { const n = new Set(s); if (n.has(id)) n.delete(id); else n.add(id); return n })

    if (error && !events) return <p className="font-sans text-body-md text-error">{error}</p>
    if (!events) return <div className="space-y-3 animate-pulse" aria-label="불러오는 중"><div className="h-28 rounded-xl bg-surface-container" /><div className="h-28 rounded-xl bg-surface-container" /></div>
    if (events.length === 0) {
        return (
            <div className="rounded-xl border border-dashed border-outline-variant px-6 py-10 text-center">
                <p className="text-[34px] mb-2">🌱</p>
                <p className="font-sans text-body-lg text-on-surface">아직 소식이 없어요. 세트를 끝내고 첫 소식의 주인공이 되어 보세요!</p>
            </div>
        )
    }

    return (
        <div className="space-y-4 max-w-[760px]">
            {error && <p className="font-sans text-body-md text-error">{error}</p>}
            {mvp && (
                <div className="flex items-center gap-3 rounded-xl border border-gold/50 bg-gradient-to-r from-gold/20 via-rose/10 to-transparent px-5 py-4">
                    <span className="text-[32px] leading-none">🏅</span>
                    <p className="font-sans text-body-md text-on-surface">
                        이번 주 MVP는 <strong className="text-gold">{mvp.userName}</strong> 님이에요{mvp.userName === userName && ' (나!)'} 🎉
                        <span className="block font-sans text-code-sm text-on-surface-variant">최근 7일 동안 세트 {mvp.weekCount}개를 끝냈어요{mvp.streak > 0 && ` · 🔥 ${mvp.streak}일 연속`}</span>
                    </p>
                </div>
            )}
            {events.map((ev, idx) => {
                const mine = ev.userName === userName
                const open = openComments.has(ev.id)
                return (
                    <article key={ev.id} className="fx-page rounded-xl border border-outline-variant bg-surface-container-low p-5" style={{ animationDelay: `${Math.min(idx, 6) * 40}ms` }}>
                        <div className="flex items-start gap-3">
                            <span className="w-10 h-10 shrink-0 rounded-full bg-gradient-to-br from-rose to-accent flex items-center justify-center font-sans text-body-md font-bold text-white">{ev.userName.slice(0, 1)}</span>
                            <div className="flex-1 min-w-0">
                                <p className="font-sans text-body-md text-on-surface leading-6">
                                    <strong>{ev.userName}</strong>{mine && <span className="ml-1 px-1.5 py-0.5 rounded-full bg-info/20 text-info font-sans text-[11px]">나</span>} 님이{' '}
                                    <span className={`font-semibold ${CATEGORY_TEXT[ev.category] ?? 'text-info'}`}>{ev.category}</span>{' '}
                                    <strong>#{ev.questSetId} {ev.setTitle}</strong> 을(를) 완료했어요 🎉
                                </p>
                                <p className="mt-1 font-sans text-code-sm text-on-surface-variant">{timeAgo(ev.completedAt, now)} · 문제 {ev.questCount}개</p>
                                {ev.cheers[0] && (
                                    <div className="fx-shine-border mt-3 flex items-center gap-3 rounded-lg border border-gold/50 bg-gradient-to-r from-gold/20 via-rose/10 to-transparent px-4 py-3">
                                        <span className="text-[28px] leading-none">{ev.cheers[0].icon}</span>
                                        <p className="font-sans text-body-md font-semibold text-on-surface">{mine ? '축하해요! ' : '축하해 주세요! '}{ev.cheers[0].text} 🎉</p>
                                    </div>
                                )}
                                <div className="mt-2 flex flex-wrap gap-1.5">
                                    {ev.cheers.slice(1).map((c) => <span key={c.text} className="rounded-full border border-gold/40 bg-gold/10 px-2.5 py-0.5 font-sans text-[12px] text-gold">{c.icon} {c.text}</span>)}
                                    {ev.perfect && <span className="rounded-full border border-gold/50 bg-gold/10 px-2.5 py-0.5 font-sans text-[12px] text-gold">💯 퍼펙트</span>}
                                    {ev.isFirst && <span className="rounded-full border border-success/40 bg-success/10 px-2.5 py-0.5 font-sans text-[12px] text-success">🌱 첫 완료</span>}
                                    {ev.isReview && <span className="rounded-full border border-sky/40 bg-sky/10 px-2.5 py-0.5 font-sans text-[12px] text-sky">🔁 복습</span>}
                                </div>
                            </div>
                        </div>

                        <div className="mt-4 flex items-center gap-2 border-t border-outline-variant/60 pt-3">
                            <div role="group" aria-label="반응" className="flex items-center gap-1.5">
                                {REACTIONS.map((r) => {
                                    const picked = ev.myReaction === r.kind
                                    const count = ev.reactions[r.kind]
                                    return (
                                        <button
                                            key={r.kind}
                                            onClick={() => react(ev, r.kind)}
                                            disabled={mine}
                                            aria-pressed={picked}
                                            title={mine ? '내 소식에는 반응을 남길 수 없어요' : picked ? `${r.label} 취소` : r.label}
                                            className={`inline-flex items-center gap-1 rounded-full border px-2.5 py-1.5 font-sans text-label-caps transition-all ${picked ? 'border-rose/60 bg-rose/15 text-rose' : 'border-outline-variant text-on-surface-variant hover:border-rose/50 hover:text-rose disabled:hover:border-outline-variant disabled:hover:text-on-surface-variant'} ${mine && count === 0 ? 'hidden' : ''} disabled:cursor-default`}
                                        >
                                            <span key={String(picked)} className={picked ? 'fx-pop' : ''}>{r.icon}</span>{count > 0 && <span className="tabular-nums">{count}</span>}
                                        </button>
                                    )
                                })}
                            </div>
                            <button
                                onClick={() => toggleComments(ev.id)}
                                aria-expanded={open}
                                className="inline-flex items-center gap-1.5 rounded-full border border-outline-variant px-3 py-1.5 font-sans text-label-caps text-on-surface-variant hover:border-sky/50 hover:text-sky transition-colors"
                            >
                                💬 {ev.comments.length > 0 ? `댓글 ${ev.comments.length}` : '댓글'}
                            </button>
                        </div>

                        {open && (
                            <div className="mt-3 space-y-2">
                                {ev.comments.map((c) => (
                                    <div key={c.id} className="flex items-start gap-2.5 rounded-lg bg-surface-container px-3 py-2">
                                        <span className="w-7 h-7 shrink-0 rounded-full bg-surface-container-highest flex items-center justify-center font-sans text-code-sm font-bold text-on-surface">{c.userName.slice(0, 1)}</span>
                                        <div className="flex-1 min-w-0">
                                            <p className="font-sans text-code-sm text-on-surface-variant"><strong className="text-on-surface">{c.userName}</strong> · {timeAgo(c.createdAt, now)}</p>
                                            <p className="font-sans text-body-md text-on-surface break-words whitespace-pre-wrap">{c.body}</p>
                                        </div>
                                        {c.canDelete && (
                                            <button onClick={() => setDeleteTarget({ eventId: ev.id, commentId: c.id })} title="댓글 지우기" aria-label="댓글 지우기" className="shrink-0 text-on-surface-variant hover:text-error transition-colors">
                                                <span className="material-symbols-outlined text-[18px]">delete</span>
                                            </button>
                                        )}
                                    </div>
                                ))}
                                <div className="flex items-center gap-2">
                                    <input
                                        value={drafts[ev.id] ?? ''}
                                        onChange={(e) => setDrafts((d) => ({ ...d, [ev.id]: e.target.value }))}
                                        onKeyDown={(e) => { if (e.key === 'Enter' && !e.nativeEvent.isComposing) { e.preventDefault(); void send(ev) } }}
                                        maxLength={COMMENT_MAX}
                                        placeholder="응원의 한마디를 남겨 보세요"
                                        className="flex-1 min-w-0 bg-surface border border-outline-variant px-3 py-2 font-sans text-body-md text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-info"
                                    />
                                    <button onClick={() => void send(ev)} disabled={!(drafts[ev.id] ?? '').trim()} className="shrink-0 bg-info px-4 py-2 font-sans text-label-caps text-white hover:brightness-110 disabled:opacity-40 transition-all">보내기</button>
                                </div>
                                {(drafts[ev.id]?.length ?? 0) > COMMENT_MAX - 40 && <p className="font-sans text-[12px] text-on-surface-variant text-right tabular-nums">{drafts[ev.id]!.length}/{COMMENT_MAX}</p>}
                            </div>
                        )}
                        {notice[ev.id] && <p className="mt-2 font-sans text-code-sm text-error" role="alert">{notice[ev.id]}</p>}
                    </article>
                )
            })}
            {hasMore && (
                <button onClick={() => void loadMore()} disabled={moreLoading} className="w-full rounded-xl border border-outline-variant py-3 font-sans text-label-caps text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high transition-colors disabled:opacity-50">
                    {moreLoading ? '불러오는 중...' : '더 보기'}
                </button>
            )}
            <ConfirmModal
                open={deleteTarget !== null}
                title="댓글을 지울까요?"
                message="지운 댓글은 되돌릴 수 없어요."
                confirmLabel="지우기"
                cancelLabel="취소"
                onConfirm={() => void confirmDelete()}
                onCancel={() => setDeleteTarget(null)}
            />
        </div>
    )
}
