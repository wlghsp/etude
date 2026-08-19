package com.etude.domain.progress

data class QuestSetProgress(
    val questSetId: Long,
    val title: String,
    val category: String,
    val total: Long,
    val completed: Long,
)

data class QuestSetProgressDetail(
    val questSetId: Long,
    val questSetTitle: String,
    val category: String,
    val total: Long,
    val completed: Long,
)

data class MemberProgress(
    val userId: Long,
    val userName: String,
    val total: Long,
    val completed: Long,
    val sets: List<QuestSetProgressDetail>,
)
