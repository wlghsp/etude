package com.etude.interfaces.api.quest

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.*
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class QuestControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questJpaRepository: QuestJpaRepository,
) : IntegrationTest({
    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    lateinit var publicSet: QuestSet
    lateinit var privateSet: QuestSet

    beforeTest {
        questJpaRepository.deleteAll()
        questSetJpaRepository.deleteAll()
        userJpaRepository.deleteAll()

        TestUsers.createAdmin(userJpaRepository)
        TestUsers.createMember(userJpaRepository)
        publicSet = TestQuestSets.createPublic(questSetJpaRepository)
        privateSet = TestQuestSets.createPrivate(questSetJpaRepository)
        TestQuests.createAndSave(questJpaRepository, questSetId = publicSet.id)
    }

    "퀘스트셋 목록을 조회하면" - {
        "필드가 모두 채워져 반환된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                get("/quest-sets").header("Authorization", "Bearer $token")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].sandboxType").value("linux"))
                .andExpect(jsonPath("$.data[0].category").value("리눅스"))
        }

        "공개 세트만 보인다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                get("/quest-sets").header("Authorization", "Bearer $token")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].title").value("공개 세트"))
        }
    }

    "공개 세트의 퀘스트 목록을 조회하면" - {
        "순서대로 반환된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                get("/quest-sets/${publicSet.id}/quests")
                    .header("Authorization", "Bearer $token")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].title").value("1번 퀘스트"))
        }
    }

    "비공개 세트의 퀘스트 목록을 조회하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                get("/quest-sets/${privateSet.id}/quests")
                    .header("Authorization", "Bearer $token")
            )
                .andExpect(status().isForbidden)
        }
    }

    "토큰 없이 퀘스트 목록을 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(
                get("/quest-sets")
            ).andExpect(status().isUnauthorized)
        }
    }


})