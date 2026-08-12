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
    fun getQuestSets(userId: Long, role: UserRole): List<QuestSetSummary> = questService.getQuestSets(userId, role)

    fun getQuests(userId: Long, role: UserRole, questSetId: Long): List<QuestSummary> = questService.getQuests(userId, role, questSetId)

    fun getQuestSetsForAdmin(): List<QuestSetAdminSummary> = questService.getQuestSetsForAdmin()

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