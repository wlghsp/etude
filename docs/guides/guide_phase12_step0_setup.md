# Phase 12 Step 0 — 프로젝트 부트스트랩

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)

이 문서를 보고 `backend-kotlin/` 프로젝트의 뼈대를 만듭니다. 이 Step에서는 아직 기능 코드를 만들지 않고,
빌드/테스트/실행이 되는 빈 프로젝트를 완성하는 것이 목표입니다. 다음 Step(Step 1 — 인증)부터 TDD로 실제
도메인 코드를 작성합니다.

---

## 0-1. 기존 TypeScript 백엔드 스냅샷 태그

Kotlin으로 넘어가기 전에 현재 `backend/`(Node.js) 상태를 고정해둡니다.

```bash
git tag -a backend-typescript-final -m "Node.js/Fastify 백엔드 최종 버전 (Kotlin 마이그레이션 이전)"
git push origin backend-typescript-final
```

**검증**: `git tag` 목록에 `backend-typescript-final`이 보이는지, GitHub 저장소의 태그 탭에서도 확인.

---

## 0-2. 개발 환경 확인

```bash
java -version     # openjdk 25.x 가 나와야 함
```

25가 아니면 sdkman으로 설치/전환 (`sdk list java --installed`로 설치된 버전 확인 후):

```bash
sdk install java 25.0.3-tem   # 이미 설치돼 있다면 생략
sdk default java 25.0.3-tem
```

> IntelliJ에서 진행한다면 `File → Project Structure → Project → SDK`가 25로 잡혀 있는지 별도로 확인해야
> 합니다. 터미널의 sdkman 설정과 IntelliJ의 Project SDK 설정은 서로 다른 곳이라 각각 맞춰야 합니다.

---

## 0-3. 프로젝트 생성

[start.spring.io](https://start.spring.io)에서 아래 옵션으로 생성:

| 항목 | 값 |
|---|---|
| Project | Gradle - Kotlin |
| Language | Kotlin |
| Spring Boot | 4.x (최신 안정 버전, Initializr 기본값 그대로) |
| Project Metadata - Group | `com.etude` |
| Project Metadata - Artifact / Name | `backend` |
| Packaging | Jar |
| Java | 25 |
| Dependencies | Spring Web, Spring Boot WebSocket, Spring Data JPA, Validation |

> Spring Boot 4.x부터 Initializr의 "Spring Web" 항목이 실제로는 `spring-boot-starter-webmvc` 아티팩트로
> 바뀌었습니다 (3.x 시절의 `spring-boot-starter-web`에서 명칭 변경). Initializr에서 선택하는 항목 이름은
> 그대로지만 생성된 `build.gradle.kts`의 실제 좌표는 이렇게 나오니 당황하지 않아도 됩니다.

> Spring Boot 4.x는 Java 17~26을 공식 지원한다 (spring.io 확인, 2026-08 기준).
>
> **Spring Security는 넣지 않는다.** 지금 인증 요구사항은 "헤더의 JWT를 검증하고 role을 체크하는
> 커스텀 필터 하나"가 전부라(기존 `auth-guard.ts`의 `authMiddleware`/`adminMiddleware` 그대로 포팅),
> `SecurityFilterChain`/CSRF/세션 관리 같은 Spring Security의 본 기능이 쓰일 일이 없다. 전체 스타터를
> 넣으면 오히려 인증 없이도 막히는 기본 설정(모든 경로 인증 요구 등)을 풀어주는 보일러플레이트만 늘어난다.
> BCrypt 해시만 `spring-security-crypto` 모듈 단독으로 가져오고, JWT 검증/인가는 일반 서블릿 필터로 직접 작성한다.

다운로드한 zip을 풀어서 `/Users/jihochoi/Documents/okestro/etude/backend-kotlin/`에 배치합니다.
(`backend/` 기존 Node.js 프로젝트는 그대로 유지 — 참고하며 작업할 것이므로 지우지 않습니다.)

---

## 0-4. build.gradle.kts — 추가 의존성

Spring Boot 4.1.0 기준으로 Initializr가 만들어준 아티팩트명이 3.x 시절과 달라졌습니다
(`spring-boot-starter-web` → `spring-boot-starter-webmvc`, Jackson Kotlin 모듈도
`com.fasterxml.jackson.module` → `tools.jackson.module`로 그룹이 바뀌었습니다). Kotlin 플러그인 버전도
프로젝트에 이미 적용된 버전(예: `2.3.21`)에 맞춥니다 — 아래는 실제 적용된 `backend-kotlin/build.gradle.kts` 기준입니다.

```kotlin
plugins {
    kotlin("jvm") version "2.3.21"
    kotlin("plugin.spring") version "2.3.21"
    id("org.springframework.boot") version "4.1.0"
    id("io.spring.dependency-management") version "1.1.7"
    kotlin("plugin.jpa") version "2.3.21"   // JPA 엔티티에 기본 생성자/open을 자동 부여
}

// Testcontainers는 Spring Boot의 dependency-management(BOM)가 관리해주지 않는 그룹이라
// 버전을 명시한 BOM을 별도로 import해야 한다. 빠뜨리면 `Could not find org.testcontainers:...:`
// (버전 없이 콜론만 붙는) 에러로 빌드가 실패한다.
extra["testcontainersVersion"] = "1.20.4"

dependencyManagement {
    imports {
        mavenBom("org.testcontainers:testcontainers-bom:${property("testcontainersVersion")}")
    }
}

dependencies {
    // --- Web / DB / 직렬화 (Initializr가 생성) ---
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-websocket")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("tools.jackson.module:jackson-module-kotlin")

    // MariaDB 드라이버
    runtimeOnly("org.mariadb.jdbc:mariadb-java-client:3.4.1")

    // BCrypt 해시만 필요 — Spring Security 전체 스타터는 넣지 않는다
    implementation("org.springframework.security:spring-security-crypto")

    // JWT
    implementation("io.jsonwebtoken:jjwt-api:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.6")

    // Docker 제어
    implementation("com.github.docker-java:docker-java-core:3.4.0")
    implementation("com.github.docker-java:docker-java-transport-httpclient5:3.4.0")

    // --- 테스트 ---
    // 개별 -test 스타터(data-jpa-test, webmvc-test 등)는 JUnit5/AssertJ/Mockito 같은 공통 기반이
    // 중복 포함되어 통합 스타터 하나로 대체한다.
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")

    testImplementation("io.mockk:mockk:1.13.13")
    testImplementation("com.ninja-squad:springmockk:4.0.2")          // Spring 빈을 MockK로 대체하는 @MockkBean
    testImplementation("org.springframework.boot:spring-boot-testcontainers")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:mariadb")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

// JPA 엔티티/임베더블에 Kotlin의 기본 `final` class를 Hibernate가 프록시할 수 있도록 open 처리
// (allOpen은 kotlin("plugin.jpa")가 kotlin("plugin.spring")과 함께 자동 등록하지만,
//  대상 애노테이션을 명시적으로 지정하면 의도가 분명해진다)
allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}

tasks.withType<Test> {
    useJUnitPlatform()
}
```

`kapt`는 쓰지 않습니다 — Lombok이나 QueryDSL의 애노테이션 프로세서를 쓰지 않는 한 이 프로젝트에는 불필요합니다.

---

## 0-5. application.yml

`src/main/resources/application.yml` — 기존 `backend/src/index.ts`, `backend/src/db.ts`의 하드코딩된
기본값을 그대로 옮깁니다.

```yaml
server:
  port: 3001
  address: 0.0.0.0

spring:
  application:
    name: etude-backend
  datasource:
    url: jdbc:mariadb://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:etude}
    username: ${DB_USER:root}
    password: ${DB_PASSWORD:root}
  jpa:
    hibernate:
      ddl-auto: validate   # 스키마는 backend/db/*.sql이 SSOT — JPA가 스키마를 바꾸지 않도록 validate
    open-in-view: false    # 컨트롤러까지 영속성 컨텍스트를 늘리지 않음 (지연로딩 예외는 서비스 계층에서 해결)
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MariaDBDialect

etude:
  jwt:
    secret: ${JWT_SECRET:dev-secret}
    expires-hours: 24
```

`src/test/resources/application-test.yml` — 테스트 프로파일 (Testcontainers가 datasource를 동적으로 주입할 것이므로 최소한만):

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate

etude:
  jwt:
    secret: test-secret
    expires-hours: 24
```

> `ddl-auto: validate`로 두는 이유: CLAUDE.md의 "단일 진실 공급원" 원칙상 스키마는 `backend/db/*.sql`이
> 유일한 출처입니다. JPA가 스키마를 자동 생성/변경(`update`/`create`)하게 두면 SQL 파일과 실제 스키마가
> 어긋날 수 있어, 대신 엔티티가 기존 스키마와 일치하는지 검증만 하도록 `validate`로 고정합니다.

---

## 0-6. 패키지 구조 뼈대 만들기

> **참고**: 이 구조는 잠정본입니다. 다음 [Step 0b](guide_phase12_step0b_multi_module.md)에서
> `apps/backend` + `modules/jpa` 멀티모듈로 재구성하면서 `src/`가 `apps/backend/src/`로 이동합니다.
> 지금은 우선 단일 모듈로 뼈대를 잡고, 빌드/실행이 되는 것부터 확인합니다.

`src/main/kotlin/com/etude/` 아래에 빈 패키지(디렉터리)만 먼저 만들어둡니다. 파일은 아직 없어도 됩니다 —
IntelliJ에서 디렉터리를 만들거나, `mkdir -p`로 만들어도 됩니다.

```
src/main/kotlin/com/etude/
  EtudeApplication.kt          # Initializr가 생성한 그대로 사용

  interfaces/api/              # Controller, DTO
  interfaces/ws/                # WebSocket 핸들러

  application/                  # Facade, Command, Info

  domain/auth/
  domain/quest/
  domain/progress/
  domain/feedback/
  domain/sandbox/
  domain/terminal/
  domain/vcluster/

  infrastructure/persistence/
  infrastructure/docker/
  infrastructure/process/
  infrastructure/security/

  config/

src/test/kotlin/com/etude/     # 위와 동일한 하위 구조로 테스트 미러링
```

```bash
cd backend-kotlin/src/main/kotlin/com/etude
mkdir -p interfaces/api interfaces/ws application \
  domain/auth domain/quest domain/progress domain/feedback domain/sandbox domain/terminal domain/vcluster \
  infrastructure/persistence infrastructure/docker infrastructure/process infrastructure/security \
  config
```

---

## 0-7. 첫 빌드/실행 검증

Initializr가 기본 생성해준 `BackendKotlinApplicationTests`(`@SpringBootTest`로 전체 스프링 컨텍스트를
띄우는 테스트)는 JPA datasource 연결을 요구하기 때문에, **MariaDB가 떠 있지 않으면 `./gradlew build`
자체가 실패**합니다. 먼저 Colima(또는 Docker Desktop)를 켜고 DB를 띄웁니다:

```bash
colima start    # 이미 떠 있으면 생략
cd ../backend   # 기존 Node.js 백엔드의 docker-compose.yml을 그대로 사용 — 같은 MariaDB를 씀
docker compose up -d
cd ../backend-kotlin
```

그다음 빌드:

```bash
./gradlew build      # 컴파일 + 테스트 실행까지 통과해야 함
```

앱 실행:

```bash
./gradlew bootRun
```

`EtudeApplication.kt`가 3001 포트로 뜨는지 로그로 확인합니다. Spring Data JPA 의존성이 있으면
엔티티가 하나도 없어도 앱 자체는 정상 기동됩니다 (아직 `@Entity` 클래스를 안 만들었기 때문에
`ddl-auto: validate`가 검증할 대상도 없는 상태 — 정상입니다).

**검증 기준**:
- `./gradlew build`가 에러 없이 성공
- `./gradlew bootRun`으로 앱이 3001 포트에 뜸 (로그에 `Tomcat started on port 3001` 확인)
- `Ctrl+C`로 정상 종료됨

여기까지 되면 Step 0 완료입니다. 다음은 [Step 0b — 멀티모듈 재구성](guide_phase12_step0b_multi_module.md)입니다.
지금까지 만든 단일 모듈 구조를 `apps/backend` + `modules/jpa`로 나눈 뒤, Step 1(인증)에서
`User` 엔티티와 `AuthService`를 TDD로 작성합니다.
