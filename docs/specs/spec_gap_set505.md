# 명세 — 세트 505 쿼리 튜닝 (1) EXPLAIN 읽기와 인덱스를 못 타는 이유

> 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 6. 생성기: `scripts/content-gen/new_sets/set505.py`.
> `linux-db`, 데이터베이스, 단원 46(SQL 4 · 테이블과 인덱스), display_order 726. 선행: 369(인덱스 문법·EXPLAIN 초입), 158.
> 모든 실습은 `shop.orders`(20,000행, 문제마다 인덱스를 따로 준비)를 쓴다. 369 가 가르친 인덱스 생성·`LIKE '%…'` 는 반복하지 않는다.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | EXPLAIN 의 type·key·rows·Extra 읽기 | key.txt = idx_cust, rows.txt = EXPLAIN rows |
| 2 | 실습 | 컬럼에 함수(`YEAR`/`MONTH`)를 씌우면 못 탐 → 날짜 범위로 | idx_created 를 타고 결과 동일 |
| 3 | 실습 | 문자열 컬럼을 숫자와 비교(형변환) → 따옴표 | type ref, key idx_phone |
| 4 | 실습 | 컬럼에 계산(`customer_id + 1`) → 값 쪽으로 | type ref, key idx_cust, 40건 |
| 5 | 객관식 | 인덱스를 못 타는 조건 고르기 | |
| 6 | 실습 | 복합 인덱스의 선두 컬럼 규칙 | created_at 선두 인덱스 추가 후 탐 |
| 7 | 실습 | 커버링 인덱스 → `Using index` | (customer_id, amount) 인덱스, Extra |
| 8 | 실습 | `Using filesort` 를 (where컬럼, order컬럼) 복합 인덱스로 제거 | filesort 없음 |
| 9 | 실습 | `Using temporary` 를 GROUP BY 인덱스로 제거 | temporary 없음 |
| 10 | 빈칸 | 인덱스만으로 답했다는 Extra 값 | `Using index` |
| 11 | 객관식 | 복합 인덱스를 잘 타는 쿼리 | |
| 12 | 순서 | 튜닝 점검 흐름(고르기→읽기→원인→수정→재확인) | |

## 수용 조건

- [x] `verify:quests --set 505` 실습 8개 통과 (정답 통과, 무행동 실패)
- [ ] `check-content.sh` 통과
- [ ] 정확성 점검(별도 에이전트)에서 차단 없음
- [ ] 화면 확인 (사용자)
