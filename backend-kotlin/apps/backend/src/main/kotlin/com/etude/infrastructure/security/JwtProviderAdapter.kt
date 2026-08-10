package com.etude.infrastructure.security

import com.etude.domain.auth.InvalidTokenException
import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.JwtProvider
import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import io.jsonwebtoken.JwtException
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.time.Duration
import java.util.Date

@Component
class JwtProviderAdapter(
    @Value("\${etude.jwt.secret}") private val secret: String,
    @Value("\${etude.jwt.expires-hours}") private val expireHours: Long,
) : JwtProvider {
    /**
     * jjwt의 HMAC-SHA 서명은 최소 256비트 키를 요구한다.
     * 운영 JWT_SECRET은 이 길이를 만족하는 값으로 설정해야 한다 (application.yml의 dev-secret은 로컬 전용)
     */
    private val key = Keys.hmacShaKeyFor(secret.toByteArray())
    override fun generate(user: User): String {
        val now = Date()
        val expiry = Date(now.time + Duration.ofHours(expireHours).toMillis())
        return Jwts.builder()
            .claim("userId", user.id)
            .claim("name", user.name)
            .claim("email", user.email)
            .claim("role", user.role.name)
            .issuedAt(now)
            .expiration(expiry)
            .signWith(key)
            .compact()
    }

    override fun verify(token: String): JwtPayload {
        try {
            val claims = Jwts.parser().verifyWith(key).build().parseSignedClaims(token).payload
            return JwtPayload(
                userId = claims.get("userId", Integer::class.java).toLong(),
                name = claims.get("name", String::class.java),
                email = claims.get("email", String::class.java),
                role = UserRole.valueOf(claims.get("role", String::class.java)),
            )
        } catch (e: JwtException) {
            throw InvalidTokenException()
        }
    }
}