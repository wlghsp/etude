# Phase 12 — Kotest 전환 가이드

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)

Step 0에서 정한 테스트 스택은 JUnit5 + MockK였다. 이 문서는 그 스택의 테스트 프레임워크만 Kotest로
바꾸는 횡단 작업이다 — 특정 Step의 기능 산출물이 아니라 기존/이후 모든 Step의 테스트 작성 방식에 적용되는
공통 규칙이므로 별도 문서로 둔다. MockK는 그대로 유지한다 (Kotest는 assertion/구조 DSL이고, mocking은
역할이 다르다).

참고: [우아한형제들 기술 블로그 — Kotest 도입기](https://techblog.woowahan.com/22586/).
이 글은 "직관적/선언형"을 이유로 FreeSpec·ShouldSpec 계열을 택했다. 이 프로젝트도 같은 방향으로
FreeSpec을 기본으로 채택하고, ShouldSpec은 상대적으로 단순한 케이스에 선택적으로 써본다.

---

## 왜 Kotest인가

- JUnit5 + `@Test` + `@DisplayName`은 테스트 이름이 메서드 이름과 문자열 애노테이션으로 분리되어 있어,
  given-when-then 계층을 코드 구조로 표현하지 못한다. 지금 `UserServiceTest.kt`처럼 `// given` 주석에
  의존하는 방식이 그 증거다.
- Kotest의 `shouldBe`, `shouldThrow` 같은 matcher는 JUnit의 `assertEquals`, `assertThrows`보다
  읽었을 때 의도가 더 명확하다.
- `useJUnitPlatform()`이 루트 [build.gradle.kts](../../backend-kotlin/build.gradle.kts)에 이미
  설정돼 있어, Kotest 러너 추가만으로 별도 설정 변경 없이 바로 실행된다.

## 스펙 스타일 두 가지를 함께 쓴다

| 스타일 | 형태 | 언제 쓰나 |
|---|---|---|
| **FreeSpec** (기본) | `"상황" - { "조건" - { "결과" { } } }` | given-when-then 3단 구조가 필요한 도메인 서비스 테스트 (`UserServiceTest` 등) |
| **ShouldSpec** | `should("...") { }` | 계층이 필요 없는 단순 케이스 (유틸/확장 함수, 단일 조건 검증) |

두 스타일을 같은 모듈 안에서 파일 단위로 섞어 써도 무방하다 — Kotest는 스펙 클래스별로 스타일을 고를 수
있다. 다만 한 테스트 클래스 안에서 스타일을 섞지는 않는다.

---

## 1. 의존성 추가

단일 진실 공급원 원칙에 따라 테스트 의존성은 루트 [build.gradle.kts](../../backend-kotlin/build.gradle.kts)의
`subprojects { dependencies { ... } }` 블록 한 곳에만 추가한다 (개별 모듈의 `build.gradle.kts`에
중복 선언하지 않는다).

```kotlin
// backend-kotlin/build.gradle.kts, subprojects { dependencies { ... } } 안에 추가
"testImplementation"("io.kotest:kotest-runner-junit5:5.9.1")
"testImplementation"("io.kotest:kotest-assertions-core:5.9.1")
```

버전은 [Kotest 릴리스 페이지](https://github.com/kotest/kotest/releases)에서 최신 5.9.x대를 확인해
맞춘다. `kotlin-test-junit5`는 당장 제거하지 않는다 — 기존 테스트가 이걸 참조하고 있을 수 있으니, 모든
테스트 파일을 Kotest로 옮긴 뒤 마지막에 정리한다 (원칙 3: 자신이 만든 orphan만 치운다).

**검증**: `./gradlew :apps:backend:dependencies --configuration testCompileClasspath | grep kotest`로
의존성이 잡히는지 확인.

---

## 2. 기존 JUnit5 테스트를 FreeSpec으로 전환하는 방법

`UserServiceTest.kt`를 예로 든다. 지금 상태:

```kotlin
class UserServiceTest {
    private val userRepository = mockk<UserRepository>()
    private val passwordEncoder = mockk<PasswordEncoder>()
    private val userService = UserService(userRepository, passwordEncoder)

    @DisplayName("")
    @Test
    fun test() {
        // given
        // when
        // then
    }
}
```

핵심 차이:
- `class X { }` → `class X : FreeSpec({ })` — 생성자 블록 안에 테스트를 선언
- `@Test fun test()` → 문자열 노드. `-`는 하위 컨텍스트, 마지막 잎 노드만 중괄호 하나로 끝난다
- `mockk()` 인스턴스는 스펙 블록 최상단에서 한 번만 만들고 재사용 (JUnit의 `@BeforeEach` 대신 Kotest는
  기본적으로 스펙당 한 인스턴스 — 격리가 필요하면 `isolationMode` 설정, 지금 규모에서는 불필요)

아래는 실제 `UserService`(`getAllMembers`, `createUser`, `resetPassword`, `changeOwnPassword`)의
4개 메서드를 전부 커버하는 완성 코드다. 그대로 `UserServiceTest.kt`에 옮겨 쓰면서 각 줄이 왜 이렇게
되는지 이해하는 것이 이번 클론코딩의 목표다.

```kotlin
package com.etude.domain.user

import com.etude.domain.auth.EmailAlreadyExistsException
import com.etude.domain.auth.PasswordEncoder
import com.etude.domain.auth.User
import com.etude.domain.auth.UserNotFoundException
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import com.etude.domain.auth.WrongPasswordException
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.collections.shouldContainExactly
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class UserServiceTest : FreeSpec({
    val userRepository = mockk<UserRepository>()
    val passwordEncoder = mockk<PasswordEncoder>()
    val userService = UserService(userRepository, passwordEncoder)

    "전체 회원 목록을 조회할 때" - {
        "이름 오름차순으로 정렬된 요약 목록을 반환한다" {
            // given — id는 BaseEntity에서 `val id: Long = 0`으로 고정되어 생성자로 못 채운다.
            // 이 테스트는 id 값 자체를 검증하지 않으므로 실제 User 생성자로 충분하다.
            val userA = User(name = "최지호", email = "jiho@etude.com", password = "hash1", role = UserRole.member)
            val userB = User(name = "가나다", email = "abc@etude.com", password = "hash2", role = UserRole.member)
            every { userRepository.findAllByRole(UserRole.member) } returns listOf(userA, userB)

            // when
            val result = userService.getAllMembers()

            // then
            result.map { it.name } shouldContainExactly listOf("가나다", "최지호")
        }
    }

    "신규 사용자 생성을 요청했을 때" - {
        "이메일이 중복되지 않으면" - {
            "비밀번호를 인코딩하여 사용자를 저장하고 요약 정보를 반환한다" {
                // given — save()가 반환하는 값을 그대로 검증하므로, 인자로 넘어온 User를 그대로 돌려주게 스텁한다.
                every { userRepository.existsByEmail("new@etude.com") } returns false
                every { passwordEncoder.encode("raw-pw") } returns "encoded-pw"
                every { userRepository.save(any()) } answers { firstArg() }

                // when
                val result = userService.createUser("최지호", "new@etude.com", "raw-pw")

                // then
                result.email shouldBe "new@etude.com"
                result.role shouldBe UserRole.member
                verify { userRepository.save(any()) }
            }
        }

        "이메일이 이미 존재하면" - {
            "EmailAlreadyExistsException을 던진다" {
                // given
                every { userRepository.existsByEmail("dup@etude.com") } returns true

                // when & then
                shouldThrow<EmailAlreadyExistsException> {
                    userService.createUser("최지호", "dup@etude.com", "raw-pw")
                }
            }
        }
    }

    "관리자가 비밀번호를 초기화할 때" - {
        "대상 사용자가 존재하면" - {
            "새 비밀번호를 인코딩하여 저장한다" {
                // given — password는 private이라 직접 못 읽으므로, matchesPassword()로 간접 검증한다.
                val user = User(name = "최지호", email = "jiho@etude.com", password = "old-hash", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.encode("new-pw") } returns "new-hash"
                every { passwordEncoder.matches("new-pw", "new-hash") } returns true
                every { userRepository.save(user) } returns user

                // when
                userService.resetPassword(1L, "new-pw")

                // then
                user.matchesPassword("new-pw", passwordEncoder) shouldBe true
                verify { userRepository.save(user) }
            }
        }

        "대상 사용자가 존재하지 않으면" - {
            "UserNotFoundException을 던진다" {
                // given
                every { userRepository.findById(999L) } returns null

                // when & then
                shouldThrow<UserNotFoundException> {
                    userService.resetPassword(999L, "new-pw")
                }
            }
        }
    }

    "본인이 비밀번호를 변경할 때" - {
        "현재 비밀번호가 일치하면" - {
            "새 비밀번호로 변경한다" {
                // given
                val user = User(name = "최지호", email = "jiho@etude.com", password = "old-hash", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.matches("current-pw", "old-hash") } returns true
                every { passwordEncoder.encode("new-pw") } returns "new-hash"
                every { passwordEncoder.matches("new-pw", "new-hash") } returns true
                every { userRepository.save(user) } returns user

                // when
                userService.changeOwnPassword(1L, "current-pw", "new-pw")

                // then
                user.matchesPassword("new-pw", passwordEncoder) shouldBe true
                verify { userRepository.save(user) }
            }
        }

        "현재 비밀번호가 일치하지 않으면" - {
            "WrongPasswordException을 던진다" {
                // given
                val user = User(name = "최지호", email = "jiho@etude.com", password = "old-hash", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.matches("wrong-pw", "old-hash") } returns false

                // when & then
                shouldThrow<WrongPasswordException> {
                    userService.changeOwnPassword(1L, "wrong-pw", "new-pw")
                }
            }
        }

        "대상 사용자가 존재하지 않으면" - {
            "UserNotFoundException을 던진다" {
                // given
                every { userRepository.findById(999L) } returns null

                // when & then
                shouldThrow<UserNotFoundException> {
                    userService.changeOwnPassword(999L, "current-pw", "new-pw")
                }
            }
        }
    }
})
```

> `User.id`는 `BaseEntity`에서 `val id: Long = 0`으로 고정되어(JPA가 영속화 시점에 채움) 생성자나
> `.apply {}`로 원하는 값을 세팅할 수 없다. 이 예시는 id 값 자체를 검증하는 케이스가 없으므로 mockk
> 없이 실제 `User(...)` 생성자로 충분하다 — Step 2 가이드(`guide_phase12_step2_user_admin.md`
> 2-3)의 AssertJ 버전과 동일한 접근이다.
>
> `User.matchesPassword()`(`User.kt:37`)는 `passwordEncoder.matches(rawPassword, password)`로
> 저장된 해시와 비교한다(2026-08 버그 수정 완료 — 이전에는 `matches(rawPassword, rawPassword)`로
> 원문끼리 비교해 항상 true를 반환하는 인증 우회 결함이 있었다).

## 3. ShouldSpec 예시 (단순 케이스)

계층이 필요 없는 테스트는 ShouldSpec으로 짧게 쓴다. 아래는 `PasswordEncoder`처럼 단일 조건만 검증하면
되는 대상을 가정한 예시다.

```kotlin
import io.kotest.core.spec.style.ShouldSpec
import io.kotest.matchers.shouldNotBe
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder

class BCryptPasswordEncoderTest : ShouldSpec({
    val encoder = BCryptPasswordEncoder()

    should("같은 원문을 두 번 인코딩하면 매번 다른 해시가 나온다") {
        val hash1 = encoder.encode("raw-pw")
        val hash2 = encoder.encode("raw-pw")

        hash1 shouldNotBe hash2
    }

    should("인코딩된 해시는 원문과 매치된다") {
        val hash = encoder.encode("raw-pw")

        encoder.matches("raw-pw", hash) shouldBe true
    }
})
```

---

## 4. 참고 — BehaviorSpec은 왜 안 쓰나 (비교용 예시)

이 프로젝트는 FreeSpec/ShouldSpec을 채택했지만, 세 번째 선택지였던 BehaviorSpec도 실제로 어떻게
다른지 보고 넘어갈 가치가 있다. `createUser`의 "이메일 중복" 케이스를 세 스타일로 나란히 써보면
차이가 뚜렷하다.

```kotlin
// BehaviorSpec — Given/When/Then이 타입에 박혀 있다. 블록 이름도 고정.
import io.kotest.core.spec.style.BehaviorSpec

class UserServiceTest : BehaviorSpec({
    val userRepository = mockk<UserRepository>()
    val passwordEncoder = mockk<PasswordEncoder>()
    val userService = UserService(userRepository, passwordEncoder)

    Given("이미 존재하는 이메일로") {
        every { userRepository.existsByEmail("dup@etude.com") } returns true

        When("사용자 생성을 요청하면") {
            Then("EmailAlreadyExistsException을 던진다") {
                shouldThrow<EmailAlreadyExistsException> {
                    userService.createUser("최지호", "dup@etude.com", "raw-pw")
                }
            }
        }
    }
})
```

```kotlin
// FreeSpec — 이 프로젝트가 실제로 쓰는 형태 (2번 섹션과 동일)
"신규 사용자 생성을 요청했을 때" - {
    "이메일이 이미 존재하면" - {
        "EmailAlreadyExistsException을 던진다" {
            every { userRepository.existsByEmail("dup@etude.com") } returns true
            shouldThrow<EmailAlreadyExistsException> {
                userService.createUser("최지호", "dup@etude.com", "raw-pw")
            }
        }
    }
}
```

**BehaviorSpec을 쓰지 않기로 한 이유**:
- `Given`/`When` 블록 안에서 실행되는 코드(위 예시의 `every { ... }`)가 "given"에 해당하는지
  "선행 준비"에 해당하는지가 문법상 강제되지 않는다 — 결국 FreeSpec과 마찬가지로 작성자가 어디에
  뭘 넣을지 판단해야 한다. 즉 구조 강제가 겉보기와 달리 완전하지 않다.
- 우아한형제들 사례가 실제로 택한 스타일이 아니다(FreeSpec/ShouldSpec 계열) — 이 가이드는 그 사례를
  따라가는 것이 목표이므로 굳이 다른 스타일을 새로 들일 이유가 없다.
- Given/When/Then 세 단어가 항상 정확히 3단으로 떨어지지 않는 케이스(예: "선행 조건이 여러 개"이거나
  "Then 없이 Given만으로 끝나는" 단순 검증)에서는 오히려 FreeSpec의 자유 중첩이 코드가 더 짧아진다.

**BehaviorSpec이 더 나은 경우**: 팀 컨벤션으로 "given-when-then 3단 구조를 절대 벗어나면 안 된다"를
강제하고 싶다면 BehaviorSpec이 FreeSpec보다 사고 방지에 유리하다. 지금 Etude는 혼자(또는 소수) 개발
중이라 그 강제력의 이점보다 FreeSpec의 유연성이 더 유용하다고 보고 FreeSpec을 택했다 — 협업 인원이
늘어나고 테스트 구조가 흐트러지는 문제가 실제로 생기면 그때 BehaviorSpec 전환을 재고할 수 있다.

## 5. 전환 대상 목록

Step 1~2에서 이미 JUnit5로 작성된 기존 테스트 5개가 전환 대상이다. 단위 테스트와 통합 테스트는 성격이
달라 순서를 나눈다 — 단위 테스트가 더 간단하니 먼저 손에 익히고, 통합 테스트의 공통 베이스
(`IntegrationTest`)를 그다음에 고친다.

| 파일 | 종류 | 비고 |
|---|---|---|
| `domain/auth/AuthServiceTest.kt` | 단위 (mockk) | 3개 테스트, `UserServiceTest`와 동일한 패턴 |
| `domain/user/UserServiceTest.kt` | 단위 (mockk) | 6개 테스트, 2번 섹션에서 이미 완성본 제공 |
| `support/IntegrationTest.kt` | 통합 베이스 클래스 | 다른 통합 테스트 3개가 전부 이걸 상속 — 여기를 먼저 고쳐야 함 |
| `interfaces/api/auth/AuthControllerTest.kt` | 통합 (MockMvc) | 4개 테스트 |
| `BackendKotlinApplicationTests.kt` | 통합 (컨텍스트 로딩만) | 가장 단순 |

## 6. 통합 테스트(`IntegrationTest`) 전환

`IntegrationTest`는 현재 일반 `abstract class`라서, 이걸 상속하는 테스트가 동시에 `FreeSpec`도
상속할 수 없다(Kotlin은 클래스 다중 상속 불가). 따라서 `IntegrationTest` 자체를 `FreeSpec`을
상속하도록 바꾼다 — 그러면 하위 통합 테스트 3개가 전부 자동으로 Kotest 스펙이 된다.

```kotlin
// 변경 전
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
        val mariadb = MariaDBContainer("mariadb:11")
    }
}
```

```kotlin
// 변경 후
package com.etude.support

import io.kotest.core.spec.style.FreeSpec
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.test.context.ActiveProfiles
import org.testcontainers.containers.MariaDBContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers

@Testcontainers
@SpringBootTest
@ActiveProfiles("test")
abstract class IntegrationTest(body: FreeSpec.() -> Unit = {}) : FreeSpec(body) {
    companion object {
        @Container
        @ServiceConnection
        val mariadb = MariaDBContainer("mariadb:11")
    }
}
```

- `FreeSpec(body: FreeSpec.() -> Unit = {})`을 파라미터로 받는 이유: `IntegrationTest`를 상속하는
  각 하위 클래스(`AuthControllerTest` 등)가 자신만의 테스트 블록을 생성자로 넘겨줘야 하기 때문이다.
  기본값 `{}`을 준 이유는 `BackendKotlinApplicationTests`처럼 `init { }`으로 직접 테스트를 쓰는
  스타일도 함께 지원하기 위해서다(아래 예시 참고).
- `companion object`의 Testcontainers 설정은 그대로 둔다 — `docs/research/kotlin_oop_class_design.md`
  5번 섹션에서 이미 짚었듯 "클래스 계층에 종속된 정적 자원"이라는 성격은 스펙 스타일이 바뀌어도
  달라지지 않는다.

`BackendKotlinApplicationTests`(가장 단순한 예)를 Kotest로 바꾸면:

```kotlin
package com.etude

import com.etude.support.IntegrationTest
import io.kotest.core.spec.style.stringSpec

class BackendKotlinApplicationTests : IntegrationTest({
    "스프링 컨텍스트가 정상적으로 로드된다" { }
})
```

`AuthControllerTest`(MockMvc 기반)를 Kotest로 바꾸면 — `@Autowired lateinit var`를 생성자 주입으로
바꾸는 게 핵심이다:

```kotlin
package com.etude.interfaces.api.auth

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.support.IntegrationTest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class AuthControllerTest(
    @Autowired val mockMvc: MockMvc,
    @Autowired val userJpaRepository: UserJpaRepository,
) : IntegrationTest({

    beforeTest {
        userJpaRepository.deleteAll()
        userJpaRepository.save(
            User(name = "테스트", email = "test@okestro.com", password = BCryptPasswordEncoder().encode("password123")!!, role = UserRole.member)
        )
    }

    "로그인이 성공하면" - {
        "토큰을 반환한다" {
            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{ "email": "test@okestro.com", "password": "password123" }""")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.token").exists())
                .andExpect(jsonPath("$.data.user.email").value("test@okestro.com"))
        }
    }

    "잘못된 비밀번호로 로그인하면" - {
        "401을 반환한다" {
            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{ "email": "test@okestro.com", "password": "wrong" }""")
            )
                .andExpect(status().isUnauthorized)
        }
    }

    "토큰 없이 /me를 호출하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/me")).andExpect(status().isUnauthorized)
        }
    }

    "토큰을 붙여 /me를 호출하면" - {
        "사용자 정보를 반환한다" {
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
})
```

`@BeforeEach fun setup()`이 `beforeTest { }`로 바뀐 이유: Kotest는 JUnit5의 `@BeforeEach`
애노테이션을 인식하지 못한다(스펙 클래스가 `@Test` 메서드 목록이 아니라 트리 구조로 동작하기 때문).
`beforeTest { }`는 그 트리의 매 leaf(테스트 하나하나)마다 실행되는 Kotest의 대응 훅이다.

`UserAdminControllerTest`(Step 2)도 `IntegrationTest`를 이렇게 고친 뒤에는 같은 패턴(생성자 주입 +
`beforeTest`)으로 바로 작성할 수 있다 — [guide_phase12_step2_user_admin.md](guide_phase12_step2_user_admin.md)
2-5절에 완성본이 있다.

## 진행 순서 (직접 수정)

이 문서는 방향만 제시한다. 실제 코드 변경은 CLAUDE.md 원칙에 따라 직접 진행한다.

1. `build.gradle.kts`에 Kotest 의존성 추가 → `./gradlew build`로 컴파일 확인
2. `AuthServiceTest.kt`, `UserServiceTest.kt`(둘 다 단위 테스트)를 FreeSpec으로 다시 작성 →
   `./gradlew test --tests "*.AuthServiceTest" --tests "*.UserServiceTest"`로 확인
3. `IntegrationTest.kt`를 6번 섹션대로 `FreeSpec` 상속으로 변경
4. `BackendKotlinApplicationTests.kt`, `AuthControllerTest.kt`(통합 테스트 2개)를 6번 섹션 예시대로
   생성자 주입 + `beforeTest` 패턴으로 다시 작성 →
   `./gradlew test --tests "*.BackendKotlinApplicationTests" --tests "*.AuthControllerTest"`로 확인
5. `UserAdminControllerTest.kt`(Step 2에서 아직 안 만들었다면 처음부터, 만들었다면 재작성)를 같은
   패턴으로 작성
6. 이후 Step에서 새로 작성하는 모든 테스트는 처음부터 FreeSpec/ShouldSpec으로 작성 (JUnit5 `@Test`
   스타일로 되돌아가지 않는다)

**검증 기준**: `./gradlew test`가 5개 파일 전부 Kotest로 전환된 뒤에도 기존과 동일하게 전체 그린
상태를 유지하면 전환 완료.
