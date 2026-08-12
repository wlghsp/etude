package com.etude.interfaces.api.quest

import com.etude.application.quest.QuestFacade
import com.etude.domain.quest.QuestSetAdminSummary
import com.etude.interfaces.api.ApiResponse
import jakarta.validation.Valid
import jakarta.validation.constraints.NotNull
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class SetPublicRequest(
    @field:NotNull val isPublic: Boolean,
)

data class GrantAccessRequest(
    @field:NotNull val userId: Long,
)


@RestController
@RequestMapping("/admin/quest-sets")
class AdminQuestSetV1Controller(
    private val questFacade: QuestFacade,
) : AdminQuestSetV1ApiSpec {
    @GetMapping
    override fun getQuestSets(): ApiResponse<List<QuestSetAdminSummary>> = ApiResponse.success(questFacade.getQuestSetsForAdmin())

    @PatchMapping("/{id}")
    override fun setPublic(
        @PathVariable id: Long,
        @Valid @RequestBody request: SetPublicRequest
    ): ApiResponse<Unit> {
        questFacade.setPublic(id, request.isPublic)
        return ApiResponse.success<Unit>()
    }

    @PostMapping("/{id}/access")
    override fun grantAccess(
        @PathVariable id: Long,
        @Valid @RequestBody request: GrantAccessRequest
    ): ApiResponse<Unit> {
        questFacade.grantAccess(id, request.userId)
        return ApiResponse.success<Unit>()
    }

    @DeleteMapping("/{id}/access/{userId}")
    override fun revokeAccess(
        @PathVariable id: Long,
        @PathVariable userId: Long): ApiResponse<Unit> {
        questFacade.revokeAccess(id, userId)
        return ApiResponse.success<Unit>()
    }
}