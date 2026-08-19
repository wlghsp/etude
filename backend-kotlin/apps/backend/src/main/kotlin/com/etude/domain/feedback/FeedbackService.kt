package com.etude.domain.feedback

import com.etude.domain.progress.FeedbackRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class FeedbackService(
    private val feedbackRepository: FeedbackRepository,
) {
    fun createFeedback(userId: Long?, page: String?, questId: Long?, questSetId: Long?, body: String) {
        feedbackRepository.save(Feedback(
            userId = userId,
            page = page,
            questId = questId,
            questSetId = questSetId,
            body = body.trim()))
    }

    fun getFeedbackList(): List<FeedbackSummary> =
        feedbackRepository.findAllOrderByCreatedAtDesc()
}