package com.etude.interfaces.api.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.support.IntegrationTest
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
class AuthControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
) : IntegrationTest({

    beforeTest {
        userJpaRepository.deleteAll()
        userJpaRepository.save(
            User(name = "테스트", email = "test@okestro.com", password = BCryptPasswordEncoder().encode("password123")!!, role = UserRole.member)
        )
    }

    "로그인이 성공하면" -  {
        "토큰을 반환한다 " {
            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{ "email": "test@okestro.com", "password": "password123" }""")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.token").exists())
                .andExpect(jsonPath("$.data.user.email").value("test@okestro.com"))
        }
    }

    "잘못된 비밀번호로 로그인하면" -  {
        "401을 반환한다 " {
            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{ "email": "test@okestro.com", "password": "wrong" }""")
            )
                .andExpect(status().isUnauthorized)
        }
    }

    "토큰 없이 /me를 호출하면" -  {
        "401을 반환한다 " {
            mockMvc.perform(get("/me")).andExpect(status().isUnauthorized)
        }
    }

    "토큰을 붙여 /me를 호출하면" -  {
        "사용자 정보를 반환한다 " {
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
})