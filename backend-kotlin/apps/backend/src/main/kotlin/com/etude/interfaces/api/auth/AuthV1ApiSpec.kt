package com.etude.interfaces.api.auth

import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.LoginResult
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Auth V1 API", description = "인증 관련 API 입니다.")
interface AuthV1ApiSpec {
    @Operation(summary = "로그인", description = "이메일/비밀번호로 로그인하고 토큰을 발급받습니다.")
    fun login(request: LoginRequest): ApiResponse<LoginResult>

    @Operation(summary = "내 정보 조회", description = "토큰으로 현재 로그인한 사용자 정보를 조회합니다.")
    fun me(payload: JwtPayload): ApiResponse<JwtPayload>
}