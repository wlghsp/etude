package com.etude.infrastructure.security

import com.etude.domain.auth.JwtPayload
import com.etude.support.error.CoreException
import com.etude.support.error.ErrorType
import org.springframework.core.MethodParameter
import org.springframework.web.bind.support.WebDataBinderFactory
import org.springframework.web.context.request.NativeWebRequest
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.method.support.ModelAndViewContainer

class LoginUserArgumentResolver : HandlerMethodArgumentResolver {
    override fun supportsParameter(parameter: MethodParameter): Boolean =
        parameter.hasParameterAnnotation(LoginUser::class.java) && parameter.parameterType == JwtPayload::class.java

    override fun resolveArgument(
        parameter: MethodParameter,
        mavContainer: ModelAndViewContainer?,
        webRequest: NativeWebRequest,
        binderFactory: WebDataBinderFactory?
    ): Any {
        val payload = webRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD, NativeWebRequest.SCOPE_REQUEST)
        return payload as? JwtPayload
            ?: throw CoreException(ErrorType.UNAUTHORIZED, "인증이 필요합니다.")
    }
}