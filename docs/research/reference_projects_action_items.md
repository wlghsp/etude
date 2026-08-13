# 참고 프로젝트 분석 종합 — Etude 적용 개선 항목

다섯 참고 프로젝트를 분석한 결과([woowacourse_service_apply_analysis.md](woowacourse_service_apply_analysis.md),
[cafekiosk_analysis.md](cafekiosk_analysis.md), [splearn_analysis.md](splearn_analysis.md),
[coffeehouse_analysis.md](coffeehouse_analysis.md), [todoapp_analysis.md](todoapp_analysis.md))에서
나온 Etude 적용 제안을 한곳에 모은 실행 목록이다. 각 항목은 원본 분석 문서의 근거를 링크로만
남기고, 여기서는 "무엇을 어떻게 할지"에 집중한다.

우선순위는 착수 비용과 지금 진행 상황(Phase 12 Step 3 진행 중) 대비 효과를 기준으로 매겼다 —
전부 지금 당장 급한 건 아니고, 다음에 해당 영역을 만질 때 참고하는 용도다.

---

## 우선순위 1 — 착수 비용 낮고 효과 확실

### 1-1. `@LoginUser` 커스텀 어노테이션 + `HandlerMethodArgumentResolver`

**출처**: [woowacourse_service_apply_analysis.md 3-3](woowacourse_service_apply_analysis.md)

**문제**: 지금 컨트롤러마다 `httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload`를
반복 캐스팅한다(`AuthV1Controller`, `MeV1Controller`, `QuestV1Controller`). 오늘 세션에서
`QuestV1Controller`가 이걸 `getHeader`로 잘못 써서 NPE가 났던 게 이 반복 패턴의 위험성을 실제로
보여준 사례다.

**할 일**: `@LoginUser` 커스텀 어노테이션과 `LoginUserArgumentResolver`(`HandlerMethodArgumentResolver`
구현체)를 만들어, `me(request: HttpServletRequest)` 대신 `me(@LoginUser payload: JwtPayload)`로
파라미터를 직접 주입받게 한다. `WebConfig`(`WebMvcConfigurer.addArgumentResolvers`)에 등록.

**시점**: Step 3~4에서 로그인 사용자 참조가 컨트롤러마다 계속 늘어나기 전, 지금 도입하는 게
나중에 여러 컨트롤러를 한꺼번에 고치는 것보다 싸다.

### 1-2. Repository 확장 함수로 `findById ?: throw` 통일

**출처**: [woowacourse_service_apply_analysis.md 4-3](woowacourse_service_apply_analysis.md)

**문제**: `userRepository.findById(id) ?: throw UserNotFoundException()` 같은 패턴이 `UserService`,
`QuestService` 등 여러 곳에 반복된다.

**할 일**: `fun UserRepository.getById(id: Long): User = findById(id) ?: throw UserNotFoundException()`
처럼 리포지토리 인터페이스별 확장 함수를 추가. `QuestSetRepository`, `QuestRepository`도 동일
패턴 적용.

**시점**: Step 3부터 도메인이 늘어나며 반복이 커지기 전에 습관을 잡아두면 좋다. 기존 Step 1/2
코드를 당장 리팩터링할 필요는 없음 — 새로 짜는 코드부터 적용.

### 1-3. "서비스 레이어는 mock 없이 실제 DB로 검증한다" 원칙 문서화

**출처**: [cafekiosk_analysis.md 4-2](cafekiosk_analysis.md)

**문제**: Etude가 이미 이 원칙대로 하고 있다(`QuestServiceTest`는 mockk로 리포지토리 목킹,
`QuestControllerTest`는 Testcontainers까지 띄우는 통합 테스트) — 그런데 이 판단 기준이 어디에도
적혀 있지 않아, 나중에 합류하는 사람이 "왜 이 테스트는 mock을 안 쓰지?"를 스스로 추론해야 한다.

**할 일**: `docs/guides/` 어딘가(또는 새 `docs/testing_guide.md`)에 한 단락으로 명문화:
- 도메인 서비스 단위 테스트 → mockk로 리포지토리 목킹
- 컨트롤러 통합 테스트 → Testcontainers로 실제 DB까지 검증
- 그 사이(리포지토리 구현체 자체)는 아직 별도 테스트가 없다는 것도 함께 명시

**시점**: 비용이 거의 없으니 다음에 가이드 문서를 만질 때 끼워 넣기.

### 1-4. 도메인 서비스는 `@Transactional`을 기본으로 붙인다 (완료)

**출처**: 오늘 세션에서 직접 겪은 문제 (참고 프로젝트 분석에서 도출된 항목은 아님)

**문제**: `QuestService.revokeAccess`가 호출하는 `QuestSetAccessRepository.deleteByQuestSetIdAndUserId`
(Spring Data JPA 파생 삭제 쿼리)가 `InvalidDataAccessApiUsageException`("No EntityManager with
actual transaction available for current thread")으로 실패했다. `save()`(Spring Data
`CrudRepository`)는 자체적으로 트랜잭션을 열어 처리해 `@Transactional` 없이도 당장은 동작하지만,
커스텀 `delete`/`update` 파생 쿼리는 호출하는 쪽에 트랜잭션이 없으면 바로 깨진다. `AuthService`를
제외한 모든 도메인 서비스(`UserService`, `QuestService`)에 `@Transactional`이 빠져 있었다.

**한 일**: `QuestService`, `UserService` 클래스에 `@Transactional` 추가(실제 소스 + Step 2/3
가이드 문서 모두 반영 완료). 순수 조회만 하는 `AuthService.login`은 제외.

**원칙**: 쓰기 작업(`save`, 파생 delete/update 쿼리)이 하나라도 있는 도메인 서비스는 새로 만들
때부터 클래스 레벨 `@Transactional`을 기본으로 붙인다 — "지금은 `save()`만 써서 안전하다"는
판단에 기대지 않는다. 나중에 파생 쿼리를 추가하는 순간 조용히 깨질 수 있기 때문이다.

### 1-5a. `@LoginUser` 리졸버 구현 시 `todoapp` 예제로 대조

**출처**: [todoapp_analysis.md 1](todoapp_analysis.md)

`todoapp`의 `UserSessionHandlerMethodArgumentResolver`(`web/support/method/`)가
[guide_loginuser_resolver.md](../guides/guide_loginuser_resolver.md)에서 만들려는 것과 동일한
`HandlerMethodArgumentResolver` 패턴을 실제로 동작시키고 있다 — 어노테이션 없이 파라미터 타입만
보고 판단한다는 점만 다르다(Etude는 `@LoginUser` 어노테이션 기반으로 이미 결정).

**할 일**: 별도 작업 아님 — 가이드대로 구현하다 막히면 이 파일을 코드 레벨로 대조하는 용도.

### 1-5b. `ExecutionTimeHandlerInterceptor` — API 응답시간 로깅 인터셉터

**출처**: [todoapp_analysis.md 7](todoapp_analysis.md)

**문제**: 배포 후 API 응답 시간을 눈으로 확인할 방법이 아직 없다.

**할 일**: `todoapp`의 `ExecutionTimeHandlerInterceptor`(`StopWatch`로 요청 처리시간 측정,
`Ordered.MIN_VALUE`로 가장 먼저 실행)를 참고해 동일한 인터셉터를 추가하고 `WebConfig`에 등록.

**시점**: 지금은 운영 모니터링 요구가 없어 보류. 배포 후 실제로 응답 시간을 확인하고 싶어지면
가장 먼저 참고.

### 1-5. `QuestSet`/`Quest` fixture를 `TestUsers`처럼 공용 오브젝트로 (완료)

**출처**: [cafekiosk_analysis.md 4-3](cafekiosk_analysis.md)

**한 일**: `support/TestQuestSets.kt`(`createPublic`/`createPrivate`), `support/TestQuests.kt`
(`create`, `questSetId`는 필수 파라미터)를 신설. `QuestControllerTest`,
`AdminQuestSetControllerTest`의 `beforeTest`가 직접 `QuestSet(...)`/`Quest(...)` 생성자를 호출하던
부분을 이 오브젝트 호출로 교체(실제 소스 + Step 3 가이드 문서 모두 반영 완료).

---

## 우선순위 2 — 도메인 문서화 (splearn에서 착안, 사용자가 직접 언급)

**출처**: [splearn_analysis.md 종합 판단](splearn_analysis.md)

splearn은 리포 루트에 `용어사전.md`(한국어\|영어\|설명 3열 표), `도메인모델.md`(애그리게잇별
속성/행위/규칙 + DDD 빌딩블록 태그, 메서드 시그니처를 코드와 일치시켜 설계-먼저 문서로 씀),
`도메인모델.drawio`(관계/카디널리티 전용 다이어그램)를 두고 있다. 코드와는 하이퍼링크가 아니라
"문서 먼저 적고 다음 커밋에서 그대로 구현"하는 커밋 단위 동기화로 연결된다.

### 2-1. 위치와 형식 결정 (다음 세션 착수 전 먼저 정할 것)

- **위치**: `docs/glossary/`는 이미 "기술 개념 설명"(WebSocket, Docker 등, Spring/Java 대비) 용도로
  쓰이고 있어 성격이 다르다. 새 폴더(`docs/domain/`)를 만들지, 다른 대안이 나을지 결정 필요.
- **형식**: splearn의 3열 용어사전 표는 그대로 가져와도 무리 없다. "속성/행위/규칙" 애그리게잇
  템플릿은 CLAUDE.md의 "명세 선행(Spec-First)" 원칙과 잘 맞물린다 — 코드 짜기 전에 이 형식으로
  먼저 설계를 적어두는 흐름.
- **다이어그램**: `.drawio`(바이너리 XML, diff 리뷰 어려움) 대신 Mermaid(마크다운 내장, git diff로
  변경 추적 가능)를 쓴다.

### 2-2. 적용 범위 — 전체가 아니라 핵심 애그리게잇부터

Etude는 splearn(단일 애그리게잇만 완성된 학습 프로젝트)과 달리 이미 여러 도메인(`auth`, `user`,
`quest`)이 있다. 전체에 한번에 적용하면 유지 비용이 커지므로, `QuestSet`/`Quest`/`QuestSetAccess`
(Step 3에서 막 구현 완료)부터 시범 도입하고, 다음 Step(Step 4 이후) 진행 시 새로 설계하는
애그리게잇에 자연스럽게 확장한다.

### 2-3. 코드-문서 연결 방식

splearn처럼 코드에 문서를 가리키는 주석은 없이 커밋 단위로만 동기화하는 방식도 가능하지만,
Etude에서는 엔티티 파일 상단에 관련 문서 경로를 한 줄 주석으로 남기는 걸 보완책으로 고려한다 —
splearn 분석에서 "코드-문서 간 명시적 링크 부재"를 약점으로 짚었기 때문.

---

## 우선순위 3 — 지금은 보류

- **아키텍처 규칙을 ArchUnit으로 자동 검증** (splearn) — 지금 도메인 개수가 적어 사람 리뷰로
  충분하다. 프로젝트가 커지면 재검토.
- **가벼운 `@WebMvcTest` 스타일 컨트롤러 테스트 분리** (cafekiosk) — 지금은 모든 통합 테스트가
  Testcontainers를 태우는 방식뿐인데, 컨트롤러가 늘어나 테스트 실행 시간이 부담스러워지면
  서비스 계층을 mock으로 막은 가벼운 웹 계층 테스트를 고려.
- **2단계 DTO 변환**(컨트롤러 DTO → 서비스 DTO, cafekiosk), **REST Docs**(cafekiosk), **동적
  테스트**(cafekiosk) — 지금 Etude 규모나 이미 갖춘 도구(springdoc, Kotest)를 감안하면 도입
  비용 대비 得이 낮다고 판단, 보류.
- **모듈 간 호출을 인터페이스(포트) 뒤에 숨기고 구현체를 동기 HTTP/메시징으로 교체 가능하게
  두기**(coffeehouse) — Etude가 지금 단일 모듈이라 적용 대상 자체가 없다. 나중에 도메인이 늘어나
  물리적으로 모듈을 쪼갤 때, 도메인 서비스 간 호출도 이 원칙으로 감싸두면 통신 방식이 바뀌어도
  호출부가 영향받지 않는다는 것만 기억해둔다.
- **도메인별 물리적 모듈 분리 + `@EnableXxxModule` 부트스트랩 애노테이션**(coffeehouse) — 지금
  도메인 개수(`auth`/`user`/`quest` 3개)에서는 오버엔지니어링. 도메인이 훨씬 늘어나 빌드 시간이나
  팀 단위 소유권 분리가 실제 문제가 될 때 재검토.
