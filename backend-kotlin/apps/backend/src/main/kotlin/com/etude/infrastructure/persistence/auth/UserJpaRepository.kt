package com.etude.infrastructure.persistence.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.domain.auth.UserSummary
import org.springframework.data.jpa.repository.JpaRepository

interface UserJpaRepository : JpaRepository<User, Long> {
    fun findByEmail(email: String): User?
    fun existsByEmail(email: String): Boolean
    fun findAllByRole(role: UserRole): List<User>
}