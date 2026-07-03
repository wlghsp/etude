import bcrypt from 'bcrypt'
import { db } from '../db.js'

export async function getAllUsers() {
    const [rows] = await db.query("SELECT id, name, email, role FROM user WHERE role = 'member' ORDER BY name")
    return rows
}

export async function createUser(name: string, email: string, password: string) {
  const hashed = await bcrypt.hash(password, 10)
  const [result] = await db.query(
    'INSERT INTO user (name, email, password, role) VALUES (?, ?, ?, ?)',
    [name, email, hashed, 'member']
  ) as any[]
  return { id: result.insertId, name, email, role: 'member'}
}

export async function resetPassword(id: string, password: string) {
    const hashed = await bcrypt.hash(password, 10)
    await db.query('UPDATE user SET password = ? WHERE id = ?', [hashed, id])
}

export async function changeOwnPassword(userId: string, currentPassword: string, newPassword: string) {
  const [rows] = await db.query(
    'SELECT password FROM user WHERE id = ?',
    [userId]
  ) as any[]
  
  const user = rows[0]
  if (!user) throw new Error('사용자를 찾을 수 없습니다.')
  
  const match = await bcrypt.compare(currentPassword, user.password)
  if (!match) throw new Error('현재 비밀번호가 올바르지 않습니다.')

  const hashed = await bcrypt.hash(newPassword, 10)
    await db.query('UPDATE user SET password = ? WHERE id = ?', [hashed, userId])
}



