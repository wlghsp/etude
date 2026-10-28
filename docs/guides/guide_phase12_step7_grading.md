# Phase 12 Step 7 — 채점 (`POST /grade`)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step6_terminal.md](guide_phase12_step6_terminal.md)

대응하는 기존 Node.js 파일: `backend/src/services/quest.ts`의 `execCheck`/`gradeQuest`,
`backend/src/services/progress.ts`의 `recordAttempt`, `backend/src/routes/quest.routes.ts`의
`POST /grade`.

**경로 표기 안내**는 Step 1과 동일합니다.

## 원본 구조 분석

`quest.routes.ts`의 `POST /grade` 핸들러는 세 가지 일을 순서대로 합니다.

1. `gradeQuest(containerId, questId, docker)` — 퀘스트의 `grade_cmd`를 컨테이너 안에서 실행해
   통과 여부(`boolean`)를 얻는다
2. `Authorization` 헤더가 있으면(그리고 유효하면) `recordAttempt(...)`로 시도 기록을 저장한다 —
   **토큰이 없거나 유효하지 않아도 요청 자체는 실패하지 않는다**, `recordAttempt`만 건너뛴다
3. `{ passed }`를 응답한다

`gradeQuest` 내부의 `execCheck`는 Step 6-1에서 만든 `execAndWait`(끝날 때까지 기다리기만 하고
결과를 버림)과 달리 **exit code를 반환값으로 써야** 합니다. 원본은 `exec.inspect()`를 100ms
간격으로 폴링해 `info.Running`이 `false`가 될 때까지 기다린 뒤 `info.ExitCode === 0`을
반환합니다. 이 Step에서는 `ContainerRuntime` 포트에 이 기능이 아직 없으므로 새로 추가합니다
(아래 7-0).

`grade_cmd`의 `$NS` 치환(`quest-${containerId.slice(0, 8)}`)은 채점 명령이 컨테이너 안에 만드는
격리 네임스페이스(예: `netns`, `cgroup` 이름)가 컨테이너마다 겹치지 않도록 하는 장치입니다 —
`Quest` 시드 SQL(`03_quest_set*.sql`)의 `grade_cmd` 문자열에 이미 `$NS` 플레이스홀더가 박혀
있으므로, 이 치환 로직 자체를 옮겨야지 시드 데이터를 건드릴 필요는 없습니다.

## 인수 조건 (이 Step의 완료 기준)

*Node.js 원본(`quest.ts`의 `gradeQuest`/`execCheck`, `progress.ts`의 `recordAttempt`,
`quest.routes.ts`의 `POST /grade`)의 실제 동작이 곧 인수 조건이다.*

**채점 (`POST /grade`)**
- [x] `{ containerId, questId, questSetId, sessionId, elapsedSec?, hintUsed?, solutionUsed? }`
      전송 시 200 + `{ passed: boolean }` (실제 컨테이너에서 `grade_cmd` 실행 결과)
- [x] `grade_cmd`의 `$NS`가 `quest-${containerId 앞 8자}`로 치환된 뒤 실행된다
- [x] 채점 명령이 15초 안에 끝나지 않으면 `passed: false` (원본 `execCheck`의 `timeoutMs`
      기본값과 동일) — 컨트롤러 테스트가 아니라 `DockerContainerRuntimeTest`(7-4b)에서
      `timeoutMs`를 줄여 검증한다
- [x] `Authorization: Bearer <유효한 토큰>`이 있으면 `quest_attempt`에 시도가 기록된다
      (`userId`는 토큰에서, 나머지는 요청 바디에서)
- [x] `Authorization` 헤더가 없거나 유효하지 않은 토큰이어도 **401이 아니라 200** —
      `recordAttempt`만 건너뛰고 채점 자체는 정상 수행된다 (원본이 `try/catch`로
      `verifyToken` 실패를 무시하는 것과 동일)
- [x] 이 엔드포인트는 `WebConfig`의 `AuthInterceptor` 대상 경로 목록(`/quest-sets/**` 등)에
      **포함하지 않는다** — 다른 REST 엔드포인트와 달리 로그인 없이도 채점만은 가능해야 한다

이 조건들은 아래 7-4(통합 테스트)로 옮겨집니다.

프론트엔드(`frontend/src/api/quest.ts`의 `gradeQuest()`)는 이미 어댑터 형태로 준비되어 있어
(`apiFetch<{ passed: boolean }>('/grade', ...)`) 이 Step에서 건드릴 필요가 없습니다 — 응답 모양이
`{ passed: boolean }`과 일치하는지만 이 Step 완료 후 확인합니다.

## 진행 방식

이 Step도 Step 6-1과 마찬가지로 원본에 이미 명확한 로직이 있어 설계를 탐색할 필요가 없습니다.
다만 `ContainerRuntime` 포트에 exit code를 반환하는 메서드가 없다는 점, 그리고
`ProgressService`가 지금은 읽기 전용(`getProgress`/`getLeaderboard`)이라 쓰기 메서드가
없다는 점, 이 두 가지가 이 Step에서 새로 채워야 할 구멍입니다.

레이어는 `domain/terminal`(포트 확장) → `infrastructure/docker`(어댑터 구현) →
`domain/quest`(채점 로직) → `domain/progress`(기록 저장) → `application/quest`(Facade) →
`interfaces/api/quest`(컨트롤러) → 통합 테스트 순으로 나갑니다.

---

## 7-0. `ContainerRuntime` 포트 확장 — `execAndCheck`

Step 6-1의 `execAndWait`은 반환값이 없습니다(`Unit`) — "끝날 때까지 기다리기만 하면 되는" 셋업
명령용입니다. 채점은 "끝난 뒤 exit code가 0인지"가 결과 그 자체이므로 별도 메서드로 분리합니다.
`execAndWait`에 `Boolean`을 억지로 얹지 않는 이유는, 셋업 명령의 exit code는 원본도 애초에 보지
않기 때문입니다(`runSetupCmd`는 결과를 버림) — 셋업과 채점은 "명령을 실행한다"는 점만 같고 "결과가
필요한가"는 다른 관심사입니다.

`domain/terminal/ContainerRuntime.kt`:

```kotlin
interface ContainerRuntime {
    fun listByLabel(label: String, includedStopped: Boolean): List<String>
    fun stopAndRemove(containerId: String)

    fun createContainer(spec: ContainerSpec): String
    fun startContainer(containerId: String)
    fun attachToMainProcess(containerId: String): TerminalStream
    fun execShell(containerId: String, command: List<String>): TerminalStream
    fun execAndWait(containerId: String, command: List<String>)
    fun execAndCheck(containerId: String, command: List<String>, timeoutMs: Long = 15_000): Boolean
}
```

`infrastructure/docker/DockerContainerRuntime.kt`에 구현을 추가합니다:

```kotlin
override fun execAndCheck(containerId: String, command: List<String>, timeoutMs: Long): Boolean {
    val execId = dockerClient.execCreateCmd(containerId)
        .withCmd(*command.toTypedArray())
        .withAttachStdout(true)
        .withAttachStderr(true)
        .exec()
        .id

    return runCatching {
        dockerClient.execStartCmd(execId).exec(ResultCallback.Adapter<Frame>())
            .awaitCompletion(timeoutMs, TimeUnit.MILLISECONDS)
        dockerClient.inspectExecCmd(execId).exec().exitCodeLong == 0L
    }.getOrDefault(false)
}
```

> `awaitCompletion(timeoutMs, TimeUnit.MILLISECONDS)`가 원본의 100ms 폴링 루프를 대체합니다 —
> docker-java의 `ResultCallback.awaitCompletion`은 타임아웃 있는 버전을 이미 제공하므로, 원본처럼
> 직접 폴링 루프를 짤 필요가 없습니다. 타임아웃을 넘기면 `awaitCompletion`이 `false`를 반환하는데
> (스트림이 아직 안 끝났다는 뜻), 이 경우 `inspectExecCmd`로 exit code를 봐도 아직 값이 없거나
> 무의미하므로 `runCatching`으로 감싸 `false`(불합격)로 처리합니다 — 원본 `execCheck`도 타임아웃
> 시 `return false`로 동일하게 처리합니다.
>
> `exitCodeLong == 0L`이 원본 `info.ExitCode === 0`에 대응합니다. docker-java의
> `InspectExecResponse`는 `exitCodeLong`(Long?)과 `exitCode`(Int, deprecated) 두 필드를 제공하는데
> 여기서는 deprecated되지 않은 쪽을 씁니다.

---

## 7-1. `QuestService` — 채점 로직

원본 `gradeQuest`가 하던 두 가지 일(grade_cmd 조회 + `$NS` 치환, execCheck 호출)을
`QuestService`에 추가합니다. `$NS` 치환은 Step 6-1의 `runSetupCommand`가 하는 일(퀘스트의 명령
배열을 DB에서 읽어와 컨테이너에서 실행)과 같은 결이라 같은 서비스에 둡니다.

`domain/quest/QuestService.kt`에 추가:

```kotlin
fun grade(containerId: String, questId: Long): Boolean {
    val quest = questRepository.findById(questId) ?: return false
    val cmd = objectMapper.readValue(quest.gradeCmd, Array<String>::class.java).toList()

    val ns = "quest-${containerId.take(8)}"
    val resolvedCmd = cmd.map { it.replace("\$NS", ns) }

    return containerRuntime.execAndCheck(containerId, resolvedCmd)
}
```

`QuestService`가 아직 `ContainerRuntime`을 주입받고 있지 않다면 생성자에 추가합니다.

> `containerId.take(8)`이 원본 `containerId.slice(0, 8)`과 동일합니다 — dockerode의
> 컨테이너 ID는 Kotlin의 `String`과 마찬가지로 앞 8자만 잘라도 실무적으로 충돌 없이
> 유일합니다(도커 자체가 짧은 ID로 이 앞 12자를 표준으로 쓰는 관행과 같은 근거).
>
> 존재하지 않는 `questId`가 들어오면 원본은 `rows.length`가 0이라 `false`를 반환합니다 — 여기서도
> `findById`가 `null`이면 예외를 던지지 않고 그대로 `false`를 반환해 원본과 동일한 관용을
> 유지합니다. Step 3의 `getQuests`처럼 접근 권한을 확인하는 경로가 아니므로(채점은 애초에
> 인증조차 필요 없는 엔드포인트) `QuestSetAccessDeniedException` 같은 예외를 새로 도입할
> 이유가 없습니다.

### 7-1b. `QuestServiceTest` — 채점 단위 테스트

`grade`는 DB 조회와 문자열 치환, 그리고 `ContainerRuntime` 호출을 조율하는 도메인 서비스
로직이므로, 실제 Docker 없이 MockK로 검증합니다(`docs/testing/testing_layers.md`의 "도메인 서비스
단위 테스트" 원칙). 실제 컨테이너에서 명령이 실행되는지는 7-4/7-4b의 몫입니다.

`QuestService` 생성자에 `containerRuntime`이 추가됐으므로 `QuestServiceTest` 상단의 mock과
생성자 호출부를 먼저 맞춥니다.

```kotlin
val containerRuntime = mockk<ContainerRuntime>()
val questService = QuestService(
    questSetRepository, questRepository, questSetAccessRepository,
    userRepository, objectMapper, containerRuntime,
)

beforeTest { clearMocks(containerRuntime) }   // 테스트 사이에 호출 기록이 섞이지 않게 비운다
```

`io.mockk.slot`, `io.mockk.clearMocks` import를 추가하고, 파일 끝(`})` 직전)에 다음 케이스를 추가합니다.

```kotlin
"채점할 때" - {
    "grade_cmd의 \$NS를 quest-{컨테이너ID 앞 8자}로 치환해서 컨테이너에 실행시킨다" {
        val quest = TestQuests.create(
            questSetId = 1L,
            gradeCmd = """["sh", "-c", "test ${'$'}NS = x"]""",
        )
        every { questRepository.findById(1L) } returns quest
        val executed = slot<List<String>>()
        every { containerRuntime.execAndCheck("abcdef1234567890", capture(executed), any()) } returns true

        questService.grade("abcdef1234567890", 1L) shouldBe true

        executed.captured shouldBe listOf("sh", "-c", "test quest-abcdef12 = x")
    }

    "컨테이너에서 채점 명령이 실패하면" - {
        "false를 반환한다" {
            val quest = TestQuests.create(questSetId = 1L, gradeCmd = """["false"]""")
            every { questRepository.findById(1L) } returns quest
            every { containerRuntime.execAndCheck(any(), any(), any()) } returns false

            questService.grade("abcdef1234567890", 1L) shouldBe false
        }
    }

    "존재하지 않는 퀘스트면" - {
        "예외 없이 false를 반환하고 컨테이너를 호출하지 않는다" {
            every { questRepository.findById(999L) } returns null

            questService.grade("abcdef1234567890", 999L) shouldBe false

            verify(exactly = 0) { containerRuntime.execAndCheck(any(), any(), any()) }
        }
    }
}
```

> `execAndCheck`는 기본 파라미터(`timeoutMs = 15_000`)가 있어도 MockK 스텁에서는 3번째 인자를
> `any()`로 명시해야 합니다. 서비스 코드는 `timeoutMs`를 생략해 호출하지만, 컴파일된 호출은 기본값이
> 채워진 3-인자 호출이기 때문입니다.
>
> **`beforeTest { clearMocks(containerRuntime) }`가 꼭 필요한 이유**: mock은 스펙 최상단에서 한 번만
> 만들어져 모든 케이스가 같은 인스턴스를 씁니다. MockK의 호출 기록도 인스턴스에 쌓이므로, 비우지
> 않으면 세 번째 케이스의 `verify(exactly = 0) { containerRuntime.execAndCheck(...) }`가 **앞선
> 두 케이스가 남긴 호출**까지 세어서 "call 1 of 1: ... should not be called"로 실패합니다.
> `grade` 코드의 버그가 아니라 테스트 격리 문제입니다.
>
> `questRepository.findById`는 `getById` 확장 함수가 아니라 `Quest?`를 반환하는 원본 메서드입니다
> (`grade`가 `?: return false`로 null을 관용하기 위해 쓰는 쪽).

---

## 7-2. `ProgressService` — 시도 기록 저장

Step 4에서 `QuestAttempt` 엔티티/리포지토리만 만들고 미뤄뒀던 쓰기 메서드를 추가합니다.

`domain/progress/QuestAttemptRepository.kt`에 추가:

```kotlin
interface QuestAttemptRepository {
    fun findProgressByUserId(userId: Long): List<QuestSetProgress>
    fun findLeaderboard(): List<MemberProgress>
    fun save(attempt: QuestAttempt)
}
```

`infrastructure/persistence/progress/QuestAttemptRepositoryImpl.kt`에 위임 추가:

```kotlin
override fun save(attempt: QuestAttempt) {
    questAttemptJpaRepository.save(attempt)
}
```

> `QuestAttemptJpaRepository`(`JpaRepository<QuestAttempt, Long>`)는 이미 `save`를 상속받고
> 있습니다. 다만 Step 4의 `QuestAttemptRepositoryImpl`은 집계 쿼리용
> `QuestAttemptQuerydslRepository`만 주입받고 있었으므로, 단순 저장에 쓸
> `QuestAttemptJpaRepository`를 **생성자에 추가로 주입**받도록 넓혀야 합니다. 저장에는 QueryDSL이
> 필요 없기 때문입니다.
>
> ```kotlin
> class QuestAttemptRepositoryImpl(
>     private val querydslRepository: QuestAttemptQuerydslRepository,
>     private val questAttemptJpaRepository: QuestAttemptJpaRepository,   // 추가
> ) : QuestAttemptRepository
> ```

`domain/progress/ProgressService.kt`에 추가 — `@Transactional(readOnly = true)`가 클래스
레벨에 붙어 있으므로 쓰기 메서드에는 `@Transactional`을 개별로 다시 붙여 오버라이드합니다:

```kotlin
@Transactional
fun recordAttempt(
    userId: Long,
    questId: Long,
    questSetId: Long,
    sessionId: String,
    passed: Boolean,
    elapsedSec: Int?,
    hintUsed: Boolean,
    solutionUsed: Boolean,
) {
    questAttemptRepository.save(
        QuestAttempt(
            userId = userId,
            questId = questId,
            questSetId = questSetId,
            sessionId = sessionId,
            elapsedSec = elapsedSec,
            hintUsed = hintUsed,
            solutionUsed = solutionUsed,
            passed = passed,
        )
    )
}
```

> 원본 `recordAttempt`가 `hintUsed`/`solutionUsed`를 `?? false`로 기본값 처리하는 부분은
> 이 Step에서 컨트롤러 쪽 요청 DTO(7-3)의 기본값으로 옮겨집니다 — 이 메서드 자체는 이미 확정된
> `Boolean`(non-null)을 받아 엔티티에 그대로 채웁니다.

---

## 7-3. `POST /grade` — 컨트롤러

이 엔드포인트가 다른 Quest 엔드포인트와 다른 점은 **인증이 선택적**이라는 것입니다.
`LoginUserArgumentResolver`(Step 1)는 이미 `parameter.isOptional`을 지원합니다 — Kotlin에서
파라미터를 nullable(`JwtPayload?`)로 선언하면 토큰이 없어도 401을 던지지 않고 `null`을 그대로
넘겨줍니다. 이 메커니즘이 원본의 `try { verifyToken(token) } catch { /* 무시 */ }`을 그대로
대체합니다 — 별도 try/catch 없이 "토큰이 없으면 payload가 null"이라는 타입으로 표현됩니다.

`GradeRequest` DTO를 `interfaces/api/quest/QuestV1ApiSpec.kt`(또는 별도 파일)에 추가합니다:

```kotlin
data class GradeRequest(
    val containerId: String,
    val questId: Long,
    val questSetId: Long,
    val sessionId: String,
    val elapsedSec: Int? = null,
    val hintUsed: Boolean = false,
    val solutionUsed: Boolean = false,
)

data class GradeResponse(val passed: Boolean)
```

`QuestV1ApiSpec`에 추가:

```kotlin
@Operation(summary = "퀘스트 채점", description = "컨테이너 안에서 채점 명령을 실행하고, 로그인 상태면 시도 기록을 남깁니다.")
fun grade(request: GradeRequest, payload: JwtPayload?): ApiResponse<GradeResponse>
```

`QuestV1Controller`에 추가:

```kotlin
@PostMapping("/grade")
override fun grade(
    @RequestBody request: GradeRequest,
    @LoginUser payload: JwtPayload?,
): ApiResponse<GradeResponse> {
    val passed = questFacade.grade(request.containerId, request.questId)

    if (payload != null) {
        questFacade.recordAttempt(
            userId = payload.userId,
            questId = request.questId,
            questSetId = request.questSetId,
            sessionId = request.sessionId,
            passed = passed,
            elapsedSec = request.elapsedSec,
            hintUsed = request.hintUsed,
            solutionUsed = request.solutionUsed,
        )
    }

    return ApiResponse.success(GradeResponse(passed))
}
```

> `@LoginUser` 자체에는 `required` 같은 속성이 없습니다(`LoginUser.kt`는 빈 마커
> 애노테이션). 필수 여부는 순전히 파라미터 타입으로 결정됩니다 —
> `LoginUserArgumentResolver.resolveArgument`(Step 1)가 `parameter.isOptional`을 보는데, 이는
> Kotlin에서 파라미터를 nullable(`JwtPayload?`)로 선언하면 `true`가 되는 값입니다. 즉 이
> 컨트롤러가 다른 Quest 엔드포인트(`payload: JwtPayload`, non-null)와 다른 점은 오직 파라미터
> 타입에 `?`를 붙였다는 것뿐입니다 — payload가 없을 때 예외를 던지는 대신 `null`을 그대로
> 반환하도록 리졸버가 이미 분기해두었으므로, 원본의 `try/catch`에 대응하는 코드를 컨트롤러
> 쪽에 새로 쓸 필요가 없습니다.
>
> `QuestFacade`에 `grade`/`recordAttempt` 두 메서드를 새로 추가해야 합니다 — 채점은
> `QuestService`, 기록은 `ProgressService` 소관이라 서로 다른 도메인 서비스를 호출하지만, 이
> 엔드포인트 하나가 "채점하고 기록한다"는 하나의 유스케이스이므로 Facade 계층에서 조합하는 것이
> Step 1부터 지켜온 레이어 원칙(Facade가 여러 도메인 서비스를 조합, 컨트롤러는 얇게 유지)과
> 일치합니다. `QuestFacade`가 `ProgressService`를 새로 주입받아야 합니다.

`application/quest/QuestFacade.kt`를 아래처럼 고칩니다. 생성자에 `ProgressService`를 추가하고,
두 메서드는 각 도메인 서비스로 **위임만** 합니다(기존 메서드들과 같은 한 줄 위임 스타일).

```kotlin
import com.etude.domain.progress.ProgressService   // 추가

@Component
class QuestFacade(
    private val questService: QuestService,
    private val progressService: ProgressService,   // 추가
) {
    // ... 기존 메서드 생략 ...

    fun grade(containerId: String, questId: Long): Boolean = questService.grade(containerId, questId)

    fun recordAttempt(
        userId: Long,
        questId: Long,
        questSetId: Long,
        sessionId: String,
        passed: Boolean,
        elapsedSec: Int?,
        hintUsed: Boolean,
        solutionUsed: Boolean,
    ) {
        progressService.recordAttempt(
            userId = userId,
            questId = questId,
            questSetId = questSetId,
            sessionId = sessionId,
            passed = passed,
            elapsedSec = elapsedSec,
            hintUsed = hintUsed,
            solutionUsed = solutionUsed,
        )
    }
}
```

> `grade`와 `recordAttempt`를 하나의 Facade 메서드로 합치지 않고 둘로 나눈 이유는 "토큰이
> 없으면 기록만 건너뛴다"는 분기를 컨트롤러가 이미 `payload != null`로 결정하기 때문입니다.
> Facade 메서드 하나로 합치면 `userId: Long?`을 받아 내부에서 또 분기해야 해서, 인증 여부라는
> HTTP 계층의 관심사가 `application` 계층으로 새어 들어갑니다.
>
> 또 하나 주의할 점: `grade`는 DB 조회 + Docker exec(최대 15초 대기)를 하는 메서드이고
> `recordAttempt`는 쓰기 트랜잭션입니다. Facade에는 `@Transactional`을 붙이지 않았으므로
> (트랜잭션은 `ProgressService.recordAttempt`가 자기 범위만 연다) 채점 대기 시간 동안 DB
> 커넥션을 점유하지 않습니다. 나중에 Facade에 `@Transactional`을 붙이고 싶어지더라도 이
> 이유 때문에 붙이지 않는 것이 맞습니다.

`/grade`는 `WebConfig`의 `AuthInterceptor` 경로 패턴(`/quest-sets/**` 등)에 **추가하지
않습니다** — 그대로 두면 인증 없이도 도달 가능한 상태가 유지되어 인수 조건과 일치합니다.

---

## 7-4. 통합 테스트 — `QuestGradeControllerTest`

Step 6-1과 마찬가지로 실제 Docker 데몬이 필요한 첫 REST 통합 테스트입니다. `MockMvc`로
`/grade`를 호출하되, 사전에 `ContainerRuntime`(실제 `DockerContainerRuntime`)으로 컨테이너를
띄우고 그 안에서 채점 명령이 성공/실패하는 시나리오와 토큰 유무에 따른 기록 여부를
검증합니다.

`src/test/kotlin/com/etude/interfaces/api/quest/QuestGradeControllerTest.kt` (전체):

```kotlin
package com.etude.interfaces.api.quest

import com.etude.domain.terminal.ContainerRuntime
import com.etude.domain.terminal.ContainerSpec
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.progress.QuestAttemptJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import com.etude.support.TestAuth
import com.etude.support.TestQuestSets
import com.etude.support.TestQuests
import com.etude.support.TestUsers
import io.kotest.matchers.shouldBe
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.ResultActions
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class QuestGradeControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val containerRuntime: ContainerRuntime,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questJpaRepository: QuestJpaRepository,
    @Autowired private val questAttemptJpaRepository: QuestAttemptJpaRepository,
) : IntegrationTest({
    var userId = 0L
    var questSetId = 0L
    lateinit var containerId: String

    // 채점 명령이 실행될 컨테이너 — 테스트마다 하나 띄우고 끝나면 지운다.
    // TerminalWebSocketHandlerTest와 같은 이유로 로컬에 이미 있는 etude-linux 이미지를 쓴다
    // (createContainer는 이미지를 자동으로 pull하지 않는다).
    beforeTest {
        userId = TestUsers.createMember(userJpaRepository).id
        questSetId = TestQuestSets.createPublic(questSetJpaRepository).id

        containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = "etude-linux",
                binds = emptyList(),
                command = listOf("sh", "-c", "trap 'exit 0' TERM; sleep 300 & wait"),
                tty = false,
                openStdin = false,
            )
        )
        containerRuntime.startContainer(containerId)
    }

    afterTest {
        containerRuntime.stopAndRemove(containerId)
    }

    fun saveQuest(gradeCmd: String): Long =
        TestQuests.createAndSave(questJpaRepository, questSetId = questSetId, gradeCmd = gradeCmd).id

    fun grade(questId: Long, token: String? = null): ResultActions =
        mockMvc.perform(
            post("/grade")
                .contentType(MediaType.APPLICATION_JSON)
                .apply { token?.let { header("Authorization", "Bearer $it") } }
                .content(
                    """
                    {
                      "containerId": "$containerId",
                      "questId": $questId,
                      "questSetId": $questSetId,
                      "sessionId": "session-1",
                      "elapsedSec": 42,
                      "hintUsed": true,
                      "solutionUsed": false
                    }
                    """.trimIndent()
                )
        )

    fun memberToken(): String =
        TestAuth.loginAndGetToken(mockMvc, TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

    "채점 명령이 성공하면" - {
        "passed: true를 응답하고, 토큰이 있으면 quest_attempt에 기록한다" {
            val questId = saveQuest("""["true"]""")

            grade(questId, memberToken())
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))

            val attempts = questAttemptJpaRepository.findAll()
            attempts.size shouldBe 1
            attempts[0].userId shouldBe userId
            attempts[0].questId shouldBe questId
            attempts[0].questSetId shouldBe questSetId
            attempts[0].sessionId shouldBe "session-1"
            attempts[0].elapsedSec shouldBe 42
            attempts[0].hintUsed shouldBe true
            attempts[0].solutionUsed shouldBe false
            attempts[0].passed shouldBe true
        }

        "grade_cmd의 \$NS를 quest-{컨테이너ID 앞 8자}로 치환해서 실행한다" {
            // 치환이 틀리면 test가 실패(exit 1)해서 passed=false가 된다
            val questId = saveQuest(
                """["sh", "-c", "test ${'$'}NS = quest-${containerId.take(8)}"]"""
            )

            grade(questId)
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))
        }
    }

    "토큰 없이 호출하면" - {
        "401이 아니라 채점 결과만 응답하고 기록은 남기지 않는다" {
            val questId = saveQuest("""["true"]""")

            grade(questId)
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))

            questAttemptJpaRepository.count() shouldBe 0
        }
    }

    "유효하지 않은 토큰으로 호출하면" - {
        "401이 아니라 채점 결과만 응답하고 기록은 남기지 않는다" {
            val questId = saveQuest("""["true"]""")

            grade(questId, token = "invalid.token.value")
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))

            questAttemptJpaRepository.count() shouldBe 0
        }
    }

    "채점 명령이 실패하면" - {
        "passed: false를 응답하고, 토큰이 있으면 실패한 시도도 기록한다" {
            val questId = saveQuest("""["false"]""")

            grade(questId, memberToken())
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(false))

            val attempts = questAttemptJpaRepository.findAll()
            attempts.size shouldBe 1
            attempts[0].passed shouldBe false
        }
    }

    "존재하지 않는 questId로 호출하면" - {
        "예외 없이 passed: false를 응답한다" {
            grade(questId = 999_999L)
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(false))
        }
    }
})
```

> **원래 스켈레톤에서 바뀐 점**
> - `@AutoConfigureMockMvc`와 `@Autowired`를 붙였습니다. 다른 컨트롤러 테스트
>   (`ProgressControllerTest` 등)와 같은 방식이고, 이게 없으면 `MockMvc`를 주입받지 못합니다.
> - `QuestRepository`는 뺐습니다. 시드는 `QuestJpaRepository`로 하는 게 기존 `TestQuests`
>   픽스처(`createAndSave`)와 맞습니다.
> - 응답 경로가 `$.data.passed`인 이유는 Step 1부터 모든 응답이 `ApiResponse`(`{ meta, data }`)로
>   감싸지기 때문입니다.
> - 컨테이너는 `beforeTest`에서 만들고 `afterTest`에서 `stopAndRemove`로 지웁니다. 이 정리가
>   빠지면 테스트를 돌릴 때마다 `sleep 300` 컨테이너가 남습니다.
> - 컨테이너가 `tty = false`, `openStdin = false`인 이유는 채점이 `exec`로 실행되기 때문입니다.
>   메인 프로세스가 살아 있기만 하면 되고 터미널 attach는 필요 없습니다.
> - **`command`를 `sleep 300`이 아니라 `sh -c "trap 'exit 0' TERM; sleep 300 & wait"`로 쓰는
>   이유**: `sleep`이 PID 1이면 SIGTERM을 무시해서 `afterTest`의 `docker stop`이 케이스마다
>   10초씩 걸립니다(6개 케이스에 약 1분). `trap`으로 SIGTERM 핸들러를 달면 0.1초대로 끝납니다.
>   자세한 원리와 실측은 [glossary/container_pid1_signals.md](../glossary/container_pid1_signals.md)
>   를 참고하세요. `exec sleep 300`처럼 `exec`를 붙이면 핸들러가 사라져 다시 느려집니다.
>
> **테스트 실행 전 확인**
> - Docker 데몬이 떠 있어야 하고 `etude-linux` 이미지가 로컬에 있어야 합니다
>   (`docker images | grep etude-linux`).
> - `"\$NS를 ..."` 테스트에서 `${'$'}NS`로 쓴 이유는 Kotlin 문자열 안의 `$NS`가 템플릿 변수로
>   해석되기 때문입니다. 서비스가 치환하는 건 컨테이너에 전달되기 전의 리터럴 `$NS`입니다.
> - 15초 타임아웃은 이 테스트에서 검증하지 않습니다. 컨트롤러 테스트는 `timeoutMs`를 바꿀 수
>   없어 실제로 15초를 기다려야 하고, 타임아웃 처리는 HTTP 계약이 아니라 `ContainerRuntime`
>   어댑터의 책임이기 때문입니다. 아래 7-4b에서 검증합니다.

> 이 테스트가 `saveQuest()`로 저장하는 퀘스트의 `grade_cmd`는 `03_quest_set*.sql`의 실제
> 퀘스트를 재사용하지 않고, 테스트 전용으로 `["true"]`(항상 성공) / `["false"]`(항상 실패) 같은
> 단순 명령을 씁니다 — 실제 시드 데이터의 채점 명령은 특정 리눅스 환경 설정을 전제해 통합 테스트
> 환경(범용 이미지)에서 그대로 통과한다는 보장이 없기 때문입니다. `$NS` 치환 자체는
> `["sh", "-c", "test $NS = quest-{컨테이너ID 앞 8자}"]`처럼 치환 결과를 직접 확인하는 명령으로
> 검증합니다(위 두 번째 케이스).

---

## 7-4b. 타임아웃 검증 — `DockerContainerRuntimeTest`

채점 타임아웃은 `DockerContainerRuntime.execAndCheck`의 동작이므로 어댑터를 직접 호출하고
`timeoutMs`를 1초로 줄여 검증합니다(기본값 15초를 기다리지 않음). `QuestGradeControllerTest`와
같은 전제(Docker 데몬, 로컬 `etude-linux` 이미지)가 필요합니다.

`src/test/kotlin/com/etude/infrastructure/docker/DockerContainerRuntimeTest.kt` (전체):

```kotlin
package com.etude.infrastructure.docker

import com.etude.domain.terminal.ContainerRuntime
import com.etude.domain.terminal.ContainerSpec
import com.etude.support.IntegrationTest
import io.kotest.matchers.shouldBe
import org.springframework.beans.factory.annotation.Autowired

class DockerContainerRuntimeTest(
    @Autowired private val containerRuntime: ContainerRuntime,
) : IntegrationTest({
    lateinit var containerId: String

    beforeTest {
        containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = "etude-linux",
                binds = emptyList(),
                command = listOf("sh", "-c", "trap 'exit 0' TERM; sleep 300 & wait"),
                tty = false,
                openStdin = false,
            )
        )
        containerRuntime.startContainer(containerId)
    }

    afterTest {
        containerRuntime.stopAndRemove(containerId)
    }

    "execAndCheck는" - {
        "명령이 exit 0으로 끝나면 true를 반환한다" {
            containerRuntime.execAndCheck(containerId, listOf("true")) shouldBe true
        }

        "명령이 0이 아닌 exit code로 끝나면 false를 반환한다" {
            containerRuntime.execAndCheck(containerId, listOf("false")) shouldBe false
        }

        "timeoutMs 안에 끝나지 않으면 false를 반환한다" {
            containerRuntime.execAndCheck(containerId, listOf("sleep", "30"), timeoutMs = 1_000) shouldBe false
        }
    }
})
```

> `IntegrationTest`를 상속하는 이유는 `QuestGradeControllerTest`와 같은 스프링 컨텍스트를 재사용해
> `ContainerRuntime` 빈을 주입받기 위해서입니다(프로젝트에 이미 있는 기반 클래스라 새 설정이
> 필요 없습니다).
>
> 이 테스트가 실패하면(`timeoutMs` 케이스에서 `true`가 나오거나 테스트가 30초 가까이 걸리면)
> `execAndCheck`의 `awaitCompletion(timeoutMs, ...)` 반환값과 `exitCodeLong` 처리를 먼저
> 의심하세요. 정상이라면 이 케이스는 약 1초에 끝납니다.

**수동 검증**: 브라우저로 실제 퀘스트를 열어 터미널에서 정답/오답을 각각 입력한 뒤 채점 버튼을
눌러, `passed` 값과 `/progress` 페이지의 진행률 반영을 눈으로 확인합니다.

---

## 완료 기준

- [x] 위 인수 조건 체크리스트 전부 통과
- [ ] `QuestServiceTest`의 채점 케이스(7-1b) 통과
- [x] `QuestGradeControllerTest`(실제 Docker 데몬 대상 통합 테스트) 통과
- [x] `DockerContainerRuntimeTest`(성공/실패/타임아웃) 통과
- [x] `./gradlew test` 전체 클래스를 한 번에 실행해도 Step 1~7 테스트 모두 통과
- [ ] 수동 검증으로 브라우저에서 채점 결과와 진행률 반영이 기존 Node.js 백엔드와 동일하게
      동작함을 확인
- [ ] `frontend/src/api/quest.ts`의 `gradeQuest()` 응답 타입(`{ passed: boolean }`)이 실제
      응답과 일치함을 확인 (일치하지 않으면 이 Step에서 컨트롤러 응답을 맞추고, 프론트 타입은
      건드리지 않는다 — 프론트 어댑터 계층 변경은 Step 10 cutover 원칙을 따른다)
