package com.etude.domain.progress

interface QuestAttemptRepository {
    fun findProgressByUserId(userId: Long) : List<QuestSetProgress>
    fun findLeaderboard(): List<MemberProgress>

}