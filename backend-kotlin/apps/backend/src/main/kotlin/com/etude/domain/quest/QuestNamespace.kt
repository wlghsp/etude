package com.etude.domain.quest

/** 퀘스트 컨테이너 하나가 쓰는 k8s namespace 이름. 세션 시작(생성/치환)과 채점(치환)이 같은 값을 써야 한다. */
fun questNamespace(containerId: String): String = "quest-${containerId.take(8)}"