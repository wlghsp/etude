package com.etude.domain.auth

import org.springframework.stereotype.Service

@Service
class AuthService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtProvider: JwtProvider,
) {
    fun login(email: String, password: String): LoginResult {
        val user = userRepository.findByEmail(email) ?: throw InvalidCredentialsException()
        if (!user.matchesPassword(password, passwordEncoder)) {
            throw InvalidCredentialsException()
        }

        val token = jwtProvider.generate(user)
        return LoginResult(token, UserSummary(user.id, user.name, user.email, user.role))
    }
}