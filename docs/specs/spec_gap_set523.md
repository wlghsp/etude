# 명세 — 세트 523 SQL 윈도 함수·WITH 입문

> 상태: 작성 중 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_db.md`. 선행: 세트 141·331(JOIN), 522(서브쿼리, 사전지식으로만 가정). 기존 374(윈도 함수·WITH 손연습)의 앞단 개념 세트라 데이터를 달리 하고(`school` DB) 개념을 한 가지씩 도입한다. `linux-db`, 데이터베이스, 단원 44, display_order 744. 생성: `scripts/content-gen/new_sets/set523.py`.

기반 데이터(`school` DB): `scores`(반 A·B, 학생 8명, 점수 동점 있음), `daily`(날짜별 방문자 5건).

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | WITH(CTE)는 임시 이름 | |
| 2 | 실습 | WITH 로 이름 붙여 반별 인원 | A 3, B 1 |
| 3 | 실습 | ROW_NUMBER 번호 | 1~8 순서 |
| 4 | 객관식 | RANK 동점 뒤 순위 건너뜀 | |
| 5 | 실습 | RANK | 1,2,2,4,5,5,7,8 |
| 6 | 실습 | DENSE_RANK + WITH 로 2등 | kim, park |
| 7 | 빈칸 | `OVER ({PARTITION BY} ...)` | |
| 8 | 실습 | PARTITION BY 반별 순위 | 반마다 1부터 |
| 9 | 실습 | 누적 합계 SUM OVER | 100~590 |
| 10 | 실습 | LAG 전날 대비 | 첫날 NULL |
| 11 | 순서 | WITH + 윈도 함수 반별 1등 | |

## 수용 조건

- [ ] `verify:quests --set 523` 실습 7개 모두 정답 통과·무행동 실패
- [ ] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음, 374 와 데이터·문제 중복 없음
- [ ] `check-content.sh` 통과
