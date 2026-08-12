# Phase 12 Step 1 — 인증 (ATDD)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step0b_multi_module.md](guide_phase12_step0b_multi_module.md)

대응하는 기존 Node.js 파일: `backend/src/services/auth.ts`, `backend/src/plugins/auth-guard.ts`,
`backend/src/routes/auth.routes.ts`. DB 스키마는 `backend/db/00_schema.sql`의 `user` 테이블 (변경하지 않음).

**경로 표기 안내**: Step 0b에서 프로젝트를 멀티모듈로 재구성했으므로, 이 문서에서 `domain/auth/User.kt`처럼
쓰는 경로는 전부 `backend-kotlin/apps/backend/src/main/kotlin/com/etude/domain/auth/User.kt`를
가리킵니다 (`apps/backend/src/main/kotlin/`이 생략된 표기). 패키지 루트는 `com.etude.backend`가 아니라
**`com.etude`**입니다 — 참고 템플릿(`com.loopers.domain.member`)과 동일하게 회사/프로젝트 패키지 바로
아래에 `domain`/`application`/`interfaces`/`infrastructure` 레이어가 옵니다. 앱 진입점
(`BackendKotlinApplication.kt`)과 전역 설정(`config/`)도 예외 없이 `com.etude` 바로 아래에 둡니다.
`BaseEntity`는 `modules/jpa`(패키지 `com.etude.domain`)에 이미 있으므로 이 Step에서는 import만 합니다.

## 인수 조건 (이 Step의 완료 기준)

*Node.js 원본(`auth.ts`, `auth-guard.ts`, `auth.routes.ts`)의 실제 동작이 곧 인수 조건이다 — 다만 응답
포맷은 참고 템플릿(`loopers-spring-kotlin-template`)의 `ApiResponse<T>` 공통 래퍼를 따른다 (1-8a 참고).
필드 이름/값 자체는 기존과 동일하게 유지하되, `{ data: { ... } }`로 한 겹 감싼다는 점만 다르다.*

**로그인 (`POST /auth/login`)**
- [ ] 올바른 이메일/비밀번호로 로그인 시 200 + `{ meta: { result: "SUCCESS" }, data: { token, user: { id, name, email, role } } }`
- [ ] 존재하지 않는 이메일 → 401 + `{ meta: { result: "FAIL", errorCode, message: "이메일 또는 비밀번호가 올바르지 않습니다." }, data: null }`
- [ ] 틀린 비밀번호 → 401 + 동일 에러 메시지 (이메일 존재 여부를 노출하지 않음)

**내 정보 조회 (`GET /me`)**
- [ ] 유효한 토큰으로 호출 시 200 + `{ meta: { result: "SUCCESS" }, data: { userId, name, email, role } }`
- [ ] 토큰 없이 호출 시 401 + `{ meta: { result: "FAIL", message: "인증이 필요합니다." }, data: null }`
- [ ] 유효하지 않은/만료된 토큰으로 호출 시 401 + `{ meta: { result: "FAIL", message: "토큰이 유효하지 않습니다." }, data: null }`

**관리자 권한 차단** (Step 2에서 실제 `/admin/*` 엔드포인트가 생기면 여기서 만든 `AdminInterceptor`로 검증)
- [ ] `role: member` 토큰으로 관리자 전용 경로 호출 시 403

이 조건들은 아래 1-9(통합 테스트)의 `AuthControllerTest`로 그대로 옮겨진다. 이 Step은 그 테스트가
전부 통과하면 완료다.

> **참고 — 프론트엔드는 이 Step에서 건드리지 않는다**: `ApiResponse<T>` 래퍼 도입으로 응답 형태가
> `{ token, user }`에서 `{ data: { token, user } }`로, 에러 형태가 `{ error }`에서
> `{ meta: { message } }`로 바뀐다. 하지만 프론트는 백엔드를 하나만 바라보는 구조라 도메인별로 부분
> 전환하면 임시 라우팅 프록시가 필요해진다 — 그 비용을 피하기 위해 Step 1~9는 Kotlin 백엔드만
> 완성하고 curl/MockMvc/Testcontainers로 검증한다. `frontend/src/api/auth.ts`(`loginApi`/`fetchMe`/
> `changePassword`)를 `ApiResponse` 포맷에 맞게 고치는 작업은 모든 도메인의 백엔드 전환이 끝난 뒤
> Step 10(cutover)에서 프론트 전체를 한 번에 전환할 때 함께 처리한다 (spec 문서의 "프론트엔드 연동
> 방침" 참고).

## 진행 방식

이 Step은 **ATDD 바깥 루프 + 구현-후-검증 안쪽 루프**로 진행합니다. `auth.ts`의 로그인 로직은 이미
명확히 정해져 있어 설계를 탐색할 이유가 없으므로, 도메인 로직은 TDD(레드-그린)가 아니라 "구현 먼저 작성
→ 단위 테스트로 검증" 순서로 만듭니다. 하지만 이 Step 전체가 끝났다고 판단하는 기준은 위 인수 조건을
검증하는 API 테스트(1-9)입니다. 레이어는 `domain/auth`(엔티티, 포트, 도메인 서비스) →
`application/auth`(Facade) → `infrastructure/persistence`, `infrastructure/security`(어댑터) →
`interfaces/api/auth`(컨트롤러) → 인수 테스트 순으로 바깥으로 나갑니다.

---

## 1-1. `BaseEntity` — Step 0b에서 이미 준비됨

`BaseEntity`(`id` + `createdAt`)는 Step 0b에서 `modules/jpa`의 `com.etude.domain.BaseEntity`로 이미
만들어뒀습니다. 이 Step에서는 새로 만들지 않고 import해서 씁니다:

```kotlin
import com.etude.domain.BaseEntity
```

`quest_set_access`를 포함해 이 프로젝트의 모든 엔티티는 대리키 `id`를 PK로 쓰므로 `BaseEntity`를
그대로 상속합니다 (Step 3에서 다룹니다).

---

## 1-2. `UserRole` — 별도 파일로 먼저 정의

`role` 같은 도메인 값은 `User` 엔티티 파일 안에 묻어두지 않고 독립된 파일로 분리합니다. 이후 Step에서
`JwtPayload`, 인가 로직(`AdminInterceptor` 등) 여러 곳에서 이 타입을 참조하게 되므로, 처음부터
`User.kt`에 종속되지 않는 위치에 두는 편이 관계를 파악하기 쉽습니다.

`domain/auth/UserRole.kt`:

```kotlin
package com.etude.domain.auth

// 00_schema.sql: role ENUM('member', 'admin') — enum 상수 이름을 스키마 값과 그대로 맞춘다
// (Hibernate EnumType.STRING은 상수 이름 자체를 문자열로 저장/비교하기 때문)
enum class UserRole { member, admin }
```

---

## 1-3. `User` 엔티티 — 테스트 없이 시작 (순수 데이터 구조)

`domain/auth/User.kt`. JPA 엔티티는 `00_schema.sql`의 컬럼과 1:1 대응해야 하므로, 이 단계는 테스트보다
스키마 일치가 우선입니다 (틀리면 `ddl-auto: validate`가 앱 기동 시점에 바로 잡아줍니다). `id`/`createdAt`은
`BaseEntity`가 제공하므로 여기서는 `user` 테이블 고유 컬럼만 선언합니다.

```kotlin
package com.etude.domain.auth

import com.etude.domain.BaseEntity   // modules/jpa 모듈 — 패키지가 com.etude.domain 임에 유의 (backend 아님)
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Table

@Entity
@Table(name = "user")
class User(
    @Column(nullable = false, length = 100)
    var name: String,

    @Column(nullable = false, unique = true, length = 200)
    val email: String,

    @Column(nullable = false, length = 200)
    var password: String,

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    val role: UserRole = UserRole.member,
) : BaseEntity()
```

**검증**: 아직 테스트 없이, `./gradlew compileKotlin`이 통과하는지만 확인.

---

## 1-4. `UserRepository` 포트 (도메인이 아는 것은 인터페이스뿐)

`domain/auth/UserRepository.kt` — 이 인터페이스가 "포트"입니다. `domain` 패키지는 Spring Data JPA를
직접 알지 못하고, 이 인터페이스만 압니다.

```kotlin
package com.etude.domain.auth

interface UserRepository {
    fun findByEmail(email: String): User?
    fun findById(id: Long): User?
    fun save(user: User): User
}
```

---

## 1-5. `AuthService` — 구현 후 테스트로 검증

**TDD가 아니라 "구현 먼저 + 테스트로 검증" 순서로 진행합니다.** `auth.ts`의 `login()` 로직은 이미
명확하게 정해져 있어서(이메일 조회 → 비밀번호 비교 → 토큰 발급), 테스트로 설계를 탐색할 이유가 없습니다.
먼저 협력자 인터페이스(포트)와 `AuthService`를 완성한 뒤, 그 동작이 맞는지 테스트로 검증하는 순서가
더 자연스럽고 빠릅니다. (Step 3 이후 도메인 규칙이 복잡한 로직—예: 채점 조건, 퀘스트 접근 제어—을 다룰
때는 실패하는 테스트를 먼저 쓰는 진짜 TDD를 다시 적용합니다.)

### `PasswordEncoder` 포트 (`domain/auth/PasswordEncoder.kt`)

```kotlin
package com.etude.domain.auth

interface PasswordEncoder {
    fun encode(rawPassword: String): String
    fun matches(rawPassword: String, encodedPassword: String): Boolean
}
```

### `JwtProvider` 포트 (`domain/auth/JwtProvider.kt`)

```kotlin
package com.etude.domain.auth

interface JwtProvider {
    fun generate(user: User): String
    fun verify(token: String): JwtPayload
}

data class JwtPayload(
    val userId: Long,
    val name: String,
    val email: String,
    val role: UserRole,
)
```

### 공통 예외/에러 타입 — `support/error` (참고 템플릿과 동일 구조)

컨트롤러마다 예외를 개별로 catch하지 않고, 참고 템플릿(`loopers-spring-kotlin-template`)처럼
`CoreException` + `ErrorType` + 전역 `@RestControllerAdvice`(1-8b)로 처리합니다. 이 Step에서 처음
만들지만 이후 모든 Step의 컨트롤러가 공유하는 공통 인프라이므로 도메인에 묻지 않고 별도 패키지에 둡니다.

`support/error/ErrorType.kt`

```kotlin
package com.etude.support.error

import org.springframework.http.HttpStatus

enum class ErrorType(val status: HttpStatus, val code: String, val message: String) {
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.reasonPhrase, "일시적인 오류가 발생했습니다."),
    BAD_REQUEST(HttpStatus.BAD_REQUEST, HttpStatus.BAD_REQUEST.reasonPhrase, "잘못된 요청입니다."),
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, HttpStatus.UNAUTHORIZED.reasonPhrase, "인증이 필요합니다."),
    FORBIDDEN(HttpStatus.FORBIDDEN, HttpStatus.FORBIDDEN.reasonPhrase, "권한이 없습니다."),
    NOT_FOUND(HttpStatus.NOT_FOUND, HttpStatus.NOT_FOUND.reasonPhrase, "존재하지 않는 요청입니다."),
}
```

`support/error/CoreException.kt`

```kotlin
package com.etude.support.error

class CoreException(
    val errorType: ErrorType,
    val customMessage: String? = null,
) : RuntimeException(customMessage ?: errorType.message)
```

### 도메인 예외 (`domain/auth/AuthExceptions.kt`)

도메인 예외는 `CoreException`을 직접 던지지 않고 이 Step 전용 타입을 유지합니다 — `AuthService`가
HTTP 상태 코드(`ErrorType`)를 알 필요는 없기 때문입니다. `ErrorType`으로의 변환은 컨트롤러
계층(1-8a)에서 합니다.

```kotlin
package com.etude.domain.auth

class InvalidCredentialsException(message: String = "이메일 또는 비밀번호가 올바르지 않습니다.") : RuntimeException(message)
class InvalidTokenException(message: String = "토큰이 유효하지 않습니다.") : RuntimeException(message)
```

### 응답 타입 (`domain/auth/AuthResult.kt`)

`AuthService`의 반환 타입을 서비스 파일 안에 같이 묻어두지 않고 별도 파일로 분리합니다 — 다른 곳(예:
Step 2의 관리자 컨트롤러)에서도 `UserSummary`를 재사용할 수 있고, IDE에서 타입명으로 찾을 때 파일명이
`AuthService.kt`로 나오는 혼란을 피할 수 있습니다.

```kotlin
package com.etude.domain.auth

data class LoginResult(val token: String, val user: UserSummary)
data class UserSummary(val id: Long, val name: String, val email: String, val role: UserRole)
```

### `AuthService` 구현 (`domain/auth/AuthService.kt`)

```kotlin
package com.etude.domain.auth

import org.springframework.stereotype.Service

@Service
class AuthService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtProvider: JwtProvider,
) {
    fun login(email: String, password: String): LoginResult {
        val user = userRepository.findByEmail(email) ?: throw InvalidCredentialsException()
        if (!passwordEncoder.matches(password, user.password)) throw InvalidCredentialsException()

        val token = jwtProvider.generate(user)
        return LoginResult(token, UserSummary(user.id, user.name, user.email, user.role))
    }
}
```

### 테스트로 검증 (`src/test/kotlin/com/etude/domain/auth/AuthServiceTest.kt`)

구현이 끝났으니, `UserRepository`/`PasswordEncoder`/`JwtProvider`를 MockK로 목킹해 `login()`의 세 가지
분기(성공/이메일 없음/비밀번호 불일치)가 의도대로 동작하는지 검증합니다.

```kotlin
package com.etude.domain.auth

import io.mockk.every
import io.mockk.mockk
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

class AuthServiceTest {

    private val userRepository = mockk<UserRepository>()
    private val passwordEncoder = mockk<PasswordEncoder>()
    private val jwtProvider = mockk<JwtProvider>()
    private val authService = AuthService(userRepository, passwordEncoder, jwtProvider)

    @DisplayName("이메일과 비밀번호가 맞으면 토큰과 사용자 정보를 반환한다")
    @Test
    fun loginSucceeds() {
        val user = User(name = "테스트", email = "test@okestro.com", password = "hashed", role = UserRole.member)
        every { userRepository.findByEmail("test@okestro.com") } returns user
        every { passwordEncoder.matches("password123", "hashed") } returns true
        every { jwtProvider.generate(user) } returns "signed-jwt"

        val result = authService.login("test@okestro.com", "password123")

        assertThat(result.token).isEqualTo("signed-jwt")
        assertThat(result.user.email).isEqualTo("test@okestro.com")
    }

    @DisplayName("존재하지 않는 이메일이면 예외를 던진다")
    @Test
    fun loginFailsWhenUserNotFound() {
        every { userRepository.findByEmail("unknown@okestro.com") } returns null

        assertThatThrownBy { authService.login("unknown@okestro.com", "anything") }
            .isInstanceOf(InvalidCredentialsException::class.java)
    }

    @DisplayName("비밀번호가 틀리면 예외를 던진다")
    @Test
    fun loginFailsWhenPasswordMismatch() {
        val user = User(name = "테스트", email = "test@okestro.com", password = "hashed", role = UserRole.member)
        every { userRepository.findByEmail("test@okestro.com") } returns user
        every { passwordEncoder.matches("wrong", "hashed") } returns false

        assertThatThrownBy { authService.login("test@okestro.com", "wrong") }
            .isInstanceOf(InvalidCredentialsException::class.java)
    }
}
```

**검증**: `./gradlew test --tests "*.AuthServiceTest"` — 3개 테스트 모두 통과해야 합니다.

---

## 1-5a. `AuthFacade` — `interfaces`가 `domain`을 직접 호출하지 않는다

Step 0 설계(`docs/guides/guide_phase12_step0_setup.md`의 패키지 구조)는 `interfaces →
application(Facade) → domain`으로 의존 방향을 잡았습니다. `application/`은 Facade, Command,
Info를 두는 레이어로 비워둔 채 시작했는데, 이번 Step에서 `AuthV1Controller`가 곧바로
`domain.auth.AuthService`를 주입받게 되면 이 레이어를 채우지 못하고 지나가게 됩니다 — 지금
채워둡니다.

`AuthFacade`는 `AuthV1Controller`(1-8d)가 쓰는 진입점입니다. 지금은 `AuthService.login()`을
그대로 위임하는 것 이상의 로직이 없지만, 이 얇은 계층을 두는 이유는 **컨트롤러가 도메인 서비스를
직접 알지 않게** 하기 위해서입니다 — 나중에 "로그인 시 마지막 접속 시각도 함께 기록한다"처럼
여러 도메인 서비스를 조합해야 하는 요구가 생기면, 그 조합 로직은 `AuthFacade`에만 추가하면 되고
컨트롤러나 `AuthService`는 건드리지 않습니다.

`application/auth/AuthFacade.kt`:

```kotlin
package com.etude.application.auth

import com.etude.domain.auth.AuthService
import com.etude.domain.auth.LoginResult
import org.springframework.stereotype.Component

@Component
class AuthFacade(
    private val authService: AuthService,
) {
    fun login(email: String, password: String): LoginResult = authService.login(email, password)
}
```

> `@Service`가 아니라 `@Component`를 씁니다 — `AuthFacade`는 도메인 비즈니스 로직을 담은
> 서비스가 아니라 `interfaces`와 `domain` 사이를 잇는 위임/조합 계층이라, 스프링 스테레오타입의
> 의미상 `@Service`(비즈니스 로직 계층)와 구분합니다.
>
> 테스트는 따로 만들지 않습니다 — `AuthFacade`는 위임 외 로직이 없고, `AuthService`가 이미
> `AuthServiceTest`로 검증되어 있으므로 같은 케이스를 Facade 레벨에서 다시 확인하는 건 검증
> 없는 중복입니다. Facade에 실제 로직(조합, 트랜잭션 경계 등)이 추가되는 시점에 그 로직만
> 테스트를 씁니다.

---

## 1-6. 어댑터 구현 — `infrastructure`

포트는 만들었으니 이제 실제 구현체(어댑터)를 붙입니다.

### `infrastructure/persistence/auth/UserJpaRepository.kt` (Spring Data JPA)

```kotlin
package com.etude.infrastructure.persistence.auth

import com.etude.domain.auth.User
import org.springframework.data.jpa.repository.JpaRepository

interface UserJpaRepository : JpaRepository<User, Long> {
    fun findByEmail(email: String): User?
}
```

### `infrastructure/persistence/auth/UserRepositoryImpl.kt` (포트 구현체)

```kotlin
package com.etude.infrastructure.persistence.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRepository
import org.springframework.stereotype.Repository

@Repository
class UserRepositoryImpl(
    private val jpaRepository: UserJpaRepository,
) : UserRepository {
    override fun findByEmail(email: String): User? = jpaRepository.findByEmail(email)
    override fun findById(id: Long): User? = jpaRepository.findById(id).orElse(null)
    override fun save(user: User): User = jpaRepository.save(user)
}
```

### `infrastructure/security/BCryptPasswordEncoderAdapter.kt`

```kotlin
package com.etude.infrastructure.security

import com.etude.domain.auth.PasswordEncoder
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder as SpringBCrypt
import org.springframework.stereotype.Component

@Component
class BCryptPasswordEncoderAdapter : PasswordEncoder {
    private val delegate = SpringBCrypt()

    override fun encode(rawPassword: String): String = delegate.encode(rawPassword)
    override fun matches(rawPassword: String, encodedPassword: String): Boolean =
        delegate.matches(rawPassword, encodedPassword)
}
```

### `infrastructure/security/JwtProviderAdapter.kt` (jjwt)

`application.yml`의 `etude.jwt.secret`/`expires-hours`를 읽어옵니다.

```kotlin
package com.etude.infrastructure.security

import com.etude.domain.auth.InvalidTokenException
import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.JwtProvider
import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.JwtException
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.time.Duration
import java.util.Date

@Component
class JwtProviderAdapter(
    @Value("\${etude.jwt.secret}") secret: String,
    @Value("\${etude.jwt.expires-hours}") private val expiresHours: Long,
) : JwtProvider {
    // jjwt의 HMAC-SHA 서명은 최소 256비트 키를 요구한다.
    // 운영 JWT_SECRET은 이 길이를 만족하는 값으로 설정해야 한다 (application.yml의 dev-secret은 로컬 전용).
    private val key = Keys.hmacShaKeyFor(secret.toByteArray())

    override fun generate(user: User): String {
        val now = Date()
        val expiry = Date(now.time + Duration.ofHours(expiresHours).toMillis())
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
```

> 기존 `auth.ts`의 JWT 페이로드 필드(`userId`, `name`, `email`, `role`)와 이름을 그대로 맞췄습니다 —
> 프론트엔드는 건드리지 않으므로 JSON 필드명이 달라지면 안 됩니다.

**검증**: 아직 컨트롤러가 없으니 앱을 띄워서 직접 확인할 수는 없습니다. `./gradlew build`로 컴파일 통과만 확인.

---

## 1-7. `JwtAuthFilter` — `auth-guard.ts` 대응

기존 `authMiddleware`/`adminMiddleware`(Fastify `preHandler`)를 서블릿 필터로 옮깁니다.
Spring Security를 쓰지 않으므로 일반 `OncePerRequestFilter`를 등록합니다.

### `infrastructure/security/JwtAuthFilter.kt`

```kotlin
package com.etude.infrastructure.security

import com.etude.domain.auth.InvalidTokenException
import com.etude.domain.auth.JwtProvider
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

const val REQUEST_ATTR_JWT_PAYLOAD = "jwtPayload"

@Component
class JwtAuthFilter(
    private val jwtProvider: JwtProvider,
) : OncePerRequestFilter() {

    override fun doFilterInternal(request: HttpServletRequest, response: HttpServletResponse, chain: FilterChain) {
        val header = request.getHeader("Authorization") ?: ""
        val token = if (header.startsWith("Bearer ")) header.removePrefix("Bearer ") else null

        if (token != null) {
            try {
                request.setAttribute(REQUEST_ATTR_JWT_PAYLOAD, jwtProvider.verify(token))
            } catch (e: InvalidTokenException) {
                // 여기서 막지 않는다 — 토큰이 없거나 유효하지 않아도 요청 자체는 통과시키고,
                // 실제 인증이 필요한 컨트롤러/인터셉터에서 payload 유무로 401을 결정한다.
                // (feedback.routes.ts처럼 토큰이 있으면 쓰고 없어도 되는 엔드포인트가 있기 때문)
            }
        }
        chain.doFilter(request, response)
    }
}
```

> 왜 필터에서 바로 401을 반환하지 않는가: 기존 `feedback.routes.ts`는 토큰이 있으면 `userId`를 기록하고
> 없어도 피드백 등록 자체는 허용합니다. 반대로 `/me`, `/admin/*`는 반드시 토큰이 있어야 합니다. 이 차이를
> 필터 하나로 처리하려 하지 않고, **필터는 "토큰이 있으면 검증해서 request attribute에 심어둔다"**까지만
> 하고, **인증이 필수인 경로는 인터셉터(아래 1-6)가 막습니다** — 기존 `authMiddleware`/`adminMiddleware`의
> 책임 분리를 그대로 유지하는 구조입니다.

### `config/WebConfig.kt` — 필터 등록 + 인증 인터셉터

```kotlin
package com.etude.config

import com.etude.infrastructure.security.JwtAuthFilter
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.UserRole
import com.etude.support.error.CoreException
import com.etude.support.error.ErrorType
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.HandlerInterceptor
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
class WebConfig(
    private val jwtAuthFilter: JwtAuthFilter,
) : WebMvcConfigurer {

    @Bean
    fun jwtAuthFilterRegistration(): FilterRegistrationBean<JwtAuthFilter> =
        FilterRegistrationBean(jwtAuthFilter).apply { order = 1 }

    override fun addInterceptors(registry: InterceptorRegistry) {
        registry.addInterceptor(AuthInterceptor())
            .addPathPatterns("/me", "/me/password", "/admin/**", "/quest-sets/**", "/progress", "/leaderboard")
        registry.addInterceptor(AdminInterceptor())
            .addPathPatterns("/admin/**")
    }
}

class AuthInterceptor : HandlerInterceptor {
    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        if (request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) == null) {
            throw CoreException(ErrorType.UNAUTHORIZED, "인증이 필요합니다.")
        }
        return true
    }
}

class AdminInterceptor : HandlerInterceptor {
    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        val payload = request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as? JwtPayload
        if (payload?.role != UserRole.admin) {
            throw CoreException(ErrorType.FORBIDDEN, "관리자 권한이 필요합니다.")
        }
        return true
    }
}
```

> 인터셉터가 응답을 직접 쓰지 않고 `CoreException`을 던지는 이유: Spring MVC는 인터셉터의
> `preHandle`에서 던진 예외도 `@RestControllerAdvice`(1-8b의 `ApiControllerAdvice`)까지 전파합니다.
> 그래서 401/403 응답도 컨트롤러 예외와 동일하게 `ApiResponse` 포맷으로 나가고, 응답 바디를 여기서
> 직접 조립할 필요가 없습니다.

> 경로 목록(`addPathPatterns`)은 이후 Step에서 quest/progress/feedback 컨트롤러를 추가하며 계속
> 늘어납니다. 지금은 Step 1~2에서 쓰는 경로만 등록하고, 각 Step에서 자신이 추가한 경로를 여기에 보탭니다.

**검증**: 아직 컨트롤러가 없어 인터셉터가 실제로 동작하는 걸 보려면 1-6까지 마쳐야 합니다.

---

## 1-8. `AuthController` — `auth.routes.ts` 대응

참고 템플릿(`loopers-spring-kotlin-template`)의 컨벤션을 따라 컨트롤러를 **ApiSpec(인터페이스) +
Controller(구현체)** 로 분리하고, 모든 응답을 공통 `ApiResponse<T>`로 감쌉니다. ApiSpec은 Swagger
문서화(`@Operation`)를 전담하고, Controller는 실제 라우팅/구현만 담당합니다.

### 1-8a. `interfaces/api/ApiResponse.kt` — 공통 응답 래퍼

Step 1에서 처음 만들지만 이후 모든 컨트롤러가 공유하는 공통 타입이라 `auth` 패키지가 아니라
`interfaces/api` 루트에 둡니다.

```kotlin
package com.etude.interfaces.api

data class ApiResponse<T>(
    val meta: Metadata,
    val data: T?,
) {
    data class Metadata(
        val result: Result,
        val errorCode: String?,
        val message: String?,
    ) {
        enum class Result { SUCCESS, FAIL }

        companion object {
            fun success() = Metadata(Result.SUCCESS, null, null)
            fun fail(errorCode: String, errorMessage: String) = Metadata(Result.FAIL, errorCode, errorMessage)
        }
    }

    companion object {
        fun success(): ApiResponse<Any> = ApiResponse(Metadata.success(), null)
        fun <T> success(data: T? = null) = ApiResponse(Metadata.success(), data)
        fun fail(errorCode: String, errorMessage: String): ApiResponse<Any?> =
            ApiResponse(meta = Metadata.fail(errorCode = errorCode, errorMessage = errorMessage), data = null)
    }
}
```

### 1-8b. `interfaces/api/ApiControllerAdvice.kt` — 전역 예외 처리

컨트롤러 안에서 개별 `try/catch`를 하지 않고, `AuthService`가 던지는 도메인 예외를 여기서 한 곳에
모아 `ApiResponse.fail(...)`로 변환합니다. `InvalidCredentialsException`/`InvalidTokenException`을
`CoreException`으로 감싸지 않고 직접 매핑하는 이유는, 이 두 예외가 이미 이 Step에서만 쓰는 명확한
의미를 가지고 있어서 `CoreException`으로 우회할 필요가 없기 때문입니다. 이후 Step에서 새 도메인
예외가 생기면 이 클래스에 `@ExceptionHandler`를 하나씩 추가합니다.

```kotlin
package com.etude.interfaces.api

import com.etude.domain.auth.InvalidCredentialsException
import com.etude.domain.auth.InvalidTokenException
import com.etude.support.error.CoreException
import com.etude.support.error.ErrorType
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class ApiControllerAdvice {
    private val log = LoggerFactory.getLogger(ApiControllerAdvice::class.java)

    @ExceptionHandler
    fun handle(e: CoreException): ResponseEntity<ApiResponse<*>> {
        log.warn("CoreException : {}", e.customMessage ?: e.message)
        return failureResponse(e.errorType.status, e.errorType.code, e.customMessage ?: e.errorType.message)
    }

    @ExceptionHandler
    fun handle(e: InvalidCredentialsException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.UNAUTHORIZED, ErrorType.UNAUTHORIZED.code, e.message!!)

    @ExceptionHandler
    fun handle(e: InvalidTokenException): ResponseEntity<ApiResponse<*>> =
        failureResponse(HttpStatus.UNAUTHORIZED, ErrorType.UNAUTHORIZED.code, e.message!!)

    @ExceptionHandler
    fun handle(e: Exception): ResponseEntity<ApiResponse<*>> {
        log.error("Unhandled exception", e)
        return failureResponse(HttpStatus.INTERNAL_SERVER_ERROR, ErrorType.INTERNAL_ERROR.code, ErrorType.INTERNAL_ERROR.message)
    }

    private fun failureResponse(status: HttpStatus, errorCode: String, message: String): ResponseEntity<ApiResponse<*>> =
        ResponseEntity(ApiResponse.fail(errorCode = errorCode, errorMessage = message), status)
}
```

ApiSpec의 `@Operation`/`@Tag` 어노테이션을 쓰려면 `apps/backend/build.gradle.kts`의 `dependencies`에
springdoc 의존성을 추가해야 합니다:

```kotlin
implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.7.0")
```

> `2.6.0`이 아니라 `2.7.0`을 쓰는 이유는 Step 3에서 QueryDSL을 도입할 때 밝혀집니다 — springdoc
> `2.6.0`은 클래스패스에 QueryDSL(`querydsl-jpa`)이 있으면 API 파라미터 자동 문서화용 빈
> (`QuerydslPredicateOperationCustomizer`)을 자동으로 켜는데, 이 빈이 참조하는
> `spring-data-commons`의 API가 Spring Boot 4.1(최신 버전)의 실제 `spring-data-commons`와
> 어긋나 `ClassNotFoundException`으로 애플리케이션 컨텍스트 로딩이 실패합니다. `2.7.0`은 이
> 버전대에 맞춰 이 문제가 없으므로, Step 3에 가서 버전을 다시 올리지 않도록 지금부터 `2.7.0`으로
> 시작합니다.

### 1-8c. `interfaces/api/auth/AuthV1ApiSpec.kt` — Swagger 인터페이스

```kotlin
package com.etude.interfaces.api.auth

import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.LoginResult
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.servlet.http.HttpServletRequest

@Tag(name = "Auth V1 API", description = "인증 관련 API 입니다.")
interface AuthV1ApiSpec {
    @Operation(summary = "로그인", description = "이메일/비밀번호로 로그인하고 토큰을 발급받습니다.")
    fun login(request: LoginRequest): ApiResponse<LoginResult>

    @Operation(summary = "내 정보 조회", description = "토큰으로 현재 로그인한 사용자 정보를 조회합니다.")
    fun me(request: HttpServletRequest): ApiResponse<JwtPayload>
}
```

### 1-8d. `interfaces/api/auth/AuthV1Controller.kt` — 구현체

```kotlin
package com.etude.interfaces.api.auth

import com.etude.application.auth.AuthFacade
import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.LoginResult
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import com.etude.interfaces.api.ApiResponse
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.Valid
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.*

data class LoginRequest(
    @field:NotBlank @field:Email val email: String,
    @field:NotBlank val password: String,
)

@RestController
class AuthV1Controller(
    private val authFacade: AuthFacade,
) : AuthV1ApiSpec {
    @PostMapping("/auth/login")
    override fun login(@Valid @RequestBody request: LoginRequest): ApiResponse<LoginResult> =
        ApiResponse.success(authFacade.login(request.email, request.password))

    @GetMapping("/me")
    override fun me(request: HttpServletRequest): ApiResponse<JwtPayload> =
        ApiResponse.success(request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload)
}
```

> `me`는 `AuthFacade`를 거치지 않습니다 — 도메인 서비스 호출 없이 요청 속성(JWT 인터셉터가
> 이미 검증해 둔 `JwtPayload`)만 읽어 반환하는 순수 컨트롤러 로직이라, 위임할 도메인 로직
> 자체가 없기 때문입니다. Facade는 "컨트롤러가 도메인 서비스를 부를 때" 거치는 계층이지, 모든
> 컨트롤러 메서드가 예외 없이 거쳐야 하는 관문은 아닙니다.
>
> 실패 응답은 컨트롤러가 아니라 `ApiControllerAdvice`(1-8b)가 만듭니다. `AuthService.login()`이
> `InvalidCredentialsException`을 던지면 `ApiControllerAdvice`가 잡아 401 + `ApiResponse.fail(...)`로
> 변환하므로, 컨트롤러 메서드 안에는 `try/catch`가 없습니다.
>
> `LoginResult`가 `ApiResponse.data`에 담겨 그대로 JSON으로 직렬화되면
> `{"meta":{"result":"SUCCESS","errorCode":null,"message":null},"data":{"token":"...","user":{"id":..,"name":..,"email":..,"role":..}}}`가
> 됩니다. 기존 `auth.ts`의 `login()` 응답과 필드 이름/값은 같지만 `data`로 한 겹 더 감싸져 있다는 점이
> 다릅니다 — 프론트엔드 수정이 필요합니다 (인수 조건 섹션의 경고 참고).

`/me/password`(본인 비밀번호 변경)는 Step 2(user/admin)에서 `changeOwnPassword` 로직과 함께 추가합니다 —
이 컨트롤러에 지금 당장 붙이지 않아도 됩니다.

---

## 1-9. 통합 테스트 — Testcontainers로 실제 요청까지 검증

다음 의존성이 아직 없어 `apps/backend/build.gradle.kts`의 `dependencies`에 추가해야 합니다:

```kotlin
// MockMvc(@AutoConfigureMockMvc) — Spring Boot 4.x부터 spring-boot-starter-test에서 분리됨
testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
testImplementation("org.testcontainers:junit-jupiter")
testImplementation("org.testcontainers:mariadb")
testImplementation("org.springframework.boot:spring-boot-testcontainers")
```

- `spring-boot-testcontainers`가 `@ServiceConnection` 어노테이션을 제공합니다.
- `spring-boot-starter-webmvc-test`가 `@AutoConfigureMockMvc`를 제공합니다. 루트 `build.gradle.kts`가
  이미 물고 있는 `spring-boot-starter-test`에는 **더 이상 포함돼 있지 않습니다** — Spring Boot 4.0부터
  `@SpringBootTest`가 MockMvc를 자동으로 지원하지 않게 되면서 기술별 테스트 스타터
  (`spring-boot-starter-<technology>-test`)로 쪼개졌기 때문입니다. 패키지 경로도 바뀌어서 아래
  `import`가 `org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc`가 아니라
  `org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc`인 점에 주의합니다.
  루트 `build.gradle.kts`는 `testcontainers-bom`만 import(버전 관리)해뒀을 뿐 testcontainers 실제
  라이브러리는 추가하지 않았으므로 이것도 함께 추가합니다.

### 1-9a. 스키마 초기화 — Testcontainers는 빈 DB에서 시작한다

`ddl-auto: validate`(CLAUDE.md의 SSOT 원칙에 따라 JPA가 스키마를 만들지 않음, 1-1 참고)인 채로
Testcontainers를 쓰면, 컨테이너가 갓 띄운 MariaDB는 완전히 빈 상태라 `Schema validation: missing
table [user]` 에러가 납니다. `backend/db/00_schema.sql`이 스키마의 SSOT이므로, 이 SQL을
`backend-kotlin` 쪽으로 옮겨서 테스트가 참조하게 합니다.

**1) `backend/db/*.sql` → `apps/backend/src/main/resources/db/*.sql`로 이관**

Node.js 마이그레이션이 끝나면 `backend/`는 어차피 사라질 예정이므로, 스키마 SSOT를 미리
`backend-kotlin` 쪽으로 옮겨둡니다 (git 이력 보존을 위해 `git mv` 사용):

```bash
git mv backend/db backend-kotlin/apps/backend/src/main/resources/db
```

옮긴 뒤에는 이 SQL을 `docker-entrypoint-initdb.d`로 마운트하던 두 compose 파일의 경로도 함께
고쳐야 실제 로컬/운영 DB 초기화가 깨지지 않습니다:
- `backend/docker-compose.yml`: `./db:/docker-entrypoint-initdb.d` →
  `../backend-kotlin/apps/backend/src/main/resources/db:/docker-entrypoint-initdb.d`
- `deploy/docker-compose.prod.yml`: `./backend/db:/docker-entrypoint-initdb.d` →
  `./backend-kotlin/apps/backend/src/main/resources/db:/docker-entrypoint-initdb.d`

`main/resources/db/`에 두면 Gradle이 기본적으로 test 클래스패스에도 포함시켜주므로 별도
`sourceSets` 설정은 필요 없습니다.

**2) `application-test.yaml`에 스키마 초기화 설정 추가**

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
    defer-datasource-initialization: false   # SQL 스크립트를 EntityManagerFactory보다 먼저 실행
  sql:
    init:
      mode: always                            # 외부 DB(MariaDB)는 기본값이 never라 명시 필요
      schema-locations: classpath:db/00_schema.sql

etude:
  jwt:
    secret: test-secret-must-be-at-least-256-bits-long-for-hmac-sha
    expires-hours: 24
```

- `spring.sql.init.mode`는 내장(H2 등) DB에서만 기본으로 켜집니다. MariaDB 같은 외부 DB는
  `always`로 명시하지 않으면 조용히 꺼진 채로 남아 스크립트가 안 돌고, `ddl-auto: validate`만 남아서
  똑같은 "missing table" 에러가 재현됩니다.
- `defer-datasource-initialization`은 이름과 반대로 동작하는 것처럼 헷갈리기 쉬운데, **`true`로
  두면 SQL 스크립트 실행이 EntityManagerFactory 생성 "이후"로 미뤄져서** `validate`가 스크립트보다
  먼저 실행되는 문제가 생깁니다. 여기서는 `false`(기본값)여야 SQL이 먼저 실행되고 그다음
  `validate`가 통과합니다.
- `etude.jwt.secret`을 `test-secret`처럼 짧게 두면 별개로 `WeakKeyException`이 납니다. HMAC-SHA
  서명은 최소 256비트(32바이트) 키를 요구하므로(`JwtProviderAdapter`의 주석 참고) 테스트용 시크릿도
  충분히 길게 잡습니다.

### 1-9b. 공통 테스트 베이스 클래스 — `@Testcontainers` 중복 제거

`AuthControllerTest`뿐 아니라 `BackendKotlinApplicationTests`(스캐폴딩이 기본 생성한 `contextLoads`
테스트, 1-9c 참고)도 `@SpringBootTest`로 전체 컨텍스트를 띄우는 통합 테스트라 동일한 Testcontainers
설정이 필요합니다. `@Testcontainers` + `MariaDBContainer` + `@ServiceConnection` + `@ActiveProfiles`
조합을 테스트 클래스마다 반복하지 않도록, 공통 베이스 클래스 하나로 뽑아 상속하게 합니다.

`src/test/kotlin/com/etude/support/IntegrationTest.kt`

```kotlin
package com.etude.support

import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.test.context.ActiveProfiles
import org.testcontainers.containers.MariaDBContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers

@Testcontainers
@SpringBootTest
@ActiveProfiles("test")
abstract class IntegrationTest {
    companion object {
        @Container
        @ServiceConnection
        val mariaDb = MariaDBContainer("mariadb:11")
    }
}
```

- `abstract class`로 선언해 이 클래스 자체는 테스트로 인식되지 않게 합니다.
- `companion object`의 `@Container` 필드는 서브클래스마다 새로 만들어지지 않고 하나로 공유되므로,
  이 베이스 클래스를 상속하는 모든 통합 테스트가 컨테이너를 재사용합니다(클래스마다 새로 띄우지
  않아 테스트 스위트 전체 실행 시간이 줄어듭니다).
- `@ActiveProfiles("test")`를 여기 한 번만 선언하면 됩니다 — 이게 빠지면 `application-test.yaml`이
  전혀 로드되지 않고 `application.yaml`(운영 설정, `dev-secret`/`localhost:3306/etude`)을 그대로
  읽어 위 1-9a에서 겪은 에러들이 그대로 재현됩니다.

`AuthControllerTest`는 `MockMvc`가 추가로 필요하므로, `@AutoConfigureMockMvc`를 얹은 서브클래스로
작성합니다:

`src/test/kotlin/com/etude/interfaces/api/auth/AuthControllerTest.kt`

```kotlin
package com.etude.interfaces.api.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.support.IntegrationTest
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*

@AutoConfigureMockMvc
class AuthControllerTest : IntegrationTest() {

    @Autowired lateinit var mockMvc: MockMvc
    @Autowired lateinit var userJpaRepository: UserJpaRepository

    @BeforeEach
    fun setUp() {
        userJpaRepository.deleteAll()
        userJpaRepository.save(
            User(
                name = "테스트",
                email = "test@okestro.com",
                // BCryptPasswordEncoder.encode()는 Java API라 Kotlin이 반환 타입을 String!(플랫폼
                // 타입)로 본다. non-null String을 기대하는 User.password에 대입 시 타입 불일치로
                // 잡히는데, 실제로 null이 반환될 일은 없으므로 !!로 단언한다.
                password = BCryptPasswordEncoder().encode("password123")!!,
                role = UserRole.member,
            )
        )
    }

    @DisplayName("로그인 성공 시 토큰을 반환한다")
    @Test
    fun loginReturnsToken() {
        mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"test@okestro.com","password":"password123"}""")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.token").exists())
            .andExpect(jsonPath("$.data.user.email").value("test@okestro.com"))
    }

    @DisplayName("잘못된 비밀번호면 401을 반환한다")
    @Test
    fun loginFailsWithWrongPassword() {
        mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"test@okestro.com","password":"wrong"}""")
        )
            .andExpect(status().isUnauthorized)
    }

    @DisplayName("토큰 없이 me 호출하면 401을 반환한다")
    @Test
    fun meFailsWithoutToken() {
        mockMvc.perform(get("/me")).andExpect(status().isUnauthorized)
    }

    @DisplayName("토큰을 붙이면 me가 사용자 정보를 반환한다")
    @Test
    fun meReturnsUserWithToken() {
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
```

> `@ServiceConnection`이 Testcontainers가 띄운 MariaDB 접속 정보를 Spring Boot의 datasource 설정에
> 자동으로 주입해줍니다 — `application-test.yml`에 URL/계정을 직접 쓸 필요가 없습니다. 이 테스트를 실행하려면
> Docker(Colima)가 떠 있어야 합니다.

### 1-9c. `BackendKotlinApplicationTests` — 스캐폴딩 기본 테스트도 격리

프로젝트 생성 시 자동으로 만들어지는 `contextLoads` 테스트도 `@SpringBootTest`로 전체 컨텍스트를
띄우므로 위와 동일한 문제(운영 설정을 그대로 읽어 JWT 키/DB 연결 실패)를 겪습니다. 지우지 않고
`IntegrationTest`를 상속시켜 고칩니다 — 이 테스트는 개별 기능 테스트가 놓치는 "빈 조립 자체가
깨지는" 전역적인 실수(순환 의존, 설정 누락 등)를 가장 값싸게 잡아주는 안전망이라 유지할 가치가
있습니다.

`src/test/kotlin/com/etude/BackendKotlinApplicationTests.kt`

```kotlin
package com.etude

import com.etude.support.IntegrationTest
import org.junit.jupiter.api.Test

class BackendKotlinApplicationTests : IntegrationTest() {
    @Test
    fun contextLoads() {
    }
}
```

**검증**:
```bash
./gradlew test --tests "*.AuthServiceTest" --tests "*.AuthControllerTest" --tests "*.BackendKotlinApplicationTests"
```
4개 통합 테스트(`AuthControllerTest`) + 3개 단위 테스트(`AuthServiceTest`) + `contextLoads` 모두
통과해야 합니다.

---

## 1-10. 수동 검증 (기존 Node 백엔드와 비교)

```bash
./gradlew bootRun
```

```bash
# 로그인
curl -X POST localhost:3001/auth/login -H "Content-Type: application/json" \
  -d '{"email":"test@okestro.com","password":"password123"}'
# → {"meta":{"result":"SUCCESS","errorCode":null,"message":null},
#    "data":{"token":"eyJ...", "user":{"id":1,"name":"테스트","email":"test@okestro.com","role":"member"}}}

# 토큰으로 /me
curl localhost:3001/me -H "Authorization: Bearer <위 토큰>"
# → {"meta":{"result":"SUCCESS","errorCode":null,"message":null},
#    "data":{"userId":1,"name":"테스트","email":"test@okestro.com","role":"member"}}

# 토큰 없이 /me
curl -i localhost:3001/me
# → 401 {"meta":{"result":"FAIL","errorCode":"Unauthorized","message":"인증이 필요합니다."},"data":null}
```

기존 `backend/`(Node.js, 포트를 다르게 띄우거나 잠시 내려두고 비교)와는 `data`/`meta`로 감싸진 형태가
다릅니다 — `data` 안의 필드명/값만 기존과 동일한지 대조합니다.

---

## 완료 기준

- `AuthServiceTest`(단위, MockK) 3개 통과
- `AuthControllerTest`(통합, Testcontainers) 4개 통과
- `/auth/login`, `/me` curl 검증에서 `data` 필드가 기존 Node.js 백엔드와 동일
- 토큰 없이 `/me` 호출 시 401, 잘못된 비밀번호로 로그인 시 401

프론트엔드(`frontend/src/api/auth.ts`)는 이 Step에서 건드리지 않는다 — 모든 도메인의 백엔드 전환이
끝난 뒤 Step 10(cutover)에서 프론트 전체를 `ApiResponse` 포맷에 맞게 한 번에 전환한다.

다음은 Step 2 — `user`/`admin` (계정 생성, 비밀번호 초기화/변경).
