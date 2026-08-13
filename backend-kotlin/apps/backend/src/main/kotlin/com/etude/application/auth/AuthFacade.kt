package com.etude.application.auth

import com.etude.domain.auth.AuthService
import com.etude.domain.auth.LoginResult
import org.springframework.stereotype.Component

@Component
class AuthFacade(
    private val authService: AuthService,
) {
    fun login(email: String, password: String): LoginResult = authService.login(email, password)
}
