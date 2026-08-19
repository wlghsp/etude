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