# 분석: `cafekiosk` (Java/Spring, TDD 실전 예제)

분석 대상: `/Users/jihochoi/Documents/study/cafekiosk` (커밋 `f978a66 Spring REST Docs`까지 진행된 시점)

목적: Etude의 Kotlin 백엔드 마이그레이션(Phase 12)에 참고할 만한 패턴을 뽑아낸다. `cafekiosk`는
Java 기반 TDD 실전 예제 레포로, 우아한형제들 `service-apply`(Kotlin/DDD, 별도 문서
[woowacourse_service_apply_analysis.md](woowacourse_service_apply_analysis.md) 참고)와는 결이
다르다 — 애그리게잇/도메인 이벤트 같은 DDD 개념보다 **테스트를 어떻게 촘촘하게 짜는가**에 무게가
실려 있다.

**중요도 안내**: 이 문서가 다루는 패턴들은 지금 Etude 진행에 급하게 필요한 것은 아니다. Etude에
이미 적용된 방식(Testcontainers, Kotest, `TestAuth`/`TestUsers` 픽스처 등)이 있다면 그쪽을
우선하고, 이 문서는 "나중에 테스트 계층을 다듬을 때" 참고하는 용도로 남겨둔다.

---

## 1. 프로젝트 구조 — 레이어 우선, 도메인 패키지는 얕음

`sample.cafekiosk.spring` 아래 `api/controller`, `api/service`, `domain/{product,order,
orderproduct,stock,history}`로 나뉜다. Etude와 동일하게 **레이어 우선** 구조지만, `domain/` 아래는
엔티티 + 리포지토리 정도로 얕고 대부분의 로직이 `api/service`에 몰려 있다.

**Etude 적용**: Etude가 이미 레이어 우선 구조를 쓰고 있으므로 구조 자체를 바꿀 이유는 없다. 다만
"도메인 로직이 서비스에 쏠리는" 경향은 Etude가 지금 하고 있는 것(엔티티에 `changePublic()` 같은
행동 메서드를 두는 것)과는 반대 방향이라 — cafekiosk 쪽이 아니라 지금 Etude 방식을 유지하는 게
낫다.

## 2. 도메인 모델링 — 정적 팩토리 + 캡슐화된 생성자

`Product`, `Order`, `Stock` 등 모든 엔티티가 동일한 패턴이다: 생성자를 `protected`/`private`로
잠그고, `Order.create(...)`, `Stock.create(...)` 같은 정적 팩토리 메서드로만 인스턴스를 만든다.
도메인 로직도 엔티티 메서드 안에 있다 — `Stock.deductQuantity()`가 재고 부족을 가드하고 예외를
던진다.

> **개념 노트 — 정적 팩토리 메서드가 생성자보다 나은 이유**
> 생성자는 이름이 없어서 "왜 이 값으로 만드는지"를 드러낼 수 없다. `Order.create(products,
> registeredDateTime)`처럼 이름 있는 메서드는 의도를 드러내고, 생성 시점에 검증 로직을 끼워 넣기도
> 쉽다. Kotlin에서는 `companion object` + `private constructor`로 동일하게 구현한다.

흥미로운 지점 하나는 연관관계 처리다. `Order → OrderProduct`는 JPA 객체 참조(`@OneToMany`)를
쓰지만, `Stock ↔ Product`는 FK가 아니라 `productNumber`라는 **문자열 값**으로 느슨하게 연결하고
서비스 코드에서 Map으로 매칭한다. "이 둘이 같은 트랜잭션에서 항상 함께 갱신되는가?"라는, `service-
apply` 분석에서 다룬 애그리게잇 경계 질문과 같은 기준으로 판단한 것으로 보인다.

**Etude 적용**: 정적 팩토리 + 캡슐화된 생성자는 Etude가 이미 `QuestSet`, `User` 등에서 하고 있는
패턴(`changePublic()`, `changePassword()` 등 행동 메서드)과 방향이 같다 — 새로 배울 건 없지만
검증된 방향이라는 확인 정도. `productNumber` 같은 값 참조 방식은 Etude의 `QuestSetAccess`
(quest_set_id + user_id를 ID로만 참조)와 이미 같은 결정을 하고 있다.

## 3. API 계층 — 2단계 DTO, 그리고 아직 다듬어지지 않은 예외 처리

컨트롤러는 `ProductCreateRequest`(Bean Validation 붙은 웹 계층 DTO)를 받아
`.toServiceRequest()`로 서비스 전용 DTO로 변환한 뒤 서비스에 넘긴다. "컨트롤러 DTO에는 검증
애너테이션을, 서비스 DTO는 순수 값만"이라는 분리 의도다.

예외 처리는 아직 단순하다 — 재고 부족 시 `IllegalArgumentException`을 그냥 던지는 수준으로,
Etude가 이미 하고 있는 도메인 예외 계층(`QuestSetNotFoundException`, `ApiControllerAdvice`의
`@ExceptionHandler`)에 비하면 더 초기 단계다.

**Etude 적용**: 2단계 DTO 변환은 지금 Etude 규모(필드 4~8개)에서는 오히려 보일러플레이트가
늘어나는 방향이라 당장 도입할 필요는 없다 — Etude의 예외 처리(`ErrorType` 중앙관리 + 도메인
예외)가 이미 cafekiosk보다 정교한 상태이므로 참고할 게 적다.

## 4. 테스트 전략 — 이 문서의 핵심

### 4-1. 테스트 베이스 클래스를 목적별로 분리

`IntegrationTestSupport`(`@SpringBootTest` + `@ActiveProfiles("test")`, 외부 연동만
`@MockBean`으로 격리)와 `ControllerTestSupport`(`@WebMvcTest` + 모든 서비스 `@MockBean`) 두
abstract 클래스를 두고, 테스트가 목적에 맞는 쪽을 상속한다. Repository 테스트도
`IntegrationTestSupport`를 상속해 같은 스프링 컨텍스트를 재사용한다 — 커밋 메시지가 "테스트
수행도 비용이다. 환경 통합하기"라고 명시할 만큼 의도적인 선택이다.

**Etude 적용**: Etude의 `IntegrationTest`(Testcontainers + `FreeSpec`)가 이미 이 역할을 하고
있다. 다만 cafekiosk처럼 "가벼운 웹 계층만 격리해서 도는 컨트롤러 테스트"(서비스를 `@MockBean`으로
막고 MockMvc만 검증)는 Etude에 아직 없다 — 지금은 전부 `IntegrationTest`(Testcontainers까지
띄우는 무거운 통합 테스트)뿐이다. 컨트롤러가 늘어나고 테스트 실행 시간이 부담스러워지는 시점에,
"인증/라우팅/직렬화만 검증하면 되는 케이스"를 가벼운 `@WebMvcTest` 스타일로 분리하는 걸 고려할
만하다 — 지금 당장은 필요하지 않다.

### 4-2. Mock 사용 원칙 — 계층마다 다르게

- 순수 단위 테스트: Mockito `@Mock`/`@InjectMocks` + `BDDMockito.given(...).willReturn(...)`
- 컨트롤러 테스트: 서비스 계층을 전부 `@MockBean`으로 막고 MockMvc로 HTTP만 검증
- **서비스(Business) 레이어 테스트는 반대로 mock을 쓰지 않고** 실제 리포지토리 + DB까지 태워서
  검증한다

**Etude 적용**: Etude는 이미 `QuestServiceTest`(mockk로 리포지토리를 목킹하는 순수 단위 테스트)와
`QuestControllerTest`/`AdminQuestSetControllerTest`(Testcontainers까지 띄우는 통합 테스트) 두
층으로 나뉘어 있어 cafekiosk의 원칙과 이미 같은 방향이다. 새로 배울 것은 크지 않지만, "서비스
레이어는 mock 없이 실제 DB로 검증한다"는 명시적 원칙은 Etude에도 문서화해둘 가치가 있다 — 지금은
암묵적으로 그렇게 하고 있을 뿐 어디에도 적혀 있지 않다.

### 4-3. Fixture는 클래스마다 private 헬퍼 — 개선 여지

ObjectMother나 공용 Fixture 클래스 없이, 테스트 클래스마다 `private fun createProduct(...)`
같은 헬퍼를 각자 정의한다. 빌더 기반이라 헬퍼 자체는 짧지만, 같은 모양의 헬퍼가 여러 테스트
클래스에 중복된다.

**Etude 적용**: 이 부분은 오히려 Etude가 오늘 이미 cafekiosk보다 한 단계 나은 방향으로
가있다 — `TestUsers`/`TestAuth`(`support` 패키지의 공용 오브젝트)로 여러 테스트 클래스가 공유하는
픽스처를 만들어뒀다. cafekiosk 방식(클래스마다 private 헬퍼)으로 되돌아갈 이유는 없다. 다만
`QuestSet`/`Quest` 생성부는 아직 각 테스트 파일에 직접 남아있으니(우아한형제들 분석 문서에서도
짚은 지점), 다음에 정리할 때 `TestQuestSets` 같은 공용 오브젝트로 뽑는 게 cafekiosk 방식보다도
나은 선택이다.

### 4-4. `@DisplayName` 문장형 관용구

모든 테스트가 한국어 문장형 `@DisplayName`을 쓰고, `given/when/then` 주석 스타일이 일관된다.

**Etude 적용**: Etude가 Kotest `FreeSpec`의 중첩 문자열 스타일(`"관리자가 계정을 생성하면" -
{ "member 권한으로 생성된다" { ... } }`)로 이미 문장형 테스트명을 쓰고 있다 — cafekiosk의
`@DisplayName`보다 오히려 더 자연스러운 방식(Kotest 프레임워크 차원의 지원)이라 배울 게 없다.

### 4-5. 그 외 — REST Docs, 동적 테스트

`RestDocsSupport` + asciidoctor로 API 문서를 테스트에서 자동 생성하는 패턴, `@TestFactory` +
`DynamicTest`로 시나리오 기반 테스트를 짜는 예시가 있다. Etude는 이미 springdoc-openapi로 API
문서를 자동 생성하고 있어 REST Docs는 중복 도입 가치가 낮다. 동적 테스트는 Kotest의
`forAll`/`withData` 같은 데이터 기반 테스트 기능으로 대체 가능하나, 지금 Etude 테스트 규모에서
급하게 필요하지는 않다.

---

## 5. Java 특유 관용구 — Kotlin에서는 자연히 사라지거나 달라짐

| Java(cafekiosk) | Kotlin(Etude)에서의 대응 |
|---|---|
| `@Getter`/`@Builder`/`@NoArgsConstructor`(Lombok) | 언어 기본 기능(주 생성자, named argument)으로 대체 — 애너테이션 자체가 불필요 |
| `Optional<T>` 또는 그냥 `null` 반환 | nullable 타입(`T?`)으로 명시적 표현, 오히려 Kotlin이 더 안전 |
| `Collectors.toMap`/`groupingBy` | `associateBy`/`groupingBy` 확장 함수로 더 간결 |
| `@RequiredArgsConstructor`(생성자 주입) | 주 생성자 자체로 대체, 보일러플레이트 자체가 사라짐 |
| Mockito `BDDMockito` 스타일 | MockK의 `every { } returns` 스타일로 재작성 필요(문법은 다르지만 이미 Etude가 mockk를 쓰고 있음) |

---

## 종합 판단: 지금 Etude에 적용할 가치가 있는 것 (낮은 우선순위)

1. **"서비스 레이어는 mock 없이 실제 DB로 검증한다"는 원칙을 문서화** — 이미 그렇게 하고 있으니
   비용은 거의 없고, 나중에 합류하는 사람이 판단 기준을 알 수 있게 된다.
2. **컨트롤러가 늘어나 통합 테스트 실행 시간이 부담스러워지면** cafekiosk의 `ControllerTestSupport`
   (`@MockBean`으로 서비스를 막은 가벼운 웹 계층 테스트)를 고려. 지금은 필요 없다.
3. **`QuestSet`/`Quest` 등 필드 많은 엔티티의 fixture를 `TestUsers`처럼 공용 오브젝트로 뽑기** —
   cafekiosk보다 이미 한발 앞서 있는 방향이니, 이어서 마저 정리하면 된다.

나머지(2단계 DTO 변환, REST Docs, 동적 테스트)는 지금 Etude 규모나 이미 갖춘 도구(springdoc,
Kotest)를 감안하면 도입 비용 대비 得이 낮다.
