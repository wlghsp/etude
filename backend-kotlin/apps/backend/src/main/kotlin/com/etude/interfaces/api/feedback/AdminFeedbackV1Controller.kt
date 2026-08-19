package com.etude.interfaces.api.feedback

import com.etude.application.feedback.FeedbackFacade
import com.etude.domain.feedback.FeedbackSummary
import com.etude.interfaces.api.ApiResponse
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/admin/feedback")
class AdminFeedbackV1Controller(
    private val feedbackFacade: FeedbackFacade,
) : AdminFeedbackV1ApiSpec {
    @GetMapping
    override fun getFeedbackList(): ApiResponse<List<FeedbackSummary>> =
        ApiResponse.success(feedbackFacade.getFeedbackList())
}