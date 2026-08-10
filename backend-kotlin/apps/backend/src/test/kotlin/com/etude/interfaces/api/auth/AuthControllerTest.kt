package com.etude.interfaces.api.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.support.IntegrationTest
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class AuthControllerTest : IntegrationTest() {

    @Autowired lateinit var mockMvc: MockMvc
    @Autowired lateinit var userJpaRepository: UserJpaRepository

    @BeforeEach
    fun setup() {
        userJpaRepository.deleteAll()
        userJpaRepository.save(
            User(
                name = "테스트",
                email = "test@okestro.com",
                password = BCryptPasswordEncoder().encode("password123")!!,
                role = UserRole.member,
            )
        )
    }

    @DisplayName("로그인 성공 시 토큰을 반환한다")
    @Test
    fun loginReturnsToken() {
        mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{ "email": "test@okestro.com", "password": "password123" }""")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.token").exists())
            .andExpect(jsonPath("$.data.user.email").value("test@okestro.com"))
    }

    @DisplayName("잘못된 비밀번호면 401을 반환한다")
    @Test
    fun loginFailsWithWrongPassword() {
        mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{ "email": "test@okestro.com", "password": "wrong" }""")
        )
            .andExpect(status().isUnauthorized)
    }

    @DisplayName("토큰 없이 me 호출하면 401을 반환한다")
    @Test
    fun meFailsWithoutToken() {
        mockMvc.perform(get("/me")).andExpect(status().isUnauthorized)
    }

    @DisplayName("토큰을 붙이면 me가 사용자 정보를 반환한다")
    @Test
    fun meReturnsUserWithToken() {
        val loginResponse = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"test@okestro.com","password":"password123"}""")
        ).andReturn().response.contentAsString
        val token = Regex(""""token":"([^"]+)"""").find(loginResponse)!!.groupValues[1]

        mockMvc.perform(get("/me").header("Authorization", "Bearer $token"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.email").value("test@okestro.com"))
    }
}