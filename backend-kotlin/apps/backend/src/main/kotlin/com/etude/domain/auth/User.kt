package com.etude.domain.auth

import com.etude.domain.BaseEntity   // modules/jpa 모듈 — 패키지가 com.etude.domain 임에 유의 (backend 아님)
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Table

@Entity
@Table(name = "user")
class User(
    name: String,
    @Column(nullable = false, unique = true, length = 200)
    val email: String,

    password: String,

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    val role: UserRole = UserRole.member,
) : BaseEntity() {
    @Column(nullable = false, length = 100)
    var name: String = name
        protected set
    @Column(nullable = false, length = 200)
    var password: String = password
        protected set

    fun changeName(newName: String) {
        name = newName
    }

    fun changePassword(encodePassword: String) {
        password = encodePassword
    }

    fun matchesPassword(rawPassword: String, passwordEncoder: PasswordEncoder): Boolean = passwordEncoder.matches(rawPassword, password)
}
