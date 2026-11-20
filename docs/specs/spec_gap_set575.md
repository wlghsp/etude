# 명세 — 세트 575 연결 장애 상황집(2) 방화벽·NAT·경로

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 43(연결이 안 될 때), display_order 835. 선행: 117, 571, 572, 573. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N12(상황집). 생성: `scripts/content-gen/new_sets/set575.py`. 방화벽·캡처 도구와 권한이 없어 현장에서 모은 출력(샘플)을 읽고 원인을 좁힌다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set575.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 575` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
