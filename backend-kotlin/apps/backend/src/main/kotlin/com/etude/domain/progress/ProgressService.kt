package com.etude.domain.progress

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class ProgressService(
    private val questAttemptRepository: QuestAttemptRepository,
) {
    fun getProgress(userId: Long): List<QuestSetProgress> =
        questAttemptRepository.findProgressByUserId(userId)

    fun getLeaderboard(): List<MemberProgress> =
        questAttemptRepository.findLeaderboard()

    @Transactional
    fun recordAttempt(
        userId: Long,
        questId: Long,
        questSetId: Long,
        sessionId: String,
        passed: Boolean,
        elapsedSec: Int?,
        hintUsed: Boolean,
        solutionUsed: Boolean
    ) {
        questAttemptRepository.save(
            QuestAttempt(
                userId = userId,
                questId = questId,
                questSetId = questSetId,
                sessionId = sessionId,
                passed = passed,
                elapsedSec = elapsedSec,
                hintUsed = hintUsed,
                solutionUsed = solutionUsed,
            )
        )
    }

}