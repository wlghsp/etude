# 분석: `todoapp` (Java/Spring, next-step 교육 과정 실습 레포)

분석 대상: `/Users/jihochoi/Documents/study/next-step/todoapp`

목적: Etude의 Kotlin 백엔드 마이그레이션(Phase 12)에 참고할 만한 패턴을 뽑아낸다. `todoapp`은
next-step 교육 과정(우아한형제들 산하 교육)의 실습 레포로, [coffeehouse_analysis.md](coffeehouse_analysis.md)와
동일 저자(`@author springrunner.kr@gmail.com`) 스타일이다. coffeehouse가 모듈 분리/헥사고날 구조
실험이었다면, todoapp은 **Spring MVC 확장 지점(인터셉터, ArgumentResolver, ReturnValueHandler,
ViewResolver)을 정공법으로 활용하는 예제**에 가깝다 — 정확히 Etude가 지금 도입하려는 `@LoginUser`
리졸버([guide_loginuser_resolver.md](../guides/guide_loginuser_resolver.md))의 완성된 참고
사례다.

**중요도 안내**: 도메인 모델 캡슐화, 예외 계층, 인터셉터 활용은 지금 Etude와 방향이 같거나 이미
앞서 있어 급하게 가져올 게 적다. 반면 **세션 홀더를 인터페이스로 감싸 요청 스코프에 두는 패턴**과
**ID를 값 객체로 감싸는 것**은 Etude가 아직 하지 않고 있어 짚어볼 가치가 있다.

---

## 1. `HandlerMethodArgumentResolver` — Etude가 만들려는 것의 실제 동작 예시

`UserSessionHandlerMethodArgumentResolver`(`web/support/method/UserSessionHandlerMethodArgumentResolver.java`)가
정확히 Etude가 도입하려는 패턴이다.

```java
public class UserSessionHandlerMethodArgumentResolver implements HandlerMethodArgumentResolver {
    private final UserSessionHolder userSessionHolder;

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return UserSession.class.isAssignableFrom(parameter.getParameterType());
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
                                   NativeWebRequest webRequest, WebDataBinderFactory binderFactory) {
        return userSessionHolder.get();
    }
}
```

**Etude와의 결정적 차이**: 커스텀 어노테이션(`@LoginUser`) 없이 **파라미터 타입만으로**
`supportsParameter`를 판단한다 — 컨트롤러 메서드에 `UserSession session`이라고만 쓰면 자동으로
주입된다. `WebMvcConfiguration.addArgumentResolvers`에 등록하는 방식은 Etude 가이드와 동일.

**Etude 적용**: 이미 [guide_loginuser_resolver.md](../guides/guide_loginuser_resolver.md)에서
`@LoginUser` 어노테이션 방식을 채택했다. 타입 기반 방식(todoapp)과 어노테이션 기반 방식(Etude
가이드)의 트레이드오프:
- **타입 기반**(todoapp): 코드가 한 글자 짧다. 하지만 다른 타입 파라미터와 이름이 겹치지 않는
  한에서만 안전하고, "왜 이 파라미터가 자동 주입되는지"가 어노테이션 없이는 한눈에 안 보인다.
- **어노테이션 기반**(Etude): `@LoginUser`가 붙어야만 리졸버가 반응하므로 의도가 명시적이고,
  같은 `JwtPayload` 타입을 파라미터로 받되 리졸버 주입을 원치 않는 경우(거의 없겠지만)와도
  구분된다.

Etude가 이미 어노테이션 기반으로 정했으므로 바꿀 필요는 없다 — todoapp은 "타입 기반도 동작한다"는
대안 사례로 참고만 해두면 된다.

## 2. `UserSessionHolder` — 세션 접근을 인터페이스 뒤에 숨긴다

`HttpUserSessionHolder`(`security/web/servlet/HttpUserSessionHolder.java`)는 `UserSessionHolder`
인터페이스의 구현체로, `RequestContextHolder`의 `SCOPE_SESSION`(`HttpSession`)에 `UserSession`을
저장/조회한다. 컨트롤러나 리졸버는 `UserSessionHolder`라는 **인터페이스**만 알고, 그 뒤가
`HttpSession`인지 다른 저장소인지 모른다.

```java
// LoginController.java
userSessionHolder.set(new UserSession(user));  // 로그인 성공 시

// UserSessionHandlerMethodArgumentResolver.java
return userSessionHolder.get();  // 리졸버가 꺼내 쓸 때
```

**Etude와의 차이**: Etude는 `JwtAuthFilter`가 `HttpServletRequest`의 attribute에 직접
`JwtPayload`를 넣고(`request.setAttribute(REQUEST_ATTR_JWT_PAYLOAD, ...)`), 가이드에서 만들
리졸버도 `webRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD, SCOPE_REQUEST)`로 request attribute를
직접 읽는다 — 즉 "attribute 키 문자열"이 필터와 리졸버 두 곳에 공유된 암묵적 계약이다. todoapp은
이 계약을 `UserSessionHolder` 인터페이스 뒤로 감춰서, 저장 방식이 바뀌어도(세션 → 다른 저장소)
필터/리졸버 코드가 문자열 키에 의존하지 않는다.

**Etude 적용**: 지금 당장 바꿀 필요는 없다 — Etude는 JWT 기반이라 애초에 세션이 없고,
`REQUEST_ATTR_JWT_PAYLOAD` 상수 하나로 필터와 리졸버가 공유하는 것 자체는 문제가 되지 않는다
(todoapp처럼 세션 저장소를 교체할 계획이 없다). 다만 "인증 주체를 꺼내는 방법을 인터페이스로
감싸면 저장 방식이 바뀌어도 호출부가 안 바뀐다"는 원칙은 나중에 Etude가 세션/Redis 등으로
인증 저장 방식을 바꿀 경우 참고할 수 있다.

## 3. 권한 검증 — `@RolesAllowed` + 인터셉터, Etude의 `AdminInterceptor`와 같은 자리

`RolesVerifyHandlerInterceptor`(`security/web/servlet/RolesVerifyHandlerInterceptor.java`)가
핸들러 메서드/클래스에 `jakarta.annotation.security.@RolesAllowed`가 있으면:
1. `request.getUserPrincipal() == null` → `UnauthorizedAccessException`(401)
2. `rolesAllowed.value()` 중 `request.isUserInRole()`이 하나도 안 맞으면 →
   `AccessDeniedException`(403)

`TodoRestController`, `UserRestController`에 클래스 레벨로 `@RolesAllowed("ROLE_USER")`를 붙여
인가 대상을 표시한다. `AccessDeniedException`/`UnauthorizedAccessException`은
`@ResponseStatus(HttpStatus.FORBIDDEN/UNAUTHORIZED)`로 상태코드를 매핑한다.

**Etude와의 차이**: Etude의 `AuthInterceptor`/`AdminInterceptor`(`WebConfig.kt`)는
`addPathPatterns`로 **경로 패턴** 기준으로 인증/관리자 여부를 검사한다. todoapp은
`@RolesAllowed` **어노테이션** 기준으로 검사한다 — 경로 패턴이 바뀌어도(리네이밍 등) 인가 규칙이
코드에 남아있고, 컨트롤러 메서드 옆에서 바로 "이건 ROLE_USER만"이라는 걸 읽을 수 있다는 장점이
있다. 반대로 경로 패턴 방식은 `WebConfig` 한 곳만 보면 전체 인가 규칙이 한눈에 보인다는 장점이
있다.

**Etude 적용**: 지금 Etude 규모(경로 몇 개)에서는 `WebConfig`의 `addPathPatterns` 방식이 여전히
더 낫다 — 인가 규칙이 흩어지지 않고 한 파일에 모여 있다. 컨트롤러/엔드포인트가 훨씬 늘어나
`WebConfig`의 패턴 목록이 길어지고 관리가 힘들어지면, `@RolesAllowed` + 인터셉터 조합으로 전환을
고려할 수 있다 — 지금은 불필요.

## 4. 도메인 모델 — ID를 값 객체로 감싸는 것까지 캡슐화

`Todo`(`core/todo/domain/Todo.java`), `User`(`core/user/domain/User.java`) 둘 다 기본 생성자를
`// for hibernate` 주석과 함께 `private`로 숨기고, 정적 팩토리(`Todo.create(...)`)만 공개한다.
Etude의 `QuestSet`/`User`와 같은 방향이다. 한 걸음 더 나아간 지점은 **ID 자체를 `@Embeddable` 값
객체로 감싼다**는 것 — `TodoId`, `UserId`(`core/shared/identifier/*`)가 단순 `Long`이 아니라
패키지-프라이빗 생성자 + `of()` 팩토리를 가진 값 객체다. 도메인 로직도 엔티티 안에 있다 —
`Todo.edit(text, completed, owner)`가 소유자 불일치 시 스스로 `TodoOwnerMismatchException`을
던진다(자기 검증).

**Etude 적용**: Etude는 지금 `Long id`를 원시 타입으로 그대로 쓴다(`User.id: Long`,
`QuestSet.id: Long`). ID를 값 객체로 감싸면 "userId 자리에 questSetId를 실수로 넘기는" 컴파일
타임 실수를 막을 수 있지만, Etude 규모(엔티티 4~5개, 파라미터 순서 실수가 실제로 발생한 적 없음)
에서는 보일러플레이트 증가 대비 효과가 낮다 — 지금 도입할 근거는 약하다. 엔티티가 크게 늘어나거나
ID 혼동으로 인한 버그가 실제로 발생하면 재검토.

## 5. 예외 처리 — `ReadableErrorAttributes`로 예외를 메시지로 변환

`ReadableErrorAttributes`(`web/support/servlet/error/ReadableErrorAttributes.java`)가
`DefaultErrorAttributes`를 감싸, 예외 클래스명 기반 코드(`"Exception.%s".formatted(...)`)를
`MessageSource`에서 조회해 사용자 친화적 메시지로 치환한다. `BindingResult`가 있으면 검증 오류
목록도 `errors` 필드에 추가한다.

**Etude와의 차이**: Etude는 `ErrorType` enum에 메시지를 직접 갖고 있고
(`CoreException(ErrorType.UNAUTHORIZED, "인증이 필요합니다.")`), todoapp은 예외 클래스명을
`MessageSource`(properties 파일)의 키로 변환해 메시지를 외부화한다. 다국어 지원이나 메시지를
코드 밖에서 관리해야 할 요구가 없다면 Etude 방식(메시지를 코드에 직접 명시)이 오히려 더 단순하고
추적하기 쉽다.

**Etude 적용**: 다국어 지원 계획이 없다면 참고할 필요 없음. Etude의 `ErrorType` 중앙관리가 이미
충분히 정교하다.

## 6. 테스트 전략 — 사실상 없음

`TodoApplicationTests.java`(`@SpringBootTest`로 컨텍스트 로딩만 확인) 하나뿐이고, 단위 테스트/
mock/Testcontainers/픽스처 관리가 전혀 없다. 코드 곳곳에 `/** 5) 확장 기능... 구현해보세요 */`
같은 실습 요구사항 주석이 남아있어, 교육 과정 진행 중(미완성) 상태의 실습 코드로 보인다.

**Etude 적용**: 참고할 게 없다 — Etude가 이미 이 레포보다 훨씬 촘촘한 테스트 체계
(`QuestServiceTest` + `QuestControllerTest` + Testcontainers)를 갖추고 있다.

## 7. 그 외 특이 패턴

- **`ContentNegotiatingViewResolver`에 CSV 뷰 추가**: `WebMvcConfiguration.ContentNegotiationCustomizer`가
  `@Autowired` setter로 `ContentNegotiatingViewResolver`의 `defaultViews`에
  `CommaSeparatedValuesView`를 끼워 넣어 CSV 다운로드를 지원한다. Etude에 CSV 내보내기 요구가
  생기면 참고할 만한 구조이나, 지금은 해당 요구 자체가 없다.
- **SSE를 서블릿 API로 직접 구현**: `OnlineUsersCounterController`가 `text/event-stream`을 손으로
  구현한 데모. Spring의 `SseEmitter`를 쓰지 않고 로우레벨로 구현한 예시라 실전 참고용은 아니다.
- **인터셉터 3종 조합**: `LoggingHandlerInterceptor`(요청 단계별 debug 로그),
  `ExecutionTimeHandlerInterceptor`(`StopWatch`로 실행시간 측정, `Ordered.MIN_VALUE`로 최우선
  실행), `RolesVerifyHandlerInterceptor`(3절 참고)를 `addInterceptors`에 순서대로 등록한다.
  실행시간 측정 인터셉터는 Etude에 아직 없는 것 — 운영 단계에서 API 응답 시간을 모니터링하고 싶을
  때 참고할 수 있다.

---

## 종합 판단: 지금 Etude에 적용할 가치가 있는 것

1. **`@LoginUser` 리졸버 가이드 자체를 검증하는 참고 사례로 활용** — 실제 동작하는
   `HandlerMethodArgumentResolver` 예제이므로, 가이드 구현 중 막히면
   `UserSessionHandlerMethodArgumentResolver.java`를 코드 레벨로 대조할 수 있다. 별도 작업 불필요.
2. **(낮은 우선순위) 실행시간 측정 인터셉터** — `ExecutionTimeHandlerInterceptor`처럼 요청
   처리시간을 로깅하는 인터셉터. 지금은 운영 모니터링 요구가 없어 보류, 배포 후 API 성능을 눈으로
   확인하고 싶어지면 가장 먼저 참고할 만한 항목.
3. 나머지(세션 홀더 인터페이스, ID 값 객체, `@RolesAllowed` 기반 인가, 메시지 외부화, CSV 뷰,
   SSE)는 Etude의 현재 방식이 이미 충분하거나 규모 대비 도입 근거가 약해 보류.
