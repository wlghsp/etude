package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.Quest
import org.springframework.data.jpa.repository.JpaRepository

interface QuestJpaRepository : JpaRepository<Quest, Long> {
    fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest>
}