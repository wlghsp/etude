package com.etude.interfaces.api.progress

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.progress.QuestAttemptJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import com.etude.support.TestAuth
import com.etude.support.TestQuestAttempts
import com.etude.support.TestQuestSets
import com.etude.support.TestQuests
import com.etude.support.TestUsers
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class ProgressControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questJpaRepository: QuestJpaRepository,
    @Autowired private val questAttemptJpaRepository: QuestAttemptJpaRepository,
) : IntegrationTest({
    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    lateinit var publicSet: QuestSet

    beforeTest {
        val member = TestUsers.createMember(userJpaRepository)
        publicSet = TestQuestSets.createPublic(questSetJpaRepository)
        val quest = TestQuests.createAndSave(questJpaRepository, questSetId = publicSet.id)
        TestQuestAttempts.createAndSave(questAttemptJpaRepository, userId = member.id, questId = quest.id, questSetId = publicSet.id, passed = true)
    }

    afterTest {
        questAttemptJpaRepository.deleteAll()
        questJpaRepository.deleteAll()
        questSetJpaRepository.deleteAll()
    }

    "내 진행률을 조회하면" - {
        "완료한 퀘스트 수가 반영된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                get("/progress").header("Authorization", "Bearer $token")
            ).andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].total").value(1))
                .andExpect(jsonPath("$.data[0].completed").value(1))
        }
    }

    "토큰 없이 진행률을 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/progress"))
                .andExpect(status().isUnauthorized)
        }
    }

    "리더보드를 조회하면" - {
        "member의 완료 수가 반영된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                get("/leaderboard").header("Authorization", "Bearer $token")
            ).andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].completed").value(1))
        }
    }

    "토큰 없이 리더보드를 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/leaderboard"))
                .andExpect(status().isUnauthorized)
        }
    }

})