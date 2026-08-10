package com.etude.domain.auth

import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

class AuthServiceTest {

    private val userRepository = mockk<UserRepository>()
    private val passwordEncoder = mockk<PasswordEncoder>()
    private val jwtProvider = mockk<JwtProvider>()
    private val authService = AuthService(userRepository, passwordEncoder, jwtProvider)

    @DisplayName("이메일과 비밀번호가 맞으면 토큰과 사용 정보를 반환한다")
    @Test
    fun loginSucceeds() {
        val user = User(name = "테스트", email = "test@okestro.com", password = "hashed", role = UserRole.member)

        every { userRepository.findByEmail("test@okestro.com") } returns user
        every { passwordEncoder.matches("password123", "hashed") } returns true
        every { jwtProvider.generate(user) } returns "signed-jwt"

        val result = authService.login("test@okestro.com", "password123")

        assertThat(result.token).isEqualTo("signed-jwt")
        assertThat(result.user.email).isEqualTo("test@okestro.com")
    }

    @DisplayName("존재하지 않는 이메일이면 예외를 던진다")
    @Test
    fun loginFailsWhenUserNotFound() {
        every { userRepository.findByEmail("unknown@okestro.com") } returns null

        assertThatThrownBy {
            authService.login("unknown@okestro.com", "anything")
        }.isInstanceOf(InvalidCredentialsException::class.java)
    }

    @DisplayName("비밀번호가 틀리면 예외를 던진다")
    @Test
    fun loginFailsWhenPasswordMismatch() {
        val user = User(name = "테스트", email = "test@okestro.com", password = "hashed", role = UserRole.member)
        every { userRepository.findByEmail("test@okestro.com") } returns user
        every { passwordEncoder.matches("wrong", "hashed") } returns false

        assertThatThrownBy {
            authService.login("test@okestro.com", "wrong")
        }.isInstanceOf(InvalidCredentialsException::class.java)
    }

}