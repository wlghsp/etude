package com.etude.infrastructure.persistence.progress

import com.etude.domain.progress.QuestAttempt
import org.springframework.data.jpa.repository.JpaRepository

interface QuestAttemptJpaRepository : JpaRepository<QuestAttempt, Long> {
}