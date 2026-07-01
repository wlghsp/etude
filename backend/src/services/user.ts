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
