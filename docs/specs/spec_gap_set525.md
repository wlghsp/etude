# 명세 — 세트 525 데이터 모델링 기초 (1) 테이블 나누기와 관계

> 상태: 작성 중 (2026-11-19). 선행: 125(DB 기초), 141·331(JOIN), 164·334(테이블 만들기·외래 키 일부). `linux-db`, 데이터베이스, 단원 46, display_order 746. 생성: `scripts/content-gen/new_sets/set525.py`.

기반 데이터(`modeling` DB): 실습마다 setup 이 빈 DB 또는 `customers`·`orders`, `students`·`courses`·`enrollments` 를 준비한다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | 엔티티 = 테이블 하나 | |
| 2 | 객관식 | 기본키로 알맞은 속성 | |
| 3 | 실습 | `customers` 만들기(PK) | PK `id`, 열 2개, 3행 이상 |
| 4 | 객관식 | 테이블을 나누는 이유(중복·불일치) | |
| 5 | 객관식 | 1:N 에서 FK 는 N 쪽 | |
| 6 | 빈칸 | `FOREIGN KEY ... {REFERENCES}` | |
| 7 | 실습 | `orders` 만들기(1:N FK) | FK 참조, 3건 이상, 한 고객 2건 이상 |
| 8 | 실습 | 고객별 주문 건수(LEFT JOIN) | 3줄, kim 2, park 0 |
| 9 | 객관식 | N:M 은 연결 테이블 | |
| 10 | 실습 | `enrollments` 연결 테이블(두 FK, 복합 PK) | FK 2개, PK 2열, 3건 이상 |
| 11 | 실습 | 연결 테이블로 JOIN 두 번 | 3줄, kim-linux, lee-sql 만 |
| 12 | 객관식 | 텍스트 ERD 읽기 | |
| 13 | 순서 | 모델링에서 생성까지 | |

## 수용 조건

- [ ] `verify:quests --set 525` 실습 5개 모두 정답 통과·무행동 실패
- [ ] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음, 한 문제에 새 개념 1개
- [ ] `check-content.sh` 통과
