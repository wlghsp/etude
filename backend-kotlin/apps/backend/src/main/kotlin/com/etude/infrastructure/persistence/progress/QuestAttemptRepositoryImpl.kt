package com.etude.infrastructure.persistence.progress

import com.etude.domain.progress.MemberProgress
import com.etude.domain.progress.QuestAttemptRepository
import com.etude.domain.progress.QuestSetProgress
import org.springframework.stereotype.Repository

@Repository
class QuestAttemptRepositoryImpl(
    private val querydslRepository: QuestAttemptQuerydslRepository,
) : QuestAttemptRepository {
    override fun findProgressByUserId(userId: Long): List<QuestSetProgress> =
        querydslRepository.findProgressByUserId(userId)

    override fun findLeaderboard(): List<MemberProgress> {
        val summaries = querydslRepository.findLeaderboardSummary()
        val details = querydslRepository.findLeaderboardDetail()
        return summaries.map { summary ->
            MemberProgress(
                userId = summary.userId,
                userName = summary.userName,
                total = summary.total,
                completed = summary.completed,
                sets = details.filter { it.userId == summary.userId }.map { it.detail },
            )
        }
    }
}