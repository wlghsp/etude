package com.etude.interfaces.api.user

import com.etude.application.user.UserFacade
import com.etude.domain.auth.JwtPayload
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import com.etude.interfaces.api.ApiResponse
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController

data class ChangePasswordReqeust(
    @field:NotBlank val currentPassword: String,
    @field:NotBlank val newPassword: String,

    )

@RestController
class MeV1Controller(
    private val userFacade: UserFacade
) : MeV1ApiSpec {
    @PatchMapping("/me/password")
    override fun changePassword(
        @Valid @RequestBody request: ChangePasswordReqeust, httpRequest: HttpServletRequest): ApiResponse<Unit> {
        val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
        userFacade.changeOwnPassword(payload.userId, request.currentPassword, request.newPassword)
        return ApiResponse.success<Unit>()
    }
}