package com.etude.domain.feedback

import com.etude.domain.progress.FeedbackRepository
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot

class FeedbackServiceTest : FreeSpec({
    val feedbackRepository = mockk<FeedbackRepository>()
    val feedbackService = FeedbackService(feedbackRepository)

    "앞 뒤 공백이 있는 내용으로 피드백을 등록하면" - {
        "trim된 내용으로 저장한다" {
            val captured = slot<Feedback>()
            every { feedbackRepository.save(capture(captured)) } answers { captured.captured }

            feedbackService.createFeedback(
                userId = 1L,
                page = "/quest-sets",
                questId = null,
                questSetId = null,
                body = "  좋아요  "
            )

            captured.captured.body shouldBe "좋아요"
        }
    }

})