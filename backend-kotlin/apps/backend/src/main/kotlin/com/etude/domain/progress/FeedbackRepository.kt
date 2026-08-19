package com.etude.domain.progress

import com.etude.domain.feedback.Feedback
import com.etude.domain.feedback.FeedbackSummary

interface FeedbackRepository {
    fun save(feedback: Feedback): Feedback
    fun findAllOrderByCreatedAtDesc(): List<FeedbackSummary>
}