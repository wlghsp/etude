# 명세 — 세트 560 문자셋·collation·시간대

> 상태: 작성 (2026-11-20). 샌드박스 `linux-db`, 카테고리 `데이터베이스`, 단원 46(SQL 4), display_order 820. 선행: 164·334·371. 근거: `gap_db.md` R3. 생성: `scripts/content-gen/new_sets/set560.py`. 이 샌드박스의 `mariadb` 클라이언트 기본 접속 문자셋은 latin1 이라, 접속 문자셋을 맞추지 않으면 한글이 이중 인코딩된다(세트의 핵심 함정, 3·4번에서 HEX 로 검증).

## 문제 구성

문제 내용·정답 확인은 세트 원본 `scripts/content-gen/new_sets/set560.py` 가 유일한 기준이다 (이 문서에는 표를 두지 않는다).

## 수용 조건

- [x] `verify:quests --set 560` 실습 7개 통과
- [x] 형식 4종, 11문제
- [x] 힌트는 방향만, 현장 정보 없음
- [x] `check-content.sh` 통과 확인
