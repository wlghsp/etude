package com.etude.domain.progress

import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk

class ProgressServiceTest : FreeSpec({
    val questAttemptRepository = mockk<QuestAttemptRepository>()
    val progressService = ProgressService(questAttemptRepository)

    "내 진행률을 조회하면" - {
        "퀘스트셋별 진행률을 반환한다" {
            val expected = listOf(QuestSetProgress(1L, "리눅스 기초", "리눅스", total = 3, completed = 1))
            every { questAttemptRepository.findProgressByUserId(10L) } returns expected

            progressService.getProgress(10L) shouldBe expected
        }
    }

    "리더보드를 조회하면" - {
        "사용자별 진행률 순위를 반환한다" {
            val expected = listOf(MemberProgress(1L, "멤버", total = 3, completed = 1, sets = emptyList()))
            every { questAttemptRepository.findLeaderboard() } returns expected

            progressService.getLeaderboard() shouldBe expected
        }
    }

})