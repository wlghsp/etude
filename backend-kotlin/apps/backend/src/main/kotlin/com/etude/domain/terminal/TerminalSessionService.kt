package com.etude.domain.terminal

import com.etude.domain.quest.QuestService
import com.etude.domain.quest.questNamespace
import com.etude.domain.sandbox.SandboxConfig
import com.etude.domain.sandbox.SandboxConfigService
import com.etude.domain.sandbox.SandboxType
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service

@Service
class TerminalSessionService(
    private val sandboxConfigService: SandboxConfigService,
    private val containerRuntime: ContainerRuntime,
    private val questService: QuestService,
    @Value("\${etude.k3d-network}") private val k3dNetwork: String,
) {
    fun open(sandboxTypeValue: String, questId: Long?, existingContainerId: String?): TerminalSession {
        val config = sandboxConfigService.getSandboxConfig(sandboxTypeValue)
        return when (val sandboxType = SandboxType.from(sandboxTypeValue, config)) {
            is SandboxType.Default -> openDefault(config, questId)
            is SandboxType.Docker -> openDocker(config, questId, existingContainerId, sandboxType.persistent)
            is SandboxType.LinuxSystemd -> openLinuxSystemd(config, questId)
            is SandboxType.K8s -> openK8s(config, questId)
            is SandboxType.K8sIsolated -> TODO("향후 구현")
        }
    }

    private fun openDefault(config: SandboxConfig, questId: Long?): TerminalSession {
        val containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = config.image,
                binds = config.binds ?: emptyList(),
                command = listOf("/bin/bash"),
                tty = true,
                openStdin = true,
            )
        )
        val stream = containerRuntime.attachToMainProcess(containerId)
        containerRuntime.startContainer(containerId)
        runSetupCommand(containerId, questId)

        return TerminalSession(containerId, stream) {
            containerRuntime.stopAndRemove(containerId)
        }
    }

    private fun openDocker(
        config: SandboxConfig,
        questId: Long?,
        existingContainerId: String?,
        persistent: Boolean,
    ): TerminalSession {
        val containerId = existingContainerId ?: run {
            val id = containerRuntime.createContainer(
                ContainerSpec(
                    image = config.image,
                    binds = config.binds ?: emptyList(),
                    command = emptyList(),
                    tty = false,
                    openStdin = false,
                    privileged = true,
                )
            )
            containerRuntime.startContainer(id)
            waitForDockerDaemon(id)
            id
        }

        runSetupCommand(containerId, questId)
        val stream = containerRuntime.execShell(containerId, listOf("/bin/sh"))

        return TerminalSession(containerId, stream) {
            if (!persistent) containerRuntime.stopAndRemove(containerId)
        }
    }

    private fun waitForDockerDaemon(containerId: String) {
        containerRuntime.execAndWait(
            containerId,
            listOf("sh", "-c", "until test -S /var/run/docker.sock; do sleep 0.2; done"),
        )
    }

    private fun openLinuxSystemd(config: SandboxConfig, questId: Long?): TerminalSession {
        val containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = config.image,
                binds = (config.binds ?: emptyList()) + "/sys/fs/cgroup:/sys/fs/cgroup:rw",
                command = emptyList(),
                tty = false,
                openStdin = false,
                privileged = true,
                cgroupnsMode = "host",
            )
        )
        containerRuntime.startContainer(containerId)
        waitForSystemd(containerId)

        runSetupCommand(containerId, questId)
        val stream = containerRuntime.execShell(containerId, listOf("/bin/bash"))

        return TerminalSession(containerId, stream) {
            containerRuntime.stopAndRemove(containerId)
        }
    }

    private fun waitForSystemd(containerId: String) {
        containerRuntime.execAndWait(
            containerId,
            listOf(
                "sh", "-c",
                "until systemctl is-system-running 2>/dev/null | grep -qE \"running|degraded\"; do sleep 0.3; done",
            ),
        )
    }

    private fun openK8s(config: SandboxConfig, questId: Long?): TerminalSession {
        val containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = config.image,
                binds = config.binds ?: emptyList(),
                command = listOf("/bin/bash"),
                tty = true,
                openStdin = true,
                networkMode = k3dNetwork,
            )
        )
        val stream = containerRuntime.attachToMainProcess(containerId)
        containerRuntime.startContainer(containerId)

        val namespace = questNamespace(containerId)
        containerRuntime.execAndWait(containerId, listOf("kubectl", "create", "namespace", namespace))
        runSetupCommand(containerId, questId, namespace)

        return TerminalSession(containerId, stream) {
            runCatching {
                containerRuntime.execAndWait(
                    containerId,
                    listOf("kubectl", "delete", "namespace", namespace, "--ignore-not-found"),
                )
            }
            containerRuntime.stopAndRemove(containerId)
        }
    }

    private fun runSetupCommand(containerId: String, questId: Long?, namespace: String? = null) {
        val setupCmd = questId?.let { questService.getSetupCommand(it) } ?: return
        val resolved = if (namespace == null) setupCmd else setupCmd.map { it.replace("\$NS", namespace) }
        containerRuntime.execAndWait(containerId, resolved)
    }

}

class TerminalSession(
    val containerId: String,
    val stream: TerminalStream,
    private val onClose: () -> Unit,
) {
    fun close() {
        stream.close()
        onClose()
    }

}