package com.etude.config

import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.security.JwtAuthFilter
import com.etude.infrastructure.security.LoginUserArgumentResolver
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import com.etude.support.error.CoreException
import com.etude.support.error.ErrorType
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.servlet.HandlerInterceptor
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
class WebConfig(
    private val jwtAuthFilter: JwtAuthFilter,
) : WebMvcConfigurer {

    @Bean
    fun jwtAuthFilterRegistration(): FilterRegistrationBean<JwtAuthFilter> = FilterRegistrationBean(jwtAuthFilter).apply { order = 1 }

    override fun addInterceptors(registry: InterceptorRegistry) {
        registry.addInterceptor(AuthInterceptor())
            .addPathPatterns("/me", "/me/password", "/admin/**", "/quest-sets/**", "/progress", "/leaderboard")
        registry.addInterceptor(AdminInterceptor())
            .addPathPatterns("/admin/**")
    }

    override fun addArgumentResolvers(resolvers: MutableList<HandlerMethodArgumentResolver>) {
        resolvers.add(LoginUserArgumentResolver())
    }
}

class AuthInterceptor : HandlerInterceptor {
    override fun preHandle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        handler: Any
    ): Boolean {
        if (request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) == null) {
            throw CoreException(ErrorType.UNAUTHORIZED, "인증이 필요합니다.")
        }
        return true
    }
}

class AdminInterceptor : HandlerInterceptor {
    override fun preHandle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        handler: Any
    ): Boolean {
        val payload = request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as? JwtPayload
        if (payload?.role != UserRole.admin) {
           throw CoreException(ErrorType.FORBIDDEN, "관리자 권한이 필요합니다.")
        }
        return true
    }
}