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

*Node.js 원본(`auth.ts`, `auth-guard.ts`, `auth.routes.ts`)의 실제 동작이 곧 인수 조건이다 — 새로
설계할 필요 없이 "기존과 동일하게 동작하는가"만 확인하면 된다.*

**로그인 (`POST /auth/login`)**
- [ ] 올바른 이메일/비밀번호로 로그인 시 200 + `{ token, user: { id, name, email, role } }`
- [ ] 존재하지 않는 이메일 → 401 + `{ error: "이메일 또는 비밀번호가 올바르지 않습니다." }`
- [ ] 틀린 비밀번호 → 401 + 동일 에러 메시지 (이메일 존재 여부를 노출하지 않음)

**내 정보 조회 (`GET /me`)**
- [ ] 유효한 토큰으로 호출 시 200 + `{ userId, name, email, role }`
- [ ] 토큰 없이 호출 시 401 + `{ error: "인증이 필요합니다." }`
- [ ] 유효하지 않은/만료된 토큰으로 호출 시 401 + `{ error: "토큰이 유효하지 않습니다." }`

**관리자 권한 차단** (Step 2에서 실제 `/admin/*` 엔드포인트가 생기면 여기서 만든 `AdminInterceptor`로 검증)
- [ ] `role: member` 토큰으로 관리자 전용 경로 호출 시 403

이 조건들은 아래 1-9(통합 테스트)의 `AuthControllerTest`로 그대로 옮겨진다. 이 Step은 그 테스트가
전부 통과하면 완료다.

## 진행 방식

이 Step은 **ATDD 바깥 루프 + 구현-후-검증 안쪽 루프**로 진행합니다. `auth.ts`의 로그인 로직은 이미
명확히 정해져 있어 설계를 탐색할 이유가 없으므로, 도메인 로직은 TDD(레드-그린)가 아니라 "구현 먼저 작성
→ 단위 테스트로 검증" 순서로 만듭니다. 하지만 이 Step 전체가 끝났다고 판단하는 기준은 위 인수 조건을
검증하는 API 테스트(1-9)입니다. 레이어는 `domain/auth`(엔티티, 포트, 도메인 서비스) →
`infrastructure/persistence`, `infrastructure/security`(어댑터) → `interfaces/api/auth`(컨트롤러) →
인수 테스트 순으로 바깥으로 나갑니다.

---

## 1-1. `BaseEntity` — Step 0b에서 이미 준비됨

`BaseEntity`(`id` + `createdAt`)는 Step 0b에서 `modules/jpa`의 `com.etude.domain.BaseEntity`로 이미
만들어뒀습니다. 이 Step에서는 새로 만들지 않고 import해서 씁니다:

```kotlin
import com.etude.domain.BaseEntity
```

`quest_set_access`처럼 PK가 단일 `id`가 아니라 복합키인 테이블은 이 `BaseEntity`를 쓰지 않고
엔티티를 직접 작성합니다 (Step 3에서 다룹니다).

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

### 도메인 예외 (`domain/auth/AuthExceptions.kt`)

```kotlin
package com.etude.domain.auth

class InvalidCredentialsException(message: String = "이메일 또는 비밀번호가 올바르지 않습니다.") : RuntimeException(message)
class InvalidTokenException(message: String = "토큰이 유효하지 않습니다.") : RuntimeException(message)
```

### `AuthService` 구현 (`domain/auth/AuthService.kt`)

```kotlin
package com.etude.domain.auth

import org.springframework.stereotype.Service

data class LoginResult(val token: String, val user: UserSummary)
data class UserSummary(val id: Long, val name: String, val email: String, val role: UserRole)

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
            response.status = 401
            response.contentType = "application/json;charset=UTF-8"
            response.writer.write("""{"error":"인증이 필요합니다."}""")
            return false
        }
        return true
    }
}

class AdminInterceptor : HandlerInterceptor {
    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        val payload = request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as? JwtPayload
        if (payload?.role != UserRole.admin) {
            response.status = 403
            response.contentType = "application/json;charset=UTF-8"
            response.writer.write("""{"error":"관리자 권한이 필요합니다."}""")
            return false
        }
        return true
    }
}
```

> 경로 목록(`addPathPatterns`)은 이후 Step에서 quest/progress/feedback 컨트롤러를 추가하며 계속
> 늘어납니다. 지금은 Step 1~2에서 쓰는 경로만 등록하고, 각 Step에서 자신이 추가한 경로를 여기에 보탭니다.

**검증**: 아직 컨트롤러가 없어 인터셉터가 실제로 동작하는 걸 보려면 1-6까지 마쳐야 합니다.

---

## 1-8. `AuthController` — `auth.routes.ts` 대응

`interfaces/api/auth/AuthController.kt`

```kotlin
package com.etude.interfaces.api.auth

import com.etude.domain.auth.AuthService
import com.etude.domain.auth.InvalidCredentialsException
import com.etude.domain.auth.JwtPayload
import com.etude.domain.auth.LoginResult
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

data class LoginRequest(
    @field:NotBlank @field:Email val email: String,
    @field:NotBlank val password: String,
)

@RestController
class AuthController(
    private val authService: AuthService,
) {
    @PostMapping("/auth/login")
    fun login(@RequestBody request: LoginRequest): ResponseEntity<Any> =
        try {
            ResponseEntity.ok(authService.login(request.email, request.password))
        } catch (e: InvalidCredentialsException) {
            ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(mapOf("error" to e.message))
        }

    @GetMapping("/me")
    fun me(request: HttpServletRequest): JwtPayload =
        request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
}
```

> `LoginResult`가 그대로 JSON으로 직렬화되면 `{"token": "...", "user": {"id":.., "name":.., "email":.., "role":..}}`가
> 되어 기존 `auth.ts`의 `login()` 반환 형태와 동일합니다.

`/me/password`(본인 비밀번호 변경)는 Step 2(user/admin)에서 `changeOwnPassword` 로직과 함께 추가합니다 —
이 컨트롤러에 지금 당장 붙이지 않아도 됩니다.

---

## 1-9. 통합 테스트 — Testcontainers로 실제 요청까지 검증

`src/test/kotlin/com/etude/backend/interfaces/api/auth/AuthControllerTest.kt`

```kotlin
package com.etude.interfaces.api.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.ninjasquad.springmockk.MockkBean
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*
import org.testcontainers.containers.MariaDBContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers

@Testcontainers
@SpringBootTest
@AutoConfigureMockMvc
class AuthControllerTest {

    companion object {
        @Container
        @ServiceConnection
        val mariaDb = MariaDBContainer("mariadb:11")
    }

    @Autowired lateinit var mockMvc: MockMvc
    @Autowired lateinit var userJpaRepository: UserJpaRepository

    @BeforeEach
    fun setUp() {
        userJpaRepository.deleteAll()
        userJpaRepository.save(
            User(
                name = "테스트",
                email = "test@okestro.com",
                password = BCryptPasswordEncoder().encode("password123"),
                role = UserRole.member,
            )
        )
    }

    @Test
    fun `로그인 성공 시 토큰을 반환한다`() {
        mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"test@okestro.com","password":"password123"}""")
        )
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.token").exists())
            .andExpect(jsonPath("$.user.email").value("test@okestro.com"))
    }

    @Test
    fun `잘못된 비밀번호면 401을 반환한다`() {
        mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"test@okestro.com","password":"wrong"}""")
        )
            .andExpect(status().isUnauthorized)
    }

    @Test
    fun `토큰 없이 me 호출하면 401을 반환한다`() {
        mockMvc.perform(get("/me")).andExpect(status().isUnauthorized)
    }

    @Test
    fun `토큰을 붙이면 me가 사용자 정보를 반환한다`() {
        val loginResponse = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"test@okestro.com","password":"password123"}""")
        ).andReturn().response.contentAsString
        val token = Regex(""""token":"([^"]+)"""").find(loginResponse)!!.groupValues[1]

        mockMvc.perform(get("/me").header("Authorization", "Bearer $token"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.email").value("test@okestro.com"))
    }
}
```

> `@ServiceConnection`이 Testcontainers가 띄운 MariaDB 접속 정보를 Spring Boot의 datasource 설정에
> 자동으로 주입해줍니다 — `application-test.yml`에 URL/계정을 직접 쓸 필요가 없습니다. 이 테스트를 실행하려면
> Docker(Colima)가 떠 있어야 합니다.

**검증**:
```bash
./gradlew test --tests "*.AuthServiceTest" --tests "*.AuthControllerTest"
```
4개 통합 테스트 + 3개 단위 테스트 모두 통과해야 합니다.

---

## 1-10. 수동 검증 (기존 Node 백엔드와 비교)

```bash
./gradlew bootRun
```

```bash
# 로그인
curl -X POST localhost:3001/auth/login -H "Content-Type: application/json" \
  -d '{"email":"test@okestro.com","password":"password123"}'
# → {"token":"eyJ...", "user":{"id":1,"name":"테스트","email":"test@okestro.com","role":"member"}}

# 토큰으로 /me
curl localhost:3001/me -H "Authorization: Bearer <위 토큰>"
# → {"userId":1,"name":"테스트","email":"test@okestro.com","role":"member"}

# 토큰 없이 /me
curl -i localhost:3001/me
# → 401 {"error":"인증이 필요합니다."}
```

기존 `backend/`(Node.js, 포트를 다르게 띄우거나 잠시 내려두고 비교)의 동일한 요청 응답과 필드명/구조가
같은지 눈으로 대조합니다.

---

## 완료 기준

- `AuthServiceTest`(단위, MockK) 3개 통과
- `AuthControllerTest`(통합, Testcontainers) 4개 통과
- `/auth/login`, `/me` curl 검증에서 기존 Node.js 백엔드와 응답 필드가 동일
- 토큰 없이 `/me` 호출 시 401, 잘못된 비밀번호로 로그인 시 401

다음은 Step 2 — `user`/`admin` (계정 생성, 비밀번호 초기화/변경).
