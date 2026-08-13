package com.etude.domain.auth

interface UserRepository {
    fun findByEmail(email: String): User?
    fun findById(id: Long): User?
    fun existsByEmail(email: String): Boolean
    fun findAllByRole(role: UserRole): List<User>
    fun save(user: User): User
}

fun UserRepository.getById(id: Long): User = findById(id) ?: throw UserNotFoundException()