package com.etude.domain.terminal

import com.etude.domain.quest.QuestService
import com.etude.domain.sandbox.SandboxConfig
import com.etude.domain.sandbox.SandboxConfigService
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.collections.shouldContain
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import io.mockk.verifyOrder

class TerminalSessionServiceTest : FreeSpec({
    fun newService(): Triple<SandboxConfigService, ContainerRuntime, TerminalSessionService> {
        val sandboxConfigService = mockk<SandboxConfigService>()
        val containerRuntime = mockk<ContainerRuntime>(relaxed = true)
        val questService = mockk<QuestService> {
            every { getSetupCommand(any()) } returns null
        }
        return Triple(
            sandboxConfigService, containerRuntime,
            TerminalSessionService(sandboxConfigService, containerRuntime, questService, "k3d-etude"),
        )
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

    "linux-systemd 분기로 열면" - {
        "cgroup 옵션으로 컨테이너를 만들고 systemd를 기다린 뒤 bash exec로 연결한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("linux-systemd") } returns
                    SandboxConfig(image = "rockylinux", binds = null, persistent = false)
            val spec = slot<ContainerSpec>()
            every { containerRuntime.createContainer(capture(spec)) } returns "c5"

            service.open("linux-systemd", questId = null, existingContainerId = null)

            spec.captured.privileged shouldBe true
            spec.captured.cgroupnsMode shouldBe "host"
            spec.captured.binds shouldContain "/sys/fs/cgroup:/sys/fs/cgroup:rw"
            verifyOrder {
                containerRuntime.startContainer("c5")
                containerRuntime.execAndWait("c5", match { it.joinToString(" ").contains("systemctl is-system-running") })
                containerRuntime.execShell("c5", listOf("/bin/bash"))
            }
        }

        "닫으면" - {
            "컨테이너를 정지/제거한다" {
                val (sandboxConfigService, containerRuntime, service) = newService()
                every { sandboxConfigService.getSandboxConfig("linux-systemd") } returns
                        SandboxConfig(image = "rockylinux", binds = null, persistent = false)
                every { containerRuntime.createContainer(any()) } returns "c6"

                service.open("linux-systemd", questId = null, existingContainerId = null).close()

                verify { containerRuntime.stopAndRemove("c6") }
            }
        }
    }

    "k8s 분기로 열면" - {
        "k3d 네트워크로 컨테이너를 만들고 namespace를 생성한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("k8s") } returns
                    SandboxConfig(image = "etude-k8s", binds = listOf("/kube:/root/.kube/config:ro"), persistent = false)
            val spec = slot<ContainerSpec>()
            every { containerRuntime.createContainer(capture(spec)) } returns "abcdef1234567890"

            service.open("k8s", questId = null, existingContainerId = null)

            spec.captured.networkMode shouldBe "k3d-etude"
            spec.captured.command shouldBe listOf("/bin/bash")
            spec.captured.tty shouldBe true
            verify { containerRuntime.attachToMainProcess("abcdef1234567890") }
            verify {
                containerRuntime.execAndWait("abcdef1234567890", listOf("kubectl", "create", "namespace", "quest-abcdef12"))
            }
        }

        "퀘스트의 setup_cmd에 \$NS가 있으면" - {
            "quest-{컨테이너ID 앞 8자}로 치환해서 실행한다" {
                val sandboxConfigService = mockk<SandboxConfigService> {
                    every { getSandboxConfig("k8s") } returns
                            SandboxConfig(image = "etude-k8s", binds = null, persistent = false)
                }
                val containerRuntime = mockk<ContainerRuntime>(relaxed = true)
                every { containerRuntime.createContainer(any()) } returns "abcdef1234567890"
                val questService = mockk<QuestService> {
                    every { getSetupCommand(7L) } returns listOf("kubectl", "-n", "\$NS", "apply", "-f", "x.yaml")
                }
                val service = TerminalSessionService(sandboxConfigService, containerRuntime, questService, "k3d-etude")

                service.open("k8s", questId = 7L, existingContainerId = null)

                verify {
                    containerRuntime.execAndWait(
                        "abcdef1234567890",
                        listOf("kubectl", "-n", "quest-abcdef12", "apply", "-f", "x.yaml"),
                    )
                }
            }
        }

        "닫으면" - {
            "namespace를 삭제한 뒤 컨테이너를 정지/제거한다" {
                val (sandboxConfigService, containerRuntime, service) = newService()
                every { sandboxConfigService.getSandboxConfig("k8s") } returns
                        SandboxConfig(image = "etude-k8s", binds = null, persistent = false)
                every { containerRuntime.createContainer(any()) } returns "abcdef1234567890"

                service.open("k8s", questId = null, existingContainerId = null).close()

                verifyOrder {
                    containerRuntime.execAndWait(
                        "abcdef1234567890",
                        listOf("kubectl", "delete", "namespace", "quest-abcdef12", "--ignore-not-found"),
                    )
                    containerRuntime.stopAndRemove("abcdef1234567890")
                }
            }

            "namespace 삭제가 실패해도 컨테이너는 정지/제거한다" {
                val (sandboxConfigService, containerRuntime, service) = newService()
                every { sandboxConfigService.getSandboxConfig("k8s") } returns
                        SandboxConfig(image = "etude-k8s", binds = null, persistent = false)
                every { containerRuntime.createContainer(any()) } returns "abcdef1234567890"
                every {
                    containerRuntime.execAndWait(any(), match { it.contains("delete") })
                } throws RuntimeException("cluster down")

                service.open("k8s", questId = null, existingContainerId = null).close()

                verify { containerRuntime.stopAndRemove("abcdef1234567890") }
            }
        }
    }
})
