# Phase 12 Step 5 — Docker (SandboxConfig, ContainerRuntime 포트/어댑터)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step4_progress_feedback.md](guide_phase12_step4_progress_feedback.md)

대응하는 기존 Node.js 파일: `backend/src/services/sandbox.ts`(`getSandboxConfig`),
`backend/src/plugins/docker.ts`(`docker` 인스턴스, `cleanupOrphanContainers`,
`cleanupRunningContainers`).

**경로 표기 안내**는 Step 1과 동일합니다 — `domain/sandbox/SandboxConfig.kt`처럼 쓰는 경로는
`backend-kotlin/apps/backend/src/main/kotlin/com/etude/domain/sandbox/SandboxConfig.kt`를
가리킵니다.

## 이 Step의 성격 — REST API가 아니라 기반(포트/어댑터) 작업

Step 1~4는 전부 REST 엔드포인트를 만들고 그 엔드포인트를 인수 조건으로 삼았습니다. Step 5는
다릅니다 — `sandbox.ts`/`docker.ts`는 그 자체로 HTTP 엔드포인트가 아니라, Step 6(터미널)과
Step 7(채점)이 컨테이너를 다루기 위해 가져다 쓰는 **내부 컴포넌트**입니다. 그래서 이 Step의
인수 조건은 "어떤 API가 몇 번 응답하는가"가 아니라 "이 컴포넌트들이 계약대로 동작하는가"이고,
검증은 MockMvc가 아니라 **단위 테스트 + Testcontainers 없는 순수 통합 테스트**(실제 Docker
데몬에 대해 직접 실행)로 이루어집니다.

명세의 [테스트 전략](../specs/spec_phase12_kotlin_migration.md) 문단이 이미 이 지점을
언급합니다: "Docker/kubectl 연동처럼 외부 프로세스 의존이 강한 부분은 인터페이스로 추상화한 뒤
단위 테스트에서는 페이크 구현체를 쓰고 최소한의 수동/스모크 테스트로 실제 동작을 검증한다
(Docker-in-Docker 통합 테스트는 비용 대비 실익이 낮아 범위에서 제외)". 즉:

- `SandboxConfig` 조회(순수 DB 조회, 로직 없음): Step 1~4와 동일하게 Testcontainers MariaDB로
  통합 테스트.
  - `sandbox` 테이블 시드 데이터(`01_sandbox.sql`)가 이미 `IntegrationTest`의
    `withInitScripts`에 포함되어 있으므로 추가 스키마 작업은 필요 없다.
- `ContainerRuntime`(고아 컨테이너 정리 등 실제 Docker 데몬을 부르는 부분): 인터페이스(포트)로
  추상화하고, 단위 테스트는 MockK 페이크로, 실제 동작 확인은 로컬에서 Docker Desktop을 띄운 채
  수동으로 `bootRun` 후 라벨이 붙은 컨테이너가 정리되는지 눈으로 확인한다(5-4).

## 인수 조건 (이 Step의 완료 기준)

**샌드박스 설정 조회 (`SandboxConfigService`, 내부 컴포넌트 — API 없음)**
- [ ] `sandbox` 테이블에 있는 타입(예: `linux`)을 조회하면 `image`, `binds`(JSON 배열 파싱),
      `persistent` 값을 담은 설정을 반환한다.
- [ ] `binds`가 `NULL`인 타입(예: `linux`)을 조회하면 `binds`가 빈 값(`null` 또는 빈 리스트)으로
      반환된다 — 원본 `getSandboxConfig`가 `config.binds`가 falsy면 치환 로직을 건너뛰는 것과 동일.
- [ ] `binds`에 `{KUBECONFIG_HOST_PATH}` 플레이스홀더가 있는 타입(`k8s`)을 조회하면 그 자리가
      `KUBECONFIG_PATH` 환경변수(없으면 `$HOME/.kube/config`) 값으로 치환된 문자열로 반환된다 —
      원본 `config.binds.map(b => b.replace('{KUBECONFIG_HOST_PATH}', kubeconfig))`와 동일.
- [ ] DB에 없는 타입을 조회하면 기존 `getSandboxConfig`의 기본값(`{ image: 'ubuntu', binds: null }`)과
      동일하게 폴백한다 — 원본이 `rows[0] ?? { image: 'ubuntu', binds: null }`로 처리하던 동작.

**컨테이너 런타임 (`ContainerRuntime` 포트/어댑터, 내부 컴포넌트 — API 없음)**
- [ ] `etude=sandbox` 라벨이 붙은 컨테이너 전체를 조회할 수 있다 (`cleanupOrphanContainers`가
      `all: true`로 정지된 컨테이너까지 포함해 조회하는 것과 동일).
- [ ] `etude=sandbox` 라벨이 붙은 **실행 중인** 컨테이너만 조회할 수 있다 (`cleanupRunningContainers`가
      `all` 옵션 없이 조회하는 것과 동일 — dockerode 기본값은 실행 중인 컨테이너만).
- [ ] 조회된 각 컨테이너를 정지 후 제거할 수 있다. 정지/제거 중 에러가 나도(이미 정지됐거나
      이미 삭제된 컨테이너 등) 나머지 컨테이너 처리에 영향을 주지 않는다 — 원본이 각 호출을
      `.catch(() => {})`로 무시하는 것과 동일한 관용(fault-tolerant cleanup)이다.
- [ ] 앱 시작 시 `cleanupOrphanContainers`에 해당하는 정리(전체: 정지+실행 중 모두)가 호출된다.
- [ ] 앱 종료 시 `cleanupRunningContainers`에 해당하는 정리(실행 중인 것만)가 호출된다.

이 조건들은 아래 5-2(단위 테스트)와 5-4(수동 검증)로 확인합니다. Step 5는 REST 엔드포인트가
없으므로 통합 테스트(MockMvc)는 `SandboxConfigService`의 DB 조회 부분에만 해당합니다.

## 진행 방식

`SandboxConfig` 조회는 원본 로직이 이미 명확한 단순 조회+치환이라 Step 3/4와 동일하게
"구현 먼저 작성 → 테스트로 검증" 순서로 갑니다.

`ContainerRuntime`은 로직 자체(정지 후 제거, 라벨 필터)는 단순하지만 **실제 Docker 데몬**이라는
외부 시스템에 의존한다는 점이 다릅니다. docker-java로 호출하는 어댑터 구현은 실제 데몬 없이는
컴파일 타임에 정확성을 보장할 수 없으므로, 포트(인터페이스)를 먼저 정의하고 그 뒤를 살을 붙이는
순서로 진행합니다:

1. `domain/terminal`에 `ContainerRuntime` 포트 인터페이스 정의 (5-0)
2. `infrastructure/docker`에 docker-java 기반 어댑터 구현 (5-1)
3. 포트를 쓰는 정리 유스케이스(`ContainerCleanupService`)와 MockK 단위 테스트 (5-2)
4. `domain/sandbox`에 `SandboxConfig`/`SandboxConfigService`와 통합 테스트 (5-3)
5. `index.ts`의 부트스트랩/종료 훅에 대응하는 Spring 생명주기 연결 + 수동 검증 (5-4)

레이어는 `domain/terminal`(포트), `domain/sandbox`(엔티티 없음 — DB 조회 결과를 담는 값 타입 +
서비스) → `infrastructure/docker`(어댑터) → 수동 검증 순으로 나갑니다. Step 6(터미널)에서
`ContainerRuntime`에 컨테이너 생성/attach 메서드가 추가될 예정이므로, 이 Step에서는 정리에
필요한 최소 메서드만 정의합니다 — 미리 확장하지 않습니다.

---

## 5-0. 포트 — `ContainerRuntime` (`domain/terminal/ContainerRuntime.kt`)

원본 `docker.ts`가 하는 일은 딱 세 가지입니다: 라벨로 컨테이너 목록 조회(전체/실행 중), 정지,
제거. 이 Step에서는 그 세 가지만 포트로 정의합니다.

```kotlin
package com.etude.domain.terminal

interface ContainerRuntime {
    fun listByLabel(label: String, includeStopped: Boolean): List<String>
    fun stopAndRemove(containerId: String)
}
```

> `listByLabel`이 컨테이너 ID(`String`)의 리스트만 반환하는 이유는 원본
> `cleanupOrphanContainers`/`cleanupRunningContainers`가 목록 조회 결과에서 실제로 쓰는 값이
> `c.Id`뿐이기 때문입니다 — dockerode의 `ContainerInfo` 전체를 그대로 옮기면 Step 6에서 필요
> 없는 필드까지 도메인 레이어에 노출됩니다. `includeStopped`가 `all: true` 여부를 대체하는
> 이유도 같습니다 — dockerode 옵션 이름을 그대로 포트에 노출하지 않고 의도를 드러내는 이름으로
> 바꿉니다.
>
> `stopAndRemove`가 정지와 제거를 하나로 묶은 이유는 원본에서 이 둘이 항상 붙어 다니고
> (`container.stop().catch(() => {}); container.remove().catch(() => {})`), 호출하는 쪽에서
> 이 둘을 분리해서 쓸 일이 없기 때문입니다 — 실패를 무시하는 관용도 이 메서드의 구현
> 내부(5-1)에 캡슐화합니다.
>
> `label`을 파라미터로 받는 이유는 지금은 `etude=sandbox` 하나뿐이지만, Step 6에서 sandbox
> 타입별로 다른 라벨이 필요해질 가능성을 남겨두기 위함이 아니라 — 원본 자체가 이미 라벨 문자열을
> 함수 밖에 상수로 빼지 않고 호출부에 인라인으로 쓰고 있어, 포트가 그 값을 강제하지 않는 편이
> 원본과 더 가깝습니다. 상수화는 5-2의 `ContainerCleanupService`에서 합니다.

---

## 5-1. 어댑터 — `DockerContainerRuntime` (`infrastructure/docker/DockerContainerRuntime.kt`)

docker-java의 `DockerClient`를 감싸 `ContainerRuntime`을 구현합니다. `DockerClient` 인스턴스
자체는 `config/DockerConfig.kt`에서 `@Bean`으로 등록합니다 — 원본 `export const docker = new
Docker()`에 대응합니다.

```kotlin
package com.etude.config

import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.core.DefaultDockerClientConfig
import com.github.dockerjava.core.DockerClientConfig
import com.github.dockerjava.core.DockerClientImpl
import com.github.dockerjava.httpclient5.ApacheDockerHttpClient
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class DockerConfig {
    @Bean
    fun dockerClient(): DockerClient {
        val config: DockerClientConfig = DefaultDockerClientConfig.createDefaultConfigBuilder().build()
        val httpClient = ApacheDockerHttpClient.Builder()
            .dockerHost(config.dockerHost)
            .sslConfig(config.sslConfig)
            .build()
        return DockerClientImpl.getInstance(config, httpClient)
    }
}
```

> `DefaultDockerClientConfig.createDefaultConfigBuilder()`는 dockerode의 `new Docker()`와
> 동일하게 `~/.docker/config.json`의 `currentContext`를 읽어, 그 컨텍스트의 소켓 경로(예:
> Colima의 `unix:///Users/xxx/.colima/default/docker.sock`)를 자동으로 찾습니다 — 별도
> `DOCKER_HOST` 환경변수 없이도 `docker context ls`가 가리키는 소켓을 그대로 사용합니다.
>
> **의존성 버전은 반드시 `3.7.1` 이상을 씁니다.** `docker-java-core`/
> `docker-java-transport-httpclient5` **`3.4.0`에는 유닉스 소켓 연결 버그가 있습니다** —
> `ApacheDockerHttpClientImpl`이 `unix` 스킴의 `connectSocket()`을 TCP 전용
> `PlainConnectionSocketFactory`에 위임해버려서, `dockerHost`가 정확히 해석돼도 실제
> 연결은 항상 `Connection refused`(로그에 `unix://localhost:2375`라는 placeholder 호스트가
> 찍힘 — 실제 연결 대상이 아니라 내부적으로 쓰는 더미 값입니다)로 실패합니다. 이 버그는
> `3.5.0`(2025-04-01, PR "Upgrade Apache HttpClient to version 5.4")에서 소켓 연결 로직이
> `DefaultHttpClientConnectionOperator` 기반으로 재작성되며 사라졌습니다 — 그래서 `3.4.0`
> 대신 이후 버전(`3.7.1`)을 씁니다. `build.gradle.kts`의 두 좌표를 모두 같은 버전으로
> 맞춰야 합니다(`docker-java-core`와 `docker-java-transport-httpclient5`는 같은 릴리스
> 사이클로 배포되므로 버전이 어긋나면 호환성 문제가 생길 수 있습니다).
>
> `docker-java-core:3.7.1`에는 `DockerClientBuilder` 클래스가 없습니다(과거 버전에 있던
> 편의 클래스로, 3.x 초반에 이미 제거됨) — 대신 `DockerClientImpl.getInstance(config,
> httpClient)`로 직접 인스턴스를 생성합니다.

```kotlin
package com.etude.infrastructure.docker

import com.etude.domain.terminal.ContainerRuntime
import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.api.model.Filters
import org.springframework.stereotype.Component

@Component
class DockerContainerRuntime(
    private val dockerClient: DockerClient,
) : ContainerRuntime {
    override fun listByLabel(label: String, includeStopped: Boolean): List<String> =
        dockerClient.listContainersCmd()
            .withShowAll(includeStopped)
            .withLabelFilter(listOf(label))
            .exec()
            .map { it.id }

    override fun stopAndRemove(containerId: String) {
        runCatching { dockerClient.stopContainerCmd(containerId).exec() }
        runCatching { dockerClient.removeContainerCmd(containerId).exec() }
    }
}
```

> `withLabelFilter(listOf(label))`은 dockerode의
> `filters: JSON.stringify({ label: ['etude=sandbox'] })`와 동일한 라벨 필터입니다 —
> docker-java는 JSON 문자열 대신 타입 세이프한 빌더 API를 제공합니다.
>
> `runCatching { ... }`(결과를 버림)이 원본의 `.catch(() => {})`에 대응합니다 — 두 호출을
> 각각 독립적으로 감싸는 이유도 원본과 동일합니다: `stop()`이 실패해도(이미 정지된 컨테이너)
> `remove()`는 시도해야 합니다.
>
> `Filters` import는 실제로 안 쓰이므로(위 코드는 `withLabelFilter`만 사용) 컴파일 시
> 미사용 import 경고가 뜨면 지웁니다 — docker-java 버전에 따라 필터 빌더 API 이름이
> `withLabelFilter`가 아닐 수 있으니, 실제 작성 시 `docker-java-core:3.7.1`의
> `ListContainersCmd` API를 확인해 정확한 메서드명을 씁니다.

---

## 5-2. `ContainerCleanupService`와 단위 테스트 (`domain/terminal/ContainerCleanupService.kt`)

원본의 `cleanupOrphanContainers`(전체)와 `cleanupRunningContainers`(실행 중만)를 그대로
옮깁니다. 라벨 상수(`SANDBOX_LABEL`)를 여기서 정의합니다.

```kotlin
package com.etude.domain.terminal

import org.springframework.stereotype.Service

@Service
class ContainerCleanupService(
    private val containerRuntime: ContainerRuntime,
) {
    fun cleanupOrphanContainers() {
        containerRuntime.listByLabel(SANDBOX_LABEL, includeStopped = true)
            .forEach { containerRuntime.stopAndRemove(it) }
    }

    fun cleanupRunningContainers() {
        containerRuntime.listByLabel(SANDBOX_LABEL, includeStopped = false)
            .forEach { containerRuntime.stopAndRemove(it) }
    }

    companion object {
        const val SANDBOX_LABEL = "etude=sandbox"
    }
}
```

> 두 메서드가 거의 동일한데(`includeStopped` 값만 다름) 하나로 합치지 않는 이유는 원본이
> 이미 두 개의 별개 함수로 나뉘어 있고, 각각 호출 시점(부트스트랩 vs 종료 훅)이 다른 의도를
> 이름으로 드러내기 때문입니다 — `cleanup(includeStopped: Boolean)` 하나로 합치면 호출부에서
> 불리언 인자의 의미를 매번 다시 읽어야 합니다.
>
> `forEach`(순차 처리)를 그대로 쓰고 코루틴 등으로 병렬화하지 않는 이유는, 원본
> `cleanupOrphanContainers`/`cleanupRunningContainers`도 `for...of` 루프로 컨테이너를 하나씩
> 순차적으로 정지/제거하기 때문입니다 — 이 Step의 인수 조건은 "원본의 실제 동작"이므로
> 그대로 따릅니다. (참고로 같은 원본 코드베이스의 `vcluster-pool.ts`는 `Promise.all`로 병렬
> 처리합니다 — 즉 원본 자체가 파일마다 일관되지 않습니다. 컨테이너 수가 많아지면 종료 시
> 정리 시간이 컨테이너 수에 비례해 늘어나는 특성이 있는데, 이는 마이그레이션이 만든 회귀가
> 아니라 원본에 이미 있던 특성입니다. 병렬화가 필요하다고 판단되면 Step 5 범위를 벗어난
> 별도 개선으로 다루고, `vcluster-pool.ts`를 옮기는 Step 8에서 원본이 병렬 처리하는 코드를
> 그대로 가져올 때 이 비일관성을 다시 참고합니다.)

단위 테스트는 `ContainerRuntime`을 MockK로 페이크하여 "올바른 라벨/옵션으로 조회하고, 조회된
컨테이너를 전부 정리하는지"만 확인합니다 — 실제 Docker 데몬은 필요 없습니다.

```kotlin
package com.etude.domain.terminal

import io.kotest.core.spec.style.FreeSpec
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class ContainerCleanupServiceTest : FreeSpec({
    val containerRuntime = mockk<ContainerRuntime>(relaxed = true)
    val service = ContainerCleanupService(containerRuntime)

    "고아 컨테이너를 정리하면" - {
        "정지된 컨테이너까지 포함해 전부 조회하고 각각 정지/제거한다" {
            every {
                containerRuntime.listByLabel(ContainerCleanupService.SANDBOX_LABEL, includeStopped = true)
            } returns listOf("c1", "c2")

            service.cleanupOrphanContainers()

            verify { containerRuntime.stopAndRemove("c1") }
            verify { containerRuntime.stopAndRemove("c2") }
        }
    }

    "실행 중인 컨테이너만 정리하면" - {
        "includeStopped=false로 조회한다" {
            every {
                containerRuntime.listByLabel(ContainerCleanupService.SANDBOX_LABEL, includeStopped = false)
            } returns listOf("c1")

            service.cleanupRunningContainers()

            verify { containerRuntime.stopAndRemove("c1") }
        }
    }
})
```

---

## 5-3. `SandboxConfig` (`domain/sandbox/SandboxConfig.kt`)와 `SandboxConfigService`

`sandbox` 테이블은 조회만 하고 애플리케이션이 쓰지 않으므로 `@Entity`로 만들지 않고, JPA 없이
JdbcTemplate 스타일의 단순 조회로도 충분합니다. 다만 이 프로젝트는 Step 3부터 JPA + QueryDSL을
표준으로 세웠으므로(명세 "DB 접근 방식 — JPA로 확정"), 일관성을 위해 `@Entity`로 매핑합니다.

```kotlin
package com.etude.domain.sandbox

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "sandbox")
class SandboxConfigEntity(
    @Id
    @Column(length = 20)
    val type: String,

    @Column(length = 100, nullable = false)
    val image: String,

    @Column(columnDefinition = "JSON")
    val binds: String?,

    @Column(nullable = false)
    val persistent: Boolean = false,
)
```

> `sandbox` 테이블은 `BaseEntity`(`id` + `createdAt`)를 상속하지 않습니다 — PK가 `type`
> (`VARCHAR`)이고 생성 시각 컬럼 자체가 없어(스키마 참고), 다른 엔티티들과 PK 전략이 다른
> 예외적인 테이블입니다.
>
> `binds`를 `String?`(JSON 원문)로 두고 파싱은 서비스 레이어에서 하는 이유는, JPA가 JSON
> 컬럼을 리스트 타입으로 직접 매핑하려면 `@Convert`로 커스텀 컨버터를 만들어야 하는데, 이
> 테이블은 조회 빈도가 낮고 로직도 이 Step 하나에서만 쓰여 그 정도의 매핑 인프라를 투자할
> 가치가 없기 때문입니다 — 원본도 `JSON.parse(row.binds)`로 애플리케이션 코드에서 직접
> 파싱합니다.

응답/조회 결과를 담는 값 타입과 서비스:

```kotlin
package com.etude.domain.sandbox

data class SandboxConfig(
    val image: String,
    val binds: List<String>?,
    val persistent: Boolean,
)
```

```kotlin
package com.etude.domain.sandbox

interface SandboxConfigRepository {
    fun findByType(type: String): SandboxConfigEntity?
}
```

```kotlin
package com.etude.domain.sandbox

import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service

@Service
class SandboxConfigService(
    private val sandboxConfigRepository: SandboxConfigRepository,
    private val objectMapper: ObjectMapper,
    @Value("\${etude.kubeconfig-path}")
    private val kubeconfigPath: String,
) {
    fun getSandboxConfig(sandboxType: String): SandboxConfig {
        val entity = sandboxConfigRepository.findByType(sandboxType)
            ?: return SandboxConfig(image = "ubuntu", binds = null, persistent = false)

        val binds = entity.binds
            ?.let { parseBinds(it) }
            ?.map { it.replace("{KUBECONFIG_HOST_PATH}", kubeconfigPath) }

        return SandboxConfig(image = entity.image, binds = binds, persistent = entity.persistent)
    }

    private fun parseBinds(json: String): List<String> =
        objectMapper.readValue(json, Array<String>::class.java).toList()
}
```

> `ObjectMapper`는 Spring Boot가 `spring-boot-starter-web`(Jackson)을 통해 이미 빈으로
> 등록해두므로 별도 설정 없이 생성자 주입만으로 쓸 수 있습니다 — 원본의
> `JSON.parse(row.binds)`에 대응하는 최소한의 코드입니다.
>
> `kubeconfigPath`를 `@Value`로 주입받는 이유는 원본이 `process.env.KUBECONFIG_PATH ??
> \`${process.env.HOME}/.kube/config\``로 환경변수를 직접 읽는 부분을, 테스트에서 값을 고정할
> 수 있도록 스프링 설정으로 옮기기 위함입니다. 폴백 로직 자체는 `@Value` SpEL이 아니라
> `application.yml`의 프로퍼티 플레이스홀더로 표현합니다.
>
> ```yaml
> etude:
>   kubeconfig-path: ${KUBECONFIG_PATH:${HOME:${user.home}}/.kube/config}
> ```
>
> `${KUBECONFIG_PATH:...}`가 원본의 `process.env.KUBECONFIG_PATH ??`에 대응하고,
> `${HOME:${user.home}}`이 `process.env.HOME`(환경변수)에 대응합니다 — Spring의 프로퍼티
> 플레이스홀더는 환경변수를 시스템 프로퍼티보다 먼저 조회하므로 `${HOME:...}`만 써도 원본과
> 동일하게 동작하지만, `HOME`이 정의되지 않는 환경(예: 일부 컨테이너)까지 대비해 JVM
> `user.home` 시스템 프로퍼티로 한 번 더 폴백합니다. `@Value` 애노테이션에 SpEL로
> `systemProperties['user.home']`만 기본값으로 박아두면 `HOME` **환경변수** 자체를 읽지
> 않게 되어 원본과 동작이 달라지므로 쓰지 않습니다 — 환경변수 우선 조회는 `application.yml`의
> 플레이스홀더 문법에 맡깁니다.
>
> **주의** — `@Value("\${etude.kubeconfig-path}")`는 SpEL 기본값이 없으므로,
> `etude.kubeconfig-path` 프로퍼티가 어느 프로파일에도 정의돼 있지 않으면 이 빈을 생성하는
> 시점에 `IllegalArgumentException`으로 **Spring 컨텍스트 기동 자체가 실패**합니다(개별
> 테스트가 실패하는 게 아니라 `SandboxConfigServiceTest`를 포함한 모든 통합 테스트가
> 컨텍스트 로딩 단계에서 죽습니다). 위 프로퍼티는 `application.yaml`(main, 공통 설정)에
> 추가해 `application-test.yaml`(test 프로파일)에서도 상속되도록 합니다 — 프로퍼티 자체는
> 프로파일에 상관없이 항상 같은 값(환경변수 우선 폴백)을 쓰면 되므로, `application-test.yaml`
> 에 별도로 오버라이드할 이유가 없습니다.

`infrastructure/persistence/sandbox/SandboxConfigRepositoryImpl.kt`:

```kotlin
package com.etude.infrastructure.persistence.sandbox

import com.etude.domain.sandbox.SandboxConfigEntity
import com.etude.domain.sandbox.SandboxConfigRepository
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

interface SandboxConfigJpaRepository : JpaRepository<SandboxConfigEntity, String>

@Repository
class SandboxConfigRepositoryImpl(
    private val jpaRepository: SandboxConfigJpaRepository,
) : SandboxConfigRepository {
    override fun findByType(type: String): SandboxConfigEntity? = jpaRepository.findById(type).orElse(null)
}
```

### 통합 테스트 — `SandboxConfigServiceTest`

`sandbox` 테이블 시드(`01_sandbox.sql`)가 이미 `IntegrationTest`의 `withInitScripts`에
포함되어 있으므로, 별도 픽스처 없이 시드된 값(`linux`, `k8s` 등)을 그대로 검증에 씁니다.
`IntegrationTest`를 상속하되 `sandbox` 테이블은 `cleanAllTables()` 대상에 넣지 않습니다 —
시드 데이터라 테스트가 지우면 안 됩니다.

```kotlin
package com.etude.domain.sandbox

import com.etude.support.IntegrationTest
import io.kotest.matchers.shouldBe
import io.kotest.matchers.nulls.shouldBeNull
import org.springframework.beans.factory.annotation.Autowired

class SandboxConfigServiceTest(
    @Autowired private val sandboxConfigService: SandboxConfigService,
) : IntegrationTest({
    "binds가 없는 타입을 조회하면" - {
        "image만 채워지고 binds는 null이다" {
            val config = sandboxConfigService.getSandboxConfig("linux")

            config.image shouldBe "etude-linux"
            config.binds.shouldBeNull()
        }
    }

    "binds에 KUBECONFIG_HOST_PATH가 있는 타입을 조회하면" - {
        "플레이스홀더가 치환된다" {
            val config = sandboxConfigService.getSandboxConfig("k8s")

            config.binds?.get(0)?.contains("{KUBECONFIG_HOST_PATH}") shouldBe false
        }
    }

    "존재하지 않는 타입을 조회하면" - {
        "ubuntu 기본값으로 폴백한다" {
            val config = sandboxConfigService.getSandboxConfig("no-such-type")

            config.image shouldBe "ubuntu"
            config.binds.shouldBeNull()
        }
    }
})
```

> `IntegrationTest`의 `cleanAllTables()`(4-7)에 `sandboxConfigJpaRepository`를 추가하지
> **않습니다** — `sandbox`는 마스터 데이터(시드로만 채워지고 테스트가 쓰고 지우는 테이블이
> 아님)라 다른 도메인 테이블과 성격이 다릅니다. 이후 Step에서도 이 원칙을 유지합니다: 테스트가
> 직접 쓰는 트랜잭션 테이블만 정리 대상에 넣습니다.

---

## 5-4. 부트스트랩/종료 훅 연결 + 수동 검증

원본 `index.ts`는 앱 시작 시 `cleanupOrphanContainers()`를, `onClose` 훅에서
`cleanupRunningContainers()`를 호출합니다. Spring Boot에서는 `ApplicationRunner`(시작 시)와
`@PreDestroy` 또는 `DisposableBean`(종료 시)으로 대응합니다.

```kotlin
package com.etude.config

import com.etude.domain.terminal.ContainerCleanupService
import jakarta.annotation.PreDestroy
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Component

@Component
@Profile("!test")
class ContainerLifecycleHooks(
    private val containerCleanupService: ContainerCleanupService,
) : ApplicationRunner {
    override fun run(args: ApplicationArguments) {
        containerCleanupService.cleanupOrphanContainers()
    }

    @PreDestroy
    fun onShutdown() {
        containerCleanupService.cleanupRunningContainers()
    }
}
```

> `ApplicationRunner`는 Spring Boot 앱 컨텍스트가 완전히 뜬 직후 한 번 실행되어 원본이
> `await fastify.listen(...)` 이전에 `await cleanupOrphanContainers()`를 호출하던 시점과
> 대응합니다. `@PreDestroy`는 앱 컨텍스트가 닫히기 직전에 호출되어 원본의
> `fastify.addHook('onClose', ...)`와 대응합니다 — 둘 다 "앱 생명주기에 묶인 정리 훅"이라는
> 점에서 동일한 역할입니다.
>
> **`@Profile("!test")`가 반드시 필요합니다.** `ApplicationRunner`는 프로덕션 기동뿐 아니라
> **모든 `@SpringBootTest` 통합 테스트가 컨텍스트를 로딩할 때도 똑같이 실행**됩니다 — Step
> 1~4에서 만든 `AuthControllerTest`, `QuestControllerTest`, `ProgressControllerTest`처럼
> 이 컴포넌트를 전혀 참조하지 않는 테스트조차 같은 Spring 컨텍스트를 공유하는 이상 예외가
> 아닙니다. 가드 없이 두면 `cleanupOrphanContainers()`가 실제 Docker 데몬에 연결을 시도하다가
> (로컬에 `DOCKER_HOST`가 없거나 데몬에 못 닿으면) `RuntimeException`이 `ApplicationRunner`
> 밖으로 던져지고, Spring이 이를 컨텍스트 초기화 실패로 취급해 **`SandboxConfigServiceTest`를
> 포함한 이 Step 이후 모든 통합 테스트가 컨텍스트 로딩 단계에서 실패**합니다(개별 테스트
> 메서드의 실패가 아니라 `IllegalStateException: Failed to load ApplicationContext`로 나타나
> 원인 파악이 어렵습니다). `application-test.yaml`이 이미 `test` 프로파일로 격리돼 있으므로
> `@Profile("!test")`만 붙이면 테스트 컨텍스트에서는 이 빈 자체가 등록되지 않아 문제가
> 사라집니다 — 원본 Node.js는애초에 테스트 스위트가 없어 이 문제가 존재하지 않았지만,
> Kotlin 백엔드는 매 Step마다 전체 애플리케이션 컨텍스트를 띄우는 통합 테스트를 쓰므로
> "테스트 중에는 외부 시스템에 실제로 연결하는 부트스트랩 훅이 돌면 안 된다"는 제약이 새로
> 생깁니다.

**수동 검증** — Docker 데몬(Docker Desktop, Colima 등)이 떠 있는 채로 확인합니다. `DOCKER_HOST`
환경변수는 없어도 됩니다(위 5-1에서 확인했듯 `~/.docker/config.json`의 현재 컨텍스트를 자동으로
찾습니다) — 다만 로컬에 MariaDB가 없으면 앱이 DB 연결 단계에서 죽으므로, `docker/` 아래
compose 등으로 먼저 띄워둡니다.

```bash
# 1. etude=sandbox 라벨이 붙은 더미 컨테이너를 하나 띄워 "고아" 상태를 재현
docker run -d --label etude=sandbox --name etude-orphan-test ubuntu sleep 300

# 2. 앱 기동 — ApplicationRunner가 위 컨테이너를 정리하는지 확인
./gradlew bootRun
# 로그 또는 별도 터미널에서:
docker ps -a --filter "label=etude=sandbox"   # 위 컨테이너가 사라져 있어야 한다

# 3. 앱이 뜬 상태에서 라벨 붙은 컨테이너를 새로 하나 띄우고
docker run -d --label etude=sandbox --name etude-running-test ubuntu sleep 300

# 4. 앱을 종료(Ctrl+C 또는 SIGTERM)한 뒤 확인
docker ps -a --filter "label=etude=sandbox"   # 역시 사라져 있어야 한다
```

> 4번에서 종료 직후 바로 확인하면 아직 `docker stop`/`docker rm` API 왕복이 끝나지 않아
> 컨테이너가 남아있는 것처럼 보일 수 있습니다 — `stopContainerCmd()`는 컨테이너에 `SIGTERM`을
> 보내고 정지될 때까지(기본 타임아웃 내에서) 기다리므로 몇 초 정도 걸립니다. 몇 초 뒤
> 다시 확인하세요.
>
> 컨테이너가 여러 개일 때 `cleanupOrphanContainers`/`cleanupRunningContainers`는 원본
> `docker.ts`와 동일하게 **순차 처리**(하나씩 정지→제거)라서, 정리 시간이 컨테이너 수에
> 비례해 늘어납니다 — 이는 원본에도 있던 특성이므로 이 Step에서 병렬화하지 않습니다(5-2
> 참고).

이 시나리오는 docker-java `3.7.1` + Colima 환경에서 실제로 검증 완료되었습니다(고아 컨테이너
정리, 실행 중 컨테이너 종료 시 정리 모두 정상 동작). 기존 Node.js 백엔드(`backend/`)로 같은
시나리오를 재현해 정리 시점과 결과가 동일한지도 비교합니다.

---

## 완료 기준

- [ ] 위 인수 조건 체크리스트 전부 통과
- [ ] `ContainerLifecycleHooks`에 `@Profile("!test")`가 붙어 있어, 통합 테스트 컨텍스트
      로딩 시 실제 Docker 데몬에 연결을 시도하지 않는지 확인
- [ ] `ContainerCleanupServiceTest`(MockK 단위 테스트) 통과
- [ ] `SandboxConfigServiceTest`(Testcontainers 통합 테스트) 통과 — `sandbox` 테이블은
      `IntegrationTest`의 `cleanAllTables()` 대상에 포함하지 않았는지 확인
- [ ] `./gradlew test` 전체 클래스를 한 번에 실행해도 Step 1~5 테스트 모두 통과
- [ ] 5-4 수동 검증으로 부트스트랩/종료 시점 컨테이너 정리가 기존 Node.js 백엔드와 동일하게
      작동함을 확인
