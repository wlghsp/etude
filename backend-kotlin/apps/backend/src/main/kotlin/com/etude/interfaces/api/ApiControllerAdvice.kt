package com.etude.interfaces.api

import com.etude.domain.auth.*
import com.etude.domain.quest.QuestSetAccessDeniedException
import com.etude.domain.quest.QuestSetNotFoundException
import com.etude.support.error.CoreException
import com.etude.support.error.ErrorType
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class ApiControllerAdvice {

    private val log = LoggerFactory.getLogger(ApiControllerAdvice::class.java)

    @ExceptionHandler
    fun handle(e: CoreException): ResponseEntity<ApiResponse<*>> {
        log.warn("CoreException: {}", e.customMessage ?: e.message)
        return failureResponse(e.errorType.status, e.errorType.code, e.customMessage ?: e.errorType.message)
    }

    @ExceptionHandler
    fun handle(e: EmailAlreadyExistsException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.CONFLICT, ErrorType.CONFLICT.code, e.message!!)
    @ExceptionHandler
    fun handle(e: UserNotFoundException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.CONFLICT, ErrorType.CONFLICT.code, e.message!!)
    @ExceptionHandler
    fun handle(e: WrongPasswordException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.UNAUTHORIZED, ErrorType.UNAUTHORIZED.code, e.message!!)
    @ExceptionHandler
    fun handle(e: InvalidCredentialsException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.UNAUTHORIZED, ErrorType.UNAUTHORIZED.code, e.message!!)
    @ExceptionHandler
    fun handle(e: InvalidTokenException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.UNAUTHORIZED, ErrorType.UNAUTHORIZED.code, e.message!!)
    @ExceptionHandler
    fun handle(e: Exception): ResponseEntity<ApiResponse<*>> {
        log.error("UnhandledException", e)
        return failureResponse(HttpStatus.INTERNAL_SERVER_ERROR, ErrorType.INTERNAL_SERVER_ERROR.code, ErrorType.INTERNAL_SERVER_ERROR.message)
    }

    // Quest
    @ExceptionHandler
    fun handle(e: QuestSetAccessDeniedException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.FORBIDDEN, ErrorType.FORBIDDEN.code, e.message!!)
    @ExceptionHandler
    fun handle(e: QuestSetNotFoundException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.NOT_FOUND, ErrorType.NOT_FOUND.code, e.message!!)

    @ExceptionHandler
    fun handle(e: MethodArgumentNotValidException): ResponseEntity<ApiResponse<*>> {
        val message = e.bindingResult?.fieldErrors?.firstOrNull()?.defaultMessage ?: "잘못된 요청입니다."
        return failureResponse(HttpStatus.BAD_REQUEST, ErrorType.BAD_REQUEST.code, message)
    }

    private fun failureResponse(status: HttpStatus, errorCode: String, message: String): ResponseEntity<ApiResponse<*>> =
        ResponseEntity(ApiResponse.fail(errorCode = errorCode, errorMessage = message), status)

}