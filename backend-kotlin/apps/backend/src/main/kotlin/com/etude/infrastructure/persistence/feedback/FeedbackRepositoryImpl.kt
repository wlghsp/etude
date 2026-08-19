package com.etude.infrastructure.persistence.feedback

import com.etude.domain.feedback.Feedback
import com.etude.domain.feedback.FeedbackSummary
import com.etude.domain.progress.FeedbackRepository
import org.springframework.stereotype.Repository

@Repository
class FeedbackRepositoryImpl(
    private val feedbackJpaRepository: FeedbackJpaRepository,
    private val querydslRepository: FeedbackQuerydslRepository,
) : FeedbackRepository {
    override fun save(feedback: Feedback): Feedback = feedbackJpaRepository.save(feedback)

    override fun findAllOrderByCreatedAtDesc(): List<FeedbackSummary> = querydslRepository.findAllOrderByCreatedAtDesc()
}