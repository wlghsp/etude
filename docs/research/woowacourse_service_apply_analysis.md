# 분석: 우아한형제들 `service-apply` (Kotlin/Spring)

분석 대상: `/Users/jihochoi/Documents/study/woowacourse/service-apply`

목적: Etude의 Kotlin 백엔드 마이그레이션(Phase 12)에 참고할 만한 패턴을 뽑아낸다. Etude가 지금
쓰고 있는 것과 겹치는 부분은 "비교"로, 새로 배울 만한 개념은 "개념 노트"를 붙여 설명한다.

이 문서는 코드를 그대로 옮겨 적용하라는 지시서가 아니다 — 각 패턴마다 "왜 좋은가"와 "Etude에 지금
당장 필요한가"를 따로 판단할 수 있게 근거와 트레이드오프를 함께 적는다.

---

## 0. DDD(Domain-Driven Design) 관점에서 보기

이 레포는 DDD(도메인 주도 설계) 스터디 레포로 알려져 있다. 아래 섹션들에서 다루는 패턴들이 사실은
DDD의 특정 개념을 Kotlin/Spring으로 구현한 것이므로, DDD 용어와 먼저 연결해두면 나머지 섹션이
"왜 이렇게 짰는가"까지 이해하기 쉬워진다.

> **개념 노트 — DDD가 뭔가?**
> 코드를 "테이블과 CRUD"가 아니라 "비즈니스가 실제로 쓰는 언어와 규칙"을 중심으로 설계하는
> 방법론이다. 핵심 도구가 몇 가지 있다: **엔티티**(고유 식별자로 구분되는 객체, 상태가 바뀌어도
> 같은 대상), **값 객체**(식별자가 없고 값 자체로 동일성을 판단하는 객체, 불변), **애그리게잇**
> (함께 일관성을 유지해야 하는 엔티티/값 객체 묶음, 바깥에서는 "루트"를 통해서만 접근), **도메인
> 이벤트**(도메인 안에서 "어떤 일이 일어났다"는 사실 자체를 나타내는 객체).

### 0-1. 애그리게잇(Aggregate)과 애그리게잇 루트

`ApplicationForm.kt`를 보면 `BaseRootEntity<ApplicationForm>`를 상속한다. 이건 "`ApplicationForm`이
하나의 애그리게잇의 루트"라는 선언이다.

> **개념 노트 — 애그리게잇 루트란?**
> 여러 엔티티/값 객체가 하나의 트랜잭션 단위로 항상 함께 일관성을 유지해야 할 때, 그 묶음을
> "애그리게잇"이라 부르고, 외부에서 접근 가능한 유일한 진입점을 "루트"라 부른다. 예를 들어
> `ApplicationForm`은 `referenceUrl`, `answers`, `submitted` 상태를 항상 함께 일관되게 유지해야
> 한다 — "제출은 됐는데 제출일시는 없는" 상태가 되면 안 된다(`init { if (submitted)
> requireNotNull(submittedDateTime) }`가 바로 이 불변식을 강제하는 코드). 애그리게잇 루트 바깥의
> 코드는 절대 `answers`나 `submitted`를 직접 건드리지 못하고, 반드시 `submit()`, `update()` 같은
> 루트의 메서드를 통해서만 상태를 바꿀 수 있다.
>
> **애그리게잇의 경계**는 곧 "이 트랜잭션 하나로 저장돼야 하는 범위"이기도 하다. `ApplicationForm`이
> `Recruitment`를 `@ManyToOne` 객체가 아니라 `recruitmentId: Long`만 갖는 이유(섹션 2-2)가 바로
> 이거다 — `ApplicationForm`을 저장할 때 `Recruitment`까지 같이 저장/수정될 필요가 없으므로, 둘은
> 서로 다른 애그리게잇이고, 그래서 ID로만 참조한다. "이 두 엔티티가 항상 같은 트랜잭션에서 함께
> 일관성을 지켜야 하는가?"가 애그리게잇을 나누는 기준이다.

**Etude 적용**: 지금 `User`는 아직 다른 엔티티를 참조하지 않아 애그리게잇 경계를 고민할 상황이
없었다. 하지만 Step 3의 `QuestSet`/`Quest`/`QuestSetAccess`, Step 4의 `QuestAttempt`를 설계할 때
이 질문을 던져봐야 한다: "`QuestSet`이 저장될 때 `Quest`들도 항상 같이 일관되게 바뀌어야 하는가?"
(그렇다면 `QuestSet`이 애그리게잇 루트이고 `Quest`는 그 안에 속한다) "아니면 `Quest`를 독립적으로
수정할 일이 있는가?"(그렇다면 별개 애그리게잇으로 ID 참조를 쓴다). `QuestSetAccess`(quest_set_id +
user_id 복합키)는 `QuestSet`도 `User`도 소유하지 않는 독립된 "관계"를 표현하므로, 그 자체로 작은
애그리게잇으로 보는 게 자연스러울 수 있다.

### 0-2. 도메인 이벤트 — "일어난 사실"을 객체로 표현하기

`ApplicationForm.submit()`의 마지막 줄:
```kotlin
registerEvent(ApplicationFormSubmittedEvent(id, userId, recruitmentId))
```

`ApplicationFormSubmittedEvent`는 필드 4개짜리 평범한 `data class`다(`occurredOn` 포함). 이 이벤트를
`MailService`가 `@TransactionalEventListener`로 받아서 "지원서 제출 완료" 메일을 보낸다.

> **개념 노트 — 도메인 이벤트와 `registerEvent`의 동작 원리**
> `AbstractAggregateRoot`(Spring Data가 제공하는 베이스 클래스)를 상속하면 `registerEvent(event)`
> 메서드를 쓸 수 있다. 이 메서드는 이벤트를 "등록"만 할 뿐 즉시 발행하지 않는다 — 이 애그리게잇이
> Spring Data Repository의 `save()`로 실제 저장될 때, Spring이 등록된 이벤트를 자동으로 꺼내서
> `ApplicationEventPublisher`로 발행한다. `@TransactionalEventListener`로 받으면 그마저도
> **트랜잭션이 성공적으로 커밋된 이후**에만 리스너가 실행된다.
>
> 이게 왜 중요한가: 만약 `submit()` 안에서 직접 `mailService.send(...)`를 호출했다면, 메일 발송이
> 실패하거나 느려질 때 지원서 제출 트랜잭션 자체가 영향을 받는다. 반대로 "제출됐다"는 사실만
> 이벤트로 등록해두고, 실제 저장이 성공적으로 끝난 뒤에 별도로 메일을 보내면 두 책임(지원서 제출
> vs 메일 발송)이 실패 지점에서도 서로 독립적이다 — 메일 서버가 죽어도 지원서 제출은 성공한다.

**Etude 적용**: 지금 Etude에는 "어떤 행동이 일어난 뒤 부수적으로 처리해야 할 일"이 아직 뚜렷하게
없다. 하지만 Step 4(진행률/피드백)나 Step 7(채점)에서 "퀘스트를 통과하면 진행률을 갱신하고,
리더보드도 갱신해야 한다"처럼 하나의 행동이 여러 후속 작업을 유발하는 지점이 생길 가능성이 높다.
그때 `QuestAttempt.markPassed()` 같은 메서드 안에서 직접 리더보드 갱신 로직까지 호출하는 대신,
`QuestPassedEvent`를 발행하고 별도 리스너가 처리하게 하면 책임이 깔끔하게 나뉜다. 다만 Spring Boot
서버가 하나뿐이고 규모가 크지 않은 지금 단계에서는, "정말 두 책임이 서로 실패해도 무관해야 하는가"를
먼저 따져보고 필요할 때 도입하면 된다 — 모든 부수 효과를 이벤트로 뽑아내는 게 항상 좋은 건 아니다
(간단한 경우엔 서비스 메서드에서 순서대로 호출하는 게 더 읽기 쉬울 수 있다).

### 0-3. 값 객체(Value Object) — `ApplicationFormAnswers`

`ApplicationForm`의 `answers: ApplicationFormAnswers`는 `@Embedded`로 매핑된 값 객체다. 식별자가
없고, 그 자체로 "지원서 문항 답변들의 묶음"이라는 값을 표현한다.

> **개념 노트 — 엔티티 vs 값 객체**
> 엔티티는 "id가 같으면 같은 것"(이름이 바뀌어도 같은 사람), 값 객체는 "필드 값이 같으면 같은
> 것"(만원짜리 지폐 두 장은 서로 바꿔도 상관없다)이다. Kotlin의 `data class`가 값 객체를 표현하기
> 딱 좋다 — `equals`/`hashCode`가 필드 값 기준으로 자동 생성되기 때문이다. `@Embedded`는 JPA에게
> "이 값 객체를 별도 테이블 없이 소유 엔티티의 컬럼으로 풀어서 저장해라"라고 알려주는 어노테이션이다.

**Etude 적용**: 지금 Etude의 `UserRole`(enum)이 사실 값 객체의 가장 단순한 형태다. 앞으로 Step 3의
`QuestSet`에 "카테고리 + 난이도" 같은 여러 필드가 항상 함께 다뉘는 묶음이 생기면, 그걸 별도
data class + `@Embeddable`로 뽑아내는 걸 고려할 만하다 — 단, 필드 하나짜리거나 서로 독립적으로
바뀌는 필드라면 억지로 값 객체로 묶을 필요는 없다.

### 0-4. 이 레포에서 DDD 원칙이 "코드로" 드러나는 지점 요약

| DDD 개념 | 코드 위치 | 무엇을 강제하는가 |
|---|---|---|
| 애그리게잇 루트 | `ApplicationForm : BaseRootEntity<ApplicationForm>()` | 상태 변경은 반드시 `submit()`/`update()`를 통해서만 |
| 불변식 | `ApplicationForm.init { requireNotNull(submittedDateTime) }` | "제출됨이면 제출일시가 반드시 있다"를 생성 시점부터 강제 |
| 애그리게잇 경계 | `recruitmentId: Long` (객체 참조 아님) | `Recruitment`와 `ApplicationForm`은 별개 트랜잭션 단위 |
| 도메인 이벤트 | `registerEvent(ApplicationFormSubmittedEvent(...))` | "제출됨"이라는 사실과 "메일을 보낸다"는 후속 처리를 분리 |
| 값 객체 | `ApplicationFormAnswers` (`@Embedded`) | 여러 답변 필드를 하나의 응집된 값으로 취급 |

이 요약표를 기준으로 아래 섹션들을 읽으면, 각 패턴이 "그냥 편리한 코드 스타일"이 아니라 DDD가
말하는 특정 원칙의 구현이라는 걸 알 수 있다.

---

## 1. 프로젝트 구조 — 도메인 우선 vs 레이어 우선

`service-apply`는 패키지를 **도메인(feature) 기준으로 먼저 나누고, 그 안에서 레이어를 나눈다**.

```
apply/
  domain/
    applicationform/   ← 이 폴더 안에 엔티티, 리포지토리, 도메인 서비스가 다 있음
    recruitment/
    user/
  application/          ← 유스케이스 서비스 + DTO
  ui/
    api/                ← 일반 사용자용 컨트롤러
    admin/               ← 관리자용 컨트롤러
  security/
support/                 ← 프로젝트 전역 공통 코드 (BaseEntity, 테스트 유틸)
```

Etude는 반대로 **레이어를 먼저 나누고(`domain/application/interfaces/infrastructure`), 그 안에서
도메인별로 나눈다** (`domain/auth/User.kt`, `domain/user/UserService.kt`).

**비교**: 어느 쪽이 "정답"은 아니다.
- 레이어 우선(Etude 방식)은 "포트/어댑터가 어디 있는지"를 한눈에 보기 쉽고, 헥사고날 아키텍처의
  레이어 경계(도메인은 인프라를 모른다)를 디렉토리 구조로 강제하기 쉽다.
- 도메인 우선(service-apply 방식)은 "이 기능 전체가 어디 있는지"를 찾기 쉽다 — `applicationform`
  기능을 통째로 이해하려면 폴더 하나만 열면 된다. 도메인 개수가 늘어날수록 이 장점이 커진다.

**적용 판단**: Etude는 CLAUDE.md에 이미 "레이어는 자신의 역할만 안다"는 원칙과 레이어 우선 구조가
못박혀 있고, Phase 12 마이그레이션이 이미 이 구조로 절반 가까이 진행됐다. 지금 구조를 바꾸는 건
비용 대비 이득이 낮다 — 다만 도메인이 훨씬 늘어나는 시점(Step 6 터미널, Step 8 vcluster 등)에
`domain/` 아래가 너무 커지면 재고할 수 있는 대안으로만 기억해둔다.

---

## 2. 도메인 모델링 — Etude가 이미 하고 있는 것 + 더 배울 것

### 2-1. private set + 행동 메서드 (Etude가 Step 2에서 막 도입한 패턴과 동일)

`ApplicationForm.kt`는 생성자로 raw 값을 받고 `private set`으로 프로퍼티를 잠근 뒤, 상태를 바꾸는
행동을 메서드로 노출한다 — Etude가 방금 `User.changePassword()`/`matchesPassword()`로 도입한 것과
정확히 같은 패턴이다. `submit()` 메서드가 "이미 제출됐는지" 가드부터 확인하고 상태를 바꾸는 것도
동일한 사고방식이다 — **불변식(invariant)을 지키는 코드가 서비스가 아니라 엔티티 안에 있다.**

> **개념 노트 — 불변식(invariant)이란?**
> "이 객체가 항상 참이어야 하는 조건"을 뜻한다. 예를 들어 `ApplicationForm`은 "제출된 폼은 다시
> 제출할 수 없다"가 불변식이다. 이 체크를 서비스 계층에 두면, 나중에 다른 서비스가 같은 엔티티를
> 다루면서 체크를 빼먹을 수 있다. 엔티티 메서드 안에 체크를 두면 그 엔티티를 다루는 모든 경로가
> 강제로 규칙을 따르게 된다.

Etude 적용: 이미 하고 있으니 계속 유지하면 된다. 앞으로 Step 3(퀘스트), Step 4(진행률/피드백)의
엔티티를 만들 때도 "이 값은 누가 언제 바꿀 수 있는가"를 먼저 정하고 `private set` + 메서드로
시작하는 습관을 이어가면 된다.

### 2-2. 연관관계를 ID 참조로 (Etude가 아직 안 겪은 문제, 미리 알아두면 좋음)

`ApplicationForm`은 `Recruitment`를 `@ManyToOne` 객체 참조가 아니라 `recruitmentId: Long`이라는
평범한 필드로만 갖는다.

> **개념 노트 — `@ManyToOne` 객체 참조가 뭐가 문제인가?**
> JPA에서 `@ManyToOne val recruitment: Recruitment`처럼 엔티티를 직접 참조로 매핑하면, 이
> `ApplicationForm`을 조회할 때마다 JPA가 연관된 `Recruitment`를 지연 로딩(lazy loading)하거나
> 즉시 로딩(eager loading)한다. 지연 로딩은 트랜잭션 밖에서 접근하면 `LazyInitializationException`이
> 나고, 즉시 로딩은 필요 없을 때도 매번 JOIN 쿼리가 나간다. 목록 조회처럼 N개의 `ApplicationForm`을
> 한 번에 가져오면 N번의 추가 쿼리(N+1 문제)가 날 수도 있다.
>
> ID만 필드로 들고 있으면 이런 문제 자체가 생기지 않는다 — `Recruitment`가 필요하면 그때
> `recruitmentRepository.findById(recruitmentId)`로 명시적으로 가져온다. 대신 "조인해서 한 번에
> 가져오는" 편의는 포기해야 하니, 정말 항상 같이 조회되는 관계라면 오히려 연관관계 매핑이 나을 수도
> 있다 — 트레이드오프다.

Etude 적용: 지금 `User`는 다른 엔티티를 참조하지 않아서 아직 이 문제를 안 겪었다. 하지만 Step 3의
`QuestSetAccess`(quest_set_id + user_id 복합키), Step 4의 `QuestAttempt`(quest_id, user_id를
참조할 가능성이 높음)에서 이 결정을 해야 한다. **원칙**: "이 엔티티를 조회할 때 연관 엔티티까지
항상 함께 필요한가?"가 아니면 ID 참조로 시작하고, 나중에 필요해지면 그때 연관관계 매핑을 추가하는
게 안전하다 — 반대(매핑부터 하고 나중에 걷어내기)는 훨씬 번거롭다.

### 2-3. 소프트 삭제 자동화 (`@SQLDelete` + `@Where`)

`Recruitment.kt`는 `deleted: Boolean` 컬럼을 두고, `@SQLDelete(sql = "UPDATE ... SET deleted = true
WHERE id = ?")` + `@Where(clause = "deleted = false")`로 "삭제"를 실제 DELETE 대신 UPDATE로 바꾸고,
조회 시 자동으로 삭제된 행을 걸러낸다.

> **개념 노트**: `@SQLDelete`는 Hibernate에게 "삭제 요청이 오면 이 SQL을 대신 실행해라"라고 알려주는
> 어노테이션이고, `@Where`는 "이 엔티티를 조회하는 모든 쿼리에 이 조건을 자동으로 덧붙여라"라는
> 어노테이션이다. 둘을 합치면 "삭제"가 실제로는 숨김 처리이면서, 도메인 코드는 삭제된 행이 존재한다는
> 사실 자체를 몰라도 된다(항상 안 보이니까).

Etude 적용: 지금 Etude 스키마(`00_schema.sql`)에는 소프트 삭제 컬럼이 없다. 필요해지는 시점은
아마 Step 3(퀘스트 세트 비공개 처리는 이미 `is_public` 플래그로 다르게 처리 중) 정도일 텐데,
당장 급하지 않다. 다만 "삭제"가 아니라 "숨김/비활성화" 요구사항이 생기면 이 패턴을 기억해두면 좋다.

### 2-4. 상태를 저장하지 않고 계산으로 파생

`Recruitment.status`는 DB 컬럼이 아니라, `period`(모집 기간)와 `recruitable`(모집 가능 여부)로부터
매번 계산되는 getter다.

Etude 적용: CLAUDE.md의 "단일 진실 공급원" 원칙과 정확히 같은 생각이다. Etude에서도 "저장해둔 값과
계산 가능한 값이 어긋날 수 있는 지점"이 생기면(예: 퀘스트 진행률을 캐시 컬럼으로 둘지, 매번
`QuestAttempt`를 세서 계산할지) 이 원칙을 기준으로 판단하면 된다 — 저장은 계산 비용이 실제로 문제가
될 때만 최후 수단으로.

---

## 3. API 계층

### 3-1. `ApiResponse<T>` — Etude보다 단순한 버전

`service-apply`의 `ApiResponse`는 `message`, `body` 두 필드뿐이다. Etude의 `ApiResponse<T>`
(`meta: {result, errorCode, message}`, `data`)보다 훨씬 단순하다.

**적용 판단**: Etude 것이 더 정교하지만(성공/실패를 `enum Result`로 명시, 에러 코드 별도 필드),
그만큼 필드가 많다. 지금 Etude 구조를 이미 여러 컨트롤러에서 쓰기 시작했으니 굳이 단순화할 이유는
없다 — 다만 "필드가 정말 다 필요한가"를 주기적으로 재점검할 가치는 있다.

### 3-2. 예외 처리 — 예외 타입별 개별 핸들러 vs Etude의 `ErrorType` 중앙관리

`service-apply`의 `ExceptionHandler`는 `LoginFailedException`, `DuplicateApplicationException`
같은 **구체적인 예외 클래스마다 `@ExceptionHandler`를 하나씩** 둔다. Etude는 `ErrorType` enum에
상태 코드/메시지를 중앙 집중시키고, 예외는 `CoreException(errorType, message)`로 감싸거나(범용),
또는 Step 2에서 하듯 도메인 예외(`EmailAlreadyExistsException` 등)를 만들고 `ApiControllerAdvice`에
핸들러를 하나씩 추가하는 **혼합 방식**을 쓰고 있다.

**비교**: `service-apply` 방식은 새 예외를 추가할 때 핸들러 등록을 빼먹으면 500으로 떨어지니
실수가 눈에 잘 띈다(테스트가 바로 깨짐). Etude가 지금 하는 혼합 방식도 크게 다르지 않다 — 다만
`ApiControllerAdvice`에 핸들러가 계속 늘어나는 게(Step 2만 해도 이미 6~7개) 부담스러워지면,
`ErrorType`에 각 상태를 등록하고 `CoreException`으로 통일하는 쪽으로 리팩터링할 시점을 재는 게
좋다. 지금 당장 바꿀 필요는 없다.

### 3-3. `@LoginUser` + `HandlerMethodArgumentResolver` — 배울 가치가 큰 패턴

`service-apply`는 컨트롤러 파라미터에 `@LoginUser user: User`만 선언하면, JWT 파싱/검증/유저 조회가
자동으로 끝난 채 `User` 객체가 바로 들어온다.

> **개념 노트 — `HandlerMethodArgumentResolver`란?**
> Spring MVC가 컨트롤러 메서드를 호출하기 직전에, 각 파라미터를 어떻게 채울지 결정하는 확장
> 지점이다. `@RequestBody`, `@PathVariable` 같은 것도 내부적으로 이 메커니즘으로 동작한다.
> 커스텀 어노테이션(`@LoginUser`)을 만들고, "이 어노테이션이 붙은 파라미터를 만나면 이렇게
> 채워라"는 로직(`LoginUserResolver`)을 등록하면, 컨트롤러 코드에서 반복되는 "토큰 꺼내서 검증하고
> 유저 조회하는" 코드를 완전히 없앨 수 있다.

Etude 적용: 지금 Etude는 `request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload`를
컨트롤러마다 직접 캐스팅해서 쓰고 있다(`AuthV1Controller.me()`, Step 2의 `MeV1Controller`).
이건 정확히 `HandlerMethodArgumentResolver`로 없앨 수 있는 반복이다. **구체적 적용안**: `@LoginUser`
같은 커스텀 어노테이션을 만들고 `JwtPayload`를 자동 주입받게 하면, `me(request: HttpServletRequest)`
같은 시그니처 대신 `me(@LoginUser payload: JwtPayload)`로 바뀌어 캐스팅 코드가 컨트롤러에서 완전히
사라진다. Step 3~4에서 로그인 사용자 정보가 필요한 컨트롤러가 늘어날 걸 감안하면, 지금(Step 2~3
사이) 도입하는 게 나중에 여러 컨트롤러를 한꺼번에 고치는 것보다 싸다.

---

## 4. 테스트 전략

### 4-1. Fixture 함수 — Builder 패턴 대신

`service-apply`는 별도 Builder 클래스 없이, top-level 함수 + 기본값 파라미터로 테스트 데이터를
만든다:

```kotlin
fun createApplicationForm(userId: Long = 1L, recruitmentId: Long = 1L, ...) = ApplicationForm(...)
```

> **개념 노트 — 왜 Builder가 필요 없는가?**
> Java에서 Builder 패턴이 흔한 이유는 생성자에 파라미터가 많을 때 "어느 위치가 어느 값인지"
> 헷갈리기 쉽고, 일부만 값을 주고 나머지는 기본값을 쓰고 싶을 때가 많기 때문이다. Kotlin은
> named argument(`createApplicationForm(userId = 5L)`)와 default parameter를 언어 차원에서
> 지원하므로, 이 두 문제가 Builder 없이 이미 해결된다.

Etude 적용: 지금 Step 1/2 테스트에서 `User(name = "테스트", email = "test@okestro.com", password
= "hashed", role = UserRole.member)`처럼 매번 생성자를 직접 호출하고 있다. 테스트가 늘어나면
(Step 3부터 `Quest`, `QuestSet` 등 필드가 더 많은 엔티티가 생긴다) 이런 fixture 함수를
`src/test/kotlin/com/etude/support/`에 모아두는 걸 고려할 만하다 — 지금 당장 급하지 않지만
엔티티 필드가 5개를 넘어가는 시점부터 도입 가치가 커진다.

### 4-2. `fun interface`(SAM)를 테스트 더블로

`ApplicationValidator`를 SAM 인터페이스로 선언해서, 테스트에서 mock 프레임워크 없이
`ApplicationValidator { _, _ -> throw ... }`처럼 람다 하나로 즉석 스텁을 만든다.

> **개념 노트 — SAM(Single Abstract Method) interface / `fun interface`란?**
> 메서드가 딱 하나뿐인 인터페이스를 Kotlin에서 `fun interface`로 선언하면, 그 인터페이스의 구현체를
> 람다식으로 바로 만들 수 있다. `fun interface Validator { fun validate(x: Int): Boolean }`라면
> `val v = Validator { it > 0 }`처럼 쓸 수 있다는 뜻이다. MockK 같은 mocking 라이브러리 없이도
> "이 상황에서는 이렇게 동작하는 가짜 구현"을 코드 세 줄로 만들 수 있어서, 특히 "검증 성공/실패"처럼
> 이분법적인 동작을 스텁할 때 mock보다 읽기 쉬울 때가 많다.

Etude 적용: Step 1/2의 `PasswordEncoder`, `JwtProvider`, `UserRepository`는 모두 메서드가
여러 개라 SAM으로 만들 수 없다. 하지만 앞으로 "메서드 하나짜리 정책/검증 인터페이스"가 생기면
(예: Step 3의 퀘스트 접근 권한 검사, Step 7의 채점 조건 검사) `fun interface`로 선언해두면 테스트가
가벼워진다. 지금 있는 인터페이스들을 바꿀 필요는 없다 — 새로 만들 때 고려할 선택지.

### 4-3. Repository 확장 함수로 null 처리 통일

`RecruitmentRepository.getById(id)`라는 확장 함수가 `findByIdOrNull(id) ?:
throw NoSuchElementException(...)`을 감싸서, 모든 서비스가 이 패턴을 반복하지 않게 한다.

Etude 적용: 지금 Etude 곳곳에서 `userRepository.findById(id) ?: throw UserNotFoundException()`
같은 패턴이 반복되고 있다(Step 2의 `resetPassword`, `changeOwnPassword`가 이미 이 형태). 도메인이
늘어날수록(Step 3의 `QuestRepository`, Step 4의 `QuestAttemptRepository` 등) 이 반복이 늘어날
것이므로, `UserRepository`에 `fun UserRepository.getById(id: Long): User = findById(id) ?:
throw UserNotFoundException()` 같은 확장 함수를 추가하는 걸 Step 3 진행하면서 검토할 만하다.
지금 Step 1/2 코드를 당장 리팩터링할 필요는 없다.

### 4-4. 커스텀 테스트 어노테이션으로 보일러플레이트 통일

`@UnitTest`, `@RepositoryTest`, `@IntegrationTest` 세 개의 커스텀 어노테이션이 각각 MockK 확장,
`@DataJpaTest`+프로필, `@SpringBootTest`+프로필을 한 번에 묶어준다.

Etude 적용: Step 1에서 이미 `IntegrationTest` 추상 클래스(상속 방식)로 비슷한 목표를 달성했다 —
다만 `service-apply`는 상속이 아니라 **어노테이션 조합**으로 이걸 한다는 차이가 있다. 상속은
Kotlin에서 클래스당 하나만 가능하지만(다중 상속 불가), 어노테이션은 여러 개를 동시에 붙일 수 있다.
지금 Etude의 `IntegrationTest`는 "Testcontainers + MockMvc가 필요한 통합 테스트" 한 가지 조합만
써서 상속으로 충분하지만, 나중에 "Testcontainers는 필요한데 MockMvc는 필요 없는 테스트"처럼 조합이
여러 갈래로 늘어나면 커스텀 어노테이션 방식이 더 유연해진다. 지금 구조를 바꿀 필요는 없다 —
필요해지는 시점을 알아채기 위한 참고 사항.

---

## 5. Kotlin다운 관용구 — 요약

| 관용구 | service-apply 사용처 | Etude 현재 상태 |
|---|---|---|
| `apply`/`let` 스코프 함수 | `createApplicationForm(...).apply { submit(pass) }` | 이미 `!!`, `?:` 등은 쓰지만 스코프 함수 활용은 적음 — 자연스럽게 늘려가면 됨 |
| `fun interface`(SAM) | `ApplicationValidator` | 아직 안 씀 — 4-2 참고 |
| 확장 함수로 Repository 보완 | `RecruitmentRepository.getById()` | 아직 안 씀 — 4-3 참고 |
| Data class 보조 생성자로 엔티티→DTO 매핑 | `ApplicationFormResponse(applicationForm)` | 지금은 `UserSummary(user.id, user.name, ...)`처럼 호출부에서 직접 변환 — 아래 6번 참고 |

---

## 6. 바로 적용해볼 만한 것 하나 — DTO의 엔티티 변환 보조 생성자

`service-apply`는 `ApplicationFormResponse(applicationForm: ApplicationForm)`처럼, 응답 DTO가
엔티티를 받는 보조 생성자를 가진다. 그러면 서비스 코드에서 `.let(::ApplicationFormResponse)`처럼
메서드 레퍼런스 하나로 변환이 끝난다.

Etude는 지금 `UserSummary(user.id, user.name, user.email, user.role)`처럼 서비스 코드에서 필드를
하나하나 나열해서 변환한다(Step 1의 `AuthService.login()`, Step 2의 `UserService.createUser()`
등 여러 곳에서 반복됨). `UserSummary`에 `constructor(user: User) : this(user.id, user.name,
user.email, user.role)`를 추가하면 이 반복을 없앨 수 있다 — 다만 지금 필드가 4개뿐이라 반복
비용이 크지 않으니, "지금 당장 고쳐야 한다"기보다는 "다음에 비슷한 DTO를 만들 때 이 패턴을 먼저
고려해본다" 정도로 남겨둔다.

---

## 종합 판단: 지금 Etude에 가장 먼저 적용할 만한 것 우선순위

1. **`@LoginUser` 커스텀 어노테이션 + ArgumentResolver** (3-3) — 반복 코드 제거 효과가 크고, Step
   3~4에서 로그인 사용자 참조가 늘어나기 전에 도입하는 게 유리하다.
2. **Repository 확장 함수로 `findById ?: throw` 통일** (4-3) — Step 3부터 도메인이 늘어나며 반복이
   커지기 전에 습관을 잡아두면 좋다.
3. 나머지(SAM 테스트 더블, Fixture 함수, DTO 보조 생성자)는 지금 당장 급하지 않지만, 필요해지는
   신호(반복이 3번 이상 보이면)가 오면 그때 적용해도 늦지 않다.

private set + 행동 메서드, ID 참조 위주 연관관계, 상태 계산 파생은 Etude가 이미 하고 있거나
Step 3부터 자연스럽게 마주칠 결정이므로, 이 문서를 그때 다시 참고하면 된다.
