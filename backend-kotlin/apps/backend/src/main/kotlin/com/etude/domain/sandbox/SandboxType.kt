package com.etude.domain.sandbox

sealed interface SandboxType {
    data object Default : SandboxType
    data class Docker(val persistent: Boolean) : SandboxType
    data object LinuxSystemd : SandboxType
    data object K8s : SandboxType
    data object K8sIsolated : SandboxType

    companion object {
        fun from(sandboxType: String, config: SandboxConfig): SandboxType = when (sandboxType) {
            "docker", "docker-persistent" -> Docker(config.persistent)
            "linux-systemd" -> LinuxSystemd
            "k8s" -> K8s
            "k8s-isolated" -> K8sIsolated
            else -> Default
        }
    }
}