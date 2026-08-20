package com.etude.config

import com.etude.domain.terminal.ContainerCleanupService
import jakarta.annotation.PreDestroy
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Component

@Component
@Profile("!test")
class ContainerLifecycleHooks(
    private val containerCleanupService: ContainerCleanupService,
) : ApplicationRunner {
    override fun run(args: ApplicationArguments?) {
        containerCleanupService.cleanupOrphanContainers()
    }

    @PreDestroy
    fun onShutdown() {
        containerCleanupService.cleanupRunningContainers()
    }
}