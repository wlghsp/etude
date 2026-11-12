# 명세 — SQL 데이터 변경 손연습 세트 (INSERT · UPDATE · DELETE · INSERT…SELECT · 트랜잭션)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-12). 세트 367, 데이터베이스 분야 `SQL 기초` 단원(id 30) 끝(세트 366 바로 뒤), 아이콘 ✏️, 샌드박스 `linux-db`. 근거: 세트 366(조회 손연습)에 이어 "INSERT·UPDATE·DELETE와 트랜잭션" 실습을 같은 `shop` 환경에서 제안했고 사용자가 "진행"했다.

## 목표

`shop` 데이터에서 "행 추가 → 여러 행 추가 → 한 행 고치기 → 여러 행 고치기 → 한 행 지우기 → 여러 행 지우기 → 트랜잭션 COMMIT → ROLLBACK → INSERT…SELECT 복사" 를 쌓는다.

## 원칙

- 터미널 9 + 객관식 1 + 빈칸 1 + 순서 1.
- setup 은 MariaDB 서버를 띄우고 `shop`(customers·customers_backup·products·orders·accounts)을 지우고 다시 만든다. 문제마다 새 상태에서 시작한다.
- 채점은 변경 **뒤의 테이블 상태**를 `GROUP_CONCAT(... ORDER BY id)` 로 한 줄로 만들어 기대값과 비교한다. 표 전체를 보므로 `WHERE` 를 빠뜨려 다른 행까지 바뀐 풀이를 거른다(3·4번).
- 8번(ROLLBACK)은 트랜잭션 안에서 조회한 합계(0)를 `/tmp/q8.txt` 에 남기게 하고(변경이 실제로 있었다는 증거), 끝난 뒤 잔액이 원래대로인지 본다.
- 한계: 7번은 `START TRANSACTION` 없이 두 UPDATE 만 해도 `-e` 가 자동 커밋(autocommit)이라 결과가 같아 통과한다. 트랜잭션을 썼는지는 힌트·해설로 안내하며 채점은 최종 상태만 본다. 1·2번처럼 같은 상태를 만드는 다른 문장도 통과한다.
- 가상 데이터만 쓴다. 문서 링크: mariadb.com/kb 의 insert·update·delete·insert-select·start-transaction (200 확인).

## 세트 구성 (12개)

| # | 형식 | 새로 익히는 것 |
|---|------|----------------|
| 1 | 터미널 | `INSERT ... VALUES` 한 행 |
| 2 | 터미널 | `VALUES (...), (...)` 여러 행 |
| 3 | 터미널 | `UPDATE ... SET ... WHERE` 한 행 |
| 4 | 터미널 | `SET price = price + 1000` 여러 행 |
| 5 | 터미널 | `DELETE ... WHERE` 한 행 |
| 6 | 터미널 | 조건에 맞는 여러 행 삭제 (SELECT 로 먼저 확인) |
| 7 | 터미널 | `START TRANSACTION` … `COMMIT` 이체 |
| 8 | 터미널 | 트랜잭션 안 조회 후 `ROLLBACK` |
| 9 | 터미널 | `INSERT ... SELECT` |
| 10 | 객관식 | WHERE 없는 UPDATE 는 모든 행을 바꾼다 |
| 11 | 빈칸 | `COMMIT` |
| 12 | 순서 | 이체 트랜잭션 흐름 |

## 수용 조건

- [x] 터미널 9문제 모두 `solution` 을 실행하면 채점이 통과한다 (`npm run verify:quests -- --set 367`, 9/9).
- [x] `check-content.sh`, `check-migrations.sh`(37개) 통과, 단원 30 끝에 배치.
- [ ] 흔한 오답(3번에서 WHERE 누락, 8번에서 COMMIT)이 채점에서 걸러지는지 실행 확인 (코드상 확인만).
- [ ] 화면: 데이터베이스 분야 `SQL 기초` 단원 끝에 보이고 1번부터 12번까지 풀린다 (수동 확인).
