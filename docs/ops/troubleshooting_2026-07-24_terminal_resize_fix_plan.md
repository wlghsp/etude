# 수정 방향 — 터미널 창 크기(resize) 미동기화 문제

## 증상

브라우저 터미널에서 긴 명령어를 입력하면, 화면 폭을 넘어가는 시점에 커서가 다음 줄 왼쪽 끝(컬럼 0)으로 이동해버림. 실제 브라우저 터미널 창은 넓은데도 마치 80컬럼짜리 좁은 터미널처럼 줄바꿈됨.

## 원인

프론트(`frontend/src/components/Terminal.tsx`)는 `FitAddon.fit()`으로 **브라우저에 보이는 xterm.js 화면의 cols/rows만** 컨테이너 크기에 맞춰 조정한다. 하지만 이 크기 정보를 서버로 전송하는 코드가 없다.

```ts
// Terminal.tsx:19-22
const fitAddon = new FitAddon()
term.loadAddon(fitAddon)
term.open(containerRef.current!)
fitAddon.fit()   // 화면만 맞추고, 서버에는 알리지 않음
```

백엔드(`backend/src/services/terminal.ts`)는 `exec.start({ hijack: true, stdin: true, Tty: true })`로 PTY를 열지만, dockerode의 `exec.resize()`를 호출하는 코드가 어디에도 없다. 그 결과 컨테이너 안 셸(bash 등)이 인식하는 터미널 크기는 도커 기본값(보통 80x24)에 고정된 채로 남는다.

브라우저 터미널 창이 80컬럼보다 넓어도, 서버 쪽 셸은 여전히 "80컬럼짜리 터미널"이라고 착각하고 그 지점에서 줄바꿈 처리를 하기 때문에 증상이 발생한다.

## 수정 방향

두 레이어를 함께 고쳐야 한다.

### 1. 프론트 — resize 이벤트를 서버로 전송

`term.onData`는 키 입력을 바이너리로 그대로 WebSocket에 보내는데, 지금 백엔드는 `socket.on('message', ...)`로 들어오는 모든 메시지를 무조건 stdin으로 취급한다(`stream.write(msg)`). resize 신호를 같은 채널에 섞어 보내려면, **바이너리(키 입력)와 별개로 구분 가능한 형태**로 보내야 한다.

```ts
// Terminal.tsx — 예시
import { useEffect, useRef, useState } from "react"

// fit 이후, 그리고 창 크기가 바뀔 때마다 resize 메시지 전송
const sendResize = () => {
  fitAddon.fit()
  const { cols, rows } = term
  ws.send(JSON.stringify({ type: 'resize', cols, rows }))
}

// WebSocket 연결 성공 시 최초 1회
ws.onopen = () => sendResize()

// 브라우저 창 크기 변경 대응
const resizeObserver = new ResizeObserver(() => sendResize())
resizeObserver.observe(containerRef.current!)

// cleanup에 resizeObserver.disconnect() 추가 필요
```

주의: 지금 `ws.send(data)`(키 입력)는 문자열(바이너리 아님)로 그대로 보내고 있어서, JSON 문자열로 resize를 보내면 백엔드가 이 둘을 구분해야 한다. 키 입력은 raw 문자열/바이너리로, resize는 JSON으로 보내는 식의 프로토콜 구분이 필요하다 (예: JSON.parse 시도 후 실패하면 키 입력으로 간주하거나, 별도 태그를 붙이는 방식).

### 2. 백엔드 — resize 메시지 수신 시 exec.resize() 호출

`backend/src/services/terminal.ts`의 각 `handle*Terminal` 함수에서 `socket.on('message', ...)` 부분을 수정해야 한다. 현재:

```ts
// 예: handleDockerTerminal (terminal.ts:158-159)
stream.on('data', (chunk: Buffer) => socket.send(chunk))
socket.on('message', (msg: Buffer) => stream.write(msg))
```

수정 방향 (의사 코드):

```ts
socket.on('message', (msg: Buffer) => {
  const str = msg.toString()
  if (str.startsWith('{') && str.includes('"type":"resize"')) {
    try {
      const { cols, rows } = JSON.parse(str)
      exec.resize({ h: rows, w: cols })
      return
    } catch { /* JSON 파싱 실패 시 일반 입력으로 처리 */ }
  }
  stream.write(msg)
})
```

`exec.resize()`는 dockerode의 `Exec` 인스턴스가 제공하는 메서드다. `container.attach()`로 연결한 경우(`handleDefaultTerminal`, `handleK8sTerminal`, `handleK8sIsolatedTerminal`)는 `container.resize()`를 쓴다 — attach 방식과 exec 방식이 API가 다르므로 각 handle* 함수마다 어떤 방식으로 PTY를 열었는지 확인 후 맞는 resize 메서드를 호출해야 한다.

- `exec.start()`로 연 경우 (`handleDockerTerminal`, `handleSystemdTerminal`) → `exec.resize({ h, w })`
- `container.attach()`로 연 경우 (`handleDefaultTerminal`, `handleK8sTerminal`, `handleK8sIsolatedTerminal`) → `container.resize({ h, w })`

## 적용 범위

`terminal.ts`의 5개 handle* 함수 전부에 동일한 패턴이 필요하다. 공통 로직이라 별도 헬퍼 함수로 뽑아서 중복을 줄이는 것도 고려할 만하다.

### 진행 상황 (2026-07-24)

- **프론트(`Terminal.tsx`)**: 반영 완료. `sendResize()`로 연결 시점 + `ResizeObserver`로 창 크기 변경 시 `{type:'resize', cols, rows}` 전송. cleanup에 `resizeObserver.disconnect()` 추가 완료.
- **백엔드(`terminal.ts`)**:
  - `handleDockerTerminal` — 반영 완료. `exec.resize({ h: rows, w: cols })` 사용 (exec.start() 방식이므로 올바른 API).
  - `handleDefaultTerminal` — 미반영. `container.attach()` 방식이므로 `container.resize({ h, w })` 사용해야 함.
  - `handleSystemdTerminal` — 미반영. `exec.start()` 방식이므로 `exec.resize({ h, w })` 사용.
  - `handleK8sTerminal` — 미반영. `container.attach()` 방식이므로 `container.resize({ h, w })` 사용.
  - `handleK8sIsolatedTerminal` — 미반영. `container.attach()` 방식이므로 `container.resize({ h, w })` 사용.

### 공통 헬퍼로 추출

5개 함수 중 4곳(`handleDockerTerminal` 포함)에 동일한 분기 로직이 반복되므로, 파일 상단(`runSetupCmd` 근처)에 헬퍼 함수를 하나 두고 각 handle*에서 호출하는 형태로 정리한다. `exec.resize`와 `container.resize`는 시그니처가 동일(`{ h, w }`)하므로 하나의 함수로 묶을 수 있다.

```ts
// terminal.ts 상단, runSetupCmd 아래에 추가
function attachResizeHandler(
  socket: WebSocket,
  stream: NodeJS.ReadWriteStream,
  resizeTarget: { resize: (opts: { h: number, w: number }) => Promise<void> }
) {
  stream.on('data', (chunk: Buffer) => socket.send(chunk))
  socket.on('message', (msg: Buffer) => {
    const str = msg.toString()
    if (str.startsWith('{') && str.includes('"type":"resize"')) {
      try {
        const { cols, rows } = JSON.parse(str)
        resizeTarget.resize({ h: rows, w: cols })
        return
      } catch { /* JSON 파싱 실패 시 일반 입력으로 처리 */ }
    }
    stream.write(msg)
  })
}
```

각 handle*에서 기존 두 줄(`stream.on('data', ...)`, `socket.on('message', ...)`)을 지우고 한 줄로 교체한다. `resizeTarget` 자리에 그 함수가 실제로 갖고 있는 `exec` 또는 `container`를 넘기면 된다.

- `handleDefaultTerminal` (`terminal.ts:116-117`) → `attachResizeHandler(socket, stream, container)`
- `handleDockerTerminal` (`terminal.ts:158-169`, 이미 인라인으로 반영됨) → `attachResizeHandler(socket, stream, exec)`로 교체해 다른 곳과 통일
- `handleSystemdTerminal` (`terminal.ts:202-203`) → `attachResizeHandler(socket, stream, exec)`
- `handleK8sTerminal` (`terminal.ts:247-248`) → `attachResizeHandler(socket, stream, container)`
- `handleK8sIsolatedTerminal` (`terminal.ts:287-288`) → `attachResizeHandler(socket, stream, container)`

각 함수의 `socket.on('close', ...)` 블록(컨테이너 정리, namespace 삭제, vcluster 반환 등)은 그대로 둔다 — 이번 변경과 무관하다.

### 반영 완료 + 검수에서 발견한 실수 (2026-07-24)

5개 함수 모두 `attachResizeHandler`로 교체 완료. 다만 처음 반영 시 `handleDockerTerminal`과 `handleSystemdTerminal`에서 `attachResizeHandler(socket, stream, container)`로 **`container`를 잘못 넘긴** 실수가 있었다.

이 두 함수는 `exec.start()`로 PTY를 연 방식이라 실제 터미널 크기를 쥐고 있는 건 `exec`이지 `container`가 아니다. dockerode의 `Container.resize()`는 컨테이너의 기본 TTY를 대상으로 하는 별개 API라, `exec`가 만든 PTY 크기는 이걸 호출해도 바뀌지 않는다. 즉 이 실수가 있으면 두 sandbox 타입(`docker`/`docker-persistent`, `linux-systemd`)만 resize가 여전히 안 먹는 상태로 남는다.

**규칙**: `resizeTarget` 인자는 그 함수가 실제로 `exec.start(...)`를 호출했으면 `exec`, `container.attach(...)`를 호출했으면 `container`를 넘긴다 — PTY를 연 방식을 그대로 따라간다.

수정 후 최종 매핑:

| 함수 | PTY를 연 방식 | resizeTarget |
|---|---|---|
| `handleDefaultTerminal` | `container.attach()` | `container` |
| `handleDockerTerminal` | `exec.start()` | `exec` |
| `handleSystemdTerminal` | `exec.start()` | `exec` |
| `handleK8sTerminal` | `container.attach()` | `container` |
| `handleK8sIsolatedTerminal` | `container.attach()` | `container` |

### 프론트 쪽 추가 버그 — ResizeObserver가 CONNECTING 상태에서 send() 시도

백엔드를 전부 고친 뒤에도 여전히 재현되어 브라우저 콘솔을 확인해보니 아래 에러가 있었다.

```
Uncaught InvalidStateError: Failed to execute 'send' on 'WebSocket': Still in CONNECTING state.
    at sendResize (Terminal.tsx:27:16)
    at ResizeObserver.<anonymous> (Terminal.tsx:45:57)
```

`ResizeObserver.observe()`는 [명세상](https://developer.mozilla.org/en-US/docs/Web/API/ResizeObserver/observe) 호출 즉시 콜백을 한 번 실행한다. 이 시점에 WebSocket이 아직 `CONNECTING`(readyState 0) 상태라 `ws.send()`가 예외를 던지고, 이후 정상적으로 열렸을 때의 resize 전송까지 실질적으로 묻혀버렸다.

**수정** (`Terminal.tsx`, 반영 완료):

```ts
const sendResize = () => {
    fitAddon.fit()
    if (ws.readyState !== WebSocket.OPEN) return
    const { cols, rows } = term
    ws.send(JSON.stringify({ type: 'resize', cols, rows }))
}
```

## 최종 결과 (2026-07-24) — 해결 완료

프론트(`Terminal.tsx`) + 백엔드(`terminal.ts` 5개 handle* 전부) + 위 readyState 가드까지 반영 후 정상 동작 확인. 긴 명령어 입력 시 터미널 창 폭에 맞게 자연스럽게 줄바꿈됨.

## 검증 방법

수정 후, 브라우저 창을 넓게/좁게 만들어보고 긴 명령어(`helm repo add bitnami http://charts.bitnami.com/bitnami && helm repo list` 같은)를 입력했을 때 터미널 창 폭에 맞게 자연스럽게 줄바꿈되는지 확인한다.
