package com.etude.application.feedback

import com.etude.domain.feedback.FeedbackService
import com.etude.domain.feedback.FeedbackSummary
import org.springframework.stereotype.Component

@Component
class FeedbackFacade(
    private val feedbackService: FeedbackService,
) {
    fun createFeedback(userId: Long?, page: String?, questId: Long?, questSetId: Long?, body: String) {
        feedbackService.createFeedback(
            userId = userId,
            page = page,
            questId = questId,
            questSetId = questSetId,
            body = body
        )
    }

    fun getFeedbackList(): List<FeedbackSummary> = feedbackService.getFeedbackList()
}