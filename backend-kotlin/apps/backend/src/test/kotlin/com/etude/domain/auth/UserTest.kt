package com.etude.domain.auth

import com.etude.support.TestUsers
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk

class UserTest : FreeSpec({

    "이름을 변경하면" - {
        "바뀐 이름이 반영된다" {
            val user = TestUsers.member()

            user.changeName("새 이름")

            user.name shouldBe "새 이름"
        }
    }

    "비밀번호를 변경하면" - {
        "다음 matchesPassword 호출이 새 비밀번호 기준으로 판단된다" {
            val user = TestUsers.member()
            val passwordEncoder = mockk<PasswordEncoder>()
            every { passwordEncoder.matches("raw", "new-hashed") } returns true

            user.changePassword("new-hashed")

            user.matchesPassword("raw", passwordEncoder) shouldBe true
        }
    }

    "비밀번호를 확인할 때" - {
        "PasswordEncoder에 현재 저장된 password를 그대로 위임한다" {
            val user = TestUsers.member()
            val passwordEncoder = mockk<PasswordEncoder>()
            every { passwordEncoder.matches("raw", any()) } returns true

            user.matchesPassword("raw", passwordEncoder) shouldBe true
        }
    }
})