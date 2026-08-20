package com.etude.domain.terminal

import org.springframework.stereotype.Service

@Service
class ContainerCleanupService(
    private val containerRuntime: ContainerRuntime,
) {
    fun cleanupOrphanContainers() {
        containerRuntime.listByLabel(SANDBOX_LABEL, includedStopped = true)
            .forEach { containerRuntime.stopAndRemove(it) }
    }

    fun cleanupRunningContainers() {
        containerRuntime.listByLabel(SANDBOX_LABEL, includedStopped = false)
            .forEach { containerRuntime.stopAndRemove(it) }
    }

    companion object {
        const val SANDBOX_LABEL = "etude=sandbox"
    }

}