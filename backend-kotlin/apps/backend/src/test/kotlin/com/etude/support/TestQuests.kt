package com.etude.support

import com.etude.domain.quest.Quest
import com.etude.infrastructure.persistence.quest.QuestJpaRepository

object TestQuests {
    fun create(
        questJpaRepository: QuestJpaRepository,
        questSetId: Long,
        orderIndex: Int = 0,
        title: String = "1번 퀘스트",
        description: String = "설명",
        hint: String? = null,
        solution: String? = null,
        setupCmd: String? = null,
        gradeCmd: String = "[]",
    ): Quest =
        questJpaRepository.save(
            Quest(questSetId, orderIndex, title, description, hint, solution, setupCmd, gradeCmd)
        )
}