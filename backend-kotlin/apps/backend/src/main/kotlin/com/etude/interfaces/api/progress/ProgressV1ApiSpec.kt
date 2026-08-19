package com.etude.interfaces.api.progress

import com.etude.domain.auth.JwtPayload
import com.etude.domain.progress.MemberProgress
import com.etude.domain.progress.QuestSetProgress
import com.etude.infrastructure.security.LoginUser
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Progress V1 API", description = "진행률/리더보드 조회 API 입니다.")
interface ProgressV1ApiSpec {
    @Operation(summary = "내 진행률 조회", description = "로그인한 사용자의 퀘스트셋별 진행률을 조회합니다.")
    fun getProgress(@LoginUser payload: JwtPayload): ApiResponse<List<QuestSetProgress>>

    @Operation(summary = "리더보드 조회", description = "member 역할 사용자의 진행률 순위를 조회합니다.")
    fun getLeaderboard(@LoginUser payload: JwtPayload): ApiResponse<List<MemberProgress>>
}