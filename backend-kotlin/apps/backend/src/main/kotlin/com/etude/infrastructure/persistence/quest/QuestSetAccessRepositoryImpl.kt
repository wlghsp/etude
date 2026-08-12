package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSetAccess
import com.etude.domain.quest.QuestSetAccessRepository
import org.springframework.stereotype.Repository

@Repository
class QuestSetAccessRepositoryImpl(
    private val jpaRepository: QuestSetAccessJpaRepository,
) : QuestSetAccessRepository {

    override fun existsByQuestSetIdAndUserId(questSetId: Long, userId: Long): Boolean =
        jpaRepository.existsByQuestSetIdAndUserId(questSetId, userId)

    override fun findAllByQuestSetId(questSetId: Long): List<QuestSetAccess> =
        jpaRepository.findAllByQuestSetId(questSetId)

    override fun save(access: QuestSetAccess) =
        jpaRepository.save(access)

    override fun deleteByQuestSetIdAndUserId(questSetId: Long, userId: Long) =
        jpaRepository.deleteByQuestSetIdAndUserId(questSetId, userId)

}