package com.etude.infrastructure.security

import com.etude.domain.auth.InvalidTokenException
import com.etude.domain.auth.JwtProvider
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpHeaders
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

const val REQUEST_ATTR_JWT_PAYLOAD = "jwtPayload"

@Component
class JwtAuthFilter(
    private val jwtProvider: JwtProvider,
) : OncePerRequestFilter() {
    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val header = request.getHeader(HttpHeaders.AUTHORIZATION) ?: ""
        val token = if (header.startsWith("Bearer ")) header.removePrefix("Bearer ") else null

        if (token != null) {
            try {
                request.setAttribute(REQUEST_ATTR_JWT_PAYLOAD, jwtProvider.verify(token))
            } catch (e: InvalidTokenException) {
                // 여기서 막지 않는다 - 토큰이 없거나 유효하지 않아도 요청 자체는 통과시키고,
                // 실제 인증이 필요한 컨트롤러/인터셉터에서 payload 유무로 401을 결정한다.
            }
        }
        filterChain.doFilter(request, response)
    }
}