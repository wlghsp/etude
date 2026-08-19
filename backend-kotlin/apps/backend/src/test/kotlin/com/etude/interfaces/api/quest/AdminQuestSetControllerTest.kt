package com.etude.interfaces.api.quest

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetAccessJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import com.etude.support.TestAuth
import com.etude.support.TestQuestSets
import com.etude.support.TestUsers
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import kotlin.properties.Delegates

@AutoConfigureMockMvc
class AdminQuestSetControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questSetAccessJpaRepository: QuestSetAccessJpaRepository,
) : IntegrationTest({

    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    lateinit var privateSet: QuestSet
    var memberId: Long by Delegates.notNull()

    beforeTest {
        TestUsers.createAdmin(userJpaRepository)
        val member = TestUsers.createMember(userJpaRepository)
        memberId = member.id
        privateSet = TestQuestSets.createPrivate(questSetJpaRepository)
    }

    "관리자가 퀘스트셋 목록을 조회하면" - {
        "isPublic과 accessUser를 포함해 전체가 보인다" {
            val token = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)

            mockMvc.perform(
                get("/admin/quest-sets").header("Authorization", "Bearer $token")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].isPublic").value(false))
                .andExpect(jsonPath("$.data[0].accessUsers").isArray)
        }
    }

    "member 권한으로 조회를 시도하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                get("/admin/quest-sets")
                    .header("Authorization", "Bearer $token")
            )
                .andExpect(status().isForbidden)
        }
    }

    "관리자가 퀘스트셋을 공개로 전환하면" - {
        "member도 목록에서 볼 수 있게 된다" {
            val token = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)

            mockMvc.perform(
                patch("/admin/quest-sets/${privateSet.id}")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"isPublic":true}""")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)
            mockMvc.perform(
                get("/quest-sets")
                .header("Authorization", "Bearer $memberToken")
            )
                .andExpect(jsonPath("$.data.length()").value(1))
        }
    }

    "관리자가 접근 권한을 부여하면" - {
        "member도 목록에서 볼 수 있게 된다" {
            val token = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)

            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":$memberId}""")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)
            mockMvc.perform(
                get("/quest-sets")
                    .header("Authorization", "Bearer $memberToken")
            )
                .andExpect(status().isOk)
        }
    }

    "관리자가 접근 권한을 회수하면" - {
        "해당 사용자가 다시 접근할 수 없게 된다" {
            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":$memberId}""")
            )

            mockMvc.perform(
                delete("/admin/quest-sets/${privateSet.id}/access/${memberId}")
                    .header("Authorization", "Bearer $adminToken")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)
            mockMvc.perform(
                get("/quest-sets/${privateSet.id}/quests")
                    .header("Authorization", "Bearer $memberToken")
            )
                .andExpect(status().isForbidden)
        }
    }

    "토큰 없이 관리자용 퀘스트셋 목록을 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/admin/quest-sets"))
                .andExpect(status().isUnauthorized)
        }
    }

    "member 권한으로 공개 여부를 변경하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                patch("/admin/quest-sets/${privateSet.id}")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"isPublic":false}""")
            )
                .andExpect(status().isForbidden)
        }
    }

    "member 권한으로 접근 권한을 부여하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":${memberId}}""")
            )
                .andExpect(status().isForbidden)
        }
    }


    "member 권한으로 접근 권한을 회수하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                delete("/admin/quest-sets/${privateSet.id}/access/$memberId")
                    .header("Authorization", "Bearer $token")
            )
                .andExpect(status().isForbidden)
        }
    }

    "이미 접근 권한이 있는 사용자에게 다시 권한을 부여하면" - {
        "에러 없이 200을 반환한다" {
            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":$memberId}""")
            ).andExpect(status().isOk)

            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":$memberId}""")
            ).andExpect(status().isOk)
        }
    }

    "권한이 없던 사용자의 접근 권한을 회수하면" - {
        "에러 없이 200을 반환한다" {
            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(
                delete("/admin/quest-sets/${privateSet.id}/access/${memberId}")
                    .header("Authorization", "Bearer $adminToken")
            ).andExpect(status().isOk)

        }
    }

})