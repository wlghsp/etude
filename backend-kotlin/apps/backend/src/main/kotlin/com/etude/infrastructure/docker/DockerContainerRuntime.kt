package com.etude.infrastructure.docker

import com.etude.domain.terminal.ContainerRuntime
import com.github.dockerjava.api.DockerClient
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

}