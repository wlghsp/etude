package com.etude.domain.quest

interface QuestSetAccessRepository {
    fun existsByQuestSetIdAndUserId(questSetId: Long, userId: Long): Boolean
    fun findAllByQuestSetId(questSetId: Long): List<QuestSetAccess>
    fun save(access: QuestSetAccess) : QuestSetAccess
    fun deleteByQuestSetIdAndUserId(questSetId: Long, userId: Long)
}