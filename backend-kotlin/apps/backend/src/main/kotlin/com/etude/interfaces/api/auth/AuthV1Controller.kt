package com.etude.interfaces.api.auth

import com.etude.domain.auth.AuthService
import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.LoginResult
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import com.etude.interfaces.api.ApiResponse
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.Valid
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController


data class LoginRequest(
    @field:NotBlank @field:Email val email: String,
    @field:NotBlank val password: String
)
@RestController
class AuthV1Controller(
    private val authService: AuthService,
) : AuthV1ApiSpec {
    @PostMapping("/auth/login")
    override fun login(@Valid @RequestBody request: LoginRequest): ApiResponse<LoginResult> =
        ApiResponse.success(authService.login(request.email, request.password))

    @GetMapping("/me")
    override fun me(request: HttpServletRequest): ApiResponse<JwtPayload> =
        ApiResponse.success(request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload)

}