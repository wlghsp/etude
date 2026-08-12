package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSetAccess
import org.springframework.data.jpa.repository.JpaRepository

interface QuestSetAccessJpaRepository : JpaRepository<QuestSetAccess, Long> {
    fun existsByQuestSetIdAndUserId(questSetId: Long, userId: Long): Boolean
    fun findAllByQuestSetId(questSetId: Long): List<QuestSetAccess>
    fun deleteByQuestSetIdAndUserId(questSetId: Long, userId: Long)
}