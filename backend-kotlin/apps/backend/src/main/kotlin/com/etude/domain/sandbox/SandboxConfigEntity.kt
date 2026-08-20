package com.etude.domain.sandbox

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "sandbox")
class SandboxConfigEntity(
    @Id
    @Column(length = 20)
    val type: String,

    @Column(length = 100, nullable = false)
    val image: String,

    @Column(columnDefinition = "JSON")
    val binds: String?,

    @Column(nullable = false)
    val persistent: Boolean = false,
)