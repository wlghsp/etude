// 피드백 스크린샷을 올리기 전에 줄인다. 실패하면 원본을 그대로 돌려주고 서버 제한(5MB)에 맡긴다.
const MAX_SIDE = 1600
const KEEP_AS_IS_BYTES = 500 * 1024

export async function shrinkImage(file: File): Promise<File> {
    try {
        const bitmap = await createImageBitmap(file)
        const scale = Math.min(1, MAX_SIDE / Math.max(bitmap.width, bitmap.height))
        if (scale === 1 && file.size <= KEEP_AS_IS_BYTES) { bitmap.close(); return file }
        const canvas = document.createElement('canvas')
        canvas.width = Math.round(bitmap.width * scale)
        canvas.height = Math.round(bitmap.height * scale)
        const ctx = canvas.getContext('2d')
        if (!ctx) { bitmap.close(); return file }
        ctx.fillStyle = '#fff' // JPEG 는 투명을 못 담으므로 흰 바탕
        ctx.fillRect(0, 0, canvas.width, canvas.height)
        ctx.drawImage(bitmap, 0, 0, canvas.width, canvas.height)
        bitmap.close()
        const blob = await new Promise<Blob | null>((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.85))
        if (!blob || blob.size >= file.size) return file
        return new File([blob], file.name.replace(/\.\w+$/, '') + '.jpg', { type: 'image/jpeg' })
    } catch {
        return file
    }
}
