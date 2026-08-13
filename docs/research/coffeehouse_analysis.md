# 분석: `coffeehouse` (Java/Spring, 멀티모듈 헥사고날 예제)

분석 대상: `/Users/jihochoi/Documents/study/coffeehouse`

목적: Etude의 Kotlin 백엔드 마이그레이션(Phase 12)에 참고할 만한 패턴을 뽑아낸다. `coffeehouse`는
Java 17 + Spring Boot 기반 학습 프로젝트로(`@author springrunner.kr@gmail.com` 주석으로 미루어
특정 강의 자료 기반), `order`/`brew`/`user` 세 도메인 모듈을 물리적으로 분리하고 모듈 간 통신을
로컬호스트 HTTP로 처리하는 **모듈 분리/헥사고날 아키텍처** 실험에 무게가 실려 있다. Etude가 이미
갖춘 것(인증, DTO 변환, 예외 처리, Testcontainers 통합 테스트)보다 오히려 미성숙한 부분이 많아,
"이 프로젝트처럼 하자"보다는 "이 프로젝트의 특정 구조적 아이디어만 가져오자" 관점으로 본다.

**중요도 안내**: Etude는 지금 단일 모듈(`backend-kotlin/apps/backend`)이고 도메인 개수(`auth`,
`user`, `quest`)도 적어, 모듈 분리 자체를 지금 도입할 이유는 없다. 이 문서는 "나중에 도메인이 늘어나
모듈 분리를 고민할 때" 참고하는 용도로 남겨둔다.

---

## 1. 전체 구조 — 도메인별 물리적 모듈 분리

Gradle 멀티모듈로 `applications:coffeehouse-server`(실행 가능한 Spring Boot 앱), `modules:order`,
`modules:brew`, `modules:user`(도메인 모듈), `libraries:spring-extensions`(공용 라이브러리, 현재는
거의 빈 상태), `tests:integration-testing`(통합 테스트 전용 서브프로젝트)로 나뉜다. 모듈 간
의존성도 `brew`만 `order`, `user`를 참조하고 나머지는 서로 독립적이다. 빌드 설정은
`buildSrc`의 사전 컴파일 Gradle 플러그인(`coffeehouse.module-conventions.gradle` 등)으로 각
모듈의 `build.gradle`을 한 줄로 압축한다.

**Etude 적용**: Etude는 지금 `auth`/`user`/`quest` 세 도메인이 전부 한 모듈 안에 패키지로만
나뉘어 있다. 도메인이 지금보다 훨씬 늘어나 빌드 시간이나 팀 단위 소유권 분리가 문제가 될 때
참고할 수 있는 구조이지, 지금 규모(도메인 3개)에서 모듈 분리는 오히려 오버엔지니어링이다.

## 2. 인증/인가 — 전혀 구현되어 있지 않음

코드 전체를 뒤져도(`auth`, `jwt`, `session`, `password`, `login`, `security`, `token` 키워드)
관련 코드가 없다. `UserAccount` 엔티티도 `userAccountId` 필드 하나뿐, 인증 관련 필드 자체가 없다.
컨트롤러는 `@PathVariable`/`@RequestBody`만 쓰고 로그인 사용자를 꺼내는 코드가 아예 없다.

**Etude 적용**: 참고할 게 없다 — Etude가 이미 JWT + 인터셉터 + (도입 예정인) `@LoginUser`
리졸버까지 갖추고 있어 이 프로젝트보다 훨씬 앞서 있는 영역이다.

## 3. 도메인 모델 — 최소한의 캡슐화, 유효성 검사는 약함

`Order` 엔티티는 `id`, `ordererId`, `orderStatus` 세 필드에 `accept()`/`complete()` 상태 전이
메서드와 정적 팩토리 `create()`를 둔다. 상태 전이 로직은 엔티티 안에 있지만 "이미 완료된 주문을
다시 accept할 수 있는가" 같은 가드는 없다. 애그리게잇 경계는 모듈 경계와 거의 일치하고, ID 타입
(`OrderId`, `UserAccountId` 등)을 모듈마다 독립적으로 재정의해 값으로만 참조한다 — 참조 대신 값
복제로 모듈 간 결합을 피한 것으로 보인다.

**Etude 적용**: 정적 팩토리 패턴 자체는 Etude가 이미 하고 있는 것과 같은 방향이라 새로 배울 게
없다. 다만 "값 객체로 다른 도메인을 참조하고 FK/객체 참조를 걸지 않는다"는 원칙은 Etude의
`QuestSetAccess`(quest_set_id + user_id를 ID로만 참조)가 이미 같은 결정을 하고 있어, 재확인 정도의
의미다. 상태 전이 가드가 없는 점은 반면교사 — Etude는 도메인 예외로 이 부분을 이미 더 잘 하고
있다.

## 4. 테스트 전략 — 단위 테스트 없음, in-memory 통합 테스트만

모듈 코드 안에 단위 테스트가 전혀 없다. 테스트는 `tests/integration-testing` 서브프로젝트에만
있고, `@SpringBootTest(webEnvironment = DEFINED_PORT)`로 전체 앱을 띄워 실제 HTTP 흐름을
검증한다. DB 자체가 없고 모든 리포지토리가 in-memory 구현체(`ConcurrentHashMap` 추정)라
Testcontainers도 필요 없다. 픽스처는 하드코딩된 UUID 문자열을 테스트마다 직접 사용 — 공용 픽스처
빌더/팩토리가 없다.

**Etude 적용**: Etude가 이미 이 프로젝트보다 훨씬 촘촘하다 — `QuestServiceTest`(mockk 단위 테스트)
+ `QuestControllerTest`(Testcontainers 통합 테스트) 두 층, 게다가 `TestUsers`/`TestAuth`/
`TestQuestSets` 같은 공용 픽스처 오브젝트까지 갖췄다. 참고할 것보다는 Etude가 이미 앞서 있다는
확인에 가깝다.

## 5. 레이어 구조 — 포트/어댑터(헥사고날), 모듈 간 통신은 로컬 HTTP

각 모듈이 `domain`(entity, service 인터페이스, service.business 구현체), `data`(repository,
http), `web` 세 계층으로 나뉜다. `domain.service`가 인터페이스(`BarCounter` 등)만 선언하고,
`data.http`의 `BarCounterHttpClient`가 그 인터페이스를 구현하면서 실제로는 `RestTemplate`로
`http://localhost:8080/...`에 HTTP 요청을 보낸다 — 즉 "다른 모듈 호출"을 인터페이스 뒤에 숨기고
구현체를 로컬 HTTP 어댑터로 둔 것. `docker-compose.yml`에 RabbitMQ가 정의돼 있지만 실제 사용
흔적은 없어 메시징 전환을 염두에 둔 스캐폴딩으로 보인다.

**Etude 적용**: Etude의 `infrastructure/persistence` 어댑터 패턴(리포지토리 인터페이스는 domain,
구현은 infrastructure)과 같은 포트/어댑터 원칙이다. 다만 "모듈 간 호출을 인터페이스로 감싸고
구현체를 교체 가능하게(지금은 동기 HTTP, 나중엔 메시징) 둔다"는 아이디어는 Etude가 지금은 단일
모듈이라 적용 대상이 없다 — 나중에 모듈을 분리하는 시점이 오면, "도메인 서비스 간 호출도 인터페이스
뒤에 숨겨두면 나중에 통신 방식(동기 HTTP ↔ 메시징)을 바꿔도 호출부가 안 바뀐다"는 원칙만
기억해두면 된다.

## 6. 컨트롤러/API 설계 — DTO 변환·공통 응답 래퍼 없음

컨트롤러가 도메인 엔티티(`Order`)를 그대로 `ResponseEntity<Order>`로 반환한다. 공통 응답 래퍼가
없고, API 문서화 도구(springdoc 등) 의존성도 없다.

**Etude 적용**: 참고할 게 없다 — Etude는 이미 `ApiResponse<T>` 공통 래퍼와 springdoc-openapi 문서화
를 갖추고 있어 이 프로젝트보다 앞서 있다.

## 7. 에러 처리 — ControllerAdvice 없음

예외는 `IllegalArgumentException`을 상속한 빈 클래스(`OrderNotFoundException`, 메시지도 없음)
뿐이고, 컨트롤러 레벨에서 이를 HTTP 상태코드로 매핑하는 로직이 없다 — Spring 기본 500 처리에
위임되는 것으로 보인다.

**Etude 적용**: 참고할 게 없다 — Etude의 `ErrorType` 중앙관리 + `ApiControllerAdvice`
`@ExceptionHandler` 조합이 이미 이 프로젝트보다 정교하다.

## 8. 특이 패턴 — 모듈 부트스트랩 애노테이션

`@EnableOrderModule`, `@EnableBrewModule`, `@EnableUserModule` 같은 커스텀 애노테이션으로 각
모듈을 부트스트랩한다(`@Import` + `@ComponentScan`을 감싼 형태) — 모듈을 독립적으로 켜고 끌 수
있게 하려는 의도로 보이나, 정작 `CoffeehouseServerApplication`에는 이 애노테이션들이 붙어있지
않고 단순 `@SpringBootApplication`의 기본 컴포넌트 스캔에 의존하고 있어 실제로는 미완성 상태다.

**Etude 적용**: 지금 당장 쓸 곳은 없다. 다만 "모듈을 선택적으로 켜고 끌 수 있게 만드는 패턴"
자체는, 나중에 Etude가 여러 모듈로 쪼개질 경우 각 모듈의 `@Configuration`을 명시적으로 다른
모듈이 골라서 `@Import`하는 형태로 참고할 수 있다 — 지금은 적용 대상이 없다.

---

## 종합 판단: 지금 Etude에 적용할 가치가 있는 것 (전부 낮은 우선순위, 사실상 보류)

이 프로젝트는 인증, DTO 변환, 예외 처리, 테스트 촘촘함 등 대부분의 영역에서 Etude보다 미성숙하다.
지금 시점에 가져올 실질적인 액션 아이템은 없고, 유일하게 눈여�겨볼 만한 것은:

1. **모듈 간 호출을 인터페이스 뒤에 숨기는 원칙** — 나중에 Etude가 여러 모듈로 쪼개질 시점에,
   도메인 서비스 간 호출도 포트(인터페이스) + 어댑터(동기 HTTP or 메시징)로 감싸두면 통신 방식을
   나중에 바꿔도 호출부가 영향받지 않는다. 지금은 단일 모듈이라 적용 대상 자체가 없다.
2. **값 객체로 도메인 간 참조, FK/객체 참조 걸지 않기** — Etude가 `QuestSetAccess`에서 이미 하고
   있는 결정과 같은 방향이라는 재확인 정도.

나머지(모듈 분리 자체, `@EnableXxxModule` 부트스트랩, in-memory 리포지토리)는 지금 Etude 규모와
이미 갖춘 도구 대비 도입 근거가 없어 보류한다.
