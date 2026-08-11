package com.etude.domain.user

import com.etude.domain.auth.EmailAlreadyExistsException
import com.etude.domain.auth.PasswordEncoder
import com.etude.domain.auth.User
import com.etude.domain.auth.UserNotFoundException
import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
import com.etude.domain.auth.UserSummary
import com.etude.domain.auth.WrongPasswordException
import org.springframework.stereotype.Service

@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
) {
    fun getAllMembers(): List<UserSummary> = userRepository.findAllByRole(UserRole.member)
                                                                .sortedBy { it.name }
                                                                .map { UserSummary(it.id, it.name, it.email, it.role) }

    fun createUser(name: String, email: String, password: String): UserSummary {
        if (userRepository.existsByEmail(email)) throw EmailAlreadyExistsException()

        val user = userRepository.save(User(name, email, passwordEncoder.encode(password), UserRole.member))

        return UserSummary(user.id, user.name, user.email, user.role)
    }

    fun resetPassword(id: Long, newPassword: String) {
        val user = userRepository.findById(id) ?: throw UserNotFoundException()
        user.changePassword(passwordEncoder.encode(newPassword))
        userRepository.save(user)
    }

    fun changeOwnPassword(userId: Long, currentPassword: String, newPassword: String) {
        val user = userRepository.findById(userId) ?: throw UserNotFoundException()

        if (!user.matchesPassword(currentPassword, passwordEncoder)) throw WrongPasswordException()

        user.changePassword(passwordEncoder.encode(newPassword))
        userRepository.save(user)
    }
}