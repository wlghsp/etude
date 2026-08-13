package com.etude.support

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import kotlin.math.round

object TestUsers {
    const val ADMIN_EMAIL = "admin@okestro.com"
    const val ADMIN_PASSWORD = "admin123"
    const val MEMBER_EMAIL = "member@okestro.com"
    const val MEMBER_PASSWORD = "member123"

    fun admin(
        name: String = "관리자",
        email: String = ADMIN_EMAIL,
        password: String = ADMIN_PASSWORD,
    ): User = User(name = name, email = email, password = BCryptPasswordEncoder().encode(password), role = UserRole.admin)

    fun member(
        name: String = "멤버",
        email: String = MEMBER_EMAIL,
        password: String = MEMBER_PASSWORD,
    ): User = User(name = name, email = email, password = BCryptPasswordEncoder().encode(password), role = UserRole.member)

    fun createAdmin(
        userJpaRepository: UserJpaRepository,
        name: String = "관리자",
        email: String = ADMIN_EMAIL,
        password: String = ADMIN_PASSWORD,
    ): User =
        userJpaRepository.save(admin(name = name, email = email, password = password))

    fun createMember(
        userJpaRepository: UserJpaRepository,
        name: String = "멤버",
        email: String = MEMBER_EMAIL,
        password: String = MEMBER_PASSWORD,
    ): User =
        userJpaRepository.save(member(name = name, email = email, password = password))
}
