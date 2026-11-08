import crypto from 'node:crypto'
import fs from 'node:fs/promises'
import path from 'node:path'
import { db } from '../db.js'

export const MAX_FILES = 3
export const MAX_FILE_BYTES = 5 * 1024 * 1024
export const MAX_TOTAL_BYTES = 10 * 1024 * 1024
const DEFAULT_RETENTION_DAYS = 30
const PURGE_INTERVAL_MS = 24 * 60 * 60 * 1000

const EXT: Record<string, string> = { 'image/png': 'png', 'image/jpeg': 'jpg', 'image/webp': 'webp' }

export class AttachmentError extends Error {
    constructor(public statusCode: number, message: string) {
        super(message)
    }
}

export type UploadedFile = { data: Buffer }
export type AttachmentRow = { id: number; feedback_id: number; stored_name: string; mime: string; size_bytes: number }

// 업로드 폴더는 호출 때마다 읽는다 (테스트와 운영 설정이 환경 변수만 바꾸면 되도록).
const uploadDir = () => process.env.FEEDBACK_UPLOAD_DIR ?? '/app/data/feedback'
const filePath = (storedName: string) => path.join(uploadDir(), path.basename(storedName))

// 확장자·Content-Type 은 믿지 않고 파일 내용으로 판정한다. SVG·GIF 는 받지 않는다.
export function detectImageMime(buf: Buffer): string | null {
    if (buf.length >= 8 && buf.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))) return 'image/png'
    if (buf.length >= 3 && buf[0] === 0xff && buf[1] === 0xd8 && buf[2] === 0xff) return 'image/jpeg'
    if (buf.length >= 12 && buf.toString('latin1', 0, 4) === 'RIFF' && buf.toString('latin1', 8, 12) === 'WEBP') return 'image/webp'
    return null
}

// 하나라도 어기면 던진다. 호출한 쪽은 아무것도 저장하지 않는다.
export function validateAttachments(files: UploadedFile[]): { data: Buffer; mime: string }[] {
    if (files.length > MAX_FILES) throw new AttachmentError(400, `이미지는 최대 ${MAX_FILES}장까지 첨부할 수 있어요.`)
    let total = 0
    return files.map((f) => {
        if (f.data.length > MAX_FILE_BYTES) throw new AttachmentError(400, '이미지는 한 장에 5MB 까지 첨부할 수 있어요.')
        total += f.data.length
        if (total > MAX_TOTAL_BYTES) throw new AttachmentError(400, '이미지 합계는 10MB 까지 첨부할 수 있어요.')
        const mime = detectImageMime(f.data)
        if (!mime) throw new AttachmentError(400, 'PNG, JPEG, WebP 이미지만 첨부할 수 있어요.')
        return { data: f.data, mime }
    })
}

async function removeFile(storedName: string) {
    await fs.rm(filePath(storedName), { force: true })
}

// 검증을 마친 이미지를 디스크와 DB 에 쓴다. 중간에 실패하면 이미 쓴 파일을 지우고 다시 던진다.
export async function saveAttachments(feedbackId: number, files: { data: Buffer; mime: string }[]) {
    const written: string[] = []
    try {
        await fs.mkdir(uploadDir(), { recursive: true })
        for (const [i, f] of files.entries()) {
            const storedName = `${feedbackId}-${i + 1}-${crypto.randomBytes(8).toString('hex')}.${EXT[f.mime]}`
            await fs.writeFile(filePath(storedName), f.data, { flag: 'wx' })
            written.push(storedName)
            await db.query(
                'INSERT INTO feedback_attachment (feedback_id, stored_name, mime, size_bytes) VALUES (?, ?, ?, ?)',
                [feedbackId, storedName, f.mime, f.data.length],
            )
        }
    } catch (err) {
        await Promise.all(written.map(removeFile))
        await db.query('DELETE FROM feedback_attachment WHERE feedback_id = ?', [feedbackId]).catch(() => {})
        throw err
    }
}

export async function getAttachment(id: number): Promise<(AttachmentRow & { data: Buffer }) | null> {
    const [rows] = await db.query('SELECT id, feedback_id, stored_name, mime, size_bytes FROM feedback_attachment WHERE id = ?', [id])
    const row = (rows as AttachmentRow[])[0]
    if (!row) return null
    try {
        return { ...row, data: await fs.readFile(filePath(row.stored_name)) }
    } catch {
        return null
    }
}

export async function listAttachments() {
    const [rows] = await db.query('SELECT id, feedback_id, stored_name, mime, size_bytes FROM feedback_attachment ORDER BY id')
    return rows as AttachmentRow[]
}

// 파일이 이미 없어도 행은 지운다. 글(feedback)은 건드리지 않는다.
export async function deleteAttachment(id: number) {
    const [rows] = await db.query('SELECT id, feedback_id, stored_name, mime, size_bytes FROM feedback_attachment WHERE id = ?', [id])
    for (const row of rows as AttachmentRow[]) await removeFile(row.stored_name)
    await db.query('DELETE FROM feedback_attachment WHERE id = ?', [id])
}

export async function deleteFeedbackAttachments(feedbackId: number) {
    const [rows] = await db.query('SELECT id, feedback_id, stored_name, mime, size_bytes FROM feedback_attachment WHERE feedback_id = ?', [feedbackId])
    for (const row of rows as AttachmentRow[]) await removeFile(row.stored_name)
    await db.query('DELETE FROM feedback_attachment WHERE feedback_id = ?', [feedbackId])
}

// 보관 기간이 지난 첨부를 지운다. 지운 개수를 돌려준다.
export async function purgeExpiredAttachments(days: number): Promise<number> {
    const [rows] = await db.query('SELECT id, stored_name FROM feedback_attachment WHERE created_at < NOW() - INTERVAL ? DAY', [days])
    for (const row of rows as { id: number; stored_name: string }[]) {
        await removeFile(row.stored_name)
        await db.query('DELETE FROM feedback_attachment WHERE id = ?', [row.id])
    }
    return (rows as unknown[]).length
}

// 기동 시 한 번, 이후 24시간마다. 실패해도 서버는 계속 돈다.
export function startAttachmentPurge(log: { info: (m: string) => void; error: (m: string) => void } = console) {
    const parsed = Number(process.env.FEEDBACK_ATTACHMENT_RETENTION_DAYS)
    const days = Number.isInteger(parsed) && parsed > 0 ? parsed : DEFAULT_RETENTION_DAYS
    const run = async () => {
        try {
            const n = await purgeExpiredAttachments(days)
            if (n > 0) log.info(`피드백 첨부 ${n}건을 보관 기간(${days}일) 경과로 삭제했습니다.`)
        } catch (err) {
            log.error(`피드백 첨부 자동 삭제 실패: ${String(err)}`)
        }
    }
    void run()
    return setInterval(run, PURGE_INTERVAL_MS).unref()
}
