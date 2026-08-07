package com.etude.domain.auth

interface UserRepository {
    fun findByEmail(email: String): User?
    fun findById(id: Long): User?
    fun save(user: User): User
}