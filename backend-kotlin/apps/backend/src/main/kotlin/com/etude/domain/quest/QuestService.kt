package com.etude.domain.quest

import com.etude.domain.auth.UserRepository
import com.etude.domain.auth.UserRole
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
            questSet.toAdminSummary(accessUsers)
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