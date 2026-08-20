package com.etude.domain.terminal

interface ContainerRuntime {
    fun listByLabel(label: String, includedStopped: Boolean): List<String>
    fun stopAndRemove(containerId: String)
}