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

    @Operation(summary = "퀘스셋 목록 조회", description = "지정한 퀘스트셋에 속한 퀘스트 목록을 순서대로 조회합니다.")
    fun getQuests(questSetId: Long, payload: JwtPayload): ApiResponse<List<QuestSummary>>
}