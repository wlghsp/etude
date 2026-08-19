package com.etude.infrastructure.persistence.progress

import com.etude.domain.auth.QUser.user
import com.etude.domain.auth.UserRole
import com.etude.domain.progress.QQuestAttempt.questAttempt
import com.etude.domain.progress.QuestSetProgress
import com.etude.domain.progress.QuestSetProgressDetail
import com.etude.domain.quest.QQuest.quest
import com.etude.domain.quest.QQuestSet.questSet
import com.querydsl.core.types.Projections
import com.querydsl.core.types.dsl.CaseBuilder
import com.querydsl.core.types.dsl.Expressions
import com.querydsl.jpa.impl.JPAQueryFactory
import org.springframework.stereotype.Repository
import kotlin.jvm.java

data class LeaderboardSummaryRow(val userId: Long, val userName: String, val total: Long, val completed: Long)
data class LeaderboardDetailRow(val userId: Long, val detail: QuestSetProgressDetail)

@Repository
class QuestAttemptQuerydslRepository(
    private val queryFactory: JPAQueryFactory,
) {
    fun findProgressByUserId(userId: Long): List<QuestSetProgress> {
        return queryFactory.select(
            Projections.constructor(
                QuestSetProgress::class.java,
                questSet.id,
                questSet.title,
                questSet.category,
                quest.id.countDistinct(),
                CaseBuilder()
                    .`when`(questAttempt.passed.isTrue)
                    .then(questAttempt.questId)
                    .otherwise(Expressions.nullExpression())
                    .countDistinct(),
            )
        ).from(questSet)
            .join(quest).on(quest.questSetId.eq(questSet.id))
            .leftJoin(questAttempt).on(
                questAttempt.questId.eq(quest.id)
                    .and(questAttempt.userId.eq(userId))
            )
            .groupBy(questSet.id, questSet.title, questSet.category)
            .orderBy(questSet.id.asc())
            .fetch()
    }

    fun findLeaderboardSummary(): List<LeaderboardSummaryRow> =
        queryFactory
            .select(
                Projections.constructor(
                    LeaderboardSummaryRow::class.java,
                    user.id, user.name,
                    quest.id.countDistinct(),
                    passedCountExpression()
                )
            )
            .from(user)
            .join(quest).on(quest.id.isNotNull) // CROSS JOIN 대응 - quest 전체와 곱
            .leftJoin(questAttempt).on(questAttempt.questId.eq(quest.id).and(questAttempt.userId.eq(user.id)))
            .where(user.role.eq(UserRole.member))
            .groupBy(user.id, user.name)
            .orderBy(passedCountExpression().desc(), user.name.asc())
            .fetch()

    fun findLeaderboardDetail(): List<LeaderboardDetailRow> =
        queryFactory
            .select(
                Projections.constructor(
                    LeaderboardDetailRow::class.java,
                    user.id,
                    Projections.constructor(
                        QuestSetProgressDetail::class.java,
                        questSet.id, questSet.title, questSet.category,
                        quest.id.countDistinct(),
                        passedCountExpression(),
                    ),
                )
            )
            .from(user)
            .join(questSet).on(questSet.id.isNotNull)
            .join(quest).on(quest.questSetId.eq(questSet.id))
            .leftJoin(questAttempt).on(questAttempt.questId.eq(quest.id).and(questAttempt.userId.eq(user.id)))
            .where(user.role.eq(UserRole.member))
            .groupBy(user.id, questSet.id)
            .orderBy(user.id.asc(), questSet.id.asc())
            .fetch()

    private fun passedCountExpression() =
        CaseBuilder()
            .`when`(questAttempt.passed.isTrue)
            .then(questAttempt.questId)
            .otherwise(Expressions.nullExpression())
            .countDistinct()
}