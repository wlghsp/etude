package com.etude.interfaces.api.quest

import com.etude.domain.quest.QuestSetAdminSummary
import com.etude.domain.quest.QuestSetSummary
import com.etude.domain.quest.QuestSummary
import com.etude.interfaces.api.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.servlet.http.HttpServletRequest

@Tag(name = "Admin Quest Set V1 API", description = "관리자용 퀘스트셋 관리 API 입니다.")
interface AdminQuestSetV1ApiSpec {
    @Operation(summary = "퀘스트셋 목록 조회(관리자)", description = "전체 퀘스트셋과 접근 권한 부여 현황을 조회합니다.")
    fun getQuestSets(): ApiResponse<List<QuestSetAdminSummary>>

    @Operation(summary = "퀘스트셋 공개 여부 변경", description = "퀘스트셋을 공개/비공개로 전환합니다.")
    fun setPublic(id: Long, request: SetPublicRequest): ApiResponse<Unit>

    @Operation(summary = "접근 권한 부여", description = "지정한 사용자에게 비공개 퀘스트셋 접근 권한을 부여합니다.")
    fun grantAccess(id: Long, request: GrantAccessRequest): ApiResponse<Unit>

    @Operation(summary = "접근 권한 회수", description = "지정한 사용자의 퀘스트셋 접근 권한을 회수합니다.")
    fun revokeAccess(id: Long, userId: Long): ApiResponse<Unit>
}