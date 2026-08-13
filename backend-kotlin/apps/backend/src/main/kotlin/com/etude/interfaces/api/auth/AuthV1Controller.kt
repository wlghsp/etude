package com.etude.interfaces.api.auth

import com.etude.application.auth.AuthFacade
import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.LoginResult
import com.etude.infrastructure.security.LoginUser
import com.etude.interfaces.api.ApiResponse
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
    private val authFacade: AuthFacade,
) : AuthV1ApiSpec {
    @PostMapping("/auth/login")
    override fun login(@Valid @RequestBody request: LoginRequest): ApiResponse<LoginResult> =
        ApiResponse.success(authFacade.login(request.email, request.password))

    @GetMapping("/me")
    override fun me(@LoginUser payload: JwtPayload): ApiResponse<JwtPayload> = ApiResponse.success(payload)

}