package com.etude.domain.sandbox

interface SandboxConfigRepository {
    fun findByType(type: String): SandboxConfigEntity?
}