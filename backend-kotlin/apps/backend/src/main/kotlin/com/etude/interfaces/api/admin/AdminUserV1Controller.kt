package com.etude.interfaces.api.admin

import com.etude.application.user.UserFacade
import com.etude.domain.auth.UserSummary
import com.etude.interfaces.api.ApiResponse
import jakarta.validation.Valid
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


data class CreateUserRequest(
    @field:NotBlank val name: String,
    @field:NotBlank @field:Email val email: String,
    @field:NotBlank val password: String,
)

data class ResetPasswordRequest(
    @field:NotBlank val password: String
)

@RestController
@RequestMapping("/admin/users")
class AdminUserV1Controller(
    private val userFacade: UserFacade,
) : AdminUserV1ApiSpec {
    @PostMapping
    override fun createUser(
        @Valid @RequestBody request: CreateUserRequest): ApiResponse<UserSummary> =
        ApiResponse.success(userFacade.createUser(request.name, request.email, request.password))


    @GetMapping
    override fun getUsers(): ApiResponse<List<UserSummary>> = ApiResponse.success(userFacade.getAllMembers())

    @PatchMapping("/{id}/password")
    override fun resetPassword(
        @PathVariable id: Long,
        @Valid @RequestBody request: ResetPasswordRequest
    ): ApiResponse<Unit> {
        userFacade.resetPassword(id, request.password)
        return ApiResponse.success<Unit>()
    }
}