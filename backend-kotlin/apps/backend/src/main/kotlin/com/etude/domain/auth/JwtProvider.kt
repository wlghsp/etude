package com.etude.domain.auth

interface JwtProvider {
    fun generate(user: User): String
    fun verify(token: String): JwtPayload
}

data class JwtPayload(
    val userId: Long,
    val name: String,
    val email: String,
    val role: UserRole,
)