# Phase 12 — 백엔드 Kotlin/Spring Boot 마이그레이션

## 배경 및 목적

현재 백엔드는 Node.js + Fastify + TypeScript로 구현되어 있다 (`backend/`, 약 1060줄).
개인 프로�트로서 제출/이력서용으로 활용할 때 본인이 실제로 익숙하고 대응 가능한 언어여야 한다는 판단 하에,
백엔드를 **Kotlin + Spring Boot**로 전면 재작성한다.

- 마이그레이션 방식: **전면 재작성** (Node.js 백엔드와 병행 운영하지 않음, 완성 후 한 번에 교체)
- 프론트엔드(`frontend/`)는 변경하지 않는다. REST API 스펙과 WebSocket 프로토콜을 그대로 유지해 API 계약을 깨지 않는다.
- DB 스키마(MariaDB)는 변경하지 않는다.

## 범위 확인 (기존 Node.js 백엔드 인벤토리)

| 파일 | 줄 수 | 역할 |
|---|---|---|
| `services/terminal.ts` | 298 | WebSocket ↔ 컨테이너 stdin/stdout 브리징. sandbox 5종 분기 (docker/docker-persistent/linux-systemd/k8s/k8s-isolated) |
| `services/vcluster-pool.ts` | 115 | vcluster 생성/폴링/풀 관리 (kubectl/vcluster CLI를 child_process로 실행) |
| `services/quest.ts` | 114 | 퀘스트/퀘스트셋 조회, 접근 제어, 채점(exec + polling) |
| `services/progress.ts` | 87 | 진행률 집계, 리더보드 |
| `services/user.ts` | 40 | 사용자 CRUD, bcrypt 비밀번호 |
| `services/auth.ts` | 38 | 로그인, JWT 발급/검증 |
| `services/sandbox.ts` | 23 | sandbox 타입별 이미지/바인드 설정 조회 |
| `services/feedback.ts` | 32 | 피드백 생성/조회 |
| `plugins/docker.ts` | 26 | dockerode 인스턴스, 고아 컨테이너 정리 |
| `plugins/k8s-namespace.ts` | 17 | 고아 네임스페이스 정리 (kubectl child_process) |
| `plugins/auth-guard.ts` | 19 | JWT 인증/관리자 권한 미들웨어 |
| `routes/*.ts` (7개) | 각 10~50 | REST/WS 라우팅 |
| `index.ts` | 45 | 앱 부트스트랩, 종료 시 정리 훅 |
| `db.ts` | 8 | mysql2 커넥션 풀 |
| `types.ts` | 15 | Quest/QuestSet 타입 |

핵심 난이도는 **`terminal.ts`**에 있다: dockerode의 `container.attach()` / `exec.start({ hijack: true })`로 얻는
raw duplex stream을 WebSocket과 직접 연결하는 구조이고, sandbox 타입별로 컨테이너 생성 옵션과 라이프사이클(정리 시점,
namespace 생성/삭제, vcluster 풀 연동)이 다르다. 이 부분이 이번 마이그레이션에서 가장 신경 써야 할 지점이다.

## 대상 스택

| 영역 | 현재 (Node.js) | 변경 후 (Kotlin) |
|---|---|---|
| 언어/런타임 | TypeScript / Node.js | Kotlin / JVM 25 |
| 웹 프레임워크 | Fastify | Spring Boot 4.x (Web MVC, 서블릿 기반) |
| WebSocket | `@fastify/websocket` (ws 기반) | `spring-boot-starter-websocket` (`BinaryWebSocketHandler`) |
| Docker 제어 | dockerode | [docker-java](https://github.com/docker-java/docker-java) |
| DB 접근 | mysql2 (raw SQL) | Spring Data JPA + Hibernate (MariaDB Dialect) |
| 인증 | jsonwebtoken + bcrypt | `jjwt` + Spring Security Crypto (BCrypt) |
| 빌드 | npm/tsc | Gradle (Kotlin DSL) |
| kubectl/vcluster 실행 | child_process.exec | `ProcessBuilder` |
| 테스트 | 없음 | JUnit5 + AssertJ + MockK, Testcontainers(MariaDB) |

**DB 접근 방식 — JPA로 확정**: 참고 템플릿([loopers-spring-kotlin-template](/Users/jihochoi/Documents/study/loopers/loopers-spring-kotlin-template))의
구조를 따라 `domain/{feature}/*.kt`에 `@Entity`를 두고, `domain`은 인터페이스(`XxxRepository`)만 알고
`infrastructure`가 Spring Data JPA로 구현한다. raw SQL(JdbcTemplate)보다 보일러플레이트는 늘지만,
엔티티가 곧 도메인 모델이 되어 TDD 대상이 분명해지고 학습 목적(객체지향 설계 연습)에 더 부합한다.
집계 쿼리(진행률, 리더보드)처럼 여러 테이블을 묶는 조회는 `@Query`(JPQL) 또는 QueryDSL로 처리한다.

**Web 방식 — Spring MVC로 확정**: 컨테이너 exec 스트림은 blocking I/O(docker-java 콜백/스트림 기반)라서
WebFlux의 리액티브 이점을 살리기 어렵다.

**테스트 전략**: 도메인 로직은 단위 테스트(mock 없이 순수 객체 테스트 또는 MockK로 협력 객체만 목킹),
Repository/Service는 Testcontainers로 실제 MariaDB에 대해 통합 테스트, Docker/kubectl 연동처럼
외부 프로세스 의존이 강한 부분(terminal, vcluster)은 인터페이스로 추상화한 뒤 단위 테스트에서는 페이크 구현체를 쓰고
최소한의 수동/스모크 테스트로 실제 동작을 검증한다 (Docker-in-Docker 통합 테스트는 비용 대비 실익이 낮아 범위에서 제외).

## 패키지 구조 (멀티모듈 + 레이어드/도메인 중심)

참고 템플릿(`loopers-spring-kotlin-template`)의 `apps/` + `modules/` 멀티모듈 구조와
`interfaces → application → domain ← infrastructure` 레이어 구조를 함께 가져온다. 앱은 `backend` 하나뿐이지만,
Gradle 멀티모듈 자체를 학습하려는 목적과 향후 재사용을 고려해 `apps/backend`(실행 앱)와
`modules/jpa`(여러 앱이 공유할 JPA 공통 코드, `BaseEntity` 등)로 분리한다 (Step 0b에서 구성).
`supports/`(로깅, 모니터링 등)는 지금 요구사항이 없어 만들지 않고, 필요해지면 같은 방식으로 추가한다.

포트(인터페이스)와 어댑터(구현체)가 분리되어 있다는 점에서 헥사고날의 핵심 아이디어를 그대로 담고 있다.

패키지 루트는 `com.etude.backend`가 아니라 **`com.etude`**이다 — 참고 템플릿(`com.loopers.domain.member`
등)과 동일하게 회사/프로젝트 패키지 바로 아래에 `domain`/`application`/`interfaces`/`infrastructure`
레이어가 온다. 앱 진입점(`BackendKotlinApplication.kt`)과 전역 설정(`config/`)도 예외 없이 `com.etude`
바로 아래에 둔다 — 지금 앱이 하나뿐인 상황에서 진입점만 다른 규칙을 적용할 이유가 없다.

```
backend-kotlin/                         (루트 — 빌드 설정 총괄)
  settings.gradle.kts, build.gradle.kts (공통 plugin/dependency)

  apps/backend/                          (실행 가능한 Spring Boot 앱)
    src/main/kotlin/com/etude/
      BackendKotlinApplication.kt   # 앱 진입점
      config/                        # WebSocketConfig, SecurityConfig, DockerConfig 등

      interfaces/api/{feature}/     # Controller, Request/Response DTO — 외부 HTTP 계약
      interfaces/ws/                # TerminalWebSocketHandler — 외부 WebSocket 계약

      application/{feature}/        # Facade(유스케이스 오케스트레이션), Command, Info(응답 조합)

      domain/{feature}/             # Entity(@Entity), VO, Repository 인터페이스, Service(도메인 규칙), 도메인 예외
        domain/auth/                #   User, JwtPayload, UserRepository(interface), PasswordEncoder(interface)
        domain/quest/                #   Quest, QuestSet, QuestSetAccess, QuestRepository(interface) 등
        domain/progress/             #   QuestAttempt, ProgressRepository(interface)
        domain/feedback/             #   Feedback, FeedbackRepository(interface)
        domain/sandbox/              #   SandboxConfig, SandboxConfigRepository(interface)
        domain/terminal/             #   TerminalSession 개념, ContainerRuntime(interface) ← 포트
        domain/vcluster/             #   PooledVCluster, VclusterProvisioner(interface) ← 포트

      infrastructure/persistence/{feature}/   # Spring Data JPA Repository + Repository 인터페이스 구현체
      infrastructure/docker/                  # DockerClient 설정 + ContainerRuntime 구현체 (docker-java)
      infrastructure/process/                 # ProcessBuilder 기반 kubectl/vcluster 실행 + VclusterProvisioner 구현체
      infrastructure/security/                # JwtProvider, BCryptPasswordEncoder 어댑터

  modules/jpa/                           (공통 JPA 모듈, api로 노출 — apps/backend가 의존)
    src/main/kotlin/com/etude/domain/
      BaseEntity.kt                       # id + createdAt만 (스키마에 updated_at/deleted_at 없음)
```

**의존 방향**: `interfaces → application → domain ← infrastructure`. `domain`은 Spring/JPA/docker-java 등
외부 라이브러리에 의존하지 않는 것이 이상적이나, JPA 엔티티는 관례상 `domain`에 두고 `@Entity` 애노테이션만
예외적으로 허용한다 (참고 템플릿과 동일한 절충). Repository는 반드시 `domain`에 인터페이스, `infrastructure`에 구현체.

각 feature(auth/quest/progress/feedback/sandbox/terminal/vcluster)별로 대응하는 기존 Node.js 파일은
아래 "마이그레이션 순서"의 각 단계에서 명시한다.

## API/프로토콜 호환성 (변경 금지 대상)

프론트엔드(`frontend/src/api.ts`, `Terminal.tsx` 등)를 건드리지 않으므로 아래는 **그대로 유지**해야 한다:

- 모든 REST 엔드포인트 경로/메서드/요청·응답 JSON 필드명 (`camelCase` 등)
- WebSocket 경로 `/ws/terminal` 및 쿼리 파라미터 (`sandboxType`, `questId`, `containerId`)
- WebSocket 메시지 프로토콜:
  - 서버→클라이언트: 최초 `{"type":"connected","containerId":"..."}` 이후 raw 바이너리 스트림
  - 클라이언트→서버: 터미널 입력은 raw bytes, resize는 `{"type":"resize","cols":N,"rows":N}` JSON
- JWT 페이로드 필드(`userId`, `name`, `email`, `role`) 및 `Authorization: Bearer <token>` 헤더
- 에러 응답 형식 `{ "error": "..." }`, 성공 단순 응답 `{ "ok": true }`

## 마이그레이션 순서 (Step별 가이드 파일로 분리)

원칙: 의존성이 적은 것부터, 검증 가능한 단위로 쪼갠다. 각 Step은 **별도 가이드 파일**로 제공한다 —
한 파일에 전체를 담지 않는다.

**테스트 전략 — ATDD 바깥 루프 + 상황별 TDD/구현-후-검증 안쪽 루프** (Cucumber 등 별도 BDD 도구는 쓰지
않고 MockMvc + JUnit5로 충분히 구현한다):

1. **인수 테스트(API 테스트) 먼저**: 그 Step에서 만들 REST/WebSocket 엔드포인트에 대해 `MockMvc` +
   Testcontainers 기반 통합 테스트를 사용자 시나리오 단위로 먼저 스켈레톤 작성한다
   (`@DisplayName`에 "로그인 성공 시 토큰을 반환한다"처럼 자연어 시나리오를 명시). 이 시점엔 당연히
   컴파일도 안 되거나 실패한다 — 이게 그 Step의 "완료 기준(인수 조건)"이 된다.
2. **안쪽을 채워 통과시킨다**: 인수 테스트를 통과시키기 위해 필요한 엔티티/포트/서비스/컨트롤러를 만든다.
   - 로직이 이미 원본(`*.ts`)에 명확히 정의되어 있고 설계를 탐색할 필요가 없는 경우(단순 CRUD, 이미 정해진
     조건 분기): **구현 먼저 작성 → 단위 테스트로 검증**하는 순서가 더 자연스럽고 빠르다.
   - 도메인 규칙이 복잡하거나(채점 조건, 접근 제어처럼 여러 케이스가 얽히는 로직) 설계가 아직 불확실한
     경우: 실패하는 단위 테스트를 먼저 쓰는 **진짜 TDD(레드-그린-리팩터)**를 적용한다.
3. 인수 테스트(API 테스트)가 통과하면 그 Step은 완료다. 필요 시 `curl`/브라우저로 기존 Node 백엔드와
   동작을 최종 비교한다.

즉 "이 기능이 끝났다"의 기준은 항상 인수 테스트(API 테스트)이고, 그 안에서 무엇을 TDD로 하고 무엇을
구현 후 검증으로 할지는 로직의 불확실성에 따라 유연하게 선택한다.

**각 Step 가이드 문서의 필수 구조**: 참고한 `/Users/jihochoi/Documents/study/next-step/atdd-camping-reservation`
(레거시 코드를 인수 테스트로 감싸는 학습 프로젝트)의 `docs/acceptance-criteria.md` 형식을 따라, 모든 Step
가이드는 본문 코드 이전에 **"인수 조건" 섹션**을 둔다 — 그 Step에서 구현할 엔드포인트별로 정상/검증/예외
케이스를 체크리스트로 나열하고, "Node.js 원본의 실제 동작이 곧 인수 조건"이라는 점을 명시한다. 이 체크리스트가
그대로 해당 Step의 통합 테스트(`*ControllerTest`)로 옮겨지고, 그 테스트가 전부 통과하면 Step이 완료된 것으로
간주한다. 리스크 매트릭스(기능별 우선순위 매기기)는 이미 Step 순서 자체가 의존성 기반 우선순위이므로 별도로
만들지 않는다.

| 상태 | Step | 가이드 파일 | 대상 Node.js 파일 | 핵심 산출물 |
|---|---|---|---|---|
| ✅ | 0 | [guide_phase12_step0_setup.md](../guides/guide_phase12_step0_setup.md) | - | TS 스냅샷 태그, Gradle+Spring Boot+Kotlin 프로젝트 뼈대, 패키지 구조, 테스트 스택 |
| ✅ | 0b | [guide_phase12_step0b_multi_module.md](../guides/guide_phase12_step0b_multi_module.md) | - | 멀티모듈 재구성 — `apps/backend`(앱) + `modules/jpa`(공통 JPA, `BaseEntity`) 분리 |
| ✅ | 1 | [guide_phase12_step1_auth.md](../guides/guide_phase12_step1_auth.md) | `auth.ts`, `auth-guard.ts`, `auth.routes.ts`, `user.ts`(로그인/비밀번호 관련) | `User` 엔티티, `AuthService`(TDD), `JwtProvider`, `JwtAuthFilter`, `AuthController`, `ApiResponse<T>` 공통 래퍼 |
| ✅ | 2 | [guide_phase12_step2_user_admin.md](../guides/guide_phase12_step2_user_admin.md) | `user.ts`(나머지), `admin.routes.ts`(user 부분) | 계정 생성/비밀번호 초기화 유스케이스 + 테스트 |
| ✅ | 3 | [guide_phase12_step3_quest.md](../guides/guide_phase12_step3_quest.md) | `types.ts`, `quest.ts`(채점 제외), `quest.routes.ts`(채점 제외), `admin.routes.ts`(quest-set 부분) | `Quest`/`QuestSet`/`QuestSetAccess` 엔티티, `QuestService`(TDD) |
| ✅ | 4 | [guide_phase12_step4_progress_feedback.md](../guides/guide_phase12_step4_progress_feedback.md) | `progress.ts`, `progress.routes.ts`, `feedback.ts`, `feedback.routes.ts` | `QuestAttempt`/`Feedback` 엔티티, 집계 쿼리 테스트 |
| ✅ | 5 | [guide_phase12_step5_docker.md](../guides/guide_phase12_step5_docker.md) | `docker.ts`, `sandbox.ts` | `ContainerRuntime` 포트/어댑터, 고아 컨테이너 정리 |
| ✅ | 6-1 | [guide_phase12_step6_terminal.md](../guides/guide_phase12_step6_terminal.md) | `terminal.ts`(공통 유틸 + default/docker 분기), `terminal.routes.ts` | `TerminalWebSocketHandler`, WebSocket attach/exec 스트림 브리징, `ContainerRuntime` 포트 확장 |
| ▶️ | 6-2 | (미작성) | `terminal.ts`(linux-systemd/k8s 분기) | systemd 대기, k8s 네임스페이스 생성/삭제 |
| ⬜ | 6-3 | (미작성, Step 8 이후) | `terminal.ts`(k8s-isolated 분기) | `VclusterProvisioner` 연동 (Step 8 선행 필요) |
| ⬜ | 7 | [guide_phase12_step7_grading.md](../guides/guide_phase12_step7_grading.md) | `quest.ts`의 `execCheck`/`gradeQuest` | 채점 로직 + `/grade` 엔드포인트 |
| ⬜ | 8 | [guide_phase12_step8_vcluster.md](../guides/guide_phase12_step8_vcluster.md) | `vcluster-pool.ts`, `k8s-namespace.ts` | `VclusterProvisioner` 포트/어댑터, 풀 관리 |
| ⬜ | 9 | [guide_phase12_step9_session_shutdown.md](../guides/guide_phase12_step9_session_shutdown.md) | `session.routes.ts`, `index.ts`(정리 훅) | 세션 종료 API, graceful shutdown |
| ⬜ | 10 | [guide_phase12_step10_cutover.md](../guides/guide_phase12_step10_cutover.md) | - | 전체 회귀 테스트, **프론트엔드 API 모듈 일괄 전환**, 배포 전환, 문서/CLAUDE.md 갱신 |

범례: ✅ 완료 · ▶️ 진행 중 · ⬜ 예정

각 가이드 파일은 진행하면서 순서대로 작성한다 (한 번에 전부 작성하지 않음). Step 6(터미널)은 분량이 크면
Step 6-1(default/docker), Step 6-2(systemd/k8s), Step 6-3(k8s-isolated)처럼 더 세분화할 수 있다.

테스트 프레임워크를 Step 0에서 정한 JUnit5 + MockK에서 Kotest(FreeSpec/ShouldSpec) + MockK로 전환하는
횡단 작업은 특정 Step에 속하지 않으므로 별도 문서로 둔다:
[guide_phase12_kotest_migration.md](../guides/guide_phase12_kotest_migration.md).

**프론트엔드 연동 방침**: Step 1에서 응답을 `ApiResponse<T>`(`{ meta, data }`) 공통 래퍼로 감싸기로
결정하면서 Node.js와 Kotlin 백엔드의 응답 포맷이 달라졌다. 프론트는 백엔드를 하나만 바라보는 구조라
(`BASE URL` 단일 설정), 도메인별로 Kotlin/Node.js를 오가며 부분 전환하면 라우팅 프록시 같은 임시
인프라가 추가로 필요해진다. 그 비용을 피하기 위해 **Step 1~9는 백엔드(Kotlin)만 완성하고 curl/MockMvc/
Testcontainers로만 검증한다 — 프론트 코드는 건드리지 않는다.** 모든 도메인의 백엔드 전환이 끝난 뒤
Step 10(cutover)에서 프론트엔드 API 모듈(`frontend/src/api/*.ts`) 전체를 `ApiResponse` 포맷에 맞게
한 번에 고치고, 그 시점에 브라우저로 전체 시나리오를 회귀 검증한다.

## 결정 사항 (확정)

1. 언어: **Kotlin** — Java보다 학습 곡선은 있지만 현재 TS 코드 스타일과 사고방식이 가장 가깝고, 실력 향상이라는 목적에 부합
2. DB 접근 방식: **JdbcTemplate (raw SQL 유지)** — JPA 엔티티 매핑은 이번 범위에서 제외
3. Web 방식: **Spring MVC (서블릿, blocking)** — 컨테이너 exec 스트림이 blocking I/O라 WebFlux의 이점이 없음
4. 새 백엔드 디렉터리: **`backend-kotlin/` 신설** — 기존 `backend/`(Node.js)는 그대로 두고 병행 참고하며 작업. 완료 후 `backend/`를 지우고 `backend-kotlin/`을 `backend/`로 리네임
5. 버전: **JVM 25 (LTS) + Spring Boot 4.x** — 작성 시점(2026-08) 기준 Spring Boot 4.1.0이 안정 최신이며 공식적으로 Java 17~26을 지원(spring.io 확인). 최신 LTS를 따라가는 것으로 결정 변경 (기존 3.3.x/JVM 21 계획에서 상향)
6. 기존 `backend/`(Node.js) 보관: **git 태그로 스냅샷 고정** (`backend-typescript-final` 등) — 마이그레이션 착수 직전에 태그 생성/푸시

## 완료 기준

- Kotlin 백엔드가 전체 시나리오(로그인/퀘스트/터미널 5종 sandbox/채점/진행률/리더보드/피드백/관리자 기능)를
  기존 Node.js 백엔드와 동일하게 처리 (Step 1~9에서 curl/MockMvc/Testcontainers로 도메인별 검증)
- Step 10에서 `frontend/src/api/*.ts`를 `ApiResponse` 포맷에 맞게 일괄 전환한 뒤, 브라우저로 전체
  시나리오가 기존과 동일하게 동작
- 앱 종료 시 컨테이너/vcluster/네임스페이스 정리 로직이 기존과 동일하게 작동
- `docs/etude_dev_guide.md`에 Phase 11 가이드 인덱스 추가, `CLAUDE.md` 스택 표기 갱신
