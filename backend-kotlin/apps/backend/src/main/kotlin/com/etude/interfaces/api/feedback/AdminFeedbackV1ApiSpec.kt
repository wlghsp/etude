package com.etude.interfaces.api.feedback

import com.etude.domain.feedback.FeedbackSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Admin Feedback V1 API", description = "관리자용 피드백 조회 API 입니다.")
interface AdminFeedbackV1ApiSpec {
    @Operation(summary = "피드백 목록 조회(관리자)", description = "전체 피드백을 최신순으로 조회합니다.")
    fun getFeedbackList(): ApiResponse<List<FeedbackSummary>>
}