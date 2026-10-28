import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs'
import { tmpdir } from 'node:os'
import path from 'node:path'
import { loadFixture } from './fixtures.js'

describe('loadFixture', () => {
    let dir: string
    beforeAll(() => { dir = mkdtempSync(path.join(tmpdir(), 'etude-fixtures-')) })
    afterAll(() => rmSync(dir, { recursive: true, force: true }))

    const write = (name: string, body: unknown) => writeFileSync(path.join(dir, name), typeof body === 'string' ? body : JSON.stringify(body))

    it('세트 번호를 두 자리로 맞춘 파일을 읽는다', () => {
        write('set01.json', { setId: 1, answers: { '1': 'pwd > /tmp/r' } })

        expect(loadFixture(1, dir)).toEqual({ setId: 1, answers: { '1': 'pwd > /tmp/r' } })
    })

    it('파일이 없으면 명확한 오류를 낸다', () => {
        expect(() => loadFixture(99, dir)).toThrow(/set99\.json/)
    })

    it('파일의 setId가 요청한 세트와 다르면 거부한다', () => {
        write('set02.json', { setId: 3, answers: { '1': 'x' } })

        expect(() => loadFixture(2, dir)).toThrow(/setId/)
    })

    it('정답이 빈 문자열이거나 문자열이 아니면 거부한다', () => {
        write('set04.json', { setId: 4, answers: { '1': '' } })
        write('set05.json', { setId: 5, answers: { '1': 7 } })

        expect(() => loadFixture(4, dir)).toThrow(/answers/)
        expect(() => loadFixture(5, dir)).toThrow(/answers/)
    })

    it('JSON이 아니면 파일 이름과 함께 거부한다', () => {
        write('set06.json', '{ not json')

        expect(() => loadFixture(6, dir)).toThrow(/set06\.json/)
    })
})
