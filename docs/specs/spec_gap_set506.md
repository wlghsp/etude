# 명세 — 세트 506 쿼리 튜닝 (2) 슬로우 쿼리 개선 실전 (`linux-db`, 단원 46, display_order 727)

> 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 7. 선행: 세트 505(EXPLAIN 읽기, 열 해석은 여기서 다시 가르치지 않음)·402(슬로우 로그).
> 데이터: `shop.orders` 20만 건, `customers` 2000명. 생성기: `scripts/content-gen/new_sets/set506.py`.

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 슬로우 로그 켜기(파일·`long_query_time=0`) | 변수 값, 로그에 쿼리 기록 |
| 2 | 실습 | `mariadb-dumpslow -s t -t 1` 로 후보 찾기 | top.txt 가 amount 쿼리 |
| 3 | 실습 | `ANALYZE FORMAT=JSON` 으로 고치기 전 측정 | r_total_time_ms, access_type ALL |
| 4 | 실습 | 인덱스 추가 후 재측정·전후 비교 | after.txt 가 ref, r_rows < 1000 |
| 5 | 실습 | 복합 인덱스(= 열 앞, 범위 열 뒤) | 인덱스 열 순서, r_rows < 15000 |
| 6 | 실습 | OR 한쪽 인덱스 부재(index_merge) | coupon 인덱스, r_rows < 2000 |
| 7 | 실습 | 상관 서브쿼리 → JOIN | JOIN 사용, 5초 내 동일 결과 |
| 8 | 실습 | OFFSET → 키셋 페이징 | OFFSET 없음, 150021~150040 |
| 9 | 실습 | 낡은 통계 → `ANALYZE TABLE` | innodb_table_stats.n_rows 갱신 |
| 10 | 객관식 | OR → UNION 시 중복 제거(UNION vs UNION ALL) | |
| 11 | 빈칸 | 키셋 조건 연산자 `>` | |
| 12 | 순서 | 튜닝 순서(후보→전 측정→수정→후 측정→결과 확인) | |

## 수용 조건

- [x] `verify:quests --set 506` 실습 9개 통과(정답 통과, 무행동 실패)
- [x] 형식 3종 이상(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] `check-content.sh` 통과
- [ ] 정확성 점검, 화면 확인 (사용자)
