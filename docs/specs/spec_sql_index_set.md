# 명세 — SQL 인덱스 손연습 세트 (CREATE INDEX · EXPLAIN · UNIQUE · 복합 인덱스 · DROP INDEX)

> 상태: **구현 중(로컬)** (2026-11-13). 세트 369, 데이터베이스 분야 `SQL 기초` 단원(id 30) 끝(세트 367 뒤), 아이콘 📇, 샌드박스 `linux-db`. 근거: 366(조회)·367(변경)에 이어 "인덱스와 실행 계획" 실습을 제안했고 사용자가 "진행"했다.

## 목표

1,000행짜리 `members` 에서 "인덱스 만들기 → 목록 보기 → EXPLAIN 으로 사용 여부 확인 → 전후 비교 → UNIQUE → 복합 인덱스 → LIKE 패턴 차이 → 삭제 → 커버링(Using index)" 을 쌓는다.

## 원칙

- 터미널 9 + 객관식 1 + 빈칸 1 + 순서 1.
- **배경을 문제 안에 적는다.** 1번에 인덱스 개념·테이블 구조·데이터 규칙, 3번에 EXPLAIN 컬럼(`type`·`key`·`rows`·`Extra`) 읽는 법을 둔다 (사용자 지적: SQL 문제는 배경 설명이 필요하다).
- setup: MariaDB 를 띄우고 `shop.members` 를 `seq_1_to_1000` 으로 채우고 `idx_age` 를 만든 뒤 `ANALYZE TABLE`. 옵티마이저가 인덱스를 고르도록 행 수를 1,000 으로 한다.
- 채점: 인덱스 상태는 `information_schema.statistics` 로, EXPLAIN 은 저장한 파일의 마지막 줄에서 `type`(4열)·`key`(6열)·`Extra`(10열)를 잘라 비교한다.
- 한계: EXPLAIN 파일은 어떤 쿼리의 것이든 열 값만 맞으면 통과한다. 옵티마이저 판단에 기대므로 MariaDB 버전이 바뀌면 재확인한다.
- 문서 링크: mariadb.com/kb 의 create-index·drop-index·show-index·explain·getting-started-with-indexes (200 확인).

## 수용 조건

- [ ] 터미널 9문제 모두 solution 으로 채점 통과 (`verify:quests -- --set 369`).
- [ ] `check-content.sh`, `check-migrations.sh` 통과, 단원 30 끝에 배치.
- [ ] 화면: 1번 배경과 3번 EXPLAIN 설명이 읽기 좋게 보인다 (수동 확인).
