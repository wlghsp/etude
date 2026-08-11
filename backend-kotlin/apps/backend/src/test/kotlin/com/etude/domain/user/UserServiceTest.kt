package com.etude.domain.user

import com.etude.domain.auth.EmailAlreadyExistsException
import com.etude.domain.auth.PasswordEncoder
import com.etude.domain.auth.User
import com.etude.domain.auth.UserNotFoundException
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import com.etude.domain.auth.WrongPasswordException
import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.FreeSpec
import io.kotest.matchers.collections.shouldContainExactly
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify

class UserServiceTest : FreeSpec({
    val userRepository = mockk<UserRepository>()
    val passwordEncoder = mockk<PasswordEncoder>()
    val userService = UserService(userRepository, passwordEncoder)

    "전체 회원 목록을 조회할 때" - {
        "이름 오름차순으로 정렬된 요약 목록을 반환한다" {
            // given - id는 BaseEntity에서 `val id: Long = 0`으로 고정되어 생성자로 못 채운다.
            // 이 테스트는 id 값 자체를 검증하지 않으므로 실제 User 생성자로 충분하다.
            val userA = User(name = "최지호", email = "jiho@etude.com", password = "hash1", role = UserRole.member)
            val userB = User(name = "가나다", email = "abc@etude.com", password = "hash2", role = UserRole.member)
            every { userRepository.findAllByRole(UserRole.member) } returns listOf(userA, userB)

            // when
            val result = userService.getAllMembers()

            // then
            result.map { it.name } shouldContainExactly listOf("가나다", "최지호")
        }
    }

    "신규 사용자 생성을 요청했을 때" - {
        "이메일이 중복되지 않으면" - {
            "비밀번호를 인코딩하여 사용자를 저장하고 요약 정보를 반환한다" {
                // given - save()가 반환하는 값을 그대로 검증하므로, 인자로 넘어온 User를 그대로 돌려주게 스텁한다.
                every { userRepository.existsByEmail("new@etude.com")} returns false
                every { passwordEncoder.encode("raw-pw") } returns "encoded-pw"
                every { userRepository.save(any()) } answers { firstArg<User>() }

                // when
                val result = userService.createUser("최지호", "new@etude.com", "raw-pw")

                // then
                result.email shouldBe "new@etude.com"
                result.role shouldBe UserRole.member
                verify { userRepository.save(any()) }
            }

            "이메일이 이미 존재하면" - {
                "EmailAlreadyExistsException을 던진다" {
                    // given
                    every { userRepository.existsByEmail("dup@etude.com") } returns true

                    // when & then
                    shouldThrow<EmailAlreadyExistsException> {
                        userService.createUser("최지호", "dup@etude.com", "raw-pw")
                    }

                }
            }
        }
    }

    "관리자가 비밀번호를 초기화할 때" - {
        "대상 사용자가 존재하면" - {
            "새 비밀번호를 인코딩하여 저장한다" {
                // given - password는 private이라 직접 못 읽으므로, matchePassword()로 간접 검증한다.
                val user = User(name = "최지호", email = "jiho@etude.com", password = "old-hash", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.encode("new-pw") } returns "new-hash"
                every { passwordEncoder.matches("new-pw", "new-hash") } returns true
                every { userRepository.save(user) } returns user

                // when
                userService.resetPassword(1L, "new-pw")

                // then
                user.matchesPassword("new-pw", passwordEncoder) shouldBe true
                verify { userRepository.save(user) }
            }

            "대상 사용자가 존재하지 않으면" - {
                "UserNotFoundException을 던진다" {
                    // given
                    every { userRepository.findById(999L) } returns null

                    // when & then
                    shouldThrow<UserNotFoundException> {
                        userService.resetPassword(999L, "new-pw")
                    }
                }
            }
        }
    }

    "본인이 비밀번호를 변경할 때" -  {
        "현재 비밀번호가 일치하면" -  {
            "새 비밀번호로 변경한다" {
                // given
                val user = User(name = "최지호", email = "jiho@etude.com", password = "old-hash", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.matches("current-pw", "old-hash") } returns true
                every { passwordEncoder.encode("new-pw") } returns "new-hash"
                every { passwordEncoder.matches("new-pw", "new-hash") } returns true
                every { userRepository.save(user) } returns user

                // when
                userService.changeOwnPassword(1L, "current-pw", "new-pw")

                // then
                user.matchesPassword("new-pw", passwordEncoder) shouldBe true
                verify { userRepository.save(user) }
            }
        }

        "현재 비밀번호가 일치하지 않으면" - {
            "WrongPasswordException을 던진다" {
                // given
                val user = User(name = "최지호", email = "jiho@etude.com", password = "old-hash", role = UserRole.member)
                every { userRepository.findById(1L) } returns user
                every { passwordEncoder.matches("wrong-pw", "old-hash") } returns false

                // when & then
                shouldThrow<WrongPasswordException> {
                    userService.changeOwnPassword(1L, "wrong-pw", "new-pw")
                }
            }
        }

        "대상 사용자가 존재하지 않으면" - {
            "UserNotFoundException을 던진다" {
                // given
                every { userRepository.findById(999L) } returns null

                // when & then
                shouldThrow<UserNotFoundException> {
                    userService.changeOwnPassword(999L, "current-pw", "new-pw")
                }
            }
        }
    }


})