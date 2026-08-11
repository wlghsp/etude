package com.etude.infrastructure.persistence.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import org.springframework.stereotype.Repository

@Repository
class UserRepositoryImpl(
    private val jpaRepository: UserJpaRepository,
) : UserRepository {
    override fun findByEmail(email: String): User? = jpaRepository.findByEmail(email)
    override fun findById(id: Long): User? = jpaRepository.findById(id).orElse(null)
    override fun existsByEmail(email: String): Boolean = jpaRepository.existsByEmail(email)
    override fun findAllByRole(role: UserRole): List<User> = jpaRepository.findAllByRole(role)
    override fun save(user: User): User = jpaRepository.save(user)
}