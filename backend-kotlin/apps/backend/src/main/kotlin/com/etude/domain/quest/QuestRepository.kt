package com.etude.domain.quest

interface QuestRepository {
    fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest>
}