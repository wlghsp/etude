package com.etude.infrastructure.persistence.auth

import com.etude.domain.auth.User
import org.springframework.data.jpa.repository.JpaRepository

interface UserJpaRepository : JpaRepository<User, Long> {
    fun findByEmail(email: String): User?
}