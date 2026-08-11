package com.etude.interfaces.api.user

import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.servlet.http.HttpServletRequest

@Tag(name = "Me V1 API", description = "내 계정 관리 API 입니다.")
interface MeV1ApiSpec {
    @Operation(summary = "비밀번호 변경", description = "현재 비밀번호를 확인한 뒤 새 비밀번호로 변경합니다.")
    fun changePassword(request: ChangePasswordReqeust, httpRequest: HttpServletRequest): ApiResponse<Unit>
}