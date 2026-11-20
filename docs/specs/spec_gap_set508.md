# 명세 — 세트 508 binlog 와 시점 복구(PITR) 실습

> 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 10 (M5). 샌드박스 `linux-db`, 카테고리 데이터베이스, 단원 20(MariaDB 운영), display_order 729. 선행: 세트 109(백업·복원).
> 생성: `scripts/content-gen/new_sets/set508.py`. 각 터미널 문제의 setup 이 `/etc/mysql/mariadb.conf.d/99-binlog.cnf`(`log_bin`·`server_id`)로 서버를 binlog 켠 채 다시 띄우고, 풀 백업(`/root/backup/full.sql`, `--master-data=2`) → 정상 변경 → 실수 `DELETE FROM items` 상황을 만든다. 1번만 binlog 를 끈 상태로 시작한다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 설정 파일로 binlog 켜고 서버 재시작 | `@@log_bin` = 1 |
| 2 | 실습 | `SHOW MASTER STATUS` 로 파일 이름·위치 | 파일 내용이 현재 값과 일치 |
| 3 | 객관식 | 풀 백업만으로 부족한 이유, binlog 의 역할 | |
| 4 | 실습 | `mariadb-binlog` 로 이벤트 읽기, DELETE 문장 찾기 | binlog.sql, bad_sql.txt |
| 5 | 실습 | 실수 트랜잭션의 시작 위치(GTID 이벤트 `# at`) 찾기 | 실제 위치와 일치 |
| 6 | 빈칸 | `--start-position` / `--stop-position` | |
| 7 | 실습 | 백업 파일 `CHANGE MASTER` 주석에서 시작 위치 찾기 | 실제 위치와 일치 |
| 8 | 실습 | 풀 백업 복원 + 위치로 재생 (PITR) | 7행, melon·kiwi·apple 1500 |
| 9 | 실습 | `--stop-datetime` 으로 재생 | 7행, kiwi |
| 10 | 순서 | PITR 절차 | |
| 11 | 실습 | binlog 가 2 파일로 나뉜 경우 이어 재생 | 7행, melon·kiwi |
| 12 | 객관식 | `--stop-position` 은 시작 위치(1599) vs 끝 위치(1725) | |

형식: 실습 8, 객관식 2, 빈칸 1, 순서 1.

## 수용 조건

- [x] 새 개념 1개씩 계단식 (켜기 → 위치 → 읽기 → 실수 위치 → 백업 위치 → 재생 → 시각 → 여러 파일)
- [x] 아무것도 안 하면 모든 실습이 실패 (결과 파일 없음, items 0행, log_bin OFF)
- [x] `npm run verify:quests -- --set 508` 실습 8개 통과
- [x] 현장 정보 없음 (일반 테이블 `shop.items`)
- 참고: 문제 12 의 위치 값(1599·1725)은 문제 5 의 시나리오와 같은 값으로 설명용이다.
