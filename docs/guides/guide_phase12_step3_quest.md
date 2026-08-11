# Phase 12 Step 3 — quest (퀘스트/퀘스트셋 조회, 접근 제어)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step2_user_admin.md](guide_phase12_step2_user_admin.md)

대응하는 기존 Node.js 파일: `backend/src/types.ts`, `backend/src/services/quest.ts`(채점 제외 —
`canAccessQuestSet`, `getQuestSets`, `getQuestSetsForAdmin`, `setQuestSetPublic`,
`grantQuestSetAccess`, `revokeQuestSetAccess`, `getQuests`), `backend/src/routes/quest.routes.ts`
(채점 제외 — `GET /quest-sets`, `GET /quest-sets/:id/quests`), `backend/src/routes/admin.routes.ts`
(quest-set 관련 라우트만 — `GET /admin/quest-sets`, `PATCH /admin/quest-sets/:id`,
`POST /admin/quest-sets/:id/access`, `DELETE /admin/quest-sets/:id/access/:userId`).
`execCheck`/`gradeQuest`/`POST /grade`는 이 Step 범위가 아니다 (Step 7). `getSetupCmd`도 이 Step
범위가 아니다 — 컨테이너 생성 시점(Step 6, 터미널)에 쓰이는 로직이라 `Quest` 엔티티에 `setupCmd`
필드만 두고 실제로 읽어 쓰는 코드는 그때 작성한다.

DB 스키마는 `apps/backend/src/main/resources/db/00_schema.sql`의 `quest_set`, `quest`,
`quest_set_access` 테이블 (변경하지 않음). 초기 데이터는 `01_sandbox.sql`, `02_quest_set.sql`,
`03_quest_set*.sql`에 이미 있으므로 이 Step에서 새로 만들지 않는다.

**경로 표기 안내**는 Step 1과 동일합니다 — `domain/quest/Quest.kt`처럼 쓰는 경로는
`backend-kotlin/apps/backend/src/main/kotlin/com/etude/domain/quest/Quest.kt`를 가리킵니다.

## 인수 조건 (이 Step의 완료 기준)

*Node.js 원본(`quest.ts`, `quest.routes.ts`, `admin.routes.ts`의 quest-set 부분)의 실제 동작이 곧
인수 조건이다. 응답 포맷은 Step 1에서 도입한 `ApiResponse<T>` 공통 래퍼를 그대로 따른다.*

**퀘스트셋 목록 조회 (`GET /quest-sets`)**
- [ ] 로그인한 사용자가 호출 시 200 + 자신이 볼 수 있는 퀘스트셋 배열
      (`is_public = true`이거나, 관리자이거나, `quest_set_access`에 자신의 접근 권한이 있는 세트만 —
      기존 `getQuestSets`의 `WHERE` 조건과 동일)
- [ ] 응답 필드는 `{ id, title, description, sandboxType, category }` (camelCase — 기존
      Node.js 응답은 DB 컬럼명을 그대로 노출해 `sandbox_type`이었지만, Step 1에서 이미
      `ApiResponse<T>` 규약과 함께 필드명을 camelCase로 통일하기로 했으므로 이 Step도 맞춘다.
      "인수 조건 = Node.js 원본과 100% 동일"이 아니라 "Node.js의 동작(필터링 규칙)을 그대로 옮기되
      필드명은 Kotlin 백엔드의 기존 컨벤션을 따른다"는 뜻이다)
- [ ] 토큰 없이 호출 시 401

**퀘스트 목록 조회 (`GET /quest-sets/:id/quests`)**
- [ ] 접근 권한이 있는 세트의 `:id`로 호출 시 200 + 퀘스트 배열
      `{ id, title, description, hint, solution, setupCmd }` (`order_index` 오름차순 정렬,
      `grade_cmd`는 채점 전용이라 이 응답에 포함하지 않음 — 기존 `getQuests`의 SELECT 컬럼과 동일)
- [ ] 접근 권한이 없는 세트의 `:id`로 호출 시 403 (기존 `canAccessQuestSet` 결과가 false일 때
      `403 + { error: '이 세트에 접근할 권한이 없습니다.' }`였던 동작과 동일 — 메시지는
      `ApiResponse.fail`의 `message` 필드로 옮겨진다)
- [ ] 토큰 없이 호출 시 401

**관리자용 퀘스트셋 목록 조회 (`GET /admin/quest-sets`)**
- [ ] 관리자 토큰으로 호출 시 200 + 전체 퀘스트셋 배열(공개 여부 무관, `id` 오름차순), 각 항목에
      `isPublic`과 `accessUsers`(그 세트에 개별 접근 권한이 부여된 사용자 목록,
      `{ id, name, email }[]`) 포함 — 기존 `getQuestSetsForAdmin`과 동일
- [ ] `member` 토큰으로 호출 시 403
- [ ] 토큰 없이 호출 시 401

**퀘스트셋 공개 여부 변경 (`PATCH /admin/quest-sets/:id`)**
- [ ] 관리자 토큰으로 `{ isPublic: false }` 전송 시 200, 해당 세트가 비공개로 바뀜 (이후
      `GET /quest-sets`에서 관리자/접근 권한 보유자 외에는 보이지 않음)
- [ ] `member` 토큰으로 호출 시 403

**퀘스트셋 접근 권한 부여 (`POST /admin/quest-sets/:id/access`)**
- [ ] 관리자 토큰으로 `{ userId }` 전송 시 200, 해당 사용자가 비공개 세트에 접근 가능해짐
- [ ] 이미 권한이 있는 사용자에게 다시 부여해도 에러 없이 200 (기존 `INSERT IGNORE`와 동일하게
      멱등하게 처리 — 중복 시 예외를 던지지 않음)
- [ ] `member` 토큰으로 호출 시 403

**퀘스트셋 접근 권한 회수 (`DELETE /admin/quest-sets/:id/access/:userId`)**
- [ ] 관리자 토큰으로 호출 시 200, 해당 사용자의 접근 권한이 제거됨
- [ ] 권한이 없던 사용자에 대해 호출해도 에러 없이 200 (기존 `DELETE ... WHERE`와 동일하게 대상이
      없어도 멱등하게 처리)
- [ ] `member` 토큰으로 호출 시 403

이 조건들은 아래 3-6(통합 테스트)의 `QuestControllerTest`/`AdminQuestSetControllerTest`로 그대로
옮겨진다. 이 Step은 그 테스트가 전부 통과하면 완료다.

프론트엔드(`frontend/src/api/quest.ts`, `admin.ts`)는 Step 1과 동일한 방침으로 이 Step에서 건드리지
않는다 — Step 10(cutover)에서 전체 API 모듈을 일괄 전환한다.

## 진행 방식

Step 1/2와 동일하게 **ATDD 바깥 루프 + 구현-후-검증 안쪽 루프**로 진행합니다. `quest.ts`의 조회/접근
제어 로직은 이미 SQL로 명확히 정의되어 있어 설계를 탐색할 이유가 없으므로, "구현 먼저 작성 → 단위
테스트로 검증" 순서를 그대로 씁니다. 다만 `canAccessQuestSet`의 3분기 조건(공개/관리자/개별 권한)은
`QuestService`에서 단위 테스트로 각 분기를 명시적으로 검증합니다 — 조건 하나를 놓치면 보안(접근 제어)
버그로 이어지기 때문에, 이 Step에서는 유일하게 "구현 후 검증"이 아니라 케이스를 먼저 나열하고 하나씩
채우는 방식으로 접근합니다. 레이어는 `domain/quest`(엔티티/포트/서비스) →
`infrastructure/persistence/quest`(어댑터) → `interfaces/api/quest`, `interfaces/api/admin`
(컨트롤러) → 인수 테스트 순으로 나갑니다. `UserRepository`, `ApiResponse<T>`, `ApiControllerAdvice`,
`AuthInterceptor`/`AdminInterceptor`는 Step 1~2에서 이미 만들어져 있으므로 재사용만 합니다.

---

## 3-0. 엔티티 3종 — `QuestSet`, `Quest`, `QuestSetAccess`

### `QuestSet` (`domain/quest/QuestSet.kt`)

`00_schema.sql`의 `quest_set` 테이블과 1:1 대응합니다. `sandbox_type`은 문자열로 그대로 두고 별도
enum을 만들지 않습니다 — `sandbox` 테이블의 `type`(PK, `VARCHAR`)을 참조하는 FK라 값의 종류가
`sandbox` 테이블 데이터에 의해 결정되고(Step 5에서 `SandboxConfig` 엔티티로 다룸), 지금 Kotlin
enum으로 하드코딩하면 나중에 `sandbox` 테이블에 새 타입이 추가될 때마다 코드도 함께 고쳐야 합니다.

```kotlin
package com.etude.domain.quest

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest_set")
class QuestSet(
    @Column(nullable = false, length = 100)
    val title: String,

    @Column(columnDefinition = "TEXT")
    val description: String?,

    @Column(name = "sandbox_type", nullable = false, length = 20)
    val sandboxType: String,

    @Column(nullable = false, length = 50)
    val category: String,

    @Column(name = "is_public", nullable = false)
    var isPublic: Boolean = true,
) : BaseEntity() {
    fun setPublic(value: Boolean) {
        isPublic = value
    }
}
```

> `isPublic`을 `var`로 열어두지 않고 `setPublic()` 메서드로 감싼 이유는 Step 2의 `User.name`/
> `password`와 동일합니다 — "공개 여부를 바꾼다"는 의도가 드러나는 진입점을 하나로 고정해두면,
> 나중에 "비공개로 바꿀 때 접근 권한 목록을 함께 정리한다" 같은 규칙이 생겨도 이 메서드 안에만
> 추가하면 됩니다. 다만 `User`처럼 `protected set` 캡슐화까지는 하지 않았습니다 — Hibernate
> 지연 로딩 프록시 이슈(Step 2의 2-0 참고)는 `open` 클래스의 `private`/`final` 조합에서만
> 발생하고, `var` 프로퍼티에 `setPublic()`을 얹는 것만으로는 그 문제가 생기지 않기 때문입니다.

### `Quest` (`domain/quest/Quest.kt`)

```kotlin
package com.etude.domain.quest

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest")
class Quest(
    @Column(name = "quest_set_id", nullable = false)
    val questSetId: Long,

    @Column(name = "order_index", nullable = false)
    val orderIndex: Int = 0,

    @Column(nullable = false, length = 200)
    val title: String,

    @Column(nullable = false, columnDefinition = "TEXT")
    val description: String,

    @Column(columnDefinition = "TEXT")
    val hint: String?,

    @Column(columnDefinition = "TEXT")
    val solution: String?,

    @Column(name = "setup_cmd", columnDefinition = "JSON")
    val setupCmd: String?,

    @Column(name = "grade_cmd", nullable = false, columnDefinition = "JSON")
    val gradeCmd: String,
) : BaseEntity()
```

> `setup_cmd`/`grade_cmd`는 스키마상 `JSON` 타입이지만, 이 Step에서는 `String`으로만 받아둡니다.
> 기존 `quest.ts`의 `getQuests()`도 `setup_cmd`를 `JSON.parse()`해서 배열로 돌려주지만, 그건 이
> 값을 실제로 셋업 커맨드로 실행하는 Step 6(터미널)의 책임입니다. 이 Step의 `GET
> /quest-sets/:id/quests` 응답에서는 원본 JSON 문자열을 그대로 내려주고, 파싱은 필요해지는 시점
> (Step 6/7)에 그 값을 실제로 쓰는 코드가 담당합니다 — 지금 파싱해서 `List<String>?`으로 바꿔봤자
> 이 Step에서 그 파싱 결과를 검증할 테스트도, 소비하는 코드도 없어 확인되지 않은 변환 로직만
> 늘어납니다. `Column(columnDefinition = "JSON")`을 명시한 이유는 Hibernate 기본 매핑이 `JSON`
> 컬럼을 `VARCHAR(255)`로 오인해 `ddl-auto: validate`가 스키마 불일치로 실패하는 걸 막기 위함입니다.

### `QuestSetAccess` — 복합키라 `BaseEntity`를 쓰지 않는다

`quest_set_access`는 `PRIMARY KEY (quest_set_id, user_id)`인 복합키 테이블입니다. `BaseEntity`는
단일 `id` 컬럼을 전제하므로 이 엔티티는 상속하지 않고 `@IdClass`로 직접 키를 구성합니다.

`domain/quest/QuestSetAccessId.kt` — 복합키 클래스 (JPA는 `@IdClass`에 쓸 클래스가 `Serializable`,
`equals`/`hashCode` 구현, 기본 생성자를 요구합니다 — Kotlin `data class`가 이 요건을 한 번에
충족시켜줍니다):

```kotlin
package com.etude.domain.quest

import java.io.Serializable

data class QuestSetAccessId(
    val questSetId: Long = 0,
    val userId: Long = 0,
) : Serializable
```

`domain/quest/QuestSetAccess.kt`:

```kotlin
package com.etude.domain.quest

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.IdClass
import jakarta.persistence.Table
import java.time.LocalDateTime

@Entity
@Table(name = "quest_set_access")
@IdClass(QuestSetAccessId::class)
class QuestSetAccess(
    @Id
    @Column(name = "quest_set_id")
    val questSetId: Long,

    @Id
    @Column(name = "user_id")
    val userId: Long,

    @Column(name = "granted_at", nullable = false)
    val grantedAt: LocalDateTime = LocalDateTime.now(),
)
```

**검증**: `./gradlew compileKotlin`이 통과하는지 확인.

---

## 3-1. Repository 포트 3종

### `QuestSetRepository` (`domain/quest/QuestSetRepository.kt`)

```kotlin
package com.etude.domain.quest

interface QuestSetRepository {
    fun findById(id: Long): QuestSet?
    fun findAllPublicOrAccessibleBy(userId: Long): List<QuestSet>
    fun findAll(): List<QuestSet>
    fun save(questSet: QuestSet): QuestSet
}
```

> `findAllPublicOrAccessibleBy`가 기존 `getQuestSets`의 3분기 조건(공개/관리자/개별 권한)을
> 그대로 옮긴 것처럼 보이지만, "관리자면 전부 보인다"는 조건은 이 메서드에 넣지 않습니다 — 그건
> role에 따른 분기이지 리포지토리가 알 책임이 아닙니다. 대신 `QuestService`(3-2)가 role을 보고
> `findAll()`(관리자) 또는 `findAllPublicOrAccessibleBy(userId)`(일반 사용자)를 선택합니다. SQL
> 재사용보다 "리포지토리는 저장소 접근만, 역할에 따른 분기는 서비스가"라는 책임 분리를 우선했습니다.

### `QuestRepository` (`domain/quest/QuestRepository.kt`)

```kotlin
package com.etude.domain.quest

interface QuestRepository {
    fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest>
}
```

### `QuestSetAccessRepository` (`domain/quest/QuestSetAccessRepository.kt`)

```kotlin
package com.etude.domain.quest

interface QuestSetAccessRepository {
    fun existsByQuestSetIdAndUserId(questSetId: Long, userId: Long): Boolean
    fun findAllByQuestSetId(questSetId: Long): List<QuestSetAccess>
    fun save(access: QuestSetAccess)
    fun deleteByQuestSetIdAndUserId(questSetId: Long, userId: Long)
}
```

---

## 3-2. `QuestService` — 접근 제어는 케이스를 먼저 나열하고 채운다

`canAccessQuestSet`의 3분기(공개 세트 / 관리자 / 개별 권한 보유)는 하나라도 놓치면 "비공개 세트가
새어 보이거나" "권한이 있는데도 막히는" 보안 버그로 직결됩니다. 이 로직만은 구현 전에 케이스를
먼저 테스트로 나열하고 하나씩 채웁니다(레드-그린).

### 도메인 예외 (`domain/quest/QuestExceptions.kt`)

```kotlin
package com.etude.domain.quest

class QuestSetAccessDeniedException(message: String = "이 세트에 접근할 권한이 없습니다.") : RuntimeException(message)
class QuestSetNotFoundException(message: String = "존재하지 않는 퀘스트셋입니다.") : RuntimeException(message)
```

### 응답 타입 (`domain/quest/QuestSetSummary.kt`)

```kotlin
package com.etude.domain.quest

import com.etude.domain.auth.UserSummary

data class QuestSetSummary(
    val id: Long,
    val title: String,
    val description: String?,
    val sandboxType: String,
    val category: String,
)

data class QuestSummary(
    val id: Long,
    val title: String,
    val description: String,
    val hint: String?,
    val solution: String?,
    val setupCmd: String?,
)

data class QuestSetAdminSummary(
    val id: Long,
    val title: String,
    val description: String?,
    val sandboxType: String,
    val category: String,
    val isPublic: Boolean,
    val accessUsers: List<UserSummary>,
)
```

> `QuestSetAdminSummary.accessUsers`가 `UserSummary`(Step 1에서 만든 `domain.auth.UserSummary`)를
> 재사용합니다. 기존 `getQuestSetsForAdmin`의 `accessUsers`도 `{ id, name, email }`만 담고
> `role`은 없었는데, `UserSummary`는 `role`까지 포함합니다. 새 타입을 만들지 않고 기존 타입에
> 필드 하나가 더 노출되는 것을 선택한 이유는, `role`이 민감 정보가 아니고(이미 관리자 전용
> API이므로 응답을 볼 수 있는 사람 자체가 제한적) 별도 DTO를 하나 더 만드는 비용이 그 이득보다
> 크기 때문입니다.

### `QuestService` 구현 (`domain/quest/QuestService.kt`)

```kotlin
package com.etude.domain.quest

import com.etude.domain.auth.UserRole
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserSummary
import org.springframework.stereotype.Service

@Service
class QuestService(
    private val questSetRepository: QuestSetRepository,
    private val questRepository: QuestRepository,
    private val questSetAccessRepository: QuestSetAccessRepository,
    private val userRepository: UserRepository,
) {
    fun getQuestSets(userId: Long, role: UserRole): List<QuestSetSummary> {
        val questSets = if (role == UserRole.admin) {
            questSetRepository.findAll()
        } else {
            questSetRepository.findAllPublicOrAccessibleBy(userId)
        }
        return questSets.map { QuestSetSummary(it.id, it.title, it.description, it.sandboxType, it.category) }
    }

    fun canAccess(userId: Long, role: UserRole, questSetId: Long): Boolean {
        val questSet = questSetRepository.findById(questSetId) ?: return false
        if (questSet.isPublic) return true
        if (role == UserRole.admin) return true
        return questSetAccessRepository.existsByQuestSetIdAndUserId(questSetId, userId)
    }

    fun getQuests(userId: Long, role: UserRole, questSetId: Long): List<QuestSummary> {
        if (!canAccess(userId, role, questSetId)) throw QuestSetAccessDeniedException()

        return questRepository.findAllByQuestSetIdOrderByOrderIndex(questSetId)
            .map { QuestSummary(it.id, it.title, it.description, it.hint, it.solution, it.setupCmd) }
    }

    fun getQuestSetsForAdmin(): List<QuestSetAdminSummary> {
        return questSetRepository.findAll().map { questSet ->
            val accessUsers = questSetAccessRepository.findAllByQuestSetId(questSet.id)
                .mapNotNull { access -> userRepository.findById(access.userId) }
                .map { UserSummary(it.id, it.name, it.email, it.role) }
            QuestSetAdminSummary(
                id = questSet.id,
                title = questSet.title,
                description = questSet.description,
                sandboxType = questSet.sandboxType,
                category = questSet.category,
                isPublic = questSet.isPublic,
                accessUsers = accessUsers,
            )
        }
    }

    fun setPublic(questSetId: Long, isPublic: Boolean) {
        val questSet = questSetRepository.findById(questSetId) ?: throw QuestSetNotFoundException()
        questSet.setPublic(isPublic)
        questSetRepository.save(questSet)
    }

    fun grantAccess(questSetId: Long, userId: Long) {
        if (questSetAccessRepository.existsByQuestSetIdAndUserId(questSetId, userId)) return
        questSetAccessRepository.save(QuestSetAccess(questSetId, userId))
    }

    fun revokeAccess(questSetId: Long, userId: Long) {
        questSetAccessRepository.deleteByQuestSetIdAndUserId(questSetId, userId)
    }
}
```

> `grantAccess`가 저장 전에 `existsByQuestSetIdAndUserId`로 먼저 확인하고 조용히 반환하는 이유는
> 기존 `INSERT IGNORE`(중복 PK를 에러 없이 무시)와 동일한 멱등성을 서비스 계층에서 명시적으로
> 재현하기 위해서입니다 — JPA `save()`는 PK가 이미 있으면 insert가 아니라 update로 동작하므로,
> 확인 없이 그�대로 `save()`하면 `grantedAt`이 갱신되어버려 "최초 부여 시점"이라는 의미가
> 깨집니다.
> `revokeAccess`가 대상이 없어도 예외 없이 넘어가는 이유도 기존 `DELETE ... WHERE`(대상이 없으면
> 0 rows affected로 조용히 끝남)와 동일한 동작을 맞추기 위해서입니다.

### 테스트로 검증 (`src/test/kotlin/com/etude/domain/quest/QuestServiceTest.kt`)

`canAccess`의 3분기를 각각 독립된 케이스로 명시합니다 — 이 부분이 이 Step에서 유일하게 "구현보다
테스트를 먼저 쓰는" 대상입니다(위 3-2 서두 참고). 나머지 메서드는 이미 구현되어 있으므로 뒤이어
검증만 합니다.

```kotlin
package com.etude.domain.quest

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class QuestServiceTest : FreeSpec({

    val questSetRepository = mockk<QuestSetRepository>()
    val questRepository = mockk<QuestRepository>()
    val questSetAccessRepository = mockk<QuestSetAccessRepository>()
    val userRepository = mockk<UserRepository>()
    val questService = QuestService(questSetRepository, questRepository, questSetAccessRepository, userRepository)

    "퀘스트셋 접근 권한을 확인할 때" - {
        "공개 세트면" - {
            "member도 접근할 수 있다" {
                val publicSet = QuestSet(title = "리눅스 기초", description = null, sandboxType = "linux", category = "리눅스", isPublic = true)
                every { questSetRepository.findById(1L) } returns publicSet

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe true
            }
        }

        "비공개 세트라도" - {
            "관리자면 접근할 수 있다" {
                val privateSet = QuestSet(title = "비공개", description = null, sandboxType = "linux", category = "리눅스", isPublic = false)
                every { questSetRepository.findById(1L) } returns privateSet

                questService.canAccess(userId = 1L, role = UserRole.admin, questSetId = 1L) shouldBe true
            }

            "member는 개별 권한이 있어야 접근할 수 있다" {
                val privateSet = QuestSet(title = "비공개", description = null, sandboxType = "linux", category = "리눅스", isPublic = false)
                every { questSetRepository.findById(1L) } returns privateSet
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns true

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe true
            }

            "member가 개별 권한도 없으면 접근할 수 없다" {
                val privateSet = QuestSet(title = "비공개", description = null, sandboxType = "linux", category = "리눅스", isPublic = false)
                every { questSetRepository.findById(1L) } returns privateSet
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns false

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe false
            }
        }

        "존재하지 않는 세트면" - {
            "접근할 수 없다" {
                every { questSetRepository.findById(999L) } returns null

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 999L) shouldBe false
            }
        }
    }

    "퀘스트 목록을 조회할 때" - {
        "접근 권한이 없으면" - {
            "예외를 던진다" {
                every { questSetRepository.findById(1L) } returns null

                io.kotest.assertions.throwables.shouldThrow<QuestSetAccessDeniedException> {
                    questService.getQuests(userId = 10L, role = UserRole.member, questSetId = 1L)
                }
            }
        }

        "접근 권한이 있으면" - {
            "order_index 순으로 반환한다" {
                val publicSet = QuestSet(title = "리눅스 기초", description = null, sandboxType = "linux", category = "리눅스", isPublic = true)
                every { questSetRepository.findById(1L) } returns publicSet
                every { questRepository.findAllByQuestSetIdOrderByOrderIndex(1L) } returns listOf(
                    Quest(questSetId = 1L, orderIndex = 0, title = "1번", description = "설명", hint = null, solution = null, setupCmd = null, gradeCmd = "[]"),
                )

                val result = questService.getQuests(userId = 10L, role = UserRole.member, questSetId = 1L)

                result.size shouldBe 1
                result[0].title shouldBe "1번"
            }
        }
    }

    "관리자가 퀘스트셋 공개 여부를 바꿀 때" - {
        "대상이 존재하면" - {
            "isPublic이 바뀐다" {
                val questSet = QuestSet(title = "리눅스 기초", description = null, sandboxType = "linux", category = "리눅스", isPublic = true)
                every { questSetRepository.findById(1L) } returns questSet
                every { questSetRepository.save(questSet) } returns questSet

                questService.setPublic(1L, false)

                questSet.isPublic shouldBe false
            }
        }

        "존재하지 않는 id면" - {
            "예외를 던진다" {
                every { questSetRepository.findById(999L) } returns null

                io.kotest.assertions.throwables.shouldThrow<QuestSetNotFoundException> {
                    questService.setPublic(999L, false)
                }
            }
        }
    }

    "관리자가 접근 권한을 부여할 때" - {
        "이미 권한이 있으면" - {
            "다시 저장하지 않는다" {
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns true

                questService.grantAccess(1L, 10L)

                verify(exactly = 0) { questSetAccessRepository.save(any()) }
            }
        }

        "권한이 없으면" - {
            "새로 저장한다" {
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns false
                every { questSetAccessRepository.save(any()) } returns Unit

                questService.grantAccess(1L, 10L)

                verify(exactly = 1) { questSetAccessRepository.save(any()) }
            }
        }
    }
})
```

**검증**: `./gradlew test --tests "*.QuestServiceTest"` — 9개 테스트 모두 통과해야 합니다.

---

## 3-3. 어댑터 구현 — `infrastructure/persistence/quest`

### `QuestSetJpaRepository.kt`, `QuestSetRepositoryImpl.kt`

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSet
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface QuestSetJpaRepository : JpaRepository<QuestSet, Long> {
    @Query(
        """
        SELECT qs FROM QuestSet qs
        WHERE qs.isPublic = true
           OR EXISTS (
               SELECT 1 FROM QuestSetAccess qsa
               WHERE qsa.questSetId = qs.id AND qsa.userId = :userId
           )
        """
    )
    fun findAllPublicOrAccessibleBy(@Param("userId") userId: Long): List<QuestSet>
}
```

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSet
import com.etude.domain.quest.QuestSetRepository
import org.springframework.stereotype.Repository

@Repository
class QuestSetRepositoryImpl(
    private val jpaRepository: QuestSetJpaRepository,
) : QuestSetRepository {
    override fun findById(id: Long): QuestSet? = jpaRepository.findById(id).orElse(null)
    override fun findAllPublicOrAccessibleBy(userId: Long): List<QuestSet> = jpaRepository.findAllPublicOrAccessibleBy(userId)
    override fun findAll(): List<QuestSet> = jpaRepository.findAll()
    override fun save(questSet: QuestSet): QuestSet = jpaRepository.save(questSet)
}
```

> JPQL의 `EXISTS` 서브쿼리로 기존 `getQuestSets` SQL의 조건을 그대로 옮겼습니다. "관리자면 전부"
> 조건은 여기 없다는 점은 3-1에서 이미 설명한 대로입니다 — `QuestService`가 role을 보고 이 메서드
> 자체를 호출할지 말지 결정합니다.

### `QuestJpaRepository.kt`, `QuestRepositoryImpl.kt`

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.Quest
import org.springframework.data.jpa.repository.JpaRepository

interface QuestJpaRepository : JpaRepository<Quest, Long> {
    fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest>
}
```

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.Quest
import com.etude.domain.quest.QuestRepository
import org.springframework.stereotype.Repository

@Repository
class QuestRepositoryImpl(
    private val jpaRepository: QuestJpaRepository,
) : QuestRepository {
    override fun findAllByQuestSetIdOrderByOrderIndex(questSetId: Long): List<Quest> =
        jpaRepository.findAllByQuestSetIdOrderByOrderIndex(questSetId)
}
```

### `QuestSetAccessJpaRepository.kt`, `QuestSetAccessRepositoryImpl.kt`

복합키 엔티티라 `JpaRepository<QuestSetAccess, QuestSetAccessId>`처럼 두 번째 타입 파라미터에
`@IdClass`로 지정한 `QuestSetAccessId`를 그대로 씁니다.

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSetAccess
import com.etude.domain.quest.QuestSetAccessId
import org.springframework.data.jpa.repository.JpaRepository

interface QuestSetAccessJpaRepository : JpaRepository<QuestSetAccess, QuestSetAccessId> {
    fun existsByQuestSetIdAndUserId(questSetId: Long, userId: Long): Boolean
    fun findAllByQuestSetId(questSetId: Long): List<QuestSetAccess>
    fun deleteByQuestSetIdAndUserId(questSetId: Long, userId: Long)
}
```

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSetAccess
import com.etude.domain.quest.QuestSetAccessRepository
import org.springframework.stereotype.Repository

@Repository
class QuestSetAccessRepositoryImpl(
    private val jpaRepository: QuestSetAccessJpaRepository,
) : QuestSetAccessRepository {
    override fun existsByQuestSetIdAndUserId(questSetId: Long, userId: Long): Boolean =
        jpaRepository.existsByQuestSetIdAndUserId(questSetId, userId)
    override fun findAllByQuestSetId(questSetId: Long): List<QuestSetAccess> =
        jpaRepository.findAllByQuestSetId(questSetId)
    override fun save(access: QuestSetAccess) {
        jpaRepository.save(access)
    }
    override fun deleteByQuestSetIdAndUserId(questSetId: Long, userId: Long) {
        jpaRepository.deleteByQuestSetIdAndUserId(questSetId, userId)
    }
}
```

**검증**: `./gradlew compileKotlin`이 통과하는지 확인.

---

## 3-4. `ApiControllerAdvice`에 예외 핸들러 추가

`QuestSetAccessDeniedException`은 403, `QuestSetNotFoundException`은 404로 응답해야 합니다.

```kotlin
// interfaces/api/ApiControllerAdvice.kt
import com.etude.domain.quest.QuestSetAccessDeniedException
import com.etude.domain.quest.QuestSetNotFoundException

// 기존 핸들러들 사이에 추가
@ExceptionHandler
fun handle(e: QuestSetAccessDeniedException): ResponseEntity<ApiResponse<*>> =
    failureResponse(HttpStatus.FORBIDDEN, ErrorType.FORBIDDEN.code, e.message!!)

@ExceptionHandler
fun handle(e: QuestSetNotFoundException): ResponseEntity<ApiResponse<*>> =
    failureResponse(HttpStatus.NOT_FOUND, ErrorType.NOT_FOUND.code, e.message!!)
```

---

## 3-5. 컨트롤러 — `QuestV1Controller`, `AdminQuestSetV1Controller`

Step 1/2와 동일하게 **ApiSpec + Controller** 분리, `ApiResponse<T>` 반환 패턴을 씁니다.

### 3-5a. `interfaces/api/quest/QuestV1ApiSpec.kt`, `QuestV1Controller.kt`

```kotlin
package com.etude.interfaces.api.quest

import com.etude.domain.quest.QuestSetSummary
import com.etude.domain.quest.QuestSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Quest V1 API", description = "퀘스트/퀘스트셋 조회 API 입니다.")
interface QuestV1ApiSpec {
    @Operation(summary = "퀘스트셋 목록 조회", description = "로그인한 사용자가 접근 가능한 퀘스트셋 목록을 조회합니다.")
    fun getQuestSets(): ApiResponse<List<QuestSetSummary>>

    @Operation(summary = "퀘스트 목록 조회", description = "지정한 퀘스트셋에 속한 퀘스트 목록을 순서대로 조회합니다.")
    fun getQuests(questSetId: Long): ApiResponse<List<QuestSummary>>
}
```

```kotlin
package com.etude.interfaces.api.quest

import com.etude.domain.auth.JwtPayload
import com.etude.domain.quest.QuestService
import com.etude.domain.quest.QuestSetSummary
import com.etude.domain.quest.QuestSummary
import com.etude.infrastructure.security.REQUEST_ATTR_JWT_PAYLOAD
import com.etude.interfaces.api.ApiResponse
import jakarta.servlet.http.HttpServletRequest
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController

@RestController
class QuestV1Controller(
    private val questService: QuestService,
) : QuestV1ApiSpec {
    @GetMapping("/quest-sets")
    override fun getQuestSets(httpRequest: HttpServletRequest): ApiResponse<List<QuestSetSummary>> {
        val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
        return ApiResponse.success(questService.getQuestSets(payload.userId, payload.role))
    }

    @GetMapping("/quest-sets/{questSetId}/quests")
    override fun getQuests(
        @PathVariable questSetId: Long,
        httpRequest: HttpServletRequest,
    ): ApiResponse<List<QuestSummary>> {
        val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
        return ApiResponse.success(questService.getQuests(payload.userId, payload.role, questSetId))
    }
}
```

> `QuestV1ApiSpec`의 두 메서드 시그니처에 `httpRequest: HttpServletRequest`가 없는 것처럼 보이지만,
> Step 2의 `MeV1ApiSpec`과 동일하게 Kotlin은 `override`가 시그니처를 완전히 일치시켜야 하므로
> 실제로는 ApiSpec에도 `httpRequest: HttpServletRequest` 파라미터를 추가해야 컴파일됩니다. 위
> 코드 블록을 그대로 복사하지 말고 파라미터를 맞춰서 작성합니다.
>
> `/quest-sets`, `/quest-sets/**`는 이미 Step 1의 `WebConfig`에서 `AuthInterceptor`가
> `addPathPatterns`에 등록해뒀으므로(1-7 참고), 토큰 없이 호출하면 컨트롤러에 도달하기 전에
> 401로 막힙니다.

### 3-5b. `interfaces/api/admin/AdminQuestSetV1ApiSpec.kt`, `AdminQuestSetV1Controller.kt`

```kotlin
package com.etude.interfaces.api.admin

import com.etude.domain.quest.QuestSetAdminSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Admin Quest Set V1 API", description = "관리자용 퀘스트셋 관리 API 입니다.")
interface AdminQuestSetV1ApiSpec {
    @Operation(summary = "퀘스트셋 목록 조회(관리자)", description = "전체 퀘스트셋과 접근 권한 부여 현황을 조회합니다.")
    fun getQuestSets(): ApiResponse<List<QuestSetAdminSummary>>

    @Operation(summary = "퀘스트셋 공개 여부 변경", description = "퀘스트셋을 공개/비공개로 전환합니다.")
    fun setPublic(id: Long, request: SetPublicRequest): ApiResponse<Unit>

    @Operation(summary = "접근 권한 부여", description = "지정한 사용자에게 비공개 퀘스트셋 접근 권한을 부여합니다.")
    fun grantAccess(id: Long, request: GrantAccessRequest): ApiResponse<Unit>

    @Operation(summary = "접근 권한 회수", description = "지정한 사용자의 퀘스트셋 접근 권한을 회수합니다.")
    fun revokeAccess(id: Long, userId: Long): ApiResponse<Unit>
}
```

```kotlin
package com.etude.interfaces.api.admin

import com.etude.domain.quest.QuestService
import com.etude.domain.quest.QuestSetAdminSummary
import com.etude.interfaces.api.ApiResponse
import jakarta.validation.Valid
import jakarta.validation.constraints.NotNull
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class SetPublicRequest(
    @field:NotNull val isPublic: Boolean,
)

data class GrantAccessRequest(
    @field:NotNull val userId: Long,
)

@RestController
@RequestMapping("/admin/quest-sets")
class AdminQuestSetV1Controller(
    private val questService: QuestService,
) : AdminQuestSetV1ApiSpec {
    @GetMapping
    override fun getQuestSets(): ApiResponse<List<QuestSetAdminSummary>> =
        ApiResponse.success(questService.getQuestSetsForAdmin())

    @PatchMapping("/{id}")
    override fun setPublic(@PathVariable id: Long, @Valid @RequestBody request: SetPublicRequest): ApiResponse<Unit> {
        questService.setPublic(id, request.isPublic)
        return ApiResponse.success<Unit>()
    }

    @PostMapping("/{id}/access")
    override fun grantAccess(@PathVariable id: Long, @Valid @RequestBody request: GrantAccessRequest): ApiResponse<Unit> {
        questService.grantAccess(id, request.userId)
        return ApiResponse.success<Unit>()
    }

    @DeleteMapping("/{id}/access/{userId}")
    override fun revokeAccess(@PathVariable id: Long, @PathVariable userId: Long): ApiResponse<Unit> {
        questService.revokeAccess(id, userId)
        return ApiResponse.success<Unit>()
    }
}
```

> `/admin/quest-sets`, `/admin/quest-sets/**`는 이미 Step 1의 `WebConfig`에서 `AdminInterceptor`
> (`addPathPatterns("/admin/**")`)가 관리자 권한을 검증하고 있으므로, 컨트롤러에서 별도로 role을
> 확인하지 않습니다 (Step 2의 `AdminUserV1Controller`와 동일한 패턴).
>
> `ApiResponse.success<Unit>()`처럼 타입 파라미터를 명시하는 이유는 Step 2에서 이미 겪은 문제와
> 같습니다 — 인자 없는 `ApiResponse.success()`는 `ApiResponse<Any>`로 고정되어 있어 반환 타입이
> `ApiResponse<Unit>`인 메서드에서 타입 불일치가 나므로, 제네릭 오버로드(`success<T>()`)를 명시적
>으로 호출해야 합니다.

---

## 3-6. 통합 테스트 — `QuestControllerTest`, `AdminQuestSetControllerTest`

Step 1/2의 `IntegrationTest`(`com.etude.support.IntegrationTest`)를 상속해 Testcontainers 설정을
재사용합니다. `IntegrationTest`가 이미 `FreeSpec`을 상속하고 있으므로(Kotest 마이그레이션 가이드
참고) 생성자 주입 + `FreeSpec` 본문 스타일로 바로 작성합니다.

`quest_set`/`quest`에 이미 시드 데이터(`02_quest_set.sql`, `03_quest_set*.sql`)가 있지만, 통합
테스트는 그 시드 데이터에 의존하지 않고 `beforeTest`에서 자신만의 데이터를 직접 만듭니다 — 시드
데이터의 개수나 내용이 나중에 바뀌어도 이 테스트가 깨지지 않게 하기 위해서입니다.

`src/test/kotlin/com/etude/interfaces/api/quest/QuestControllerTest.kt`

```kotlin
package com.etude.interfaces.api.quest

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.domain.quest.Quest
import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.MockMvc

@AutoConfigureMockMvc
class QuestControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questJpaRepository: QuestJpaRepository,
) : IntegrationTest({

    fun loginAndGetToken(email: String, password: String): String {
        val response = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"$email","password":"$password"}""")
        ).andReturn().response.contentAsString
        return Regex(""""token":"([^"]+)"""").find(response)!!.groupValues[1]
    }

    lateinit var publicSet: QuestSet
    lateinit var privateSet: QuestSet

    beforeTest {
        questJpaRepository.deleteAll()
        questSetJpaRepository.deleteAll()
        userJpaRepository.deleteAll()

        userJpaRepository.save(
            User(name = "멤버", email = "member@okestro.com", password = BCryptPasswordEncoder().encode("member123")!!, role = UserRole.member)
        )
        publicSet = questSetJpaRepository.save(
            QuestSet(title = "공개 세트", description = null, sandboxType = "linux", category = "리눅스", isPublic = true)
        )
        privateSet = questSetJpaRepository.save(
            QuestSet(title = "비공개 세트", description = null, sandboxType = "linux", category = "리눅스", isPublic = false)
        )
        questJpaRepository.save(
            Quest(questSetId = publicSet.id, orderIndex = 0, title = "1번 퀘스트", description = "설명", hint = null, solution = null, setupCmd = null, gradeCmd = "[]")
        )
    }

    "퀘스트셋 목록을 조회하면" - {
        "공개 세트만 보인다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(get("/quest-sets").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].title").value("공개 세트"))
        }
    }

    "공개 세트의 퀘스트 목록을 조회하면" - {
        "순서대로 반환된다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(get("/quest-sets/${publicSet.id}/quests").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].title").value("1번 퀘스트"))
        }
    }

    "비공개 세트의 퀘스트 목록을 조회하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(get("/quest-sets/${privateSet.id}/quests").header("Authorization", "Bearer $token"))
                .andExpect(status().isForbidden)
        }
    }

    "토큰 없이 퀘스트셋 목록을 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/quest-sets")).andExpect(status().isUnauthorized)
        }
    }
})
```

`src/test/kotlin/com/etude/interfaces/api/admin/AdminQuestSetControllerTest.kt`

```kotlin
package com.etude.interfaces.api.admin

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRole
import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.MockMvc

@AutoConfigureMockMvc
class AdminQuestSetControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
) : IntegrationTest({

    fun loginAndGetToken(email: String, password: String): String {
        val response = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"$email","password":"$password"}""")
        ).andReturn().response.contentAsString
        return Regex(""""token":"([^"]+)"""").find(response)!!.groupValues[1]
    }

    lateinit var privateSet: QuestSet
    lateinit var memberId: Long

    beforeTest {
        questSetJpaRepository.deleteAll()
        userJpaRepository.deleteAll()

        userJpaRepository.save(
            User(name = "관리자", email = "admin@okestro.com", password = BCryptPasswordEncoder().encode("admin123")!!, role = UserRole.admin)
        )
        val member = userJpaRepository.save(
            User(name = "멤버", email = "member@okestro.com", password = BCryptPasswordEncoder().encode("member123")!!, role = UserRole.member)
        )
        memberId = member.id
        privateSet = questSetJpaRepository.save(
            QuestSet(title = "비공개 세트", description = null, sandboxType = "linux", category = "리눅스", isPublic = false)
        )
    }

    "관리자가 퀘스트셋 목록을 조회하면" - {
        "isPublic과 accessUsers를 포함해 전체가 보인다" {
            val token = loginAndGetToken("admin@okestro.com", "admin123")

            mockMvc.perform(get("/admin/quest-sets").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].isPublic").value(false))
                .andExpect(jsonPath("$.data[0].accessUsers").isArray)
        }
    }

    "member 권한으로 조회를 시도하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken("member@okestro.com", "member123")

            mockMvc.perform(get("/admin/quest-sets").header("Authorization", "Bearer $token"))
                .andExpect(status().isForbidden)
        }
    }

    "관리자가 퀘스트셋을 공개로 전환하면" - {
        "member도 목록에서 볼 수 있게 된다" {
            val adminToken = loginAndGetToken("admin@okestro.com", "admin123")

            mockMvc.perform(
                patch("/admin/quest-sets/${privateSet.id}")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"isPublic":true}""")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken("member@okestro.com", "member123")
            mockMvc.perform(get("/quest-sets").header("Authorization", "Bearer $memberToken"))
                .andExpect(jsonPath("$.data.length()").value(1))
        }
    }

    "관리자가 접근 권한을 부여하면" - {
        "해당 사용자가 비공개 세트를 볼 수 있게 된다" {
            val adminToken = loginAndGetToken("admin@okestro.com", "admin123")

            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":$memberId}""")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken("member@okestro.com", "member123")
            mockMvc.perform(get("/quest-sets/${privateSet.id}/quests").header("Authorization", "Bearer $memberToken"))
                .andExpect(status().isOk)
        }
    }

    "관리자가 접근 권한을 회수하면" - {
        "해당 사용자가 다시 접근할 수 없게 된다" {
            val adminToken = loginAndGetToken("admin@okestro.com", "admin123")
            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":$memberId}""")
            )

            mockMvc.perform(
                delete("/admin/quest-sets/${privateSet.id}/access/$memberId")
                    .header("Authorization", "Bearer $adminToken")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken("member@okestro.com", "member123")
            mockMvc.perform(get("/quest-sets/${privateSet.id}/quests").header("Authorization", "Bearer $memberToken"))
                .andExpect(status().isForbidden)
        }
    }
})
```

**검증**:
```bash
./gradlew test --tests "*.QuestServiceTest" --tests "*.QuestControllerTest" --tests "*.AdminQuestSetControllerTest"
```
9개 단위 테스트 + 4개 통합 테스트(퀘스트) + 5개 통합 테스트(관리자) 모두 통과해야 합니다.

---

## 3-7. 수동 검증 (기존 Node 백엔드와 비교)

```bash
./gradlew bootRun
```

```bash
# 로그인
TOKEN=$(curl -s -X POST localhost:3001/auth/login -H "Content-Type: application/json" \
  -d '{"email":"admin@okestro.com","password":"<관리자 비밀번호>"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

# 퀘스트셋 목록 조회
curl localhost:3001/quest-sets -H "Authorization: Bearer $TOKEN"

# 퀘스트 목록 조회 (id는 위 응답에서 확인)
curl localhost:3001/quest-sets/1/quests -H "Authorization: Bearer $TOKEN"

# 관리자용 퀘스트셋 목록 (accessUsers 포함)
curl localhost:3001/admin/quest-sets -H "Authorization: Bearer $TOKEN"

# 공개 여부 전환
curl -X PATCH localhost:3001/admin/quest-sets/1 -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"isPublic":false}'

# 접근 권한 부여/회수 (userId는 실제 대상 사용자 id로 교체)
curl -X POST localhost:3001/admin/quest-sets/1/access -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" -d '{"userId":2}'
curl -X DELETE localhost:3001/admin/quest-sets/1/access/2 -H "Authorization: Bearer $TOKEN"
```

기존 `backend/`(Node.js)와는 `data`/`meta`로 감싸진 형태와 `sandbox_type` → `sandboxType`,
`is_public` → `isPublic` 같은 필드명 표기가 다릅니다 — 값 자체와 필터링 결과(어떤 세트가 보이는지)가
동일한지 대조합니다.

---

## 완료 기준

- `QuestServiceTest`(단위, MockK) 9개 통과
- `QuestControllerTest`(통합, Testcontainers) 4개 + `AdminQuestSetControllerTest` 5개 통과
- `member` 토큰으로 비공개 세트의 퀘스트 목록 조회 시 403
- 관리자 토큰으로 공개 여부 전환/접근 권한 부여·회수 curl 검증에서 이후 `GET /quest-sets` 결과가
  즉시 반영됨
- `member` 토큰으로 `/admin/quest-sets` 및 그 하위 경로 호출 시 403

프론트엔드는 Step 1과 동일한 방침으로 이 Step에서 건드리지 않는다 (spec 문서의 "프론트엔드 연동
방침" 참고 — Step 10에서 일괄 전환).

다음은 Step 4 — `progress`/`feedback` (`QuestAttempt`/`Feedback` 엔티티, 집계 쿼리).
