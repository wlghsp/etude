import {authHeaders, apiFetch} from './base.js'


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
    sandboxType: string
    category: string
    isPublic: boolean
    accessUsers: { id: number; name: string; email: string}[]
}

export async function fetchAllUsers(): Promise<AdminUser[]> {
    return apiFetch<AdminUser[]>(`/admin/users`, { headers: authHeaders() })
}

export async function fetchAdminQuestSets(): Promise<AdminQuestSet[]> {
    return apiFetch<AdminQuestSet[]>(`/admin/quest-sets`, { headers: authHeaders() })
}

export async function setQuestSetPublic(id: number, isPublic: boolean) {
    await apiFetch<void>(`/admin/quest-sets/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type' : 'application/json', ...authHeaders() },
        body: JSON.stringify({ isPublic })
    })
}

export async function grantAccess(questSetId: number, userId: number) {
    await apiFetch<void>(`/admin/quest-sets/${questSetId}/access`, {
        method: 'POST',
        headers: { 'Content-Type' : 'application/json', ...authHeaders() },
        body: JSON.stringify({ userId })
    })
}

export async function revokeAccess(questSetId: number, userId: number) {
    await apiFetch<void>(`/admin/quest-sets/${questSetId}/access/${userId}`, {
        method: 'DELETE',
        headers: authHeaders(),
    })
}