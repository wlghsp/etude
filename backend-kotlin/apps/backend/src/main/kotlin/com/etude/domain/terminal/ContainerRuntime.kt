package com.etude.domain.terminal

interface ContainerRuntime {
    fun listByLabel(label: String, includedStopped: Boolean): List<String>
    fun stopAndRemove(containerId: String)

    fun createContainer(spec: ContainerSpec): String
    fun startContainer(containerId: String)
    fun attachToMainProcess(containerId: String): TerminalStream
    fun execShell(containerId: String, command: List<String>): TerminalStream
    fun execAndWait(containerId: String, command: List<String>)
}

data class ContainerSpec(
    val image: String,
    val binds: List<String>,
    val command: List<String>,
    val tty: Boolean,
    val openStdin: Boolean,
    val privileged: Boolean = false,
    val networkMode: String? = null,
    val extraLabels: Map<String, String> = emptyMap(),
)

