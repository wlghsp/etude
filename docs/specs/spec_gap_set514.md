# 명세 — 세트 514 MariaDB 문제 해결 상황집 (3): 서버가 안 뜰 때·비밀번호 분실·실수 삭제·복제 상태 읽기

> 근거: `docs/research/content_gap_2026-11-19/gap_db.md` 필수 3 와 권장 "복제 장애 시나리오 실습". 샌드박스 `linux-db`, 카테고리 데이터베이스, 단원 20(MariaDB 운영), display_order 735. 겹치지 않는 세트: 503(접속 오류·락·접속 가득 참), 508(binlog 시점 복구).
> 생성: `scripts/content-gen/new_sets/set514.py`. 서버 기동 실패는 setup 이 `mysqld_safe` 의 로그를 `/var/log/mysql/error.log` 로 돌려 두고(`99-errlog.cnf`) 일부러 망가뜨린 뒤 한 번 시도해 실패 로그를 남긴다. 복제 문제는 한 컨테이너에서 원본(3306, binlog 켬)과 복제본(`mariadbd` 두 번째 인스턴스, 3307, 소켓 `/tmp/r.sock`, datadir `/var/lib/mysql_r`)을 띄워 **실제 복제**로 재현한다.

## 구성

| # | 형식 | 개념 | 확인 |
|---|---|---|---|
| 1 | 실습 | 서버 기동 실패: 오류 로그의 첫 ERROR, 데이터 디렉터리 소유자(chown) | 서버 응답, ibdata1 소유자 mysql, 행 수 |
| 2 | 객관식 | 로그는 첫 ERROR 가 원인, Aborting 은 여파 | |
| 3 | 실습 | 서버 기동 실패: 설정 변수 이름 오타(unknown variable) | 서버 응답, max_connections=300, 다른 설정 유지 |
| 4 | 실습 | root 비밀번호 분실 복구(--skip-grant-tables, FLUSH PRIVILEGES, ALTER USER, 재시작) | 새 비밀번호 접속, 옛 비밀번호 거부, 데이터 유지 |
| 5 | 빈칸 | `--skip-grant-tables`, `--skip-networking` | |
| 6 | 순서 | 비밀번호 복구 절차 | |
| 7 | 실습 | 실수 DROP 한 표 하나만 복구(임시 DB 에 풀고 RENAME TABLE) | coupons 3행, 새 주문 유지, 임시 DB 삭제 |
| 8 | 실습 | `SHOW SLAVE STATUS\G` 읽기: 오류 번호, 멈춘 스레드 | errno 1062, thread SQL |
| 9 | 실습 | IO 스레드 1045: CHANGE MASTER TO MASTER_PASSWORD | IO·SQL Yes, 멈춘 동안의 변경(melon) 반영 |
| 10 | 객관식 | 1062 와 1032 의 뜻(복제본에 있다/없다) | |
| 11 | 실습 | 1062 조치: 복제본의 충돌 행 삭제 후 START SLAVE | SQL Yes, 원본 값, 두 서버 동일 |
| 12 | 실습 | 1032 조치: sql_slave_skip_counter 로 한 건만 건너뛰기 | SQL Yes, 뒤 변경(after) 반영, 두 서버 동일 |

형식: 실습 8, 객관식 2, 빈칸 1, 순서 1.

## 수용 조건

- [x] 오류 메시지 → 원인 → 고치기 흐름, 새 개념 1개씩
- [ ] 아무것도 안 하면 모든 실습이 실패 (서버 다운·옛 비밀번호·표 없음·복제 멈춤)
- [ ] `npm run verify:quests -- --set 514` 실습 8개 통과
- [x] 현장 정보 없음 (`shop`, `repl`, 예시 비밀번호)
- 참고: 복제본 접속은 `mariadb -S /tmp/r.sock`. 문제 12 의 skip 은 양쪽 결과가 이미 같음을 확인한 경우에 한정해 가르친다.
