package com.etude.infrastructure.persistence.sandbox

import com.etude.domain.sandbox.SandboxConfigEntity
import org.springframework.data.jpa.repository.JpaRepository

interface SandboxConfigJpaRepository : JpaRepository<SandboxConfigEntity, String> {
}