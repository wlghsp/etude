package com.etude.interfaces.api.admin

import com.etude.domain.auth.UserSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Admin User V1 API", description = "관리자용 계정 관리 API 입니다.")
interface AdminUserV1ApiSpec {
    @Operation(summary = "계정 생성", description = "member 권한 계정을 생성합니다.")
    fun createUser(request: CreateUserRequest): ApiResponse<UserSummary>

    @Operation(summary = "계정 목록 조회", description = "member 권한 계정 목록을 이름순으로 조회합니다.")
    fun getUsers(): ApiResponse<List<UserSummary>>

    @Operation(summary = "비밀번호 초기화", description = "지정한 계정의 비밀번호를 초기화합니다.")
    fun resetPassword(id: Long, request: ResetPasswordRequest): ApiResponse<Unit>
}