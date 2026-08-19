package com.etude.application.progress

import com.etude.domain.progress.MemberProgress
import com.etude.domain.progress.ProgressService
import com.etude.domain.progress.QuestSetProgress
import org.springframework.stereotype.Component

@Component
class ProgressFacade(
    private val progressService: ProgressService,
) {
    fun getProgress(userId: Long) : List<QuestSetProgress> = progressService.getProgress(userId)
    fun getLeaderboard(): List<MemberProgress> = progressService.getLeaderboard()
}