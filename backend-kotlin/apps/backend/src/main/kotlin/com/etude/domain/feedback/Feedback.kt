package com.etude.domain.feedback

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "feedback")
class Feedback(
    @Column(name = "user_id")
    val userId: Long?,

    @Column(length = 100)
    val page: String?,

    @Column(name = "quest_id")
    val questId: Long?,

    @Column(name = "quest_set_id")
    val questSetId: Long?,

    @Column(nullable = false, columnDefinition = "TEXT")
    val body: String,
) : BaseEntity()