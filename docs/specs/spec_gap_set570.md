# 명세 — 세트 570 dig 출력 읽기와 이름 해석 경로

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 47, display_order 830. 선행: 405. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N5(dig 로 DNS 질의). 생성: `scripts/content-gen/new_sets/set570.py`. dig·외부 DNS 에 의존하면 환경마다 달라 고정 샘플 출력을 읽는다. /etc/hosts·getent 는 실제 환경에서 확인한다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set570.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 570` 실습 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
