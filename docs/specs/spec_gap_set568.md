# 명세 — 세트 568 ping·traceroute·mtr 읽기

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(비특권), 카테고리 `네트워크`, 단원 47(네트워크 기초), display_order 828. 선행: 379. 근거: `docs/research/content_gap_2026-11-19/gap_network.md` 백로그 N3(ping·traceroute·mtr 읽기). 생성: `scripts/content-gen/new_sets/set568.py`. 외부 네트워크 상태가 환경마다 달라 127.0.0.1 실행과 고정 샘플 출력 읽기로 구성한다. mtr 는 이미지에 없어 샘플로만 다룬다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set568.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 568` 실습 6개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
