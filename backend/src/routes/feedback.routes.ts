import type { FastifyPluginAsync } from "fastify"
import { createFeedback, deleteFeedback } from "../services/feedback.js";
import { verifyToken } from "../services/auth.js";
import { AttachmentError, saveAttachments, validateAttachments, type UploadedFile } from "../services/feedback-attachments.js";

type FeedbackInput = { page?: string; questId?: number; questSetId?: number; body?: string }

const optionalNumber = (v: unknown) => (v === undefined || v === '' || v === null || Number.isNaN(Number(v)) ? null : Number(v))

export const feedbackRoutes: FastifyPluginAsync = async (app) => {
    app.post<{ Body: FeedbackInput }>(
        '/feedback',
        async (req, reply) => {
            let userId: number | null = null
            const authHeader = req.headers['authorization']
            if (authHeader?.startsWith('Bearer ')) {
                try {
                    userId = verifyToken(authHeader.slice(7)).userId
                } catch {}
            }

            let input: FeedbackInput = req.body ?? {}
            const files: UploadedFile[] = []
            if (req.isMultipart()) {
                input = {}
                try {
                    for await (const part of req.parts()) {
                        if (part.type === 'file') {
                            const data = await part.toBuffer()
                            if (data.length > 0) files.push({ data })
                        } else if (typeof part.value === 'string') {
                            ;(input as Record<string, unknown>)[part.fieldname] = part.value
                        }
                    }
                } catch (err: any) {
                    if (typeof err?.code === 'string' && err.code.startsWith('FST_')) {
                        return reply.code(400).send({ error: '이미지는 최대 3장, 한 장 5MB, 합계 10MB 까지 첨부할 수 있어요.' })
                    }
                    throw err
                }
            }

            const body = input.body?.trim()
            if (!body) return reply.code(400).send({ error: '내용을 입력해주세요.' })
            if (files.length > 0 && userId === null) return reply.code(401).send({ error: '이미지를 첨부하려면 로그인이 필요합니다.' })

            let images
            try {
                images = validateAttachments(files)
            } catch (err) {
                if (err instanceof AttachmentError) return reply.code(err.statusCode).send({ error: err.message })
                throw err
            }

            const id = await createFeedback(userId, input.page ?? null, optionalNumber(input.questId), optionalNumber(input.questSetId), body)
            if (images.length > 0) {
                try {
                    await saveAttachments(id, images)
                } catch (err) {
                    await deleteFeedback(id).catch(() => {})
                    throw err
                }
            }
            return { ok: true }
        }
    )
}
