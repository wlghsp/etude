# 명세 — MariaDB 3차 퀴즈 세트 414·415 (GTID, 반동기 복제, mariadb-dump)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-17). [spec_mariadb_round2.md](spec_mariadb_round2.md)에 이어 단원 20 `MariaDB 운영` 끝에 세트를 더한다(뒤 세트 7개의 display_order 는 밀렸다). 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 414 | 20 (565, 🆔) | MariaDB GTID | domain_id-server_id-sequence_number, server_id 의 뜻, sequence_number 증가, gtid_slave_pos, MASTER_USE_GTID 의 slave_pos 권장·current_pos 위험, 프라이머리 전환이 쉬운 이유, mysql.gtid_slave_pos 의 crash-safe, MySQL 과 한 방향 호환, gtid_domain_id 기본 0, 복제 시작 순서 |
| 415 | 20 (566, 🤝) | 반동기 복제와 mariadb-dump | 레플리카 확인 대기, enabled 기본 OFF, timeout 기본 10000ms 와 비동기 전환, AFTER_SYNC, 보장 범위(릴레이 로그 도달), --single-transaction(트랜잭션 엔진), --master-data 값 2, --routines 기본 FALSE, 덤프로 레플리카 만드는 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

MariaDB Knowledge Base 의 GTID, Semisynchronous Replication, mariadb-dump/mysqldump 페이지. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(42개) 통과, 새 세트의 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- gtid_binlog_pos 는 원문에 의미 설명이 없어 뺐다. 반동기 복제의 플러그인 이름과 내장된 버전은 원문에 없어 "서버에 내장"만 다뤘다. mariadb-dump 의 --master-data 는 본문과 옵션 표의 기본값이 달라(1 대 0) 기본값을 묻지 않았고, --source-data 는 원문에 없어 다루지 않았다.
- 데이터베이스 분야에는 이번 작업과 무관한 기존 아이콘 중복(예: 🧮 158·332)이 있다. 이번에 더한 🆔·🤝 는 겹치지 않는다.
- 두 순서 문제는 문서 설명을 이은 일반 절차다. 샌드박스에서 실제 복제를 구성하지 않아 퀴즈로만 다룬다.
