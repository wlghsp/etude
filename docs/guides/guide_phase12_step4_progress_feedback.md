# Phase 12 Step 4 — progress/feedback (진행률, 리더보드, 피드백)

명세: [specs/spec_phase12_kotlin_migration.md](../specs/spec_phase12_kotlin_migration.md)
이전 Step: [guide_phase12_step3_quest.md](guide_phase12_step3_quest.md)

대응하는 기존 Node.js 파일: `backend/src/services/progress.ts`(`getProgress`, `getLeaderboard` —
`recordAttempt`는 이 Step 범위가 아니다, 아래 참고), `backend/src/routes/progress.routes.ts`
(`GET /progress`, `GET /leaderboard`), `backend/src/services/feedback.ts`(`createFeedback`,
`getFeedbackList`), `backend/src/routes/feedback.routes.ts`(`POST /feedback`),
`backend/src/routes/admin.routes.ts`(`GET /admin/feedback`만 — 나머지 admin 라우트는 Step 2/3에서
이미 다룸).

`recordAttempt`(퀘스트 시도 기록 INSERT)는 이 Step 범위가 아니다 — Step 7(채점)에서
`POST /grade`가 채점 결과를 저장할 때 호출하는 함수라, 그때 `QuestService`(또는 별도
`GradingService`)에 구현한다. 이 Step에서는 `QuestAttempt` **엔티티와 리포지토리만** 만든다 —
`getProgress`/`getLeaderboard`의 집계 쿼리가 이미 있는 `quest_attempt` 테이블을 읽어야 하기
때문이다. 즉 이 Step이 끝나도 `quest_attempt`에는 아직 아무도 INSERT하지 않는다 — 통합 테스트가
직접 리포지토리로 시드를 넣어 집계 로직만 검증한다.

DB 스키마는 `apps/backend/src/main/resources/db/00_schema.sql`의 `quest_attempt`, `feedback`
테이블. 이미 존재하고, 컬럼도 갖춰져 있어(Step 3까지와 달리) `created_at` 추가 같은 스키마 수정은
필요 없다. 다만 `quest_attempt`는 시각 컬럼명이 `attempted_at`이라 `BaseEntity`(`created_at`을
전제)를 그대로 상속하면 컬럼명이 안 맞는다 — 4-0에서 `@AttributeOverride`로 해결한다.

**경로 표기 안내**는 Step 1과 동일합니다 — `domain/progress/QuestAttempt.kt`처럼 쓰는 경로는
`backend-kotlin/apps/backend/src/main/kotlin/com/etude/domain/progress/QuestAttempt.kt`를
가리킵니다. `feedback`은 `progress`와 다른 도메인 패키지(`domain/feedback`)로 분리합니다 —
진행률/리더보드와 피드백은 서로 참조하지 않는 별개 기능이라 패키지를 섞을 이유가 없습니다.

## 인수 조건 (이 Step의 완료 기준)

*Node.js 원본(`progress.ts`, `progress.routes.ts`, `feedback.ts`, `feedback.routes.ts`,
`admin.routes.ts`의 `/admin/feedback`)의 실제 동작이 곧 인수 조건이다. 응답 포맷은 Step 1에서
도입한 `ApiResponse<T>` 공통 래퍼를 그대로 따른다.*

**내 진행률 조회 (`GET /progress`)**
- [ ] 로그인한 사용자가 호출 시 200 + 퀘스트셋별 진행률 배열
      `{ questSetId, title, category, total, completed }` (모든 퀘스트셋을 포함하되 — 기존
      `getProgress`가 `JOIN`으로 퀘스트가 하나도 없는 세트는 애초에 제외한다는 점에 유의 — 각
      세트의 전체 퀘스트 수와 `passed = true`인 시도가 있는 고유 퀘스트 수를 센다.
      `LEFT JOIN quest_attempt`로 해당 사용자의 시도만 카운트하므로 다른 사용자의 시도는 섞이지
      않는다)
- [ ] 토큰 없이 호출 시 401

**리더보드 조회 (`GET /leaderboard`)**
- [ ] 로그인한 사용자가 호출 시 200 + `member` 역할 사용자별 순위 배열
      `{ userId, userName, total, completed, sets: [{ questSetId, questSetTitle, category, total,
      completed }] }` (완료 수 내림차순, 동점이면 이름 오름차순 — 기존 `getLeaderboard`의
      `ORDER BY completed DESC, u.name`과 동일. `admin` 역할은 집계 대상에서 제외 — 기존
      `WHERE u.role = 'member'`와 동일)
- [ ] 토큰 없이 호출 시 401

**피드백 등록 (`POST /feedback`)**
- [ ] `{ page, questId?, questSetId?, body }` 전송 시 200, `feedback` 테이블에 레코드 생성
      (`questId`/`questSetId`는 선택값 — 특정 퀘스트 화면이 아니라 목록 화면 등에서도 피드백을
      남길 수 있다)
- [ ] 토큰이 있으면 그 사용자의 `userId`가 기록되고, 토큰이 없어도(또는 유효하지 않아도) 401이
      아니라 `userId = null`로 정상 등록됨 (기존 `feedback.routes.ts`가 `authMiddleware` 없이
      `Authorization` 헤더를 있으면만 파싱해 실패해도 무시하던 동작과 동일 — **이 엔드포인트는
      로그인 여부와 무관하게 열려 있다**)
- [ ] `body`가 빈 문자열이거나 공백만 있으면 400 (기존 `if (!body?.trim())`과 동일)

**관리자용 피드백 목록 조회 (`GET /admin/feedback`)**
- [ ] 관리자 토큰으로 호출 시 200 + 피드백 배열
      `{ id, userName, page, questSetTitle, questTitle, body, createdAt }` (최신순 —
      `userName`/`questSetTitle`/`questTitle`은 각각 작성자가 없거나 퀘스트/퀘스트셋을 지정하지
      않은 경우 `null` — 기존 `LEFT JOIN` 결과와 동일)
- [ ] `member` 토큰으로 호출 시 403
- [ ] 토큰 없이 호출 시 401

이 조건들은 아래 4-6(통합 테스트)의 `ProgressControllerTest`/`FeedbackControllerTest`로 그대로
옮겨진다. 이 Step은 그 테스트가 전부 통과하면 완료다.

프론트엔드(`frontend/src/api/progress.ts`, `feedback.ts`)는 Step 1과 동일한 방침으로 이 Step에서
건드리지 않는다 — Step 10(cutover)에서 전체 API 모듈을 일괄 전환한다.

## 진행 방식

Step 1~3과 동일하게 **ATDD 바깥 루프 + 구현-후-검증 안쪽 루프**로 진행합니다. 이 Step의 로직은
전부 집계 쿼리이거나(진행률/리더보드) 단순 CRUD(피드백)라 설계를 탐색할 이유가 없어 "구현 먼저
작성 → 단위 테스트로 검증" 순서를 그대로 씁니다. `Feedback` 생성 시 "빈 문자열이면 400" 같은 얕은
검증은 Bean Validation으로 처리하고, 별도 도메인 예외 없이 `ApiControllerAdvice`의 기존
`MethodArgumentNotValidException` 핸들러(Step 1)를 재사용합니다.

레이어는 `domain/progress`(엔티티/포트/서비스), `domain/feedback`(엔티티/포트/서비스) →
`application/progress`, `application/feedback`(Facade) →
`infrastructure/persistence/progress`, `infrastructure/persistence/feedback`(어댑터) →
`interfaces/api/progress`, `interfaces/api/feedback` → 인수 테스트 순으로 나갑니다.
`UserRepository`, `QuestRepository`, `QuestSetRepository`, `ApiResponse<T>`,
`ApiControllerAdvice`, `AuthInterceptor`/`AdminInterceptor`는 Step 1~3에서 이미 만들어져 있으므로
재사용만 합니다.

**집계 쿼리도 Step 3과 동일하게 QueryDSL로 작성합니다** — `QuestSetQuerydslRepository`(Step 3)가
이미 `JPAQueryFactory`를 이 프로젝트의 표준으로 세워뒀으므로, `getProgress`/`getLeaderboard`의
`GROUP BY` + 조건부 `COUNT(CASE WHEN ...)`도 JPQL 문자열 대신 QueryDSL의 `Q타입` +
`Projections.constructor`로 타입 세이프하게 표현합니다. JPQL 문자열은 컴파일 타임에 오타나 필드명
변경을 잡아주지 못하지만(예: `QuestSetProgress` 생성자 순서가 바뀌면 JPQL의 `SELECT new ...(...)`
순서와 조용히 어긋날 수 있습니다), QueryDSL은 `Q타입` 필드를 직접 참조하므로 리팩터링 시
컴파일러가 즉시 잡아줍니다.

---

## 4-0. 엔티티 2종 — `QuestAttempt`, `Feedback`

### `QuestAttempt` (`domain/progress/QuestAttempt.kt`)

`quest_attempt.attempted_at`은 `created_at`과 의미가 같지만 컬럼명이 다릅니다. `id` 선언을
중복하지 않기 위해 `BaseEntity`(`modules/jpa`)는 그대로 상속하고, `@AttributeOverride`로
`createdAt` 필드가 매핑되는 컬럼명만 `attempted_at`으로 바꿉니다.

```kotlin
package com.etude.domain.progress

import com.etude.domain.BaseEntity
import jakarta.persistence.AttributeOverride
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "quest_attempt")
@AttributeOverride(name = "createdAt", column = Column(name = "attempted_at", nullable = false, updatable = false))
class QuestAttempt(
    @Column(name = "user_id", nullable = false)
    val userId: Long,

    @Column(name = "quest_id", nullable = false)
    val questId: Long,

    @Column(name = "quest_set_id", nullable = false)
    val questSetId: Long,

    @Column(name = "session_id", nullable = false, length = 36)
    val sessionId: String,

    @Column(name = "elapsed_sec")
    val elapsedSec: Int?,

    @Column(name = "hint_used", nullable = false)
    val hintUsed: Boolean = false,

    @Column(name = "solution_used", nullable = false)
    val solutionUsed: Boolean = false,

    @Column(nullable = false)
    val passed: Boolean = false,
) : BaseEntity()
```

> `@AttributeOverride`는 부모(`BaseEntity`)가 선언한 필드의 **DB 컬럼 매핑만** 자식 엔티티에서
> 바꾸는 JPA 표준 기능입니다. `id` 필드는 건드리지 않으므로 `BaseEntity`를 상속하는 다른
> 엔티티(`QuestSet`, `Quest` 등)와 동일하게 PK 처리가 됩니다 — 오직 `createdAt` → `attempted_at`
> 컬럼명 매핑만 오버라이드합니다. `Quest`/`QuestSet`은 `id`, `Feedback`은 아래에서 보듯 그대로
> `created_at`을 쓰므로 오버라이드가 필요 없습니다 — `QuestAttempt`만 예외적으로 다른 컬럼명을
> 쓰는 이유는 "시도한 시각"이라는 의미가 "생성된 시각"보다 도메인적으로 더 명확해서 원본
> Node.js 스키마가 그렇게 설계했기 때문입니다(임의로 바꾸지 않고 그대로 유지).

`elapsedSec`가 nullable인 이유는 원본 `recordAttempt(..., elapsedSec?: number, ...)`의
선택 파라미터와 동일합니다 — Step 7에서 실제로 이 필드를 채우는 로직을 작성할 때 다시 다룹니다.

### `Feedback` (`domain/feedback/Feedback.kt`)

`feedback.created_at`은 이름이 그대로 맞으므로 `BaseEntity`를 별도 오버라이드 없이 상속합니다.
`userId`/`questId`/`questSetId`가 전부 nullable인 것도 원본 스키마 그대로입니다.

```kotlin
package com.etude.domain.feedback

import com.etude.domain.BaseEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Table

@Entity
@Table(name = "feedback")
class Feedback(
    @Column(name = "user_id")
    val userId: Long?,

    @Column(length = 100)
    val page: String?,

    @Column(name = "quest_id")
    val questId: Long?,

    @Column(name = "quest_set_id")
    val questSetId: Long?,

    @Column(nullable = false, columnDefinition = "TEXT")
    val body: String,
) : BaseEntity()
```

> `page`가 nullable인 이유는 원본 스키마(`page VARCHAR(100)`, `NOT NULL` 제약 없음)를 그대로
> 따른 것입니다 — 실제로 프론트엔드가 항상 `page`를 채워 보내더라도, 엔티티 레벨에서 이를
> 강제하지 않는 게 원본 동작과 일치합니다.

---

## 4-1. Repository 포트 2종

### `QuestAttemptRepository` (`domain/progress/QuestAttemptRepository.kt`)

`getProgress`/`getLeaderboard`가 필요로 하는 집계 결과를 리포지토리 메서드로 미리 정의합니다 —
서비스가 원시 `List<QuestAttempt>`를 받아 애플리케이션 레이어에서 다시 집계하지 않고, 집계
자체를 쿼리로 위임합니다(원본 Node.js가 SQL로 이미 그렇게 하고 있으므로 동일 전략).

```kotlin
package com.etude.domain.progress

interface QuestAttemptRepository {
    fun findProgressByUserId(userId: Long): List<QuestSetProgress>
    fun findLeaderboard(): List<MemberProgress>
}
```

`QuestSetProgress`, `MemberProgress`는 4-2에서 정의하는 순수 데이터 클래스입니다 — 이 시점에는
아직 정의되지 않았으니 컴파일 에러가 나는 게 정상입니다(다음 절에서 채웁니다).

### `FeedbackRepository` (`domain/feedback/FeedbackRepository.kt`)

```kotlin
package com.etude.domain.feedback

interface FeedbackRepository {
    fun save(feedback: Feedback): Feedback
    fun findAllOrderByCreatedAtDesc(): List<FeedbackSummary>
}
```

`findAllOrderByCreatedAtDesc`가 엔티티가 아니라 `FeedbackSummary`(4-2)를 직접 반환하는 이유는
`getFeedbackList`가 `feedback`, `user`, `quest_set`, `quest` 4개 테이블을 조인한 결과이기
때문입니다 — `Feedback` 엔티티 하나로는 `userName`/`questSetTitle`/`questTitle`을 담을 수 없어,
Step 3의 `QuestSetRepository.findAllPublicOrAccessibleBy`처럼 리포지토리가 조인 결과를 요약
타입으로 바로 돌려줍니다.

---

## 4-2. 응답/집계 타입 (`domain/progress/ProgressSummary.kt`, `domain/feedback/FeedbackSummary.kt`)

```kotlin
// domain/progress/ProgressSummary.kt
package com.etude.domain.progress

data class QuestSetProgress(
    val questSetId: Long,
    val title: String,
    val category: String,
    val total: Long,
    val completed: Long,
)

data class QuestSetProgressDetail(
    val questSetId: Long,
    val questSetTitle: String,
    val category: String,
    val total: Long,
    val completed: Long,
)

data class MemberProgress(
    val userId: Long,
    val userName: String,
    val total: Long,
    val completed: Long,
    val sets: List<QuestSetProgressDetail>,
)
```

> `QuestSetProgress`(내 진행률용, 필드명 `title`)와 `QuestSetProgressDetail`(리더보드의 세트별
> 상세, 필드명 `questSetTitle`)이 구조는 거의 같은데 이름이 다른 두 타입으로 나뉘는 이유는 원본
> 응답 필드명이 실제로 다르기 때문입니다(`getProgress`는 `title`, `getLeaderboard`의 `sets`
> 배열은 `questSetTitle`). 하나로 통합하면 인수 조건의 필드명 요구를 만족시키지 못합니다.

```kotlin
// domain/feedback/FeedbackSummary.kt
package com.etude.domain.feedback

import java.time.LocalDateTime

data class FeedbackSummary(
    val id: Long,
    val userName: String?,
    val page: String?,
    val questSetTitle: String?,
    val questTitle: String?,
    val body: String,
    val createdAt: LocalDateTime,
)
```

---

## 4-3. 도메인 서비스 — `ProgressService`, `FeedbackService`

### `ProgressService` (`domain/progress/ProgressService.kt`)

```kotlin
package com.etude.domain.progress

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class ProgressService(
    private val questAttemptRepository: QuestAttemptRepository,
) {
    fun getProgress(userId: Long): List<QuestSetProgress> =
        questAttemptRepository.findProgressByUserId(userId)

    fun getLeaderboard(): List<MemberProgress> =
        questAttemptRepository.findLeaderboard()
}
```

> [1-4 원칙](../research/reference_projects_action_items.md)("쓰기 작업이 하나라도 있으면
> `@Transactional`을 붙인다")은 조회 전용 서비스에 붙이지 말라는 뜻은 아닙니다. `ProgressService`는
> 쓰기가 전혀 없지만 `@Transactional(readOnly = true)`를 명시적으로 붙입니다 — 읽기 전용임을
> 코드로 드러내고, Hibernate가 dirty checking을 생략해 약간의 성능 이점도 얻습니다. 반대로
> `AuthService.login`(Step 1)에는 이 어노테이션이 없는데, 이후 이 문서 스타일을 따를 신규
> 서비스는 조회 전용이라도 `readOnly = true`를 기본으로 붙이는 쪽을 권장합니다.

집계 자체(GROUP BY, 조건부 COUNT)는 이미 리포지토리 쿼리가 다 하고 있어 서비스는 얇은
패스스루입니다. TDD로 검증할 조건 분기가 없으므로 4-5(단위 테스트)에서는 "서비스가 리포지토리
결과를 그대로 반환하는지"만 mockk로 확인합니다.

### `FeedbackService` (`domain/feedback/FeedbackService.kt`)

```kotlin
package com.etude.domain.feedback

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class FeedbackService(
    private val feedbackRepository: FeedbackRepository,
) {
    fun createFeedback(userId: Long?, page: String?, questId: Long?, questSetId: Long?, body: String) {
        feedbackRepository.save(Feedback(userId = userId, page = page, questId = questId, questSetId = questSetId, body = body.trim()))
    }

    fun getFeedbackList(): List<FeedbackSummary> = feedbackRepository.findAllOrderByCreatedAtDesc()
}
```

> `save()`를 호출하므로 [1-4 원칙](../research/reference_projects_action_items.md)에 따라
> 클래스 레벨 `@Transactional`을 붙입니다.
>
> `body.trim()`을 서비스에서 하는 이유는 "빈 문자열/공백만 있으면 400"이라는 검증 자체는
> 컨트롤러의 Bean Validation(`@NotBlank`)이 이미 막아주지만, trim된 값을 저장하는 것 자체는
> 검증이 아니라 "저장 전 정규화"라는 서비스의 책임이기 때문입니다 — 원본 `createFeedback`
> 호출부(`body.trim()`)와 동일한 지점에 로직을 둡니다.

---

## 4-3a. Facade 2종 — `ProgressFacade`, `FeedbackFacade`

Step 2/3과 동일하게 `interfaces`가 `domain`을 직접 호출하지 않고 `application` 레이어를 거칩니다.
지금은 각 서비스 메서드를 그대로 위임만 하는 얇은 Facade입니다.

```kotlin
// application/progress/ProgressFacade.kt
package com.etude.application.progress

import com.etude.domain.progress.MemberProgress
import com.etude.domain.progress.ProgressService
import com.etude.domain.progress.QuestSetProgress
import org.springframework.stereotype.Component

@Component
class ProgressFacade(
    private val progressService: ProgressService,
) {
    fun getProgress(userId: Long): List<QuestSetProgress> = progressService.getProgress(userId)
    fun getLeaderboard(): List<MemberProgress> = progressService.getLeaderboard()
}
```

```kotlin
// application/feedback/FeedbackFacade.kt
package com.etude.application.feedback

import com.etude.domain.feedback.FeedbackService
import com.etude.domain.feedback.FeedbackSummary
import org.springframework.stereotype.Component

@Component
class FeedbackFacade(
    private val feedbackService: FeedbackService,
) {
    fun createFeedback(userId: Long?, page: String?, questId: Long?, questSetId: Long?, body: String) =
        feedbackService.createFeedback(userId, page, questId, questSetId, body)

    fun getFeedbackList(): List<FeedbackSummary> = feedbackService.getFeedbackList()
}
```

---

## 4-4. 어댑터 구현 — `infrastructure/persistence/progress`, `infrastructure/persistence/feedback`

### `QuestAttemptQuerydslRepository.kt`, `QuestAttemptRepositoryImpl.kt`

Step 3의 `QuestSetQuerydslRepository`와 동일한 구조입니다 — QueryDSL 전용 쿼리를 별도 클래스로
분리하고, `RepositoryImpl`이 이를 포트 인터페이스 뒤로 감춥니다. `QQuestSet`, `QQuest`,
`QQuestAttempt`는 어노테이션 프로세서(`kapt`)가 엔티티로부터 자동 생성하므로 별도 작성이
필요 없습니다 — Step 3에서 QueryDSL gradle 설정(3-3)을 이미 마쳤다면 빌드 시 자동으로 생깁니다.

```kotlin
package com.etude.infrastructure.persistence.progress

import com.etude.domain.progress.QQuestAttempt.questAttempt
import com.etude.domain.progress.QuestSetProgress
import com.etude.domain.quest.QQuest.quest
import com.etude.domain.quest.QQuestSet.questSet
import com.querydsl.core.types.Projections
import com.querydsl.core.types.dsl.CaseBuilder
import com.querydsl.core.types.dsl.Expressions
import com.querydsl.jpa.impl.JPAQueryFactory
import org.springframework.stereotype.Repository

@Repository
class QuestAttemptQuerydslRepository(
    private val queryFactory: JPAQueryFactory
) {
    fun findProgressByUserId(userId: Long): List<QuestSetProgress> =
        queryFactory
            .select(
                Projections.constructor(
                    QuestSetProgress::class.java,
                    questSet.id,
                    questSet.title,
                    questSet.category,
                    quest.id.countDistinct(),
                    CaseBuilder()
                        .`when`(questAttempt.passed.isTrue)
                        .then(questAttempt.questId)
                        .otherwise(Expressions.nullExpression())
                        .countDistinct(),
                )
            )
            .from(questSet)
            .join(quest).on(quest.questSetId.eq(questSet.id))
            .leftJoin(questAttempt).on(questAttempt.questId.eq(quest.id).and(questAttempt.userId.eq(userId)))
            .groupBy(questSet.id, questSet.title, questSet.category)
            .orderBy(questSet.id.asc())
            .fetch()
}
```

> `Projections.constructor(QuestSetProgress::class.java, ...)`는 JPQL의
> `SELECT new ...(...)`와 같은 역할을 하는 QueryDSL API입니다 — 인자 순서가
> `QuestSetProgress`의 생성자 순서(`questSetId, title, category, total, completed`)와 일치해야
> 하는 것도 동일합니다. 다만 JPQL 문자열과 달리 `questSet.title`처럼 `Q타입` 필드를 직접
> 참조하므로, `QuestSet` 엔티티의 필드명이 바뀌면 컴파일 에러로 바로 드러납니다.
>
> `CaseBuilder().when(...).then(...).otherwise(...)`가 원본 SQL의
> `CASE WHEN qa.passed = 1 THEN qa.quest_id END`에 대응합니다 — `otherwise(Expressions.
> nullExpression())`로 조건에 안 맞는 행은 명시적으로 `NULL`을 반환하게 하고, 그 결과를
> `countDistinct()`로 세면 `NULL`은 카운트에서 자동으로 제외됩니다(SQL `COUNT`의 표준 동작과
> 동일) — 원본 SQL의 `COUNT(DISTINCT CASE WHEN qa.passed = 1 THEN qa.quest_id END)`가 정확히
> 이 방식으로 동작합니다.
>
> `quest.id.countDistinct()`, `...questId.countDistinct()`가 원본 SQL의 두 `COUNT(DISTINCT ...)`
> 와 동일한 이유도 그대로입니다 — `leftJoin(questAttempt)`가 시도 횟수만큼 행을 늘리므로,
> 퀘스트 총 개수와 통과한 고유 퀘스트 개수를 각각 `DISTINCT`로 세지 않으면 재시도가 있는 경우
> 개수가 부풀려집니다.

`findLeaderboard`도 원본처럼 두 단계(요약 쿼리 + 세트별 상세 쿼리)로 나눠 QueryDSL로 작성한 뒤
애플리케이션 코드에서 합칩니다.

```kotlin
package com.etude.infrastructure.persistence.progress

import com.etude.domain.progress.QQuestAttempt.questAttempt
import com.etude.domain.progress.QuestSetProgressDetail
import com.etude.domain.quest.QQuest.quest
import com.etude.domain.quest.QQuestSet.questSet
import com.etude.domain.auth.QUser.user
import com.etude.domain.auth.UserRole
import com.querydsl.core.types.Projections
import com.querydsl.core.types.dsl.CaseBuilder
import com.querydsl.core.types.dsl.Expressions
import com.querydsl.jpa.impl.JPAQueryFactory
import org.springframework.stereotype.Repository

data class LeaderboardSummaryRow(val userId: Long, val userName: String, val total: Long, val completed: Long)
data class LeaderboardDetailRow(val userId: Long, val detail: QuestSetProgressDetail)

@Repository
class QuestAttemptQuerydslRepository(
    private val queryFactory: JPAQueryFactory
) {
    // ...findProgressByUserId 위에 계속...

    fun findLeaderboardSummary(): List<LeaderboardSummaryRow> =
        queryFactory
            .select(
                Projections.constructor(
                    LeaderboardSummaryRow::class.java,
                    user.id, user.name,
                    quest.id.countDistinct(),
                    passedCountExpression(),
                )
            )
            .from(user)
            .join(quest).on(quest.id.isNotNull) // CROSS JOIN 대응 — quest 전체와 곱
            .leftJoin(questAttempt).on(questAttempt.questId.eq(quest.id).and(questAttempt.userId.eq(user.id)))
            .where(user.role.eq(UserRole.member))
            .groupBy(user.id, user.name)
            .orderBy(passedCountExpression().desc(), user.name.asc())
            .fetch()

    fun findLeaderboardDetail(): List<LeaderboardDetailRow> =
        queryFactory
            .select(
                Projections.constructor(
                    LeaderboardDetailRow::class.java,
                    user.id,
                    Projections.constructor(
                        QuestSetProgressDetail::class.java,
                        questSet.id, questSet.title, questSet.category,
                        quest.id.countDistinct(),
                        passedCountExpression(),
                    ),
                )
            )
            .from(user)
            .join(questSet).on(questSet.id.isNotNull)
            .join(quest).on(quest.questSetId.eq(questSet.id))
            .leftJoin(questAttempt).on(questAttempt.questId.eq(quest.id).and(questAttempt.userId.eq(user.id)))
            .where(user.role.eq(UserRole.member))
            .groupBy(user.id, questSet.id)
            .orderBy(user.id.asc(), questSet.id.asc())
            .fetch()

    private fun passedCountExpression() =
        CaseBuilder()
            .`when`(questAttempt.passed.isTrue)
            .then(questAttempt.questId)
            .otherwise(Expressions.nullExpression())
            .countDistinct()
}
```

> `CROSS JOIN`은 QueryDSL에 직접 대응하는 메서드가 없어 `.join(...).on(quest.id.isNotNull)`처럼
> 항상 참인 조건으로 대체합니다 — 원본 SQL의 `CROSS JOIN quest q`, `CROSS JOIN quest_set qs`와
> 동일한 효과(모든 조합)를 냅니다. `passedCountExpression()`을 private 함수로 뽑은 이유는
> `SELECT` 절과 `ORDER BY` 절(`completed DESC`) 양쪽에서 같은 식이 반복되기 때문입니다 —
> 원본 SQL도 `ORDER BY completed DESC`처럼 같은 집계를 정렬에 재사용합니다.

```kotlin
package com.etude.infrastructure.persistence.progress

import com.etude.domain.progress.MemberProgress
import com.etude.domain.progress.QuestAttempt
import com.etude.domain.progress.QuestAttemptRepository
import com.etude.domain.progress.QuestSetProgress
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

interface QuestAttemptJpaRepository : JpaRepository<QuestAttempt, Long>

@Repository
class QuestAttemptRepositoryImpl(
    private val querydslRepository: QuestAttemptQuerydslRepository,
) : QuestAttemptRepository {
    override fun findProgressByUserId(userId: Long): List<QuestSetProgress> =
        querydslRepository.findProgressByUserId(userId)

    override fun findLeaderboard(): List<MemberProgress> {
        val summaries = querydslRepository.findLeaderboardSummary()
        val details = querydslRepository.findLeaderboardDetail()
        return summaries.map { summary ->
            MemberProgress(
                userId = summary.userId,
                userName = summary.userName,
                total = summary.total,
                completed = summary.completed,
                sets = details.filter { it.userId == summary.userId }.map { it.detail },
            )
        }
    }
}
```

> `QuestAttemptJpaRepository`(Spring Data JPA 인터페이스)는 이 Step의 `QuestAttemptRepositoryImpl`
> 생성자에는 주입하지 않습니다 — 조회는 전부 QueryDSL(`querydslRepository`)이 담당하고, `save()`는
> `QuestAttemptRepository` 포트 인터페이스에 아직 없는(Step 7에서 추가할) 메서드이기 때문입니다.
> 그런데도 이 인터페이스 자체는 지금 정의해둡니다 — 테스트 픽스처(`TestQuestAttempts`, 4-7)가
> 통합 테스트에서 시드 데이터를 넣을 때 `@Autowired`로 직접 주입받아 `save()`/`deleteAll()`을
> 쓰기 때문입니다. Step 7이 `QuestAttemptRepository.save()`를 추가하면, 그때는
> `QuestAttemptRepositoryImpl`도 이 인터페이스를 주입받아 위임하도록 고칩니다.

### `FeedbackQuerydslRepository.kt`, `FeedbackRepositoryImpl.kt`

```kotlin
package com.etude.infrastructure.persistence.feedback

import com.etude.domain.auth.QUser.user
import com.etude.domain.feedback.FeedbackSummary
import com.etude.domain.feedback.QFeedback.feedback
import com.etude.domain.quest.QQuest.quest
import com.etude.domain.quest.QQuestSet.questSet
import com.querydsl.core.types.Projections
import com.querydsl.jpa.impl.JPAQueryFactory
import org.springframework.stereotype.Repository

@Repository
class FeedbackQuerydslRepository(
    private val queryFactory: JPAQueryFactory
) {
    fun findAllOrderByCreatedAtDesc(): List<FeedbackSummary> =
        queryFactory
            .select(
                Projections.constructor(
                    FeedbackSummary::class.java,
                    feedback.id, user.name, feedback.page, questSet.title, quest.title,
                    feedback.body, feedback.createdAt,
                )
            )
            .from(feedback)
            .leftJoin(user).on(feedback.userId.eq(user.id))
            .leftJoin(questSet).on(feedback.questSetId.eq(questSet.id))
            .leftJoin(quest).on(feedback.questId.eq(quest.id))
            .orderBy(feedback.createdAt.desc(), feedback.id.desc())
            .fetch()
}
```

> `feedback.id.desc()`를 2차 정렬 키로 추가하는 이유 — `createdAt`은 `LocalDateTime.now()`
> (`BaseEntity`)로 채워지는데, 같은 테스트 메서드 안에서 연속으로 `POST /feedback`을 두 번
> 호출하면 두 레코드의 `created_at`이 밀리초 해상도 안에서 완전히 같은 값이 될 수 있습니다.
> `created_at`만으로 정렬하면 값이 동일한 두 행의 순서를 DB가 보장하지 않아(삽입 순서로 나올 수도,
> 아닐 수도 있음), "최신순"을 검증하는 테스트가 실행할 때마다 결과가 달라지는 취약한 상태가
> 됩니다. `id`는 `AUTO_INCREMENT`라 나중에 생성된 레코드가 항상 더 큰 값을 가지므로, 동시각
> 레코드 사이의 순서를 결정적으로 만들어줍니다.

```kotlin
package com.etude.infrastructure.persistence.feedback

import com.etude.domain.feedback.Feedback
import com.etude.domain.feedback.FeedbackRepository
import com.etude.domain.feedback.FeedbackSummary
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

interface FeedbackJpaRepository : JpaRepository<Feedback, Long>

@Repository
class FeedbackRepositoryImpl(
    private val feedbackJpaRepository: FeedbackJpaRepository,
    private val querydslRepository: FeedbackQuerydslRepository,
) : FeedbackRepository {
    override fun save(feedback: Feedback): Feedback = feedbackJpaRepository.save(feedback)
    override fun findAllOrderByCreatedAtDesc(): List<FeedbackSummary> = querydslRepository.findAllOrderByCreatedAtDesc()
}
```

> `save`는 Spring Data JPA(`feedbackJpaRepository`)에 남겨두고 조회만 QueryDSL로 옮긴 이유는
> Step 3의 `QuestSetRepositoryImpl`과 동일합니다 — 단순 저장은 `JpaRepository.save()`로 충분하고,
> QueryDSL은 복잡한 조회(조인, 집계, 동적 조건)에만 씁니다.

---

## 4-5. 단위 테스트 — `ProgressServiceTest`, `FeedbackServiceTest`

`ProgressService`는 리포지토리 결과를 그대로 반환하는 얇은 서비스라, "호출을 위임하는지"만
mockk로 확인합니다.

```kotlin
package com.etude.domain.progress

import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk

class ProgressServiceTest : FreeSpec({
    val questAttemptRepository = mockk<QuestAttemptRepository>()
    val progressService = ProgressService(questAttemptRepository)

    "내 진행률을 조회하면" - {
        "퀘스트셋별 진행률을 반환한다" {
            val expected = listOf(QuestSetProgress(1L, "리눅스 기초", "리눅스", total = 3, completed = 1))
            every { questAttemptRepository.findProgressByUserId(10L) } returns expected

            progressService.getProgress(10L) shouldBe expected
        }
    }

    "리더보드를 조회하면" - {
        "사용자별 진행률 순위를 반환한다" {
            val expected = listOf(MemberProgress(1L, "멤버", total = 3, completed = 1, sets = emptyList()))
            every { questAttemptRepository.findLeaderboard() } returns expected

            progressService.getLeaderboard() shouldBe expected
        }
    }
})
```

`FeedbackService`는 `body.trim()` 정규화만 검증할 가치가 있습니다.

```kotlin
package com.etude.domain.feedback

import io.kotest.core.spec.style.FreeSpec
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify

class FeedbackServiceTest : FreeSpec({
    val feedbackRepository = mockk<FeedbackRepository>()
    val feedbackService = FeedbackService(feedbackRepository)

    "앞뒤 공백이 있는 내용으로 피드백을 등록하면" - {
        "trim된 내용으로 저장한다" {
            val captured = slot<Feedback>()
            every { feedbackRepository.save(capture(captured)) } answers { captured.captured }

            feedbackService.createFeedback(userId = 1L, page = "/quest-sets", questId = null, questSetId = null, body = "  좋아요  ")

            captured.captured.body shouldBe "좋아요"
        }
    }
})
```

---

## 4-6. `ApiControllerAdvice`, 컨트롤러 — `ProgressV1Controller`, `FeedbackV1Controller`, `AdminFeedbackV1Controller`

**정정** — 이전 버전의 이 문서는 "Step 1에서 만든 `MethodArgumentNotValidException` 핸들러를
재사용한다"고 서술했지만, 실제로는 `ApiControllerAdvice`에 그 핸들러가 없었습니다. Step 1~3의
`@field:NotBlank`(`LoginRequest` 등)는 지금까지 "검증 실패 시 400이 맞는지"를 테스트로 확인한
적이 없어(전부 정상 입력만 테스트) 이 결함이 드러나지 않았을 뿐입니다. 지금 `ApiControllerAdvice`
는 알려지지 않은 예외를 잡는 범용 `handle(e: Exception)`만 있어서, `MethodArgumentNotValidException`
(Bean Validation 실패 시 Spring이 던지는 예외)이 여기로 떨어지면 400이 아니라 500으로 응답합니다
— 이 Step에서 처음으로 `@field:NotBlank` 검증 실패를 테스트하면서 드러난 문제이므로, 핸들러를
새로 추가합니다.

`interfaces/api/ApiControllerAdvice.kt`에 추가:

```kotlin
@ExceptionHandler
fun handle(e: MethodArgumentNotValidException): ResponseEntity<ApiResponse<*>> {
    val message = e.bindingResult.fieldErrors.firstOrNull()?.defaultMessage ?: "잘못된 요청입니다."
    return failureResponse(HttpStatus.BAD_REQUEST, ErrorType.BAD_REQUEST.code, message)
}
```

`import org.springframework.web.bind.MethodArgumentNotValidException`을 추가하고, 다른
`@ExceptionHandler`들과 마찬가지로 클래스 안에 둡니다. `ErrorType.BAD_REQUEST`는 이미
`support/error/ErrorType.kt`(Step 1)에 정의되어 있으므로 그대로 씁니다.

> 여러 필드가 동시에 검증에 실패할 수 있지만 `firstOrNull()`로 첫 번째 오류 메시지만 응답에
> 담습니다 — 원본 Node.js(`if (!body?.trim()) return reply.code(400).send({ error: '내용을
> 입력해주세요.' })`)도 필드 하나(`body`)만 검증하므로 여러 오류를 배열로 모아 응답하는 구조가
> 필요하지 않습니다. 나중에 검증 대상 필드가 늘어나 "여러 오류를 한 번에 보여줘야 한다"는 요구가
> 생기면 그때 `fieldErrors` 전체를 순회하도록 확장합니다.

### `interfaces/api/progress/ProgressV1ApiSpec.kt`, `ProgressV1Controller.kt`

```kotlin
package com.etude.interfaces.api.progress

import com.etude.domain.progress.MemberProgress
import com.etude.domain.progress.QuestSetProgress
import com.etude.infrastructure.security.LoginUser
import com.etude.domain.auth.JwtPayload
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Progress V1 API", description = "진행률/리더보드 조회 API 입니다.")
interface ProgressV1ApiSpec {
    @Operation(summary = "내 진행률 조회", description = "로그인한 사용자의 퀘스트셋별 진행률을 조회합니다.")
    fun getProgress(payload: JwtPayload): ApiResponse<List<QuestSetProgress>>

    @Operation(summary = "리더보드 조회", description = "member 역할 사용자의 진행률 순위를 조회합니다.")
    fun getLeaderboard(payload: JwtPayload): ApiResponse<List<MemberProgress>>
}
```

```kotlin
package com.etude.interfaces.api.progress

import com.etude.application.progress.ProgressFacade
import com.etude.domain.auth.JwtPayload
import com.etude.domain.progress.MemberProgress
import com.etude.domain.progress.QuestSetProgress
import com.etude.infrastructure.security.LoginUser
import com.etude.interfaces.api.ApiResponse
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class ProgressV1Controller(
    private val progressFacade: ProgressFacade,
) : ProgressV1ApiSpec {
    @GetMapping("/progress")
    override fun getProgress(@LoginUser payload: JwtPayload): ApiResponse<List<QuestSetProgress>> =
        ApiResponse.success(progressFacade.getProgress(payload.userId))

    @GetMapping("/leaderboard")
    override fun getLeaderboard(@LoginUser payload: JwtPayload): ApiResponse<List<MemberProgress>> =
        ApiResponse.success(progressFacade.getLeaderboard())
}
```

> [guide_loginuser_resolver.md](guide_loginuser_resolver.md)에서 만든 `@LoginUser` 리졸버를
> 처음부터 적용합니다 — Step 3까지는 `HttpServletRequest` + 캐스팅 패턴이었지만, 이 리팩터링이
> 완료된 이후에 작성하는 컨트롤러이므로 새 패턴을 기본으로 씁니다. `getLeaderboard`는 사실
> `payload`의 값 자체를 쓰지 않지만(리더보드는 전체 member 대상), 로그인 여부 확인은
> `AuthInterceptor`가 이미 경로 패턴(`/leaderboard`, `WebConfig`)으로 막고 있으므로 `@LoginUser`
> 파라미터 없이 그냥 `fun getLeaderboard(): ApiResponse<List<MemberProgress>>`로 선언해도
> 무방합니다 — 여기서는 일관성을 위해 유지했지만, 실제 구현 시 파라미터를 빼도 인수 조건에는
> 영향이 없습니다.

### `@LoginUser`를 nullable로 — 로그인 여부와 무관한 엔드포인트

`/feedback`은 `WebConfig`의 `AuthInterceptor.addPathPatterns` 목록에 없는(즉 인증이 강제되지
않는) 유일한 로그인 관련 엔드포인트입니다. `JwtAuthFilter`가 이미 인증이 있으면 request
attribute에 payload를 넣어두는 동작 자체는 `/feedback`에도 똑같이 적용됩니다(필터는 모든
요청에 걸리고, 인터셉터만 경로별로 강제 여부가 다릅니다). 그러니 컨트롤러가
`HttpServletRequest`/`JwtProvider`를 직접 주입받아 토큰을 다시 파싱할 필요가 없습니다 —
[guide_loginuser_resolver.md](guide_loginuser_resolver.md)의 `LoginUserArgumentResolver`가
파라미터를 `JwtPayload?`(nullable)로 선언하면 payload가 없어도 예외 대신 `null`을 반환하도록
이미 확장되어 있으므로, 별도 어노테이션 없이 `@LoginUser payload: JwtPayload?`로 그대로
씁니다.

### `interfaces/api/feedback/FeedbackV1ApiSpec.kt`, `FeedbackV1Controller.kt`

```kotlin
package com.etude.interfaces.api.feedback

import com.etude.domain.auth.JwtPayload
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Feedback V1 API", description = "피드백 등록 API 입니다.")
interface FeedbackV1ApiSpec {
    @Operation(summary = "피드백 등록", description = "로그인 여부와 무관하게 피드백을 등록합니다.")
    fun createFeedback(request: CreateFeedbackRequest, payload: JwtPayload?): ApiResponse<Unit>
}
```

```kotlin
package com.etude.interfaces.api.feedback

import com.etude.application.feedback.FeedbackFacade
import com.etude.domain.auth.JwtPayload
import com.etude.infrastructure.security.LoginUser
import com.etude.interfaces.api.ApiResponse
import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController

data class CreateFeedbackRequest(
    val page: String?,
    val questId: Long?,
    val questSetId: Long?,
    @field:NotBlank val body: String,
)

@RestController
class FeedbackV1Controller(
    private val feedbackFacade: FeedbackFacade,
) : FeedbackV1ApiSpec {
    @PostMapping("/feedback")
    override fun createFeedback(
        @Valid @RequestBody request: CreateFeedbackRequest,
        @LoginUser payload: JwtPayload?,
    ): ApiResponse<Unit> {
        feedbackFacade.createFeedback(payload?.userId, request.page, request.questId, request.questSetId, request.body)
        return ApiResponse.success<Unit>()
    }
}
```

> `HttpServletRequest`, `JwtProvider` 의존성이 컨트롤러에서 완전히 사라집니다 — 토큰 파싱이라는
> 인증 관심사가 리졸버(인프라 레이어)에 이미 있고, 컨트롤러는 `payload?.userId`처럼 이미 검증된
> 값만 다루는 다른 컨트롤러들과 같은 모양이 됩니다. 원본 `feedback.routes.ts`(`try { userId =
> verifyToken(...).userId } catch {}`)가 하던 "토큰이 있으면 검증하고, 없거나 실패하면 무시"라는
> 동작은 `LoginUserArgumentResolver`가 `JwtAuthFilter`(요청마다 토큰을 검증해 유효하면 request
> attribute에 payload를 채우고, 유효하지 않으면 조용히 넘어가는 필터)가 이미 채워둔 request
> attribute를 읽는 것으로 그대로 유지됩니다 — 잘못된 토큰이 와도 `JwtAuthFilter`가 애초에
> attribute를 채우지 않으므로 조용히 `null`이 됩니다.
>
> `@LoginUser payload: JwtPayload`(non-null)로 쓰는 다른 컨트롤러(`AuthV1Controller`,
> `MeV1Controller`, `QuestV1Controller`, `ProgressV1Controller`)와 같은 어노테이션을 쓰면서도
> 동작이 다른 이유는 순전히 파라미터 타입의 nullable 여부(`JwtPayload` vs `JwtPayload?`)
> 때문입니다 — 별도의 `@OptionalLoginUser` 같은 어노테이션을 새로 만들지 않습니다.

### `interfaces/api/feedback/AdminFeedbackV1ApiSpec.kt`, `AdminFeedbackV1Controller.kt`

```kotlin
package com.etude.interfaces.api.feedback

import com.etude.domain.feedback.FeedbackSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Admin Feedback V1 API", description = "관리자용 피드백 조회 API 입니다.")
interface AdminFeedbackV1ApiSpec {
    @Operation(summary = "피드백 목록 조회(관리자)", description = "전체 피드백을 최신순으로 조회합니다.")
    fun getFeedbackList(): ApiResponse<List<FeedbackSummary>>
}
```

```kotlin
package com.etude.interfaces.api.feedback

import com.etude.application.feedback.FeedbackFacade
import com.etude.domain.feedback.FeedbackSummary
import com.etude.interfaces.api.ApiResponse
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/admin/feedback")
class AdminFeedbackV1Controller(
    private val feedbackFacade: FeedbackFacade,
) : AdminFeedbackV1ApiSpec {
    @GetMapping
    override fun getFeedbackList(): ApiResponse<List<FeedbackSummary>> =
        ApiResponse.success(feedbackFacade.getFeedbackList())
}
```

> `/admin/feedback`은 `WebConfig`의 `addPathPatterns("/admin/**")`에 이미 포함되므로
> `AuthInterceptor`/`AdminInterceptor`가 인증/권한을 처리합니다 — 컨트롤러에서 별도 role 확인이
> 필요 없습니다(Step 2/3의 관리자 컨트롤러와 동일 패턴).

---

## 4-7. `IntegrationTest` 공통 데이터 정리 — 여러 통합 테스트 클래스 간 FK 오염 방지

Step 4에서 새로 생기는 `quest_attempt`는 `user`, `quest`, `quest_set` 세 테이블을 동시에 FK로
참조하는 첫 테이블입니다. 지금까지 각 통합 테스트 클래스(`AuthControllerTest`,
`UserAdminControllerTest`, `QuestControllerTest`, `AdminQuestSetControllerTest`)는 `beforeTest`
에서 **자기 도메인 테이블만** 지우는 방식으로 문제없이 동작해왔습니다 — 그런데 이 클래스들은
모두 같은 `IntegrationTest`를 상속해 Testcontainers MariaDB 컨테이너 **하나를 공유**하고,
Kotest는 여러 스펙 클래스의 실행 순서를 보장하지 않습니다.

`ProgressControllerTest`가 (실행 순서상) 먼저 돌면서 `quest`/`quest_attempt`를 만들고 나면, 그
뒤에 실행되는 `QuestControllerTest.beforeTest`의 `questJpaRepository.deleteAll()`이 아직 남아있는
`quest_attempt.quest_id` FK 제약에 걸려 `DataIntegrityViolationException`을 던집니다. 개별
클래스만 실행하면 이 오염이 없어 통과하지만, 전체 테스트를 한 번에 돌리면 클래스 실행 순서에 따라
실패/통과가 갈립니다.

`ProgressControllerTest`의 `afterTest`에서 자신이 만든 데이터만 지우는 방식으로도 이번 케이스는
막을 수 있지만, 그건 "이번에 드러난 증상"만 봉합하는 것이라 **Step 5 이후 또 다른 테이블이
FK로 얽힐 때마다 같은 문제가 재발**합니다. 매 Step마다 "내가 참조하는 테이블도 같이 지워야
하나?"를 개별 테스트 클래스가 서로 알아야 하는 구조 자체가 근본 원인이므로, 여러 클래스가 공유하는
`IntegrationTest`(`support/IntegrationTest.kt`)에 **전체 도메인 테이블을 FK 자식→부모 순으로
지우는 공통 로직**을 한 곳에 둡니다. 이후 모든 통합 테스트 클래스는 이 공통 정리에 의존하고,
자기 `beforeTest`에서 개별 `deleteAll()`을 직접 호출하지 않습니다.

```kotlin
package com.etude.support

import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.feedback.FeedbackJpaRepository
import com.etude.infrastructure.persistence.progress.QuestAttemptJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetAccessJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import io.kotest.core.spec.style.FreeSpec
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.test.context.ActiveProfiles
import org.testcontainers.containers.MariaDBContainer
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers

@Testcontainers
@SpringBootTest
@ActiveProfiles("test")
abstract class IntegrationTest(body: FreeSpec.() -> Unit = {}) : FreeSpec() {
    @Autowired private lateinit var questAttemptJpaRepository: QuestAttemptJpaRepository
    @Autowired private lateinit var feedbackJpaRepository: FeedbackJpaRepository
    @Autowired private lateinit var questSetAccessJpaRepository: QuestSetAccessJpaRepository
    @Autowired private lateinit var questJpaRepository: QuestJpaRepository
    @Autowired private lateinit var questSetJpaRepository: QuestSetJpaRepository
    @Autowired private lateinit var userJpaRepository: UserJpaRepository

    companion object {
        @Container
        @ServiceConnection
        val mariadb = MariaDBContainer("mariadb:11")
            .withInitScripts("db/00_schema.sql", "db/01_sandbox.sql")
    }

    init {
        body()
        beforeTest { cleanAllTables() }
    }

    // FK 자식 → 부모 순서로 각 리포지토리의 deleteAll()을 호출한다. 문자열로 테이블명을 조립해
    // 네이티브 쿼리를 실행하는 대신 이미 존재하는 JpaRepository들을 그대로 쓰므로, "안전한 값만
    // SQL에 들어간다"를 굳이 별도로 검증할 필요가 없다 — 각 deleteAll()이 그 리포지토리가 매핑된
    // 테이블만 정확히 지운다는 게 JPA 타입 시스템으로 이미 보장된다. 새 테이블을 추가하면 그
    // 테이블을 참조하는 자식이 없는지 확인한 뒤 이 목록의 알맞은 위치(자신을 참조하는 리포지토리
    // 보다 앞)에 추가한다.
    //
    // 클래스 레벨 @Transactional을 붙이지 않는 이유 — `beforeTest { cleanAllTables() }`는 같은
    // 객체 안에서 this.cleanAllTables()를 호출하는 self-invocation이라 Spring의 프록시를 거치지
    // 않고, @Transactional을 붙여도 실제로는 적용되지 않는다(AOP 프록시 기반 트랜잭션의 알려진
    // 제약). 다행히 SimpleJpaRepository.deleteAll()은 그 자체로 이미 @Transactional이 걸려 있어
    // 각 호출은 독립적으로 안전하게 커밋된다 — 6개를 하나의 트랜잭션으로 묶는 원자성은 없지만,
    // 테스트 데이터 정리 목적에서는 그 원자성이 필요하지 않다.
    fun cleanAllTables() {
        listOf<JpaRepository<*, *>>(
            questAttemptJpaRepository,
            feedbackJpaRepository,
            questSetAccessJpaRepository,
            questJpaRepository,
            questSetJpaRepository,
            userJpaRepository,
        ).forEach { it.deleteAll() }
    }
}
```

> `abstract class IntegrationTest(body: FreeSpec.() -> Unit = {}) : FreeSpec()`으로 바뀐 이유 —
> 기존에는 `FreeSpec(body)`로 생성자에서 바로 `body`를 실행했지만, `beforeTest { cleanAllTables() }`
> 등록이 서브클래스의 `body`보다 먼저 이루어져야 순서가 꼬이지 않습니다(Kotest의 `beforeTest`는
> 등록된 순서와 무관하게 매 테스트 앞에서 실행되므로 엄밀히는 순서가 문제되지 않지만, `init`
> 블록 안에서 `body()`를 명시적으로 호출하고 그 다음 `beforeTest`를 등록하는 편이 "무엇이 어떤
> 순서로 설정되는지"를 코드로 더 분명하게 드러냅니다).
>
> **주의 — 기존 통합 테스트 5개(`AuthControllerTest`, `UserAdminControllerTest`,
> `QuestControllerTest`, `AdminQuestSetControllerTest`, 그리고 이 Step에서 만들
> `ProgressControllerTest`)의 `beforeTest`에서 각자 하던 `deleteAll()` 호출을 전부 지워야
> 합니다** — 이제 `IntegrationTest`가 매 테스트 앞에서 전체 테이블을 지워주므로, 개별
> `beforeTest`는 "지우기"가 아니라 "이 테스트에 필요한 데이터 만들기"만 담당합니다. `beforeTest`
> 등록 순서상 `IntegrationTest`의 정리가 서브클래스의 정리보다 먼저 실행된다는 보장이 없으므로
> (Kotest는 등록 순서대로 실행), 서브클래스에 남아있는 개별 `deleteAll()`을 지우지 않으면
> 오히려 서브클래스가 방금 만든 데이터를 자신의 `deleteAll()`이 다시 지워버리는 새로운 버그가
> 생깁니다.

이 변경은 Step 4뿐 아니라 이미 존재하는 Step 1~3의 통합 테스트 파일에도 영향을 줍니다 — Step 4
범위를 넘어서는 공통 인프라 변경이므로, 아래 순서로 적용합니다.

1. `IntegrationTest.kt`를 위 코드로 교체.
2. `AuthControllerTest`, `UserAdminControllerTest`, `QuestControllerTest`,
   `AdminQuestSetControllerTest`의 `beforeTest`에서 `xxxJpaRepository.deleteAll()` 호출을 전부
   제거(데이터를 새로 만드는 코드는 그대로 둔다).
3. `./gradlew test`로 Step 1~3 테스트가 여전히 통과하는지 먼저 확인 — 이 단계가 깨지면 Step 4로
   넘어가지 않고 여기서 원인을 잡는다.
4. 이어서 아래 `ProgressControllerTest`를 작성 — `beforeTest`에 `deleteAll()`이 없다는 점,
   `afterTest`가 아예 없다는 점이 이전 버전과의 차이다.

## 4-7a. 통합 테스트 — `ProgressControllerTest`, `FeedbackControllerTest`

Step 3의 `TestAuth`, `TestUsers`, `TestQuestSets`, `TestQuests`를 그대로 재사용합니다.
`QuestAttempt` 픽스처는 이 Step에서 처음 필요하므로 `TestQuestAttempts` 오브젝트를 새로
만듭니다.

`src/test/kotlin/com/etude/support/TestQuestAttempts.kt`:

```kotlin
package com.etude.support

import com.etude.domain.progress.QuestAttempt
import com.etude.infrastructure.persistence.progress.QuestAttemptJpaRepository

object TestQuestAttempts {
    fun createAndSave(
        questAttemptJpaRepository: QuestAttemptJpaRepository,
        userId: Long,
        questId: Long,
        questSetId: Long,
        sessionId: String = "session-1",
        passed: Boolean = true,
    ): QuestAttempt = questAttemptJpaRepository.save(
        QuestAttempt(userId = userId, questId = questId, questSetId = questSetId, sessionId = sessionId, elapsedSec = null, passed = passed)
    )
}
```

`src/test/kotlin/com/etude/interfaces/api/progress/ProgressControllerTest.kt`:

```kotlin
package com.etude.interfaces.api.progress

import com.etude.domain.quest.QuestSet
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.progress.QuestAttemptJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.*
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class ProgressControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questJpaRepository: QuestJpaRepository,
    @Autowired private val questAttemptJpaRepository: QuestAttemptJpaRepository,
) : IntegrationTest({
    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    lateinit var publicSet: QuestSet

    beforeTest {
        val member = TestUsers.createMember(userJpaRepository)
        publicSet = TestQuestSets.createPublic(questSetJpaRepository)
        val quest = TestQuests.createAndSave(questJpaRepository, questSetId = publicSet.id)
        TestQuestAttempts.createAndSave(questAttemptJpaRepository, userId = member.id, questId = quest.id, questSetId = publicSet.id, passed = true)
    }

    // `deleteAll()`이 사라진 이유는 4-7의 `IntegrationTest.beforeTest { cleanAllTables() }`가
    // 이미 처리하기 때문입니다. Kotest는 `beforeTest`를 등록된 순서대로 실행하는데,
    // `IntegrationTest`의 `init` 블록이 `beforeTest { cleanAllTables() }`를 서브클래스의
    // `beforeTest`(위 블록)보다 먼저 등록하므로 — "전체 정리 → 이 테스트에 필요한 데이터 생성"
    // 순서가 항상 보장됩니다.

    "내 진행률을 조회하면" - {
        "완료한 퀘스트 수가 반영된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(get("/progress").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].total").value(1))
                .andExpect(jsonPath("$.data[0].completed").value(1))
        }
    }

    "토큰 없이 진행률을 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/progress")).andExpect(status().isUnauthorized)
        }
    }

    "리더보드를 조회하면" - {
        "member의 완료 수가 반영된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(get("/leaderboard").header("Authorization", "Bearer $token"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].completed").value(1))
        }
    }

    "토큰 없이 리더보드를 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/leaderboard")).andExpect(status().isUnauthorized)
        }
    }
})
```

> `afterTest`로 `quest_attempt`를 정리하는 이유는 `beforeTest`만으로는 부족하기 때문입니다 —
> Kotest는 여러 `IntegrationTest` 서브클래스(`QuestControllerTest`, `AdminQuestSetControllerTest`,
> `ProgressControllerTest` 등)가 Testcontainers MariaDB를 공유하고, 클래스 간 실행 순서를
> 보장하지 않습니다. `ProgressControllerTest`가 먼저 실행되어 `quest_attempt` 레코드를 남긴 채
> 끝나면, 그 뒤에 실행되는 `QuestControllerTest.beforeTest`의
> `questJpaRepository.deleteAll()`(quest 삭제)이 아직 남아있는 `quest_attempt.quest_id` FK 제약에
> 걸려 `DataIntegrityViolationException`을 던집니다 — 개별 클래스만 실행하면 이 오염이 없어
> 통과하지만, 전체 테스트를 한 번에 돌리면 실행 순서에 따라 실패한다. `quest`/`quest_set`을 참조하는
> 새 테이블(`quest_attempt`)을 도입한 이 Step에서 처음 드러난 문제이므로, Step 3의 테스트들은
> 건드리지 않고 `ProgressControllerTest`가 "내가 만든 건 내가 치운다" 원칙으로 스스로 정리한다.

`src/test/kotlin/com/etude/interfaces/api/feedback/FeedbackControllerTest.kt`:

```kotlin
package com.etude.interfaces.api.feedback

import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.feedback.FeedbackJpaRepository
import com.etude.support.IntegrationTest
import com.etude.support.TestAuth
import com.etude.support.TestUsers
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class FeedbackControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val feedbackJpaRepository: FeedbackJpaRepository,
) : IntegrationTest({
    fun loginAndGetToken(email: String, password: String): String = TestAuth.loginAndGetToken(mockMvc, email, password)

    beforeTest {
        TestUsers.createAdmin(userJpaRepository)
        TestUsers.createMember(userJpaRepository)
    }

    "로그인한 사용자가 피드백을 등록하면" - {
        "200을 반환하고 작성자가 기록된다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(
                post("/feedback")
                    .header("Authorization", "Bearer $token")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"page":"/quest-sets","body":"좋아요"}""")
            ).andExpect(status().isOk)

            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(get("/admin/feedback").header("Authorization", "Bearer $adminToken"))
                .andExpect(jsonPath("$.data[0].userName").value("멤버"))
        }
    }

    "토큰 없이 피드백을 등록하면" - {
        "200을 반환하고 작성자가 null로 기록된다" {
            mockMvc.perform(
                post("/feedback")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"page":"/quest-sets","body":"익명 피드백"}""")
            ).andExpect(status().isOk)

            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(get("/admin/feedback").header("Authorization", "Bearer $adminToken"))
                .andExpect(jsonPath("$.data[0].userName").doesNotExist())
        }
    }

    "빈 내용으로 피드백을 등록하면" - {
        "400을 반환한다" {
            mockMvc.perform(
                post("/feedback")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content("""{"page":"/quest-sets","body":"   "}""")
            ).andExpect(status().isBadRequest)
        }
    }

    "관리자가 피드백 목록을 조회하면" - {
        "최신순으로 반환된다" {
            mockMvc.perform(
                post("/feedback").contentType(MediaType.APPLICATION_JSON).content("""{"page":"/a","body":"첫번째"}""")
            )
            mockMvc.perform(
                post("/feedback").contentType(MediaType.APPLICATION_JSON).content("""{"page":"/b","body":"두번째"}""")
            )

            val adminToken = loginAndGetToken(TestUsers.ADMIN_EMAIL, TestUsers.ADMIN_PASSWORD)
            mockMvc.perform(get("/admin/feedback").header("Authorization", "Bearer $adminToken"))
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data[0].body").value("두번째"))
        }
    }

    "member 권한으로 피드백 목록을 조회하면" - {
        "403을 반환한다" {
            val token = loginAndGetToken(TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

            mockMvc.perform(get("/admin/feedback").header("Authorization", "Bearer $token"))
                .andExpect(status().isForbidden)
        }
    }

    "토큰 없이 피드백 목록을 조회하면" - {
        "401을 반환한다" {
            mockMvc.perform(get("/admin/feedback")).andExpect(status().isUnauthorized)
        }
    }
})
```

**검증**:
```bash
./gradlew test --tests "*.ProgressServiceTest" --tests "*.FeedbackServiceTest" --tests "*.ProgressControllerTest" --tests "*.FeedbackControllerTest"
```
2개 단위 테스트(진행률/리더보드 위임) + 1개 단위 테스트(피드백 trim) + 4개 통합 테스트(진행률/
리더보드) + 6개 통합 테스트(피드백) 모두 통과해야 합니다.

---

## 4-8. 수동 검증 (기존 Node 백엔드와 비교)

```bash
./gradlew bootRun
```

```bash
TOKEN=$(curl -s -X POST localhost:3001/auth/login -H "Content-Type: application/json" \
  -d '{"email":"member@okestro.com","password":"<멤버 비밀번호>"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)

curl -s localhost:3001/progress -H "Authorization: Bearer $TOKEN" | jq
curl -s localhost:3001/leaderboard -H "Authorization: Bearer $TOKEN" | jq
curl -s -X POST localhost:3001/feedback -H "Content-Type: application/json" \
  -d '{"page":"/quest-sets","body":"수동 검증 피드백"}' | jq

ADMIN_TOKEN=$(curl -s -X POST localhost:3001/auth/login -H "Content-Type: application/json" \
  -d '{"email":"admin@okestro.com","password":"<관리자 비밀번호>"}' | grep -o '"token":"[^"]*' | cut -d'"' -f4)
curl -s localhost:3001/admin/feedback -H "Authorization: Bearer $ADMIN_TOKEN" | jq
```

기존 Node.js 백엔드(`backend/`, 포트 다름)에서 동일한 요청을 보내 응답 구조(필드명, 정렬 순서)가
`ApiResponse<T>` 래핑을 제외하고 동일한 데이터를 담는지 눈으로 비교합니다.

## 완료 기준

- [ ] 4-7의 `IntegrationTest` 공통 정리 적용 — `AuthControllerTest`,
      `UserAdminControllerTest`, `QuestControllerTest`, `AdminQuestSetControllerTest`의
      `beforeTest`에서 개별 `deleteAll()` 호출을 제거하고, `./gradlew test`로 Step 1~3 테스트가
      단독 실행/전체 실행 양쪽에서 통과하는지 먼저 확인.
- [ ] 위 인수 조건 체크리스트 전부 통과 (`ProgressControllerTest`, `FeedbackControllerTest`)
- [ ] `ProgressServiceTest`, `FeedbackServiceTest` 단위 테스트 통과
- [ ] `./gradlew test` **전체 클래스를 한 번에** 실행해도 Step 1~4 테스트 모두 통과 — 개별 클래스만
      실행했을 때 통과하는 것으로는 부족하다(4-7에서 다룬 실행 순서 의존 버그가 재발하지 않았는지
      확인하는 것이 이 Step의 핵심 검증 포인트).
- [ ] 수동 검증(4-8)으로 기존 Node.js 백엔드와 응답 데이터 비교 완료
