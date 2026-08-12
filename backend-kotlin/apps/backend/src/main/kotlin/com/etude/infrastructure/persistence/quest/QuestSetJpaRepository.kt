package com.etude.infrastructure.persistence.quest

import com.etude.domain.quest.QuestSet
import org.springframework.data.jpa.repository.JpaRepository

interface QuestSetJpaRepository : JpaRepository<QuestSet, Long>