# 빈틈 분석: 데이터베이스 (공개 예정 분야, 최우선)

분석 대상: category=`데이터베이스` 세트 35개, 단원 6개(30 SQL 1 · 44 SQL 2 · 45 SQL 3 · 46 SQL 4 · 20 MariaDB 운영 · 31 Redis).
근거: merged.json 단원 요약 + 세트별 문제 형식 집계 + 문제 본문 전수 키워드 검색(339KB, 키워드 100여 개) + 대표 세트 문제 제목 전체 확인.
표기: `없음`(문제 본문 전체에서 검색 0건) / `얕음`(문항 1~3개, 개념 퀴즈 위주) / `보통` / `충분`. 검색 기반 판단은 `코드상 확인됨`, 문제 전문을 읽지 않은 판단은 `추정`.

---

## 요약

- **현재 수준**: SQL 조회~변경~DDL~인덱스 기초 사다리(세트 125~371)와 Redis 기본~복제·Sentinel(60~401)은 뼈대가 있다. MariaDB 복제·GTID·Galera·백업은 개념 퀴즈로 꽤 깊다. 다만 **"입문~중급 표준 범위"로 보면 SQL 중급 문법, 데이터 모델링, 트랜잭션/락 실습, 권한·보안, 튜닝/모니터링, 장애 상황집이 통째로 비어 있어** 공개하기에는 균형이 맞지 않는다.
- **가장 큰 빈틈 3개**
  1. **MariaDB 장애 상황집 부재** (오류 메시지 → 원인 → 해결 실습). Redis 에는 102 가 있지만 MariaDB 에는 0개. `Too many connections`, `Lock wait timeout`, `Deadlock`, 복제 중단(1062/1032), 디스크 풀, 접속 거부 등이 문제 본문에 거의 없다(검색 NONE).
  2. **트랜잭션·락·데드락 실습 부재**. 격리 수준은 87 의 개념 퀴즈 4문항뿐이고, `SELECT ... FOR UPDATE`, 데드락, `SHOW ENGINE INNODB STATUS`, gap lock, 메타데이터 락, `Lock wait timeout` 은 본문에 없다(검색 NONE). "데드락" 단어는 59 에 1건(deadlock)뿐.
  3. **데이터 모델링·정규화·ERD 와 SQL 중급 문법(UNION/EXISTS/함수/날짜/NULL 처리) 전무**. 정규화·ERD·1:N/N:M·UNION·COALESCE·DATE_FORMAT 모두 검색 0건. 보안(권한 최소화, SQL 인젝션, TLS)과 백업 운영(binlog 보존, mariadb-backup 실습, 점검)도 얕다.
- **형식 문제**: 35개 세트 중 터미널 실습 세트는 10개(126·366·367·369·371·372·374·109·60·83·99·102·118·91 중 실제 DB 접속 실습). 개념 퀴즈가 `choice` 14문항 위주인 세트(139·140·141·158·159·164)와 복제/로그 퀴즈(59·87·402·403·414·415·400·401)는 choice 9~14개 + fill 2 + order 1 구성으로 "이해 확인"은 되나 **MariaDB 운영 단원은 터미널 실습이 109·91 둘뿐**(둘 다 단일 서버).
- **단원 순서 문제(감사 결과 재확인)**: SQL 1 단원의 366 이 JOIN 을 선행 요구, 372/374 가 개념 세트 없이 6개 개념 도입, 159 가 9개 개념 과밀, MariaDB 운영 단원은 종합(59·87)이 기초(158·109·414)보다 앞. 신규 세트는 이 사다리의 **빈 칸을 채우는 방식**으로 제안한다(기존 세트 재배치는 이 문서 범위 밖이므로 `브리지` 표시만).

---

## 참고 커리큘럼

학습자 = 사내 인프라 운영자. DBA 전업이 아니라 "서비스 DB 를 만지고, 장애를 1차로 판단하고, 백업·복제를 점검할 수 있는" 수준을 목표로 한다. MariaDB/MySQL 중심, Redis 포함, PostgreSQL 은 선택.

| # | 영역 | 핵심 주제 |
|---|------|-----------|
| D1 | DB 기본 개념 | RDBMS 개념(행·열·테이블·스키마), 클라이언트/서버, 접속(소켓/TCP), 데이터 디렉터리·설정 파일(my.cnf)·서비스 기동, OLTP/OLAP·RDBMS vs NoSQL 개요 |
| D2 | SQL 조회 기본 | SELECT·WHERE·ORDER·LIMIT/OFFSET·DISTINCT, NULL 처리(IS NULL·COALESCE·IFNULL), 문자열·숫자·날짜 함수(CONCAT·SUBSTRING·DATE_FORMAT·DATEDIFF·NOW), LIKE/REGEXP, CASE |
| D3 | 집계 | COUNT/SUM/AVG/MIN/MAX, GROUP BY, HAVING, GROUP_CONCAT, ROLLUP(선택) |
| D4 | JOIN·집합 | INNER/LEFT/RIGHT/CROSS, SELF JOIN, 다중 JOIN, UNION/UNION ALL, (EXCEPT/INTERSECT: MariaDB 10.3+) |
| D5 | 서브쿼리·윈도·CTE | 스칼라/IN/EXISTS·NOT EXISTS 서브쿼리, 상관 서브쿼리, 파생 테이블, WITH(CTE), 윈도 함수(ROW_NUMBER·RANK·LAG·누적), 페이징 |
| D6 | 데이터 변경(DML) | INSERT(다중·SELECT), UPDATE/DELETE 안전 습관, UPSERT(ON DUPLICATE KEY·REPLACE), INSERT IGNORE, LOAD DATA/INTO OUTFILE, TRUNCATE |
| D7 | DDL·자료형·제약 | CREATE/ALTER/DROP, 자료형 선택(INT·DECIMAL·VARCHAR·DATETIME vs TIMESTAMP·ENUM), PK/UNIQUE/FK/CHECK/DEFAULT, 문자셋·collation(utf8mb4), 온라인 DDL(ALGORITHM/LOCK) |
| D8 | 데이터 모델링 | 엔티티·관계(1:1/1:N/N:M), ERD 읽기, 정규화(1~3NF), 반정규화 판단, 키 설계(대리키 vs 자연키), 이력/삭제 설계(soft delete) |
| D9 | 트랜잭션·격리·락 | ACID, autocommit, COMMIT/ROLLBACK/SAVEPOINT, 격리 수준 4종·이상 현상, MVCC, 행/갭/넥스트키 락, SELECT ... FOR UPDATE, 메타데이터 락, 데드락 재현·로그 읽기, 락 대기 타임아웃, 긴 트랜잭션 |
| D10 | 인덱스·실행계획·튜닝 | B-Tree 구조, 단일/복합 인덱스, leftmost prefix, 커버링, 선택도·카디널리티, EXPLAIN(type·key·rows·Extra: filesort/temporary), 인덱스 못 타는 패턴(함수·형변환·앞 와일드카드), ANALYZE TABLE, 슬로우 쿼리 로그 조사, N+1·페이징 튜닝, 힌트(선택) |
| D11 | 사용자·권한·보안 | CREATE USER/호스트, GRANT/REVOKE/SHOW GRANTS, 최소 권한, ROLE, 비밀번호 정책·플러그인, 원격 접속 제한(bind-address), TLS, 계정 분리(앱/백업/모니터링), SQL 인젝션 개념, 감사 로그(선택) |
| D12 | 백업·복구 | 논리(mariadb-dump) vs 물리(mariadb-backup), 일관성 옵션, 부분 복구, binlog 와 PITR(mariadb-binlog), 보존·정리(expire_logs), 복원 검증·리허설, 실수 DROP/DELETE 복구 |
| D13 | 복제·HA | 비동기/반동기, binlog 형식, GTID, 복제 상태 읽기(Seconds_Behind·Last_*_Error), 복제 오류 조치, Galera(쿼럼·SST/IST), failover/switchover, 프록시(MaxScale/ProxySQL), 읽기 분리·VIP |
| D14 | 운영·모니터링 | 프로세스리스트·KILL, VARIABLES/STATUS, 핵심 지표(Threads_connected·Slow_queries·buffer pool hit·Handler_read), information_schema/performance_schema 기본, 용량 관리, 로그(error/slow/general), 버전 업그레이드, 시간대 |
| D15 | **MariaDB 상황집(장애 대응)** | 접속 불가·`Too many connections`·`Access denied`, 락 대기/데드락, 슬로우 쿼리 폭주, 복제 중단/지연, 디스크 풀, 크래시 복구·InnoDB 복구 모드, 실수 삭제 복구, 문자 깨짐, 계정/권한 사고 |
| D16 | Redis 기본 | 자료구조(String/Hash/List/Set/ZSet), TTL, INCR, 키 설계, KEYS vs SCAN, INFO 읽기, Stream/Pub-Sub/HyperLogLog/Bitmap(선택) |
| D17 | Redis 캐시·활용 패턴 | Cache-Aside, 캐시 무효화·TTL 전략, 스탬피드·hot key·big key, 세션 저장, 분산 락, 레이트 리미터, 파이프라인·MULTI/Lua |
| D18 | Redis 운영·영속화·HA | RDB/AOF, maxmemory/eviction, 복제, Sentinel, Cluster, 보안(requirepass·ACL·protected-mode·bind), 모니터링(INFO·slowlog·latency·MEMORY USAGE), 상황집 |
| D19 | 프로그래밍 객체·고급(선택) | VIEW, 저장 프로시저/함수, 트리거, 이벤트, JSON 컬럼, 파티셔닝 |
| D20 | PostgreSQL(선택) | psql 기본, MariaDB 와의 차이(스키마·시퀀스·VACUUM·pg_dump/PITR 개요) |

---

## 커버리지 표

형식 약어: Q=개념 퀴즈(객관식·빈칸·순서), T=터미널 실습. 터미널 세트 중 `linux-db` 는 단일 MariaDB 서버(shop DB), `linux` 는 Redis 샌드박스.

| 영역 | 주제 | 현재 세트 | 깊이 | 형식 | 비고 |
|------|------|-----------|------|------|------|
| D1 | 행·열·테이블·DB, SHOW/USE/DESC | 125(Q), 126(T 8문항) | 충분 | Q+T | 개념→실습 쌍 |
| D1 | 설정 파일(my.cnf)·데이터 디렉터리·서비스 기동/중지·소켓 vs TCP | 없음(402에 로그 파일 위치 일부) | 없음 | - | 검색 my.cnf/datadir/ibdata NONE |
| D1 | OLTP/OLAP, RDBMS vs NoSQL, 엔진(InnoDB vs 기타) | 87(InnoDB 내부 일부) | 얕음 | Q | |
| D2 | SELECT·WHERE·AND/OR·IN·LIKE·BETWEEN·IS NULL·ORDER·DISTINCT | 139·329(Q), 366(T) | 보통 | Q 중심, T 366 | 366 은 JOIN 선행 요구(감사 이슈) |
| D2 | NULL 처리 함수(COALESCE/IFNULL) | 없음 | 없음 | - | NONE |
| D2 | 문자열·날짜·숫자 함수(CONCAT·SUBSTRING·DATE_FORMAT·DATEDIFF) | 없음(CONCAT 369 에 보조 사용, NOW() 125 에 1건, ROUND 140/158 보조) | 없음 | - | 현장 실무 빈도 높음 |
| D2 | REGEXP, LIKE 심화 | 139(LIKE만) | 얕음 | Q | |
| D3 | COUNT(*) vs COUNT(col), 집계 4종, GROUP BY, HAVING | 140·330(Q), 366(T) | 충분 | Q+T | |
| D3 | GROUP_CONCAT, ROLLUP | 없음 | 없음 | - | 선택 |
| D4 | INNER/LEFT JOIN, ON 누락 곱집합, 별칭 | 141·331(Q), 366·372(T) | 충분 | Q+T | 141 은 INNER/LEFT 분리 권고(감사) |
| D4 | RIGHT/CROSS/SELF JOIN | 없음(자기 자신 331·400 은 무관) | 없음 | - | SELF JOIN(계층·직원-상사) 실무 필수 |
| D4 | UNION / UNION ALL, 집합 연산 | 없음 | 없음 | - | NONE |
| D5 | 스칼라·IN 서브쿼리 | 372(T) | 얕음 | T만, 개념 세트 없음 | 감사: 가르치는 개념 세트 부재 |
| D5 | EXISTS / NOT EXISTS / 상관 서브쿼리 | 없음(검색의 EXISTS 는 `IF EXISTS` 구문) | 없음 | - | |
| D5 | CASE | 372(T 1문항) | 얕음 | T | 개념 설명 없음 |
| D5 | 윈도 함수·CTE | 374(T) | 얕음~보통 | T만, 개념 세트 없음 | 문제 순서 오류 있음(WITH Q5 < Q9) |
| D5 | 페이징(LIMIT/OFFSET 한계, 키셋) | 102(Redis 문맥 외 무관) | 없음 | - | |
| D6 | INSERT/UPDATE/DELETE 기본, 안전 습관, 오류 1062/1364/1048 | 159·333(Q), 367(T) | 충분 | Q+T | 159 과밀(9개) |
| D6 | INSERT...SELECT | 367 Q9 | 얕음 | T | 가르침 없이 등장 |
| D6 | UPSERT(ON DUPLICATE KEY/REPLACE), INSERT IGNORE | 333 Q9(추정) | 얕음 | Q | 333 에 REPLACE 1건, 개요엔 없음 |
| D6 | LOAD DATA / INTO OUTFILE / CSV 입출력 | 없음 | 없음 | - | 권장 |
| D7 | CREATE TABLE·제약·AUTO_INCREMENT·ALTER·DROP/TRUNCATE | 164·334(Q), 371(T) | 충분 | Q+T | |
| D7 | 자료형 선택(DATETIME vs TIMESTAMP·ENUM·DECIMAL), 오류 1406/1366/1292 | 164·334 일부 | 보통 | Q | ENUM/ON UPDATE 없음 |
| D7 | 문자셋·collation, 한글 깨짐 | 164(utf8mb4 1건) | 얕음 | Q | collation NONE |
| D7 | 온라인 DDL(ALGORITHM/LOCK), 대용량 ALTER 위험 | 없음 | 없음 | - | 현장 필수 |
| D8 | ERD·관계(1:N/N:M)·정규화·반정규화·키 설계 | 없음(141 은 "테이블 분리·외래키" 개념 1개뿐) | 없음 | - | 정규화/ERD/정규형 NONE |
| D9 | autocommit·COMMIT·ROLLBACK | 159·333(Q), 367(T Q7·8) | 보통 | Q+T | |
| D9 | SAVEPOINT | 333 Q10 | 얕음 | Q | |
| D9 | 격리 수준 4종, dirty/non-repeatable/phantom, MVCC | 87(Q 4~5문항) | 얕음~보통 | Q만 | 터미널 재현 없음 |
| D9 | SELECT...FOR UPDATE / 공유락 / 행락 대기 | 159 Q14(Q 1문항) | 얕음 | Q | FOR UPDATE NONE |
| D9 | 데드락 재현·원인·로그(SHOW ENGINE INNODB STATUS) | 없음 | 없음 | - | **필수** |
| D9 | 락 대기 타임아웃, 메타데이터 락, 긴 트랜잭션 | 87 Q14(긴 트랜잭션 1문항) | 얕음 | Q | |
| D10 | 인덱스 생성/목록/UNIQUE/복합/LIKE 패턴, EXPLAIN 읽기 | 369(T 9), 158 Q13·14(Q), 87 Q11~13(Q) | 보통 | Q+T | 369 과밀(5개) |
| D10 | 인덱스 못 타는 패턴(함수·형변환·OR), 커버링, 카디널리티·ANALYZE TABLE | 158 Q14, 87 Q12(카디널리티 1건), 369 Q9(Extra) | 얕음 | Q+T | 커버링 NONE |
| D10 | EXPLAIN Extra(filesort·temporary), rows 추정 | 369 Q9(Using index 1건) | 얕음 | T | filesort NONE |
| D10 | 슬로우 쿼리 로그 | 402(Q 9문항, 터미널 아님) | 보통 | Q만 | 실제 로그로 조사하는 실습 없음 |
| D10 | 쿼리 튜닝 실전(서브쿼리→JOIN 변환, 정렬·그룹 인덱스, 페이징, N+1) | 없음 | 없음 | - | **필수** |
| D11 | CREATE USER·GRANT·REVOKE·SHOW GRANTS·호스트 | 158·332(Q) | 보통 | Q만(터미널 없음) | 실습 필요 |
| D11 | 최소 권한 설계(앱/백업/모니터링 계정), ROLE, 비밀번호 정책 | 없음 | 없음 | - | **필수** |
| D11 | 원격 접속 제한·bind-address·TLS | 158 에 ssl 키워드 6건은 SSL 접속 일부(추정) | 얕음 | Q | TLS 없음 |
| D11 | SQL 인젝션 개념 | 없음 | 없음 | - | 권장 |
| D11 | root 비밀번호 분실 복구(--skip-grant-tables) | 없음 | 없음 | - | 권장(상황집) |
| D12 | mariadb-dump 덤프·복원·테이블 하나 복구·압축·검증 | 109(T 5, Q 7) | 충분 | Q+T | |
| D12 | dump 일관성 옵션(--single-transaction, --master-data, --routines) | 59·91·109·415 | 충분(중복 4곳) | Q(+T91) | 중복 과다 |
| D12 | 논리 vs 물리 백업, mariadb-backup/xtrabackup 실제 절차 | 109 Q4(개념만, mariabackup 1회 언급) | 얕음 | Q | 절차 없음 |
| D12 | binlog 로 PITR(mysqlbinlog) | 59 Q8(순서 퀴즈 1개) | 얕음 | Q | **터미널 실습 없음, 필수** |
| D12 | binlog 보존·정리(PURGE·expire_logs_days)·디스크 관리 | 59·87 에 PURGE 3건 | 얕음 | Q | |
| D12 | 백업 자동화·복원 리허설 점검 | 109 Q6(운영 DB 직접 복원 금지) | 얕음 | Q | |
| D13 | 비동기/반동기 복제 개념, 복제 상태 읽기 | 59(Q), 91(T 3), 415(Q) | 보통 | Q+T(91) | 단일 서버라 실제 복제 구성 실습 불가, 상태 출력 파일 읽기 방식(추정) |
| D13 | 복제 오류 조치(skip counter·1062/1032) | 59 Q10(1문항), 91 | 얕음 | Q | 시나리오 실습 필요 |
| D13 | binlog 형식·GTID | 403, 414(Q 12문항씩) | 충분 | Q | |
| D13 | Galera(쿼럼·충돌·AUTO_INCREMENT·recv_queue) | 59(Q), 91(T) | 보통 | Q+T | SST/IST·bootstrap 순서 일부 |
| D13 | failover/switchover/split-brain, MaxScale | 59 Q6·7 | 얕음 | Q | ProxySQL·Keepalived/VIP·읽기 분리 NONE |
| D14 | PROCESSLIST·KILL, VARIABLES vs STATUS, SET GLOBAL, 용량 조회 | 158·332(Q) | 보통 | Q만 | 터미널 없음 |
| D14 | 핵심 모니터링 지표(Threads_connected·Slow_queries·Innodb_buffer_pool_reads·Handler_read_*) | 158 Q(Threads_connected 1건) | 얕음 | Q | |
| D14 | information_schema·performance_schema·sys 스키마 | 158 Q12(information_schema 1건) | 얕음 | Q | performance_schema NONE |
| D14 | InnoDB 버퍼 풀·redo 크기 튜닝, innodb_flush_log_at_trx_commit·sync_binlog | 403(버퍼 풀 LRU), 87(WAL 개념) | 얕음 | Q | 설정값 NONE |
| D14 | 버전 업그레이드(mariadb-upgrade), 시간대, 에러 로그 읽기 | 없음 | 없음 | - | 권장/선택 |
| D15 | MariaDB 상황집 | 없음(Redis 102 만 존재) | 없음 | - | **필수** |
| D16 | String/Hash/List/Set/ZSet, TTL, INCR, SCAN, INFO | 60(T 8), 99(T 5) | 충분 | Q+T | |
| D16 | Stream·Pub/Sub·HyperLogLog·Bitmap·GEO | 없음 | 없음 | - | 선택 |
| D17 | 분산 락·안전 해제·MULTI/Lua·rate limit | 60 Q11, 83(T 6) | 충분 | Q+T | 83 과밀 |
| D17 | Cache-Aside·무효화·스탬피드·big key/hot key·세션 저장 | 없음(캐시 언급은 eviction 문맥) | 없음 | - | **필수**(Redis 의 존재 이유) |
| D17 | 파이프라인, MEMORY USAGE, big key 찾기 | 없음 | 없음 | - | 권장 |
| D18 | RDB/AOF 설정·복원 | 118(T 3, Q 7), 83 | 충분 | Q+T | |
| D18 | maxmemory·eviction 정책 | 83 Q7·Q14, 102 Q3·8 | 보통 | Q+T | |
| D18 | 복제, Sentinel, Cluster | 400, 401(Q 12문항씩) | 보통 | Q만 | **터미널 실습 없음**(실제 구성/장애 유도 없음) |
| D18 | 보안(requirepass·ACL·protected-mode·bind) | 99 Q11(requirepass 접속), RENAME-COMMAND 1건 | 얕음 | Q+T | ACL 사용자 생성 없음 |
| D18 | 모니터링(INFO 섹션·latency·slowlog) | 99 Q7, 102(slowlog T) | 보통 | Q+T | latency monitor·fork 지연 NONE |
| D18 | Redis 상황집 | 102(Q 7+T 5) | 충분 | Q+T | 복제 끊김·Sentinel 전환·OOM·fork 지연 등은 추가 여지 |
| D19 | VIEW | 372 Q8(1문항) | 얕음 | T | |
| D19 | 저장 프로시저/함수·트리거·이벤트 | 없음(109·415 의 "프로시저" 는 --routines 옵션 맥락) | 없음 | - | 선택 |
| D19 | JSON 컬럼, 파티셔닝 | 403 JSON(binlog 문맥), 401 파티션(Cluster 문맥) | 없음 | - | 선택 |
| D20 | PostgreSQL | 없음 | 없음 | - | 선택 |

---

## 빈틈 목록(우선순위)

### 필수 (없으면 공개 곤란)

| # | 빈틈 | 근거 |
|---|------|------|
| M1 | **MariaDB 장애 상황집**(접속 불가·Too many connections·Access denied·락 대기·슬로우 폭주·복제 중단·디스크 풀·크래시 복구·실수 삭제) | 20 단원 세트 중 상황집 형식 0개(102 는 Redis). Too many connections·Lock wait timeout·Aborted_connects·innodb_force_recovery 검색 NONE. 91 은 점검 실습이지 오류 메시지 해석 형식이 아님 |
| M2 | **트랜잭션·락 실습**(2 세션 재현: 격리 수준 차이, FOR UPDATE, 락 대기, 데드락 발생·로그 읽기, 긴 트랜잭션) | 데드락/FOR UPDATE/SHOW ENGINE/gap lock/Lock wait timeout 전부 NONE. 87 은 개념 퀴즈(13 choice), 159 Q14 하나가 락 체험. 운영자가 가장 자주 마주치는 장애 원인 |
| M3 | **쿼리 튜닝 실전**(EXPLAIN → 원인 → 인덱스/쿼리 수정, filesort·temporary·함수 사용 인덱스 무력화·형변환·페이징) | 369 는 인덱스 문법·EXPLAIN 초입 수준, 튜닝 루프(슬로우 로그 → EXPLAIN → 수정 → 재측정) 실습 없음. 402 는 퀴즈만. filesort/커버링 NONE |
| M4 | **사용자·권한·보안 실습**(최소 권한 설계, 앱/읽기/백업 계정 분리, SHOW GRANTS 검증, 호스트 제한, ROLE, SQL 인젝션 개념) | 158·332 는 퀴즈만(터미널 0). 최소 권한·ROLE·SQL 인젝션·TLS·skip-grant 모두 NONE. 공개 시 "보안" 항목 공백 |
| M5 | **binlog 기반 PITR 실습**(실수로 DELETE → 풀백업 + mariadb-binlog 재생으로 시점 복구) | PITR 은 59 Q8 순서 퀴즈 1개. mysqlbinlog 문제 본문 1건. 109 는 dump 복원만 실습. 백업·복구 영역의 핵심 시나리오가 실습 부재 |
| M6 | **데이터 모델링·정규화·ERD** | 정규화·ERD·정규형·1:N·N:M·반정규화 전부 NONE. 표준 DB 커리큘럼의 기초 영역이 비어 있음 |
| M7 | **SQL 중급 문법 보강**: 함수(문자열·날짜·COALESCE), UNION, EXISTS/NOT EXISTS, SELF JOIN, 서브쿼리/CASE 개념 세트 | UNION·COALESCE·DATE_FORMAT·RIGHT/CROSS/SELF JOIN 전부 NONE. 372 는 서브쿼리·CASE·VIEW 를 개념 세트 없이 터미널로 도입(감사 이슈 high), 374 도 동일 |
| M8 | **Redis 캐시 패턴**(Cache-Aside·TTL 전략·무효화·스탬피드·big/hot key) | 검색 NONE. Redis 6개 세트가 자료구조·락·영속화·복제에 편중, "왜 캐시로 쓰는가·어떻게 안 깨지게 쓰는가"가 없음 |

### 권장

| # | 빈틈 | 근거 |
|---|------|------|
| R1 | 복제 장애 시나리오 실습(1062/1032 오류, 중단→원인→skip/재동기화, 지연 원인) | 59 Q10(1문항), 91 만. 복제 상태 필드 읽기까지만. 단일 서버 샌드박스 한계(추정: 복제 상태 출력 파일 읽기·가짜 상태 해석 형식으로 대체 가능) |
| R2 | 모니터링 핵심 지표·performance_schema/sys 사용(접속 수·QPS·buffer pool hit·핫 쿼리) | Slow_queries·Com_select·Handler_read·performance_schema 전부 NONE. 158 은 PROCESSLIST/VARIABLES 위주 |
| R3 | 문자셋·collation·시간대(한글 깨짐·비교 대소문자·TZ 어긋남) | utf8mb4 1건, collation·time_zone NONE |
| R4 | 대용량 변경 안전하게: 온라인 DDL(ALGORITHM/LOCK), 배치 삭제(LIMIT 반복), INSERT 배치, LOAD DATA/OUTFILE | 전부 NONE. 현장 사고 빈도 높음 |
| R5 | 물리 백업(mariadb-backup) 절차와 증분 개념, binlog 보존 정책 | 109 Q4 개념, mariabackup 1회 언급. expire_logs·PURGE 정책 퀴즈 없음 |
| R6 | InnoDB 핵심 설정(buffer pool 크기·flush_log_at_trx_commit·sync_binlog) 의미와 영향 | 403 는 LRU/덤프만. 설정값 NONE |
| R7 | Redis 보안(ACL 사용자·requirepass·protected-mode·bind), Redis 복제/Sentinel/Cluster 실습 | 99 Q11 접속만. 400·401 은 퀴즈 12문항씩 terminal 0 |
| R8 | 고가용성 접점: Keepalived/VIP, 읽기 분리, ProxySQL, 애플리케이션 failover | MaxScale 1건, 나머지 NONE |
| R9 | 단원 재정렬(선행 순서): 366(JOIN 선행)·372/374(개념 없음)·159(과밀)·59/87(기초 앞)·83 | 감사 이슈. 신규 세트의 `브리지`로 일부 해소 가능 |
| R10 | 에러 로그 읽기·기동 실패 진단·mariadb-upgrade | 에러 로그 읽는 문항 NONE |

### 선택

| # | 빈틈 | 근거 |
|---|------|------|
| O1 | 저장 프로시저/함수·트리거·이벤트·VIEW 심화 | 372 VIEW 1문항 외 NONE. 사내 운영자 활용도 중하 |
| O2 | JSON 컬럼, 파티셔닝 | 맥락 외 NONE |
| O3 | Redis Stream·Pub/Sub·HyperLogLog·Bitmap·GEO | NONE |
| O4 | ROLLUP·GROUP_CONCAT·EXCEPT/INTERSECT | NONE |
| O5 | PostgreSQL 입문(psql·VACUUM·pg_dump/PITR 개요) | 현재 0. 지시상 선택 |
| O6 | 감사 로그(server_audit 플러그인) | NONE |

---

## 신규 세트 백로그

원칙: 기존 사다리의 빈 칸을 메우는 최소 세트. 개념은 계단식(새 개념 1~2개씩, 기초→핵심→응용). 터미널은 `linux-db`(MariaDB 단일 서버, shop DB)·`linux`(Redis). 2 세션이 필요한 실습은 샌드박스가 백그라운드 세션을 지원하는지가 전제(`추정`: 터미널 셸에서 `mariadb -e "..." &` 또는 두 번째 접속을 셸 `&` 로 띄워 재현 가능, 구현 시 확인). 복제 시나리오는 실제 2 서버가 어려우면 "출력 파일/상황 파일을 읽고 판단·수정"하는 형식으로 대체(`추정`).

### 백로그 표

| 우선순위 | 제목 | 형식 | 들어갈 단원 | 선행 | 핵심 개념(계단식) | 예상 문제 수 |
|---|---|---|---|---|---|---|
| 필수 1 | **MariaDB 문제 해결 상황집 (1) 접속·권한·연결 수** | 상황집(T) | 20 MariaDB 운영 (158/332 뒤) | 158·332 | ① `Access denied`(계정·호스트·비밀번호) ② `Can't connect`(서비스·소켓·포트) ③ `Too many connections`(max_connections·Threads_connected·PROCESSLIST) ④ `Aborted_connects`·잠긴 계정 | 10~12 (T 8, Q 3) |
| 필수 2 | **MariaDB 문제 해결 상황집 (2) 락·느림·디스크** | 상황집(T) | 20 MariaDB 운영 | 위 세트, 트랜잭션 락 세트 | ① `Lock wait timeout exceeded` 원인 세션 찾아 KILL ② 데드락 로그 읽기 ③ 느린 쿼리 폭주(PROCESSLIST→EXPLAIN→인덱스) ④ 디스크 풀(binlog·임시 파일·대용량 테이블) ⑤ 에러 로그 읽기 | 12 (T 9, Q 3) |
| 필수 3 | **MariaDB 문제 해결 상황집 (3) 복제·복구** | 상황집(T+Q) | 20 MariaDB 운영 (복제 세트들 뒤) | 59·91·414 | ① 복제 중단 1062/1032 해석 ② Seconds_Behind 지연 원인 ③ 실수 삭제 복구 ④ 크래시 후 기동 실패(innodb_force_recovery 개념) ⑤ root 비밀번호 분실 복구 | 10~12 (T 6, Q 5) |
| 필수 4 | **트랜잭션과 격리 수준 체험** | 터미널 실습 | 45 SQL 3 (367 뒤) 또는 20 MariaDB 운영 입구 | 159·333·367 | ① 두 세션 만들기·autocommit 끄기 ② READ COMMITTED vs REPEATABLE READ 차이 재현 ③ 커밋 안 된 변경이 안 보이는 것 ④ SAVEPOINT·부분 롤백 | 9~10 (T 7, Q 2~3) |
| 필수 5 | **락과 데드락 직접 만들어 보기** | 터미널 실습 | 20 MariaDB 운영 (87 앞) | 필수 4 | ① `SELECT ... FOR UPDATE`와 행 락 ② 락 대기와 `innodb_lock_wait_timeout` ③ 데드락 재현(두 세션 교차 갱신) ④ `SHOW ENGINE INNODB STATUS`/`information_schema` 로 대기 관계 읽기 ⑤ 긴 트랜잭션 찾기·KILL ⑥ 예방(접근 순서 통일·짧은 트랜잭션) | 10~12 (T 9, Q 3) |
| 필수 6 | **쿼리 튜닝 (1) EXPLAIN 읽기와 인덱스 못 타는 이유** | 개념 퀴즈+터미널 | 46 SQL 4 (369 뒤) | 369·158 | ① EXPLAIN 열(type·key·rows·Extra) ② 함수·형변환·앞 와일드카드로 인덱스 무력화 ③ 복합 인덱스 순서·커버링 ④ `Using filesort`/`Using temporary` 제거 | 12 (T 8, Q 4) |
| 필수 7 | **쿼리 튜닝 (2) 슬로우 쿼리 개선 실전** | 터미널 실습 | 46 SQL 4 → 20 MariaDB 운영(402 뒤) | 필수 6, 402 | ① 슬로우 로그에서 후보 찾기 ② 측정 전/후 비교(ANALYZE/EXPLAIN·시간) ③ 서브쿼리→JOIN, OR→UNION ④ 페이징(OFFSET→키셋) ⑤ 통계 갱신(ANALYZE TABLE) | 10~12 (T 10, Q 2) |
| 필수 8 | **계정·권한 설계 실습** | 터미널 실습 | 20 MariaDB 운영 (158/332 뒤) | 158·332 | ① 앱용 계정 만들기(호스트 제한) ② 읽기 전용 계정 ③ 최소 권한 점검(SHOW GRANTS) ④ 권한 회수·계정 삭제 ⑤ ROLE 로 묶기 ⑥ 비밀번호·원격 접속 제한 | 10 (T 8, Q 2) |
| 필수 9 | **DB 보안 기본: SQL 인젝션·TLS·노출 점검** | 개념 퀴즈 | 20 MariaDB 운영 | 필수 8 | ① SQL 인젝션 원리와 방어(파라미터 바인딩) ② 접속 암호화(TLS) 확인 ③ 바인드 주소·기본 계정 점검 ④ 백업 파일·덤프 속 민감정보 | 12 (Q 10, 빈칸·순서 2) |
| 필수 10 | **binlog 와 시점 복구(PITR) 실습** | 터미널 실습 | 20 MariaDB 운영 (109 뒤, 59 앞으로 이동 권고) | 109 | ① binlog 켜기·목록·위치 확인 ② 이벤트 읽기(mariadb-binlog) ③ 실수 시점 찾기 ④ 풀 백업 복원 + binlog 재생(stop-datetime/position) ⑤ 복구 후 검증 | 9~10 (T 8, Q 2) |
| 필수 11 | **데이터 모델링 기초 (1) 테이블 나누기와 관계** | 개념 퀴즈 | 신규 단원 "SQL 5 · 설계" 또는 46 SQL 4 (164 앞) | 125·141 | ① 엔티티·속성·PK ② 1:N 과 FK ③ N:M 과 연결 테이블 ④ ERD 읽기 | 12~15 (Q, 객관식·빈칸·순서 혼합) |
| 필수 12 | **데이터 모델링 기초 (2) 정규화와 반정규화** | 개념 퀴즈+터미널 | 위 단원 | 필수 11 | ① 이상 현상(삽입·갱신·삭제) ② 1NF ③ 2NF ④ 3NF ⑤ 반정규화를 선택하는 이유·위험 ⑥ 실제 쪼개 보기(CREATE+INSERT…SELECT) | 12 (Q 8, T 4) |
| 필수 13 | **SQL 중급 (1) 함수: 문자열·숫자·날짜·NULL** | 개념 퀴즈+터미널 | 30 SQL 1 (140/330 뒤, 366 앞) | 139·140 | ① COALESCE·IFNULL ② 문자열(CONCAT·SUBSTRING·REPLACE) ③ 날짜(NOW·DATE_FORMAT·DATEDIFF·간격) ④ 숫자(ROUND) ⑤ 조건식 CASE 기초 | 12 (Q 6, T 6) |
| 필수 14 | **SQL 중급 (2) JOIN 확장과 UNION** | 개념 퀴즈+터미널 | 44 SQL 2 (331 뒤, 372 앞) | 141·331 | ① RIGHT/CROSS JOIN ② SELF JOIN(상사-직원) ③ UNION vs UNION ALL ④ 중복·정렬 규칙 | 10~12 (Q 5, T 6) |
| 필수 15 | **SQL 중급 (3) 서브쿼리와 EXISTS 개념** | 개념 퀴즈 | 44 SQL 2 (필수 14 뒤, 372 앞) | 필수 14 | ① 스칼라·IN 서브쿼리 ② EXISTS/NOT EXISTS ③ NOT IN 과 NULL 함정 ④ 파생 테이블 ⑤ CASE 로 분류 ⑥ VIEW 개념 | 14 (Q 10, 빈칸 2, 순서 2) |
| 필수 16 | **SQL 윈도 함수·WITH 개념 입문** | 개념 퀴즈 | 44 SQL 2 (372 뒤, 374 앞) | 필수 15 | ① WITH(CTE) ② ROW_NUMBER ③ RANK/DENSE_RANK 차이 ④ PARTITION BY ⑤ 누적·LAG | 12 (Q 9, 빈칸·순서 3) |
| 필수 17 | **Redis 캐시 패턴 입문 (Cache-Aside)** | 개념 퀴즈+터미널 | 31 Redis (99 뒤, 83 앞) | 60·99 | ① Cache-Aside 읽기/쓰기 순서 ② TTL 설계 ③ 무효화(삭제 vs 갱신) ④ 캐시 미스 폭주(스탬피드) 개념 ⑤ 세션 저장 | 12 (Q 7, T 5) |
| 권장 1 | **Redis 캐시 운영: big key·hot key·메모리** | 터미널 실습 | 31 Redis (102 뒤) | 필수 17·83 | ① big key 찾기(--bigkeys·MEMORY USAGE) ② hot key 징후 ③ eviction 정책 선택 실습 ④ 파이프라인으로 대량 입력 | 9~10 (T 8, Q 2) |
| 권장 2 | **복제 장애 시나리오 실습** | 상황집(T) | 20 MariaDB 운영 | 59·91·414 | ① 상태 출력 읽고 원인 분류 ② 1062/1032 해석 ③ 안전한 조치와 위험한 조치 ④ 재동기화 절차 | 8~10 |
| 권장 3 | **MariaDB 모니터링 지표 읽기** | 터미널 실습 | 20 MariaDB 운영 (158 뒤) | 158·332 | ① STATUS 핵심 지표(Threads·Slow_queries·Questions) ② 버퍼 풀 히트율 ③ information_schema 로 큰 테이블 찾기 ④ performance_schema/sys 로 느린 쿼리 | 10 (T 8, Q 2) |
| 권장 4 | **대용량 데이터 다룰 때 안전 수칙** | 개념 퀴즈+터미널 | 45 SQL 3 (367 뒤) 또는 46 SQL 4 | 159·164·371 | ① 배치 삭제(LIMIT 반복) ② 온라인 DDL(ALGORITHM/LOCK) ③ LOAD DATA/OUTFILE ④ 대형 ALTER 전 점검 | 10~12 |
| 권장 5 | **문자셋·collation·시간대** | 개념 퀴즈+터미널 | 46 SQL 4 (371 뒤) | 164·371 | ① utf8mb4 와 한글/이모지 ② collation 과 대소문자 비교 ③ DATETIME vs TIMESTAMP, 서버·세션 시간대 | 10 |
| 권장 6 | **mariadb-backup(물리 백업) 입문과 binlog 정리** | 개념 퀴즈 | 20 MariaDB 운영 (109 뒤) | 109 | ① 논리 vs 물리 선택 ② full/incremental 개념 ③ prepare·restore 순서 ④ binlog 보존·PURGE | 10~12 |
| 권장 7 | **Redis 보안·ACL 과 Sentinel 실습** | 터미널 실습 | 31 Redis (401 뒤) | 99·401 | ① requirepass·protected-mode·bind ② ACL 사용자(읽기 전용) ③ Sentinel 상태 명령으로 마스터 확인·failover 흐름 읽기 | 9~10 (T 7, Q 2) |
| 권장 8 | **InnoDB 핵심 설정과 영향** | 개념 퀴즈 | 20 MariaDB 운영 (87·403 뒤) | 87·403 | ① buffer pool 크기 ② flush_log_at_trx_commit ③ sync_binlog ④ 내구성 vs 성능 | 10 |
| 선택 | 프로시저·트리거·이벤트 입문 | 개념 퀴즈 | 신규 단원 후보 | 372 | VIEW → 프로시저 → 트리거 → 이벤트 | 12 |
| 선택 | PostgreSQL 입문(psql·VACUUM·pg_dump) | 개념 퀴즈 | 새 코스 후보 | - | psql 기본 → MariaDB 와의 차이 → 백업 | 12 |

필수 17개, 권장 8개, 선택 2개 = **27개**. 우선 제작 순서 제안(공개 임박 기준, 한 번에 다 못 만들 때):
1. 상황집 3종(필수 1~3) + 락·데드락(필수 4~5) — 운영자 가치가 가장 크고 현재 완전 공백.
2. 튜닝(필수 6~7), 권한·보안(필수 8~9), PITR(필수 10).
3. SQL 중급(필수 13~16)과 모델링(필수 11~12) — 학습 사다리 완성.
4. Redis 캐시(필수 17) 후 권장군.

**메모(세트 수 줄이는 옵션)**: 필수 9 는 필수 8 과 합쳐 1세트(권한+보안)로, 필수 15·16 은 합쳐 1세트(서브쿼리+윈도 개념)로 해도 개념 밀도가 허용 범위(감사의 "6개 이상 과다" 기준을 넘으므로 비추천, 합치면 2세트 분량). 일정 때문에 줄여야 하면 필수 9 와 필수 12 의 터미널 부분을 먼저 줄인다.

---

## 형식 균형

### 현재 분포(문제 수 기준, 집계 결과)

- 터미널(terminal) 문제를 가진 세트: 60·83·91·99·102·109·118(Redis·MariaDB 운영 일부), 126·366·367·369·371·372·374(SQL 손연습). 그 외 28개 안팎 세트는 choice/fill/order 만.
- 개념 퀴즈 세트의 구성은 choice 14 + fill 1 + order 1(139·140·141·158·159·164) 또는 fill 10 + order 4(329~334 의 "(2/2)" 반복 세트) 로 **형식이 2가지로 고정**.
- MariaDB 운영 단원(20): 세트 10개 중 터미널 있는 세트는 109·91 둘뿐. 59·87·402·403·414·415·158·332 는 100% 퀴즈. 복제·GTID·로그·권한·모니터링·격리 수준은 "읽고 맞추기"로만 학습.
- Redis 단원(31): 60·83·99·102·118 은 터미널 비중 높음(좋음). 400·401(복제·Sentinel/Cluster)은 퀴즈 전용.

### 권고

| 영역 | 현재 | 권고 비율(터미널 : 퀴즈) | 이유 |
|------|------|--------------------------|------|
| SQL 조회~변경(D2~D6) | 개념 세트 → 터미널 손연습 구조(양호) | 40 : 60 유지. 단, **개념 설명 없는 터미널 세트(372·374·366 의 JOIN)에는 앞에 개념 세트 추가**(필수 14~16) | 순서 오류가 문제 |
| 트랜잭션·락·데드락(D9) | 퀴즈 전용 | **70 : 30** | 2 세션 재현이 이해의 핵심. 퀴즈로는 락 대기·데드락 체감이 안 됨 |
| 인덱스·튜닝(D10) | 369 만 터미널, 402 퀴즈 | **70 : 30** | 측정→수정→재측정 루프는 실습 필수 |
| 권한·보안(D11) | 퀴즈 전용 | **60 : 40** | GRANT/SHOW GRANTS 는 직접 확인해야 정착 |
| 백업·PITR(D12) | dump 만 터미널 | **60 : 40** | PITR 과 복원 검증은 실습이 본질 |
| 복제·HA(D13) | 퀴즈 중심, 91 만 터미널 | **40 : 60** | 샌드박스 한계(다중 서버)로 상태 읽기·설정 수정·로그 해석 형태 실습 위주. 구성 실습은 어렵다 |
| 운영·모니터링(D14) | 퀴즈 전용 | **60 : 40** | STATUS/information_schema 는 직접 조회해야 의미 |
| 상황집(D15) | 없음 | **80 : 20** | 오류 재현→원인 확인→수정 |
| 데이터 모델링(D8) | 없음 | **30 : 70** | 개념 중심. 마지막에 CREATE 로 쪼개 보기 정도만 터미널 |
| Redis 복제·Sentinel/Cluster(D18) | 400·401 퀴즈 전용 | **50 : 50** | 상태 명령 출력 읽기·설정 파일 수정 실습 추가 |

### 문제 형식 다양화 (프로젝트 규칙: 한 세트에 형식 3종 이상, 객관식 편중 금지)

- 139·140·141·158·159·164·59·87·400~415 는 choice 9~14 개에 fill 1~2·order 1 이라 **객관식 편중**. 신규 세트는 `읽고 고치기`(오류가 있는 SQL/설정 수정), `출력 읽고 원인 고르기`, `순서`, `빈칸`, `터미널`을 섞어 한 세트 3종 이상.
- (2/2) 반복 세트(329~334)는 fill 10·order 4·choice 1 로 객관식이 오히려 적다. 의도된 보완 구조이므로 유지.

---

## 상황집

### 현재
- **Redis**: 세트 102 "Redis 문제 해결 상황집: OOM, 연결 거부, 느린 명령" (Q 7 + T 5). OOM·Connection refused·slowlog·max clients·TTL 없는 키는 있음.
- **MariaDB/SQL**: 상황집 형식 세트 **0개**. 비슷한 것으로 159 의 INSERT/UPDATE 오류 코드 해석(1062·1364·1048, 퀴즈), 164 의 자료형 오류(1406·1366·1292, 퀴즈), 91 의 복제·Galera 점검(터미널), 109 의 "삭제된 DB 를 덤프에서 복구"(T 10). 모두 단편적이고 "운영 중 오류를 만나서 읽고 푸는" 서사가 아니다.

### 필요한 시나리오 (오류 메시지 → 원인 → 해결, 모두 재현 가능한 일반 상황)

**(1) 접속·연결·권한**
1. `ERROR 1045 Access denied for user` — 비밀번호/호스트(`user@host`)/인증 플러그인 확인 → 계정 확인·재설정
2. `ERROR 2002/2003 Can't connect` — 서비스 중지·소켓 경로·포트 리슨 확인 → 서비스 기동
3. `ERROR 1040 Too many connections` — Threads_connected·PROCESSLIST 로 누가 점유하는지 확인 → 유휴 연결 정리·max_connections·앱 커넥션 풀
4. `ERROR 1044/1142 command denied` — 권한 부족 → SHOW GRANTS 로 확인 후 최소 권한만 부여
5. `ERROR 1130 Host is not allowed` — 원격 호스트 제한 → 계정 호스트 부분·bind-address 확인

**(2) 락·성능**
6. `ERROR 1205 Lock wait timeout exceeded` — 열려 있는 긴 트랜잭션(information_schema.INNODB_TRX) 찾아 해제 → 앱 쪽 트랜잭션 짧게
7. `ERROR 1213 Deadlock found` — 재현, `SHOW ENGINE INNODB STATUS` 로 원인 읽기 → 접근 순서 통일·재시도
8. 쿼리 하나가 서버 전체를 느리게 — PROCESSLIST → KILL → EXPLAIN → 인덱스
9. `Waiting for table metadata lock` — 장시간 열린 트랜잭션이 ALTER 를 막는 상황
10. `ERROR 1206`/`ERROR 1114 table is full`·디스크 풀 — 임시/로그/데이터 용량 위치 확인 → binlog 정리·큰 테이블 정리 (실제 디스크 채우기는 재현 위험, 설정값·df 출력 해석 형식으로 대체, `추정`)

**(3) 복제·복구**
11. `Duplicate entry` 로 SQL 스레드 중단 — SHOW REPLICA STATUS 해석 → 위험한 skip 과 안전한 조치 구분
12. `Seconds_Behind_Master` 증가 — 큰 트랜잭션·단일 스레드·레플리카 부하 구분
13. 실수로 `DELETE`/`DROP` — 백업 + binlog 로 복구(필수 10 과 연동)
14. 서버가 기동하지 않음 — 에러 로그 읽기(권한·디스크·설정 오류), InnoDB 복구 모드 개념
15. root 비밀번호 분실 — skip-grant-tables 로 임시 접속 후 재설정, 보안 위험 인지

**(4) 데이터·문자열**
16. `ERROR 1366 Incorrect string value`(한글/이모지) — 문자셋 확인 → utf8mb4
17. `ERROR 1292/1264 out of range`·잘림 경고 — 자료형 선택, strict mode
18. `ERROR 1451/1452` 외래 키 위반 — 부모/자식 삭제·삽입 순서

→ 필수 1~3 세 세트로 위 시나리오 1~16 을 나눠 담고, 17·18 은 164·334 와 겹치므로 신규 세트에서 제외(이미 부분 커버).

**Redis 상황집 보강 여지(권장, 102 확장 또는 별도 세트)**: 복제 끊김(`MASTER_LINK_STATUS down`)·Sentinel 전환 후 클라이언트 연결 실패·fork 지연(대용량 RDB 시 지연)·`NOAUTH Authentication required`·`READONLY You can't write against a read only replica`.

---

## 부록: 감사 이슈와 신규 세트의 연결

| 감사 이슈 | 신규 세트에서 해소 |
|-----------|--------------------|
| 366 이 JOIN 선행 요구 | 필수 13(함수)로 366 앞 단계 보강은 되나 366 자체 문제 7~9 분리/이동은 별도 편집 필요(신규 아님) |
| 372 가 서브쿼리·CASE·VIEW 를 개념 없이 도입 | 필수 14·15 가 선행 개념 세트가 됨 |
| 374 윈도 개념 없음 | 필수 16 |
| 159 과다(트랜잭션 포함) | 필수 4 가 트랜잭션 단일 개념 입문, 159 자체 분할은 별도 편집 |
| 59·87 이 기초(158·109·414)보다 앞 | 필수 10(binlog)·필수 5(락)가 입구 역할. 재배치는 별도 편집 |
| 369 EXPLAIN 읽는 법을 가르치는 세트 없음 | 필수 6 |
| 83 과밀·Redis 캐시 패턴 부재 | 필수 17 이 캐시 사용 개념을 앞에서 담당, 83 자체 분할은 별도 편집 |

민감·현장 정보 없음. 모든 시나리오는 일반화된 개념 기준.
