package com.etude.interfaces.api.feedback

import com.etude.domain.auth.JwtPayload
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Feedback V1 API", description = "피드백 등록 API 입니다.")
interface FeedbackV1ApiSpec {
    @Operation(summary = "피드백 등록", description = "로그인 여부와 무관하게 피드백을 등록합니다.")
    fun createFeedback(request: CreateFeedbackRequest, payload: JwtPayload?): ApiResponse<Unit>
}