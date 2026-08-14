# 테스트 계층별 mock 사용 원칙

근거: [docs/research/reference_projects_action_items.md 1-3](../research/reference_projects_action_items.md)

## 문제

Etude는 이미 계층마다 mock을 다르게 쓰고 있다 — `QuestServiceTest`는 리포지토리를 mockk로
목킹하고, `QuestControllerTest`는 Testcontainers까지 띄워 실제 DB로 검증한다. 그런데 이 판단
기준이 어디에도 적혀 있지 않아서, 나중에 합류하는 사람이 "왜 이 테스트는 mock을 쓰고 저 테스트는
안 쓰지?"를 코드를 읽고 스스로 추론해야 한다. 이 문서는 지금 암묵적으로 하고 있는 걸 그대로
명문화한다 — 새 규칙을 만드는 게 아니다.

## 원칙 — 계층마다 다르게

### 1. 도메인 엔티티 단위 테스트 — mock 없음

엔티티 자신의 행동만 검증하므로 협력 객체가 없거나 있어도 값 객체 수준이라 mock이 필요 없다.

```kotlin
// QuestSetTest.kt
class QuestSetTest : FreeSpec({
    "공개 여부를 변경하면" - {
        "isPublic이 바뀐다" {
            val questSet = TestQuestSets.public(title = "리눅스 기초")
            questSet.changePublic(false)
            questSet.isPublic shouldBe false
        }
    }
})
```

`UserTest`(`PasswordEncoder`를 mockk로 목킹)처럼 엔티티가 외부 인터페이스에 위임하는 경우는
예외 — "엔티티가 협력 객체에 올바르게 위임하는지"만 확인하면 되므로 mock이 맞다. 판단 기준은
"엔티티가 DB나 다른 서비스에 의존하는가"가 아니라 "엔티티가 자기 책임 밖의 것(암호화 알고리즘
등)을 다른 객체에 위임하는가"이다.

### 2. 도메인 서비스 단위 테스트 — 리포지토리를 mockk로 목킹

서비스가 조율하는 로직(조건 분기, 여러 리포지토리 호출 순서 등)만 검증하면 되므로, 실제 DB 없이
리포지토리 인터페이스를 mockk로 대체한다.

```kotlin
// QuestServiceTest.kt
class QuestServiceTest : FreeSpec({
    val questSetRepository = mockk<QuestSetRepository>()
    val questService = QuestService(questSetRepository, ...)

    "퀘스트셋 접근 권한을 확인할 때" - {
        "공개 세트면" - {
            "member도 접근할 수 있다" {
                every { questSetRepository.findById(1L) } returns TestQuestSets.public()
                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe true
            }
        }
    }
})
```

**왜 mock을 쓰는가**: 서비스 로직(조건 분기)을 검증하는 데 실제 DB가 필요 없다. DB 접근/트랜잭션
경계는 이 테스트의 관심사가 아니고, mock을 쓰면 테스트가 빠르고 리포지토리 구현 세부사항과
무관해진다.

### 3. 컨트롤러 통합 테스트 — Testcontainers로 실제 DB까지 검증

`IntegrationTest`(`support/IntegrationTest.kt`)를 상속해 `@SpringBootTest` + Testcontainers
MariaDB로 애플리케이션 컨텍스트 전체(라우팅, 인증 인터셉터, JPA 매핑, 트랜잭션)를 실제로 띄운다.

```kotlin
// QuestControllerTest.kt (예시 구조)
class QuestControllerTest(
    @Autowired private val mockMvc: MockMvc,
) : IntegrationTest({
    "토큰 없이 /quest-sets를 호출하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/quest-sets")).andExpect(status().isUnauthorized)
        }
    }
})
```

**왜 mock을 쓰지 않는가**: 여기서 검증할 대상 자체가 "여러 컴포넌트가 실제로 맞물려 동작하는가"
(인터셉터가 401을 막는지, JPA 매핑이 실제 스키마와 맞는지, 트랜잭션이 걸리는지)다. mock으로 이런
컴포넌트를 대체하면 검증하려는 것 자체가 사라진다.

### 4. 리포지토리 구현체 자체 — 아직 별도 테스트 없음

`infrastructure/persistence/*RepositoryImpl.kt`는 현재 별도 단위 테스트가 없다 — 컨트롤러
통합 테스트(3번)가 실제 DB를 거치며 간접적으로 검증하고 있을 뿐이다. 리포지토리 쿼리 로직이
복잡해지거나(QueryDSL 조건이 많아지는 등) 컨트롤러 테스트만으로 커버리지가 부족하다고 느껴지면,
`IntegrationTest`를 상속하는 별도 리포지토리 테스트를 추가하는 걸 그때 고려한다 — 지금은 없다는
사실만 기록해둔다.

## 요약

| 계층 | mock 대상 | 이유 |
|---|---|---|
| 엔티티 단위 (`XxxTest`) | 없음 (외부 인터페이스 위임 시만 해당 인터페이스) | 자기 자신의 행동만 검증 |
| 도메인 서비스 (`XxxServiceTest`) | 리포지토리 (mockk) | 조율 로직만 검증, DB 무관 |
| 컨트롤러 통합 (`XxxControllerTest`) | 없음 (Testcontainers 실제 DB) | 컴포넌트 간 실제 연동을 검증하는 게 목적 |
| 리포지토리 구현체 | — | 아직 별도 테스트 없음, 컨트롤러 테스트가 간접 검증 |

새 도메인을 추가할 때도 이 표를 그대로 따른다 — 이 문서는 새 규칙이 아니라 지금 하고 있는 방식의
기록이다.
