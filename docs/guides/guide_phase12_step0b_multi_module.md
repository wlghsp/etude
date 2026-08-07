# Phase 12 Step 0b — 멀티모듈 재구성

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step0_setup.md](guide_phase12_step0_setup.md)

Step 0에서는 `backend-kotlin/`을 단일 Gradle 모듈로 만들었습니다. 이 Step에서는 참고 템플릿
(`loopers-spring-kotlin-template`)의 `apps/` + `modules/` 구조를 우리 프로젝트 규모에 맞게 가져와,
**실행 가능한 애플리케이션 모듈(`apps/backend`)**과 **여러 곳에서 재사용할 공통 모듈(`modules/jpa`)**을
분리합니다.

**왜 지금 하는가**: 아직 코드가 `User.kt` 하나뿐이라 재구성 비용이 가장 쌉니다. Step 1(인증)부터는
파일이 빠르게 늘어나므로, 패키지 구조를 다시 잡을 거라면 지금이 마지막 기회입니다.

**왜 필요한가 (지금 당장의 실익과, 배움의 목적)**: 지금은 앱이 `backend` 하나뿐이라 멀티모듈의 이점(모듈 간
경계로 컴파일 단위를 쪼개 빌드 캐시를 재사용하거나, 여러 앱이 공통 코드를 공유하는 것)이 크게 체감되지
않습니다. 하지만 이후 배치/워커 같은 별도 실행 단위가 생기거나, Gradle 멀티모듈 구조 자체를 배워두고
싶다는 목적이 있다면 지금 작은 규모로 연습해두는 것이 유효합니다. `modules/jpa`는 "언젠가 두 번째 앱이
생기면 그대로 재사용될 것"을 가정한 모듈입니다.

---

## 0b-1. 목표 구조

```
backend-kotlin/                       (루트 — 빌드 설정 총괄, 실행 파일 없음)
  settings.gradle.kts                 (모듈 include 목록)
  build.gradle.kts                    (모든 서브모듈에 공통 적용되는 plugin/dependency)
  gradlew, gradlew.bat, gradle/       (그대로 루트에 유지)

  apps/
    backend/                          (Step 0의 backend-kotlin 본체가 여기로 이동)
      build.gradle.kts                (앱 전용 의존성: web, websocket, jjwt, docker-java 등)
      src/main/kotlin/com/etude/
        BackendKotlinApplication.kt   # 앱 진입점
        config/                        # 전역 설정
        interfaces/, application/, domain/(auth 등 도메인별), infrastructure/
      src/test/kotlin/com/etude/...
      src/main/resources/application.yaml
      src/test/resources/application-test.yaml

  modules/
    jpa/                              (여러 앱이 공유할 JPA 공통 코드)
      build.gradle.kts                (spring-boot-starter-data-jpa, MariaDB 드라이버, Testcontainers)
      src/main/kotlin/com/etude/domain/BaseEntity.kt
```

`apps/backend`가 `modules/jpa`에 의존합니다 (`implementation(project(":modules:jpa"))`). 반대 방향
의존은 없습니다 — `modules/jpa`는 `apps/backend`의 존재를 모릅니다.

`supports/`(로깅, 모니터링 등 참고 템플릿에 있던 계층)는 지금 요구사항이 없어 만들지 않습니다. 필요해지면
`modules/`와 같은 방식으로 그때 추가합니다 — 쓰지 않을 추상화를 미리 만들지 않습니다.

---

## 0b-2. 디렉터리 이동

```bash
cd /Users/jihochoi/Documents/okestro/etude/backend-kotlin

mkdir -p apps/backend modules/jpa/src/main/kotlin/com/etude/domain

# Step 0에서 만든 앱 본체를 apps/backend로 이동
git mv src apps/backend/src 2>/dev/null || mv src apps/backend/src
git mv HELP.md apps/backend/HELP.md 2>/dev/null || mv HELP.md apps/backend/HELP.md

# User.kt는 domain/auth에 남기고, BaseEntity만 modules/jpa로 옮길 예정이므로
# 이 시점엔 src 전체를 옮기기만 하고 BaseEntity 분리는 0b-4에서 진행합니다.
```

> `git mv`가 실패하면(아직 git에 추적되지 않은 새 파일이라) 그냥 `mv`로 이동합니다. 이동 후
> `git status`로 rename으로 인식되는지 확인해두면 이후 diff가 깔끔합니다.

---

## 0b-3. 루트 `settings.gradle.kts` / `build.gradle.kts`

### `backend-kotlin/settings.gradle.kts` (전체 교체)

```kotlin
rootProject.name = "etude-backend"

include(
    ":apps:backend",
    ":modules:jpa",
)
```

### `backend-kotlin/build.gradle.kts` (전체 교체 — 공통 설정만 남김)

플러그인 선언과 Kotlin/Java 툴체인, 테스트 실행 방식처럼 **모든 서브모듈에 공통되는 설정**만 루트에 둡니다.
각 모듈이 실제로 어떤 의존성을 쓰는지는 `apps/backend/build.gradle.kts`, `modules/jpa/build.gradle.kts`에
개별적으로 선언합니다.

```kotlin
plugins {
    kotlin("jvm") version "2.3.21" apply false
    kotlin("plugin.spring") version "2.3.21" apply false
    kotlin("plugin.jpa") version "2.3.21" apply false
    id("org.springframework.boot") version "4.1.0" apply false
    id("io.spring.dependency-management") version "1.1.7" apply false
}

allprojects {
    group = "com.etude"
    version = "0.0.1-SNAPSHOT"

    repositories {
        mavenCentral()
    }
}

subprojects {
    apply(plugin = "org.jetbrains.kotlin.jvm")
    apply(plugin = "org.jetbrains.kotlin.plugin.spring")
    apply(plugin = "io.spring.dependency-management")

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(25)
        }
    }

    extra["testcontainersVersion"] = "1.20.4"

    dependencyManagement {
        imports {
            mavenBom("org.testcontainers:testcontainers-bom:${property("testcontainersVersion")}")
        }
    }

    dependencies {
        "implementation"("org.jetbrains.kotlin:kotlin-reflect")
        "testImplementation"("org.springframework.boot:spring-boot-starter-test")
        "testImplementation"("org.jetbrains.kotlin:kotlin-test-junit5")
        "testImplementation"("io.mockk:mockk:1.13.13")
        "testImplementation"("com.ninja-squad:springmockk:4.0.2")
        "testRuntimeOnly"("org.junit.platform:junit-platform-launcher")
    }

    tasks.withType<Test> {
        useJUnitPlatform()
    }
}

// 루트 프로젝트 자체는 빌드 산출물이 없다 — apps/modules 하위 서브모듈만 빌드 대상
tasks.configureEach { enabled = false }
```

> `dependencyManagement { imports { ... } }` 블록은 `io.spring.dependency-management` 플러그인이
> 적용된 뒤에만 쓸 수 있는 DSL입니다. `subprojects { }` 블록 안에서 `apply(plugin = ...)`를 먼저 실행한
> 다음에 이 블록이 오는 순서를 지켜야 합니다 (위 코드처럼 순서대로 두면 문제없습니다).

---

## 0b-4. `modules/jpa` — 공통 JPA 모듈

### `modules/jpa/build.gradle.kts`

```kotlin
plugins {
    kotlin("plugin.jpa")
}

dependencies {
    api("org.springframework.boot:spring-boot-starter-data-jpa")
    runtimeOnly("org.mariadb.jdbc:mariadb-java-client:3.4.1")

    testImplementation("org.springframework.boot:spring-boot-testcontainers")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.testcontainers:mariadb")
}

allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}
```

> `api(...)`로 선언한 이유: `apps/backend`가 `modules/jpa`에 의존하면, `spring-boot-starter-data-jpa`가
> 제공하는 `@Entity`, `JpaRepository` 같은 타입도 `apps/backend` 코드에서 그대로 써야 합니다.
> `implementation(...)`으로 선언하면 이 타입들이 `modules/jpa`에 갇혀서 `apps/backend`에서 컴파일
> 에러가 납니다 — Gradle의 `api` vs `implementation` 차이가 실제로 드러나는 지점입니다.

### `modules/jpa/src/main/kotlin/com/etude/domain/BaseEntity.kt`

Step 1 가이드에서 다루기로 했던 얇은 `BaseEntity`(`id` + `createdAt`만, `updatedAt`/`deletedAt` 없음)를
여기로 옮깁니다.

```kotlin
package com.etude.domain

import jakarta.persistence.Column
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.MappedSuperclass
import java.time.LocalDateTime

@MappedSuperclass
abstract class BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now()
}
```

---

## 0b-5. `apps/backend` — 앱 전용 의존성

### `apps/backend/build.gradle.kts` (신규 작성)

Step 0에서 루트에 있던 `build.gradle.kts`의 앱 전용 의존성(웹, 소켓, JWT, docker-java 등)을 여기로
옮깁니다. `spring-boot-starter-data-jpa`와 MariaDB 드라이버는 `modules/jpa`가 `api`로 제공하므로
여기서 다시 선언하지 않습니다.

```kotlin
plugins {
    kotlin("plugin.jpa")
    id("org.springframework.boot")
}

dependencies {
    implementation(project(":modules:jpa"))

    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-websocket")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("tools.jackson.module:jackson-module-kotlin")

    // BCrypt 해시만 필요 — Spring Security 전체 스타터는 넣지 않는다
    implementation("org.springframework.security:spring-security-crypto")

    // JWT
    implementation("io.jsonwebtoken:jjwt-api:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.6")

    // Docker 제어
    implementation("com.github.docker-java:docker-java-core:3.4.0")
    implementation("com.github.docker-java:docker-java-transport-httpclient5:3.4.0")
}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll("-Xjsr305=strict", "-Xannotation-default-target=param-property")
    }
}

allOpen {
    annotation("jakarta.persistence.Entity")
    annotation("jakarta.persistence.MappedSuperclass")
    annotation("jakarta.persistence.Embeddable")
}
```

> `id("org.springframework.boot")`(버전 없이)만 적용하고 `kotlin("plugin.jpa")`도 버전 없이 적용하는
> 이유: 루트 `build.gradle.kts`에서 `apply false`로 버전만 등록해뒀기 때문에, 서브모듈에서는 버전을
> 다시 쓰지 않고 플러그인 id만 적용하면 루트에서 정한 버전이 그대로 적용됩니다.
>
> `modules/jpa/build.gradle.kts`가 `kotlin("plugin.jpa")`만 적용하고 `org.springframework.boot`
> 플러그인은 적용하지 않은 것도 같은 이유입니다 — `modules/jpa`는 실행 가능한 앱이 아니라 라이브러리이므로
> `bootJar`(실행 가능한 fat jar를 만드는 태스크)가 필요 없습니다. 반대로 `apps/backend`는
> `org.springframework.boot` 플러그인이 있어야 `bootJar`/`bootRun`이 활성화됩니다.

### `apps/backend/src/main/kotlin/com/etude/domain/auth/User.kt` 수정

`BaseEntity` import 경로가 바뀌었으므로 한 줄만 고칩니다. 패키지 루트는 `com.etude.backend`가 아니라
`com.etude`입니다 — 참고 템플릿(`com.loopers.domain.member`)과 동일하게 회사/프로젝트 패키지 바로 아래
`domain`/`application`/`interfaces`/`infrastructure` 레이어를 둡니다. 앱 진입점과 `config/`도 예외 없이
`com.etude` 바로 아래에 둡니다.

```kotlin
package com.etude.domain.auth

import com.etude.domain.BaseEntity   // modules/jpa 모듈에서 가져옴 (패키지가 com.etude.domain 임에 유의 — backend 아님)
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Table

@Entity
@Table(name = "user")
class User(
    @Column(nullable = false, length = 100)
    var name: String,

    @Column(nullable = false, unique = true, length = 200)
    val email: String,

    @Column(nullable = false, length = 200)
    var password: String,

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    val role: UserRole = UserRole.member,
) : BaseEntity()
```

---

## 0b-6. Gradle Wrapper 및 IntelliJ 재인식

```bash
cd /Users/jihochoi/Documents/okestro/etude/backend-kotlin
./gradlew clean build
```

IntelliJ에서 작업 중이었다면 `File → Reload Gradle Project`(또는 `Gradle` 툴 윈도우의 새로고침 아이콘)로
다중 모듈 구조를 다시 인식시켜야 합니다. `.idea/modules.xml`이 갱신되면서 `apps.backend`, `modules.jpa`
두 모듈이 프로젝트 트리에 별도로 나타나는지 확인합니다.

**검증**:
```bash
./gradlew :apps:backend:build      # 앱 모듈만 빌드
./gradlew :modules:jpa:build       # jpa 모듈만 빌드
./gradlew build                    # 전체
```

DB(Colima + `docker compose up -d`, Step 0의 0-7 참고)가 떠 있는 상태에서 실행:

```bash
./gradlew :apps:backend:bootRun
```

**완료 기준**:
- `./gradlew build`가 두 모듈 모두 성공
- `:apps:backend:bootRun`으로 앱이 3001 포트에 정상 기동
- IntelliJ 프로젝트 트리에 `apps/backend`, `modules/jpa`가 별도 모듈로 표시됨

---

## 참고 — 이후 Step 진행 시 경로/패키지 표기

Step 1 가이드(및 이후 모든 Step)에서 `domain/auth/User.kt` 같은 경로 표기는 이제
`apps/backend/src/main/kotlin/com/etude/domain/auth/User.kt`를 가리키는 것으로 읽습니다. 패키지 루트는
`com.etude.backend`가 아니라 **`com.etude`**입니다 — `domain`/`application`/`interfaces`/`infrastructure`
레이어가 `com.etude` 바로 아래에 옵니다 (참고 템플릿의 `com.loopers.*`와 동일한 패턴). 앱 진입점
(`BackendKotlinApplication.kt`)과 전역 설정(`config/`)도 예외 없이 `com.etude` 바로 아래에 둡니다.

`BaseEntity`처럼 여러 도메인이 공유할 만한 극소수 타입만 `modules/jpa`(패키지 `com.etude.domain`)에
두고, 나머지 도메인 로직(auth/quest/progress/feedback/terminal/vcluster 등)은 모두 `apps/backend`
안의 `com.etude.domain.*`, `com.etude.application.*`, `com.etude.infrastructure.*`,
`com.etude.interfaces.*`에 둡니다 — 지금 두 번째 앱이 없는 상태에서 전부를 모듈로 쪼개는 건 과도한
추상화이므로, "정말 재사용될 것이 확실한 것"만 모듈로 승격시키는 원칙을 유지합니다.
