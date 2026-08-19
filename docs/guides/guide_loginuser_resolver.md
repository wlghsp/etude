# `@LoginUser` 커스텀 어노테이션 — 컨트롤러의 JwtPayload 캐스팅 제거

근거: [docs/research/reference_projects_action_items.md 1-1](../research/reference_projects_action_items.md)

## 문제

로그인한 사용자 정보가 필요한 컨트롤러 메서드마다 아래 패턴이 반복되고 있다.

```kotlin
val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
```

반복되는 곳:

- `AuthV1Controller.me` — `backend-kotlin/apps/backend/src/main/kotlin/com/etude/interfaces/api/auth/AuthV1Controller.kt:32`
- `MeV1Controller.changePassword` — `.../interfaces/api/user/MeV1Controller.kt:27`
- `QuestV1Controller.getQuestSets`, `getQuests` — `.../interfaces/api/quest/QuestV1Controller.kt:20,28`

이 패턴은 두 가지 위험을 갖는다.

1. **캐스팅 실수**: `as JwtPayload`는 컴파일 타임에 안전성을 보장하지 않는다. 실제로
   `QuestV1Controller`에서 `getAttribute` 대신 `getHeader`를 잘못 써서 NPE가 났던 사례가 있다.
2. **ApiSpec 인터페이스 오염**: `override`가 시그니처를 일치시켜야 하므로, `QuestV1ApiSpec`/
   `MeV1ApiSpec` 같은 인터페이스에도 `HttpServletRequest`가 그대로 노출된다 — API 스펙 문서에
   HTTP 서블릿 타입이 드러나는 건 계층 분리 원칙에 맞지 않는다.

## 방향

Spring MVC의 `HandlerMethodArgumentResolver`를 구현해, 컨트롤러 메서드 파라미터에
`@LoginUser payload: JwtPayload`라고 쓰면 `JwtAuthFilter`가 request attribute에 넣어둔
`JwtPayload`를 Spring이 알아서 주입하게 만든다.

```kotlin
fun me(@LoginUser payload: JwtPayload): ApiResponse<JwtPayload> =
    ApiResponse.success(payload)
```

## 구현

### 1. `@LoginUser` 어노테이션 (`infrastructure/security/ .kt`)

```kotlin
package com.etude.infrastructure.security

@Target(AnnotationTarget.VALUE_PARAMETER)
@Retention(AnnotationRetention.RUNTIME)
annotation class LoginUser
```

### 2. `LoginUserArgumentResolver` (`infrastructure/security/LoginUserArgumentResolver.kt`)

파라미터를 `JwtPayload`(non-null)로 선언하면 payload가 없을 때 401을 던지고, `JwtPayload?`
(nullable)로 선언하면 없을 때 그냥 `null`을 반환한다 — "필수 로그인"과 "선택적 로그인"을 별도
어노테이션 없이 Kotlin의 nullable 타입만으로 구분한다. `MethodParameter.isOptional()`이
Kotlin 파라미터의 nullable 여부를 인식하므로 이 판단에 그대로 쓸 수 있다.

```kotlin
package com.etude.infrastructure.security

import com.etude.domain.auth.JwtPayload
import com.etude.support.error.CoreException
import com.etude.support.error.ErrorType
import org.springframework.core.MethodParameter
import org.springframework.web.bind.support.WebDataBinderFactory
import org.springframework.web.context.request.NativeWebRequest
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.method.support.ModelAndViewContainer

class LoginUserArgumentResolver : HandlerMethodArgumentResolver {
    override fun supportsParameter(parameter: MethodParameter): Boolean =
        parameter.hasParameterAnnotation(LoginUser::class.java) &&
            parameter.parameterType == JwtPayload::class.java

    override fun resolveArgument(
        parameter: MethodParameter,
        mavContainer: ModelAndViewContainer?,
        webRequest: NativeWebRequest,
        binderFactory: WebDataBinderFactory?
    ): JwtPayload? {
        val payload = webRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD, NativeWebRequest.SCOPE_REQUEST) as? JwtPayload
        if (payload != null) return payload
        if (parameter.isOptional) return null
        throw CoreException(ErrorType.UNAUTHORIZED, "인증이 필요합니다.")
    }
}
```

> `AuthInterceptor`(`WebConfig.kt`)가 이미 인증이 필요한 경로에서 payload 존재 여부를 401로
> 걸러주므로, `@LoginUser payload: JwtPayload`(non-null)로 선언한 파라미터에서는 이 리졸버가
> 호출되는 시점에 정상적으로는 payload가 항상 있다. 그래도 리졸버 단독으로도 안전하도록
> 방어적으로 예외를 던진다.
>
> `@LoginUser payload: JwtPayload?`(nullable)로 선언하면 `AuthInterceptor.addPathPatterns`
> 목록에 없는(인증이 강제되지 않는) 경로에서도 안전하게 쓸 수 있다 — payload가 있으면 그대로
> 받고, 없으면 예외 대신 `null`을 받는다. 이 경우 컨트롤러가 로그인 여부에 따라 분기하는 로직을
> 직접 작성해야 한다(예: `payload?.userId`).

### 3. `WebConfig`에 등록

`WebConfig.kt`는 이미 `WebMvcConfigurer`를 구현하고 있으므로 `addArgumentResolvers`만 추가하면
된다.

```kotlin
override fun addArgumentResolvers(resolvers: MutableList<HandlerMethodArgumentResolver>) {
    resolvers.add(LoginUserArgumentResolver())
}
```

### 4. 컨트롤러 교체

**Before** (`AuthV1Controller.kt`)

```kotlin
@GetMapping("/me")
override fun me(request: HttpServletRequest): ApiResponse<JwtPayload> =
    ApiResponse.success(request.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload)
```

**After**

```kotlin
@GetMapping("/me")
override fun me(@LoginUser payload: JwtPayload): ApiResponse<JwtPayload> =
    ApiResponse.success(payload)
```

`AuthV1ApiSpec`의 `fun me(request: HttpServletRequest): ...`도 `fun me(payload: JwtPayload): ...`로
함께 바꿔야 `override`가 성립한다 (파라미터 자체는 어노테이션 없이 타입만 일치하면 되지만,
가독성을 위해 ApiSpec에도 `@LoginUser`를 붙여둔다).

같은 방식으로 아래도 교체한다.

- `MeV1ApiSpec.changePassword` / `MeV1Controller.changePassword` — `httpRequest: HttpServletRequest`
  파라미터를 제거하고 `@LoginUser payload: JwtPayload`로 교체, 본문의
  `httpRequest.getAttribute(...)` 캐스팅 줄 삭제.
- `QuestV1ApiSpec.getQuestSets`/`getQuests`, `QuestV1Controller.getQuestSets`/`getQuests` — 동일.

## 검증 기준

- [ ] 컴파일 통과 — 4개 컨트롤러 메서드 어디에도 `REQUEST_ATTR_JWT_PAYLOAD`, `as JwtPayload`,
      `HttpServletRequest` 파라미터가 남아있지 않다 (단, `WebConfig`의 `AuthInterceptor`/
      `AdminInterceptor`는 여전히 `HttpServletRequest`를 쓴다 — 그건 인터셉터의 역할이라 대상이
      아니다).
- [ ] 기존 통합 테스트 그대로 통과 — `AuthControllerTest`, `UserAdminControllerTest`,
      `QuestControllerTest`, `AdminQuestSetControllerTest`. 이 리팩터링은 동작을 바꾸지 않으므로
      기존 테스트가 수정 없이 통과해야 한다 (토큰 없이 호출 시 401인 케이스 포함 — payload가 없을
      때 리졸버가 예외를 던지는 경로).
- [ ] 새 컨트롤러(Step 4 이후)에서 로그인 사용자가 필요하면 이 패턴을 기본으로 쓴다.
- [ ] 로그인 여부와 무관하게 동작해야 하는 엔드포인트(Step 4의 `/feedback` 등)는
      `@LoginUser payload: JwtPayload?`(nullable)로 선언해 재사용한다 — 별도의
      `@OptionalLoginUser` 어노테이션이나 리졸버를 새로 만들지 않는다.
