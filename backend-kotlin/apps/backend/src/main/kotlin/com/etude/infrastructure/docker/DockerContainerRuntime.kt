package com.etude.infrastructure.docker

import com.etude.domain.terminal.ContainerRuntime
import com.etude.domain.terminal.ContainerSpec
import com.etude.domain.terminal.TerminalStream
import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.api.async.ResultCallback
import com.github.dockerjava.api.model.HostConfig
import org.springframework.stereotype.Component

@Component
class DockerContainerRuntime(
    private val dockerClient: DockerClient,
) : ContainerRuntime {

    override fun listByLabel(
        label: String,
        includedStopped: Boolean
    ): List<String> =
        dockerClient.listContainersCmd()
            .withShowAll(includedStopped)
            .withLabelFilter(listOf(label))
            .exec()
            .map { it.id }

    override fun stopAndRemove(containerId: String) {
        runCatching { dockerClient.stopContainerCmd(containerId).exec() }
        runCatching { dockerClient.removeContainerCmd(containerId).exec() }
    }

    override fun createContainer(spec: ContainerSpec): String {
        val hostConfig = HostConfig.newHostConfig()
            .withBinds(spec.binds.map { com.github.dockerjava.api.model.Bind.parse(it) })
            .withPrivileged(spec.privileged)
            .apply { spec.networkMode?.let { withNetworkMode(it) } }

        return dockerClient.createContainerCmd(spec.image)
            .withLabels(mapOf("etude" to "sandbox") + spec.extraLabels)
            .withCmd(spec.command)
            .withTty(spec.tty)
            .withAttachStdin(spec.openStdin)
            .withAttachStdout(spec.openStdin)
            .withAttachStderr(spec.openStdin)
            .withStdinOpen(spec.openStdin)
            .withHostConfig(hostConfig)
            .exec()
            .id
    }

    override fun startContainer(containerId: String) {
        dockerClient.startContainerCmd(containerId).exec()
    }

    override fun attachToMainProcess(containerId: String): TerminalStream =
        AttachTerminalStream(dockerClient, containerId)

    override fun execShell(
        containerId: String,
        command: List<String>
    ): TerminalStream =
        ExecTerminalStream(dockerClient, containerId, command)

    override fun execAndWait(containerId: String, command: List<String>) {
        val execId = dockerClient.execCreateCmd(containerId)
            .withCmd(*command.toTypedArray())
            .withAttachStdout(true)
            .withAttachStderr(true)
            .exec()
            .id

        dockerClient.execStartCmd(execId).exec(
            ResultCallback.Adapter()
        ).awaitCompletion()
    }

}