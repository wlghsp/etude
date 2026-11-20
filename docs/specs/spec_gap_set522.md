# 명세 — 세트 522 SQL 중급 (3) 서브쿼리와 EXISTS

> 상태: 작성 중 (2026-11-19). 선행: 세트 141·331(JOIN), 510(JOIN 확장·UNION). 세트 372(서브쿼리·CASE·VIEW 손연습)의 **앞단 개념 세트**이며, 372 가 개념 없이 다룬 스칼라·IN·CASE 를 계단식으로 가르치고 EXISTS·NOT IN/NULL·파생 테이블을 더한다. `linux-db`, 데이터베이스, 단원 44, display_order 743. 생성: `scripts/content-gen/new_sets/set522.py`.

기반 데이터(`mall` DB): `members`(5명), `orders`(6건, 금액), `coupon_used`(회원 번호 1·3 과 NULL 한 행).

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | 서브쿼리가 돌려주는 것(스칼라) | |
| 2 | 실습 | 평균보다 큰 주문 (스칼라 서브쿼리) | 2·4·6 번 |
| 3 | 실습 | IN 서브쿼리 | kim·lee·park |
| 4 | 순서 | IN 서브쿼리 조립 | |
| 5 | 객관식 | EXISTS 는 행 존재 여부 | |
| 6 | 실습 | EXISTS (연관 서브쿼리) | park |
| 7 | 실습 | NOT EXISTS | choi·han |
| 8 | 빈칸 | `WHERE {NOT EXISTS}` | |
| 9 | 객관식 | NOT IN 에 NULL 이 있으면 빈 결과 | |
| 10 | 실습 | NULL 안전하게 거르기 | lee·choi·han |
| 11 | 실습 | FROM 절 서브쿼리(파생 테이블) | 평균 91666 대 |
| 12 | 실습 | 파생 테이블 + LEFT JOIN + CASE | 5줄, 등급 |

## 수용 조건

- [ ] `verify:quests --set 522` 실습 7개 모두 정답 통과·무행동 실패
- [ ] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] 372 와 중복 없음(372 는 상품·주문 `shop` 데이터의 손연습, 522 는 `mall` 데이터의 개념 계단)
- [ ] `check-content.sh` 통과
