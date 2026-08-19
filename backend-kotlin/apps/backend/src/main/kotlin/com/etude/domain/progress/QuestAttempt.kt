package com.etude.domain.progress

import com.etude.domain.BaseEntity
import jakarta.persistence.AttributeOverride
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest_attempt")
@AttributeOverride(name= "createdAt", column = Column(name = "attempted_at", nullable = false, updatable = false))
class QuestAttempt(
    @Column(name = "user_id", nullable = false)
    val userId: Long,

    @Column(name = "quest_id", nullable = false)
    val questId: Long,

    @Column(name = "quest_set_id", nullable = false)
    val questSetId: Long,

    @Column(name = "session_id", nullable = false, length = 36)
    val sessionId: String,

    @Column(name = "elapsed_sec")
    val elapsedSec: Int?,

    @Column(name = "hint_used", nullable = false)
    val hintUsed: Boolean = false,

    @Column(name = "solution_used", nullable = false)
    val solutionUsed: Boolean = false,

    @Column(nullable = false)
    val passed: Boolean = false,
) : BaseEntity()