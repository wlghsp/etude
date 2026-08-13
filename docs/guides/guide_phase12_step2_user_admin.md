# Phase 12 Step 2 — user/admin (계정 생성·비밀번호 관리)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step1_auth.md](guide_phase12_step1_auth.md)

대응하는 기존 Node.js 파일: `backend/src/services/user.ts`(전체),
`backend/src/routes/admin.routes.ts`(user 관련 라우트만 — `/admin/users`, `/admin/users/:id/password`.
quest-set 관련 라우트는 Step 3 범위). `PATCH /me/password`는 Step 1에서 `AuthController`에 붙이지
않고 이 Step으로 미뤄뒀던 부분입니다.

이 Step에서 다루는 4개 엔드포인트:
- `POST /admin/users` — 계정 생성 (관리자 전용)
- `GET /admin/users` — member 목록 조회 (관리자 전용)
- `PATCH /admin/users/:id/password` — 관리자가 임의 계정 비밀번호 초기화 (관리자 전용)
- `PATCH /me/password` — 본인 비밀번호 변경 (로그인 필요)

DB 스키마는 Step 1과 동일하게 `user` 테이블을 그대로 씁니다 (변경하지 않음).

**경로 표기 안내**는 Step 1과 동일합니다 — `domain/user/UserService.kt`처럼 쓰는 경로는
`backend-kotlin/apps/backend/src/main/kotlin/com/etude/domain/user/UserService.kt`를 가리킵니다.

## 인수 조건 (이 Step의 완료 기준)

*Node.js 원본(`user.ts`, `admin.routes.ts`)의 실제 동작이 곧 인수 조건이다. 응답 포맷은 Step 1에서
도입한 `ApiResponse<T>` 공통 래퍼를 그대로 따른다.*

**계정 생성 (`POST /admin/users`)**
- [ ] 관리자 토큰으로 `{ name, email, password }` 전송 시 200 + `{ id, name, email, role: "member" }`
- [ ] 새로 생성된 계정은 `role: member`로 고정 (요청 바디로 role을 바꿀 수 없음 — 기존 `createUser`가
  role을 하드코딩하는 것과 동일)
- [ ] 이미 존재하는 이메일로 생성 시도 시 409 (스키마의 `email UNIQUE` 제약)
- [ ] `member` 토큰(비관리자)으로 호출 시 403
- [ ] 토큰 없이 호출 시 401

**계정 목록 조회 (`GET /admin/users`)**
- [ ] 관리자 토큰으로 호출 시 200 + `[{ id, name, email, role }]` 배열 (`role = 'member'`인 계정만,
  이름순 정렬 — 기존 `getAllUsers`의 `WHERE role = 'member' ORDER BY name`과 동일)
- [ ] `member` 토큰으로 호출 시 403

**비밀번호 초기화 (`PATCH /admin/users/:id/password`)**
- [ ] 관리자 토큰으로 `{ password }` 전송 시 200, 해당 계정 비밀번호가 새 값으로 변경됨
- [ ] `member` 토큰으로 호출 시 403
- [ ] 존재하지 않는 `id`로 호출 시 404

**본인 비밀번호 변경 (`PATCH /me/password`)**
- [ ] 로그인한 사용자가 `{ currentPassword, newPassword }` 전송, 현재 비밀번호가 맞으면 200 +
  비밀번호 변경됨
- [ ] 현재 비밀번호가 틀리면 401 + `{ message: "현재 비밀번호가 올바르지 않습니다." }`
- [ ] 토큰 없이 호출 시 401

이 조건들은 아래 2-5(통합 테스트)의 `UserAdminControllerTest`로 그대로 옮겨진다. 이 Step은 그 테스트가
전부 통과하면 완료다.

프론트엔드(`frontend/src/api/admin.ts`, `user.ts`, `auth.ts`)는 Step 1과 동일한 방침으로 이 Step에서
건드리지 않는다 — Step 10(cutover)에서 전체 API 모듈을 일괄 전환한다.

## 진행 방식

Step 1과 동일하게 **ATDD 바깥 루프 + 구현-후-검증 안쪽 루프**로 진행합니다. `user.ts`의 로직(계정 생성,
비밀번호 초기화/변경)은 이미 명확히 정해져 있어 설계를 탐색할 이유가 없으므로, "구현 먼저 작성 → 단위
테스트로 검증" 순서를 그대로 씁니다. 레이어는 `domain/auth`(엔티티 보강) → `domain/user`(서비스) →
`application/user`(Facade) → `interfaces/api/admin`, `interfaces/api/user`(컨트롤러) → 인수
테스트 순으로 나갑니다.
`UserRepository`, `PasswordEncoder`, `CoreException`/`ErrorType`, `ApiResponse<T>`,
`ApiControllerAdvice`, `AuthInterceptor`/`AdminInterceptor`는 Step 1에서 이미 만들어져 있으므로
재사용만 합니다. `User` 엔티티는 이 Step에서 캡슐화를 보강합니다 (2-0 참고).

---

## 2-0. `User` 엔티티 캡슐화 — 비밀번호를 스스로 관리하게 한다

**변경 체크리스트** (`domain/auth/User.kt`를 실제로 고칠 때 이 순서로 확인합니다):

1. `name: String`, `password: String` 생성자 파라미터에서 `var`를 제거하고 `@Column`도 함께 뗀다
   (생성자 파라미터는 프로퍼티가 아니므로 `@Column`을 못 붙임 — 아래 상세 설명 참고).
2. 클래스 본문에 `name`, `password`를 프로퍼티로 재선언하고 `@Column`을 그쪽으로 옮긴다.
3. `name`은 `private set`(읽기는 공개, 쓰기만 잠금), `password`는 `private`(읽기·쓰기 모두 잠금)
   으로 가시성을 다르게 준다 — 이유는 이 문서 하단의 "`private set`과 `private var`의 차이" 참고.
4. `private set`/`private` 앞에 `final`을 붙인다 — `@Entity`가 `allOpen`으로 자동 `open` 처리되기
   때문에 안 붙이면 컴파일 에러가 난다. (대안으로 `final` 없이 `protected set`을 쓸 수도 있다 —
   차이는 `docs/research/kotlin_oop_class_design.md`의 1-1 참고. 이 가이드는 `final` +
   `private set`으로 통일한다.)
5. `changeName(newName: String)`, `changePassword(encodedPassword: String)`,
   `matchesPassword(rawPassword: String, passwordEncoder: PasswordEncoder): Boolean` 세 메서드를
   추가한다.
6. `domain/auth/AuthService.kt`의 `login()`에서 `user.password`를 직접 읽던 부분을
   `user.matchesPassword(...)`로 바꾼다(아래 "Step 1 코드도 이 방식에 맞춰 고칩니다" 참고).
7. `./gradlew test --tests "*.AuthServiceTest"`로 Step 1 테스트가 여전히 통과하는지 확인한다.

아래는 각 단계의 "왜"를 설명한다.

Step 1의 `User`는 `password`와 `name`이 둘 다 `var`로 열려 있어서 외부 코드가 `user.password =
"아무값"`, `user.name = "아무값"`처럼 직접 대입할 수 있었습니다. 이 방식은 "값을 어떻게 바꿀 수
있는가"라는 규칙이 `User` 자신이 아니라 호출부의 관례에만 의존하게 만듭니다 — 나중에 다른 서비스가
실수로 잘못된 값을 그대로 대입해도 컴파일러가 막아주지 못합니다. `password`뿐 아니라 `name`도
`private set`으로 잠그고, 값을 바꾸거나 확인하는 행동을 `User`의 메서드로 옮깁니다.

`name`은 지금 시점엔 실제 변경 기능이 없습니다(Node.js 원본 `user.ts`에도 이름 변경 API가 없음).
그래도 캡슐화하는 이유는 "지금 당장 규칙이 없다"와 "앞으로도 아무나 대입해도 된다"는 다른 이야기라서
입니다 — `var`로 열어두면 원칙(값 변경은 항상 의도가 드러나는 메서드를 통해서만)이 `password`에만
적용되고 `name`은 예외라는 어중간한 상태가 됩니다. 지금은 `changeName()`이 검증 없이 값만
바꾸지만, 나중에 길이 제한 같은 규칙이 생기면 이 메서드 안에만 추가하면 됩니다.

`domain/auth/User.kt` (Step 1에서 만든 파일을 수정)

```kotlin
package com.etude.domain.auth

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Table

@Entity
@Table(name = "user")
class User(
    name: String,
    @Column(nullable = false, unique = true, length = 200)
    val email: String,
    password: String,
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    val role: UserRole = UserRole.member,
) : BaseEntity() {
    @Column(nullable = false, length = 100)
    final var name: String = name
        private set

    @Column(nullable = false, length = 200)
    private final var password: String = password

    fun changeName(newName: String) {
        name = newName
    }

    fun changePassword(encodedPassword: String) {
        password = encodedPassword
    }

    fun matchesPassword(rawPassword: String, passwordEncoder: PasswordEncoder): Boolean =
        passwordEncoder.matches(rawPassword, password)
}
```

- `name`, `password` 둘 다 생성자 파라미터로는 그대로 받되(그래야 `User(name = "...", ...)`처럼
  객체를 처음 만들 때는 값을 줄 수 있음), 클래스 본문에서 `private set`(name)/`private`(password)
  프로퍼티로 다시 선언해서 **생성 이후에는 클래스 밖에서 대입할 수 없게** 잠갔습니다. 이게
  `service-apply`(`docs/research/woowacourse_service_apply_analysis.md`)에서 본
  "주 생성자는 raw 값을 받고, 프로퍼티는 `private set`으로 다시 선언"하는 패턴입니다.
- **`@Column`은 생성자 파라미터가 아니라 클래스 본문에서 다시 선언한 프로퍼티 쪽에 붙입니다.**
  `var`/`val` 없이 선언한 생성자 파라미터(`name: String`, `password: String`)는 Kotlin에서 그냥
  "생성자 실행 시 한 번 쓰이고 마는 값"일 뿐 프로퍼티가 아닙니다. `@Column`은 필드/프로퍼티에만 붙일
  수 있는 어노테이션이라, 파라미터 쪽에 그대로 두면 `This annotation is not applicable to target
  'value parameter'`라는 컴파일 에러가 납니다. `email`, `role`처럼 `val`을 생성자에서 바로 붙인
  경우는 그 자체가 프로퍼티라서 `@Column`을 그 자리에 둬도 되지만, `name`/`password`처럼 클래스
  본문에서 별도 프로퍼티로 다시 선언하는 경우는 어노테이션도 그 본문 선언 쪽으로 함께 옮겨야 합니다.
- **`final`을 붙이지 않으면 `Private setters for open properties are prohibited` 에러가 납니다.**
  `build.gradle.kts`의 `allOpen { annotation("jakarta.persistence.Entity") }` 설정 때문에
  `@Entity`가 붙은 `User` 클래스는 자동으로 `open`(상속·오버라이드 가능) 처리됩니다 — JPA가 지연
  로딩 프록시를 만들려면 클래스가 `open`이어야 하기 때문에 이 설정 자체는 지우면 안 됩니다. 문제는
  클래스가 `open`이면 그 안의 `var` 프로퍼티도 기본적으로 오버라이드 가능한 것으로 취급되는데,
  Kotlin은 "오버라이드 가능한 프로퍼티에 `private set`을 붙이는 것"을 금지합니다(서브클래스가
  오버라이드하면서 `public set`으로 풀어버릴 수 있어 `private`의 의미가 깨지기 때문). 그래서
  `name`/`password` 프로퍼티 선언 앞에 `final`을 명시해 "이 프로퍼티만큼은 오버라이드할 수 없다"고
  못 박아야 `private set`/`private`이 허용됩니다. `email`, `role`은 `val`(애초에 재대입 자체가
  없음)이라 이 문제가 발생하지 않습니다.

> **`private set`과 `private var`의 차이** — 둘 다 "클래스 밖에서 직접 대입 못 하게 막는다"는
> 목적은 같지만, 잠그는 범위가 다릅니다.
> ```kotlin
> var name: String = name
>     private set        // 읽기(get)는 public, 쓰기(set)만 private
>
> private var password: String = password   // 읽기(get)/쓰기(set) 둘 다 private
> ```
> Kotlin의 `var`/`val` 프로퍼티는 내부적으로 getter(+ `var`면 setter)를 자동으로 만듭니다.
> `private set`은 그중 **setter에만** `private`을 붙이는 문법이라 getter는 원래 가시성(여기선
> `var`의 기본값인 `public`)을 유지합니다. 반면 프로퍼티 선언 앞에 `private`을 통째로 붙이면
> getter/setter 둘 다 그 가시성을 따라가므로, 읽기까지 막힙니다. 즉 `private set`은 "밖에서
> 읽을 수는 있지만 마음대로 바꾸지는 못하게" 하는 **부분 잠금**이고, `private var`는 "존재 자체를
> 밖에 드러내지 않는" **완전 잠금**입니다.

- `name`은 `private set`만 썼습니다 — 읽기(`user.name`)는 여전히 공개(`public`)이고, 쓰기만
  막혔습니다. `UserSummary(it.id, it.name, ...)`, JWT claim(`claim("name", user.name)`)처럼
  이미 `user.name`을 읽던 코드는 전혀 영향받지 않습니다.
- `password`는 `private`(get도 set도 비공개)입니다 — 비밀번호는 읽기 자체를 막아야 하므로(해시값을
  그대로 노출하면 안 됨) `name`보다 더 엄격하게 잠급니다. 조회가 필요한 유일한 경우(비교)는
  `matchesPassword()`로만 가능합니다.
- `name` 변경은 `changeName(newName)`으로만 가능하고, 이 메서드는 파라미터 이름부터 "이미
  인코딩된 값을 넣어라"라고 못 박아 둔 `changePassword(encodedPassword)`와 같은 이유로 존재합니다
  — 지금은 검증 로직이 없지만, 나중에 이름 길이 제한 같은 규칙이 생기면 이 메서드 안에만 추가하면
  모든 호출 경로에 자동으로 적용됩니다.
- 비교는 `matchesPassword(rawPassword, passwordEncoder)`로만 가능합니다. `PasswordEncoder`를
  파라미터로 받는 이유: `User`(도메인 엔티티)가 `PasswordEncoder`를 필드로 들고 있게 하면 엔티티가
  또 다른 협력자에 계속 의존하게 되므로, 그때그때 호출부가 들고 있는 `PasswordEncoder`를 넘겨받는
  방식을 씁니다.
- 실제 해싱(`passwordEncoder.encode(...)`) 자체는 여전히 서비스 계층의 책임입니다 — `User`는
  "해시가 어떻게 계산되는지" 모르고, "해시된 값을 어떻게 보관/비교하는지"만 압니다. 책임을 정확히
  나눈 것이지, 서비스 계층의 일을 엔티티로 옮긴 게 아닙니다.

이 Step에는 `changeName()`을 호출하는 API가 없습니다(Node.js 원본 `user.ts`에 이름 변경 기능
자체가 없으므로). 그렇다고 `name`을 `var`로 열어두면 안 됩니다 — "지금 이 값을 바꿀 코드가 없다"와
"이 값을 아무 코드나 마음대로 바꿀 수 있다"는 전혀 다른 이야기입니다. `var`로 열어두면 지금 당장은
아무도 안 써도, 나중에 어떤 코드든 `user.name = "실수로대입한값"`을 할 수 있는 구멍이 컴파일 타임에
막히지 않은 채로 항상 남아있게 됩니다. `private set` + `changeName()`으로 잠그면 그 구멍 자체가
지금부터 원천 차단됩니다 — `user.name = "..."`을 어디서 시도하든 컴파일 에러가 납니다. 이름 변경
기능이 실제로 필요해지는 시점이 오면, 그때는 이미 있는 `changeName()`을 호출하는 컨트롤러/서비스
코드만 추가하면 됩니다.

**Step 1 코드도 이 방식에 맞춰 고칩니다** — `domain/auth/AuthService.kt`의 `login()`이 아직
`user.password`를 직접 읽고 있습니다:

```kotlin
// 변경 전 (Step 1)
if (!passwordEncoder.matches(password, user.password)) throw InvalidCredentialsException()

// 변경 후
if (!user.matchesPassword(password, passwordEncoder)) throw InvalidCredentialsException()
```

`AuthServiceTest`(Step 1)의 세 테스트는 `User(..., password = "hashed", ...)`로 여전히 생성자를
통해 초기값을 줄 수 있으므로(생성자 파라미터 자체는 그대로 `private var`) 테스트 코드는 고치지
않아도 됩니다. `every { passwordEncoder.matches("password123", "hashed") } returns true`처럼
mock 설정도 그대로 유효합니다 — `matchesPassword`가 내부에서 `passwordEncoder.matches(...)`를
호출하는 얇은 위임이기 때문입니다.

**검증**: `./gradlew test --tests "*.AuthServiceTest"` — Step 1의 3개 테스트가 여전히 통과하는지
확인합니다 (엔티티 캡슐화가 Step 1의 동작을 깨지 않았는지 확인하는 회귀 검증).

---

## 2-1. `UserRepository` 확장 — 이메일 중복 확인 + role별 조회

`domain/auth/UserRepository.kt`(Step 1에서 만든 포트)에 이 Step에서 쓸 메서드 두 개를 미리 추가해
둡니다 — 이메일 중복 확인용 `existsByEmail`(계정 생성에서 사용), member 목록 조회용
`findAllByRole`(목록 조회에서 사용). `findByEmail`이 이미 있지만, "존재 여부만 확인"하는 의도를
이름으로 드러내기 위해 `existsByEmail`을 별도로 둡니다.

```kotlin
package com.etude.domain.auth

interface UserRepository {
    fun findByEmail(email: String): User?
    fun findById(id: Long): User?
    fun existsByEmail(email: String): Boolean
    fun findAllByRole(role: UserRole): List<User>
    fun save(user: User): User
}
```

`infrastructure/persistence/auth/UserJpaRepository.kt`, `UserRepositoryImpl.kt`에도 대응 메서드를
추가합니다.

```kotlin
// UserJpaRepository.kt
interface UserJpaRepository : JpaRepository<User, Long> {
    fun findByEmail(email: String): User?
    fun existsByEmail(email: String): Boolean
    fun findAllByRole(role: UserRole): List<User>
}
```

```kotlin
// UserRepositoryImpl.kt — override 추가
override fun existsByEmail(email: String): Boolean = jpaRepository.existsByEmail(email)
override fun findAllByRole(role: UserRole): List<User> = jpaRepository.findAllByRole(role)
```

**검증**: `./gradlew compileKotlin`이 통과하는지 확인.

---

## 2-2. 도메인 예외 추가 (`domain/auth/AuthExceptions.kt`)

Step 1에서 만든 파일에 이 Step에서 쓸 예외 3개를 더합니다. `InvalidCredentialsException`/
`InvalidTokenException` 옆에 나란히 둡니다 — 인증/계정 관련 예외를 한 파일에 모아두면 찾기 쉽습니다.

```kotlin
package com.etude.domain.auth

class InvalidCredentialsException(message: String = "이메일 또는 비밀번호가 올바르지 않습니다.") : RuntimeException(message)
class InvalidTokenException(message: String = "토큰이 유효하지 않습니다.") : RuntimeException(message)
class EmailAlreadyExistsException(message: String = "이미 사용 중인 이메일입니다.") : RuntimeException(message)
class UserNotFoundException(message: String = "사용자를 찾을 수 없습니다.") : RuntimeException(message)
class WrongPasswordException(message: String = "현재 비밀번호가 올바르지 않습니다.") : RuntimeException(message)
```

---

## 2-3. `UserService` — 구현 후 테스트로 검증

Step 1의 `AuthService`와 마찬가지로 로직이 이미 정해져 있으므로 "구현 먼저 + 테스트로 검증" 순서를
씁니다.

### 응답 타입 (`domain/user/UserSummary.kt`)

Step 1의 `AuthResult.kt`에 이미 `UserSummary`가 있습니다 — 이 Step에서 새로 만들지 않고 그대로
재사용합니다 (`domain.auth.UserSummary`). `getAllUsers`/`createUser`의 반환 타입으로 씁니다.

### `UserService` 구현 (`domain/user/UserService.kt`)

`user.ts`의 네 함수(`getAllUsers`, `createUser`, `resetPassword`, `changeOwnPassword`)를 그대로
옮깁니다.

```kotlin
package com.etude.domain.user

import com.etude.domain.auth.EmailAlreadyExistsException
import com.etude.domain.auth.PasswordEncoder
import com.etude.domain.auth.User
import com.etude.domain.auth.UserNotFoundException
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import com.etude.domain.auth.UserSummary
import com.etude.domain.auth.WrongPasswordException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
) {
    fun getAllMembers(): List<UserSummary> =
        userRepository.findAllByRole(UserRole.member)
            .sortedBy { it.name }
            .map { UserSummary(it.id, it.name, it.email, it.role) }

    fun createUser(name: String, email: String, password: String): UserSummary {
        if (userRepository.existsByEmail(email)) throw EmailAlreadyExistsException()

        val user = userRepository.save(
            User(name = name, email = email, password = passwordEncoder.encode(password), role = UserRole.member)
        )
        return UserSummary(user.id, user.name, user.email, user.role)
    }

    fun resetPassword(id: Long, newPassword: String) {
        val user = userRepository.findById(id) ?: throw UserNotFoundException()
        user.changePassword(passwordEncoder.encode(newPassword))
        userRepository.save(user)
    }

    fun changeOwnPassword(userId: Long, currentPassword: String, newPassword: String) {
        val user = userRepository.findById(userId) ?: throw UserNotFoundException()
        if (!user.matchesPassword(currentPassword, passwordEncoder)) throw WrongPasswordException()

        user.changePassword(passwordEncoder.encode(newPassword))
        userRepository.save(user)
    }
}
```

> `getAllMembers`가 쓰는 `UserRepository.findAllByRole(...)`은 2-1에서 이미 추가해뒀습니다.
> 정렬(`ORDER BY name`)은 JPA 메서드 이름 규칙(`findAllByRoleOrderByName`)으로 DB에 위임할 수도
> 있지만, 여기서는 도메인 서비스에서 `.sortedBy { }`로 처리해 정렬 기준이 도메인 코드에 드러나게
> 했습니다 — 둘 다 맞는 선택이라 팀 컨벤션에 따라 바꿔도 됩니다.
>
> 클래스에 `@Transactional`을 붙이는 걸 이 프로젝트의 기본값으로 삼습니다 — 쓰기 작업(`save`)이
> 하나라도 있는 도메인 서비스는 처음부터 붙여둡니다. `save()`(Spring Data `CrudRepository`)
> 자체는 자체적으로 트랜잭션을 열어 처리하므로 `@Transactional` 없이도 당장은 동작하지만, (1)
> `resetPassword`/`changeOwnPassword`처럼 "조회 → 수정 → 저장"이 여러 단계로 이뤄지는 메서드는
> 트랜잭션이 없으면 그 사이의 원자성이 보장되지 않고, (2) 나중에 커스텀 삭제/수정 파생 쿼리를
> 추가하면 트랜잭션 없이는 `InvalidDataAccessApiUsageException`으로 바로 깨집니다(Step 3의
> `QuestService.revokeAccess`가 실제로 이 문제를 겪었습니다). 순수 조회만 하는 서비스
> (`AuthService.login`처럼 `save`/`delete`가 전혀 없는 경우)는 붙이지 않아도 무방합니다.

### 테스트로 검증 (`src/test/kotlin/com/etude/domain/user/UserServiceTest.kt`)

테스트 프레임워크는 JUnit5 `@Test` 대신 Kotest `FreeSpec`을 쓴다 — 세부 이유와 의존성 추가 방법은
[guide_phase12_kotest_migration.md](guide_phase12_kotest_migration.md)를 먼저 본다. 이 Step부터는
새 테스트를 처음부터 Kotest로 작성한다.

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
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class UserServiceTest : FreeSpec({

    val userRepository = mockk<UserRepository>()
    val passwordEncoder = mockk<PasswordEncoder>()
    val userService = UserService(userRepository, passwordEncoder)

    "신규 계정을 생성할 때" - {
        "이메일이 중복되지 않으면" - {
            "member 권한으로 계정을 생성한다" {
                every { userRepository.existsByEmail("new@okestro.com") } returns false
                every { passwordEncoder.encode("password123") } returns "hashed"
                every { userRepository.save(any()) } answers {
                    firstArg<User>().apply { /* id는 DB가 채워주므로 테스트에서는 그대로 반환 */ }
                }

                val result = userService.createUser("신규", "new@okestro.com", "password123")

                result.email shouldBe "new@okestro.com"
                result.role shouldBe UserRole.member
            }
        }

        "이메일이 이미 존재하면" - {
            "예외를 던진다" {
                every { userRepository.existsByEmail("dup@okestro.com") } returns true

                shouldThrow<EmailAlreadyExistsException> {
                    userService.createUser("중복", "dup@okestro.com", "password123")
                }
            }
        }
    }

    "관리자가 비밀번호를 초기화할 때" - {
        "대상 사용자가 존재하면" - {
            "새 해시로 저장한다" {
                val user = User(name = "테스트", email = "test@okestro.com", password = "old-hashed", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.encode("newpass123") } returns "new-hashed"
                every { passwordEncoder.matches("newpass123", "new-hashed") } returns true
                every { userRepository.save(user) } returns user

                userService.resetPassword(1L, "newpass123")

                // password는 private이라 직접 못 읽으므로, matchesPassword로 간접 검증한다.
                user.matchesPassword("newpass123", passwordEncoder) shouldBe true
            }
        }

        "존재하지 않는 id면" - {
            "예외를 던진다" {
                every { userRepository.findById(999L) } returns null

                shouldThrow<UserNotFoundException> {
                    userService.resetPassword(999L, "newpass123")
                }
            }
        }
    }

    "본인이 비밀번호를 변경할 때" - {
        "현재 비밀번호가 맞으면" - {
            "비밀번호를 변경한다" {
                val user = User(name = "테스트", email = "test@okestro.com", password = "old-hashed", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.matches("current123", "old-hashed") } returns true
                every { passwordEncoder.encode("newpass123") } returns "new-hashed"
                every { passwordEncoder.matches("newpass123", "new-hashed") } returns true
                every { userRepository.save(user) } returns user

                userService.changeOwnPassword(1L, "current123", "newpass123")

                user.matchesPassword("newpass123", passwordEncoder) shouldBe true
            }
        }

        "현재 비밀번호가 틀리면" - {
            "예외를 던진다" {
                val user = User(name = "테스트", email = "test@okestro.com", password = "old-hashed", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.matches("wrong", "old-hashed") } returns false

                shouldThrow<WrongPasswordException> {
                    userService.changeOwnPassword(1L, "wrong", "newpass123")
                }
            }
        }
    }
})
```

> `verify { userRepository.save(any()) }` 같은 호출 검증이 필요 없다면 굳이 넣지 않는다 —
> `every { ... } answers { ... }`로 반환값을 직접 검증하는 편이 더 명확하다.

**검증**: `./gradlew test --tests "*.UserServiceTest"` — 6개 테스트 모두 통과해야 합니다.

---

## 2-3a. `UserFacade` — `interfaces`가 `domain`을 직접 호출하지 않는다

Step 0 설계(`docs/guides/guide_phase12_step0_setup.md`의 패키지 구조)는 `interfaces →
application(Facade) → domain`으로 의존 방향을 잡았습니다. Step 1(auth)에서 `AuthFacade`로 이미
채워 넣기 시작한 `application/` 레이어를 이 Step에서도 이어갑니다.

`UserFacade`는 `AdminUserV1Controller`와 `MeV1Controller`(2-4) 두 곳이 공유하는 진입점입니다.
지금은 `UserService`의 메서드를 그대로 위임하는 것 이상의 로직이 없지만, 이 얇은 계층을 두는
이유는 **컨트롤러가 도메인 서비스를 직접 알지 않게** 하기 위해서입니다 — 나중에 "계정 생성 시
환영 이메일도 함께 보낸다"처럼 여러 도메인 서비스를 조합해야 하는 요구가 생기면, 그 조합 로직은
`UserFacade`에만 추가하면 되고 컨트롤러나 `UserService`는 건드리지 않습니다.

`application/user/UserFacade.kt`:

```kotlin
package com.etude.application.user

import com.etude.domain.auth.UserSummary
import com.etude.domain.user.UserService
import org.springframework.stereotype.Component

@Component
class UserFacade(
    private val userService: UserService,
) {
    fun getAllMembers(): List<UserSummary> = userService.getAllMembers()

    fun createUser(name: String, email: String, password: String): UserSummary =
        userService.createUser(name, email, password)

    fun resetPassword(id: Long, newPassword: String) {
        userService.resetPassword(id, newPassword)
    }

    fun changeOwnPassword(userId: Long, currentPassword: String, newPassword: String) {
        userService.changeOwnPassword(userId, currentPassword, newPassword)
    }
}
```

> `@Service`가 아니라 `@Component`를 씁니다 — `UserFacade`는 도메인 비즈니스 로직을 담은
> 서비스가 아니라 `interfaces`와 `domain` 사이를 잇는 위임/조합 계층이라, 스프링 스테레오타입의
> 의미상 `@Service`(비즈니스 로직 계층)와 구분합니다. Step 1의 `AuthFacade`와 동일한 이유입니다.
>
> 테스트는 따로 만들지 않습니다 — `UserFacade`는 위임 외 로직이 없고, `UserService`가 이미
> `UserServiceTest`로 검증되어 있으므로 같은 케이스를 Facade 레벨에서 다시 확인하는 건 검증
> 없는 중복입니다. Facade에 실제 로직(조합, 트랜잭션 경계 등)이 추가되는 시점에 그 로직만
> 테스트를 씁니다.

---

## 2-4. 컨트롤러 — `AdminUserV1Controller`, `MeV1Controller`

Step 1과 동일하게 **ApiSpec + Controller** 분리, `ApiResponse<T>` 반환 패턴을 씁니다.
`ApiControllerAdvice`(Step 1에서 만듦)에 이 Step의 새 예외 3개에 대한 `@ExceptionHandler`를 추가합니다.

### 2-4a. `ApiControllerAdvice`에 예외 핸들러 추가

`EmailAlreadyExistsException`은 409(Conflict)를 반환해야 하는데, 지금 `ErrorType`에는 `CONFLICT`가
없습니다(`INTERNAL_SERVER_ERROR`/`BAD_REQUEST`/`UNAUTHORIZED`/`FORBIDDEN`/`NOT_FOUND`만 존재). 이
Step에서는 `ErrorType`에 `CONFLICT` 항목을 새로 추가하는 방식을 씁니다 — 기존 enum 패턴(status/code/
message를 한 곳에서 관리)과 일관되고, 앞으로 다른 409 케이스가 생겨도 그대로 재사용할 수 있기 때문입니다.

```kotlin
// support/error/ErrorType.kt — 기존 항목들 사이에 추가
CONFLICT(HttpStatus.CONFLICT, HttpStatus.CONFLICT.reasonPhrase, "이미 존재하는 리소스입니다."),
```

```kotlin
// interfaces/api/ApiControllerAdvice.kt
import com.etude.domain.auth.EmailAlreadyExistsException
import com.etude.domain.auth.UserNotFoundException
import com.etude.domain.auth.WrongPasswordException

// 기존 핸들러들 사이에 추가
@ExceptionHandler
fun handle(e: EmailAlreadyExistsException): ResponseEntity<ApiResponse<*>> =
    failureResponse(HttpStatus.CONFLICT, ErrorType.CONFLICT.code, e.message!!)

@ExceptionHandler
fun handle(e: UserNotFoundException): ResponseEntity<ApiResponse<*>> =
    failureResponse(HttpStatus.NOT_FOUND, ErrorType.NOT_FOUND.code, e.message!!)

@ExceptionHandler
fun handle(e: WrongPasswordException): ResponseEntity<ApiResponse<*>> =
    failureResponse(HttpStatus.UNAUTHORIZED, ErrorType.UNAUTHORIZED.code, e.message!!)
```

### 2-4b. `interfaces/api/admin/AdminUserV1ApiSpec.kt`

```kotlin
package com.etude.interfaces.api.admin

import com.etude.domain.auth.UserSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Admin User V1 API", description = "관리자용 계정 관리 API 입니다.")
interface AdminUserV1ApiSpec {
    @Operation(summary = "계정 생성", description = "member 권한 계정을 생성합니다.")
    fun createUser(request: CreateUserRequest): ApiResponse<UserSummary>

    @Operation(summary = "계정 목록 조회", description = "member 권한 계정 목록을 이름순으로 조회합니다.")
    fun getUsers(): ApiResponse<List<UserSummary>>

    @Operation(summary = "비밀번호 초기화", description = "지정한 계정의 비밀번호를 초기화합니다.")
    fun resetPassword(id: Long, request: ResetPasswordRequest): ApiResponse<Unit>
}
```

### 2-4c. `interfaces/api/admin/AdminUserV1Controller.kt`

```kotlin
package com.etude.interfaces.api.admin

import com.etude.application.user.UserFacade
import com.etude.domain.auth.UserSummary
import com.etude.interfaces.api.ApiResponse
import jakarta.validation.Valid
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.*

data class CreateUserRequest(
    @field:NotBlank val name: String,
    @field:NotBlank @field:Email val email: String,
    @field:NotBlank val password: String,
)

data class ResetPasswordRequest(
    @field:NotBlank val password: String,
)

@RestController
@RequestMapping("/admin/users")
class AdminUserV1Controller(
    private val userFacade: UserFacade,
) : AdminUserV1ApiSpec {
    @PostMapping
    override fun createUser(@Valid @RequestBody request: CreateUserRequest): ApiResponse<UserSummary> =
        ApiResponse.success(userFacade.createUser(request.name, request.email, request.password))

    @GetMapping
    override fun getUsers(): ApiResponse<List<UserSummary>> =
        ApiResponse.success(userFacade.getAllMembers())

    @PatchMapping("/{id}/password")
    override fun resetPassword(
        @PathVariable id: Long,
        @Valid @RequestBody request: ResetPasswordRequest,
    ): ApiResponse<Unit> {
        userFacade.resetPassword(id, request.password)
        return ApiResponse.success()
    }
}
```

> `/admin/users`, `/admin/users/**`는 이미 Step 1의 `WebConfig`에서 `AdminInterceptor`
> (`addPathPatterns("/admin/**")`)가 관리자 권한을 검증하고 있으므로, 컨트롤러에서 별도로
> role을 확인하지 않습니다.

### 2-4d. `interfaces/api/user/MeV1ApiSpec.kt`, `MeV1Controller.kt`

Step 1의 `AuthV1Controller`에 있던 `GET /me`와 다른 컨트롤러로 분리합니다 — `/me/password`는
"내 계정 관리"에 속하지 "인증(로그인/토큰)"에 속하지 않으므로, `auth` 패키지가 아니라 `user` 패키지에
둡니다 (`GET /me`를 옮기지 않는 이유는 아래 참고).

```kotlin
package com.etude.interfaces.api.user

import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Me V1 API", description = "내 계정 관리 API 입니다.")
interface MeV1ApiSpec {
    @Operation(summary = "비밀번호 변경", description = "현재 비밀번호를 확인한 뒤 새 비밀번호로 변경합니다.")
    fun changePassword(request: ChangePasswordRequest): ApiResponse<Unit>
}
```

```kotlin
package com.etude.interfaces.api.user

import com.etude.application.user.UserFacade
import com.etude.domain.auth.JwtPayload
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import com.etude.interfaces.api.ApiResponse
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.*

data class ChangePasswordRequest(
    @field:NotBlank val currentPassword: String,
    @field:NotBlank val newPassword: String,
)

@RestController
class MeV1Controller(
    private val userFacade: UserFacade,
) : MeV1ApiSpec {
    @PatchMapping("/me/password")
    override fun changePassword(
        @Valid @RequestBody request: ChangePasswordRequest,
        httpRequest: HttpServletRequest,
    ): ApiResponse<Unit> {
        val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
        userFacade.changeOwnPassword(payload.userId, request.currentPassword, request.newPassword)
        return ApiResponse.success()
    }
}
```

> `MeV1ApiSpec.changePassword`의 시그니처가 `HttpServletRequest`를 받지 않는 것처럼 보이지만,
> Kotlin은 인터페이스와 구현체의 파라미터 개수가 달라도 `override`가 시그니처를 완전히 일치시켜야
> 하므로 실제로는 `ApiSpec`에도 `httpRequest: HttpServletRequest` 파라미터를 추가해야 컴파일됩니다.
> Step 1의 `AuthV1ApiSpec.me(request: HttpServletRequest)`와 동일한 패턴입니다 — 위 `MeV1ApiSpec`
> 코드 블록을 그대로 복사하지 말고 파라미터를 맞춰서 작성합니다.

> `GET /me`를 이 컨트롤러로 옮기지 않는 이유: Step 1에서 이미 `AuthV1Controller`에 만들어져 있고,
> 인수 조건도 이미 통과한 상태입니다. "완료된 걸 건드리지 않는다"는 원칙에 따라 그대로 둡니다.
> `/me`, `/me/password`가 서로 다른 컨트롤러 클래스에 있는 게 어색해 보일 수 있지만, URL 경로가
> 같다고 반드시 같은 컨트롤러에 있어야 하는 건 아닙니다 — `/me`는 "지금 로그인한 사용자가 누구인가"
> (인증의 일부), `/me/password`는 "내 계정 정보를 바꾼다"(계정 관리)로 책임이 다릅니다.

---

## 2-5. 통합 테스트 — `UserAdminControllerTest`

`src/test/kotlin/com/etude/interfaces/api/admin/UserAdminControllerTest.kt`

Step 1의 `IntegrationTest`(`com.etude.support.IntegrationTest`)를 상속해 Testcontainers 설정을
재사용합니다. 단위 테스트와 마찬가지로 Kotest `FreeSpec`으로 작성합니다 — `@SpringBootTest`,
`@AutoConfigureMockMvc` 같은 애노테이션은 Kotest 스펙 클래스에도 JUnit5 테스트와 동일하게 적용되므로
(Kotest가 `useJUnitPlatform()` 위에서 동작), `@Autowired lateinit var`도 그대로 쓸 수 있습니다.
다만 `@BeforeEach`는 Kotest 문법이 아니므로, FreeSpec의 `beforeTest { }` 훅으로 바꿉니다.

```kotlin
package com.etude.interfaces.api.admin

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.support.IntegrationTest
import io.kotest.core.spec.style.FreeSpec
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*

@AutoConfigureMockMvc
class UserAdminControllerTest : IntegrationTest(), FreeSpec() {
    // IntegrationTest는 일반 abstract class이므로 FreeSpec과 다중 상속이 안 됨 — 아래 "주의" 참고

    init {
        @Autowired lateinit var mockMvc: MockMvc
        @Autowired lateinit var userJpaRepository: UserJpaRepository
    }
}
```

> **주의 — 위 코드는 컴파일되지 않는다.** Kotlin은 클래스를 하나만 상속할 수 있는데, `IntegrationTest`도
> `FreeSpec`도 둘 다 클래스(인터페이스가 아님)라 동시 상속이 불가능하다. 실제로는 `IntegrationTest` 자체를
> `FreeSpec`을 상속하도록 바꿔야 한다. `IntegrationTest`는 여러 통합 테스트가 공유하는 베이스 클래스이므로,
> 여기를 한 번만 고치면 그 하위의 모든 통합 테스트(`AuthControllerTest`, `UserAdminControllerTest`,
> `BackendKotlinApplicationTests`)가 전부 Kotest 방식으로 통일된다. 구체적인 변경 방법은
> [guide_phase12_kotest_migration.md](guide_phase12_kotest_migration.md)의 "통합 테스트(`IntegrationTest`)
> 전환" 절 참고. 이 Step에서는 `IntegrationTest`를 먼저 그 문서대로 고친 뒤, 아래 완성된 형태로
> `UserAdminControllerTest`를 작성한다.

```kotlin
package com.etude.interfaces.api.admin

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.support.IntegrationTest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*

@AutoConfigureMockMvc
class UserAdminControllerTest(
    @Autowired val mockMvc: MockMvc,
    @Autowired val userJpaRepository: UserJpaRepository,
) : IntegrationTest({

    fun loginAndGetToken(email: String, password: String): String {
        val response = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"$email","password":"$password"}""")
        ).andReturn().response.contentAsString
        return Regex(""""token":"([^"]+)"""").find(response)!!.groupValues[1]
    }

    beforeTest {
        userJpaRepository.deleteAll()
        userJpaRepository.save(
            User(name = "관리자", email = "admin@okestro.com", password = BCryptPasswordEncoder().encode("admin123")!!, role = UserRole.admin)
        )
        userJpaRepository.save(
            User(name = "멤버", email = "member@okestro.com", password = BCryptPasswordEncoder().encode("member123")!!, role = UserRole.member)
        )
    }

    "관리자가 계정을 생성하면" - {
        "member 권한으로 생성된다" {
            val token = loginAndGetToken("admin@okestro.com", "admin123")

            mockMvc.perform(
                post("/admin/users")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"name":"신규","email":"new@okestro.com","password":"password123"}""")
            )
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.email").value("new@okestro.com"))
                .andExpect(jsonPath("$.data.role").value("member"))
        }
    }

    "member 권한으로 계정 생성을 시도하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(
                post("/admin/users")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"name":"신규","email":"new2@okestro.com","password":"password123"}""")
            )
                .andExpect(status().isForbidden)
        }
    }

    "관리자가 계정 목록을 조회하면" - {
        "member만 이름순으로 반환한다" {
            val token = loginAndGetToken("admin@okestro.com", "admin123")

            mockMvc.perform(get("/admin/users").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].email").value("member@okestro.com"))
        }
    }

    "관리자가 비밀번호를 초기화하면" - {
        "새 비밀번호로 로그인할 수 있다" {
            val adminToken = loginAndGetToken("admin@okestro.com", "admin123")
            val memberId = userJpaRepository.findByEmail("member@okestro.com")!!.id

            mockMvc.perform(
                patch("/admin/users/$memberId/password")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"password":"newpass123"}""")
            )
                .andExpect(status().isOk)

            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"email":"member@okestro.com","password":"newpass123"}""")
            )
                .andExpect(status().isOk)
        }
    }

    "본인이 비밀번호를 변경할 때" - {
        "현재 비밀번호가 맞으면 변경된다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(
                patch("/me/password")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"currentPassword":"member123","newPassword":"newpass456"}""")
            )
                .andExpect(status().isOk)

            mockMvc.perform(
                post("/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"email":"member@okestro.com","password":"newpass456"}""")
            )
                .andExpect(status().isOk)
        }

        "현재 비밀번호가 틀리면 401을 반환한다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(
                patch("/me/password")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"currentPassword":"wrong","newPassword":"newpass456"}""")
            )
                .andExpect(status().isUnauthorized)
        }
    }
})
```

> `@Autowired`를 생성자 파라미터로 받는 방식으로 바뀐 이유: Kotest 스펙은 본문이 `init { }` 블록
> (정확히는 생성자 블록)이라 `lateinit var` + `@BeforeEach` 조합보다 생성자 주입이 Kotest 관용구에
> 더 맞는다. Spring이 테스트 클래스를 생성할 때 생성자 파라미터에 `@Autowired`가 있으면 자동으로
> 주입해준다.

**검증**:
```bash
./gradlew test --tests "*.UserServiceTest" --tests "*.UserAdminControllerTest"
```
6개 단위 테스트 + 6개 통합 테스트 모두 통과해야 합니다.

---

## 2-6. 수동 검증 (기존 Node 백엔드와 비교)

```bash
./gradlew bootRun
```

```bash
# 관리자 로그인
TOKEN=$(curl -s -X POST localhost:3001/auth/login -H "Content-Type: application/json" \
  -d '{"email":"admin@okestro.com","password":"<관리자 비밀번호>"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 계정 생성
curl -X POST localhost:3001/admin/users -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"신규","email":"new@okestro.com","password":"password123"}'
# → {"meta":{"result":"SUCCESS",...},"data":{"id":..,"name":"신규","email":"new@okestro.com","role":"member"}}

# 계정 목록 조회
curl localhost:3001/admin/users -H "Authorization: Bearer $TOKEN"

# 비밀번호 초기화
curl -X PATCH localhost:3001/admin/users/<id>/password -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"password":"newpass123"}'

# 본인 비밀번호 변경
curl -X PATCH localhost:3001/me/password -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"currentPassword":"password123","newPassword":"newpass456"}'
```

기존 `backend/`(Node.js)와는 `data`/`meta`로 감싸진 형태가 다릅니다 — `data` 안의 필드명/값만 기존과
동일한지 대조합니다.

---

## 완료 기준

- `UserServiceTest`(단위, MockK) 6개 통과
- `UserAdminControllerTest`(통합, Testcontainers) 6개 통과
- 관리자 토큰으로 계정 생성/목록 조회/비밀번호 초기화 curl 검증에서 `data` 필드가 기존 Node.js
  백엔드와 동일
- `member` 토큰으로 `/admin/users` 호출 시 403
- 본인 비밀번호 변경 성공/실패(현재 비밀번호 불일치) 각각 curl 검증

프론트엔드는 Step 1과 동일한 방침으로 이 Step에서 건드리지 않는다 (spec 문서의 "프론트엔드 연동
방침" 참고 — Step 10에서 일괄 전환).

다음은 Step 3 — `quest` (`Quest`/`QuestSet`/`QuestSetAccess` 엔티티, 채점 제외 CRUD).
