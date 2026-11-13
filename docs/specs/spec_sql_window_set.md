# 명세 — SQL 윈도 함수와 WITH 손연습 세트 (ROW_NUMBER · RANK · PARTITION BY · 누적 합계 · LAG · CTE)

> 상태: **구현 중(로컬)** (2026-11-13). 세트 374, 데이터베이스 분야 `SQL 기초` 단원(id 30) 끝(세트 372 뒤), 아이콘 🪟, 샌드박스 `linux-db`. 근거: 기존 SQL 세트(366·367·369·371·372)에 없는 윈도 함수와 CTE. 사용자가 콘텐츠 세트를 알아서 이어 가라고 위임했다(2026-11-13).

## 목표

`sales`(판매 8건)에서 "ROW_NUMBER → RANK(동점) → DENSE_RANK → PARTITION BY → WITH+rn=1 → 누적 SUM OVER → 묶음 합계 → LAG → WITH 재사용" 을 쌓는다.

## 원칙

- 터미널 9 + 객관식 1 + 빈칸 1 + 순서 1. setup 은 `shop.sales`(west 의 500 이 동점)를 새로 만든다.
- 배경은 문제 안에 적는다(1번에 윈도 함수·`OVER`·`PARTITION BY`, 5번에 CTE).
- 채점은 저장한 출력 파일을 같은 쿼리의 실제 결과와 **순서까지** 비교한다(순서가 의미인 문제들이라 sort 하지 않음).
- 한계: 같은 결과를 내는 다른 쿼리도 통과한다(예: 9번에서 WITH 없이 서브쿼리를 두 번 써도 통과).
- 문서 링크: mariadb.com/kb 의 window-functions·row_number·rank·dense_rank·lag·with (200 확인).

## 수용 조건

- [ ] 터미널 9문제 모두 solution 으로 채점 통과 (`verify:quests -- --set 374`).
- [ ] 풀기 전 상태가 채점에서 실패한다.
- [ ] `check-content.sh`, `check-migrations.sh` 통과, 단원 30 끝에 배치.
- [ ] 화면: 단원 `SQL 기초` 끝에 보이고 배경 설명이 읽기 좋게 보인다 (수동 확인).
