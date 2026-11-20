# 명세 — 세트 509 SQL 중급 (1) 함수: 문자열·숫자·날짜·NULL, CASE

> 상태: 작성 (2026-11-19). 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 13. 샌드박스 `linux-db`, 카테고리 데이터베이스, 단원 30 (SQL 1), display_order 730. 선행: 139·140. 생성: `scripts/content-gen/new_sets/set509.py`.

계단식: 문제마다 새 개념 1개. 터미널은 `club.members`(6행, nick·phone·email 에 NULL 포함)를 조회한 결과를 파일에 저장하고, 검사는 같은 DB 에서 기대 결과를 뽑아 비교한다(파일이 없으면 실패).

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 객관식 | `NULL = NULL` 은 NULL | |
| 2 | 실습 | `IFNULL` | q2.txt 가 기대 결과와 같다 |
| 3 | 실습 | `COALESCE` (phone → email → none) | q3.txt |
| 4 | 객관식 | `CONCAT` 에 NULL 이 있으면 NULL | |
| 5 | 빈칸 | `SUBSTRING(name, 1, 1)` | |
| 6 | 실습 | `REPLACE` 로 하이픈 제거 | q6.txt, 4행 |
| 7 | 객관식 | `ROUND(7.456, 1)` = 7.5 | |
| 8 | 실습 | `ROUND(AVG(score), 1)` | 81.8 |
| 9 | 실습 | `DATE_FORMAT(joined, '%Y-%m')` | q9.txt |
| 10 | 객관식 | `DATEDIFF` 결과와 인자 순서 | |
| 11 | 순서 | `CASE ... WHEN ... ELSE ... END` | |
| 12 | 실습 | `CASE` 로 등급 A·B·C | q12.txt, 6행 |

## 수용 조건

- [ ] `verify:quests --set 509` 실습 6개 통과 (정답 통과, 무행동 실패)
- [ ] 형식 4종(실습·객관식·빈칸·순서), 현장 정보 없음
- [ ] `check-content.sh` 통과
