package com.etude.support

import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post

object TestAuth {

    fun loginAndGetToken(mockMvc: MockMvc, email: String, password: String): String {
        val response = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"$email","password":"$password"}""")
        ).andReturn().response.contentAsString
        return Regex(""""token":"([^"]+)"""").find(response)!!.groupValues[1]
    }

}
