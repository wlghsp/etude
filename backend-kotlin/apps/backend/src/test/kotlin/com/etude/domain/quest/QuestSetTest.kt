package com.etude.domain.quest

import com.etude.domain.auth.UserRole
import com.etude.domain.auth.UserSummary
import com.etude.support.TestQuestSets
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe

class QuestSetTest : FreeSpec({

    "공개 여부를 변경하면" - {
        "isPublic이 바뀐다" {
            val questSet = TestQuestSets.public(title = "리눅스 기초")

            questSet.changePublic(false)

            questSet.isPublic shouldBe false
        }
    }

    "관리자용 요약으로 변환하면" - {
        "자신의 필드와 전달받은 accessUser를 그대로 담는다" {
            val questSet = TestQuestSets.private(title = "리눅스 기초", description = "설명")
            val accessUsers = listOf(UserSummary(1L, "멤버", "member@okestro.", UserRole.member))

            val summary = questSet.toAdminSummary(accessUsers = accessUsers)

            summary.title shouldBe "리눅스 기초"
            summary.description shouldBe "설명"
            summary.isPublic shouldBe false
            summary.accessUsers shouldBe accessUsers
        }
    }
})