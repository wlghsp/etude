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
- [ ] `{ containerId, questId, questSetId, sessionId, elapsedSec?, hintUsed?, solutionUsed? }`
      전송 시 200 + `{ passed: boolean }` (실제 컨테이너에서 `grade_cmd` 실행 결과)
- [ ] `grade_cmd`의 `$NS`가 `quest-${containerId 앞 8자}`로 치환된 뒤 실행된다
- [ ] 채점 명령이 15초 안에 끝나지 않으면 `passed: false` (원본 `execCheck`의 `timeoutMs`
      기본값과 동일)
- [ ] `Authorization: Bearer <유효한 토큰>`이 있으면 `quest_attempt`에 시도가 기록된다
      (`userId`는 토큰에서, 나머지는 요청 바디에서)
- [ ] `Authorization` 헤더가 없거나 유효하지 않은 토큰이어도 **401이 아니라 200** —
      `recordAttempt`만 건너뛰고 채점 자체는 정상 수행된다 (원본이 `try/catch`로
      `verifyToken` 실패를 무시하는 것과 동일)
- [ ] 이 엔드포인트는 `WebConfig`의 `AuthInterceptor` 대상 경로 목록(`/quest-sets/**` 등)에
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
> 있으므로 이 어댑터가 새로 주입받을 의존성은 없습니다 — Step 4에서 `QuestAttemptRepositoryImpl`이
> `QuestAttemptQuerydslRepository`만 주입받고 있었다면, 집계 전용이 아닌 단순 저장에는
> QueryDSL이 필요 없으므로 `QuestAttemptJpaRepository`를 함께 주입받도록 생성자를 넓힙니다.

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

`/grade`는 `WebConfig`의 `AuthInterceptor` 경로 패턴(`/quest-sets/**` 등)에 **추가하지
않습니다** — 그대로 두면 인증 없이도 도달 가능한 상태가 유지되어 인수 조건과 일치합니다.

---

## 7-4. 통합 테스트 — `QuestGradeControllerTest`

Step 6-1과 마찬가지로 실제 Docker 데몬이 필요한 첫 REST 통합 테스트입니다. `MockMvc`로
`/grade`를 호출하되, 사전에 `ContainerRuntime`(실제 `DockerContainerRuntime`)으로 컨테이너를
띄우고 그 안에서 채점 명령이 성공/실패하는 두 시나리오를 검증합니다.

```kotlin
class QuestGradeControllerTest(
    private val containerRuntime: ContainerRuntime,
    private val questRepository: QuestRepository,
) : IntegrationTest({
    "채점 명령이 성공하면" - {
        "passed: true를 응답하고, 토큰이 있으면 quest_attempt에 기록한다" {
            // given: grade_cmd가 항상 성공하는 퀘스트를 시드하고 컨테이너를 하나 띄운다
            // when: 유효한 회원 토큰으로 /grade 호출
            // then: 200, passed=true, quest_attempt 테이블에 1건 저장됨을 확인
        }
    }

    "토큰 없이 호출하면" - {
        "401이 아니라 채점 결과만 응답하고 기록은 남기지 않는다" {
            // when: Authorization 헤더 없이 /grade 호출
            // then: 200, quest_attempt에는 추가되지 않음
        }
    }

    "채점 명령이 실패하면" - {
        "passed: false를 응답한다" {
            // grade_cmd가 항상 실패(exit 1)하는 퀘스트로 검증
        }
    }
})
```

> 이 테스트가 시드하는 퀘스트의 `grade_cmd`는 `03_quest_set*.sql`의 실제 퀘스트를 재사용하지
> 않고, 테스트 전용으로 `["true"]`(항상 성공) / `["false"]`(항상 실패) 같은 단순 명령을 직접
> INSERT합니다 — 실제 시드 데이터의 채점 명령은 특정 리눅스 환경 설정을 전제해 통합 테스트
> 환경(범용 이미지)에서 그대로 통과한다는 보장이 없기 때문입니다. `$NS` 치환 자체를 검증하려면
> `["sh", "-c", "test $NS = quest-${컨테이너ID 앞 8자}"]`처럼 치환 결과를 직접 확인하는 명령을
> 시드에 넣습니다.

**수동 검증**: 브라우저로 실제 퀘스트를 열어 터미널에서 정답/오답을 각각 입력한 뒤 채점 버튼을
눌러, `passed` 값과 `/progress` 페이지의 진행률 반영을 눈으로 확인합니다.

---

## 완료 기준

- [ ] 위 인수 조건 체크리스트 전부 통과
- [ ] `QuestGradeControllerTest`(실제 Docker 데몬 대상 통합 테스트) 통과
- [ ] `./gradlew test` 전체 클래스를 한 번에 실행해도 Step 1~7 테스트 모두 통과
- [ ] 수동 검증으로 브라우저에서 채점 결과와 진행률 반영이 기존 Node.js 백엔드와 동일하게
      동작함을 확인
- [ ] `frontend/src/api/quest.ts`의 `gradeQuest()` 응답 타입(`{ passed: boolean }`)이 실제
      응답과 일치함을 확인 (일치하지 않으면 이 Step에서 컨트롤러 응답을 맞추고, 프론트 타입은
      건드리지 않는다 — 프론트 어댑터 계층 변경은 Step 10 cutover 원칙을 따른다)
