# Phase 8d 명세 — 실습 세션 보안 (인증 + 컨테이너 소유권)

## 목표

터미널·채점 API를 로그인한 사용자만, 그것도 **자기 세션의 컨테이너에 대해서만** 쓸 수 있게 한다. 컨테이너 정리는 WebSocket 수명주기 한 곳으로 모으고, 인증 없이 컨테이너를 중지하던 세션 종료 API(`/session/end`)는 없앤다. 로그인 화면이 있어도 API가 열려 있으면 보안 경계가 아니다.

Phase 8c(도메인 + HTTPS)로 서비스가 도메인에 공개된 뒤 이 문제의 위험이 커졌다. [Phase 8c 범위 B](spec_phase8c_https.md)의 "애플리케이션 레벨" 점검에서 이어지는 작업이다.

## 용어

| 용어 | 의미 | 생성 주체 |
|------|------|-----------|
| **attemptSessionId** | 한 세트를 푸는 동안의 퀘스트 시도를 묶는 값. 진행 기록(`quest_attempt.session_id`)에만 쓴다. 보안 경계가 아니다. | 클라이언트 ([App.tsx](../../frontend/src/App.tsx)). API 필드명은 기존대로 `sessionId`를 유지한다. |
| **터미널 세션** | WebSocket 한 번의 연결과, 그에 딸린 컨테이너 하나. 서버 메모리의 세션 레지스트리가 `containerId`로 식별한다. 별도의 세션 ID는 두지 않는다. | 서버 |

## 현황 (코드로 확인한 사실)

| 경로 | 문제 |
|------|------|
| `GET /ws/terminal` ([terminal.routes.ts](../../backend/src/routes/terminal.routes.ts)) | 인증이 없다. 누구나 컨테이너를 만들 수 있다. |
| `GET /ws/terminal`의 `containerId` 쿼리 | `docker-persistent`가 클라이언트가 보낸 호스트 컨테이너 ID에 소유권 확인 없이 `exec`를 만든다. ID를 알면 다른 사용자 컨테이너, 심하면 운영 컨테이너에도 접근을 시도할 수 있다. 이 명세의 핵심 위험이다. |
| `GET /ws/terminal`의 `sandboxType` 쿼리 | 클라이언트 입력을 그대로 쓴다. `getSandboxConfig`는 모르는 값이면 `ubuntu` 기본값으로 동작한다. |
| `POST /grade` ([quest.routes.ts](../../backend/src/routes/quest.routes.ts)) | 토큰이 없어도 채점이 실행된다. 토큰이 있을 때만 기록한다. `containerId`·`questSetId`는 body 입력을 그대로 믿는다. |
| `POST /session/end` ([session.routes.ts](../../backend/src/routes/session.routes.ts)) | 인증 없이 전달받은 아무 컨테이너 ID나 중지·삭제한다. 이 명세에서 **삭제**한다. |
| persistent 컨테이너 정리 | WebSocket이 닫혀도 서버가 정리하지 않고 클라이언트의 `/session/end`에 의존한다. 탭을 그냥 닫으면 서버 재시작까지 컨테이너가 남는다. |
| WebSocket 끊김 감지 | 서버가 연결 생존을 확인하지 않는다. nginx `proxy_read_timeout`이 3600초라, 노트북 절전·Wi-Fi 단절처럼 close 이벤트가 오지 않는 경우 컨테이너가 최대 약 한 시간 남을 수 있다. |

참고: 실습용 Docker 컨테이너는 `Privileged`로 만들어지고, 호스트 Docker 소켓을 마운트한 것은 backend 컨테이너다. 이 둘은 별개 요소다. 이 명세는 소켓/privileged 구조 자체를 바꾸지 않고(범위 밖), 그 위에서 "누가 어떤 컨테이너를 다룰 수 있는가"를 막는다.

## 설계

### 결정: 터미널 재접속 기능을 이번 범위에서 제거한다

프론트는 `docker-persistent`에서 같은 `Terminal` 컴포넌트를 세트 전체 동안 유지한다 ([App.tsx](../../frontend/src/App.tsx)의 `key`가 세트 ID 기준). 즉 "persistent"가 퀘스트 사이에서 상태를 유지하는 데 WebSocket 재접속은 필요하지 않다.

따라서:

- 클라이언트가 호스트 컨테이너 ID를 보내 기존 컨테이너를 재사용하는 경로를 **없앤다**. 가장 위험했던 경로 자체가 사라진다.
- WebSocket 연결마다 **새 컨테이너**를 만든다.
- 모든 sandbox는 **WebSocket 종료 시 정리**한다. `docker-persistent`는 "WebSocket이 열려 있는 동안 퀘스트 간 유지"로 의미를 좁힌다.
- 정리 책임은 **WebSocket close handler 한 곳**에만 둔다. 그래서 `/session/end`는 삭제한다. 남기면 close와 동시에 실행되는 경합, stop/remove 중복, `k8s-isolated`의 vcluster 자원을 레지스트리만으로 찾을 수 없는 문제, 두 정리 경로가 따로 변하는 문제가 생긴다. 프론트의 사용처는 WebSocket 수명주기로 대체된다: 세트 이탈은 `Terminal` unmount, 환경 초기화는 `resetKey` 변경에 따른 unmount와 새 연결, 탭 닫기는 브라우저의 WebSocket 종료.
- 네트워크 끊김 후 같은 컨테이너로 복구하는 재접속은 별도 Phase로 미룬다. 이 선택의 대가: 연결이 끊기면 persistent 상태(세트 안에서 쌓은 작업)가 사라진다.

### 1. WebSocket 인증: 일회용 ticket

브라우저 WebSocket은 `Authorization` 헤더를 보낼 수 없다. 토큰을 쿼리스트링에 싣는 방식은 nginx 접근 로그에 JWT가 남으므로 쓰지 않고, 짧게 사는 일회용 ticket을 쓴다.

```
1. 로그인한 사용자가  POST /terminal-sessions  요청 (Authorization 헤더, JWT, body: { questId })
2. 서버가 questId로 quest_set_id, sandbox_type을 DB에서 조회하고 접근 권한을 검사
3. 서버가 ticket 발급 (응답: { ticket })
4. 브라우저가  /ws/terminal?ticket=...  로 연결
5. 서버가 ticket을 소비하고 연결을 받아들인다
```

ticket에 연결된 서버측 정보 (메모리):

```
userId, questId, questSetId, sandboxType, expiresAt
```

`sandboxType`과 `questSetId`는 **클라이언트 입력을 신뢰하지 않고 서버가 확정**한다 (`questId → quest.quest_set_id → quest_set.sandbox_type`). WebSocket 쿼리의 `sandboxType`·`questId`·`containerId`는 더 이상 받지 않는다.

ticket 규격:

- 생성: `crypto.randomBytes(32).toString('base64url')` (CSPRNG, 256비트). `Math.random`은 쓰지 않는다.
- 유효시간: 30초.
- 소비: 조회와 삭제를 같은 동기 구간에서 처리한다 (Node 단일 스레드이므로 `Map`의 get 후 즉시 delete). 두 번째 사용은 항상 실패한다.
- 만료 ticket 정리: 소비 시점에 만료를 검사(lazy)하고, 발급 시 만료된 항목을 함께 걷어낸다. 별도 타이머는 두지 않는다.
- 무효(없음/만료/재사용) ticket의 WebSocket은 연결 직후 close code `1008`(policy violation)과 사유 문자열로 닫는다. 컨테이너는 만들지 않는다.

### 2. 세션 레지스트리 (메모리 Map)

```
containerId → { userId, questSetId, sandboxType }
```

Map 하나만 둔다. 채점·종료는 모두 `containerId`로 소유자를 확인하므로 역방향 조회가 필요 없다. 재접속을 없앴으므로 별도의 세션 ID와 상태 전이 표도 최소화된다.

DB 테이블은 두지 않는다. 이유:

- backend 시작 시 `etude=sandbox` 컨테이너를 모두 제거한다 (`cleanupOrphanContainers`).
- vcluster도 시작 시 정리한다.
- 컨테이너 수명이 WebSocket 연결 수명에 묶이므로, 서버 프로세스 수명 = Map 수명이다.

backend를 여러 인스턴스로 늘리거나 재시작 후 세션 복구가 필요해지면 DB/Redis로 옮긴다.

수명주기:

| 시점 | 동작 |
|------|------|
| 컨테이너 생성 직후, `connected` 전송 **전** | 레지스트리에 등록 |
| 컨테이너 생성/setup 실패 | 등록하지 않았거나 이미 했으면 제거. 만든 컨테이너는 정리하고 WebSocket을 닫는다. |
| WebSocket 종료 (close handler, **유일한 정리 경로**) | 레지스트리 항목 제거 → 컨테이너 중지·삭제, `k8s-isolated`는 `releaseVcluster()` 호출(현재 정책은 삭제)하며 **해당 vcluster의 kubeconfig 파일(`~/.etude/vcluster-kubeconfigs/`)도 함께 지운다**. 순서는 레지스트리가 먼저다. |
| heartbeat 실패 | 아래 "끊김 감지"의 `terminate()`가 연결을 끊으면 위 close handler가 그대로 실행된다. 별도 정리 코드를 두지 않는다. |
| 서버 종료·시작 | 기존 정리 로직이 컨테이너를 제거하고, 메모리 Map은 프로세스와 함께 사라진다. 고아 vcluster 정리와 함께 이전 프로세스가 남긴 `pool-*-kubeconfig.yaml`도 지운다. |

### 3. 끊김 감지 (heartbeat)

- 서버가 연결마다 30초 간격으로 WebSocket `ping`을 보낸다. 브라우저는 `pong`을 자동으로 응답한다.
- `pong`을 받으면 그 연결의 생존 표시를 갱신한다.
- 다음 `ping` 시점에 직전 주기의 `pong`이 없었으면 `terminate()`로 연결을 끊는다 (최대 약 60초 안에 정리).
- `terminate()` 이후의 정리는 일반 close handler가 한다 (레지스트리, 컨테이너, vcluster).
- heartbeat 타이머는 연결이 닫힐 때와 서버가 종료될 때 해제한다.

### 4. 접근 권한

기존 `canAccessQuestSet()`을 재사용한다. 단, body의 `questSetId`를 그대로 넘기지 않는다.

- ticket 발급 시: `questId`로 실제 `quest_set_id`를 DB에서 조회 → 그 세트에 `canAccessQuestSet()` 실행
- 채점 시: `containerId`가 본인 소유인지, 그리고 `questId`가 **그 세션의 `questSetId`에 속하는지** 확인
- 진행 기록(`recordAttempt`)에는 body가 아니라 **서버가 조회한 `questSetId`**를 넘긴다. `userId`는 토큰에서 가져온다.

### 5. API 변경 요약

| API | 변경 |
|-----|------|
| `POST /terminal-sessions` (신규) | `authMiddleware`. 입력: `questId` 하나. 출력: `{ ticket }`. |
| `GET /ws/terminal` | `ticket` 쿼리만 받는다. 없거나 무효면 `1008`로 닫는다. 연결마다 heartbeat. |
| `POST /grade` | `authMiddleware` 필수. body의 `questSetId`는 무시/제거. 본인 컨테이너만, 세션 세트에 속한 퀘스트만. |
| `POST /session/end` | **삭제**. 정리는 WebSocket close handler로 일원화. |

## 프론트엔드 영향

- [Terminal.tsx](../../frontend/src/components/Terminal.tsx): WebSocket을 열기 전에 `POST /terminal-sessions`로 ticket을 받는다. 연결 파라미터는 `ticket` 하나다. `containerId`/`sandboxType` prop은 연결에 쓰지 않게 된다.
- [api/](../../frontend/src/api): ticket 발급 함수 추가. 엔드포인트 URL은 이 폴더가 유일한 출처다.
- `/grade` 호출은 이미 `Authorization` 헤더 유틸이 있어, 헤더가 항상 붙는지만 확인한다. body에서 `questSetId`를 뺀다.
- `/session/end` 삭제에 맞춰 `endSession()` API 함수와 [App.tsx](../../frontend/src/App.tsx)의 두 호출(세트 이탈 cleanup, 환경 초기화 `onReset`)을 제거한다. 정리는 `Terminal` unmount 시의 `ws.close()`가 대신한다.
- 프론트와 백엔드를 **함께 배포**해야 한다 (`/ws/terminal` 쿼리 형식이 바뀐다).

## 수용 조건

- [ ] 인증 없이 `POST /terminal-sessions` → `401`
- [ ] 접근 권한 없는 퀘스트로 ticket 발급 → `403`
- [ ] 유효하지 않거나 만료된 ticket → WebSocket 거부 (`1008`)
- [ ] 같은 ticket 재사용 → 거부
- [ ] 클라이언트가 `containerId`를 보내 기존 컨테이너에 붙는 경로가 없다
- [ ] 임의 `sandboxType` 지정 불가 (서버가 DB에서 확정)
- [ ] 남의 컨테이너 채점 → `403`
- [ ] 요청한 quest가 세션의 세트에 속하지 않음 → `403`
- [ ] `/grade`가 body의 `questSetId`가 아니라 서버 조회 값으로 기록한다
- [ ] `/session/end` 라우트가 존재하지 않는다 (프론트에도 호출이 없다)
- [ ] 레지스트리 등록은 `connected` 전송 전에 일어난다
- [ ] WebSocket 종료 시 **persistent 포함** 모든 컨테이너와 레지스트리 항목 정리 (`k8s-isolated`는 vcluster 반환 포함)
- [ ] WebSocket 종료 후 해당 vcluster와 그 kubeconfig 파일이 모두 제거된다
- [ ] backend 시작 시 이전 프로세스가 남긴 pool kubeconfig 파일이 정리된다
- [ ] pong이 없는 연결이 제한 시간(최대 약 60초) 안에 끊기고 같은 close handler로 정리된다
- [ ] heartbeat 타이머가 연결 종료·서버 종료 시 해제된다
- [ ] 컨테이너 생성 실패 시 레지스트리에 항목이 남지 않는다
- [ ] 서버 종료·재시작 시 고아 컨테이너 정리

## 테스트 전략

- ticket 발급/소비/만료, 세션 레지스트리: 단위 테스트
- 인증·권한(401/403): Fastify `inject()` 기반 API 테스트 ([Node 테스트 가이드](../guides/completed/guide_node_testing_01_first_test.md)의 `buildApp()` 구조 전제)
- 실제 WebSocket 연결은 `inject()`로 검증할 수 없으므로 통합 테스트를 별도로 둔다. 최소 케이스:
  - 정상 ticket으로 연결
  - ticket 재사용 거부
  - 만료 ticket 거부
  - 다른 사용자 컨테이너에 대한 채점 거부
  - 교차 세트 퀘스트 채점 거부
  - pong을 보내지 않는 연결이 제한 시간 안에 정리됨

## 범위 밖

- 터미널 재접속(네트워크 끊김 후 같은 컨테이너로 복구) — 별도 Phase
- backend 컨테이너의 Docker 소켓 마운트 / 실습 컨테이너 `Privileged` 구조 변경 (별도 검토)
- 로그인 rate limit, JWT 만료·갱신 정책
- 운영 DB `MYSQL_ROOT_PASSWORD: root` 제거 (DB가 `127.0.0.1`에만 바인딩되어 급하지 않음, 별도 작업)
- 퀘스트 채점식 전수 감사와 채점 검증 러너 (다음 단계)
- backend 중복 실행 시 기동 정리가 먼저 실행되어 **기존 프로세스의 컨테이너·vcluster pool을 지우는 문제** (정리 → pool 생성 → `listen` 순서라, 두 번째 프로세스가 포트 충돌(`EADDRINUSE`)로 죽기 전에 이미 정리를 끝낸다). 8d와 별개의 운영 안정성 문제이며, 파괴적인 기동 정리 전에 같은 포트·프로세스가 이미 실행 중인지 확인하는 보호 장치가 필요하다. 별도 작업으로 다룬다.

## 구현 순서

1. `buildApp()` 분리와 Vitest 최소 기반 (테스트 Step 1)
2. ticket 저장소와 세션 레지스트리: 단위 테스트 → 구현
3. `POST /terminal-sessions` (ticket 발급) 구현
4. `/ws/terminal`의 ticket 소비, 컨테이너 생성 시 레지스트리 등록, WebSocket 종료 시 전체 정리 (close handler 일원화)
5. WebSocket heartbeat (ping/pong, `terminate()`)
6. `/grade`에 인증·소유권 적용, `/session/end` 라우트 삭제
7. 인증·권한 회귀 테스트 (+ WebSocket 통합 테스트)
8. 프론트: `Terminal.tsx` ticket 흐름 적용, `endSession()`과 호출 두 곳 제거, `/grade` body 정리
