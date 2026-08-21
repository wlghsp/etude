package com.etude.domain.quest

interface QuestRepository {
    fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest>
    fun findById(id: Long): Quest?
}