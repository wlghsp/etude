package com.etude.infrastructure.persistence.feedback

import com.etude.domain.feedback.Feedback
import org.springframework.data.jpa.repository.JpaRepository

interface FeedbackJpaRepository : JpaRepository<Feedback, Long> {
}