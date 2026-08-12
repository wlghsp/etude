package com.etude.domain.quest

import com.etude.domain.auth.UserSummary

data class QuestSetSummary(
    val id: Long,
    val title: String,
    val description: String?,
    val sandboxType: String,
    val category: String,
)

data class QuestSummary(
    val id: Long,
    val title: String,
    val description: String,
    val hint: String?,
    val solution: String?,
    val setupCmd: String?,
)

data class QuestSetAdminSummary(
    val id: Long,
    val title: String,
    val description: String?,
    val sandboxType: String,
    val category: String,
    val isPublic: Boolean,
    val accessUsers: List<UserSummary>,
)

