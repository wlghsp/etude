plugins {
    kotlin("plugin.jpa")
    kotlin("kapt")
    id("org.springframework.boot")
}

dependencies {
    implementation(project(":modules:jpa"))

    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-websocket")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")

    // BCrypt 해시만 필요 — Spring Security 전체 스타터는 넣지 않는다
    implementation("org.springframework.security:spring-security-crypto")

    // JWT
    implementation("io.jsonwebtoken:jjwt-api:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.6")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.6")

    // Docker 제어
    implementation("com.github.docker-java:docker-java-core:3.4.0")
    implementation("com.github.docker-java:docker-java-transport-httpclient5:3.4.0")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.7.0")

    // QueryDSL
    implementation("com.querydsl:querydsl-jpa:5.1.0:jakarta")
    kapt("com.querydsl:querydsl-apt:5.1.0:jakarta")
    kapt("jakarta.annotation:jakarta.annotation-api")
    kapt("jakarta.persistence:jakarta.persistence-api")

    // Testcontainers 의존성 3종 + allOpen 설정은 루트 build.gradle.kts의 subprojects { }에서 공통 관리
    // MockMvc(@AutoConfigureMockMvc)는 spring-boot-starter-test(루트에서 공통 관리)에 포함되어 있다
}

kotlin {
    compilerOptions {
        freeCompilerArgs.addAll("-Xjsr305=strict")
    }
}
