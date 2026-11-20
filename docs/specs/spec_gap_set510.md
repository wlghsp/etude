# 명세 — 세트 510 SQL 중급 (2) JOIN 확장과 UNION

> 상태: 작성 중 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 14. 선행: 세트 141(JOIN 개념)·331. `linux-db`, 데이터베이스, 단원 44, display_order 731. 생성: `scripts/content-gen/new_sets/set510.py`.

기반 데이터(`hr` DB): `dept`(dev·sales·hr), `emp`(5명, `manager_id` 로 상사 지정), `sizes`·`colors`, `list_a`·`list_b`(이메일 3개씩, 2개 겹침).

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | RIGHT JOIN 은 오른쪽 테이블을 모두 남김 | |
| 2 | 실습 | RIGHT JOIN 으로 직원 없는 부서 찾기 | 파일에 `hr` |
| 3 | 실습 | CROSS JOIN 모든 조합 | 6줄, L·blue 조합 |
| 4 | 객관식 | CROSS JOIN 행 수 = 곱 | |
| 5 | 실습 | SELF JOIN 직원-상사 | 4줄, choi→kim |
| 6 | 실습 | SELF LEFT JOIN 으로 최상위 직원 포함 | 5줄, park NULL |
| 7 | 순서 | 직원-상사 쿼리 조립 | |
| 8 | 실습 | UNION(중복 제거) | 4줄, 중복 없음 |
| 9 | 실습 | UNION ALL + 마지막 ORDER BY | 6줄, 정렬됨 |
| 10 | 빈칸 | `UNION {ALL}` | |
| 11 | 객관식 | FULL OUTER JOIN 대체(LEFT UNION RIGHT) | |

## 수용 조건

- [ ] `verify:quests --set 510` 실습 6개 모두 정답 통과·무행동 실패
- [ ] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] `check-content.sh` 통과
