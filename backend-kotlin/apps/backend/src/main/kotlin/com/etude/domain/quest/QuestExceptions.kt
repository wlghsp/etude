package com.etude.domain.quest

class QuestSetAccessDeniedException(message: String = "이 세트에 접근할 권한이 없습니다.") : RuntimeException(message)
class QuestSetNotFoundException(message: String = "존재하지 않는 퀘스트셋입니다.") : RuntimeException(message)