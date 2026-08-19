package com.etude.support

import com.etude.domain.progress.QuestAttempt
import com.etude.infrastructure.persistence.progress.QuestAttemptJpaRepository

object TestQuestAttempts {
    fun createAndSave(
        questAttemptJpaRepository: QuestAttemptJpaRepository,
        userId: Long,
        questId: Long,
        questSetId: Long,
        sessionId: String = "session-1",
        passed: Boolean = true,
    ): QuestAttempt = questAttemptJpaRepository.save(
        QuestAttempt(
            userId = userId,
            questId = questId,
            questSetId = questSetId,
            sessionId = sessionId,
            elapsedSec = null,
            passed = passed
        )
    )
}