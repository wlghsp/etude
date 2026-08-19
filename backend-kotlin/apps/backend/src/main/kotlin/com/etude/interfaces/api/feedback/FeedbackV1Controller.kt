package com.etude.interfaces.api.feedback

import com.etude.application.feedback.FeedbackFacade
import com.etude.domain.auth.JwtPayload
import com.etude.infrastructure.security.LoginUser
import com.etude.interfaces.api.ApiResponse
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController

data class CreateFeedbackRequest(
    val page: String?,
    val questId: Long?,
    val questSetId: Long?,
    @field:NotBlank val body: String,
)

@RestController
class FeedbackV1Controller(
    private val feedbackFacade: FeedbackFacade,
) : FeedbackV1ApiSpec {
    @PostMapping("/feedback")
    override fun createFeedback(
        @Valid @RequestBody request: CreateFeedbackRequest,
        @LoginUser payload: JwtPayload?,
    ): ApiResponse<Unit> {
        feedbackFacade.createFeedback(payload?.userId, request.page, request.questId, request.questSetId, request.body)
        return ApiResponse.success<Unit>()
    }
}