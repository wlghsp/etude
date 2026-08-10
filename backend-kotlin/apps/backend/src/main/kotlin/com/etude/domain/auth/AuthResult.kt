package com.etude.domain.auth

data class LoginResult(val token: String, val user: UserSummary)
data class UserSummary(val id: Long, val name: String, val email: String, val role: UserRole)