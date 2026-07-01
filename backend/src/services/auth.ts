import bcrypt from 'bcrypt'
import jwt, { type Jwt } from 'jsonwebtoken'
import { db } from '../db.js'


const JWT_SECRET = process.env.JWT_SECRET ?? 'dev-secret'
const JWT_EXPIRES = '24h'

export interface JwtPayload {
    userId: number
    name: string
    email: string
    role: string
}

export async function login(email: string, password: string) {
    const [rows] = await db.query(
        'SELECT id, name, email, password, role FROM user WHERE email = ?',
        [email]
    ) as any[]

    const user = rows[0]
    if (!user) throw new Error('이메일 또는 비밀번호가 올바르지 않습니다.')
    
    const match = await bcrypt.compare(password, user.password)
    if (!match) throw new Error('이메일 또는 비밀번호가 올바르지 않습니다.')

    const token = jwt.sign({ userId: user.id, name: user.name, email: user.email, role: user.role} satisfies JwtPayload, JWT_SECRET, { expiresIn: JWT_EXPIRES })

    return {
        token,
        user: { id: user.id, name: user.name, email: user.email, role: user.role }
    }
}

export function verifyToken(token: string): JwtPayload {
    return jwt.verify(token, JWT_SECRET) as JwtPayload
}
