package com.etude.support

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository

object TestQuestSets {
    fun createPublic(
        questSetJpaRepository: QuestSetJpaRepository,
        title: String = "공개 세트",
        description: String? = null,
        sandboxType: String = "linux",
        category: String = "리눅스",
    ) : QuestSet =
        questSetJpaRepository.save(
            QuestSet(title = title, description = description, sandboxType = sandboxType, category = category, isPublic = true)
        )

    fun createPrivate(
        questSetJpaRepository: QuestSetJpaRepository,
        title: String = "비공개 세트",
        description: String? = null,
        sandboxType: String = "linux",
        category: String = "리눅스",
    ) : QuestSet =
        questSetJpaRepository.save(
            QuestSet(title = title, description = description, sandboxType = sandboxType, category = category, isPublic = false)
        )
}