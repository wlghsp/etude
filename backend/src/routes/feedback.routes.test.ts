import { describe, it, expect, beforeAll, afterAll, beforeEach, vi } from 'vitest'
import type { FastifyInstance } from 'fastify'
import jwt from 'jsonwebtoken'
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'

vi.hoisted(() => {
    process.env.JWT_SECRET = 'test-secret'
})

// 메모리 DB: 이 라우트가 쓰는 SQL 만 흉내 낸다. 파일은 실제 임시 폴더에 쓴다.
type FbRow = { id: number; user_id: number | null; page: string; body: string }
type AtRow = { id: number; feedback_id: number; stored_name: string; mime: string; size_bytes: number; created_at: Date }
const mem = vi.hoisted(() => ({
    feedback: [] as any[],
    attachments: [] as any[],
    failAttachmentInsert: false,
    nextId: 1,
}))

vi.mock('../db.js', () => ({
    db: {
        query: vi.fn(async (sql: string, params: any[] = []) => {
            const s = sql.replace(/\s+/g, ' ').trim()
            if (s.startsWith('INSERT INTO feedback_attachment')) {
                if (mem.failAttachmentInsert) throw new Error('db down')
                const [feedback_id, stored_name, mime, size_bytes] = params
                const row = { id: mem.nextId++, feedback_id, stored_name, mime, size_bytes, created_at: new Date() }
                mem.attachments.push(row)
                return [{ insertId: row.id }]
            }
            if (s.startsWith('INSERT INTO feedback')) {
                const [user_id, page, , , body] = params
                const row = { id: mem.nextId++, user_id, page, body }
                mem.feedback.push(row)
                return [{ insertId: row.id }]
            }
            if (s.startsWith('SELECT') && s.includes('FROM feedback_attachment') && s.includes('created_at <')) {
                const days = Number(params[0])
                const limit = Date.now() - days * 86400_000
                return [mem.attachments.filter((a) => a.created_at.getTime() < limit)]
            }
            if (s.startsWith('SELECT') && s.includes('FROM feedback_attachment') && s.includes('WHERE id = ?')) {
                return [mem.attachments.filter((a) => a.id === Number(params[0]))]
            }
            if (s.startsWith('SELECT') && s.includes('FROM feedback_attachment') && s.includes('WHERE feedback_id = ?')) {
                return [mem.attachments.filter((a) => a.feedback_id === Number(params[0]))]
            }
            if (s.startsWith('SELECT') && s.includes('FROM feedback_attachment')) {
                return [mem.attachments]
            }
            if (s.startsWith('DELETE FROM feedback_attachment WHERE id = ?')) {
                mem.attachments = mem.attachments.filter((a) => a.id !== Number(params[0]))
                return [{}]
            }
            if (s.startsWith('DELETE FROM feedback_attachment WHERE feedback_id = ?')) {
                mem.attachments = mem.attachments.filter((a) => a.feedback_id !== Number(params[0]))
                return [{}]
            }
            if (s.startsWith('DELETE FROM feedback WHERE id = ?')) {
                mem.feedback = mem.feedback.filter((f) => f.id !== Number(params[0]))
                return [{}]
            }
            if (s.startsWith('SELECT') && s.includes('FROM feedback f')) return [mem.feedback]
            throw new Error('예상 못한 SQL: ' + s)
        }),
    },
}))

import { buildApp } from '../app.js'
import { purgeExpiredAttachments } from '../services/feedback-attachments.js'

const tokenFor = (userId: number, role = 'member') =>
    jwt.sign({ userId, name: 't', email: 't@example.com', role }, 'test-secret')
const auth = (userId = 7, role = 'member') => ({ authorization: `Bearer ${tokenFor(userId, role)}` })

// 최소 PNG/JPEG/WebP/GIF/SVG 헤더 (매직 바이트만 맞으면 된다)
const png = (extra = 0) => Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]), Buffer.alloc(16 + extra)])
const jpeg = () => Buffer.concat([Buffer.from([0xff, 0xd8, 0xff, 0xe0]), Buffer.alloc(16)])
const webp = () => Buffer.concat([Buffer.from('RIFF'), Buffer.from([0, 0, 0, 0]), Buffer.from('WEBP'), Buffer.alloc(16)])
const gif = () => Buffer.concat([Buffer.from('GIF89a'), Buffer.alloc(16)])
const svg = () => Buffer.from('<svg xmlns="http://www.w3.org/2000/svg"><script>1</script></svg>')

type Part = { name: string; value?: string; filename?: string; type?: string; data?: Buffer }
function multipart(parts: Part[]) {
    const boundary = '----etudetest'
    const chunks: Buffer[] = []
    for (const p of parts) {
        let head = `--${boundary}\r\nContent-Disposition: form-data; name="${p.name}"`
        if (p.filename !== undefined) head += `; filename="${p.filename}"`
        head += '\r\n'
        if (p.filename !== undefined) head += `Content-Type: ${p.type ?? 'application/octet-stream'}\r\n`
        head += '\r\n'
        chunks.push(Buffer.from(head), p.data ?? Buffer.from(p.value ?? ''), Buffer.from('\r\n'))
    }
    chunks.push(Buffer.from(`--${boundary}--\r\n`))
    return { payload: Buffer.concat(chunks), contentType: `multipart/form-data; boundary=${boundary}` }
}
const fields = (body = '화면이 이상해요'): Part[] => [
    { name: 'page', value: '/sets/1' },
    { name: 'body', value: body },
]
const file = (data: Buffer, filename = 'a.png', type = 'image/png'): Part => ({ name: 'files', filename, type, data })

describe('피드백 이미지 첨부', () => {
    let app: FastifyInstance
    let dir: string
    const filesOnDisk = () => fs.readdirSync(dir)

    beforeAll(async () => {
        dir = fs.mkdtempSync(path.join(os.tmpdir(), 'etude-fb-'))
        process.env.FEEDBACK_UPLOAD_DIR = dir
        app = await buildApp()
    })
    afterAll(async () => {
        await app.close()
        fs.rmSync(dir, { recursive: true, force: true })
    })
    beforeEach(() => {
        mem.feedback = []
        mem.attachments = []
        mem.failAttachmentInsert = false
        mem.nextId = 1
        for (const f of fs.readdirSync(dir)) fs.rmSync(path.join(dir, f), { recursive: true, force: true })
    })

    const send = (parts: Part[], headers: Record<string, string> = auth()) => {
        const m = multipart(parts)
        return app.inject({ method: 'POST', url: '/feedback', headers: { ...headers, 'content-type': m.contentType }, payload: m.payload })
    }
    const nothingSaved = () => {
        expect(mem.feedback).toHaveLength(0)
        expect(mem.attachments).toHaveLength(0)
        expect(filesOnDisk()).toHaveLength(0)
    }

    it('1. 로그인한 사용자가 PNG 와 글을 보내면 글·첨부 1건씩 저장되고 파일이 생긴다', async () => {
        const res = await send([...fields(), file(png())])

        expect(res.statusCode).toBe(200)
        expect(mem.feedback).toHaveLength(1)
        expect(mem.attachments).toHaveLength(1)
        expect(mem.attachments[0]).toMatchObject({ feedback_id: mem.feedback[0].id, mime: 'image/png' })
        expect(filesOnDisk()).toEqual([mem.attachments[0].stored_name])
        expect(fs.readFileSync(path.join(dir, mem.attachments[0].stored_name)).equals(png())).toBe(true)
    })

    it('2. 내용이 이미지가 아니면(.png 이름이어도) 400, SVG·GIF 도 400, 아무것도 저장하지 않는다', async () => {
        for (const data of [Buffer.from('not an image at all'), svg(), gif()]) {
            const res = await send([...fields(), file(data, 'fake.png', 'image/png')])
            expect(res.statusCode).toBe(400)
            nothingSaved()
        }
    })

    it('3. 4장째, 장당 5MB 초과, 합계 10MB 초과는 각각 400 이고 아무것도 저장하지 않는다', async () => {
        const four = await send([...fields(), file(png()), file(jpeg(), 'b.jpg', 'image/jpeg'), file(webp(), 'c.webp', 'image/webp'), file(png())])
        expect(four.statusCode).toBe(400)
        nothingSaved()

        const big = await send([...fields(), file(png(5 * 1024 * 1024))])
        expect(big.statusCode).toBe(400)
        nothingSaved()

        const total = await send([...fields(), file(png(4.5 * 1024 * 1024)), file(png(4.5 * 1024 * 1024)), file(png(4.5 * 1024 * 1024))])
        expect(total.statusCode).toBe(400)
        nothingSaved()
    })

    it('3-1. PNG·JPEG·WebP 3장은 저장된다', async () => {
        const res = await send([...fields(), file(png()), file(jpeg(), 'b.jpg', 'image/jpeg'), file(webp(), 'c.webp', 'image/webp')])
        expect(res.statusCode).toBe(200)
        expect(mem.attachments.map((a) => a.mime).sort()).toEqual(['image/jpeg', 'image/png', 'image/webp'])
    })

    it('4. 토큰 없이 파일을 보내면 401, 토큰 없이 글만 보내는 기존 동작은 200', async () => {
        const withFile = await send([...fields(), file(png())], {})
        expect(withFile.statusCode).toBe(401)
        nothingSaved()

        const textOnly = await app.inject({ method: 'POST', url: '/feedback', payload: { page: '/x', body: '글만' } })
        expect(textOnly.statusCode).toBe(200)
        expect(mem.feedback).toHaveLength(1)
    })

    it('4-1. 잘못된 토큰으로 파일을 보내도 401', async () => {
        const res = await send([...fields(), file(png())], { authorization: 'Bearer nope' })
        expect(res.statusCode).toBe(401)
        nothingSaved()
    })

    it('5. JSON 로만 보내는 기존 요청(첨부 없음)이 그대로 동작한다', async () => {
        const res = await app.inject({ method: 'POST', url: '/feedback', headers: auth(), payload: { page: '/x', questId: 3, questSetId: 2, body: ' 안녕 ' } })

        expect(res.statusCode).toBe(200)
        expect(res.json()).toEqual({ ok: true })
        expect(mem.feedback[0]).toMatchObject({ user_id: 7, body: '안녕' })
    })

    it('5-1. multipart 에서도 글이 비어 있으면 400 이고 파일은 남지 않는다', async () => {
        const res = await send([...fields('   '), file(png())])
        expect(res.statusCode).toBe(400)
        nothingSaved()
    })

    it('6. 관리자가 아니면 조회·삭제 API 는 403, 토큰이 없으면 401', async () => {
        await send([...fields(), file(png())])
        const id = mem.attachments[0].id
        for (const [method, url] of [['GET', `/admin/feedback/attachments/${id}`], ['DELETE', `/admin/feedback/attachments/${id}`], ['DELETE', `/admin/feedback/${mem.feedback[0].id}/attachments`]] as const) {
            expect((await app.inject({ method, url, headers: auth(7, 'member') })).statusCode, `${method} ${url}`).toBe(403)
            expect((await app.inject({ method, url })).statusCode, `${method} ${url}`).toBe(401)
        }
        expect(mem.attachments).toHaveLength(1)
        expect(filesOnDisk()).toHaveLength(1)
    })

    it('7. 삭제 API 호출 뒤 파일과 행이 없고 피드백 글은 남는다 (개별·피드백 단위 모두)', async () => {
        await send([...fields(), file(png()), file(jpeg(), 'b.jpg', 'image/jpeg')])
        const [a1, a2] = mem.attachments

        const one = await app.inject({ method: 'DELETE', url: `/admin/feedback/attachments/${a1.id}`, headers: auth(1, 'admin') })
        expect(one.statusCode).toBe(200)
        expect(mem.attachments.map((a) => a.id)).toEqual([a2.id])
        expect(filesOnDisk()).toEqual([a2.stored_name])

        const all = await app.inject({ method: 'DELETE', url: `/admin/feedback/${mem.feedback[0].id}/attachments`, headers: auth(1, 'admin') })
        expect(all.statusCode).toBe(200)
        expect(mem.attachments).toHaveLength(0)
        expect(filesOnDisk()).toHaveLength(0)
        expect(mem.feedback).toHaveLength(1)
    })

    it('7-1. 파일이 이미 없어도 삭제하면 행은 지워진다', async () => {
        await send([...fields(), file(png())])
        fs.rmSync(path.join(dir, mem.attachments[0].stored_name))

        const res = await app.inject({ method: 'DELETE', url: `/admin/feedback/attachments/${mem.attachments[0].id}`, headers: auth(1, 'admin') })

        expect(res.statusCode).toBe(200)
        expect(mem.attachments).toHaveLength(0)
    })

    it('8. 저장 중 DB 오류가 나면 이미 쓴 파일이 남지 않는다', async () => {
        mem.failAttachmentInsert = true
        const res = await send([...fields(), file(png()), file(jpeg(), 'b.jpg', 'image/jpeg')])

        expect(res.statusCode).toBe(500)
        expect(filesOnDisk()).toHaveLength(0)
    })

    it('9. 저장 파일명에 원래 이름이 들어가지 않고, 경로 구분자가 있어도 폴더 밖에 쓰지 않는다', async () => {
        const res = await send([...fields(), file(png(), '../../evil/../secret.png')])

        expect(res.statusCode).toBe(200)
        const stored = mem.attachments[0].stored_name as string
        expect(stored).toMatch(/^\d+-\d+-[0-9a-f]{16}\.png$/)
        expect(stored).not.toContain('secret')
        expect(filesOnDisk()).toEqual([stored])
        expect(fs.existsSync(path.resolve(dir, '..', 'secret.png'))).toBe(false)
    })

    it('10. 이미지 조회 응답에 nosniff·DB 의 mime·attachment 헤더가 들어간다', async () => {
        await send([...fields(), file(jpeg(), 'x.png', 'image/png')]) // 이름·헤더는 png 여도 내용은 JPEG
        const res = await app.inject({ method: 'GET', url: `/admin/feedback/attachments/${mem.attachments[0].id}`, headers: auth(1, 'admin') })

        expect(res.statusCode).toBe(200)
        expect(res.headers['content-type']).toBe('image/jpeg')
        expect(res.headers['x-content-type-options']).toBe('nosniff')
        expect(res.headers['content-disposition']).toMatch(/^attachment/)
        expect(res.rawPayload.equals(jpeg())).toBe(true)
    })

    it('10-1. 없는 첨부는 404', async () => {
        const res = await app.inject({ method: 'GET', url: '/admin/feedback/attachments/999', headers: auth(1, 'admin') })
        expect(res.statusCode).toBe(404)
    })

    it('11. 보관 기간이 지난 첨부만 자동 삭제되고 글과 기간 안의 첨부는 남는다', async () => {
        await send([...fields(), file(png()), file(jpeg(), 'b.jpg', 'image/jpeg')])
        mem.attachments[0].created_at = new Date(Date.now() - 31 * 86400_000)
        const [old, fresh] = mem.attachments

        const removed = await purgeExpiredAttachments(30)

        expect(removed).toBe(1)
        expect(mem.attachments.map((a) => a.id)).toEqual([fresh.id])
        expect(filesOnDisk()).toEqual([fresh.stored_name])
        expect(fs.existsSync(path.join(dir, old.stored_name))).toBe(false)
        expect(mem.feedback).toHaveLength(1)
    })

    it('11-1. 자동 삭제는 파일이 이미 없어도 행을 지운다', async () => {
        await send([...fields(), file(png())])
        mem.attachments[0].created_at = new Date(Date.now() - 40 * 86400_000)
        fs.rmSync(path.join(dir, mem.attachments[0].stored_name))

        expect(await purgeExpiredAttachments(30)).toBe(1)
        expect(mem.attachments).toHaveLength(0)
    })

    it('관리자 목록에 첨부 id·mime·크기가 포함된다', async () => {
        await send([...fields(), file(png())])
        const res = await app.inject({ method: 'GET', url: '/admin/feedback', headers: auth(1, 'admin') })

        expect(res.statusCode).toBe(200)
        expect(res.json()[0].attachments).toEqual([{ id: mem.attachments[0].id, mime: 'image/png', sizeBytes: png().length }])
    })
})
