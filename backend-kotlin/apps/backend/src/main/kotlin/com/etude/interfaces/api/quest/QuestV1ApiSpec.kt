package com.etude.interfaces.api.quest

import com.etude.domain.auth.JwtPayload
import com.etude.domain.quest.QuestSetSummary
import com.etude.domain.quest.QuestSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag

@Tag(name = "Quest V1 API", description = "퀘스트/퀘스트셋 조회 API 입니다.")
interface QuestV1ApiSpec {
    @Operation(summary = "퀘스트셋 목록 조회", description = "로그인한 사용자가 접근 가능한 퀘스트셋 목록을 조회합니다.")
    fun getQuestSets(payload: JwtPayload): ApiResponse<List<QuestSetSummary>>

    @Operation(summary = "퀘스트셋 목록 조회", description = "지정한 퀘스트셋에 속한 퀘스트 목록을 순서대로 조회합니다.")
    fun getQuests(questSetId: Long, payload: JwtPayload): ApiResponse<List<QuestSummary>>

    @Operation(summary = "퀘스트 채점", description = "컨테이너 안에서 채점 명령을 실행하고, 로그인 상태면 시도 기록을 남깁니다.")
    fun grade(request: GradeRequest, payload: JwtPayload?): ApiResponse<GradeResponse>
}

data class GradeRequest(
    val containerId: String,
    val questId: Long,
    val questSetId: Long,
    val sessionId: String,
    val elapsedSec: Int? = null,
    val hintUsed: Boolean = false,
    val solutionUsed: Boolean = false,
)

data class GradeResponse(val passed: Boolean)