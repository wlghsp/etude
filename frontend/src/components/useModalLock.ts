import { useEffect } from 'react'

/** 모달이 열려 있는 동안 <html data-modal> 을 켜서, 뒤 화면의 반복 애니메이션을 멈춘다 (index.css). 모달이 가볍게 뜨고 타이핑 중에 깜빡이지 않게 한다. */
export function useModalLock(open: boolean) {
    useEffect(() => {
        if (!open) return
        document.documentElement.setAttribute('data-modal', '')
        return () => document.documentElement.removeAttribute('data-modal')
    }, [open])
}
