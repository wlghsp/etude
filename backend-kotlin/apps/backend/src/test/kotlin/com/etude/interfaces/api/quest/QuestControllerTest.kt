package com.etude.interfaces.api.quest

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.domain.quest.Quest
import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class QuestControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questJpaRepository: QuestJpaRepository,
) : IntegrationTest({
    fun loginAndGetToken(email: String, password: String): String {
        val response = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"$email","password":"$password"}""")
        ).andReturn().response.contentAsString
        return Regex("""token":"([^"]+)""").find(response)!!.groupValues[1]
    }

    lateinit var publicSet: QuestSet
    lateinit var privateSet: QuestSet

    beforeTest {
        questJpaRepository.deleteAll()
        questSetJpaRepository.deleteAll()
        userJpaRepository.deleteAll()

        userJpaRepository.save(
            User(name = "관리자", email = "admin@okestro.com", password = BCryptPasswordEncoder().encode("admin123")!!, role = UserRole.admin)
        )
        userJpaRepository.save(
            User(name = "멤버", email = "member@okestro.com", password = BCryptPasswordEncoder().encode("member123")!!, role = UserRole.member)
        )
        publicSet = questSetJpaRepository.save(
            QuestSet(title = "공개 세트", description = null, sandboxType = "linux", category = "리눅스", isPublic = true)
        )
        privateSet = questSetJpaRepository.save(
            QuestSet(title = "비공개 세트", description = null, sandboxType = "linux", category = "리눅스", isPublic = false)
        )
        questJpaRepository.save(
            Quest(questSetId = publicSet.id, orderIndex = 0, title = "1번 퀘스트", description = "설명", hint = null, solution = null, setupCmd = null, gradeCmd = "[]")
        )
    }

    "퀘스트셋 목록을 조회하면" - {
        "공개 세트만 보인다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

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
            val token = loginAndGetToken("member@okestro.com", "member123")

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
            val token = loginAndGetToken("member@okestro.com", "member123")

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