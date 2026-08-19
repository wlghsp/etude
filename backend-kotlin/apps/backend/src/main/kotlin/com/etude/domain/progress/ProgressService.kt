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

}