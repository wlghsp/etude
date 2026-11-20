# 명세 — 세트 557 격리 수준 4종 직접 재현

> 상태: 작성 (2026-11-20). 샌드박스 `linux-db`, 카테고리 `데이터베이스`, 단원 20, display_order 817. 선행: 502(트랜잭션·락 기초, 두 번째 세션을 백그라운드로 띄우는 방식). 근거: `docs/research/content_gap_2026-11-19/gap_db.md` M2(격리 수준 4종 재현). 생성: `scripts/content-gen/new_sets/set557.py`.

MariaDB 10.6 의 격리 변수는 `tx_isolation` 이다(`transaction_isolation` 은 11.1 부터). 502 의 FOR UPDATE·락 대기·데드락과 겹치지 않게 "무엇이 보이는가"에 집중한다.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set557.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 557` 실습 7개 통과 (정답 통과, 무행동 실패)
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
