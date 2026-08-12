package com.etude.domain.quest

import com.etude.domain.BaseEntity
import com.etude.domain.auth.UserSummary
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest_set")
class QuestSet(
    @Column(nullable = false, length = 100)
    val title: String,

    @Column(columnDefinition = "TEXT")
    val description: String?,

    @Column(name = "sandbox_type", nullable = false, length = 20)
    val sandboxType: String,

    @Column(nullable = false, length = 50)
    val category: String,

    isPublic: Boolean = true,
) : BaseEntity() {
    @Column(name = "is_public", nullable = false)
    var isPublic: Boolean = isPublic
        protected set

    fun changePublic(value: Boolean) {
        isPublic = value
    }

    fun toAdminSummary(accessUsers: List<UserSummary>): QuestSetAdminSummary {
        return QuestSetAdminSummary(
            id = id,
            title = title,
            description = description,
            sandboxType = sandboxType,
            category = category,
            isPublic = isPublic,
            accessUsers = accessUsers,
        )
    }
}