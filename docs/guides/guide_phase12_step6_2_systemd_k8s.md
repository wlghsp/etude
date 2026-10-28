# Phase 12 Step 6-2 — 터미널 (linux-systemd, k8s)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step6_terminal.md](guide_phase12_step6_terminal.md) (6-1: default/docker)

대응하는 기존 Node.js 파일: `backend/src/services/terminal.ts`의 `waitForSystemd`,
`handleSystemdTerminal`, `handleK8sTerminal`, 그리고 `runSetupCmd`의 `$NS` 치환 부분.

**경로 표기 안내**는 Step 1과 동일합니다.

6-1에서 `TerminalSessionService.open`의 `when` 분기에 `TODO("향후 구현")`로 남겨 둔 두 줄을
채우는 작업입니다.

```kotlin
is SandboxType.LinuxSystemd -> TODO("향후 구현")   // ← 이 Step
is SandboxType.K8s -> TODO("향후 구현")            // ← 이 Step
is SandboxType.K8sIsolated -> TODO("향후 구현")    // ← 6-3 (Step 8 이후)
```

## 원본 구조 분석

6-1의 두 분기와 비교하면 이 둘은 **기존 패턴의 변형**입니다. 새 개념은 "컨테이너 생성 옵션이 더
붙는다"와 "세션 시작/종료에 외부 명령이 하나씩 끼어든다" 두 가지뿐입니다.

| | 컨테이너 생성 | 시작 후 | 터미널 연결 | 종료 시 |
|---|---|---|---|---|
| `default`(6-1) | bash, tty | setup | **attach** | stop+remove |
| `docker`(6-1) | privileged, command 없음 | `docker.sock` 대기 → setup | **exec** `/bin/sh` | stop+remove (persistent 제외) |
| **`linux-systemd`** | privileged + **cgroup 마운트 + cgroupns=host**, command 없음 | **systemd 부팅 대기** → setup | **exec** `/bin/bash` | stop+remove |
| **`k8s`** | **k3d 네트워크**, bash, tty | **namespace 생성** → setup(`$NS` 치환) | **attach** | **namespace 삭제** → stop+remove |

- `linux-systemd`는 `docker` 분기와 골격이 같습니다(exec 연결, 대기 명령 후 setup). 대기 명령과 생성 옵션만
  다릅니다.
- `k8s`는 `default` 분기와 골격이 같습니다(attach 연결). 네트워크 모드와, 종료 시 정리해야 할 외부 자원
  (k8s namespace)이 하나 늘어납니다.

### `$NS` 치환 — 이미 한 곳에 있는 규칙이 두 번째 사용처를 얻는다

`$NS`는 퀘스트가 k8s 네임스페이스 이름을 쓰는 자리 표시자이고, 값은 `quest-{컨테이너ID 앞 8자}`입니다.
Step 7의 `QuestService.grade`가 이미 `"quest-${containerId.take(8)}"`를 만들어 쓰고 있는데, 이 Step에서
`k8s` 분기가 **같은 값**을 namespace 생성/삭제/setup 치환에 씁니다. 세션 시작에서 만든 namespace 이름과
채점 때 치환하는 이름이 어긋나면 채점이 항상 실패하므로, 이 규칙은 한 곳에서만 정의해야 합니다
(CLAUDE.md의 단일 진실 공급원 원칙). 아래 6-2-0에서 먼저 추출합니다.

> 원본은 `k8s`/`k8s-isolated`에서만 setup의 `$NS`를 치환합니다(`runSetupCmd(container, questId,
> container.id)`처럼 `containerId`를 넘길 때만). 다른 분기는 치환하지 않으므로 이식도 동일하게
> `k8s` 분기에서만 치환합니다.

## 인수 조건 (이 Step의 완료 기준)

*Node.js 원본(`terminal.ts`의 `handleSystemdTerminal`/`handleK8sTerminal`)의 실제 동작이 곧 인수
조건이다. 이 두 분기는 Docker-in-Docker(systemd)와 k3d 클러스터(k8s)가 있어야 실제 동작하므로
자동 테스트는 **서비스 단위 테스트(MockK)** 로 분기 로직을 검증하고, 실물 동작은 **수동 검증**으로 확인한다
(명세의 테스트 전략: 외부 프로세스 의존이 강한 부분은 페이크 + 최소 스모크).*

**`linux-systemd` 분기**
- [ ] 컨테이너가 `Privileged`, `/sys/fs/cgroup:/sys/fs/cgroup:rw` 바인드(+ sandbox 테이블의 `binds`),
      `CgroupnsMode=host`로 생성된다. 메인 프로세스는 이미지 기본값(command 없음), tty/stdin 없음
- [ ] 시작 후 `systemctl is-system-running`이 `running` 또는 `degraded`가 될 때까지 대기한 뒤
      setup을 실행한다
- [ ] 터미널은 `/bin/bash` **exec**로 연결된다 (`docker` 분기의 `/bin/sh`와 다름)
- [ ] WebSocket이 닫히면 컨테이너가 정지/제거된다

**`k8s` 분기**
- [ ] 컨테이너가 `/bin/bash`, tty, stdin으로 생성되고 네트워크 모드는 `K3D_NETWORK`(기본
      `k3d-etude`)이다. `binds`는 sandbox 테이블 값(kubeconfig 마운트)이다
- [ ] 시작 후 `kubectl create namespace quest-{컨테이너ID 앞 8자}`를 컨테이너 안에서 실행한다
- [ ] setup 명령의 `$NS`가 `quest-{컨테이너ID 앞 8자}`로 치환되어 실행된다 (`default` 등 다른 분기는
      치환하지 않는다)
- [ ] 터미널은 `default`처럼 메인 프로세스 **attach**로 연결된다
- [ ] WebSocket이 닫히면 `kubectl delete namespace quest-... --ignore-not-found`를 먼저 실행하고, 그
      **실패와 무관하게** 컨테이너를 정지/제거한다 (원본 `try { ... } catch {}` 후 stop/remove)

**공통**
- [ ] 연결 성립 직후 `{"type":"connected","containerId":"..."}` 한 번 (6-1 `TerminalWebSocketHandler`가 이미
      처리 — 이 Step에서 손대지 않는다)

## 진행 방식

6-1과 같은 이유로 원본 로직이 명확해 **구현 후 단위 테스트로 검증**하는 순서입니다.

1. 6-2-0 `$NS` 규칙 추출 (기존 `QuestService.grade` 리팩터링, 동작 불변)
2. 6-2-1 `ContainerSpec`/어댑터 확장 (`cgroupnsMode`)
3. 6-2-2 설정 추가 (`etude.k3d-network`)
4. 6-2-3 `TerminalSessionService` 두 분기 구현
5. 6-2-4 단위 테스트
6. 6-2-5 수동 검증

---

## 6-2-0. `$NS` 규칙을 한 곳으로 — `questNamespace`

`domain/quest/QuestNamespace.kt` (신규):

```kotlin
package com.etude.domain.quest

/** 퀘스트 컨테이너 하나가 쓰는 k8s namespace 이름. 세션 시작(생성/치환)과 채점(치환)이 같은 값을 써야 한다. */
fun questNamespace(containerId: String): String = "quest-${containerId.take(8)}"
```

`QuestService.grade`의 치환부를 이 함수로 바꿉니다 (동작 불변):

```kotlin
// 변경 전
val ns = "quest-${containerId.take(8)}"
// 변경 후
val ns = questNamespace(containerId)
```

> 기존 `QuestServiceTest`의 `$NS` 치환 케이스(`quest-abcdef12`)가 이 리팩터링의 안전망입니다.
> 바꾼 뒤 `QuestServiceTest`가 그대로 통과해야 합니다.

---

## 6-2-1. `ContainerSpec` 확장 — `cgroupnsMode`

`linux-systemd`만 필요한 옵션입니다. `domain/terminal/ContainerRuntime.kt`의 `ContainerSpec`에 추가:

```kotlin
data class ContainerSpec(
    val image: String,
    val binds: List<String>,
    val command: List<String>,
    val tty: Boolean,
    val openStdin: Boolean,
    val privileged: Boolean = false,
    val networkMode: String? = null,
    val cgroupnsMode: String? = null,    // 추가 — "host" 등. systemd 컨테이너용
    val extraLabels: Map<String, String> = emptyMap(),
)
```

`infrastructure/docker/DockerContainerRuntime.kt`의 `createContainer`:

```kotlin
val hostConfig = HostConfig.newHostConfig()
    .withBinds(spec.binds.map { com.github.dockerjava.api.model.Bind.parse(it) })
    .withPrivileged(spec.privileged)
    .apply { spec.networkMode?.let { withNetworkMode(it) } }
    .apply { spec.cgroupnsMode?.let { withCgroupnsMode(it) } }   // 추가
```

> docker-java 3.7.1의 `HostConfig.withCgroupnsMode`는 enum이 아니라 **`String`** 을 받습니다
> (`"host"`/`"private"`). 그래서 `ContainerSpec`도 `String?`으로 둡니다. 도메인 계층이 docker-java
> 타입을 모르게 하려는 원칙과도 맞습니다.
>
> 이 필드에 기본값(`null`)이 있어서 기존 호출부(`default`/`docker`/테스트)는 수정할 필요가 없습니다.

---

## 6-2-2. 설정 — `etude.k3d-network`

원본은 `process.env.K3D_NETWORK ?? 'k3d-etude'`를 읽습니다. `application.yaml`의 `etude:` 아래에
추가합니다 (`kubeconfig-path`와 같은 방식):

```yaml
etude:
  kubeconfig-path: ${KUBECONFIG_PATH:${HOME:${user.home}}/.kube/config}
  k3d-network: ${K3D_NETWORK:k3d-etude}      # 추가
```

> **로컬 실행 시 주의 — kubeconfig 경로**: 기본값 `~/.kube/config`는 서버 주소가
> `https://127.0.0.1:6443`이라, **컨테이너 안에서는 자기 자신을 가리켜 클러스터에 닿지 않습니다.**
> 컨테이너가 k3d 네트워크에서 접속하려면 서버 주소가 `https://k3d-etude-server-0:6443`인 kubeconfig가
> 필요하고, 이 프로젝트에서는 `~/.kube/config-etude`가 그것입니다 (운영 서버의 `KUBECONFIG` 설정과 같은
> 파일, [kubeconfig.md](../glossary/kubeconfig.md) 참고). 로컬에서 k8s 분기를 쓸 때는 백엔드를 이렇게
> 띄웁니다.
>
> ```bash
> KUBECONFIG_PATH=$HOME/.kube/config-etude ./gradlew :apps:backend:bootRun
> ```
>
> IDE에서 실행한다면 실행 설정의 환경변수에 `KUBECONFIG_PATH`를 추가합니다.

---

## 6-2-3. `TerminalSessionService` — 두 분기 구현

### 생성자에 네트워크 이름 주입

```kotlin
@Service
class TerminalSessionService(
    private val sandboxConfigService: SandboxConfigService,
    private val containerRuntime: ContainerRuntime,
    private val questService: QuestService,
    @Value("\${etude.k3d-network}") private val k3dNetwork: String,   // 추가
)
```

> 생성자가 바뀌므로 `TerminalSessionServiceTest`의 `newService()`도 같이 고칩니다 (6-2-4).

### 디스패처의 `TODO` 두 줄 교체

```kotlin
is SandboxType.LinuxSystemd -> openLinuxSystemd(config, questId)
is SandboxType.K8s -> openK8s(config, questId)
is SandboxType.K8sIsolated -> TODO("향후 구현")   // 6-3
```

### `linux-systemd`

`docker` 분기와 골격이 같습니다. 대기 명령만 `systemctl`로 바뀌고, 쉘이 `/bin/bash`입니다.

```kotlin
private fun openLinuxSystemd(config: SandboxConfig, questId: Long?): TerminalSession {
    val containerId = containerRuntime.createContainer(
        ContainerSpec(
            image = config.image,
            binds = (config.binds ?: emptyList()) + "/sys/fs/cgroup:/sys/fs/cgroup:rw",
            command = emptyList(),
            tty = false,
            openStdin = false,
            privileged = true,
            cgroupnsMode = "host",
        )
    )
    containerRuntime.startContainer(containerId)
    waitForSystemd(containerId)

    runSetupCommand(containerId, questId)
    val stream = containerRuntime.execShell(containerId, listOf("/bin/bash"))

    return TerminalSession(containerId, stream) {
        containerRuntime.stopAndRemove(containerId)
    }
}

private fun waitForSystemd(containerId: String) {
    containerRuntime.execAndWait(
        containerId,
        listOf(
            "sh", "-c",
            "until systemctl is-system-running 2>/dev/null | grep -qE \"running|degraded\"; do sleep 0.3; done",
        ),
    )
}
```

> `waitForDockerDaemon`(6-1)과 완전히 같은 모양입니다. `execAndWait`가 "끝날 때까지 기다리고 결과는
> 버린다"는 6-1의 정의를 그대로 재사용합니다. 대기 명령 자체가 조건이 충족될 때만 끝나는 루프이기
> 때문에 exit code를 볼 필요가 없습니다.
>
> **Docker 데몬이 없는 환경**: `Privileged` + `CgroupnsMode=host` + `/sys/fs/cgroup` 마운트는 Linux
> 호스트의 cgroup 구조에 의존합니다. 이 머신은 colima(VM 위의 Docker)라서 VM의 cgroup 설정에 따라
> systemd가 안 뜰 수 있습니다. 그 경우 `waitForSystemd`가 끝나지 않고 연결이 멈추는 것처럼 보입니다.
> 원본이 운영 서버(OCI Linux)에서 동작하던 구성이므로, **로컬에서 안 되면 코드 문제가 아니라 환경
> 문제일 가능성**을 먼저 의심하세요.

### `k8s`

`default` 분기와 골격이 같습니다. namespace 생성/삭제와 `$NS` 치환이 추가됩니다.

```kotlin
private fun openK8s(config: SandboxConfig, questId: Long?): TerminalSession {
    val containerId = containerRuntime.createContainer(
        ContainerSpec(
            image = config.image,
            binds = config.binds ?: emptyList(),
            command = listOf("/bin/bash"),
            tty = true,
            openStdin = true,
            networkMode = k3dNetwork,
        )
    )
    val stream = containerRuntime.attachToMainProcess(containerId)
    containerRuntime.startContainer(containerId)

    val namespace = questNamespace(containerId)
    containerRuntime.execAndWait(containerId, listOf("kubectl", "create", "namespace", namespace))
    runSetupCommand(containerId, questId, namespace)

    return TerminalSession(containerId, stream) {
        runCatching {
            containerRuntime.execAndWait(
                containerId,
                listOf("kubectl", "delete", "namespace", namespace, "--ignore-not-found"),
            )
        }
        containerRuntime.stopAndRemove(containerId)
    }
}
```

> `attachToMainProcess`를 `startContainer`보다 먼저 호출하는 순서는 6-1 `default` 분기와 같습니다
> (시작 직후 나오는 첫 출력을 놓치지 않기 위해).
>
> 종료 때 `runCatching`으로 감싸는 이유는 원본의 `try { ... } catch {}`와 같습니다. 클러스터가 내려가
> 있거나 `kubectl`이 실패해도 **컨테이너 정리는 반드시 이어져야** 컨테이너가 남지 않습니다.
> `stopAndRemove` 자체가 이미 내부에서 실패를 삼키므로 그쪽은 감쌀 필요가 없습니다.
>
> 시작 시 `kubectl create namespace`는 실패해도 예외를 던지지 않습니다. 6-1의 `execAndWait`가 exit
> code를 버리기 때문인데, 원본도 결과를 보지 않으므로 동작은 같습니다. 다만 클러스터가 꺼져 있으면
> namespace가 없는 채로 세션이 열려 **퀘스트 채점이 항상 실패**합니다. 이런 증상이 보이면 가장 먼저
> `scripts/dev-up.sh`로 k3d가 떠 있는지 확인하세요.

### `runSetupCommand` — 선택적 `$NS` 치환

기존 `runSetupCommand`에 `namespace` 파라미터를 추가합니다. 값이 있을 때만 치환합니다.

```kotlin
private fun runSetupCommand(containerId: String, questId: Long?, namespace: String? = null) {
    val setupCmd = questId?.let { questService.getSetupCommand(it) } ?: return
    val resolved = if (namespace == null) setupCmd else setupCmd.map { it.replace("\$NS", namespace) }
    containerRuntime.execAndWait(containerId, resolved)
}
```

> `default`/`docker`/`linux-systemd` 호출부는 인자를 넘기지 않으므로 기존 동작(치환 없음) 그대로입니다.

---

## 6-2-4. 단위 테스트 — `TerminalSessionServiceTest` 확장

### `newService()` 수정

생성자에 네트워크 이름이 추가됐으므로 맞춥니다.

```kotlin
return Triple(
    sandboxConfigService, containerRuntime,
    TerminalSessionService(sandboxConfigService, containerRuntime, questService, "k3d-etude"),
)
```

### 추가할 케이스

`io.mockk.slot`, `io.mockk.verifyOrder`, `io.kotest.matchers.shouldBe`,
`io.kotest.matchers.collections.shouldContain` import를 추가합니다. `QuestService`를 케이스에서 직접 다뤄야
하는 `$NS` 케이스를 위해, 그 케이스에서는 `newService()` 대신 직접 구성합니다.

```kotlin
"linux-systemd 분기로 열면" - {
    "cgroup 옵션으로 컨테이너를 만들고 systemd를 기다린 뒤 bash exec로 연결한다" {
        val (sandboxConfigService, containerRuntime, service) = newService()
        every { sandboxConfigService.getSandboxConfig("linux-systemd") } returns
                SandboxConfig(image = "rockylinux", binds = null, persistent = false)
        val spec = slot<ContainerSpec>()
        every { containerRuntime.createContainer(capture(spec)) } returns "c5"

        service.open("linux-systemd", questId = null, existingContainerId = null)

        spec.captured.privileged shouldBe true
        spec.captured.cgroupnsMode shouldBe "host"
        spec.captured.binds shouldContain "/sys/fs/cgroup:/sys/fs/cgroup:rw"
        verifyOrder {
            containerRuntime.startContainer("c5")
            containerRuntime.execAndWait("c5", match { it.joinToString(" ").contains("systemctl is-system-running") })
            containerRuntime.execShell("c5", listOf("/bin/bash"))
        }
    }

    "닫으면" - {
        "컨테이너를 정지/제거한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("linux-systemd") } returns
                    SandboxConfig(image = "rockylinux", binds = null, persistent = false)
            every { containerRuntime.createContainer(any()) } returns "c6"

            service.open("linux-systemd", questId = null, existingContainerId = null).close()

            verify { containerRuntime.stopAndRemove("c6") }
        }
    }
}

"k8s 분기로 열면" - {
    "k3d 네트워크로 컨테이너를 만들고 namespace를 생성한다" {
        val (sandboxConfigService, containerRuntime, service) = newService()
        every { sandboxConfigService.getSandboxConfig("k8s") } returns
                SandboxConfig(image = "etude-k8s", binds = listOf("/kube:/root/.kube/config:ro"), persistent = false)
        val spec = slot<ContainerSpec>()
        every { containerRuntime.createContainer(capture(spec)) } returns "abcdef1234567890"

        service.open("k8s", questId = null, existingContainerId = null)

        spec.captured.networkMode shouldBe "k3d-etude"
        spec.captured.command shouldBe listOf("/bin/bash")
        spec.captured.tty shouldBe true
        verify { containerRuntime.attachToMainProcess("abcdef1234567890") }
        verify {
            containerRuntime.execAndWait("abcdef1234567890", listOf("kubectl", "create", "namespace", "quest-abcdef12"))
        }
    }

    "퀘스트의 setup_cmd에 \$NS가 있으면" - {
        "quest-{컨테이너ID 앞 8자}로 치환해서 실행한다" {
            val sandboxConfigService = mockk<SandboxConfigService> {
                every { getSandboxConfig("k8s") } returns
                        SandboxConfig(image = "etude-k8s", binds = null, persistent = false)
            }
            val containerRuntime = mockk<ContainerRuntime>(relaxed = true)
            every { containerRuntime.createContainer(any()) } returns "abcdef1234567890"
            val questService = mockk<QuestService> {
                every { getSetupCommand(7L) } returns listOf("kubectl", "-n", "\$NS", "apply", "-f", "x.yaml")
            }
            val service = TerminalSessionService(sandboxConfigService, containerRuntime, questService, "k3d-etude")

            service.open("k8s", questId = 7L, existingContainerId = null)

            verify {
                containerRuntime.execAndWait(
                    "abcdef1234567890",
                    listOf("kubectl", "-n", "quest-abcdef12", "apply", "-f", "x.yaml"),
                )
            }
        }
    }

    "닫으면" - {
        "namespace를 삭제한 뒤 컨테이너를 정지/제거한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("k8s") } returns
                    SandboxConfig(image = "etude-k8s", binds = null, persistent = false)
            every { containerRuntime.createContainer(any()) } returns "abcdef1234567890"

            service.open("k8s", questId = null, existingContainerId = null).close()

            verifyOrder {
                containerRuntime.execAndWait(
                    "abcdef1234567890",
                    listOf("kubectl", "delete", "namespace", "quest-abcdef12", "--ignore-not-found"),
                )
                containerRuntime.stopAndRemove("abcdef1234567890")
            }
        }

        "namespace 삭제가 실패해도 컨테이너는 정지/제거한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("k8s") } returns
                    SandboxConfig(image = "etude-k8s", binds = null, persistent = false)
            every { containerRuntime.createContainer(any()) } returns "abcdef1234567890"
            every {
                containerRuntime.execAndWait(any(), match { it.contains("delete") })
            } throws RuntimeException("cluster down")

            service.open("k8s", questId = null, existingContainerId = null).close()

            verify { containerRuntime.stopAndRemove("abcdef1234567890") }
        }
    }
}
```

> 마지막 케이스(삭제 실패에도 정리가 이어짐)가 `runCatching`의 존재 이유를 검증합니다. 이 케이스를 먼저
> 쓰고 `runCatching` 없이 구현해 실패하는 것을 확인한 뒤 감싸는 순서로 하면, 이 분기에서 유일하게 TDD로
> 의미가 있는 부분입니다.
>
> `containerRuntime`이 relaxed mock이라 `execAndWait` 같은 호출이 아무 일도 하지 않으므로, `verifyOrder`로
> 호출 **순서**를 검증합니다. systemd 분기의 "대기 → setup → exec 연결" 순서와 k8s 분기의 "삭제 → 정리" 순서는
> 틀리면 실제로 동작이 깨지는 부분입니다.

---

## 6-2-5. 수동 검증

자동 테스트로는 분기 로직까지만 보장하고, 실제 systemd/k3d 동작은 직접 확인합니다.

### k8s

1. `scripts/dev-up.sh` (k3d 포함)
2. 백엔드 기동: `KUBECONFIG_PATH=$HOME/.kube/config-etude ./gradlew :apps:backend:bootRun`
3. 프론트에서 k8s 계열 퀘스트셋을 열고 터미널이 연결되는지 확인
4. 터미널에서 `kubectl get ns` → `quest-xxxxxxxx` namespace가 보이는지
5. 호스트 터미널에서 `kubectl --context k3d-etude get ns`로도 같은 namespace가 보이는지
6. 브라우저 탭을 닫거나 퀘스트를 나간 뒤 같은 명령으로 **namespace가 사라졌는지**
7. 정답 입력 후 채점 → `passed: true` (namespace 이름이 세션 시작과 채점에서 일치한다는 증거)

### linux-systemd

1. `linux-systemd` 퀘스트셋을 열고 연결까지 걸리는 시간 확인 (systemd 부팅 대기 때문에 몇 초 걸림)
2. 터미널에서 `systemctl status` 가 동작하는지 (`System has not been booted with systemd` 가 나오면 실패)
3. 탭을 닫은 뒤 `docker ps`에 컨테이너가 남지 않았는지

### 실패 시 확인 순서

| 증상 | 원인 후보 |
|---|---|
| k8s 터미널은 열리는데 `kubectl`이 `connection refused` | 마운트된 kubeconfig의 서버 주소가 `127.0.0.1` — `KUBECONFIG_PATH`를 `config-etude`로 (6-2-2) |
| namespace가 안 생기고 채점이 계속 실패 | k3d가 꺼져 있음 → `scripts/dev-up.sh` |
| 탭을 닫았는데 namespace가 남음 | 종료 시 삭제 실패. 클러스터 상태 확인. 남은 것은 Step 8/9의 고아 namespace 정리 대상 |
| systemd 연결이 멈춤 | colima VM의 cgroup 환경 문제 가능성 (6-2-3 안내 참고) |

---

## 이 Step에서 다루지 않는 것

- **`k8s-isolated`(6-3)**: vcluster 풀(`assignFromPool`/`releaseVcluster`)이 필요해 Step 8 이후.
- **고아 namespace 정리**: 서버가 비정상 종료돼 `delete namespace`가 못 돈 경우의 청소는 원본의
  `plugins/k8s-namespace.ts`에 해당하며 Step 8/9에서 다룬다. 고아 **컨테이너** 정리는 5에서 만든
  `ContainerCleanupService`가 `etude=sandbox` 라벨로 이미 처리한다.

## 완료 기준

- [ ] 위 인수 조건 체크리스트 전부 통과
- [ ] `QuestServiceTest`가 6-2-0 리팩터링 후에도 그대로 통과 (`$NS` 치환 동작 불변)
- [ ] `TerminalSessionServiceTest`의 systemd/k8s 케이스 통과
- [ ] `./gradlew test` 전체 통과
- [ ] 수동 검증: k8s 퀘스트셋에서 namespace 생성/삭제와 채점 성공 확인
- [ ] 수동 검증: linux-systemd 퀘스트셋에서 `systemctl` 동작 확인 (환경 문제로 안 되면 사유를 기록)
