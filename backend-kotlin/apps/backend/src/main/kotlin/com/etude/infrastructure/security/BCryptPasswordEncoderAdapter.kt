package com.etude.infrastructure.security

import com.etude.domain.auth.PasswordEncoder
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder as SpringBCrypt
import org.springframework.stereotype.Component

@Component
class BCryptPasswordEncoderAdapter : PasswordEncoder {
    private val delegate = SpringBCrypt()

    override fun encode(rawPassword: String): String = delegate.encode(rawPassword)!!
    override fun matches(rawPassword: String, encodedPassword: String): Boolean =
        delegate.matches(rawPassword, encodedPassword)
}