package com.etude.infrastructure.persistence.sandbox

import com.etude.domain.sandbox.SandboxConfigEntity
import com.etude.domain.sandbox.SandboxConfigRepository
import org.springframework.stereotype.Repository

@Repository
class SandboxConfigRepositoryImpl(
    private val jpaRepository: SandboxConfigJpaRepository,
) : SandboxConfigRepository {
    override fun findByType(type: String): SandboxConfigEntity? =
        jpaRepository.findById(type).orElse(null)
}