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
        @PathVariable questSetId: Long, httpRequest: HttpServletRequest
    ): ApiResponse<List<QuestSummary>> {
        val payload = httpRequest.getAttribute(REQUEST_ATTR_JWT_PAYLOAD) as JwtPayload
        return ApiResponse.success(questFacade.getQuests(payload.userId, payload.role, questSetId))
    }
}