package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSet
import com.etude.domain.quest.QuestSetRepository
import org.springframework.stereotype.Repository

@Repository
class QuestSetRepositoryImpl(
    private val jpaRepository: QuestSetJpaRepository,
    private val querydslRepository: QuestSetQuerydslRepository,
) : QuestSetRepository {

    override fun findById(id: Long): QuestSet? = jpaRepository.findById(id).orElse(null)

    override fun findAllPublicOrAccessibleBy(userId: Long): List<QuestSet> = querydslRepository.findAllPublicOrAccessibleBy(userId)

    override fun findAll(): List<QuestSet> = jpaRepository.findAll()

    override fun save(questSet: QuestSet): QuestSet = jpaRepository.save(questSet)

}