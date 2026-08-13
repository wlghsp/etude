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
`quest_set_access` 테이블. 단, `quest_set`/`quest`에는 `created_at` 컬럼이 빠져 있는데
`QuestSet`/`Quest` 엔티티(3-0)가 `BaseEntity`(`id` + `created_at` 요구)를 상속하므로,
`00_schema.sql`에 두 테이블 모두 `user`/`quest_set_access`와 동일한 방식으로
`created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP`를 추가해야 한다 — 없으면
`ddl-auto: validate`가 "missing column [created_at]"로 애플리케이션 컨텍스트 로딩 자체를
실패시킨다. 시드 데이터가 없는 컬럼이라 마이그레이션 없이 로컬 DB를 재초기화(drop 후
`00_schema.sql`부터 재실행)하면 된다. 초기 데이터는 `01_sandbox.sql`, `02_quest_set.sql`,
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
채우는 방식으로 접근합니다. 레이어는 `domain/quest`(엔티티/포트/서비스) → `application/quest`
(Facade) → `infrastructure/persistence/quest`(어댑터) → `interfaces/api/quest`(사용자용/관리자용
컨트롤러 모두 이 패키지) → 인수 테스트 순으로 나갑니다. `UserRepository`, `ApiResponse<T>`,
`ApiControllerAdvice`, `AuthInterceptor`/`AdminInterceptor`는 Step 1~2에서 이미 만들어져 있으므로
재사용만 합니다.

---

## 3-0. 엔티티 3종 — `QuestSet`, `Quest`, `QuestSetAccess`

### `00_schema.sql` 수정 — `quest_set`/`quest`에 `created_at` 추가

엔티티를 작성하기 전에 스키마부터 맞춥니다. `apps/backend/src/main/resources/db/00_schema.sql`의
`quest_set`, `quest` 테이블에 `user`/`quest_set_access`와 동일한 컬럼을 추가합니다.

```sql
CREATE TABLE quest_set (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  title        VARCHAR(100) NOT NULL,
  description  TEXT,
  sandbox_type VARCHAR(20) NOT NULL DEFAULT 'linux',
  category     VARCHAR(50) NOT NULL DEFAULT '기타',
  is_public    BOOLEAN NOT NULL DEFAULT TRUE,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sandbox_type) REFERENCES sandbox(type)
);

CREATE TABLE quest (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  quest_set_id BIGINT NOT NULL,
  order_index  INT NOT NULL DEFAULT 0,
  title        VARCHAR(200) NOT NULL,
  description  TEXT NOT NULL,
  hint         TEXT,
  solution     TEXT,
  setup_cmd    JSON,
  grade_cmd    JSON NOT NULL,
  created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (quest_set_id) REFERENCES quest_set(id)
);
```

> `QuestSet`/`Quest`(아래)가 둘 다 `BaseEntity`(`modules/jpa`)를 상속하는데, `BaseEntity`는
> `id`와 `created_at` 두 컬럼을 전제합니다. `ddl-auto: validate`(`application.yaml`)는 시작
> 시점에 엔티티와 실제 테이블 컬럼을 비교하므로, 스키마에 `created_at`이 없으면
> `SchemaManagementException: missing column [created_at]`로 애플리케이션 컨텍스트 로딩
> 자체가 실패합니다. `quest_set_access`는 이미 `created_at`이 있으므로(3-0의 `QuestSetAccess`
> 절 참고) 건드리지 않습니다.
>
> 시드 데이터가 없는 컬럼 추가라 마이그레이션 스크립트 없이 로컬 DB를 재초기화(테이블 drop 후
> `00_schema.sql`부터 순서대로 재실행)하면 됩니다.

### `QuestSet` (`domain/quest/QuestSet.kt`)

`00_schema.sql`의 `quest_set` 테이블과 1:1 대응합니다. `sandbox_type`은 문자열로 그대로 두고 별도
enum을 만들지 않습니다 — `sandbox` 테이블의 `type`(PK, `VARCHAR`)을 참조하는 FK라 값의 종류가
`sandbox` 테이블 데이터에 의해 결정되고(Step 5에서 `SandboxConfig` 엔티티로 다룸), 지금 Kotlin
enum으로 하드코딩하면 나중에 `sandbox` 테이블에 새 타입이 추가될 때마다 코드도 함께 고쳐야 합니다.

```kotlin
package com.etude.domain.quest

import com.etude.domain.BaseEntity
import com.etude.domain.auth.UserSummary
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

    isPublic: Boolean = true,
) : BaseEntity() {
    @Column(name = "is_public", nullable = false)
    var isPublic: Boolean = isPublic
        protected set

    fun changePublic(value: Boolean) {
        isPublic = value
    }

    fun toAdminSummary(accessUsers: List<UserSummary>): QuestSetAdminSummary {
        return QuestSetAdminSummary(
            id = id,
            title = title,
            description = description,
            sandboxType = sandboxType,
            category = category,
            isPublic = isPublic,
            accessUsers = accessUsers,
        )
    }
}
```

> `isPublic`을 `var`로 열어두지 않고 `changePublic()` 메서드로 감싼 이유는 Step 2의 `User.name`/
> `password`와 동일합니다 — "공개 여부를 바꾼다"는 의도가 드러나는 진입점을 하나로 고정해두면,
> 나중에 "비공개로 바꿀 때 접근 권한 목록을 함께 정리한다" 같은 규칙이 생겨도 이 메서드 안에만
> 추가하면 됩니다. `User`와 동일하게 `protected set`으로 캡슐화합니다 — `@Entity` 클래스는
> `allOpen` 설정으로 자동 `open` 처리되므로, Hibernate 지연 로딩 프록시가 이 프로퍼티에
> 접근하려면 `private`이 아니라 `protected` 이상으로 열어둬야 합니다(Step 2의 2-0 참고).
>
> `toAdminSummary()`는 이 `QuestSet` 자신의 필드(`id`, `title`, `description`, `sandboxType`,
> `category`, `isPublic`)를 `QuestSetAdminSummary`로 옮기는 변환만 맡습니다. `accessUsers`는
> `questSetAccessRepository`/`userRepository` 조회 없이는 얻을 수 없는 값이라 엔티티가 직접
> 가져올 수 없으므로(엔티티가 리포지토리를 의존하면 도메인 → 인프라 방향 의존이 되어 레이어
> 역할이 깨집니다), 이미 조회된 값을 파라미터로 받기만 합니다.

### `QuestSet` 자체의 행동을 검증하는 `QuestSetTest`

`changePublic()`과 `toAdminSummary()`도 `User`와 마찬가지로 지금까지는 `QuestServiceTest`/
`QuestControllerTest`를 통해서만 간접적으로 실행되고 있었습니다. `QuestSet`은 `Spring`이나 DB
없이 순수 객체 생성만으로 검증 가능하므로, 엔티티 자체의 단위 테스트를 별도로 둡니다.

`src/test/kotlin/com/etude/domain/quest/QuestSetTest.kt`:

```kotlin
package com.etude.domain.quest

import com.etude.domain.auth.UserRole
import com.etude.domain.auth.UserSummary
import com.etude.support.TestQuestSets
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe

class QuestSetTest : FreeSpec({

    "공개 여부를 변경하면" - {
        "isPublic이 바뀐다" {
            val questSet = TestQuestSets.public(title = "리눅스 기초")

            questSet.changePublic(false)

            questSet.isPublic shouldBe false
        }
    }

    "관리자용 요약으로 변환하면" - {
        "자신의 필드와 전달받은 accessUsers를 그대로 담는다" {
            val questSet = TestQuestSets.private(title = "리눅스 기초", description = "설명")
            val accessUsers = listOf(UserSummary(1L, "멤버", "member@okestro.com", UserRole.member))

            val summary = questSet.toAdminSummary(accessUsers)

            summary.title shouldBe "리눅스 기초"
            summary.description shouldBe "설명"
            summary.isPublic shouldBe false
            summary.accessUsers shouldBe accessUsers
        }
    }
})
```

> `TestQuestSets`(3-6a)는 이 문서 뒤쪽에서 정의되지만, `QuestSet` 자체는 Spring이나 DB 없이
> 순수 객체로 만들어지므로 `public()`/`private()`처럼 저장을 거치지 않는 함수만 있으면 여기서도
> 바로 재사용할 수 있습니다. 구현 순서상 `TestQuestSets.kt`를 먼저 만들어두고 이 테스트를
> 작성해야 합니다.

> `toAdminSummary` 테스트가 `accessUsers`를 파라미터로 그냥 넘겨 받는 이유는, `QuestSet`이
> 리포지토리를 모르는 순수 엔티티라 "누가 접근 권한을 가졌는지"를 스스로 조회할 방법이 없기
> 때문입니다(위 각주 참고). 이 테스트는 "전달받은 값을 있는 그대로 담는지"만 확인하면 되고,
> 실제로 어떤 유저들이 조회되는지는 `QuestServiceTest.getQuestSetsForAdmin`(3-2)의 책임입니다.

**검증**: `./gradlew test --tests "*.QuestSetTest"` — 2개 테스트 모두 통과해야 합니다.

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

### `QuestSetAccess` — 단일 `id` PK + `(quest_set_id, user_id)` UNIQUE 제약

`quest_set_access`는 `id BIGINT AUTO_INCREMENT PRIMARY KEY`를 가지며, `(quest_set_id, user_id)`는
복합키가 아니라 `UNIQUE KEY uk_quest_set_access`로만 중복을 막습니다. 다른 엔티티와 마찬가지로
`BaseEntity`를 그대로 상속합니다.

`domain/quest/QuestSetAccess.kt`:

```kotlin
package com.etude.domain.quest

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest_set_access")
class QuestSetAccess(
    @Column(name = "quest_set_id", nullable = false)
    val questSetId: Long,

    @Column(name = "user_id", nullable = false)
    val userId: Long,
) : BaseEntity()
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
    fun save(access: QuestSetAccess): QuestSetAccess
    fun deleteByQuestSetIdAndUserId(questSetId: Long, userId: Long)
}
```

> `save()`가 `Unit`이 아니라 `QuestSetAccess`를 반환하는 이유는 다른 리포지토리(`QuestSetRepository.save(): QuestSet`)와 관례를 맞추기 위해서입니다 — JPA `save()`는 INSERT 시 DB가 채운 `id`(auto-increment)를 엔티티에 반영해 돌려주므로, 반환값을 버리면 저장된 레코드의 `id`를 알 방법이 없어집니다. 지금 `grantAccess`(3-2)는 저장된 값을 실제로 쓰지 않지만, 인터페이스 차원에서는 "저장 후 알 수 있는 정보를 버리지 않는다"는 관례를 지킵니다.

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
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
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
        questSet.changePublic(isPublic)
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
> 기존 `INSERT IGNORE`(중복을 에러 없이 무시)와 동일한 멱등성을 서비스 계층에서 명시적으로
> 재현하기 위해서입니다 — `QuestSetAccess(questSetId, userId)`는 매번 새 엔티티(PK `id` 미할당)를
> 만들므로 확인 없이 그대로 `save()`하면 `(quest_set_id, user_id)` UNIQUE 제약을 두 번째 호출에서
> 위반해 예외가 던져집니다.
> `revokeAccess`가 대상이 없어도 예외 없이 넘어가는 이유도 기존 `DELETE ... WHERE`(대상이 없으면
> 0 rows affected로 조용히 끝남)와 동일한 동작을 맞추기 위해서입니다.
>
> 클래스에 `@Transactional`을 붙인 이유는 `revokeAccess`가 호출하는
> `QuestSetAccessRepository.deleteByQuestSetIdAndUserId`가 내부적으로 Spring Data JPA의 파생
> 삭제 쿼리(`delete`)인데, 이 메서드는 트랜잭션 경계 밖에서 호출하면 `InvalidDataAccessApiUsageException`
> ("No EntityManager with actual transaction available for current thread")을 던지기 때문입니다.
> 조회(`findAll`, `existsBy...`)는 트랜잭션이 없어도 동작하지만, `save`/`delete`처럼 데이터를
> 바꾸는 메서드는 트랜잭션이 반드시 필요합니다. `setPublic`/`grantAccess`의 `save()`도 같은
> 이유로 트랜잭션이 필요하므로, 메서드마다 개별로 붙이지 않고 클래스 전체에 `@Transactional`을
> 걸어 모든 쓰기 메서드를 한 번에 커버합니다.

### 테스트로 검증 (`src/test/kotlin/com/etude/domain/quest/QuestServiceTest.kt`)

`canAccess`의 3분기를 각각 독립된 케이스로 명시합니다 — 이 부분이 이 Step에서 유일하게 "구현보다
테스트를 먼저 쓰는" 대상입니다(위 3-2 서두 참고). 나머지 메서드는 이미 구현되어 있으므로 뒤이어
검증만 합니다.

```kotlin
package com.etude.domain.quest

import com.etude.domain.auth.User
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import com.etude.support.TestQuests
import com.etude.support.TestQuestSets
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
                val publicSet = TestQuestSets.public()
                every { questSetRepository.findById(1L) } returns publicSet

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe true
            }
        }

        "비공개 세트라도" - {
            "관리자면 접근할 수 있다" {
                val privateSet = TestQuestSets.private()
                every { questSetRepository.findById(1L) } returns privateSet

                questService.canAccess(userId = 1L, role = UserRole.admin, questSetId = 1L) shouldBe true
            }

            "member는 개별 권한이 있어야 접근할 수 있다" {
                val privateSet = TestQuestSets.private()
                every { questSetRepository.findById(1L) } returns privateSet
                every { questSetAccessRepository.existsByQuestSetIdAndUserId(1L, 10L) } returns true

                questService.canAccess(userId = 10L, role = UserRole.member, questSetId = 1L) shouldBe true
            }

            "member가 개별 권한도 없으면 접근할 수 없다" {
                val privateSet = TestQuestSets.private()
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
                val publicSet = TestQuestSets.public()
                every { questSetRepository.findById(1L) } returns publicSet
                every { questRepository.findAllByQuestSetIdOrderByOrderIndex(1L) } returns listOf(
                    TestQuests.create(questSetId = 1L, title = "1번"),
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
                val questSet = TestQuestSets.public()
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
                every { questSetAccessRepository.save(any()) } returns QuestSetAccess(1L, 10L)

                questService.grantAccess(1L, 10L)

                verify(exactly = 1) { questSetAccessRepository.save(any()) }
            }
        }
    }
})
```

**검증**: `./gradlew test --tests "*.QuestServiceTest"` — 9개 테스트 모두 통과해야 합니다.

---

## 3-2a. `QuestFacade` — `interfaces`가 `domain`을 직접 호출하지 않는다

Step 0 설계(`docs/guides/guide_phase12_step0_setup.md`의 패키지 구조)는
`interfaces → application(Facade) → domain`으로 의존 방향을 잡았습니다. `application/`은 Facade,
Command, Info를 두는 레이어로 비워둔 채 시작했는데, Step 1(auth)과 Step 2(user/admin)에서
Controller가 `domain.*.XxxService`를 바로 주입받아 쓰면서 이 레이어를 채우지 못하고 지나갔습니다
— Step 3(Quest)부터 바로잡습니다. Step 1~2도 뒤이어 별도로 `AuthFacade`, `UserFacade`를 채워
넣습니다.

`QuestFacade`는 `QuestV1Controller`/`AdminQuestSetV1Controller`(3-5) 두 곳이 공유하는
진입점입니다. 지금 시점엔 `QuestService`의 메서드를 그대로 위임하는 것 이상의 로직이 없지만,
이 얇은 계층을 두는 이유는 **컨트롤러가 도메인 서비스를 직접 알지 않게** 하기 위해서입니다 —
나중에 "퀘스트셋 조회 시 진행률도 함께 내려준다"처럼 여러 도메인 서비스(`QuestService` +
`ProgressService`)를 조합해야 하는 요구가 생기면, 그 조합 로직은 `QuestFacade`에만 추가하면
되고 컨트롤러나 `QuestService`는 건드리지 않습니다. 지금 당장 조합할 다른 서비스가 없다고 해서
Facade를 생략하면, 나중에 그 조합이 필요해졌을 때 컨트롤러 코드에 여러 서비스 호출이 섞여
들어가거나 뒤늦게 레이어를 새로 끼워 넣어야 합니다.

`application/quest/QuestFacade.kt`:

```kotlin
package com.etude.application.quest

import com.etude.domain.auth.UserRole
import com.etude.domain.quest.QuestService
import com.etude.domain.quest.QuestSetAdminSummary
import com.etude.domain.quest.QuestSetSummary
import com.etude.domain.quest.QuestSummary
import org.springframework.stereotype.Component

@Component
class QuestFacade(
    private val questService: QuestService,
) {
    fun getQuestSets(userId: Long, role: UserRole): List<QuestSetSummary> =
        questService.getQuestSets(userId, role)

    fun getQuests(userId: Long, role: UserRole, questSetId: Long): List<QuestSummary> =
        questService.getQuests(userId, role, questSetId)

    fun getQuestSetsForAdmin(): List<QuestSetAdminSummary> =
        questService.getQuestSetsForAdmin()

    fun setPublic(questSetId: Long, isPublic: Boolean) {
        questService.setPublic(questSetId, isPublic)
    }

    fun grantAccess(questSetId: Long, userId: Long) {
        questService.grantAccess(questSetId, userId)
    }

    fun revokeAccess(questSetId: Long, userId: Long) {
        questService.revokeAccess(questSetId, userId)
    }
}
```

> `canAccess`는 위임하지 않습니다 — 이건 `QuestService.getQuests` 내부에서만 쓰이는 private한
> 접근 제어 판단이라(3-2 참고), 컨트롤러나 Facade가 직접 호출할 일이 없습니다. Facade에 그대로
> 노출하면 "이 메서드를 컨트롤러에서 호출해도 되는 건가?"라는 불필요한 판단을 호출부에 떠넘기게
> 됩니다.
>
> 지금은 각 메서드가 단순 위임(1줄)이라 "왜 굳이 이 계층을 두는가"라는 의문이 들 수 있습니다.
> 답은 코딩 가이드라인의 "3. Surgical Changes"가 아니라 Step 0에서 이미 확정한 레이어 규칙을
> 따르는 것입니다 — 이 얇음 자체가 문제가 아니라 정상입니다. Facade가 조합 로직을 갖게 되는
> 시점은 실제로 여러 도메인 서비스를 엮어야 하는 요구가 생겼을 때뿐입니다.
>
> 테스트는 따로 만들지 않습니다 — `QuestFacade`는 위임 외 로직이 없고, `QuestService`가 이미
> `QuestServiceTest`로 검증되어 있으므로 같은 케이스를 Facade 레벨에서 mockk로 다시 확인하는 건
> 검증 없는 중복입니다. Facade에 실제 로직(조합, 트랜잭션 경계 등)이 추가되는 시점에 그 로직만
> 테스트를 씁니다.

---

## 3-3. 어댑터 구현 — `infrastructure/persistence/quest`

**이 Step만 QueryDSL 실험.** 대부분의 리포지토리 메서드(`findById`, `existsByQuestSetIdAndUserId`,
`findAllByQuestSetIdOrderByOrderIndex` 등)는 Spring Data JPA의 메서드 이름 파생 쿼리로 충분히
표현되므로 그대로 둡니다. 다만 `findAllPublicOrAccessibleBy`(`isPublic = true OR EXISTS(...)`)는
메서드 이름으로 표현할 수 없어 지금까지는 JPQL 문자열(`@Query`)로 짜야 했는데, 이런 동적/복잡
조건을 다루는 용도로 QueryDSL을 도입합니다 — 문자열 JPQL은 컴파일 시점에 오타나 필드명 변경을
잡아주지 못하지만, QueryDSL은 컴파일된 `Q타입`(`QQuestSet`, `QQuestSetAccess`)을 통해 타입
세이프하게 같은 쿼리를 표현합니다. `QuestService`, 포트 인터페이스(`QuestSetRepository` 등)는
그대로이고 어댑터 구현 방식만 바뀝니다.

### QueryDSL gradle 설정

Kotlin에서 QueryDSL이 엔티티로부터 `Q타입`(`QQuestSet` 등)을 생성하려면 애노테이션 프로세서가
필요합니다. QueryDSL은 아직 KSP를 공식 지원하지 않으므로 `kapt`를 씁니다.

`apps/backend`, `modules/jpa` 둘 다 `@Entity`/`@MappedSuperclass`를 가지므로(`QuestSet` 등은
`apps/backend`에, `BaseEntity`는 `modules/jpa`에 있음) 두 모듈 모두 kapt가 필요합니다. kapt는
모듈 경계를 넘어 소스를 함께 스캔하지 않으므로 — 각 모듈은 자신의 소스에 있는
`@Entity`/`@MappedSuperclass`만 보고 그 모듈의 `build/generated/source/kapt/main`에 자기 몫의
Q타입을 생성합니다. `modules/jpa`에 kapt가 없으면 `BaseEntity`의 `QBaseEntity`가 만들어지지
않고, `apps/backend`에서 생성된 `QUser`/`QQuestSet`(모두 `BaseEntity`를 상속)이 자신의 부모
Q타입을 참조하다 `cannot find symbol` 컴파일 에러가 납니다.

두 모듈에 각각 명시적으로 선언합니다 — 루트 `build.gradle.kts`의 `subprojects { }`(allOpen 등
JPA 쓰는 모듈이면 예외 없이 필요한 필수 설정을 모아두는 곳)에 얹는 방법도 있지만, QueryDSL은
이 Step에서 Quest 도메인에 국한해 실험해보는 선택적 도구입니다. 루트에 두면 "JPA를 쓰는 모든
서브모듈이 앞으로도 자동으로 QueryDSL을 갖는다"는 걸 프로젝트 전체 규칙으로 못박게 되므로,
지금은 실제로 QueryDSL이 필요한 두 모듈에만 적는 편이 "이 프로젝트가 QueryDSL을 어디서 쓰는지"를
파일만 보고 알 수 있어 낫습니다.

> `apps/backend`가 이미 `springdoc-openapi-starter-webmvc-ui`(Step 1)를 쓰고 있는데,
> Step 1에서 이 의존성을 `2.7.0`으로 명시해둔 이유가 여기서 드러납니다. springdoc `2.6.0`은
> 클래스패스에 QueryDSL(`querydsl-jpa`)이 있으면 API 파라미터 자동 문서화용 빈
> (`QuerydslPredicateOperationCustomizer`)을 `@ConditionalOnClass`로 자동 생성하는데, 이 빈이
> 참조하는 `spring-data-commons`의 `TypeInformation` 클래스를 로드하는 데 실패해
> `ClassNotFoundException` → 애플리케이션 컨텍스트 로딩 실패로 이어집니다. 이 프로젝트는
> QueryDSL을 `JPAQueryFactory`로 직접 짜는 용도로만 쓰고 springdoc의 자동 파라미터 바인딩
> 기능은 쓰지 않으므로, 이 충돌은 QueryDSL 자체의 문제가 아니라 springdoc `2.6.0`이 최신
> Spring Boot(4.1)의 `spring-data-commons`와 어긋나는 버전 문제입니다. `springdoc-openapi`를
> `2.7.0`(또는 그 이상)으로 올리면 해결됩니다 — Step 1에서 이미 `2.7.0`으로 시작했다면 Step 3에
> 와서 이 문제를 겪지 않습니다.

`apps/backend/build.gradle.kts`:

```kotlin
plugins {
    kotlin("plugin.jpa")
    kotlin("kapt")
    id("org.springframework.boot")
}

dependencies {
    implementation(project(":modules:jpa"))

    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    // ... 기존 의존성 유지

    // QueryDSL
    implementation("com.querydsl:querydsl-jpa:5.1.0:jakarta")
    kapt("com.querydsl:querydsl-apt:5.1.0:jakarta")
    kapt("jakarta.annotation:jakarta.annotation-api")
    kapt("jakarta.persistence:jakarta.persistence-api")
}
```

`modules/jpa/build.gradle.kts`:

```kotlin
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
```

> `querydsl-jpa`에 `:jakarta` classifier를 붙인 이유는 이 프로젝트가 `javax.persistence`가 아닌
> `jakarta.persistence`(Spring Boot 4.x 기준)를 쓰기 때문입니다 — classifier 없는 아티팩트는
> 구버전 `javax` 패키지를 기준으로 빌드되어 있어 섞이지 않습니다. `kapt`가 `@Entity`/
> `@MappedSuperclass`를 스캔해 각 모듈의 `build/generated/source/kapt/main`에 Q타입을 자동
> 생성하므로, 이후 어댑터 코드에서 별도 설정 없이 `import` 해서 씁니다.

`JPAQueryFactory`를 스프링 빈으로 등록합니다. `WebConfig`(Step 1~2에서 만든 `AuthInterceptor`/
`AdminInterceptor` 등록용 설정 클래스)와 동일하게 `config` 패키지(도메인/인프라 어디에도
속하지 않는 앱 전역 설정)에 둡니다.

`config/QuerydslConfig.kt`:

```kotlin
package com.etude.config

import com.querydsl.jpa.impl.JPAQueryFactory
import jakarta.persistence.EntityManager
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class QuerydslConfig(
    private val entityManager: EntityManager,
) {
    @Bean
    fun jpaQueryFactory(): JPAQueryFactory = JPAQueryFactory(entityManager)
}
```

**검증**: `./gradlew :modules:jpa:kaptKotlin :apps:backend:kaptKotlin`을 실행해
`modules/jpa/build/generated/source/kapt/main/com/etude/domain/QBaseEntity.java`와
`apps/backend/build/generated/source/kapt/main/com/etude/domain/quest/QQuestSet.java` 등이
각각 생성되는지 확인.

### `QuestSetJpaRepository.kt`, `QuestSetRepositoryImpl.kt`

`findAllPublicOrAccessibleBy`를 JPQL 문자열 대신 QueryDSL로 옮기므로, `QuestSetJpaRepository`
에는 더 이상 이 메서드를 선언하지 않습니다 — `QuestSetRepositoryImpl`이 `JPAQueryFactory`를 직접
써서 구현합니다.

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSet
import org.springframework.data.jpa.repository.JpaRepository

interface QuestSetJpaRepository : JpaRepository<QuestSet, Long>
```

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSet
import org.springframework.data.jpa.repository.JpaRepository

interface QuestSetJpaRepository : JpaRepository<QuestSet, Long>
```

QueryDSL로 짜는 `findAllPublicOrAccessibleBy`는 상속(예: `QuestSetRepositoryCustom`을
`QuestSetJpaRepository`가 구현하는 Spring Data 관용 패턴)으로 엮지 않고, 완전히 독립된 클래스
`QuestSetQuerydslRepository`로 분리합니다. `QuestSetRepositoryImpl`(포트 어댑터)이 이 클래스를
필드로 주입받아 필요할 때 위임하는 합성(composition) 구조입니다 — 상속 계층에 끼워 넣지 않으므로
`QuestSetQuerydslRepository`는 QueryDSL만 알면 되고, `QuestSetJpaRepository`/`JpaRepository`는
이 클래스의 존재를 몰라도 됩니다.

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QQuestSet.questSet
import com.etude.domain.quest.QQuestSetAccess.questSetAccess
import com.etude.domain.quest.QuestSet
import com.querydsl.jpa.JPAExpressions
import com.querydsl.jpa.impl.JPAQueryFactory
import org.springframework.stereotype.Repository

@Repository
class QuestSetQuerydslRepository(
    private val queryFactory: JPAQueryFactory,
) {
    fun findAllPublicOrAccessibleBy(userId: Long): List<QuestSet> =
        queryFactory
            .selectFrom(questSet)
            .where(
                questSet.isPublic.isTrue
                    .or(
                        JPAExpressions
                            .selectOne()
                            .from(questSetAccess)
                            .where(
                                questSetAccess.questSetId.eq(questSet.id),
                                questSetAccess.userId.eq(userId),
                            )
                            .exists()
                    )
            )
            .fetch()
}
```

> `JPAExpressions.selectOne().from(...).where(...).exists()`가 기존 JPQL의
> `EXISTS (SELECT 1 FROM QuestSetAccess qsa WHERE ...)` 서브쿼리와 동일한 표현입니다. Q타입
> 필드(`questSet.isPublic`, `questSetAccess.questSetId`)를 통해 컬럼명을 문자열이 아니라
> 컴파일 타임에 검증된 참조로 다루므로, 예를 들어 `QuestSet`에 컬럼을 리네이밍하면 이 쿼리는
> 컴파일 에러로 바로 드러납니다 — 문자열 JPQL이었다면 런타임까지 발견되지 않았을 실수입니다.
> "관리자면 전부" 조건이 여기 없는 이유는 3-1에서 설명한 대로 `QuestService`가 role을 보고 이
> 메서드 자체를 호출할지 말지 결정하기 때문입니다.

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSet
import com.etude.domain.quest.QuestSetRepository
import org.springframework.stereotype.Repository

@Repository
class QuestSetRepositoryImpl(
    private val jpaRepository: QuestSetJpaRepository,
    private val querydslRepository: QuestSetQuerydslRepository,
) : QuestSetRepository {
    override fun findById(id: Long): QuestSet? = jpaRepository.findById(id).orElse(null)

    override fun findAllPublicOrAccessibleBy(userId: Long): List<QuestSet> =
        querydslRepository.findAllPublicOrAccessibleBy(userId)

    override fun findAll(): List<QuestSet> = jpaRepository.findAll()
    override fun save(questSet: QuestSet): QuestSet = jpaRepository.save(questSet)
}
```

> `findById`/`findAll`/`save`는 QueryDSL이 필요 없는 단순 CRUD라 `JpaRepository`를 그대로
> 씁니다 — 모든 메서드를 QueryDSL로 바꾸는 게 목적이 아니라, 복잡한 조건이 실제로 필요한
> 지점에서만 씁니다. `QuestSetRepositoryImpl`은 포트(`QuestSetRepository`)를 구현하는 책임만
> 지고, "이 메서드는 JPA로 짜는지 QueryDSL로 짜는지"는 각 협력자(`jpaRepository`,
> `querydslRepository`)에게 위임합니다 — 어댑터 자신은 어느 기술로 구현됐는지 몰라도 됩니다.

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

다른 엔티티와 동일하게 `BaseEntity`의 단일 `id`(`Long`)를 두 번째 타입 파라미터로 씁니다.

```kotlin
package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSetAccess
import org.springframework.data.jpa.repository.JpaRepository

interface QuestSetAccessJpaRepository : JpaRepository<QuestSetAccess, Long> {
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
    override fun save(access: QuestSetAccess): QuestSetAccess = jpaRepository.save(access)
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
import jakarta.servlet.http.HttpServletRequest

@Tag(name = "Quest V1 API", description = "퀘스트/퀘스트셋 조회 API 입니다.")
interface QuestV1ApiSpec {
    @Operation(summary = "퀘스트셋 목록 조회", description = "로그인한 사용자가 접근 가능한 퀘스트셋 목록을 조회합니다.")
    fun getQuestSets(httpRequest: HttpServletRequest): ApiResponse<List<QuestSetSummary>>

    @Operation(summary = "퀘스트 목록 조회", description = "지정한 퀘스트셋에 속한 퀘스트 목록을 순서대로 조회합니다.")
    fun getQuests(questSetId: Long, httpRequest: HttpServletRequest): ApiResponse<List<QuestSummary>>
}
```

```kotlin
package com.etude.interfaces.api.quest

import com.etude.application.quest.QuestFacade
import com.etude.domain.auth.JwtPayload
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
    private val questFacade: QuestFacade,
) : QuestV1ApiSpec {
    @GetMapping("/quest-sets")
    override fun getQuestSets(httpRequest: HttpServletRequest): ApiResponse<List<QuestSetSummary>> {
        val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
        return ApiResponse.success(questFacade.getQuestSets(payload.userId, payload.role))
    }

    @GetMapping("/quest-sets/{questSetId}/quests")
    override fun getQuests(
        @PathVariable questSetId: Long,
        httpRequest: HttpServletRequest,
    ): ApiResponse<List<QuestSummary>> {
        val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
        return ApiResponse.success(questFacade.getQuests(payload.userId, payload.role, questSetId))
    }
}
```

> `QuestV1ApiSpec`의 두 메서드가 `httpRequest: HttpServletRequest`를 파라미터로 갖는 이유는
> Kotlin의 `override`가 시그니처를 완전히 일치시켜야 하기 때문입니다 — `QuestV1Controller`
> 구현체가 `HttpServletRequest`를 받아 `JwtPayload`를 꺼내 쓰므로, 인터페이스에도 동일한
> 파라미터가 있어야 오버라이드가 성립합니다. Step 2의 `MeV1ApiSpec.changePassword`와 동일한
> 패턴입니다.
>
> `/quest-sets`, `/quest-sets/**`는 이미 Step 1의 `WebConfig`에서 `AuthInterceptor`가
> `addPathPatterns`에 등록해뒀으므로(1-7 참고), 토큰 없이 호출하면 컨트롤러에 도달하기 전에
> 401로 막힙니다.

### 3-5b. `interfaces/api/quest/AdminQuestSetV1ApiSpec.kt`, `AdminQuestSetV1Controller.kt`

```kotlin
package com.etude.interfaces.api.quest

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
package com.etude.interfaces.api.quest

import com.etude.application.quest.QuestFacade
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
    private val questFacade: QuestFacade,
) : AdminQuestSetV1ApiSpec {
    @GetMapping
    override fun getQuestSets(): ApiResponse<List<QuestSetAdminSummary>> =
        ApiResponse.success(questFacade.getQuestSetsForAdmin())

    @PatchMapping("/{id}")
    override fun setPublic(@PathVariable id: Long, @Valid @RequestBody request: SetPublicRequest): ApiResponse<Unit> {
        questFacade.setPublic(id, request.isPublic)
        return ApiResponse.success<Unit>()
    }

    @PostMapping("/{id}/access")
    override fun grantAccess(@PathVariable id: Long, @Valid @RequestBody request: GrantAccessRequest): ApiResponse<Unit> {
        questFacade.grantAccess(id, request.userId)
        return ApiResponse.success<Unit>()
    }

    @DeleteMapping("/{id}/access/{userId}")
    override fun revokeAccess(@PathVariable id: Long, @PathVariable userId: Long): ApiResponse<Unit> {
        questFacade.revokeAccess(id, userId)
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

### 3-6a. 공통 테스트 헬퍼 — `TestAuth`, `TestUsers`, `TestQuestSets`

`AuthControllerTest`(Step 1), `UserAdminControllerTest`(Step 2)에 이어 이 Step의 두 통합 테스트도
"로그인해서 토큰을 받는다", "admin/member 계정을 만든다", "공개/비공개 퀘스트셋을 만든다"는 절차를
반복합니다. 세 번째 테스트부터 같은 코드를 또 복붙하는 대신 `support` 패키지에 공통 헬퍼로
뽑아둡니다.

**로그인/유저 생성/퀘스트셋 생성 헬퍼는 `IntegrationTest`가 아니라 독립 오브젝트(`TestAuth`,
`TestUsers`, `TestQuestSets`)로 둡니다** — `IntegrationTest`는 "Testcontainers로 통합 테스트
환경을 어떻게 띄우는가"만 책임지는 클래스입니다. 로그인 흐름이나 테스트 데이터 생성은 그와 다른
관심사라, 같은 클래스에 얹으면 책임이 섞입니다. 세 오브젝트 모두 `IntegrationTest`를 몰라도 되는
순수 헬퍼로 설계합니다.

`src/test/kotlin/com/etude/support/TestAuth.kt`:

```kotlin
package com.etude.support

import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post

object TestAuth {
    // 여러 ControllerTest(AuthControllerTest, UserAdminControllerTest, QuestControllerTest 등)가
    // "로그인해서 토큰을 받아온다"는 동일한 절차를 반복하므로 여기 한 곳에서 관리한다.
    fun loginAndGetToken(mockMvc: MockMvc, email: String, password: String): String {
        val response = mockMvc.perform(
            post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"email":"$email","password":"$password"}""")
        ).andReturn().response.contentAsString
        return Regex(""""token":"([^"]+)"""").find(response)!!.groupValues[1]
    }
}
```

**유저 픽스처(`TestUsers`)는 Step 2(2-0)에서 이미 만들어뒀습니다** — `User` 캡슐화 직후,
`UserTest`(Step 2)가 필요한 시점에 미리 뽑아둔 것을 여기서도 그대로 재사용합니다. 새로 만들
필요 없이 `import com.etude.support.TestUsers`만 하면 됩니다.

**퀘스트셋 픽스처는 `TestQuestSets` 오브젝트로 뽑습니다** — `QuestSet(title = "공개 세트",
description = null, sandboxType = "linux", category = "리눅스", isPublic = true)`처럼 필드 5개짜리
생성자 호출이 `QuestControllerTest`, `AdminQuestSetControllerTest` 양쪽에 반복됩니다. `TestUsers`와
동일하게 named argument + default parameter로 필요한 값만 오버라이드하게 합니다.

`src/test/kotlin/com/etude/support/TestQuestSets.kt`:

```kotlin
package com.etude.support

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository

object TestQuestSets {
    fun public(
        title: String = "공개 세트",
        description: String? = null,
        sandboxType: String = "linux",
        category: String = "리눅스",
    ): QuestSet = QuestSet(title = title, description = description, sandboxType = sandboxType, category = category, isPublic = true)

    fun private(
        title: String = "비공개 세트",
        description: String? = null,
        sandboxType: String = "linux",
        category: String = "리눅스",
    ): QuestSet = QuestSet(title = title, description = description, sandboxType = sandboxType, category = category, isPublic = false)

    fun createPublic(
        questSetJpaRepository: QuestSetJpaRepository,
        title: String = "공개 세트",
        description: String? = null,
        sandboxType: String = "linux",
        category: String = "리눅스",
    ): QuestSet = questSetJpaRepository.save(public(title, description, sandboxType, category))

    fun createPrivate(
        questSetJpaRepository: QuestSetJpaRepository,
        title: String = "비공개 세트",
        description: String? = null,
        sandboxType: String = "linux",
        category: String = "리눅스",
    ): QuestSet = questSetJpaRepository.save(private(title, description, sandboxType, category))
}
```

> `isPublic`만 다르고 나머지 필드가 똑같은 메서드를 `public`/`private`(순수 생성)과
> `createPublic`/`createPrivate`(생성 + 저장) 두 켤레로 나눈 이유는, `isPublic: Boolean`
> 파라미터 하나로 통합하면 호출부에서 `TestQuestSets.create(..., isPublic = true)`처럼 매번
> 의도를 다시 적어야 하기 때문입니다. 메서드 이름 자체가 "공개 세트인지 비공개 세트인지"를
> 드러내면 테스트 코드를 읽을 때 별도로 `isPublic` 값을 눈으로 확인할 필요가 없습니다.
>
> `public()`/`private()`가 따로 있는 이유는 `TestUsers.admin()`/`member()`와 동일합니다 —
> `createPublic`/`createPrivate`는 `QuestSetJpaRepository`가 필요해 `IntegrationTest`에서만
> 쓸 수 있고, `QuestSetTest`(Spring/DB 없이 순수 `QuestSet` 객체만 다루는 단위 테스트)에서는
> 저장 없이 객체만 만드는 `public()`/`private()`가 있어야 픽스처를 재사용할 수 있습니다.

**퀘스트 픽스처는 `TestQuests` 오브젝트로 뽑습니다** — `Quest(questSetId = publicSet.id,
orderIndex = 0, title = "1번 퀘스트", description = "설명", hint = null, solution = null, setupCmd
= null, gradeCmd = "[]")`처럼 필드 8개짜리 생성자 호출입니다. `QuestControllerTest`에는 지금
하나뿐이지만, 퀘스트 목록/순서 검증 테스트가 늘어나면 바로 반복될 후보이므로 처음부터 뽑아둡니다.

`src/test/kotlin/com/etude/support/TestQuests.kt`:

```kotlin
package com.etude.support

import com.etude.domain.quest.Quest
import com.etude.infrastructure.persistence.quest.QuestJpaRepository

object TestQuests {
    fun create(
        questSetId: Long,
        orderIndex: Int = 0,
        title: String = "1번 퀘스트",
        description: String = "설명",
        hint: String? = null,
        solution: String? = null,
        setupCmd: String? = null,
        gradeCmd: String = "[]",
    ): Quest = Quest(
        questSetId = questSetId,
        orderIndex = orderIndex,
        title = title,
        description = description,
        hint = hint,
        solution = solution,
        setupCmd = setupCmd,
        gradeCmd = gradeCmd,
    )

    fun createAndSave(
        questJpaRepository: QuestJpaRepository,
        questSetId: Long,
        orderIndex: Int = 0,
        title: String = "1번 퀘스트",
        description: String = "설명",
        hint: String? = null,
        solution: String? = null,
        setupCmd: String? = null,
        gradeCmd: String = "[]",
    ): Quest = questJpaRepository.save(create(questSetId, orderIndex, title, description, hint, solution, setupCmd, gradeCmd))
}
```

> `TestUsers`/`TestQuestSets`와 동일하게 순수 생성(`create`)과 저장(`createAndSave`)을
> 나눕니다 — `QuestServiceTest`(3-2)처럼 mockk만으로 동작하는 순수 단위 테스트는
> `QuestJpaRepository`가 없어도 `Quest` 객체가 필요하고, `QuestControllerTest`(3-6)처럼 실제
> DB에 넣어야 하는 통합 테스트는 저장까지 하는 함수가 필요하기 때문입니다.

> `TestQuestSets`와 달리 `questSetId`에는 기본값을 주지 않습니다 — 어느 퀘스트셋에 속한 퀘스트인지는
> 테스트 시나리오마다 다르고(`publicSet.id`인지 `privateSet.id`인지), 잘못된 기본값을 실수로
> 그대로 쓰면 "의도한 세트와 다른 세트에 퀘스트가 생기는" 오류가 조용히 발생할 수 있기 때문입니다.
> 필수 파라미터로 남겨 호출부가 항상 명시하게 강제합니다.

`src/test/kotlin/com/etude/interfaces/api/quest/QuestControllerTest.kt`

```kotlin
package com.etude.interfaces.api.quest

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import com.etude.support.TestAuth
import com.etude.support.TestQuestSets
import com.etude.support.TestQuests
import com.etude.support.TestUsers
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
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

    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    lateinit var publicSet: QuestSet
    lateinit var privateSet: QuestSet

    beforeTest {
        questJpaRepository.deleteAll()
        questSetJpaRepository.deleteAll()
        userJpaRepository.deleteAll()

        TestUsers.createAdmin(userJpaRepository)
        TestUsers.createMember(userJpaRepository)
        publicSet = TestQuestSets.createPublic(questSetJpaRepository)
        privateSet = TestQuestSets.createPrivate(questSetJpaRepository)
        TestQuests.createAndSave(questJpaRepository, questSetId = publicSet.id)
    }

    "퀘스트셋 목록을 조회하면" - {
        "공개 세트만 보인다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(get("/quest-sets").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].title").value("공개 세트"))
        }
    }

    "공개 세트의 퀘스트 목록을 조회하면" - {
        "순서대로 반환된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(get("/quest-sets/${publicSet.id}/quests").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].title").value("1번 퀘스트"))
        }
    }

    "비공개 세트의 퀘스트 목록을 조회하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

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

> `beforeTest`가 `TestUsers.createAdmin`도 호출하는 이유는, 이 Step의 다른 테스트
> (`AdminQuestSetControllerTest`)와 달리 `QuestControllerTest` 자체는 admin 계정을 쓰지
> 않지만, `AuthInterceptor`/`AdminInterceptor`가 role 기반으로 분기하는 걸 감안해 "member만
> 존재하는 상태"보다 "admin과 member가 공존하는 상태"에서 사용자용 API가 올바르게 동작하는지
> 확인하는 편이 더 현실적인 시나리오이기 때문입니다.
>
> `MockMvcRequestBuilders.post`, `MediaType`, `BCryptPasswordEncoder`, `User`/`UserRole` import가
> 이 파일에서 사라진 걸 확인하세요 — 로그인/유저 생성 로직이 헬퍼로 옮겨가면서 이 테스트
> 파일에서는 더 이상 직접 쓰지 않습니다. `AutoConfigureMockMvc`의 import 경로는 Spring Boot
> 3.5.x 기준 `org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc`
> 입니다.

`src/test/kotlin/com/etude/interfaces/api/quest/AdminQuestSetControllerTest.kt`

```kotlin
package com.etude.interfaces.api.quest

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetAccessJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.IntegrationTest
import com.etude.support.TestAuth
import com.etude.support.TestQuestSets
import com.etude.support.TestUsers
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.MockMvc
import kotlin.properties.Delegates

@AutoConfigureMockMvc
class AdminQuestSetControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questSetAccessJpaRepository: QuestSetAccessJpaRepository,
) : IntegrationTest({

    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    lateinit var privateSet: QuestSet
    var memberId: Long by Delegates.notNull()

    beforeTest {
        questSetAccessJpaRepository.deleteAll()
        questSetJpaRepository.deleteAll()
        userJpaRepository.deleteAll()

        TestUsers.createAdmin(userJpaRepository)
        val member = TestUsers.createMember(userJpaRepository)
        memberId = member.id
        privateSet = TestQuestSets.createPrivate(questSetJpaRepository)
    }
```

> `memberId`는 `lateinit`을 못 씁니다 — `lateinit`은 "초기화 전엔 null"이라는 상태를 내부적으로
> 표현해야 하는데, `Long`(JVM 원시 타입 `long`)은 애초에 null을 담을 수 없어 이 메커니즘 자체가
> 성립하지 않습니다(`QuestSet`처럼 참조 타입에는 문제없이 쓰입니다). 대신
> `kotlin.properties.Delegates.notNull()`을 쓰면 `lateinit`과 동일하게 "초기화 전에 읽으면
> 예외"라는 동작을 원시 타입에도 적용할 수 있습니다.

```kotlin
    "관리자가 퀘스트셋 목록을 조회하면" - {
        "isPublic과 accessUsers를 포함해 전체가 보인다" {
            val token = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)

            mockMvc.perform(get("/admin/quest-sets").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].isPublic").value(false))
                .andExpect(jsonPath("$.data[0].accessUsers").isArray)
        }
    }

    "member 권한으로 조회를 시도하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(get("/admin/quest-sets").header("Authorization", "Bearer $token"))
                .andExpect(status().isForbidden)
        }
    }

    "관리자가 퀘스트셋을 공개로 전환하면" - {
        "member도 목록에서 볼 수 있게 된다" {
            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)

            mockMvc.perform(
                patch("/admin/quest-sets/${privateSet.id}")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"isPublic":true}""")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)
            mockMvc.perform(get("/quest-sets").header("Authorization", "Bearer $memberToken"))
                .andExpect(jsonPath("$.data.length()").value(1))
        }
    }

    "관리자가 접근 권한을 부여하면" - {
        "해당 사용자가 비공개 세트를 볼 수 있게 된다" {
            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)

            mockMvc.perform(
                post("/admin/quest-sets/${privateSet.id}/access")
                    .header("Authorization", "Bearer $adminToken")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"userId":$memberId}""")
            ).andExpect(status().isOk)

            val memberToken = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)
            mockMvc.perform(get("/quest-sets/${privateSet.id}/quests").header("Authorization", "Bearer $memberToken"))
                .andExpect(status().isOk)
        }
    }

    "관리자가 접근 권한을 회수하면" - {
        "해당 사용자가 다시 접근할 수 없게 된다" {
            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
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

            val memberToken = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)
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

> `AuthControllerTest`(Step 1)는 `TestUsers`/`TestAuth`를 쓰지 않고 원래 방식(자체
> 계정 직접 생성, 로그인 응답을 직접 파싱)을 유지합니다 — 로그인 자체가 이 테스트의 검증
> 대상이므로, 공통 헬퍼로 감싸면 정작 테스트하려는 로직이 헬퍼 뒤에 숨어버립니다. 반면
> `UserAdminControllerTest`(Step 2)는 이 Step처럼 로그인은 "전제 조건"일 뿐이라 헬퍼를
> 그대로 씁니다 — Step 2 가이드로 돌아가 이 변경을 반영해뒀는지 확인하세요.

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
