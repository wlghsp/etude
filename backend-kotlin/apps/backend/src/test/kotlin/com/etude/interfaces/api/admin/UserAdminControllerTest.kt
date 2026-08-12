package com.etude.interfaces.api.admin

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.support.IntegrationTest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class UserAdminControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
) : IntegrationTest({

    fun loginAndGetToken(email: String, password: String): String {
        val response = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"$email","password":"$password"}""")
        ).andReturn().response.contentAsString
        return Regex("""token":"([^"]+)""").find(response)!!.groupValues[1]
    }

    beforeTest {
        userJpaRepository.deleteAll()
        userJpaRepository.save(
            User(name = "관리자", email = "admin@okestro.com", password = BCryptPasswordEncoder().encode("admin123")!!, role = UserRole.admin)
        )
        userJpaRepository.save(
            User(name = "멤버", email = "member@okestro.com", password = BCryptPasswordEncoder().encode("member123")!!, role = UserRole.member)
        )
    }


    "관리자가 계정을 생성하면" - {
        "member 권한으로 생성된다" {
            val token = loginAndGetToken("admin@okestro.com", "admin123")

            mockMvc.perform(
                post("/admin/users")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"name":"신규","email":"new@okestro.com","password":"password123"}""")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.email").value("new@okestro.com"))
                .andExpect(jsonPath("$.data.role").value("member"))
        }
    }

    "member 권한으로 계정 생성을 시도하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(
                post("/admin/users")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"name":"신규", "email":"new2@okestro.com", "password":"password123"}""")
            )
                .andExpect(status().isForbidden)
        }
    }

    "관리자가 계정 목록을 조회하면" - {
        "member만 이름순으로 반환한다" {
            val token = loginAndGetToken("admin@okestro.com", "admin123")

            mockMvc.perform(get("/admin/users").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data.[0].email").value("member@okestro.com"))
        }
    }

    "관리자가 비밀번호를 초기화하면" - {
        "새 비밀번호로 로그인할 수 있다" {
            val adminToken = loginAndGetToken("admin@okestro.com", "admin123")
            val memberId = userJpaRepository.findByEmail("member@okestro.com")!!.id

            mockMvc.perform(
                patch("/admin/users/$memberId/password")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"password":"newpass123"}""")
            )
                .andExpect(status().isOk)

            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"email":"member@okestro.com","password":"newpass123"}""")
            )
                .andExpect(status().isOk)
        }
    }

    "본인이 비밀번호를 변경할 때" - {
        "현재 비밀번호가 맞으면 변경된다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(
                patch("/me/password")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"currentPassword":"member123","newPassword":"newpass456"}""")
            )
                .andExpect(status().isOk)

            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"email":"member@okestro.com","password":"newpass456"}""")
            )
                .andExpect(status().isOk)
        }

        "현재 비밀번호가 틀리면 401을 반환한다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(
                patch("/me/password")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"currentPassword":"wrong","newPassword":"newpass456"}""")
            )
                .andExpect(status().isUnauthorized)
        }
    }

})