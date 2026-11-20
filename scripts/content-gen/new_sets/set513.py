import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 513: MariaDB 문제 해결 상황집 (2) 느린 쿼리 폭주, 에러 로그, 디스크. 명세: docs/specs/spec_gap_set513.md
# 선행: 502·503(락·접속 오류), 505·506(EXPLAIN·인덱스). 락·데드락은 다루지 않는다.

CLEAN13 = "rm -rf /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf /tmp/*.log"
LABSOCK = "mariadb -S /tmp/lab/mysql.sock"
# 연습용 보조 서버(/tmp/lab)를 내린다. 데이터 디렉터리도 지운다.
LABDOWN = ("mariadb-admin -S /tmp/lab/mysql.sock shutdown >/dev/null 2>&1; for i in $(seq 1 30); do [ -S /tmp/lab/mysql.sock ] || break; sleep 0.5; done; rm -rf /tmp/lab")
LABINIT = ("mkdir -p /tmp/lab && chown mysql:mysql /tmp/lab && mariadb-install-db --user=mysql --datadir=/tmp/lab/data --auth-root-authentication-method=normal --skip-test-db >/dev/null 2>&1")
LABWAIT = "for i in $(seq 1 60); do mariadb -S /tmp/lab/mysql.sock -e 'select 1' >/dev/null 2>&1 && break; sleep 0.5; done"
# 다른 세션을 모두 끊고 느린 쿼리 로그를 기본 상태로 되돌린다.
MAINRESET = ("for id in $(mariadb -N -e \"SELECT id FROM information_schema.processlist WHERE id<>CONNECTION_ID()\"); do mariadb -e \"KILL $id\" >/dev/null 2>&1; done; "
             "mariadb -e 'SET GLOBAL slow_query_log=0; SET GLOBAL long_query_time=10'")

SHOP13 = (LABDOWN + "; " + DBUP + "; " + MAINRESET + """; mariadb -e 'DROP DATABASE IF EXISTS shop; CREATE DATABASE shop; USE shop; CREATE TABLE orders (id INT AUTO_INCREMENT PRIMARY KEY, customer_id INT NOT NULL, amount INT NOT NULL, created_at DATETIME NOT NULL) ENGINE=InnoDB; INSERT INTO orders (customer_id, amount, created_at) SELECT seq % 1000, seq % 500, NOW() - INTERVAL (seq % 365) DAY FROM seq_1_to_300000; DROP USER IF EXISTS "report"@"localhost"; CREATE USER "report"@"localhost" IDENTIFIED BY "R3port"; GRANT SELECT ON shop.* TO "report"@"localhost"; DROP USER IF EXISTS "app"@"localhost"; CREATE USER "app"@"localhost" IDENTIFIED BY "S3cret"; GRANT ALL ON shop.* TO "app"@"localhost"; FLUSH PRIVILEGES;'; """ + CLEAN13)

# app 세션 하나(정상)와 report 세션 셋(같은 느린 쿼리)을 띄우고 6초 기다린다
STORM = (SHOP13 + "; nohup mariadb -uapp -pS3cret shop -e 'SELECT SLEEP(600)' >/dev/null 2>&1 & sleep 1; "
         "for i in 1 2 3; do nohup mariadb -ureport -pR3port shop -e \"SELECT COUNT(*), SUM(amount) FROM orders WHERE customer_id = 7 AND SLEEP(600)\" >/dev/null 2>&1 & sleep 1; done; sleep 3")

# 용량 연습: shop(작음)과 archive(큼, 약 56MB)
BIG13 = (SHOP13 + """; mariadb -e 'DROP DATABASE IF EXISTS archive; CREATE DATABASE archive; USE archive; CREATE TABLE events_log (id INT AUTO_INCREMENT PRIMARY KEY, msg VARCHAR(255) NOT NULL) ENGINE=InnoDB; INSERT INTO events_log (msg) SELECT REPEAT(CHAR(97 + seq % 26), 200) FROM seq_1_to_200000;'""")

# 설정에 오타가 있어 뜨지 못하는 보조 서버
LABBAD = (LABDOWN + "; " + CLEAN13 + "; " + LABINIT + "; printf '[mysqld]\\ndatadir=/tmp/lab/data\\nsocket=/tmp/lab/mysql.sock\\npid-file=/tmp/lab/mysql.pid\\nskip-networking\\nlog-error=/tmp/lab/error.log\\nuser=mysql\\ninnodb_buffer_pool_sizee=64M\\n' > /tmp/lab/my.cnf; "
          "chown mysql:mysql /tmp/lab/my.cnf; mariadbd --defaults-file=/tmp/lab/my.cnf >/dev/null 2>&1; true")

# 이진 로그(binlog)가 5개 쌓인 보조 서버. 보관 기간 설정은 없다(기본 0 = 영원히 보관).
LABBINLOG = (LABDOWN + "; " + CLEAN13 + "; " + LABINIT + "; printf '[mysqld]\\ndatadir=/tmp/lab/data\\nsocket=/tmp/lab/mysql.sock\\npid-file=/tmp/lab/mysql.pid\\nskip-networking\\nlog-error=/tmp/lab/error.log\\nuser=mysql\\nlog-bin=/tmp/lab/binlog\\nserver-id=1\\n' > /tmp/lab/my.cnf; "
             "chown mysql:mysql /tmp/lab/my.cnf; nohup mariadbd --defaults-file=/tmp/lab/my.cnf >/dev/null 2>&1 & " + LABWAIT + "; "
             + LABSOCK + " -e 'CREATE DATABASE d; CREATE TABLE d.t (id INT AUTO_INCREMENT PRIMARY KEY, v VARCHAR(200))'; "
             "for i in 1 2 3 4; do " + LABSOCK + " d -e \"INSERT INTO d.t (v) SELECT REPEAT('x', 200) FROM seq_1_to_5000; FLUSH BINARY LOGS\"; done")

b = SetBuilder(513, 'MariaDB 문제 해결 상황집 (2): 느린 쿼리 폭주, 에러 로그, 디스크',
               'MariaDB 가 느려지거나 멈추는 운영 상황을 직접 해결합니다. PROCESSLIST 로 폭주한 쿼리 찾기, KILL QUERY 로 중단, EXPLAIN 으로 전체 훑기 확인, 인덱스 추가, 느린 쿼리 로그 켜기, 에러 로그(/tmp/lab/error.log)로 서버가 안 뜨는 원인 찾기, du 로 용량을 먹는 DB·파일 찾기, PURGE BINARY LOGS 로 binlog 정리, 큰 테이블 정리 후 OPTIMIZE TABLE 로 디스크 돌려받기를 연습합니다.',
               'linux-db', '데이터베이스', 20, 734, '🔥',
               [{"title": "MariaDB 슬로 쿼리 로그", "url": "https://mariadb.com/kb/en/slow-query-log-overview/"}, {"title": "PURGE BINARY LOGS", "url": "https://mariadb.com/kb/en/purge-binary-logs/"}], 6)

# 1 -------------------------------------------------------------
b.nt('서버가 느리다: 폭주한 세션 찾기', '`shop` 데이터베이스를 쓰는 서비스가 갑자기 느려졌습니다. 보고서 도구가 쓰는 `report` 계정이 비슷한 쿼리를 여러 개 동시에 돌리고 있다는 제보가 있습니다.\n\n서버에서 실행 중인 세션 목록을 보고, **`report` 계정의 세션 Id** 를 모두 `/tmp/ids.txt` 에 한 줄에 하나씩 저장하세요. (`app` 계정 등 다른 세션은 제외)',
     '`SHOW FULL PROCESSLIST;` 로 목록을 보거나, `information_schema.processlist` 를 `User` 로 걸러 조회하세요. `-N` 은 제목 줄을 빼 줍니다.',
     "mariadb -e 'SHOW FULL PROCESSLIST'\nmariadb -N -e \"SELECT id FROM information_schema.processlist WHERE user='report'\" > /tmp/ids.txt\ncat /tmp/ids.txt\n\n# PROCESSLIST 의 Id 가 KILL 할 때 쓰는 번호. Time 이 길고 Info 가 같은 쿼리가 줄지어 있으면 폭주 신호다",
     STORM,
     [chk('파일에 세션 Id 가 있다', '[ -s /tmp/ids.txt ]'),
      chk('report 계정의 세션과 정확히 같다', '[ "$(sort -n /tmp/ids.txt | tr \'\\n\' \' \')" = "$(mariadb -N -e "SELECT id FROM information_schema.processlist WHERE user=\'report\' ORDER BY id" | tr \'\\n\' \' \')" ]')])
# 2 -------------------------------------------------------------
b.nt('폭주한 쿼리만 멈추기: KILL QUERY', '앞 문제와 같은 상황입니다. `report` 계정의 쿼리 세 개가 `shop.orders` 를 오래 붙잡고 서비스를 느리게 만듭니다. 급한 불을 끄세요. **`report` 계정의 쿼리를 모두 중단**하되, 정상적으로 일하는 **`app` 계정의 세션은 건드리지 마세요.**\n\n(`KILL QUERY 번호` 는 접속은 두고 실행 중인 쿼리만 멈춥니다. `KILL 번호` 는 접속 자체를 끊습니다.)',
     '세션 번호를 하나씩 직접 쓰거나, 번호를 조회해 반복문으로 돌려도 됩니다. 어느 계정의 세션을 끊는지 꼭 확인하세요.',
     "for id in $(mariadb -N -e \"SELECT id FROM information_schema.processlist WHERE user='report'\"); do mariadb -e \"KILL QUERY $id\"; done\nsleep 1\nmariadb -e 'SHOW FULL PROCESSLIST'\n\n# 조회·반복문 모두 user 로 범위를 좁혀야 한다. 범위를 안 좁히고 전부 KILL 하면 정상 서비스까지 끊긴다",
     STORM,
     [chk('report 의 실행 중 쿼리가 없다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.processlist WHERE user=\'report\' AND command=\'Query\'")" = 0 ]'),
      chk('app 세션은 살아 있다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.processlist WHERE user=\'app\'")" = 1 ]')])
# 3 -------------------------------------------------------------
b.nt('EXPLAIN: 전체를 훑고 있다', '폭주한 원인은 `shop` 의 `orders` 테이블(주문 30만 건)에서 고객별로 조회하는 쿼리가 느린 것이었습니다. 이 쿼리가 어떻게 실행되는지 `EXPLAIN` 으로 확인하세요.\n\n`SELECT * FROM orders WHERE customer_id = 77` 의 실행 계획에서 다음 두 값을 파일에 저장하세요. (값만)\n- `/tmp/type.txt` : `type` 열 (접근 방식. `ALL` 은 테이블 전체 훑기, `ref` 는 인덱스로 찾기)\n- `/tmp/rows.txt` : `rows` 열 (읽을 것으로 예상한 행 수)',
     '`mariadb -N shop -e "EXPLAIN SELECT ..."` 의 출력은 탭으로 구분된 열입니다. `cut -f 번호` 로 필요한 열만 뽑으세요. 열 순서는 `\\G` 로 보면 알 수 있습니다.',
     "mariadb -N shop -e 'EXPLAIN SELECT * FROM orders WHERE customer_id = 77' | cut -f4 > /tmp/type.txt\nmariadb -N shop -e 'EXPLAIN SELECT * FROM orders WHERE customer_id = 77' | cut -f9 > /tmp/rows.txt\ncat /tmp/type.txt /tmp/rows.txt\n\n# type=ALL 이고 rows 가 테이블 전체 행 수와 비슷하면 인덱스를 못 타고 다 읽는 중이다",
     SHOP13,
     [chk('type 이 ALL 이다', '[ "$(cat /tmp/type.txt)" = ALL ]'),
      chk('rows 가 20만 이상이다', '[ "$(cat /tmp/rows.txt)" -ge 200000 ]')])
# 4 -------------------------------------------------------------
b.nt('인덱스로 고치고 EXPLAIN 으로 확인', '`shop.orders` 에는 `customer_id` 인덱스가 없어 고객 한 명의 주문을 찾을 때마다 30만 건을 모두 읽습니다. 인덱스를 만들어 `SELECT * FROM orders WHERE customer_id = 77` 이 **인덱스를 타게** 고치세요. 데이터(30만 건)는 그대로 둡니다.\n\n(큰 운영 테이블에서 인덱스를 만들면 시간이 걸리고 디스크도 씁니다. 사용이 적은 시간에 합니다.)',
     '`CREATE INDEX 이름 ON 테이블 (컬럼)` 입니다. 만든 뒤 `EXPLAIN` 의 `type` 과 `key` 열이 어떻게 바뀌는지 직접 확인하세요.',
     "mariadb shop -e 'CREATE INDEX idx_orders_customer ON orders (customer_id)'\nmariadb shop -e 'EXPLAIN SELECT * FROM orders WHERE customer_id = 77'\n\n# 이제 type=ref, rows 는 수백 건으로 줄어든다. 인덱스는 조회를 빠르게 하는 대신 쓰기와 용량 비용이 든다",
     SHOP13,
     [chk('EXPLAIN type 이 ref 다', '[ "$(mariadb -N shop -e \'EXPLAIN SELECT * FROM orders WHERE customer_id = 77\' | cut -f4)" = ref ]'),
      chk('읽는 행이 5000 이하다', '[ "$(mariadb -N shop -e \'EXPLAIN SELECT * FROM orders WHERE customer_id = 77\' | cut -f9)" -le 5000 ]'),
      chk('주문 30만 건이 그대로다', '[ "$(mariadb -N shop -e \'SELECT COUNT(*) FROM orders\')" = 300000 ]')])
# 5 -------------------------------------------------------------
b.nt('느린 쿼리 로그 켜기', '느린 쿼리를 **사후에도** 찾으려면 느린 쿼리 로그를 켜 두어야 합니다. 지금 서버에는 꺼져 있습니다. 서버를 재시작하지 않고 다음과 같이 설정하세요.\n- 로그 켜기\n- **1초 이상** 걸린 쿼리를 기록\n- 기록 파일: `/tmp/slow.log`\n\n설정한 뒤 `SELECT SLEEP(2)` 를 한 번 실행해, 로그 파일에 그 쿼리가 실제로 남게 하세요.',
     '`SET GLOBAL 변수=값;` 으로 서버 실행 중에 바꿀 수 있는 변수들입니다. 변수 이름은 `SHOW VARIABLES LIKE \'%slow%\';` 와 `SHOW VARIABLES LIKE \'long_query%\';` 로 찾으세요. 쿼리는 설정이 끝난 뒤에 실행해야 기록됩니다.',
     "mariadb -e \"SET GLOBAL slow_query_log_file='/tmp/slow.log'; SET GLOBAL long_query_time=1; SET GLOBAL slow_query_log=1\"\nmariadb -e 'SELECT SLEEP(2)'\ncat /tmp/slow.log\n\n# SET GLOBAL 은 새로 맺는 접속부터 적용된다. 재시작하면 사라지니 영구 설정은 설정 파일(my.cnf)에도 적는다",
     SHOP13,
     [chk('느린 쿼리 로그가 켜져 있다', '[ "$(mariadb -N -e \'SELECT @@slow_query_log\')" = 1 ]'),
      chk('기준이 1초 이하다', '[ "$(mariadb -N -e \'SELECT @@global.long_query_time <= 1\')" = 1 ]'),
      chk('파일에 SLEEP(2) 가 남았다', 'grep -q "SLEEP(2)" /tmp/slow.log')])
# 6 -------------------------------------------------------------
b.nt('서버가 안 뜬다: 에러 로그 읽기', '연습용 MariaDB 서버(설정 `/tmp/lab/my.cnf`, 소켓 `/tmp/lab/mysql.sock`)가 뜨지 않고 바로 종료됩니다. 서버는 `mariadbd --defaults-file=/tmp/lab/my.cnf` 로 띄우며, 서버가 남긴 **에러 로그는 `/tmp/lab/error.log`** 입니다.\n\n에러 로그에서 원인을 찾아 설정 파일을 고치고, 서버를 띄우세요. 서버가 떠 있는 상태에서 `innodb_buffer_pool_size` 값(원래 의도한 `64M`)을 `/tmp/bp.txt` 에 저장하세요. (값만)\n\n(서버는 `nohup mariadbd ... &` 처럼 백그라운드로 띄웁니다. 접속은 `mariadb -S /tmp/lab/mysql.sock` 입니다.)',
     '에러 로그는 줄마다 `[Note]`, `[Warning]`, `[ERROR]` 단계가 붙습니다. 급한 것은 `[ERROR]` 줄입니다. `grep` 으로 그 줄만 먼저 보세요.',
     "grep ERROR /tmp/lab/error.log\nsed -i 's/innodb_buffer_pool_sizee/innodb_buffer_pool_size/' /tmp/lab/my.cnf\nnohup mariadbd --defaults-file=/tmp/lab/my.cnf >/dev/null 2>&1 &\nfor i in $(seq 1 60); do mariadb -S /tmp/lab/mysql.sock -e 'select 1' >/dev/null 2>&1 && break; sleep 0.5; done\nmariadb -S /tmp/lab/mysql.sock -N -e 'SELECT @@innodb_buffer_pool_size' > /tmp/bp.txt\ncat /tmp/bp.txt\n\n# [ERROR] unknown variable 줄이 원인(변수 이름 오타). 설정을 고친 뒤 다시 띄우고 'ready for connections' 로 확인한다",
     LABBAD,
     [chk('설정 파일에서 오타가 사라졌다', '! grep -q "sizee" /tmp/lab/my.cnf'),
      chk('서버에 접속된다', '[ "$(mariadb -S /tmp/lab/mysql.sock -N -e \'SELECT 1\')" = 1 ]'),
      chk('에러 로그에 기동 완료가 남았다', 'grep -q "ready for connections" /tmp/lab/error.log'),
      chk('저장한 값이 64M 다', '[ "$(cat /tmp/bp.txt)" = 67108864 ]')])
# 7 -------------------------------------------------------------
b.nt('디스크가 찬다: 용량 먹는 곳 찾기', '서버의 데이터 디렉터리(`/var/lib/mysql`) 디스크가 가득 차 가고 있습니다. 먼저 **무엇이 용량을 쓰는지** 찾아야 합니다. `/var/lib/mysql` 아래에는 데이터베이스마다 디렉터리가 있습니다.\n\n아래 두 가지를 파일에 저장하세요. (이름만)\n- `/tmp/big_db.txt` : 디렉터리 용량이 가장 큰 **데이터베이스 이름**\n- `/tmp/big_file.txt` : 그 데이터베이스 디렉터리 안에서 **가장 큰 파일 이름**',
     '`du -sk 경로/*/` 는 디렉터리별 합계를 킬로바이트로 보여 줍니다. `sort -n` 으로 정렬하고, 파일은 `ls -S`(큰 순서 정렬)가 편합니다.',
     "du -sk /var/lib/mysql/*/ | sort -n\ndu -sk /var/lib/mysql/*/ | sort -n | tail -1 | awk '{print $2}' | xargs basename > /tmp/big_db.txt\nls -S /var/lib/mysql/$(cat /tmp/big_db.txt) | head -1 > /tmp/big_file.txt\ncat /tmp/big_db.txt /tmp/big_file.txt\n\n# 어디가 큰지 모르면 du 로 위에서부터 좁혀 간다. InnoDB 는 테이블마다 .ibd 파일이 하나다",
     BIG13,
     [chk('가장 큰 DB 가 archive 다', '[ "$(cat /tmp/big_db.txt)" = archive ]'),
      chk('가장 큰 파일이 events_log.ibd 다', '[ "$(cat /tmp/big_file.txt)" = events_log.ibd ]')])
# 8 -------------------------------------------------------------
b.nt('binlog 가 쌓였다: PURGE 로 정리', '연습용 서버(소켓 `/tmp/lab/mysql.sock`, 파일 `/tmp/lab/binlog.*`)의 이진 로그(binlog)가 다섯 개 쌓였습니다. 보관 기간 설정이 없어 계속 쌓여 디스크를 채우는 중입니다. 다음 두 가지를 하세요.\n1. **가장 최근 binlog 두 개만 남기고** 나머지를 삭제 (서버가 알고 있는 방식으로)\n2. 재발 방지로 보관 기간을 **3일(259200초)** 로 설정 (서버 실행 중에 적용)\n\n(binlog 파일을 `rm` 으로 직접 지우면 서버의 목록(index)과 어긋나므로 쓰지 않습니다.)',
     '`SHOW BINARY LOGS;` 로 파일 목록을 먼저 보세요. 정리 명령은 `PURGE BINARY LOGS` 이고, 보관 기간 변수 이름은 `SHOW VARIABLES LIKE \'%expire%\';` 로 찾습니다. 접속은 `mariadb -S /tmp/lab/mysql.sock` 입니다.',
     "mariadb -S /tmp/lab/mysql.sock -e 'SHOW BINARY LOGS'\nmariadb -S /tmp/lab/mysql.sock -e \"PURGE BINARY LOGS TO 'binlog.000004'\"\nmariadb -S /tmp/lab/mysql.sock -e 'SET GLOBAL binlog_expire_logs_seconds=259200'\nmariadb -S /tmp/lab/mysql.sock -e 'SHOW BINARY LOGS'\nls /tmp/lab\n\n# PURGE BINARY LOGS TO 'X' 는 X 보다 앞선 파일을 지운다(X 는 남는다). 복제나 복구가 아직 읽을 로그는 지우면 안 되니 확인 후에 한다",
     LABBINLOG,
     [chk('서버 목록에서 옛 binlog 가 없다', '[ "$(mariadb -S /tmp/lab/mysql.sock -N -e \'SHOW BINARY LOGS\' | cut -f1 | grep -cE \'binlog\\.00000[123]$\')" = 0 ]'),
      chk('디스크에서도 옛 파일이 없다', '! ls /tmp/lab/binlog.00000[123] 2>/dev/null | grep -q .'),
      chk('최근 두 개는 남아 있다', '[ -e /tmp/lab/binlog.000004 ] && [ -e /tmp/lab/binlog.000005 ]'),
      chk('보관 기간이 3일이다', '[ "$(mariadb -S /tmp/lab/mysql.sock -N -e \'SELECT @@binlog_expire_logs_seconds\')" = 259200 ]')])
# 9 -------------------------------------------------------------
b.nt('오래된 행을 지웠는데 디스크가 안 줄어든다', '`archive` 데이터베이스의 `events_log` 테이블(20만 건, 파일 `/var/lib/mysql/archive/events_log.ibd` 약 56MB)이 디스크를 차지합니다. 오래된 로그(`id` 가 **180000 이하**)를 삭제하고, 운영에 필요한 최근 20000건은 남기세요.\n\n그런데 행을 지워도 `.ibd` 파일 크기는 그대로입니다. 지운 공간을 **운영체제에 돌려주어** 파일이 **20MB(20000000바이트) 미만**이 되게 하세요. (`TRUNCATE`·`DROP` 으로 전부 지우면 안 됩니다.)',
     '`DELETE` 는 InnoDB 파일 안에 빈 공간만 만들 뿐 파일을 줄이지 않습니다. 테이블을 다시 만들어 공간을 돌려주는 명령을 찾으세요. 크기는 `ls -l` 로 확인합니다.',
     "mariadb -e 'DELETE FROM archive.events_log WHERE id <= 180000'\nls -l /var/lib/mysql/archive/events_log.ibd\nmariadb -e 'OPTIMIZE TABLE archive.events_log'\nls -l /var/lib/mysql/archive/events_log.ibd\n\n# DELETE 후에는 파일 크기가 그대로. OPTIMIZE TABLE(테이블 재구성)로 빈 공간을 돌려받는다. 재구성 중에는 임시로 디스크를 더 쓰니 여유 공간이 있을 때 한다",
     BIG13,
     [chk('남은 행이 20000건이다', '[ "$(mariadb -N -e \'SELECT COUNT(*) FROM archive.events_log\')" = 20000 ]'),
      chk('가장 오래된 행이 180001 이다', '[ "$(mariadb -N -e \'SELECT MIN(id) FROM archive.events_log\')" = 180001 ]'),
      chk('파일이 20MB 미만이다', '[ "$(stat -c %s /var/lib/mysql/archive/events_log.ibd)" -lt 20000000 ]')])
# 10 객관식 ------------------------------------------------------
b.choice('Errcode: 28 은 무슨 뜻일까', '큰 `GROUP BY` 쿼리를 돌리다가 아래 오류가 났습니다.\n\n`ERROR 3 (HY000): Error writing file \'/tmp/MYabc123\' (Errcode: 28 "No space left on device")`\n\n가장 알맞은 해석은 무엇인가요?', '오류 번호가 아니라 메시지 속 파일 경로와 `No space left` 에 주목하세요.',
         ['쿼리가 정렬·집계에 쓰는 임시 파일을 만들 디스크(tmpdir) 공간이 부족하다', '접속 계정의 비밀번호가 틀렸다', '다른 세션이 행을 잠가서 기다리다 시간이 초과됐다', '`max_connections` 한도에 도달했다'], 0,
         'Errcode 28 은 운영체제 오류 번호로 "디바이스에 남은 공간이 없다"는 뜻입니다. 큰 정렬·집계는 메모리에 다 못 담으면 tmpdir(기본 /tmp)에 임시 파일을 쓰는데 그 디스크가 가득 찼습니다. tmpdir 디스크 정리·확장과 쿼리 자체를 줄이는 방법을 점검합니다. 비밀번호 오류는 1045, 락 대기는 1205, 접속 한도는 1040 입니다.')
# 11 빈칸 --------------------------------------------------------
b.fill('느린 쿼리 로그: 읽은 행 수', '느린 쿼리 로그의 한 항목입니다. 쿼리가 **결과를 만들려고 실제로 읽어 본 행 수**를 나타내는 필드 이름을 채우세요.', '결과로 돌려준 행 수(`Rows_sent`)와 달리, 걸러내기 전에 훑은 행 수입니다.',
       '# Query_time: 4.210  Lock_time: 0.000  Rows_sent: 12  {0}: 300000', ['Rows_examined', 'Rows_sent', 'Lock_time', 'Thread_id'], [0],
       '`Rows_examined` 는 서버가 읽어 본 행 수입니다. 돌려준 행(`Rows_sent`)은 12 인데 읽은 행이 30만이라면 인덱스 없이 전체를 훑었다는 강한 신호입니다. `Query_time` 은 총 실행 시간, `Lock_time` 은 락을 기다린 시간입니다.')
# 12 순서 --------------------------------------------------------
b.order('느린 쿼리 폭주 대응 순서', '서비스가 갑자기 느려졌고 한 쿼리가 서버를 붙잡고 있는 것으로 보입니다. 올바른 대응 순서로 카드를 놓으세요. (서비스 영향을 먼저 줄이고, 원인 분석과 영구 수리는 그다음입니다.)', '지금 일어나는 일 파악, 급한 불 끄기, 원인 분석, 수리, 효과 확인 중 어느 것이 앞서야 하는지 생각해 보세요.',
        ['EXPLAIN 으로 인덱스를 못 타는 원인 확인', '인덱스를 추가해 쿼리를 고침', '고친 뒤 EXPLAIN 으로 개선 확인', 'PROCESSLIST 로 폭주한 세션 확인', 'KILL QUERY 로 폭주한 쿼리 중단'], [3, 4, 0, 1, 2],
        '먼저 PROCESSLIST 로 무슨 일이 벌어지는지 보고, 서비스를 되살리기 위해 폭주한 쿼리부터 KILL QUERY 로 멈춥니다. 그다음 EXPLAIN 으로 원인(전체 훑기)을 분석하고 인덱스로 고친 뒤, 다시 EXPLAIN 으로 개선을 확인합니다. 쿼리를 멈추지 않고 분석부터 하면 그동안 서비스가 계속 느립니다.')

if __name__ == '__main__':
    preview(b)
