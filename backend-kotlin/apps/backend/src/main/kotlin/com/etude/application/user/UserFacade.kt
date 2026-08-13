package com.etude.application.user

import com.etude.domain.auth.UserSummary
import com.etude.domain.user.UserService
import org.springframework.stereotype.Component

@Component
class UserFacade(
    private val userService: UserService,
) {
    fun getAllMembers(): List<UserSummary> = userService.getAllMembers()

    fun createUser(name: String, email: String, password: String): UserSummary =
        userService.createUser(name, email, password)

    fun resetPassword(id: Long, newPassword: String) {
        userService.resetPassword(id, newPassword)
    }

    fun changeOwnPassword(userId: Long, currentPassword: String, newPassword: String) {
        userService.changeOwnPassword(userId, currentPassword, newPassword)
    }
}
