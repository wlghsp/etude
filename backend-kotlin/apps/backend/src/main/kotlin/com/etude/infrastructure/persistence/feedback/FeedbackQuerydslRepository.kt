package com.etude.infrastructure.persistence.feedback

import com.etude.domain.auth.QUser.user
import com.etude.domain.feedback.FeedbackSummary
import com.etude.domain.feedback.QFeedback.feedback
import com.etude.domain.quest.QQuest.quest
import com.etude.domain.quest.QQuestSet.questSet
import com.querydsl.core.types.Projections
import com.querydsl.jpa.impl.JPAQueryFactory
import org.springframework.stereotype.Repository

@Repository
class FeedbackQuerydslRepository (
    private val queryFactory: JPAQueryFactory
){
    fun findAllOrderByCreatedAtDesc(): List<FeedbackSummary> =
        queryFactory
            .select(
                Projections.constructor(
                    FeedbackSummary::class.java,
                    feedback.id, user.name,
                    feedback.page, questSet.title, quest.title, feedback.body, feedback.createdAt,
                )
            )
            .from(feedback)
            .leftJoin(user).on(feedback.userId.eq(user.id))
            .leftJoin(questSet).on(feedback.questSetId.eq(questSet.id))
            .leftJoin(quest).on(feedback.questId.eq(quest.id))
            .orderBy(feedback.createdAt.desc(), feedback.id.desc())
            .fetch()
}