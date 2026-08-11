package com.etude.support

import io.kotest.core.spec.style.FreeSpec
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.test.context.ActiveProfiles
import org.testcontainers.containers.MariaDBContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers

@Testcontainers
@SpringBootTest
@ActiveProfiles("test")
abstract class IntegrationTest(body: FreeSpec.() -> Unit = {}) : FreeSpec(body) {
    companion object {
        // 스키마 초기화를 Spring(spring.sql.init)이 아니라 컨테이너 시작 시점에 한 번만 실행한다.
        // 여러 @SpringBootTest spec(AuthControllerTest, BackendKotlinApplicationTests 등)이
        // Kotest 환경에서 컨텍스트를 캐시 공유하지 못하고 각자 초기화를 시도하면서
        // spring.sql.init이 매번 재실행돼 "Table already exists"가 나던 문제를 원천 차단한다.
        @Container
        @ServiceConnection
        val mariadb = MariaDBContainer("mariadb:11")
            .withInitScript("db/00_schema.sql")
    }
}