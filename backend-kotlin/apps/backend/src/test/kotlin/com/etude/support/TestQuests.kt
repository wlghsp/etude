package com.etude.support

import com.etude.domain.quest.Quest
import com.etude.infrastructure.persistence.quest.QuestJpaRepository

object TestQuests {
    fun create(
        questSetId: Long,
        orderIndex: Int = 0,
        title: String = "1번 퀘스트",
        description: String = "설명",
        hint: String? = null,
        solution: String? = null,
        setupCmd: String? = null,
        gradeCmd: String = "[]",
    ): Quest = Quest(
        questSetId = questSetId,
        orderIndex = orderIndex,
        title = title,
        description =  description,
        hint =  hint,
        solution =  solution,
        setupCmd = setupCmd,
        gradeCmd =  gradeCmd
    )

    fun createAndSave(
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
            create(questSetId, orderIndex, title, description, hint, solution, setupCmd, gradeCmd)
        )
}