package com.etude.domain.feedback

import java.time.LocalDateTime

data class FeedbackSummary(
    val id: Long,
    val userName: String?,
    val page: String?,
    val questSetTitle: String?,
    val questTitle: String?,
    val body: String,
    val createdAt: LocalDateTime,
)