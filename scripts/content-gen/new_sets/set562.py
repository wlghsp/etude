import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 562: 복제 직접 구성하고 고장 내 보기 (한 컨테이너에 mariadbd 두 개: primary 3307 / replica 3308). 명세: docs/specs/spec_gap_set562.md
# 선행: 59·91·414(복제 개념·상태 읽기). 로컬에서 실제 복제·1062 중단·skip 동작을 확인했다. 메모리 때문에 기본 서버(3306)는 띄우지 않는다.

P = "mariadb -S /tmp/r1/mysql.sock"
R = "mariadb -S /tmp/r2/mysql.sock"
DOWN62 = ("for n in 1 2; do mariadb-admin -S /tmp/r$n/mysql.sock shutdown >/dev/null 2>&1; done; "
          "for i in $(seq 1 40); do [ -S /tmp/r1/mysql.sock ] || [ -S /tmp/r2/mysql.sock ] || break; sleep 0.5; done; pkill mysqld_safe >/dev/null 2>&1; rm -rf /tmp/r1 /tmp/r2 /tmp/*.txt")
UP62 = ("for n in 1 2; do d=/tmp/r$n; mkdir -p $d; chown mysql:mysql $d; mariadb-install-db --user=mysql --datadir=$d/data --auth-root-authentication-method=normal --skip-test-db >/dev/null 2>&1; "
        "printf \"[mysqld]\\ndatadir=$d/data\\nsocket=$d/mysql.sock\\npid-file=$d/mysql.pid\\nport=330$((6+n))\\nbind-address=127.0.0.1\\nserver-id=$n\\nlog-bin=$d/binlog\\nrelay-log=$d/relay\\nlog-error=$d/error.log\\nuser=mysql\\ninnodb_buffer_pool_size=16M\\ninnodb_log_file_size=8M\\nperformance_schema=OFF\\n\" > $d/my.cnf; "
        "chown mysql:mysql $d/my.cnf; nohup mariadbd --defaults-file=$d/my.cnf >/dev/null 2>&1 & done; "
        "for n in 1 2; do for i in $(seq 1 60); do mariadb -S /tmp/r$n/mysql.sock -e 'select 1' >/dev/null 2>&1 && break; sleep 0.5; done; done")
# primary 에는 shop.t(행 1)와 복제 계정이 있고, replica 는 비어 있다
BASE62 = (DOWN62 + "; " + UP62 + "; " + P + " -e \"CREATE DATABASE shop; CREATE TABLE shop.t (id INT PRIMARY KEY, v VARCHAR(20)); INSERT INTO shop.t VALUES (1,'a'); CREATE USER 'repl'@'127.0.0.1' IDENTIFIED BY 'replpw'; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'127.0.0.1'\"")
CHG = lambda pw: R + f" -e \"CHANGE MASTER TO MASTER_HOST='127.0.0.1', MASTER_PORT=3307, MASTER_USER='repl', MASTER_PASSWORD='{pw}', MASTER_LOG_FILE='binlog.000001', MASTER_LOG_POS=4; START SLAVE\""
WAITSYNC = "for i in $(seq 1 40); do [ \"$(" + R + " -N -e 'SELECT COUNT(*) FROM shop.t' 2>/dev/null)\" = 1 ] && break; sleep 0.5; done"
CONF62 = BASE62 + "; " + CHG('replpw') + "; " + WAITSYNC
# 복제 중이던 replica 에 누군가 직접 id 3 을 넣었고, primary 에도 id 3 이 들어와 SQL 스레드가 멈춘 상황
FAIL62 = (CONF62 + "; " + R + " -e \"INSERT INTO shop.t VALUES (3,'r')\"; " + P + " -e \"INSERT INTO shop.t VALUES (3,'p')\"; "
          "for i in $(seq 1 40); do [ \"$(" + R + " -N -e 'SHOW SLAVE STATUS\\G' | grep -c 'Last_SQL_Errno: 1062')\" = 1 ] && break; sleep 0.5; done")
# 복제 계정 비밀번호가 틀리게 설정된 replica
BADPW62 = BASE62 + "; " + CHG('wrongpw') + "; sleep 3"
SS = lambda f: R + f" -e 'SHOW SLAVE STATUS\\G' | grep -E '^ *{f}:' | sed 's/.*: //'"

b = SetBuilder(562, '복제 직접 구성하고 고장 내 보기: CHANGE MASTER·SHOW SLAVE STATUS·1062 중단',
               '한 컨테이너 안에 MariaDB 서버 두 개(primary 3307, replica 3308)를 띄워 실제 복제를 다뤄 봅니다. primary 의 binlog 위치 읽기, 복제 계정으로 CHANGE MASTER TO 와 START SLAVE, 변경이 replica 로 따라오는 것 확인, replica 에 따로 들어간 행 때문에 SQL 스레드가 1062 로 멈추는 상황 읽기, skip 하지 않고 원인을 없애 복구하기, 복제 계정 비밀번호가 틀렸을 때의 IO 스레드 오류를 직접 해 봅니다.',
               'linux-db', '데이터베이스', 20, 822, '🔁',
               [{"title": "MariaDB 복제 설정", "url": "https://mariadb.com/kb/en/setting-up-replication/"}, {"title": "SHOW REPLICA STATUS", "url": "https://mariadb.com/kb/en/show-replica-status/"}], 1)

# 1
b.nt('primary 의 binlog 위치 읽기', '복제는 primary 의 **binlog(변경 기록)** 를 replica 가 읽어 따라 하는 방식입니다. 지금 서버 두 개가 떠 있습니다.\n- primary: 소켓 `/tmp/r1/mysql.sock` (포트 3307)\n- replica: 소켓 `/tmp/r2/mysql.sock` (포트 3308)\n\n접속은 `mariadb -S 소켓경로` 입니다. primary 의 **현재 binlog 파일 이름**을 `/tmp/file.txt`, **현재 위치(Position)** 를 `/tmp/pos.txt` 에 저장하세요. (값만)',
     '`SHOW MASTER STATUS;` 의 출력은 `File`, `Position` 열이 있습니다. `-N` 과 `cut -f` 로 열을 뽑으세요.',
     P + " -e 'SHOW MASTER STATUS'\n" + P + " -N -e 'SHOW MASTER STATUS' | cut -f1 > /tmp/file.txt\n" + P + " -N -e 'SHOW MASTER STATUS' | cut -f2 > /tmp/pos.txt\ncat /tmp/file.txt /tmp/pos.txt\n\n# replica 는 '어느 파일의 어느 위치부터' 읽을지 이 값으로 알려 받는다. 방금 만든 서버라 binlog.000001 이다",
     BASE62, [chk('파일 이름이 맞다', '[ "$(cat /tmp/file.txt)" = "$(' + P + " -N -e 'SHOW MASTER STATUS' | cut -f1)\" ]"), chk('위치가 맞다', '[ "$(cat /tmp/pos.txt)" = "$(' + P + " -N -e 'SHOW MASTER STATUS' | cut -f2)\" ] && [ \"$(cat /tmp/pos.txt)\" -gt 4 ]")])
# 2
b.nt('replica 를 primary 에 연결하기', 'replica(`/tmp/r2/mysql.sock`)가 primary 를 따라가게 설정하세요. primary 는 방금 만든 서버라 `binlog.000001` 의 처음(위치 `4`)부터 읽으면 모든 변경을 받습니다. primary 에는 복제 전용 계정이 이미 만들어져 있습니다.\n- 접속 주소: `127.0.0.1`, 포트 `3307`\n- 계정: `repl` / 비밀번호 `replpw`\n\nreplica 에서 연결 정보를 지정하고 복제를 시작한 뒤, replica 에 `shop.t` 의 데이터가 따라와야 합니다.',
     'replica 에서 `CHANGE MASTER TO MASTER_HOST=..., MASTER_PORT=..., MASTER_USER=..., MASTER_PASSWORD=..., MASTER_LOG_FILE=..., MASTER_LOG_POS=...;` 다음 `START SLAVE;` 입니다. 확인은 `SHOW SLAVE STATUS\\G`.',
     R + " -e \"CHANGE MASTER TO MASTER_HOST='127.0.0.1', MASTER_PORT=3307, MASTER_USER='repl', MASTER_PASSWORD='replpw', MASTER_LOG_FILE='binlog.000001', MASTER_LOG_POS=4; START SLAVE\"\nsleep 2\n" + R + " -e 'SHOW SLAVE STATUS\\G' | grep -E 'Running|Behind'\n" + R + " -e 'SELECT * FROM shop.t'\n\n# Slave_IO_Running(binlog 받는 스레드)과 Slave_SQL_Running(적용하는 스레드)이 모두 Yes 여야 정상이다",
     BASE62, [chk('IO 스레드가 Yes 다', '[ "$(' + SS('Slave_IO_Running') + ')" = Yes ]'), chk('SQL 스레드가 Yes 다', '[ "$(' + SS('Slave_SQL_Running') + ')" = Yes ]'), chk('replica 에 데이터가 따라왔다', '[ "$(' + R + " -N -e 'SELECT v FROM shop.t WHERE id=1')\" = a ]")])
# 3
b.nt('primary 의 변경이 replica 로 따라온다', '복제가 연결된 상태입니다. **primary** 의 `shop.t` 에 `(2, \'b\')` 를 INSERT 하고, 잠시 뒤 **replica** 에서 `id=2` 행의 `v` 값을 읽어 `/tmp/rep.txt` 에 저장하세요. (값만)',
     '쓰기는 primary 소켓, 읽기는 replica 소켓입니다. 복제는 거의 즉시 따라오지만 읽기 전에 1~2초 기다려도 됩니다.',
     P + " -e \"INSERT INTO shop.t VALUES (2,'b')\"\nsleep 1\n" + R + " -N -e 'SELECT v FROM shop.t WHERE id=2' > /tmp/rep.txt\ncat /tmp/rep.txt\n\n# replica 에는 직접 쓰지 않고 primary 에만 쓴다. 읽기 분산용으로 replica 를 쓴다",
     CONF62, [chk('replica 에서 b 를 읽었다', '[ "$(cat /tmp/rep.txt)" = b ]'), chk('primary 에도 행이 있다', '[ "$(' + P + " -N -e 'SELECT COUNT(*) FROM shop.t WHERE id=2')\" = 1 ]")])
# 4
b.nt('복제가 멈췄다: 오류 읽기', '복제 중이던 replica 의 SQL 스레드가 멈췄다는 알림이 왔습니다. replica(`/tmp/r2/mysql.sock`)의 `SHOW SLAVE STATUS\\G` 를 보고 아래를 저장하세요. (값만)\n- `/tmp/sql.txt` : `Slave_SQL_Running` 값\n- `/tmp/errno.txt` : `Last_SQL_Errno` (마지막 SQL 오류 번호)',
     '`SHOW SLAVE STATUS\\G` 출력에서 `grep` 으로 해당 줄만 고르고 `sed \'s/.*: //\'` 로 값만 남길 수 있습니다. 오류 번호가 무엇을 뜻하는지는 `Last_SQL_Error` 줄에 풀이가 있습니다.',
     R + " -e 'SHOW SLAVE STATUS\\G' | grep -E 'Last_SQL_Err|Slave_SQL_Running'\n" + SS('Slave_SQL_Running') + " > /tmp/sql.txt\n" + SS('Last_SQL_Errno') + " > /tmp/errno.txt\ncat /tmp/sql.txt /tmp/errno.txt\n\n# SQL_Running=No, 오류 1062(Duplicate entry): primary 의 INSERT 를 적용하려는데 replica 에 같은 키가 이미 있다",
     FAIL62, [chk('SQL 스레드가 멈춰 있다', '[ "$(cat /tmp/sql.txt)" = No ]'), chk('오류 번호가 1062 다', '[ "$(cat /tmp/errno.txt)" = 1062 ]')])
# 5
b.nt('skip 하지 않고 원인을 없애 복구하기', '앞 문제의 원인은 누군가 replica 에 `(3, \'r\')` 를 **직접 넣어** 두어서, primary 의 `(3, \'p\')` INSERT 가 중복으로 실패한 것입니다. 오류를 건너뛰는(skip) 방법도 있지만, 그러면 replica 의 `id=3` 이 primary 와 **다른 값(`r`)** 으로 남습니다.\n\nreplica 에서 **원인이 된 행을 정리**해 멈춘 이벤트가 정상 적용되도록 하고 복제를 다시 시작하세요. 끝나면 replica 의 `id=3` 값이 primary 와 같은 `p` 이고 두 스레드가 모두 `Yes` 여야 합니다.',
     '멈춘 이벤트가 왜 실패했는지, replica 쪽에서 무엇이 걸림돌인지 보세요. 걸림돌을 없앤 뒤 멈춘 스레드를 다시 돌리면 같은 이벤트를 다시 적용합니다.',
     R + " -e 'DELETE FROM shop.t WHERE id=3'\n" + R + " -e 'START SLAVE'\nsleep 2\n" + R + " -e 'SELECT * FROM shop.t'\n" + R + " -e 'SHOW SLAVE STATUS\\G' | grep -E 'Running'\n\n# 충돌 행을 지우고 재시작하면 멈춘 INSERT (3,'p') 가 다시 적용되어 두 서버가 같아진다. sql_slave_skip_counter 로 건너뛰면 둘이 영영 달라질 수 있다",
     FAIL62, [chk('SQL 스레드가 Yes 다', '[ "$(' + SS('Slave_SQL_Running') + ')" = Yes ]'), chk('replica 의 id=3 이 p 다', '[ "$(' + R + " -N -e 'SELECT v FROM shop.t WHERE id=3')\" = p ]"), chk('두 서버의 행 수가 같다', '[ "$(' + R + " -N -e 'SELECT COUNT(*) FROM shop.t')\" = \"$(" + P + " -N -e 'SELECT COUNT(*) FROM shop.t')\" ]")])
# 6
b.nt('연결 자체가 안 된다: IO 스레드 오류', '이번에는 replica 의 **IO 스레드**(primary 에서 binlog 를 받아 오는 쪽)가 `Yes` 가 아닙니다. `SHOW SLAVE STATUS\\G` 의 `Last_IO_Errno` (IO 스레드의 마지막 오류 번호)를 `/tmp/io.txt` 에 저장하세요. 그런 다음 원인을 고쳐서(복제 계정 `repl` 의 올바른 비밀번호는 `replpw`) 두 스레드가 모두 `Yes` 가 되게 하세요.',
     '오류 번호는 `Last_IO_Errno` 줄에 있습니다. 연결 정보 중 틀린 항목만 바꿀 수 있고, 바꾸기 전에 스레드를 멈춰야 합니다.',
     SS('Last_IO_Errno') + " > /tmp/io.txt\ncat /tmp/io.txt\n" + R + " -e \"STOP SLAVE; CHANGE MASTER TO MASTER_PASSWORD='replpw'; START SLAVE\"\nsleep 2\n" + R + " -e 'SHOW SLAVE STATUS\\G' | grep -E 'Running'\n\n# 1045(Access denied): 계정·비밀번호 문제. 계정이 맞는지(primary 에서 SHOW GRANTS), 호스트 부분이 맞는지도 같이 본다",
     BADPW62, [chk('IO 오류 번호가 1045 다', '[ "$(cat /tmp/io.txt)" = 1045 ]'), chk('IO 스레드가 Yes 다', '[ "$(' + SS('Slave_IO_Running') + ')" = Yes ]'), chk('SQL 스레드가 Yes 다', '[ "$(' + SS('Slave_SQL_Running') + ')" = Yes ]'), chk('데이터가 따라왔다', '[ "$(' + R + " -N -e 'SELECT COUNT(*) FROM shop.t')\" = 1 ]")])
# 7
b.choice('Seconds_Behind_Master 가 NULL', 'replica 에서 `SHOW SLAVE STATUS` 를 봤더니 `Seconds_Behind_Master: NULL` 입니다. 가장 알맞은 해석은?', '0 과 NULL 이 각각 무엇을 뜻하는지 비교해 보세요.',
         ['복제가 멈춰 있어 측정할 수 없다', '지연이 전혀 없다', '지연이 너무 커서 표시를 못 한다', 'replica 가 primary 보다 앞서 있다'], 0,
         'Seconds_Behind_Master 는 복제가 돌아가는 동안의 지연(초)이고, 스레드가 멈추면 계산할 수 없어 NULL 입니다. 0 이 지연 없음입니다. NULL 을 정상으로 오해하지 않도록, 항상 Slave_IO_Running·Slave_SQL_Running 과 Last_*_Error 를 함께 봅니다.')
# 8
b.choice('sql_slave_skip_counter 의 위험', '복제가 1062 로 멈췄을 때 `SET GLOBAL sql_slave_skip_counter=1;` 로 오류가 난 이벤트를 건너뛰고 재개하는 방법이 있습니다. 이 방법의 가장 큰 위험은?', '건너뛴 이벤트가 하던 일이 어디에 남는지 생각해 보세요.',
         ['건너뛴 변경이 반영되지 않아 두 서버가 조용히 달라질 수 있다', 'primary 의 binlog 가 삭제되어 복구가 불가능해진다', 'replica 가 자동으로 primary 로 승격되어 쓰기가 갈라진다', '복제 계정의 비밀번호가 초기화되어 연결이 끊긴다'], 0,
         'skip 은 문제의 이벤트를 적용하지 않고 넘어가므로 replica 와 primary 의 데이터가 어긋난 채 복제는 정상처럼 보입니다. 가능하면 원인(replica 에 직접 쓴 행 등)을 찾아 없애고, 정말 건너뛰어야 한다면 영향 범위를 확인한 뒤 나중에 데이터를 맞춥니다.')
# 9
b.fill('복제 상태를 보는 명령', 'replica 에서 IO·SQL 스레드 상태와 마지막 오류를 한눈에 보는 명령의 빈칸을 채우세요.', 'primary 쪽 binlog 위치를 보는 `SHOW MASTER STATUS` 의 짝이 되는 명령입니다.',
       'SHOW {0} STATUS\\G', ['SLAVE', 'PROCESSLIST', 'VARIABLES', 'WARNINGS'], [0],
       '`SHOW SLAVE STATUS`(10.5 부터 `SHOW REPLICA STATUS` 도 같은 뜻)가 replica 의 복제 상태를 보여 줍니다. 나머지는 `STATUS` 와 함께 쓰는 문장이 아닙니다.')
# 10
b.order('replica 를 새로 붙이는 순서', 'primary 와 replica 를 새로 연결하는 순서입니다. 연결 직전에 binlog 위치를 확인해야 하고, 상태 확인은 시작한 뒤에 합니다. 올바른 순서로 놓으세요.', '연결하려면 무엇이 미리 준비돼 있어야 하는지 생각해 보세요.',
        ['replica 에서 START SLAVE 로 복제 시작', 'primary 에 복제 전용 계정을 만들고 REPLICATION SLAVE 권한 부여', 'replica 에서 SHOW SLAVE STATUS 로 두 스레드가 Yes 인지 확인', 'replica 에서 CHANGE MASTER TO 로 주소·계정·binlog 위치 지정', 'primary 에서 SHOW MASTER STATUS 로 binlog 파일과 위치 확인'], [1, 4, 3, 0, 2],
        '먼저 primary 에 복제 계정을 만들고 현재 binlog 위치를 확인합니다. replica 에서 CHANGE MASTER TO 로 연결 정보를 넣고 START SLAVE 로 시작한 뒤, SHOW SLAVE STATUS 로 IO·SQL 스레드가 모두 Yes 인지 확인합니다.')

if __name__ == '__main__':
    preview(b)
