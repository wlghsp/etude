package com.etude.interfaces.api.quest

import com.etude.domain.terminal.ContainerRuntime
import com.etude.domain.terminal.ContainerSpec
import com.etude.infrastructure.persistence.auth.UserJpaRepository
import com.etude.infrastructure.persistence.progress.QuestAttemptJpaRepository
import com.etude.infrastructure.persistence.quest.QuestJpaRepository
import com.etude.infrastructure.persistence.quest.QuestSetJpaRepository
import com.etude.support.*
import io.kotest.matchers.shouldBe
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.ResultActions
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

@AutoConfigureMockMvc
class QuestGradeControllerTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val containerRuntime: ContainerRuntime,
    @Autowired private val userJpaRepository: UserJpaRepository,
    @Autowired private val questSetJpaRepository: QuestSetJpaRepository,
    @Autowired private val questJpaRepository: QuestJpaRepository,
    @Autowired private val questAttemptJpaRepository: QuestAttemptJpaRepository,
) : IntegrationTest({
    var userId = 0L
    var questSetId = 0L
    lateinit var containerId: String

    /// 채점 명령이 실행될 컨테이너 - 테스트마다 하나 띄우고 끝나면 지운다.
    // TerminalWebSocketHandlerTest와 같은 이유로 로컬에 이미 있는 etude-linux 이미지를 쓴다
    // (createContainer는 이미지를 자동으로 pull하지 않는다)
    beforeTest {
        userId = TestUsers.createMember(userJpaRepository).id
        questSetId = TestQuestSets.createPublic(questSetJpaRepository).id

        containerId = containerRuntime.createContainer(
            ContainerSpec(
                image = "etude-linux",
                binds = emptyList(),
                command = listOf("sh", "-c", "trap 'exit 0' TERM; sleep 300 & wait"),
                tty = false,
                openStdin = false,
            )
        )
        containerRuntime.startContainer(containerId)
    }

    afterTest {
        containerRuntime.stopAndRemove(containerId)
    }

    fun saveQuest(gradeCmd: String): Long = TestQuests.createAndSave(questJpaRepository, questSetId = questSetId, gradeCmd = gradeCmd).id

    fun grade(questId: Long, token: String? = null): ResultActions =
        mockMvc.perform(
            post("/grade")
                .contentType(MediaType.APPLICATION_JSON)
                .apply { token?.let { header("Authorization", "Bearer $it") } }
                .content(
                    """
                    {
                      "containerId": "$containerId",
                      "questId": $questId,
                      "questSetId": $questSetId,
                      "sessionId": "session-1",
                      "elapsedSec": 42,
                      "hintUsed": true,
                      "solutionUsed": false
                    }
                    """.trimIndent()
                )
        )

    fun memberToken(): String = TestAuth.loginAndGetToken(mockMvc, TestUsers.MEMBER_EMAIL, TestUsers.MEMBER_PASSWORD)

    "채점 명령이 성공하면" - {
        "passed: true를 응답하고, 토큰이 있으면 quest_attempt에 기록한다" {
            val questId = saveQuest("""["true"]""")

            grade(questId, memberToken())
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))

            val attempts = questAttemptJpaRepository.findAll()
            attempts.size shouldBe 1
            attempts[0].userId shouldBe userId
            attempts[0].questId shouldBe questId
            attempts[0].questSetId shouldBe questSetId
            attempts[0].sessionId shouldBe "session-1"
            attempts[0].elapsedSec shouldBe 42
            attempts[0].hintUsed shouldBe true
            attempts[0].solutionUsed shouldBe false
            attempts[0].passed shouldBe true
        }

        "grade_cmd의 \$NS를 quest-{컨테이너ID 앞 8자}로 치환해서 실행한다" {
            // 치환이 틀리면 test가 실패(exit 1)해서 passed=false가 된다
            val questId = saveQuest(
                """["sh", "-c", "test ${'$'}NS = quest-${containerId.take(8)}"]"""
            )

            grade(questId)
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))
        }
    }

    "토큰 없이 호출하면" - {
        "401이 아니라 채점 결과만 응답하고 기록은 남기지 않는다" {
            val questId = saveQuest("""["true"]""")

            grade(questId)
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))

            questAttemptJpaRepository.count() shouldBe 0
        }
    }

    "유효하지 않은 토큰으로 호출하면" - {
        "401이 아니라 채점 결과만 응답하고 기록은 남기지 않는다" {
            val questId = saveQuest("""["true"]""")

            grade(questId, token = "invalid.token.value")
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(true))

            questAttemptJpaRepository.count() shouldBe 0
        }
    }

    "채점 명령이 실패하면" - {
        "passed: false를 응답하고, 토큰이 있으면 실패한 시도도 기록한다" {
            val questId = saveQuest("""["false"]""")

            grade(questId, memberToken())
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(false))

            val attempts = questAttemptJpaRepository.findAll()
            attempts.size shouldBe 1
            attempts[0].passed shouldBe false
        }
    }

    "존재하지 않는 questId로 호출하면" - {
        "예외 없이 passed: false를 응답한다" {
            grade(questId = 999_999L)
                .andExpect(status().isOk)
                .andExpect(jsonPath("$.data.passed").value(false))
        }
    }

})