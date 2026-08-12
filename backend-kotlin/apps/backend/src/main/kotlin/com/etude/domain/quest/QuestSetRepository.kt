package com.etude.domain.quest

interface QuestSetRepository {
    fun findById(id: Long): QuestSet?
    fun findAllPublicOrAccessibleBy(userId: Long) : List<QuestSet>
    fun findAll(): List<QuestSet>
    fun save(questSet: QuestSet): QuestSet
}