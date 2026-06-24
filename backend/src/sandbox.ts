import { db } from "./db.js"


export async function getSandboxConfig(sandboxType: string) {
    const [rows] = await db.query<any[]>(
        'SELECT image, binds FROM sandbox WHERE type = ?',
        [sandboxType]
    )
    const row = rows[0] ?? { image: 'ubuntu', binds: null }
    return {
        image: row.image,
        binds: typeof row.binds === 'string' ? JSON.parse(row.binds) : row.binds,
    }
}