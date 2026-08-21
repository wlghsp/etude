package com.etude.domain.terminal

import com.etude.domain.quest.QuestService
import com.etude.domain.sandbox.SandboxConfig
import com.etude.domain.sandbox.SandboxConfigService
import io.kotest.core.spec.style.FreeSpec
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class TerminalSessionServiceTest : FreeSpec({
    fun newService(): Triple<SandboxConfigService, ContainerRuntime, TerminalSessionService> {
        val sandboxConfigService = mockk<SandboxConfigService>()
        val containerRuntime = mockk<ContainerRuntime>(relaxed = true)
        val questService = mockk<QuestService> {
            every { getSetupCommand(any()) } returns null
        }
        return Triple(sandboxConfigService, containerRuntime, TerminalSessionService(sandboxConfigService, containerRuntime, questService))
    }

    "default 분기(sandboxType=linux)로 열면" - {
        "attach 방식으로 연결하고 컨테이너를 시작한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("linux") } returns
                    SandboxConfig(image = "etude-linux", binds = null, persistent = false)
            every { containerRuntime.createContainer(any()) } returns "c1"

            service.open("linux", questId = null, existingContainerId = null)

            verify { containerRuntime.attachToMainProcess("c1") }
            verify { containerRuntime.startContainer("c1") }
        }
    }

    "docker 분기로 닫으면" - {
        "컨테이너를 정지/제거한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("docker") } returns
                    SandboxConfig(image = "docker:dind", binds = null, persistent = false)
            every { containerRuntime.createContainer(any()) } returns "c2"

            val session = service.open("docker", questId = null, existingContainerId = null)
            session.close()

            verify { containerRuntime.stopAndRemove("c2") }
        }
    }

    "docker-persistent 분기로 닫으면" - {
        "컨테이너를 지우지 않는다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("docker-persistent") } returns
                    SandboxConfig(image = "docker:dind", binds = null, persistent = true)
            every { containerRuntime.createContainer(any()) } returns "c3"

            val session = service.open("docker-persistent", questId = null, existingContainerId = null)
            session.close()

            verify(exactly = 0) { containerRuntime.stopAndRemove("c3") }
        }
    }

    "docker-persistent 분기에 containerId가 있으면" - {
        "새로 만들지 않고 재사용한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("docker-persistent") } returns
                    SandboxConfig(image = "docker:dind", binds = null, persistent = true)

            service.open("docker-persistent", questId = null, existingContainerId = "existing-c4")

            verify(exactly = 0) { containerRuntime.createContainer(any()) }
            verify { containerRuntime.execShell("existing-c4", listOf("/bin/sh")) }
        }
    }


})