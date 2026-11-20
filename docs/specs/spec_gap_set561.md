# 명세 — 세트 561 큰 테이블 안전하게 바꾸기

> 상태: 작성 (2026-11-20). 샌드박스 `linux-db`, 카테고리 `데이터베이스`, 단원 45(SQL 3), display_order 821. 선행: 367·371·558. 근거: `gap_db.md` R4(온라인 DDL·배치 삭제·LOAD DATA/OUTFILE). 생성: `scripts/content-gen/new_sets/set561.py`. MariaDB 10.6 에서 직접 확인: ADD COLUMN INSTANT 가능, 타입 변경은 INPLACE·INSTANT 불가(오류 1846)·COPY 가능, ADD INDEX 는 INPLACE+LOCK=NONE 가능.

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set561.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 561` 실습 7개 통과
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
