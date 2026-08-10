package com.etude.domain.auth

class InvalidCredentialsException(message: String = "이메일 또는 비밀번호가 올바르지 않습니다.") : RuntimeException(message)
class InvalidTokenException(message: String = "토큰이 유효하지 않습니다.") : RuntimeException(message)