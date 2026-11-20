# 명세 — 세트 564 Redis 복제 직접 해 보기

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(Redis 6.0.16), 카테고리 `데이터베이스`, 단원 31, display_order 824. 선행: 400·563. 근거: `gap_db.md` R7(Redis 복제). 생성: `scripts/content-gen/new_sets/set564.py`. 한 컨테이너에 redis-server 두 개(6379 primary, 6380 replica), 로컬에서 복제·승격·옛 primary 편입을 직접 확인.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set564.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 564` 실습 6개 통과
- [x] 형식 4종, 10문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
