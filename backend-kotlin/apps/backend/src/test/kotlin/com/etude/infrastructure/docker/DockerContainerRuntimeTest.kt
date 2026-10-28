package com.etude.infrastructure.docker

import com.etude.domain.terminal.ContainerRuntime
import com.etude.domain.terminal.ContainerSpec
import com.etude.support.IntegrationTest
import io.kotest.matchers.shouldBe
import org.springframework.beans.factory.annotation.Autowired

class DockerContainerRuntimeTest(
    @Autowired private val containerRuntime: ContainerRuntime,
): IntegrationTest({
    lateinit var containerId: String

    beforeTest {
        containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = "etude-linux",
                binds = emptyList(),
                command = listOf("sh", "-c", "trap 'exit 0' TERM; sleep 300 & wait"),
                tty = false,
                openStdin = false,
            )
        )
        containerRuntime.startContainer(containerId)
    }

    afterTest {
        containerRuntime.stopAndRemove(containerId)
    }

    "execAndCheck는" - {
        "명령이 exit 0으로 끝나면 true를 반환한다" {
            containerRuntime.execAndCheck(containerId, listOf("true")) shouldBe true
        }

        "명령이 0이 아닌 exit code로 끝나면 false를 반환한다" {
            containerRuntime.execAndCheck(containerId, listOf("false")) shouldBe false
        }

        "timeoutMs 안에 끝나지 않으면 false를 반환한다" {
            containerRuntime.execAndCheck(containerId, listOf("sleep", "30"), timeoutMs = 1_000) shouldBe false
        }
    }
})