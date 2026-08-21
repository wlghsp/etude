package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.Quest
import com.etude.domain.quest.QuestRepository
import org.springframework.stereotype.Repository

@Repository
class QuestRepositoryImpl(
    private val jpaRepository: QuestJpaRepository
) : QuestRepository {
    override fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest> =
        jpaRepository.findAllByQuestSetIdOrderByOrderIndex(questSetId)

    override fun findById(id: Long): Quest? = jpaRepository.findById(id).orElse(null)
}