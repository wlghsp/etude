# 명세 — 세트 558 락 종류 직접 만나기: 공유 락·갭 락·메타데이터 락

> 상태: 작성 (2026-11-20). 샌드박스 `linux-db`, 카테고리 `데이터베이스`, 단원 20, display_order 818. 선행: 502·557. 근거: `gap_db.md` M2(락 변형: 공유락·갭락·메타데이터 락). 생성: `scripts/content-gen/new_sets/set558.py`. 데드락·FOR UPDATE 기본은 502 에서 다루므로 제외.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set558.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 558` 실습 7개 통과
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
