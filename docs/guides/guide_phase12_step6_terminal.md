# Phase 12 Step 6-1 — 터미널 (WebSocket 인프라 + default/docker/docker-persistent)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step5_docker.md](guide_phase12_step5_docker.md)

대응하는 기존 Node.js 파일: `backend/src/services/terminal.ts`(298줄 중 공통 유틸 +
`handleDefaultTerminal`/`handleDockerTerminal` 분기), `backend/src/routes/terminal.routes.ts`.

**경로 표기 안내**는 Step 1과 동일합니다.

## 이 Step의 분할 이유

명세가 예고한 대로 Step 6은 sandbox 5종(default·docker·docker-persistent·linux-systemd·k8s·
k8s-isolated) 분기가 커서 3단계로 나눕니다:

- **6-1(이 문서)**: WebSocket 인프라(`TerminalWebSocketHandler`, attach/exec 스트림 브리징,
  resize 프로토콜) + 가장 단순한 두 분기(`default`, `docker`/`docker-persistent`)
- **6-2(다음 문서)**: `linux-systemd`(cgroup/systemd 대기), `k8s`(네임스페이스 생성/삭제)
- **6-3(Step 8 이후)**: `k8s-isolated` — `vcluster-pool.ts`(`assignFromPool`/`releaseVcluster`)에
  의존하므로 Step 8(vcluster)에서 `VclusterProvisioner` 포트가 먼저 만들어진 뒤에야 이 분기를
  이식할 수 있습니다. 6-1/6-2에서는 이 분기를 다루지 않습니다.

## 원본 구조 분석

`terminal.ts`의 `handleTerminal`은 `sandboxType`으로 5개 핸들러 함수 중 하나로 분기하는
디스패처입니다. 6-1에서 다룰 두 핸들러(`handleDefaultTerminal`, `handleDockerTerminal`)를
비교하면 공통 골격이 보입니다:

1. 컨테이너 생성(또는 기존 컨테이너 재사용 — `docker-persistent`만) → 시작
2. stdin/stdout을 WebSocket에 연결할 스트림 확보 — **여기서 `default`와 `docker`가 갈립니다**
   (아래 "핵심 차이" 참고)
3. `runSetupCmd` — 퀘스트에 `setup_cmd`가 있으면 실행
4. `{"type":"connected","containerId":...}` 전송
5. WebSocket ↔ 스트림 양방향 브리징 (`attachResizeHandler`)
6. WebSocket `close` 시 정리(`docker-persistent`만 컨테이너를 지우지 않고 살려둠)

### 핵심 차이 — `container.attach()` vs `container.exec()`

- **`handleDefaultTerminal`**: 컨테이너 자체를 `Tty: true, Cmd: ['/bin/bash']`로 만들고
  `container.attach()`로 그 메인 프로세스(bash)의 stdin/stdout에 직접 연결합니다. 컨테이너의
  PID 1이 곧 사용자의 셸입니다.
- **`handleDockerTerminal`**: 컨테이너는 `OpenStdin: false, Tty: false`로 조용히 띄우고(메인
  프로세스는 이미지의 기본 커맨드), 그 안에서 별도로 `container.exec(['/bin/sh'])`를 실행해
  그 exec 프로세스의 stdin/stdout에 연결합니다. 컨테이너가 Docker 데몬을 품은
  `docker:dind` 이미지라 메인 프로세스가 `dockerd`이고, 사용자 셸은 그 위에서 실행되는
  별도 프로세스이기 때문입니다. `docker-persistent`는 여기에 더해 `existingContainerId`가
  있으면 새로 만들지 않고 재사용합니다(같은 컨테이너에 여러 번 exec).

docker-java에서는 이 둘이 `ContainerRuntime` 포트 위에 각각 "attach" 계열, "exec" 계열
메서드로 대응됩니다 — 이 Step에서 포트를 확장합니다(Step 5는 정리용 메서드만 가지고
있었습니다).

## 인수 조건 (이 Step의 완료 기준)

*Node.js 원본(`terminal.ts`의 `handleDefaultTerminal`/`handleDockerTerminal`,
`terminal.routes.ts`)의 실제 동작이 곧 인수 조건이다. WebSocket이라 MockMvc로 직접 검증할 수
없으므로, 이 Step은 Spring `WebSocketClient`를 사용한 통합 테스트로 검증한다(아래 6-6 참고).*

**연결 (`GET /ws/terminal?sandboxType=...&questId=...&containerId=...`)**
- [ ] `sandboxType` 쿼리 파라미터 없이 연결하면 기본값 `linux`로 처리된다 (원본
      `params.get('sandboxType') ?? 'linux'`와 동일 — `linux` 타입은 아래 `default` 분기로
      간다)
- [ ] `sandboxType=docker` 또는 `docker-persistent`로 연결하면 `docker`/`docker-persistent`
      분기로 간다
- [ ] 연결 직후 서버가 `{"type":"connected","containerId":"..."}` 텍스트 프레임을 정확히 한 번
      먼저 보낸다 (원본 `socket.send(JSON.stringify({ type: 'connected', containerId }))`)
- [ ] 이 엔드포인트는 **인증을 요구하지 않는다** — 프론트엔드(`Terminal.tsx`)가 애초에 토큰을
      전달하지 않으므로, JWT 필터/인터셉터 경로 목록에 `/ws/terminal`을 추가하지 않는다(기존
      REST 엔드포인트와 다른 유일한 예외)

**`default` 분기 (`sandboxType`이 `docker`/`docker-persistent`/`linux-systemd`/`k8s`/
`k8s-isolated`가 아닌 모든 값 — 즉 `linux`, `linux-ssh` 등)**
- [ ] 컨테이너가 `sandbox` 테이블 설정(`SandboxConfigService`)의 `image`/`binds`로 생성되고
      `etude=sandbox` 라벨이 붙는다
- [ ] 컨테이너의 메인 프로세스(`/bin/bash`, Tty)에 직접 attach되어, 클라이언트가 보낸 바이트가
      그대로 셸 입력으로 들어가고 셸 출력이 그대로 클라이언트로 돌아온다
- [ ] 퀘스트에 `setup_cmd`가 있으면(questId로 조회) 연결 성립 전에 그 명령이 컨테이너 안에서
      실행된다
- [ ] WebSocket이 닫히면 컨테이너가 정지되고 제거된다 (원본
      `container.stop().then(() => container.remove()).catch(() => {})`)

**`docker`/`docker-persistent` 분기**
- [ ] `docker`: 매번 새 컨테이너를 `Privileged: true`로 생성하고, `/var/run/docker.sock`이
      생길 때까지 폴링한 뒤(`waitForDocker` — Docker-in-Docker 데몬이 뜨는 시간) `/bin/sh`
      exec에 연결한다
- [ ] `docker-persistent`: `containerId` 쿼리 파라미터가 있으면 새로 만들지 않고 그 컨테이너에
      exec만 새로 붙인다(재연결). 없으면 `docker`와 동일하게 새로 만든다
- [ ] `docker`는 WebSocket이 닫히면 컨테이너를 정지/제거하지만, `docker-persistent`는
      **정지/제거하지 않는다** (원본 `if (!config.persistent) { ... }`)
- [ ] 퀘스트에 `setup_cmd`가 있으면 exec 연결 전에 실행된다

이 조건들은 아래 6-6(통합 테스트)로 옮겨집니다.

## 진행 방식

WebSocket 핸들러와 attach/exec 스트림 브리징은 원본에도 명확한 로직이 이미 있고 설계를 탐색할
필요가 없으므로 "구현 먼저 작성 → 검증" 순서로 갑니다. 다만 raw duplex stream을
WebSocket과 연결하는 부분(원본이 명세에서 "가장 신경 써야 할 지점"으로 꼽은 부분)은 Node.js의
스트림 이벤트 모델과 Java의 블로킹 I/O 모델이 근본적으로 다르므로, 그 변환 지점만 자세히
설명합니다.

레이어는 `domain/terminal`(포트 확장) → `infrastructure/docker`(어댑터 구현) →
`domain/terminal`(TerminalSessionService — sandboxType별 분기) →
`interfaces/ws`(WebSocketHandler) → 통합 테스트 순으로 나갑니다.

---

## 6-0. `ContainerRuntime` 포트 확장 — attach/exec 메서드 추가

Step 5의 `ContainerRuntime`은 정리(`listByLabel`, `stopAndRemove`)만 알았습니다. 이 Step은
컨테이너 생성과 두 가지 스트림 연결 방식(attach/exec)을 추가로 필요로 합니다.

```kotlin
package com.etude.domain.terminal

interface ContainerRuntime {
    fun listByLabel(label: String, includeStopped: Boolean): List<String>
    fun stopAndRemove(containerId: String)

    fun createContainer(spec: ContainerSpec): String
    fun startContainer(containerId: String)
    fun attachToMainProcess(containerId: String): TerminalStream
    fun execShell(containerId: String, command: List<String>): TerminalStream
    fun execAndWait(containerId: String, command: List<String>)
}

data class ContainerSpec(
    val image: String,
    val binds: List<String>,
    val command: List<String>,
    val tty: Boolean,
    val openStdin: Boolean,
    val privileged: Boolean = false,
    val networkMode: String? = null,
    val extraLabels: Map<String, String> = emptyMap(),
)

interface TerminalStream {
    fun onOutput(listener: (ByteArray) -> Unit)
    fun write(data: ByteArray)
    fun resize(cols: Int, rows: Int)
    fun close()
}
```

> `ContainerSpec`이 원본의 `docker.createContainer({...})` 호출 인자를 값 타입으로 뽑아낸
> 이유는, 5종 분기마다 이 옵션 조합이 조금씩 다르고(6-2에서 `linux-systemd`가
> `CgroupnsMode`를, `k8s`가 `NetworkMode`를 추가로 씁니다) 그 차이를 어댑터 구현
> (`DockerContainerRuntime`)이 아니라 도메인 서비스(6-2에서 만들 `TerminalSessionService`)가
> 결정하게 하기 위함입니다 — 포트가 "무엇을 만들지"를 값으로 받고 "어떻게 docker-java API를
> 호출할지"는 어댑터 책임으로 남깁니다.
>
> `attachToMainProcess`(→ `default` 분기의 `container.attach()`)와 `execShell`(→
> `docker`/`linux-systemd`/`k8s` 분기의 `container.exec()`)을 별도 메서드로 나눈 이유는
> "핵심 차이" 절에서 설명한 것처럼 두 방식이 docker-java에서도 서로 다른 API
> (`AttachContainerCmd` vs `ExecCreateCmd`+`ExecStartCmd`)이기 때문입니다 — 하나로
> 합치면 어댑터 내부에서 다시 분기해야 해서 포트가 감추려는 차이를 오히려 드러냅니다.
>
> `execAndWait`(→ `runSetupCmd`, `waitForDocker`처럼 "출력은 필요 없고 끝날 때까지 기다리기만
> 하면 되는" 짧은 명령)을 `execShell`과 분리한 이유는 원본에서 이 두 쓰임새가 이미 다른
> 옵션(`AttachStdout: false`)으로 구분되고, `TerminalStream`(양방향 대화형 스트림)을 돌려줄
> 필요가 없는 호출에 그 인터페이스를 억지로 맞추면 "스트림을 읽지 않고 버려도 되는지" 같은
> 불필요한 질문이 생기기 때문입니다.
>
> `TerminalStream`이 콜백(`onOutput`) + 명령형 메서드(`write`/`resize`/`close`) 조합인 이유는
> 아래 6-2에서 자세히 다룹니다 — Node.js의 `stream.on('data', ...)` 이벤트 모델을 Java
> 블로킹 I/O 위에서 흉내 내는 지점입니다.

---

## 6-1. 핵심 — Node.js 스트림을 Java 블로킹 I/O로 옮기기

원본의 `attachResizeHandler`는 Node.js의 duplex stream(`NodeJS.ReadWriteStream`)을 받아
`stream.on('data', chunk => socket.send(chunk))`로 "데이터가 도착하면 WebSocket으로 보낸다"는
**이벤트 기반** 브리징을 합니다. dockerode의 `container.attach()`/`exec.start({ hijack: true })`
가 돌려주는 스트림은 논블로킹 이벤트 스트림입니다.

docker-java(동기 블로킹 I/O 기반)는 다른 모양을 돌려줍니다 — `attachContainerCmd`/
`execStartCmd`의 `exec(ResultCallback)` API가 **콜백 기반**입니다(`ResultCallback.onNext(Frame)`
이 프레임 도착마다 호출됨). 이 자체는 원본의 이벤트 모델과 유사하지만, "클라이언트가 입력을
보내면 그 바이트를 컨테이너로 써야 한다"는 반대 방향(쓰기)은 별도 `OutputStream`을 통해
동기적으로 이루어집니다. 즉 **읽기는 콜백, 쓰기는 블로킹 스트림**이라는 비대칭이 Node.js
duplex stream과의 근본적인 차이입니다.

아래에서 만드는 `AttachTerminalStream`/`ExecTerminalStream`은 `infrastructure/docker`
패키지에 두는 **어댑터 계층의 헬퍼 클래스**입니다 — `domain/terminal`의 `TerminalStream`
포트를 구현하되, 그 자체는 도메인이 아니라 6-2에서 만들 `DockerContainerRuntime`과 같은
계층에 있습니다. 이 비대칭을 감춰 상위(WebSocketHandler, 그리고 `DockerContainerRuntime`을
호출하는 도메인 서비스)에는 Node.js와 비슷한 콜백+쓰기 인터페이스만 보이게 하는 것이
이 두 클래스의 역할입니다.

```kotlin
package com.etude.infrastructure.docker

import com.etude.domain.terminal.TerminalStream
import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.api.async.ResultCallback
import com.github.dockerjava.api.model.Frame
import java.io.PipedInputStream
import java.io.PipedOutputStream

class AttachTerminalStream(
    private val dockerClient: DockerClient,
    private val containerId: String,
) : TerminalStream {
    private val stdinPipeOut = PipedOutputStream()
    private val stdinPipeIn = PipedInputStream(stdinPipeOut)
    private var outputListener: ((ByteArray) -> Unit)? = null

    init {
        dockerClient.attachContainerCmd(containerId)
            .withStdIn(stdinPipeIn)
            .withStdOut(true)
            .withStdErr(true)
            .withFollowStream(true)
            .exec(object : ResultCallback.Adapter<Frame>() {
                override fun onNext(frame: Frame) {
                    outputListener?.invoke(frame.payload)
                }
            })
    }   

    override fun onOutput(listener: (ByteArray) -> Unit) {
        outputListener = listener
    }

    override fun write(data: ByteArray) {
        stdinPipeOut.write(data)
        stdinPipeOut.flush()
    }

    override fun resize(cols: Int, rows: Int) {
        dockerClient.resizeContainerCmd(containerId).withSize(rows, cols).exec()
    }

    override fun close() {
        stdinPipeOut.close()
    }
}
```

> `PipedOutputStream`/`PipedInputStream` 쌍을 쓰는 이유 — docker-java의
> `attachContainerCmd().withStdIn(inputStream)`은 **`InputStream`을 요구**합니다(우리가
> 밀어 넣는 게 아니라 라이브러리가 당겨 읽는 pull 모델). 하지만 우리는 WebSocket
> `onMessage` 콜백이 호출될 때마다(즉 push 모델로) 컨테이너에 바이트를 써야 합니다. 이
> push↔pull 불일치를 메모리 파이프로 연결합니다: `write()`가 `stdinPipeOut`에 쓰면, 그
> 반대편 `stdinPipeIn`(docker-java가 내부적으로 읽고 있는 스트림)에 그대로 나타납니다.
> 이것이 이 Step에서 "가장 신경 써야 할 지점"의 정체입니다 — Node.js는 스트림이 애초에
> 양방향 이벤트 객체라 이런 변환이 필요 없지만, JDK 표준 스트림은 단방향(`InputStream`
> 아니면 `OutputStream`)이라 두 개를 파이프로 이어 붙여야 duplex처럼 동작합니다.
>
> `onOutput`이 리스너를 **나중에** 등록해도 되는 이유는(생성자에서 바로 `exec()`를 호출해
> 콜백이 이미 등록됐는데) `outputListener`가 `var`이고 `onNext`가 매번 최신 값을 참조하기
> 때문입니다 — WebSocketHandler가 세션을 연 뒤에 `onOutput`을 호출해도 그 이전에 도착한
> 프레임만 유실되고(연결 성립 직후라 사실상 없음) 이후 프레임은 정상 전달됩니다.

`ExecTerminalStream`(exec 계열, `docker`/`linux-systemd`/`k8s` 분기용)도 거의 동일한 구조인데
`attachContainerCmd` 대신 `execStartCmd`를 씁니다:

```kotlin
class ExecTerminalStream(
    private val dockerClient: DockerClient,
    containerId: String,
    command: List<String>,
) : TerminalStream {
    private val execId: String
    private val stdinPipeOut = PipedOutputStream()
    private val stdinPipeIn = PipedInputStream(stdinPipeOut)
    private var outputListener: ((ByteArray) -> Unit)? = null

    init {
        execId = dockerClient.execCreateCmd(containerId)
            .withCmd(*command.toTypedArray())
            .withAttachStdin(true).withAttachStdout(true).withAttachStderr(true)
            .withTty(true)
            .exec()
            .id

        dockerClient.execStartCmd(execId)
            .withStdIn(stdinPipeIn)
            .withTty(true)
            .exec(object : com.github.dockerjava.api.async.ResultCallback.Adapter<com.github.dockerjava.api.model.Frame>() {
                override fun onNext(frame: com.github.dockerjava.api.model.Frame) {
                    outputListener?.invoke(frame.payload)
                }
            })
    }

    override fun onOutput(listener: (ByteArray) -> Unit) { outputListener = listener }
    override fun write(data: ByteArray) { stdinPipeOut.write(data); stdinPipeOut.flush() }
    override fun resize(cols: Int, rows: Int) {
        dockerClient.resizeExecCmd(execId).withSize(rows, cols).exec()
    }
    override fun close() { stdinPipeOut.close() }
}
```

> exec 계열은 `resize`가 `resizeContainerCmd`가 아니라 `resizeExecCmd`(exec 프로세스
> 전용 TTY 크기 조정)를 씁니다 — 원본의 `exec.resize({ h, w })`(`Docker.Exec`의 메서드)에
> 대응하며, `attach` 계열의 `container.resize()`와 API 자체가 다릅니다.

---

## 6-2. 어댑터 구현 — `DockerContainerRuntime` 확장

Step 5의 `DockerContainerRuntime`(`infrastructure/docker/`)에 메서드를 추가합니다. 위 6-1에서
만든 `AttachTerminalStream`/`ExecTerminalStream`은 같은 `infrastructure/docker` 패키지에
있으므로 별도 import 없이 바로 참조할 수 있습니다.

```kotlin
package com.etude.infrastructure.docker

import com.etude.domain.terminal.ContainerRuntime
import com.etude.domain.terminal.ContainerSpec
import com.etude.domain.terminal.TerminalStream
import com.github.dockerjava.api.DockerClient
import com.github.dockerjava.api.model.HostConfig
import org.springframework.stereotype.Component

@Component
class DockerContainerRuntime(
    private val dockerClient: DockerClient,
) : ContainerRuntime {
    // ... listByLabel, stopAndRemove는 Step 5와 동일 ...

    override fun createContainer(spec: ContainerSpec): String {
        val hostConfig = HostConfig.newHostConfig()
            .withBinds(spec.binds.map { com.github.dockerjava.api.model.Bind.parse(it) })
            .withPrivileged(spec.privileged)
            .apply { spec.networkMode?.let { withNetworkMode(it) } }

        return dockerClient.createContainerCmd(spec.image)
            .withLabels(mapOf("etude" to "sandbox") + spec.extraLabels)
            .withCmd(spec.command)
            .withTty(spec.tty)
            .withAttachStdin(spec.openStdin)
            .withAttachStdout(spec.openStdin)
            .withAttachStderr(spec.openStdin)
            .withStdinOpen(spec.openStdin)
            .withHostConfig(hostConfig)
            .exec()
            .id
    }

    override fun startContainer(containerId: String) {
        dockerClient.startContainerCmd(containerId).exec()
    }

    override fun attachToMainProcess(containerId: String): TerminalStream =
        AttachTerminalStream(dockerClient, containerId)

    override fun execShell(containerId: String, command: List<String>): TerminalStream =
        ExecTerminalStream(dockerClient, containerId, command)

    override fun execAndWait(containerId: String, command: List<String>) {
        val execId = dockerClient.execCreateCmd(containerId)
            .withCmd(*command.toTypedArray())
            .withAttachStdout(true)
            .withAttachStderr(true)
            .exec()
            .id
        dockerClient.execStartCmd(execId).exec(
            com.github.dockerjava.api.async.ResultCallback.Adapter()
        ).awaitCompletion()
    }
}
```

> `execAndWait`이 `awaitCompletion()`으로 끝날 때까지 블로킹하는 이유는 원본의
> `runSetupCmd`가 `new Promise((resolve) => stream.on('end', resolve))`로 exec 프로세스
> 종료를 명시적으로 기다린 뒤에야 다음 단계(WebSocket에 `connected` 전송)로 넘어가기
> 때문입니다 — 셋업 명령이 끝나기 전에 사용자가 터미널을 쓰기 시작하면 안 됩니다.
>
> `withAttachStdin(spec.openStdin)`처럼 `AttachStdin`/`AttachStdout`/`AttachStderr`를 전부
> `openStdin` 하나로 묶은 이유는, 원본에서 이 세 값이 항상 함께 움직이기 때문입니다
> (`default`/`k8s` 분기는 셋 다 `true`, `docker`/`linux-systemd` 분기는 셋 다 `false`) —
> 실제로 어긋나는 조합이 원본에 없으므로 `ContainerSpec`에 필드를 3개 대신 1개만 둡니다.

---

## 6-3. `TerminalSessionService` — sandboxType 분기 (default/docker만)

원본 `handleTerminal`은 `if/else` 체인으로 5개 핸들러 함수 중 하나를 고르는 디스패처입니다.
이를 문자열 `when`으로 그대로 옮기는 대신, sandbox 종류를 **sealed interface**로 표현합니다
— 이유는 두 가지입니다.

1. sandbox 종류는 이 프로젝트에서 6개로 이미 상한이 정해져 있고(명세 표에 6-1/6-2/6-3로
   전부 나열됨), 런타임에 동적으로 늘어나는 목록이 아닙니다. "타입이 언제 얼마나 늘어날지
   모르는" 상황에 맞는 개방-폐쇄 설계(전략 인터페이스 + Map 등록)보다, "정해진 케이스를
   하나도 빠뜨리면 안 되는" 상황에 맞는 **컴파일 타임 exhaustiveness 체크**(`when`이 sealed
   타입의 모든 케이스를 다루지 않으면 컴파일 에러)가 이 Step의 실수 방지에 더 유용합니다 —
   6-2/6-3에서 새 케이스를 sealed에 추가하는 순간, 아직 처리하지 않은 `when` 분기가 있으면
   그 자리에서 컴파일이 깨져 "이 Step에서 놓친 케이스가 있다"는 걸 즉시 알 수 있습니다.
2. `docker-persistent`는 `docker`와 로직이 완전히 같고 "지속 여부"라는 값 하나만
   다릅니다(원본 `handleDockerTerminal`이 이미 하나의 함수로 처리). `enum`은 이 관계를
   표현할 수 없어(각 상수가 고정값만 가짐) 방금 전 시도처럼 "같은 구현체를 두 키에 매핑"하는
   특수 처리가 필요했지만, sealed interface는 `Docker(val persistent: Boolean)`라는 data
   class로 이 관계 자체를 타입에 담을 수 있습니다 — `DOCKER_PERSISTENT`라는 별도 상수가
   아예 사라집니다.

### `SandboxType` — `domain/sandbox/SandboxType.kt`

```kotlin
package com.etude.domain.sandbox

sealed interface SandboxType {
    data object Default : SandboxType
    data class Docker(val persistent: Boolean) : SandboxType
    data object LinuxSystemd : SandboxType
    data object K8s : SandboxType
    data object K8sIsolated : SandboxType

    companion object {
        fun from(sandboxType: String, config: SandboxConfig): SandboxType = when (sandboxType) {
            "docker", "docker-persistent" -> Docker(persistent = config.persistent)
            "linux-systemd" -> LinuxSystemd
            "k8s" -> K8s
            "k8s-isolated" -> K8sIsolated
            else -> Default
        }
    }
}
```

> `Docker(val persistent: Boolean)`가 `docker`/`docker-persistent` 두 문자열을 하나의
> 타입으로 흡수하는 지점입니다 — `persistent` 값은 `sandboxType` 문자열이 아니라
> `SandboxConfig.persistent`(Step 5, `sandbox` 테이블의 `persistent` 컬럼)에서 가져옵니다.
> 원본 `handleDockerTerminal`도 정지 여부를 `sandboxType` 문자열이 아니라
> `config.persistent`(DB 설정값)로 판단하므로 동일한 근거입니다 — `sandbox` 테이블이
> 이미 `docker`는 `persistent=FALSE`, `docker-persistent`는 `persistent=TRUE`로 시드돼
> 있어(`01_sandbox.sql`) 이 값이 단일 진실 공급원입니다(CLAUDE.md 원칙과 일치).
>
> `from()`이 매칭되지 않는 문자열(`linux`, `linux-ssh` 등)을 전부 `Default`로 보내는 것도
> 원본의 `else` 분기(알려진 5개 값이 아니면 전부 `handleDefaultTerminal`)와 동일한 관용입니다.
>
> `data object`(파라미터 없는 케이스)를 쓰는 이유는 Kotlin의 `object`가 `data class`처럼
> 자동으로 유용한 `toString()`을 갖게 해주기 때문입니다(디버깅/로그 가독성) — 기능적으로는
> `object`만 써도 무방합니다.

### `TerminalSessionService` — 디스패처 (`domain/terminal/TerminalSessionService.kt`)

디스패처는 sealed 타입에 대해 직접 `when`으로 분기하고, 각 케이스의 실제 로직은 이 서비스
안의 `private` 메서드가 담당합니다. 6-1은 `Default`/`Docker` 두 케이스만 구현하고 나머지는
`TODO()`로 남겨 컴파일은 되지만 호출 시 명확히 실패하게 해둡니다 — 6-2에서 하나씩 채웁니다.

```kotlin
package com.etude.domain.terminal

import com.etude.domain.quest.QuestService
import com.etude.domain.sandbox.SandboxConfig
import com.etude.domain.sandbox.SandboxConfigService
import com.etude.domain.sandbox.SandboxType
import org.springframework.stereotype.Service

@Service
class TerminalSessionService(
    private val sandboxConfigService: SandboxConfigService,
    private val containerRuntime: ContainerRuntime,
    private val questService: QuestService,
) {
    fun open(sandboxTypeValue: String, questId: Long?, existingContainerId: String?): TerminalSession {
        val config = sandboxConfigService.getSandboxConfig(sandboxTypeValue)
        return when (val sandboxType = SandboxType.from(sandboxTypeValue, config)) {
            is SandboxType.Default -> openDefault(config, questId)
            is SandboxType.Docker -> openDocker(config, questId, existingContainerId, sandboxType.persistent)
            is SandboxType.LinuxSystemd -> TODO("6-2에서 구현")
            is SandboxType.K8s -> TODO("6-2에서 구현")
            is SandboxType.K8sIsolated -> TODO("6-3(Step 8 이후)에서 구현")
        }
    }

    private fun openDefault(config: SandboxConfig, questId: Long?): TerminalSession {
        val containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = config.image,
                binds = config.binds ?: emptyList(),
                command = listOf("/bin/bash"),
                tty = true,
                openStdin = true,
            )
        )
        val stream = containerRuntime.attachToMainProcess(containerId)
        containerRuntime.startContainer(containerId)
        runSetupCommand(containerId, questId)

        return TerminalSession(containerId, stream) {
            containerRuntime.stopAndRemove(containerId)
        }
    }

    private fun openDocker(
        config: SandboxConfig,
        questId: Long?,
        existingContainerId: String?,
        persistent: Boolean,
    ): TerminalSession {
        val containerId = existingContainerId ?: run {
            val id = containerRuntime.createContainer(
                ContainerSpec(
                    image = config.image,
                    binds = config.binds ?: emptyList(),
                    command = emptyList(),
                    tty = false,
                    openStdin = false,
                    privileged = true,
                )
            )
            containerRuntime.startContainer(id)
            waitForDockerDaemon(id)
            id
        }

        runSetupCommand(containerId, questId)
        val stream = containerRuntime.execShell(containerId, listOf("/bin/sh"))

        return TerminalSession(containerId, stream) {
            if (!persistent) containerRuntime.stopAndRemove(containerId)
        }
    }

    private fun waitForDockerDaemon(containerId: String) {
        containerRuntime.execAndWait(
            containerId,
            listOf("sh", "-c", "until test -S /var/run/docker.sock; do sleep 0.2; done"),
        )
    }

    private fun runSetupCommand(containerId: String, questId: Long?) {
        val setupCmd = questId?.let { questService.getSetupCommand(it) } ?: return
        containerRuntime.execAndWait(containerId, setupCmd)
    }
}

class TerminalSession(
    val containerId: String,
    val stream: TerminalStream,
    private val onClose: () -> Unit,
) {
    fun close() {
        stream.close()
        onClose()
    }
}
```

> `when (val sandboxType = ...)`이 `else` 분기 없이 sealed의 5개 케이스를 전부 나열하는
> 것이 컴파일러의 exhaustiveness 체크를 받는 지점입니다 — `SandboxType`에 케이스를
> 추가하고 이 `when`에 대응 분기를 안 넣으면 `'when' expression must be exhaustive`로
> 컴파일이 즉시 실패합니다. 6-2/6-3에서 `TODO("...")` 분기를 실제 구현으로 바꿀 때도 이
> 목록 자체는 이미 완전하므로 새로 분기를 추가할 필요 없이 본문만 채우면 됩니다.
>
> `waitForDockerDaemon`이 원본 `waitForDocker`(300ms 간격 폴링 + exec 종료 대기)를
> `execAndWait` 하나로 대체하는 이유는, "폴링 셸 스크립트가 끝날 때까지 기다린다"는 결과가
> 같기 때문입니다 — `until test -S ...; do sleep 0.2; done`이라는 셸 스크립트 자체가 이미
> 폴링 로직이므로, 그 프로세스가 끝나기를 기다리기만 하면 되고 Kotlin 쪽에서 별도로 폴링
> 루프를 짤 필요가 없습니다(원본도 사실 이렇게 하고 있습니다 — `exec.inspect()`로 폴링하는
> 것은 "그 exec 프로세스가 끝났는지"를 확인하는 것뿐입니다).

`QuestService.getSetupCommand(questId: Long): List<String>?`은 아직 없으므로 이 Step에서
추가합니다. `QuestRepository`에도 ID로 단건 조회하는 메서드가 없어 함께 추가합니다.

`domain/quest/QuestRepository.kt`에 추가:
```kotlin
interface QuestRepository {
    fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest>
    fun findById(id: Long): Quest?
}
```

`domain/quest/QuestService.kt`에 추가:
```kotlin
fun getSetupCommand(questId: Long): List<String>? {
    val quest = questRepository.findById(questId) ?: return null
    val raw = quest.setupCmd ?: return null
    return objectMapper.readValue(raw, Array<String>::class.java).toList()
}
```

> `ObjectMapper` 주입과 JSON 배열 파싱 패턴은 Step 5의 `SandboxConfigService.parseBinds`와
> 동일합니다 — `Quest.setupCmd`도 `sandbox.binds`처럼 JSON 배열 문자열 컬럼이기 때문입니다.
> `QuestService`가 아직 `ObjectMapper`를 주입받고 있지 않다면 생성자에 추가합니다.

`infrastructure/persistence/quest/QuestRepositoryImpl.kt`에도 `findById` 위임을 추가합니다:
```kotlin
override fun findById(id: Long): Quest? = questJpaRepository.findById(id).orElse(null)
```

---

## 6-4. `TerminalWebSocketHandler` — WebSocket 계층

Spring의 `BinaryWebSocketHandler`를 씁니다(명세의 스택 표에 이미 명시됨). 이진 프레임(터미널
바이트 스트림)과 텍스트 프레임(resize JSON, connected 알림)을 둘 다 다뤄야 하므로
`TextWebSocketHandler`가 아니라 `BinaryWebSocketHandler`를 상속하되 `handleTextMessage`도
오버라이드합니다 — 원본이 `socket.on('message', ...)` 하나로 바이너리/텍스트를 문자열로
변환해 구분하는 것과 달리, Spring WebSocket은 프레임 타입 자체로 콜백이 나뉩니다.

```kotlin
package com.etude.interfaces.ws

import com.etude.domain.terminal.TerminalSessionService
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.stereotype.Component
import org.springframework.web.socket.BinaryMessage
import org.springframework.web.socket.CloseStatus
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.BinaryWebSocketHandler
import java.util.concurrent.ConcurrentHashMap

data class ResizeMessage(val type: String, val cols: Int, val rows: Int)

@Component
class TerminalWebSocketHandler(
    private val terminalSessionService: TerminalSessionService,
    private val objectMapper: ObjectMapper,
) : BinaryWebSocketHandler() {
    private val sessions = ConcurrentHashMap<String, com.etude.domain.terminal.TerminalSession>()

    override fun afterConnectionEstablished(session: WebSocketSession) {
        val params = org.springframework.web.util.UriComponentsBuilder.fromUri(session.uri!!).build().queryParams
        val sandboxType = params.getFirst("sandboxType") ?: "linux"
        val questId = params.getFirst("questId")?.toLong()
        val existingContainerId = params.getFirst("containerId")

        val terminalSession = terminalSessionService.open(sandboxType, questId, existingContainerId)
        sessions[session.id] = terminalSession

        synchronized(session) {
            session.sendMessage(TextMessage(
                objectMapper.writeValueAsString(mapOf("type" to "connected", "containerId" to terminalSession.containerId))
            ))
        }

        terminalSession.stream.onOutput { bytes ->
            synchronized(session) { session.sendMessage(BinaryMessage(bytes)) }
        }
    }

    override fun handleBinaryMessage(session: WebSocketSession, message: BinaryMessage) {
        sessions[session.id]?.stream?.write(message.payload.array())
    }

    override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
        val terminalSession = sessions[session.id] ?: return
        val resize = runCatching { objectMapper.readValue(message.payload, ResizeMessage::class.java) }.getOrNull()
        if (resize?.type == "resize") {
            terminalSession.stream.resize(resize.cols, resize.rows)
        } else {
            terminalSession.stream.write(message.payload.toByteArray())
        }
    }

    override fun afterConnectionClosed(session: WebSocketSession, status: CloseStatus) {
        sessions.remove(session.id)?.close()
    }
}
```

> `afterConnectionEstablished`가 컨테이너 생성 + `setup_cmd` 실행까지 **동기적으로 끝낸 뒤**
> `connected` 메시지를 보내는 것이 원본과 동일한 순서입니다 — `TerminalSessionService.open()`
> 내부의 `execAndWait`이 블로킹이므로, 이 핸들러 메서드도 자연히 그 시간만큼 블로킹됩니다.
> Node.js는 `async` 핸들러라 이 대기 시간에도 이벤트 루프가 다른 연결을 처리할 수 있었지만,
> Spring MVC(서블릿 기반)는 WebSocket 세션 하나에 스레드 하나가 붙는 모델이라 이 블로킹이
> 다른 연결에 영향을 주지 않습니다 — 명세의 "Web 방식 — Spring MVC로 확정" 결정이 이
> 지점에서 실제로 맞아떨어집니다.
>
> **`connected` 전송을 `onOutput` 콜백 등록보다 먼저 하고, 두 전송 모두
> `synchronized(session) { ... }`로 감싸는 것이 필수입니다.** `attach`/`exec` 시작 직후
> 컨테이너가 곧바로 출력(셸 프롬프트 등)을 내보낼 수 있는데, `onOutput` 콜백은 docker-java의
> 별도 콜백 스레드에서 호출됩니다 — `connected` 텍스트 메시지를 보내는 메인 스레드와 그
> 콜백 스레드가 **같은 `WebSocketSession`에 동시에 쓰기를 시도**하면, Java WebSocket 구현체
> (Tomcat)는 한 세션에 대해 동시에 두 개의 메시지 전송을 허용하지 않으므로
> `IllegalStateException: The remote endpoint was in state [BINARY_PARTIAL_WRITING]...`가
> 발생합니다. 원본 Node.js(`ws` 라이브러리)는 이벤트 루프가 단일 스레드라 이런 동시 쓰기
> 경쟁이 애초에 없었지만, JVM은 콜백이 실제로 별도 스레드에서 실행되므로 명시적으로
> 직렬화해야 합니다. `onOutput` 등록을 `connected` 전송 뒤로 미루면 최소한 "연결 시점의"
> 경쟁은 없어지지만, 그 이후에도 컨테이너 출력이 여러 프레임으로 연속 도착하면 콜백이
> 겹쳐 호출될 수 있으므로 `synchronized(session)`으로 이 세션에 대한 모든 `sendMessage`
> 호출 자체를 직렬화해야 완전히 안전합니다.
>
> `handleTextMessage`가 JSON 파싱을 시도했다가 실패하면 일반 입력(`write`)으로 처리하는
> 로직은 원본 `attachResizeHandler`의
> `if (str.startsWith('{') && str.includes('"type":"resize"'))`와 동일한 관용입니다 —
> 다만 원본은 문자열 접두사 검사(얕은 휴리스틱)로 먼저 걸러내는데, 여기서는 `runCatching`으로
> 파싱 자체를 시도해보고 실패하면 폴백하는 방식을 씁니다. 결과적으로 "resize가 아닌 텍스트
> 입력"을 오탐하지 않는다는 점은 동일합니다.
>
> **주의**: 원본은 터미널 입력을 WebSocket의 **바이너리** 프레임으로 보내지 않고 `term.onData`
> (문자열)를 그대로 `ws.send(data)`합니다 — 브라우저의 `WebSocket.send(string)`은 텍스트
> 프레임이 됩니다. 즉 **키 입력은 텍스트 프레임, 서버→클라이언트 출력만 바이너리 프레임**
> 입니다(`Terminal.tsx`의 `ws.binaryType = 'arraybuffer'`는 수신 프레임 해석 방식일 뿐, 송신
> 프레임 타입과는 무관합니다). 그래서 `handleBinaryMessage`가 아니라 `handleTextMessage`가
> 키 입력을 받는 게 맞습니다 — 위 코드의 `handleTextMessage`가 resize가 아니면
> `stream.write(message.payload.toByteArray())`로 떨어지는 경로가 실제 키 입력 처리
> 경로입니다. `handleBinaryMessage`는 원본 프로토콜상 클라이언트가 보낼 일이 없지만, 방어적으로
> 남겨둡니다.

`config/WebSocketConfig.kt`에 핸들러를 등록합니다:

```kotlin
package com.etude.config

import com.etude.interfaces.ws.TerminalWebSocketHandler
import org.springframework.context.annotation.Configuration
import org.springframework.web.socket.config.annotation.EnableWebSocket
import org.springframework.web.socket.config.annotation.WebSocketConfigurer
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry

@Configuration
@EnableWebSocket
class WebSocketConfig(
    private val terminalWebSocketHandler: TerminalWebSocketHandler,
) : WebSocketConfigurer {
    override fun registerWebSocketHandlers(registry: WebSocketHandlerRegistry) {
        registry.addHandler(terminalWebSocketHandler, "/ws/terminal")
            .setAllowedOrigins("*")
    }
}
```

> `setAllowedOrigins("*")`는 로컬 개발 단계의 임시 설정입니다 — 원본 Fastify 서버도
> `@fastify/cors`에서 `origin: true`(모든 origin 허용)로 열어뒀으므로 REST와 동일한 정책을
> WebSocket에도 맞춥니다. 배포 전환(Step 10) 시점에 REST CORS 정책과 함께 재검토합니다.
>
> `/ws/terminal`은 `WebConfig`의 `AuthInterceptor` 대상 경로 목록에 **포함하지 않습니다**
> (인수 조건 참고) — 애초에 서블릿 필터(`JwtAuthFilter`)와 인터셉터는 HTTP 요청에 적용되는
> 것이고, WebSocket 핸드셰이크 자체는 일반 HTTP GET 요청이라 `JwtAuthFilter`를 통과하긴
> 하지만, 토큰이 없어도 필터가 그냥 통과시키므로(Step 4의 `/feedback`과 동일한 관찰) 별도
> 조치가 필요 없습니다.

---

## 6-5. 단위 테스트 — `TerminalSessionServiceTest`

`ContainerRuntime`을 MockK로 페이크해 분기 로직만 검증합니다 — 실제 Docker 연결은 6-6(통합
테스트)에서 다룹니다.

```kotlin
package com.etude.domain.terminal

import com.etude.domain.quest.QuestService
import com.etude.domain.sandbox.SandboxConfig
import com.etude.domain.sandbox.SandboxConfigService
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class TerminalSessionServiceTest : FreeSpec({
    fun newService(): Triple<SandboxConfigService, ContainerRuntime, TerminalSessionService> {
        val sandboxConfigService = mockk<SandboxConfigService>()
        val containerRuntime = mockk<ContainerRuntime>(relaxed = true)
        val questService = mockk<QuestService> {
            every { getSetupCommand(any()) } returns null
        }
        return Triple(sandboxConfigService, containerRuntime, TerminalSessionService(sandboxConfigService, containerRuntime, questService))
    }

    "default 분기(sandboxType=linux)로 열면" - {
        "attach 방식으로 연결하고 컨테이너를 시작한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("linux") } returns
                SandboxConfig(image = "etude-linux", binds = null, persistent = false)
            every { containerRuntime.createContainer(any()) } returns "c1"

            service.open("linux", questId = null, existingContainerId = null)

            verify { containerRuntime.attachToMainProcess("c1") }
            verify { containerRuntime.startContainer("c1") }
        }
    }

    "docker 분기로 닫으면" - {
        "컨테이너를 정지/제거한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("docker") } returns
                SandboxConfig(image = "docker:dind", binds = null, persistent = false)
            every { containerRuntime.createContainer(any()) } returns "c2"

            val session = service.open("docker", questId = null, existingContainerId = null)
            session.close()

            verify { containerRuntime.stopAndRemove("c2") }
        }
    }

    "docker-persistent 분기로 닫으면" - {
        "컨테이너를 지우지 않는다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("docker-persistent") } returns
                SandboxConfig(image = "docker:dind", binds = null, persistent = true)
            every { containerRuntime.createContainer(any()) } returns "c3"

            val session = service.open("docker-persistent", questId = null, existingContainerId = null)
            session.close()

            verify(exactly = 0) { containerRuntime.stopAndRemove("c3") }
        }
    }

    "docker-persistent 분기에 containerId가 있으면" - {
        "새로 만들지 않고 재사용한다" {
            val (sandboxConfigService, containerRuntime, service) = newService()
            every { sandboxConfigService.getSandboxConfig("docker-persistent") } returns
                SandboxConfig(image = "docker:dind", binds = null, persistent = true)

            service.open("docker-persistent", questId = null, existingContainerId = "existing-c4")

            verify(exactly = 0) { containerRuntime.createContainer(any()) }
            verify { containerRuntime.execShell("existing-c4", listOf("/bin/sh")) }
        }
    }
})
```

> `newService()`가 매 테스트 케이스마다 새 mock 세트를 만들어 반환하는 이유는, `FreeSpec`이
> 기본 격리 모드(`SingleInstance`)에서 spec 인스턴스 하나(따라서 최상위에 선언한 mock도
> 하나)를 모든 테스트 케이스가 공유하기 때문입니다 — mock을 최상위에서 한 번만 만들면
> `verify(exactly = 0) { containerRuntime.createContainer(any()) }`처럼 "호출 안 됐는지"를
> 확인하는 검증이 **이전에 실행된 다른 테스트의 호출 이력까지 함께** 보게 되어, 개별
> 실행에서는 통과하지만 클래스 전체를 실행하면 실패하는 순서 의존 버그가 생깁니다. 이
> 프로젝트의 다른 `FreeSpec` 테스트(예: Step 4의 `ProgressServiceTest`)와 달리 이 테스트가
> `newService()` 같은 헬퍼를 두는 이유는, 다른 테스트들은 매 케이스가 이미 자기 mock을
> 새로 선언하는 반면 이 테스트는 4개 케이스가 같은 3개 mock 조합(`sandboxConfigService`,
> `containerRuntime`, `questService`)을 반복해서 필요로 하기 때문입니다 — 매번 3줄씩
> 반복하는 대신 헬퍼로 묶었습니다.
>
> `questService`는 모든 테스트가 "setup_cmd 없음"만 필요로 하므로 헬퍼 안에서 한 번만
> 스텁합니다 — 개별 테스트가 매번 `every { questService.getSetupCommand(any()) } returns
> null`을 반복할 필요가 없습니다. 반대로 `sandboxConfigService`/`containerRuntime`의
> 스텁은 테스트마다 다른 값(`sandboxType`, 반환 `containerId`)이 필요해 각 테스트 블록
> 안에 남겨둡니다.

---

## 6-6. 통합 테스트 — `TerminalWebSocketHandlerTest`

Spring `WebSocketClient`(`StandardWebSocketClient`)로 실제 핸드셰이크부터 검증합니다. 이
Step은 **실제 Docker 데몬**이 있어야 통과하는 첫 통합 테스트입니다 — Step 5의 방침("Docker
연동은 단위 테스트는 페이크, 실제 동작은 수동/스모크 검증")을 그대로 따르되, WebSocket
핸드셰이크·프레임 프로토콜 자체는 MockK로 대체할 수 없는 부분이라 예외적으로 로컬 Docker
데몬에 대해 도는 통합 테스트를 둡니다(CI에서는 Docker 소켓이 없으면 이 테스트만 건너뛰도록
`@EnabledIfEnvironmentVariable` 등으로 표시하는 것을 권장 — 이 Step에서는 로컬 검증만
다룹니다).

이 서버는 부트 시 JPA/Hibernate가 DB에 연결해 스키마를 검증합니다(`ddl-auto: validate`) —
`TerminalWebSocketHandler` 자체는 DB를 쓰지 않지만, Spring 컨텍스트 전체가 뜨는 이상 DB
연결은 피할 수 없습니다. 그래서 이 테스트도 Step 1~5의 다른 통합 테스트와 동일하게
`support/IntegrationTest`를 상속해 Testcontainers MariaDB를 자동으로 띄웁니다(그냥
`@SpringBootTest`만 붙이면 `application.yaml`의 기본 데이터소스가 로컬 `localhost:3306`을
가리켜, 로컬에 MariaDB를 직접 켜두지 않는 한 컨텍스트 로딩 자체가
`JDBCConnectionException`으로 실패합니다). `IntegrationTest`가 이미 `@SpringBootTest`를
갖고 있으므로, 이 클래스에서는 실제 포트로 뜨는 서버가 필요하다는 것만
`webEnvironment = RANDOM_PORT`로 재선언합니다 — 서브클래스에 붙인 애노테이션이 상위
클래스의 것을 덮어씁니다.

```kotlin
package com.etude.interfaces.ws

import com.etude.support.IntegrationTest
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.server.LocalServerPort
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.client.standard.StandardWebSocketClient
import org.springframework.web.socket.handler.TextWebSocketHandler
import java.util.concurrent.CompletableFuture
import java.util.concurrent.TimeUnit

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class TerminalWebSocketHandlerTest(
    @LocalServerPort private val port: Int,
) : IntegrationTest({
    "linux 타입으로 연결하면" - {
        "connected 메시지를 받는다" {
            val client = StandardWebSocketClient()
            val connectedFuture = CompletableFuture<String>()

            val handler = object : TextWebSocketHandler() {
                override fun handleTextMessage(session: WebSocketSession, message: TextMessage) {
                    connectedFuture.complete(message.payload)
                }
            }

            val session = client.execute(handler, "ws://localhost:$port/ws/terminal?sandboxType=linux").get()
            val received = connectedFuture.get(10, TimeUnit.SECONDS)

            assert(received.contains("\"type\":\"connected\""))
            session.close()
        }
    }
})
```

> `@LocalServerPort`를 필드 주입(`@LocalServerPort private var port: Int = 0`)이 아니라
> **생성자 주입**으로 받는 이유는, 이 프로젝트의 다른 통합 테스트(`ProgressControllerTest`
> 등)가 전부 `IntegrationTest({ ... })` 람다 생성자 패턴을 쓰고, Kotest의
> `SpringAutowireConstructorExtension`이 생성자 파라미터를 자동으로 주입하는 방식을
> 표준으로 삼고 있기 때문입니다 — 이 프로젝트에서는 필드 주입을 쓰지 않습니다.
>
> 이 테스트는 `sandbox` 테이블의 `linux` 타입 이미지(`etude-linux`)가 로컬 Docker에 실제로
> pull/build되어 있어야 통과합니다 — Testcontainers는 MariaDB만 자동으로 준비해줄 뿐 이
> 이미지까지 준비해주지 않으므로, 로컬에서 `docker build`로 미리 만들어둔 이미지가
> 필요합니다(기존 Node.js 백엔드 개발 시 이미 만들어뒀을 이미지를 재사용). CI 파이프라인에
> 올릴 때는 이 이미지 빌드 단계를 별도로 추가하거나, 이 테스트 클래스를 태그로 분리해 기본
> `./gradlew test`에서 제외하는 방안을 Step 10(cutover) 이전에 결정합니다.

**수동 검증**: 브라우저로 실제 프론트엔드(`frontend/`)를 띄우고 `linux`/`docker` 타입
퀘스트를 열어, 터미널 입출력과 resize가 기존 Node.js 백엔드와 동일하게 동작하는지 눈으로
확인합니다. `docker-persistent`는 터미널을 닫았다가 같은 `containerId`로 다시 여는 시나리오
(퀘스트 목록 → 같은 퀘스트 재진입)까지 확인합니다.

---

## 완료 기준

- [ ] 위 인수 조건 체크리스트 전부 통과 (`default`, `docker`, `docker-persistent`)
- [ ] `TerminalSessionServiceTest`(MockK 단위 테스트) 통과
- [ ] `TerminalWebSocketHandlerTest`(실제 Docker 데몬 대상 통합 테스트) 통과
- [ ] `./gradlew test` 전체 클래스를 한 번에 실행해도 Step 1~6-1 테스트 모두 통과
- [ ] 수동 검증으로 브라우저 터미널이 기존 Node.js 백엔드와 동일하게 동작함을 확인
      (`linux`, `docker`, `docker-persistent` 3종)
- [ ] `linux-systemd`, `k8s`, `k8s-isolated`는 이 Step 범위가 아님을 확인 — 다음 Step(6-2)에서
      이어감
