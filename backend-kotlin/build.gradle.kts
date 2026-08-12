plugins {
    kotlin("jvm") version "2.0.20" apply false
    kotlin("plugin.spring") version "2.0.20" apply false
    kotlin("plugin.jpa") version "2.0.20" apply false
    id("org.springframework.boot") version "3.5.13" apply false
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

    // subprojects{} 블록 안에서는 apply(plugin=...)로 건 플러그인의 확장(java{}, dependencyManagement{})을
    // 타입 세이프 DSL로 바로 못 찾는다 (스크립트 컴파일 시점에 플러그인이 아직 적용되지 않은 것으로 취급됨).
    // extensions.configure<T>()로 명시적으로 우회한다.
    extensions.configure<JavaPluginExtension> {
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    extra["testcontainersVersion"] = "1.21.4"

    // org.springframework.boot 플러그인이 적용된 모듈(apps/backend)에는 Spring Boot BOM이 자동 적용되지만,
    // 라이브러리 모듈(modules/jpa)처럼 그 플러그인을 쓰지 않는 곳은 BOM이 안 걸려 spring-boot-starter-* 의
    // 버전을 못 찾는다. io.spring.dependency-management만으로 모든 서브모듈에 동일하게 BOM을 걸어준다.
    extensions.configure<io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension> {
        imports {
            mavenBom("org.testcontainers:testcontainers-bom:${property("testcontainersVersion")}")
            mavenBom(org.springframework.boot.gradle.plugin.SpringBootPlugin.BOM_COORDINATES)
        }
    }

    dependencies {
        "implementation"("org.jetbrains.kotlin:kotlin-reflect")
        "testImplementation"("org.springframework.boot:spring-boot-starter-test")
        "testImplementation"("org.jetbrains.kotlin:kotlin-test-junit5")
        "testImplementation"("io.mockk:mockk:1.13.13")
        "testImplementation"("com.ninja-squad:springmockk:4.0.2")
        "testRuntimeOnly"("org.junit.platform:junit-platform-launcher")
        "testImplementation"("io.kotest:kotest-runner-junit5:5.9.1")
        "testImplementation"("io.kotest:kotest-assertions-core:5.9.1")
        // Kotest에서 Spring 생성자 주입(SpringExtension)을 쓰려면 필수
        "testImplementation"("io.kotest.extensions:kotest-extensions-spring:1.3.0")

        // apps/backend, modules/jpa 둘 다 JPA를 쓰므로 Testcontainers도 공통으로 필요
        "testImplementation"("org.testcontainers:junit-jupiter")
        "testImplementation"("org.testcontainers:mariadb")
        "testImplementation"("org.springframework.boot:spring-boot-testcontainers")
    }

    tasks.withType<Test> {
        useJUnitPlatform()
    }

    // kotlin("plugin.jpa")가 적용된 서브모듈(apps/backend, modules/jpa)에서만 allOpen이 유효하므로
    // plugins.withId로 감싼다 — 두 모듈에 각각 중복 선언하지 않고 한 곳에서 관리한다.
    plugins.withId("org.jetbrains.kotlin.plugin.jpa") {
        extensions.configure<org.jetbrains.kotlin.allopen.gradle.AllOpenExtension> {
            annotation("jakarta.persistence.Entity")
            annotation("jakarta.persistence.MappedSuperclass")
            annotation("jakarta.persistence.Embeddable")
        }
    }
}

// 루트 프로젝트 자체는 빌드 산출물이 없다 — apps/modules 하위 서브모듈만 빌드 대상
tasks.configureEach { enabled = false }