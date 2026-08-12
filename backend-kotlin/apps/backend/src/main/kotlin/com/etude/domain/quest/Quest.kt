package com.etude.domain.quest

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest")
class Quest(
    @Column(name = "quest_set_id", nullable = false)
    val questSetId: Long,

    @Column(name = "order_index", nullable = false)
    val orderIndex: Int = 0,

    @Column(nullable = false, length = 200)
    val title: String,

    @Column(nullable = false, columnDefinition = "TEXT")
    val description: String,

    @Column(columnDefinition = "TEXT")
    val hint: String?,

    @Column(columnDefinition = "TEXT")
    val solution: String?,

    @Column(name = "setup_cmd", columnDefinition = "JSON")
    val setupCmd: String?,

    @Column(name = "grade_cmd", nullable = false, columnDefinition = "JSON")
    val gradeCmd: String,
) : BaseEntity()