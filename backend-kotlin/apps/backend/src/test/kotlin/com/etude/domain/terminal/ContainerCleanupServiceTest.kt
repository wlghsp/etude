package com.etude.domain.terminal

import io.kotest.core.spec.style.FreeSpec
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class ContainerCleanupServiceTest : FreeSpec({
    val containerRuntime = mockk<ContainerRuntime>(relaxed = true)
    val service = ContainerCleanupService(containerRuntime)

    "고아 컨테이너를 정리하면" - {
        "정지된 컨테이너까지 포함해 전부 조회하고 각각 정지/제거한다" {
            every {
                containerRuntime.listByLabel(ContainerCleanupService.SANDBOX_LABEL, includedStopped = true)
            } returns listOf("c1", "c2")

            service.cleanupOrphanContainers()

            verify { containerRuntime.stopAndRemove("c1") }
            verify { containerRuntime.stopAndRemove("c2") }
        }
    }

    "실행중인 컨테이너만 정리하면" - {
        "includeStopped=false로 조회한다" {
            every {
                containerRuntime.listByLabel(ContainerCleanupService.SANDBOX_LABEL, includedStopped = false)
            } returns listOf("c1")

            service.cleanupRunningContainers()

            verify { containerRuntime.stopAndRemove("c1") }
        }
    }

})