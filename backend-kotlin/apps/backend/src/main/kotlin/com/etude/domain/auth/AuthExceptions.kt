package com.etude.domain.auth

class InvalidCredentialsException(message: String = "이메일 또는 비밀번호가 올바르지 않습니다.") : RuntimeException(message)
class InvalidTokenException(message: String = "토큰이 유효하지 않습니다.") : RuntimeException(message)
class EmailAlreadyExistsException(message: String = "이미 사용중인 이메일입니다.") : RuntimeException(message)
class UserNotFoundException(message: String = "사용자를 찾을 수 없습니다.") : RuntimeException(message)
class WrongPasswordException(message: String = "현재 비밀번호가 올바르지 않습니다.") : RuntimeException(message)