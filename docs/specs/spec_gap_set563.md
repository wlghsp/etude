# 명세 — 세트 563 Redis 보안: requirepass·ACL·bind·protected-mode

> 상태: 작성 (2026-11-20). 샌드박스 `linux`(Redis 6.0.16), 카테고리 `데이터베이스`, 단원 31, display_order 823. 선행: 99·102·524. 근거: `gap_db.md` R7(Redis 보안·ACL). 생성: `scripts/content-gen/new_sets/set563.py`. 로컬에서 requirepass·NOAUTH·ACL(NOPERM)·설정 파일 기동을 직접 확인.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set563.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 563` 실습 7개 통과
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
