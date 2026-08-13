# Repository 확장 함수로 `findById ?: throw` 통일

근거: [docs/research/reference_projects_action_items.md 1-2](../research/reference_projects_action_items.md)

## 문제

"ID로 조회하고, 없으면 도메인 예외를 던진다"는 패턴이 서비스 코드에 반복되고 있다.

```kotlin
// UserService.kt:33
val user = userRepository.findById(id) ?: throw UserNotFoundException()

// UserService.kt:39
val user = userRepository.findById(userId) ?: throw UserNotFoundException()

// QuestService.kt:50
val questSet = questSetRepository.findById(questSetId) ?: throw QuestSetNotFoundException()
```

지금은 3곳뿐이지만, 매번 `findById(...) ?: throw XxxNotFoundException()`을 손으로 쓰다 보면
언젠가 한 곳에서 `?: throw`를 빼먹거나 다른 예외 타입을 잘못 던지는 실수가 생길 수 있다.

## 방향

리포지토리 인터페이스별로 "ID로 조회하고 없으면 던진다"를 뜻하는 확장 함수 `getById`를 하나씩
추가한다. 서비스 코드는 `findById(id) ?: throw ...`를 `getById(id)` 한 줄로 줄여 쓴다.

```kotlin
fun UserRepository.getById(id: Long): User = findById(id) ?: throw UserNotFoundException()
```

**주의 — 모든 `findById`를 바꾸는 게 아니다.** `QuestService.canAccess`의
`questSetRepository.findById(questSetId) ?: return false`처럼 "없으면 예외가 아니라 다른 값을
반환"하는 곳은 이 패턴의 대상이 아니다. "없으면 무조건 예외"인 호출부만 `getById`로 바꾼다.

## 구현

### 1. `UserRepository` 확장 함수 (`domain/auth/UserRepository.kt`)

인터페이스 파일 안에 확장 함수를 같이 둔다 — 리포지토리 하나당 파일 하나이므로 별도 파일을 만들
필요는 없다.

```kotlin
package com.etude.domain.auth

interface UserRepository {
    fun findByEmail(email: String): User?
    fun findById(id: Long): User?
    fun existsByEmail(email: String): Boolean
    fun findAllByRole(role: UserRole): List<User>
    fun save(user: User): User
}

fun UserRepository.getById(id: Long): User = findById(id) ?: throw UserNotFoundException()
```

### 2. `QuestSetRepository` 확장 함수 (`domain/quest/QuestSetRepository.kt`)

```kotlin
package com.etude.domain.quest

interface QuestSetRepository {
    fun findById(id: Long): QuestSet?
    fun findAllPublicOrAccessibleBy(userId: Long): List<QuestSet>
    fun findAll(): List<QuestSet>
    fun save(questSet: QuestSet): QuestSet
}

fun QuestSetRepository.getById(id: Long): QuestSet = findById(id) ?: throw QuestSetNotFoundException()
```

### 3. 호출부 교체

**`UserService.kt`**

```kotlin
fun resetPassword(id: Long, newPassword: String) {
    val user = userRepository.getById(id)
    user.changePassword(passwordEncoder.encode(newPassword))
    userRepository.save(user)
}

fun changeOwnPassword(userId: Long, currentPassword: String, newPassword: String) {
    val user = userRepository.getById(userId)

    if (!user.matchesPassword(currentPassword, passwordEncoder)) throw WrongPasswordException()

    user.changePassword(passwordEncoder.encode(newPassword))
    userRepository.save(user)
}
```

**`QuestService.kt`**

```kotlin
fun setPublic(questSetId: Long, isPublic: Boolean) {
    val questSet = questSetRepository.getById(questSetId)

    questSet.changePublic(isPublic)
    questSetRepository.save(questSet)
}
```

> `canAccess`의 `questSetRepository.findById(questSetId) ?: return false`는 그대로 둔다 — 이
> 호출은 "없으면 예외"가 아니라 "없으면 접근 불가"라는 별개의 의미라 `getById`로 바꾸면 오히려
> 의도가 왜곡된다.

### 4. `QuestRepository`, `QuestSetAccessRepository`는 지금은 대상 없음

`QuestRepository.findById`, `QuestSetAccessRepository`에는 "없으면 예외" 패턴으로 호출하는 곳이
현재 없다 (`QuestSetAccessRepository`는 `findById` 자체가 없다). 지금은 확장 함수를 추가하지
않는다 — 실제로 그 패턴이 필요해지는 시점에 같은 방식으로 추가한다.

## 검증 기준

- [ ] `UserService.resetPassword`, `UserService.changeOwnPassword`,
      `QuestService.setPublic`이 `getById`를 쓰고, `findById(...) ?: throw`가 이 세 곳에서
      사라졌다.
- [ ] `QuestService.canAccess`의 `findById(questSetId) ?: return false`는 그대로 남아있다 —
      실수로 `getById`로 바꾸지 않았는지 확인.
- [ ] 컴파일 통과, 기존 테스트(`UserServiceTest`, `QuestServiceTest`,
      `UserAdminControllerTest`, `QuestControllerTest`, `AdminQuestSetControllerTest`) 수정 없이
      통과 — 동작을 바꾸지 않는 리팩터링이므로 테스트 결과도 동일해야 한다.
- [ ] 새로 리포지토리를 추가하거나 "없으면 예외" 조회가 반복되기 시작하면, 이 문서의 패턴대로
      해당 리포지토리 인터페이스 파일에 `getById` 확장 함수를 함께 추가한다.
