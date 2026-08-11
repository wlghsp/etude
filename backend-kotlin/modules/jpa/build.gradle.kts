plugins {
    kotlin("plugin.jpa")
}

dependencies {
    api("org.springframework.boot:spring-boot-starter-data-jpa")
    runtimeOnly("org.mariadb.jdbc:mariadb-java-client:3.4.1")
    // Testcontainers 의존성 3종 + allOpen 설정은 루트 build.gradle.kts의 subprojects { }에서 공통 관리
}
