package com.etude.domain.quest

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest_set_access")
class QuestSetAccess(
    @Column(name = "quest_set_id", nullable = false)
    val questSetId: Long,
    @Column(name = "user_id", nullable = false)
    val userId: Long,
) : BaseEntity()