# 명세 — MariaDB 2차 퀴즈 세트 402·403 (슬로우 로그, 바이너리 로그 형식·버퍼 풀)

> 상태: **구현 완료(로컬), 화면 확인 대기** (2026-11-14). 데이터베이스 분야 단원 20 `MariaDB 운영` 끝에 퀴즈 두 세트를 더한다(뒤 Redis 단원 세트 7개의 display_order 는 밀렸다). 형식·근거 규칙은 [spec_storage_quiz_sets.md](spec_storage_quiz_sets.md)와 같다.

## 구성

| 세트 | 단원 | 제목 | 내용 |
|---|---|---|---|
| 402 | 20 MariaDB 운영 (563) | 슬로우 쿼리 로그 | 기본 꺼짐, SET GLOBAL 즉시 켜기(재시작 전까지), long_query_time 10초, `${hostname}-slow.log`, log_output FILE 기본(TABLE=mysql.slow_log), min_examined_row_limit, log_queries_not_using_indexes, log_slow_verbosity, log_slow_rate_limit, mariadb-dumpslow, 조사 순서 |
| 403 | 20 MariaDB 운영 (564) | 바이너리 로그 형식과 버퍼 풀 | STATEMENT·ROW·MIXED, 기본 MIXED, 안전하지 않은 문장에서 ROW 로 전환, 비결정적 문장(LIMIT), ROW 의 저장 비용과 WHERE 없는 DELETE, 형식은 서버마다 따로, 버퍼 풀 old 37%, 덤프·로드, 형식 변경 순서 |

각 세트 12문제(객관식 9, 빈칸 2, 순서 1).

## 근거 문서

mariadb.com/kb 의 slow-query-log-overview, binary-log-formats, innodb-buffer-pool. 위 내용은 원문에서 직접 확인했다.

## 수용 조건

- [x] 마이그레이션 적용·재실행 안전, `check-content.sh`, `check-migrations.sh`(30개) 통과, 데이터베이스 분야 display_order 중복 없음 — `검증됨`
- [x] 정답 위치 분산, 보기 길이 단서(경고 0) — `검증됨`
- [ ] 화면 확인 (`미검증`)

## 알려진 한계

- 변수 이름은 10.11 에서 바뀐 것(`log_slow_query` 등)을 해설에만 언급했고, 문제는 이름이 바뀌지 않은 개념 위주로 냈다.
- 문서에서 `mysqldumpslow` 는 확인되지 않아 `mariadb-dumpslow` 만 썼다. 버퍼 풀의 "전용 서버 80%" 권장, `innodb_buffer_pool_instances`, 기본 크기 128MB 는 원문에서 확인되지 않아 뺐다. 바이너리 로그 기본 형식의 버전별 변경 이력도 뺐다.
- 순서 문제 둘은 문서 설명을 이은 큰 줄기다.
