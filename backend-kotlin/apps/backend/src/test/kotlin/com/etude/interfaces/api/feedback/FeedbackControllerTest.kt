package com.etude.interfaces.api.feedback

import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.feedback.FeedbackJpaRepository
import com.etude.support.IntegrationTest
import com.etude.support.TestAuth
import com.etude.support.TestUsers
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class FeedbackControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val feedbackJpaRepository: FeedbackJpaRepository,

) : IntegrationTest({
    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    beforeTest {
        TestUsers.createAdmin(userJpaRepository)
        TestUsers.createMember(userJpaRepository)
    }

    "로그인한 사용자가 피드백을 등록하면" - {
        "200을 반환하고 작성자가 기록된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                post("/feedback")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"page":"/quest-sets","body":"좋아요"}""")
            ).andExpect(status().isOk)

            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(get("/admin/feedback").header("Authorization", "Bearer $adminToken"))
                .andExpect(jsonPath("$.data[0].userName").value("멤버"))
        }
    }

    "토큰 없이 피드백을 등록하면" - {
        "200을 반환하고 작성자가 null로 기록된다" {
            mockMvc.perform(
                post("/feedback")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"page":"/quest-sets","body":"익명 피드백"}""")
            ).andExpect(status().isOk)

            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(get("/admin/feedback").header("Authorization", "Bearer $adminToken"))
                .andExpect(jsonPath("$.data[0].userName").doesNotExist())
        }
    }

    "빈 내용으로 피드백을 등록하면" - {
        "400을 반환한다" {
            mockMvc.perform(
                post("/feedback")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"page":"/quest-sets","body":"   "}""")
            ).andExpect(status().isBadRequest)
        }
    }

    "관리자가 피드백 목록을 조회하면" - {
        "최신순으로 반환된다" {
            mockMvc.perform(
                post("/feedback").contentType(MediaType.APPLICATION_JSON).content("""{"page":"/a","body":"첫번째"}""")
            )
            mockMvc.perform(
                post("/feedback").contentType(MediaType.APPLICATION_JSON).content("""{"page":"/b","body":"두번째"}""")
            )

            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(get("/admin/feedback").header("Authorization", "Bearer $adminToken"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].body").value("두번째"))
        }
    }

    "토큰 없이 피드백 목록을 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/admin/feedback")).andExpect(status().isUnauthorized)
        }
    }
})