plugins {
    kotlin("plugin.jpa")
    kotlin("kapt")
}

dependencies {
    api("org.springframework.boot:spring-boot-starter-data-jpa")
    runtimeOnly("org.mariadb.jdbc:mariadb-java-client:3.4.1")
    // Testcontainers 의존성 3종 + allOpen 설정은 루트 build.gradle.kts의 subprojects { }에서 공통 관리

    // QueryDSL — BaseEntity(@MappedSuperclass)의 QBaseEntity 생성용
    implementation("com.querydsl:querydsl-jpa:5.1.0:jakarta")
    kapt("com.querydsl:querydsl-apt:5.1.0:jakarta")
    kapt("jakarta.annotation:jakarta.annotation-api")
    kapt("jakarta.persistence:jakarta.persistence-api")
}
