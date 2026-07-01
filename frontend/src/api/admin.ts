import { BASE, authHeaders } from './base.js'


export interface AdminUser {
    id: number
    name: string
    email: string
    role: string
}

export interface AdminQuestSet {
    id: number
    title: string
    description: string
    sandbox_type: string
    category: string
    is_public: boolean
    accessUsers: { id: number; name: string; email: string}[]
}

export async function fetchAllUsers(): Promise<AdminUser[]> {
    const res = await fetch(`${BASE}/admin/users`, { headers: authHeaders() })
    return res.json()
}

export async function fetchAdminQuestSets(): Promise<AdminQuestSet[]> {
    const res = await fetch(`${BASE}/admin/quest-sets`, { headers: authHeaders() })
    return res.json()
}

export async function setQuestSetPublic(id: number, isPublic: boolean) {
    await fetch(`${BASE}/admin/quest-sets/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type' : 'application/json', ...authHeaders() },
        body: JSON.stringify({ is_public: isPublic})
    })
}

export async function grantAccess(questSetId: number, userId: number) {
    await fetch(`${BASE}/admin/quest-sets/${questSetId}/access`, {
        method: 'POST',
        headers: { 'Content-Type' : 'application/json', ...authHeaders() },
        body: JSON.stringify({ userId })
    })
}

export async function revokeAccess(questSetId: number, userId: number) {
    await fetch(`${BASE}/admin/quest-sets/${questSetId}/access${userId}`, {
        method: 'DELETE',
        headers: authHeaders(),
    })
}