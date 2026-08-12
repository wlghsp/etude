package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QQuestSet.questSet
import com.etude.domain.quest.QQuestSetAccess.questSetAccess
import com.etude.domain.quest.QuestSet
import com.querydsl.jpa.JPAExpressions
import com.querydsl.jpa.impl.JPAQueryFactory
import org.springframework.stereotype.Repository

@Repository
class QuestSetQuerydslRepository(
    private val queryFactory: JPAQueryFactory
) {
    fun findAllPublicOrAccessibleBy(userId: Long): List<QuestSet> =
        queryFactory
            .selectFrom(questSet)
            .where(
                questSet.isPublic.isTrue
                    .or(
                        JPAExpressions
                            .selectOne()
                            .from(questSetAccess)
                            .where(
                                questSetAccess.questSetId.eq(questSet.id),
                                    questSetAccess.userId.eq(userId),
                            )
                            .exists()
                    )
            )
            .fetch()

}