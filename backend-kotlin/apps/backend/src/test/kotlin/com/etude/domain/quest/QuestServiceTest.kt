package com.etude.domain.quest

import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import com.etude.support.TestQuestSets
import com.etude.support.TestQuests
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class QuestServiceTest : FreeSpec({
    val questSetRepository = mockk<QuestSetRepository>()
    val questRepository = mockk<QuestRepository>()
    val questSetAccessRepository = mockk<QuestSetAccessRepository>()
    val userRepository = mockk<UserRepository>()
    val questService = QuestService(questSetRepository, questRepository, questSetAccessRepository, userRepository)

    "퀘스트셋 접근 권한을 확인할 때" -  {
        "공개 세트면" - {
            "member도 접근할 수 있다" {
                val publicSet = TestQuestSets.public()
                every { questSetRepository.findById(1L) } returns publicSet

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe true
            }
        }

        "비공개 세트라도" - {
            "관리자면 접근할 수 있다" {
                val privateSet = TestQuestSets.private()
                every { questSetRepository.findById(1L) } returns privateSet

                questService.canAccess(userId = 1L, role = UserRole.admin, questSetId = 1L) shouldBe true
            }

            "member는 개별 권한이 있어야 접근할 수 있다" {
                val privateSet = TestQuestSets.private()
                every { questSetRepository.findById(1L) } returns privateSet
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns true

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe true
            }

            "member가 개별 권한도 없으면 접근할 수 있다" {
                val privateSet = TestQuestSets.private()
                every { questSetRepository.findById(1L) } returns privateSet
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns false

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe false
            }
        }

        "존재하지 않는 세트면" - {
            "접근할 수 없다" {
                every { questSetRepository.findById(999L) } returns null

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 999L) shouldBe false
            }
        }
    }

    "퀘스트 목록을 조회할 때" - {
        "접근 권한이 없으면" - {
            "예외를 던진다" {
                every { questSetRepository.findById(1L) } returns null

                shouldThrow<QuestSetAccessDeniedException> {
                    questService.getQuests(userId = 10L, role = UserRole.member, questSetId = 1L)
                }
            }
        }

        "접근 권한이 있으면" - {
            "order_index 순으로 반환한다" {
                val publicSet = TestQuestSets.public()
                every { questSetRepository.findById(1L) } returns publicSet
                every { questRepository.findAllByQuestSetIdOrderByOrderIndex(1L) } returns listOf(
                    TestQuests.create(questSetId = 1L, title = "1번")
                )

                val result = questService.getQuests(userId = 10L, role = UserRole.member, questSetId = 1L)

                result.size shouldBe 1
                result[0].title shouldBe "1번"

            }
        }
    }

    "관리자가 퀘스트셋 공개 여부를 바꿀 때" - {
        "대상이 존재하면" - {
            "isPublic이 바뀐다" {
                val questSet = TestQuestSets.public()
                every { questSetRepository.findById(1L) } returns questSet
                every { questSetRepository.save(questSet) } returns questSet

                questService.setPublic(1L, false)

                questSet.isPublic shouldBe false
            }
        }

        "존재하지 않는 id면" - {
            "예외를 던진다" {
                every { questSetRepository.findById(999L) } returns null

                shouldThrow<QuestSetNotFoundException> {
                    questService.setPublic(999L, false)
                }
            }
        }
    }


    "관리자가 접근 권한을 부여할 때" - {
        "이미 권한이 있으면" - {
            "다시 저장하지 않는다" {
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns true

                questService.grantAccess(1L, 10L)

                verify(exactly = 0) { questSetAccessRepository.save(any()) }
            }
        }

        "권한이 없으면" - {
            "새로 저장한다" {
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns false
                every { questSetAccessRepository.save(any()) } returns QuestSetAccess(1L, 10L)
                questService.grantAccess(1L, 10L)

                verify(exactly = 1) { questSetAccessRepository.save(any()) }
            }
        }
    }

})

