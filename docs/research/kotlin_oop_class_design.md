# 리서치: 객체지향을 잘 지키는 Kotlin 클래스 설계

목적: Step 2에서 `User` 엔티티를 캡슐화하며 계속 헷갈렸던 지점들("생성자에 둘까 본문에 둘까",
"val로 할까 var로 할까", "이 로직을 엔티티에 둘까 서비스에 둘까")을 권위 있는 출처를 근거로
원칙화한다. `docs/research/woowacourse_service_apply_analysis.md`(우아한형제들 `service-apply`
분석)와 짝을 이루는 문서다 — 그쪽이 "실제 프로젝트에서 이렇게 짜더라"였다면, 이 문서는 "왜 그렇게
짜는 게 맞는지"를 원전에서 확인한 것이다.

각 섹션은 **원칙 → 이유/근거(출처 포함) → Before/After 예시 → Etude 적용**의 순서로 구성했다.

---

## 1. 주 생성자 vs 클래스 본문(body) — 언제 나눠 쓰는가

**원칙**: 단순히 값을 받아서 그대로 저장하는 프로퍼티는 주 생성자에서 끝낸다. 검증이 필요하면
`init` 블록을 쓰고, 캡슐화(외부에서 재대입 금지)가 필요한 프로퍼티만 클래스 본문에서 재선언한다.

> **개념 노트 — `init` 블록이란?**
> 주 생성자는 파라미터 목록만 가질 수 있고 실행 코드를 담을 수 없다. 생성 시점에 검증이나 부가
> 로직이 필요하면 `init { }` 블록에 쓴다. 실행 순서는 "프로퍼티 초기화 → `init` 블록 →
> 2차 생성자 본문"이다 — 즉 생성자 파라미터가 프로퍼티로 다 채워진 뒤에 `init`이 돈다.

```kotlin
// Before — 2차 생성자로 억지로 검증
class User {
    val email: String
    constructor(email: String) { this.email = email }
}

// After — init 블록으로 검증만 분리
class User(val email: String) {
    init { require(email.contains("@")) { "invalid email: $email" } }
}
```

**Etude 적용 — Step 2에서 실제로 겪은 사례**: `User.kt`에서 `email`, `role`은 `val`로 생성자에서
바로 끝내지만(재대입 자체가 없으니 그걸로 충분), `name`, `password`는 "생성 후에도 값이 바뀌지만
`private`으로 잠가야 하는" 프로퍼티라서 주 생성자엔 타입 없는 파라미터로만 받고, 클래스 본문에서
`private set`/`private` 프로퍼티로 재선언했다:

```kotlin
class User(
    name: String,                                    // 그냥 값 — 프로퍼티 아님
    @Column(...) val email: String,                   // 재대입 없음 → 생성자에서 끝
    password: String,
    @Enumerated(...) @Column(...) val role: UserRole = UserRole.member,
) : BaseEntity() {
    @Column(...)
    final var name: String = name                     // 캡슐화 필요 → 본문에서 재선언
        private set

    @Column(...)
    private final var password: String = password     // 더 엄격하게 잠금(읽기도 막음)

    fun changeName(newName: String) { name = newName }
    fun changePassword(encodedPassword: String) { password = encodedPassword }
}
```

이 판단(어떤 필드를 생성자에서 끝내고 어떤 필드를 본문으로 옮길지)의 기준은 정확히 이 섹션의
원칙과 같다 — **"재대입이 필요 없다(`val`) → 생성자에서 끝"**, **"재대입이 필요하지만 아무나
바꾸면 안 된다(`private set`) → 본문에서 재선언"**.

출처: [Classes | Kotlin Docs](https://kotlinlang.org/docs/classes.html), Effective Kotlin
Item 33 — 생성자에는 상태 초기화에 필요한 파라미터만, 본문에는 기본값/파생 프로퍼티를 두라는
구분 ([kt.academy](https://kt.academy/article/ek-constructor))

### 1-1. `private set` + `final` vs `protected set` — JPA `allOpen` 환경에서의 선택

Step 2에서 `private set`을 쓰다가 `Private setters for open properties are prohibited` 에러를
겪었다(원인: `build.gradle.kts`의 `allOpen { annotation("jakarta.persistence.Entity") }`가
`@Entity` 클래스를 자동으로 `open`으로 만들고, `open` 클래스의 프로퍼티는 기본적으로 오버라이드
가능해서 `private set`과 충돌). 이때 택한 해법은 프로퍼티에 `final`을 명시해 "이것만은 오버라이드
불가"로 못박는 것이었다.

**대안이 하나 더 있다는 걸 실험으로 확인했다**: `final` 없이 `protected set`만 써도 컴파일이
된다.

```kotlin
// 방식 A — Step 2에서 실제로 쓴 방식
final var name: String = name
    private set

// 방식 B — final 없이 protected set (실험으로 컴파일 성공 확인)
var name: String = name
    protected set
```

**왜 `protected set`은 `final` 없이도 되는가**: Kotlin이 "오버라이드 가능한 프로퍼티에
`private set`을 금지"하는 이유는, 서브클래스가 그 프로퍼티를 오버라이드하면서 가시성을 넓혀버릴
수 있어서(`private`보다 넓은 범위로 재정의) 부모의 "아무도 못 바꾼다"는 보장이 깨지기 때문이다.
`protected`는 애초에 "서브클래스는 접근 가능"이라는 가시성이라, 서브클래스가 오버라이드해도
`protected`이거나 그보다 넓은 범위로만 재정의할 수 있을 뿐 이 규칙과 충돌하지 않는다.

**어느 쪽을 쓸까**: JetBrains 공식 `kotlin-agent-skills`(JPA 엔티티 매핑 가이드)는 DB가 생성하는
`id` 필드 같은 경우 `protected set`을 쓰는 걸 표준 패턴으로 제시한다 — "이 클래스와 그 서브클래스
안에서는 만질 수 있어야 하지만, 그 바깥에서는 절대 안 된다"는 의도이기 때문이다. `User.name`처럼
"이 클래스 자신조차 서브클래스가 없고, 정말 완전히 이 클래스 안에서만 바뀌어야 한다"는 의도가
명확하면 `final` + `private set`이 더 정확한 표현이다. 두 방식 다 외부 코드에서 대입을 막는다는
결과는 동일하므로, 팀 컨벤션에 따라 하나로 통일해도 된다 — Etude는 지금 `final` + `private set`을
쓰고 있으니 이후 엔티티도 이 방식으로 통일하는 걸 권장한다(서브클래스가 없는 엔티티라면 `protected`
보다 `private`이 의도를 더 정확히 드러낸다).

출처: JetBrains 공식 GitHub — [kotlin-agent-skills, JPA entity mapping 스킬](https://github.com/Kotlin/kotlin-agent-skills/blob/main/skills/kotlin-backend-jpa-entity-mapping/SKILL.md), [JPA Buddy — Best Practices and Common Pitfalls of Using JPA with Kotlin](https://jpa-buddy.com/blog/best-practices-and-common-pitfalls/)

---

## 2. `val`/`var` 선택 기준

**원칙**: 기본은 `val`. 재할당이 실제로 필요할 때만 `var`를 쓴다. 컬렉션도 값이 바뀔 일이 없다면
가변 컬렉션(`MutableList`)이 아니라 읽기 전용 인터페이스(`List`, `Set`)로 선언한다.

**근거**: Kotlin 공식 코딩 컨벤션 — "Always declare local variables and properties as `val`
rather than `var` if they are not modified after initialization." (초기화 이후 값이 안 바뀐다면
항상 `val`로 선언하라.)

```kotlin
// Before — 딱히 재할당이 필요 없는데 var + mutableListOf
var result = mutableListOf<User>()
for (u in repo.findAll()) if (u.isActive) result.add(u)

// After — val + 함수형 연산자
val result = repo.findAll().filter { it.isActive }
```

**DDD 관점과의 연결** (`woowacourse_service_apply_analysis.md`의 0-3 "값 객체" 섹션 참고):
값 객체는 애초에 "값이 같으면 같은 것"이라는 정의상 불변이어야 한다 — 그래서 값 객체는 필드 전부를
`val`로 선언하는 게 자연스럽다(Kotlin의 `data class`가 기본적으로 이 형태를 유도한다). 반대로
엔티티는 "시간이 지나며 상태가 바뀌는 대상"이 본질이라 `var`가 필요한 필드가 생기는데, 그 `var`를
`public`으로 열어둘지 `private set`으로 잠글지가 다음 섹션(캡슐화)의 주제다.

**Etude 적용**: `User`의 `email`, `role`이 `val`인 것도 이 원칙 그대로다 — 이메일과 권한은
지금 시점에 변경 기능 자체가 없으므로(Node.js 원본에도 없음) `val`로 "변경 자체가 불가능하다"는
사실을 타입 시스템으로 못박아둔다. `name`, `password`가 `var`인 이유는 실제로 바뀔 수 있는
값이기 때문이다.

출처: [Coding Conventions | Kotlin Docs](https://kotlinlang.org/docs/coding-conventions.html)

---

## 3. 캡슐화 — Kotlin에서 세터를 어떻게 다루는가 (Tell, Don't Ask)

**원칙**: 객체의 내부 상태를 꺼내와서 외부에서 판단한 뒤 그 결과를 다시 객체에 밀어넣지 말고,
객체에게 "무엇을 하라"고 지시한다. Kotlin의 프로퍼티 문법(`var`)은 자바의 getter/setter를 자동으로
만들어줄 뿐이지, `public var`로 열어두면 캡슐화 원칙은 여전히 깨진 것이다.

> **개념 노트 — Tell, Don't Ask란?**
> "객체의 상태를 물어보고(Ask) 그 답에 따라 호출부가 상태를 바꾸는" 대신, "객체에게 하고 싶은
> 일을 그대로 지시(Tell)하고 상태를 어떻게 바꿀지는 객체 스스로 결정하게 하라"는 원칙이다. 이걸
> 지키면 "이 상태가 어떻게 바뀔 수 있는가"에 대한 지식이 객체 하나에만 모이고, 호출부 여러 곳에
> 흩어지지 않는다.

**근거**: "You shouldn't make decisions based on the internal state of an object and then
update that object... it spreads the knowledge of the implementation throughout the code."
(객체의 내부 상태를 보고 판단한 뒤 그 객체를 갱신하지 말라 — 그러면 구현에 대한 지식이 코드
전체에 흩어진다.)

```kotlin
// Before (Ask) — 호출부가 User의 내부 규칙(5회 실패 시 잠금)을 알고 있어야 함
class User(var failedLoginCount: Int, var status: String)
fun handleFailedLogin(u: User) {
    u.failedLoginCount += 1
    if (u.failedLoginCount >= 5) u.status = "LOCKED"
}

// After (Tell) — 규칙을 User 자신이 캡슐화
class User(private var failedLoginCount: Int = 0, var status: UserStatus = UserStatus.ACTIVE) {
    fun recordFailedLogin() {
        failedLoginCount += 1
        if (failedLoginCount >= 5) status = UserStatus.LOCKED
    }
}
```

**Etude 적용 — Step 2에서 정확히 이 리팩터링을 했다**: 캡슐화 이전(`user.password = ...`)은
"Ask" 스타일이었다 — `UserService`가 "새 해시값을 계산해서(판단) `User`의 필드에 그대로 밀어넣는다
(갱신)"는 구조였다. 캡슐화 이후(`user.changePassword(...)`)는 "Tell" 스타일이다 — `UserService`는
"비밀번호를 바꿔라"라고 지시만 하고, "값이 실제로 어떻게 바뀌는가"는 `User`가 스스로 안다. 비교도
마찬가지다: `passwordEncoder.matches(password, user.password)`(Ask, `user.password`를 꺼내와서
바깥에서 비교)가 `user.matchesPassword(password, passwordEncoder)`(Tell, "이 비밀번호가 맞는지
너가 판단해")로 바뀌었다.

출처: [How getters and setters harm encapsulation](https://nvoulgaris.com/how-getters-and-setters-harm-encapsulation/)

---

## 4. 행동을 어디에 둘 것인가 — Anemic vs Rich Domain Model

**원칙**: 도메인 객체(엔티티)에 데이터만 있고 모든 로직이 서비스 계층에 있는 설계("빈약한 도메인
모델", Anemic Domain Model)는 안티패턴이다. 데이터와 그 데이터를 다루는 행동을 함께 묶은 설계
("풍부한 도메인 모델", Rich Domain Model)가 객체지향의 본래 목적에 맞다.

> **개념 노트 — Anemic Domain Model이 왜 문제인가?**
> Martin Fowler는 이렇게 설명한다: "The catch comes when you look at the behavior, and you
> realize that there is hardly any behavior on these objects, making them little more than
> bags of getters and setters."(문제는 행동을 들여다볼 때 나타난다 — 이 객체들에 행동이 거의
> 없다는 걸 알게 되고, 결국 getter/setter 뭉치에 불과해진다.) 그리고 더 직접적으로: "The anemic
> domain model is really just a procedural style design... If all your logic is in services,
> you've robbed yourself blind."(빈약한 도메인 모델은 사실 절차적 스타일 설계일 뿐이다 — 모든
> 로직이 서비스에 있다면, 스스로를 눈뜨고 도둑맞은 셈이다.)
>
> 문제의 핵심은 "객체지향"이라는 이름을 달고 있지만 실제로는 데이터(엔티티)와 알고리즘(서비스)이
> 완전히 분리된 절차적 프로그래밍이라는 점이다 — 캡슐화의 이점(상태와 그 상태를 다루는 규칙이
> 항상 함께 있다는 보장)을 전혀 못 누린다.

```kotlin
// Before (Anemic) — User는 상태만, 규칙은 서비스에
class User(var status: UserStatus, var passwordHash: String)
class UserService {
    fun deactivate(u: User) {
        if (u.status == UserStatus.LOCKED) throw IllegalStateException()
        u.status = UserStatus.INACTIVE
    }
}

// After (Rich) — 규칙이 User 자신에게
class User(var status: UserStatus, private set, private var passwordHash: String) {
    fun deactivate() {
        check(status != UserStatus.LOCKED) { "locked user cannot deactivate" }
        status = UserStatus.INACTIVE
    }
}
class UserService(private val repo: UserRepository) {
    fun deactivate(id: Long) {
        val u = repo.findById(id) ?: throw UserNotFoundException(id)
        u.deactivate()
        repo.save(u)
    }
}
```

**Etude 적용**: `UserService.resetPassword()`/`changeOwnPassword()`가 정확히 "After" 형태로
이미 짜여 있다 — 서비스는 "리포지토리에서 찾고, 도메인 객체에게 지시하고, 저장한다"는 오케스트레이션
만 하고, "비밀번호가 어떻게 바뀌는지/일치하는지"라는 규칙은 `User`가 갖고 있다. 이게 바로 Rich
Domain Model이다. `woowacourse_service_apply_analysis.md`의 `ApplicationForm.submit()` /
`checkSubmitted()`도 같은 사례다 — "이미 제출된 지원서는 다시 제출 못 한다"는 규칙이 서비스가
아니라 `ApplicationForm` 자신에게 있다.

**주의할 점**: 이 원칙이 "모든 로직을 무조건 엔티티에 욱여넣어라"는 뜻은 아니다. 여러 애그리게잇을
가로지르는 조율(예: "이 사용자가 만든 계정을 저장하고, 그 결과를 응답 DTO로 변환한다")은 서비스의
정당한 몫이다. 판단 기준은 "이 로직이 한 객체의 내부 상태/불변식만 다루는가"(그렇다면 엔티티) vs
"여러 객체/리포지토리를 오가며 흐름을 조율하는가"(그렇다면 서비스)다.

출처: [AnemicDomainModel - Martin Fowler's Bliki](https://martinfowler.com/bliki/AnemicDomainModel.html)

---

## 5. `companion object` vs `object` — 언제 쓰는가

**원칙**: `object`는 애플리케이션 전역에서 단 하나만 존재해야 하는 진짜 싱글톤에 쓴다(지연
초기화). `companion object`는 특정 클래스에 종속된 정적 멤버(팩토리 메서드, 상수, 확장 함수 등)에
쓴다(클래스가 로드되는 시점에 즉시 초기화 — 자바의 `static`과 같은 시맨틱).

```kotlin
// Before — companion을 전역 싱글톤처럼 오용 (클래스와 무관한 전역 상태를 companion에 둠)
class UserRepositoryImpl(...) {
    companion object { val globalCache = mutableMapOf<Long, User>() }
}

// After — 역할을 정확히 분리
class UserRepositoryImpl(...) : UserRepository {
    companion object { fun UserEntity.toDomain() = User(id, email, nickname) }  // 팩토리/변환 헬퍼
}
object AppClock { fun now(): Instant = Instant.now() }  // 진짜 전역 싱글톤
```

**Etude 적용**: Step 1의 `IntegrationTest`(`com.etude.support.IntegrationTest`)의
`companion object { @Container @ServiceConnection val mariaDb = MariaDBContainer(...) }`가
이 패턴이다 — `MariaDBContainer`는 "`IntegrationTest`를 상속하는 모든 테스트가 공유하는 정적
자원"이라 companion object가 정확히 맞는 선택이었다(전역 싱글톤이 아니라 이 클래스 계층에
종속된 자원이므로 `object`가 아니라 `companion object`).

출처: [Object declarations and expressions | Kotlin Docs](https://kotlinlang.org/docs/object-declarations.html)

### 5-1. `companion object` + `private constructor` — 팩토리 메서드로 "항상 유효한 객체"만 만들기

**원칙**: 생성 시점에 검증이 필요하거나, 생성자 이름만으로는 의도가 드러나지 않는 경우, 주 생성자를
`private`으로 감추고 `companion object`에 의미 있는 이름의 팩토리 함수를 둔다. 이렇게 하면 "이
클래스의 인스턴스는 항상 이 팩토리를 거쳐야만 만들어질 수 있다"를 컴파일러가 강제한다 — 검증을
빼먹은 채로 생성자를 직접 호출하는 경로 자체가 없어진다.

```kotlin
class Order private constructor(
    val customerId: Long,
    var status: OrderStatus,
    var total: BigDecimal
) {
    companion object {
        fun create(customerId: Long, items: List<OrderItem>): Order {
            require(items.isNotEmpty()) { "주문 항목이 비어있을 수 없습니다" }
            val total = items.sumOf { it.price * it.quantity }
            return Order(customerId, OrderStatus.CREATED, total)
        }
    }
}
val order = Order.create(customerId = 1L, items = cartItems)
```

**Etude 적용**: 지금 `User`는 `AuthService`/`UserService`가 `User(name = ..., email = ..., ...)`를
생성자로 직접 호출하고 있다. 지금은 검증이 거의 없어서(이메일 형식 등은 `@field:Email`처럼
컨트롤러의 Bean Validation이 이미 처리) 문제가 없지만, 나중에 "가입 시점에만 적용되는 규칙"(예:
이메일 도메인 화이트리스트, 초기 비밀번호 강도 검사)이 생기면 `User.register(name, email,
rawPassword, passwordEncoder)` 같은 팩토리 함수로 옮기는 걸 고려할 만하다 — 지금 당장 필요하진
않다.

출처: [DZone — Factory Pattern in Kotlin](https://dzone.com/articles/factory-pattern-in-kotlin), [Baeldung on Kotlin — Companion Object](https://www.baeldung.com/kotlin/companion-object)

---

## 6. 인터페이스 설계 — 언제 만들고, `fun interface`는 언제 쓰는가

**원칙**: 인터페이스는 "구현을 교체할 수 있어야 한다" 또는 "테스트에서 가짜 구현으로 대체해야
한다"는 실질적 필요가 있을 때 만든다. 메서드가 하나뿐인 "복잡한 계약"(여러 파라미터, 명확한 이름이
필요한 경우)일 때만 `fun interface`(SAM)를 쓰고, 단순한 함수 시그니처면 함수 타입 자체로 충분하다.

**근거**: Effective Kotlin 저자 Marcin Moskała — "by hiding objects behind an interface, we
abstract away any actual implementation... we reduce coupling."(인터페이스 뒤로 객체를 숨기면
실제 구현을 추상화해서 결합도를 낮춘다.) 다만 추상화에는 이해 비용이 따르므로 남용을 경계해야
한다고도 짚는다. Kotlin 공식 문서는 `fun interface`를 "API가 더 복잡한 개체를 받아들이는 경우...
함수 타입의 시그니처로 표현할 수 없는 자명하지 않은 계약이 있는 경우"에만 쓰라고 권한다.

```kotlin
// Before — 불필요한 인터페이스 (구현이 하나뿐이고 교체 계획도 없음)
interface EmailValidator { fun validate(email: String): Boolean }
class RegexEmailValidator : EmailValidator { override fun validate(e: String) = e.contains("@") }

// After — 단순 계약은 함수 타입으로 충분
typealias EmailValidator = (String) -> Boolean
val regexEmailValidator: EmailValidator = { it.contains("@") }

// 진짜 디커플링이 필요한 경우는 인터페이스 유지
interface UserRepository { fun findByEmail(email: String): User?; fun save(user: User): User }
class UserRepositoryImpl(private val jpa: UserJpaRepository) : UserRepository { ... }
```

**Etude 적용**: `UserRepository`, `PasswordEncoder`, `JwtProvider`가 전부 정확히 "진짜 디커플링이
필요한 경우"다 — 도메인 계층(`AuthService`, `UserService`)이 JPA/BCrypt/jjwt라는 구체적인 구현을
몰라야 한다는 헥사고날 아키텍처의 요구가 명확하기 때문이다. 반대로 `fun interface`가 어울리는
후보는 아직 Etude에 없지만, `woowacourse_service_apply_analysis.md`의 4-2에서 짚었듯 Step 3의
퀘스트 접근 권한 검사, Step 7의 채점 조건 검사처럼 "메서드 하나짜리 정책"이 생기면 그때 고려할
만하다.

출처: [Item 26: Use abstraction to protect code against changes | kt.academy](https://kt.academy/article/ek-abstraction-code-changes), [Functional (SAM) interfaces | Kotlin Docs](https://kotlinlang.org/docs/fun-interfaces.html)

### 6-1. 인바운드/아웃바운드 포트 네이밍 — 실제 국내 헥사고날 사례

우아한형제들 기술블로그의 "Spring Boot Kotlin Multi Module로 구성해보는 헥사고날 아키텍처" 글은
포트 이름 짓는 방식을 구체적으로 보여준다:

- **아웃바운드 포트**(도메인이 인프라에 요청하는 쪽, Etude의 `UserRepository`에 해당):
  `MerchantSettingManagementOutputPort`처럼 **역할 + `OutputPort`** 접미사. Application 계층이
  인터페이스를 정의하고, Framework(인프라) 계층이 구현한다.
- **인바운드 포트**(외부가 도메인에 요청하는 쪽, Etude로 치면 컨트롤러가 호출하는 서비스 인터페이스):
  `MerchantSettingRetrieveUseCase { fun getOrCreateDefault(merchantNo: String): MerchantSetting }`
  처럼 **동사 + `UseCase`** 접미사. 파라미터/반환값이 전부 도메인 객체(`MerchantSetting`)이고
  프레임워크 타입(HTTP 요청/응답, JPA 엔티티 등)이 시그니처에 전혀 노출되지 않는다.
- 의존성 방향: 인바운드 포트 구현체가 아웃바운드 포트 인터페이스에 의존 → 인프라(어댑터)를
  자유롭게 교체할 수 있다.

**Etude 적용**: 지금 Etude는 `UserRepository`(아웃바운드)는 있지만, `AuthService`/`UserService`
자체를 인터페이스로 분리하지는 않았다(구현 클래스를 컨트롤러가 직접 참조). 지금 규모(구현체가
하나뿐이고 교체 계획도 없음)에서는 이게 맞는 선택이다 — 6번 섹션의 원칙("구현이 하나뿐이고 바뀔
계획도 없으면 인터페이스 없이 클래스 하나로 충분한지 재고")과 일치한다. 다만 나중에 "동일한
유스케이스를 여러 방식으로 구현해야 하는" 상황(예: 채점 로직이 sandbox 타입별로 크게 달라지는
Step 6~7)이 생기면, `~UseCase` 인터페이스로 분리하는 걸 고려할 만하다.

출처: [우아한형제들 기술블로그 — Spring Boot Kotlin Multi Module로 구성해보는 헥사고날 아키텍처](https://techblog.woowahan.com/12720/)

---

## 7. `data class` vs 일반 `class` — 특히 JPA 엔티티에서

**원칙**: 값 객체(식별자 없이 값 자체로 동일성을 판단하는 대상)는 `data class`가 적합하다. 반면
JPA `@Entity`처럼 식별자(ID) 기반의 정체성을 가진 엔티티는 `data class`를 피하거나, 쓰더라도
`equals`/`hashCode`를 직접 오버라이드해야 한다.

> **개념 노트 — 왜 `data class` + JPA 엔티티가 함정인가?**
> `data class`는 주 생성자의 프로퍼티만 갖고 `equals`/`hashCode`/`copy()`를 자동 생성한다. 문제는
> JPA 엔티티의 `id`가 보통 `null`(아직 저장 안 됨) → `실제 값`(저장 후 DB가 채워줌)으로 바뀐다는
> 점이다. `id`가 `equals`/`hashCode` 계산에 포함되면, **저장 전과 저장 후에 같은 객체의
> `hashCode()`가 달라진다.** 이 객체를 `HashSet`에 넣어뒀다면, 저장 후엔 그 객체를 찾을 수 없게
> 된다(해시 버킷이 달라졌으므로). Vlad Mihalcea(Hibernate 핵심 기여자)의 권장 해법은
> `hashCode()`를 아예 클래스 기준 상수로 고정하고, `equals()`는 `id`가 `null`이 아닐 때만
> 비교하는 것이다. jpa-buddy.com의 실증 분석도 같은 결론에 도달한다 — 결국 `data class`를 JPA
> 엔티티에 안전하게 쓰려면 `equals`/`hashCode`를 직접 오버라이드해야 하는데, 그러면 애초에
> `data class`를 쓰는 이점(자동 생성) 자체가 무의미해진다.

```kotlin
// Before — 흔한 함정
@Entity
data class UserEntity(@Id @GeneratedValue val id: Long? = null, val email: String, val nickname: String)

// After — 일반 class + ID 기반 equals/hashCode
@Entity
class UserEntity(@Id @GeneratedValue val id: Long? = null, var email: String, var nickname: String) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is UserEntity) return false
        return id != null && id == other.id
    }
    override fun hashCode(): Int = javaClass.hashCode()
}

// 값 객체는 여전히 data class가 적합
data class Email(val value: String) { init { require(value.contains("@")) } }
```

**Etude 적용**: `User.kt`가 처음부터 일반 `class`였던 게(가이드가 `data class User(...)`가 아니라
`class User(...) : BaseEntity()`로 썼던 것) 바로 이 문제를 피한 것이다. `BaseEntity`(Step 0b에서
`modules/jpa`에 만든 공통 베이스)를 확인해볼 가치가 있다 — 만약 `equals`/`hashCode`를 `id` 기준으로
이미 구현해뒀다면 이 원칙을 이미 지키고 있는 것이고, 아니라면(예: 기본 `Object.equals`를 그대로
씀) Step 3 이후 엔티티가 늘어나기 전에 `BaseEntity`에 한 번만 이 패턴을 구현해두는 게 안전하다 —
모든 엔티티가 `BaseEntity`를 상속하므로, 거기 한 번 구현하면 이후 만드는 모든 엔티티에 자동으로
적용된다.

출처: [Data classes | Kotlin Docs](https://kotlinlang.org/docs/data-classes.html), [Vlad Mihalcea - equals/hashCode with JPA identifier](https://vladmihalcea.com/how-to-implement-equals-and-hashcode-using-the-jpa-entity-identifier/), [jpa-buddy.com - Kotlin JPA pitfalls](https://jpa-buddy.com/blog/best-practices-and-common-pitfalls/)

---

## 종합 — 체크리스트로 정리

새 도메인 클래스(엔티티/서비스)를 만들 때 스스로 물어볼 질문들:

1. **이 필드는 생성 이후에 값이 바뀌는가?**
   - 아니오 → `val`, 생성자에서 끝.
   - 예 → 다음 질문으로.
2. **이 필드를 아무 코드나 마음대로 바꿔도 괜찮은가?**
   - 예(단순 데이터) → `var`로 두되, 정말 규칙이 없는지 한 번 더 의심해본다.
   - 아니오(규칙이 있음/있을 수 있음) → 클래스 본문에서 `private set`(또는 완전히 `private`)으로
     재선언하고, 의미 있는 이름의 메서드(`changeX()`, `matchesX()`)로만 바꿀 수 있게 한다.
     JPA `@Entity`(`allOpen`으로 클래스가 자동 `open`)라서 `private set`이 컴파일 에러가 나면,
     `final`을 프로퍼티 앞에 붙이거나(오버라이드 자체를 막음, 서브클래스가 없는 리프 엔티티에 적합)
     `protected set`을 쓴다(서브클래스는 접근 가능해야 하는 경우, `final` 불필요 — 1-1 참고).
3. **이 로직은 한 객체의 내부 상태/불변식만 다루는가, 여러 객체를 조율하는가?**
   - 한 객체만 → 그 객체(엔티티)의 메서드로.
   - 여러 객체 조율 → 서비스의 메서드로.
4. **이 타입은 식별자로 구분되는가(엔티티), 값 자체로 구분되는가(값 객체)?**
   - 엔티티(특히 JPA `@Entity`) → 일반 `class` + `id` 기반 `equals`/`hashCode`.
   - 값 객체 → `data class`.
5. **이 인터페이스는 실제로 구현이 여러 개가 되거나 테스트에서 대체돼야 하는가?**
   - 예 → 인터페이스로 분리. 아웃바운드(리포지토리 등)는 `~Repository`/`~OutputPort`, 인바운드
     (유스케이스)는 `~UseCase`처럼 역할이 이름에서 드러나게 짓는다(6-1 참고).
   - 아니오(구현이 하나뿐이고 바뀔 계획도 없음) → 인터페이스 없이 클래스 하나로 충분한지 재고.
   - 메서드가 하나뿐이고 계약이 단순 → 함수 타입/`typealias`. 계약이 복잡(여러 의미있는 파라미터,
     이름이 필요) → `fun interface`.
6. **이 객체는 생성 시점에 검증이 필요하거나, 생성자만으로 의도가 잘 안 드러나는가?**
   - 예 → 주 생성자를 `private`으로 감추고 `companion object`에 의미 있는 이름의 팩토리 함수를
     둔다(5-1 참고). 검증을 빼먹은 채 생성자를 직접 호출하는 경로 자체를 없앤다.
   - 아니오 → 지금처럼 생성자를 그대로 공개해도 무방.
