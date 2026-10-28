import { describe, it, expect } from 'vitest'
import { registerSession, getSession, removeSession } from './session-registry.js'

const session = { userId: 7, questSetId: 12, sandboxType: 'k8s' }

describe('session registry', () => {
    it('등록한 세션을 containerId로 조회한다', () => {
        registerSession('container-a', session)

        expect(getSession('container-a')).toEqual(session)
        removeSession('container-a')
    })

    it('등록되지 않은 containerId는 undefined', () => {
        expect(getSession('container-unknown')).toBeUndefined()
    })

    it('제거하면 조회되지 않고, 이미 없어도 에러 없이 끝난다 (멱등)', () => {
        registerSession('container-b', session)

        removeSession('container-b')
        expect(getSession('container-b')).toBeUndefined()
        expect(() => removeSession('container-b')).not.toThrow()
    })

    it('이미 등록된 containerId를 다른 값으로 덮어쓰지 않는다', () => {
        registerSession('container-c', session)

        expect(() => registerSession('container-c', { ...session, userId: 99 })).toThrow()
        expect(getSession('container-c')).toEqual(session)
        removeSession('container-c')
    })
})
