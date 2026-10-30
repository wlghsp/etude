import { useEffect, useState } from 'react'

// 환경이 준비되는 동안 보여 주는 학습 팁. 기다리는 시간도 배우는 시간이 되게 한다.
const TIPS = [
    '`Tab` 키를 누르면 명령어와 파일 이름이 자동으로 완성돼요.',
    '`↑` 방향키로 방금 친 명령을 다시 불러올 수 있어요.',
    '`Ctrl+C` 는 실행 중인 명령을 멈춰요. 화면이 멈춘 것 같을 때 눌러 보세요.',
    '`Ctrl+L` 로 화면을 깨끗하게 지울 수 있어요.',
    '명령 뒤에 `--help` 를 붙이면 사용법과 옵션이 나와요.',
    '`pwd` 로 지금 위치를 먼저 확인하는 습관이 실수를 줄여요.',
    '`>` 는 파일을 덮어쓰고 `>>` 는 이어서 써요. 로그를 남길 땐 `>>` 가 안전해요.',
    'k8s 에서 `k` 는 `kubectl` 의 줄임말이에요. 짧게 쳐도 같아요.',
    '`kubectl describe` 의 맨 아래 Events 에 문제의 이유가 적혀 있어요.',
    '막히면 힌트부터 보세요. 풀이는 마지막 수단이에요.',
    '틀려도 괜찮아요. 여러 번 시도하면서 배우는 거예요.',
    '푼 세트도 가끔 다시 풀어 보세요. 복습이 기억을 오래 남겨요.',
]

function Tip({ text }: { text: string }) {
    return (
        <>
            {text.split(/(`[^`]+`)/g).map((part, i) =>
                part.startsWith('`') && part.endsWith('`') && part.length > 2
                    ? <code key={i} className="font-mono text-[0.92em] bg-surface-container-highest text-gold px-1.5 py-0.5 rounded-sm">{part.slice(1, -1)}</code>
                    : <span key={i}>{part}</span>
            )}
        </>
    )
}

export function LoadingScreen({ message = '환경을 준비하고 있어요' }: { message?: string }) {
    const [tip, setTip] = useState(0)
    useEffect(() => {
        const t = setInterval(() => setTip((n) => (n + 1) % TIPS.length), 5000)
        return () => clearInterval(t)
    }, [])
    return (
        <div className="flex flex-col items-center justify-center gap-8 px-6 text-center">
            <div className="relative w-28 h-28">
                <div className="absolute inset-0 rounded-full border-4 border-surface-container-highest" />
                <div className="absolute inset-0 rounded-full border-4 border-transparent border-t-sky border-r-accent fx-spin" />
                <div className="absolute inset-0 flex items-center justify-center">
                    <span className="material-symbols-outlined text-[40px] text-sky">terminal</span>
                </div>
            </div>
            <p className="font-sans text-headline-md text-on-surface">{message}</p>
            <div className="min-h-[56px] max-w-[420px]">
                <p key={tip} className="fx-tip font-sans text-body-md text-on-surface-variant leading-7">
                    <span className="text-gold mr-1.5">💡 TIP</span><Tip text={TIPS[tip]!} />
                </p>
            </div>
        </div>
    )
}
