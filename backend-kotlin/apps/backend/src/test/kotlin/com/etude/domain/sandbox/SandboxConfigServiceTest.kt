package com.etude.domain.sandbox

import com.etude.support.IntegrationTest
import io.kotest.matchers.nulls.shouldBeNull
import io.kotest.matchers.shouldBe
import org.springframework.beans.factory.annotation.Autowired

class SandboxConfigServiceTest(
    @Autowired val sandboxConfigService: SandboxConfigService,
) : IntegrationTest({
    "binds가 없는 타입을 조회하면" - {
        "image만 채워지고 binds는 null이다" {
            val config = sandboxConfigService.getSandboxConfig("linux")

            config.image shouldBe "etude-linux"
            config.binds.shouldBeNull()
        }
    }

    "binds에 KUBECONFIG_HOST_PATH가 있는 타입을 조회하면" - {
        "플레이스홀더가 치환된다" {
            val config = sandboxConfigService.getSandboxConfig("k8s")

            config.binds?.get(0)?.contains("{KUBECONFIG_HOST_PATH}") shouldBe false
        }
    }

    "존재하지 않는 타입을 조회하면" - {
        "ubuntu 기본값으로 폴백한다" {
            val config = sandboxConfigService.getSandboxConfig("no-such-type")

            config.image shouldBe "ubuntu"
            config.binds.shouldBeNull()
        }
    }

})