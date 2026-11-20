import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 557: 격리 수준 4종 직접 재현. 명세: docs/specs/spec_gap_set557.md
# 선행: 502(트랜잭션·락 기초: 두 번째 세션을 백그라운드로 띄우는 방식). MariaDB 10.6 은 변수 이름이 tx_isolation 이다(transaction_isolation 은 11.1 부터).

RESET57 = ("for id in $(mariadb -N -e \"SELECT id FROM information_schema.processlist WHERE id<>CONNECTION_ID()\"); do mariadb -e \"KILL $id\" >/dev/null 2>&1; done; "
           "mariadb -e \"SET GLOBAL tx_isolation='REPEATABLE-READ'\"")
ISO = (DBUP + "; " + RESET57 + """; mariadb -e 'DROP DATABASE IF EXISTS bank; CREATE DATABASE bank; USE bank; CREATE TABLE accounts (id INT PRIMARY KEY, owner VARCHAR(20), balance INT) ENGINE=InnoDB; INSERT INTO accounts VALUES (1,"kim",1000),(2,"lee",500);'; """ + CLEAN)
BAL = "mariadb -N bank -e 'SELECT balance FROM accounts WHERE id=1'"
# 파일에서 SLEEP 결과(0)를 뺀 값들을 한 줄로
VALS = lambda f: f"$(grep -v '^0$' {f} | tr '\\n' ' ')"

b = SetBuilder(557, '격리 수준 4종 직접 재현: READ UNCOMMITTED·READ COMMITTED·REPEATABLE READ·SERIALIZABLE',
               '같은 데이터를 두 세션이 동시에 만질 때 격리 수준에 따라 무엇이 보이는지 직접 만들어 봅니다. 기본 격리 수준 확인, READ COMMITTED 와 REPEATABLE READ 에서 같은 행을 두 번 읽기, READ UNCOMMITTED 의 더티 리드, 스냅샷 읽기와 현재 읽기(FOR UPDATE)의 차이, SERIALIZABLE 의 락 대기, 서버 기본값 바꾸기를 두 세션 실습으로 익힙니다.',
               'linux-db', '데이터베이스', 20, 817, '🧪',
               [{"title": "SET TRANSACTION", "url": "https://mariadb.com/kb/en/set-transaction/"}, {"title": "InnoDB 격리 수준", "url": "https://mariadb.com/kb/en/innodb-lock-modes/"}], 5)

# 1
b.nt('기본 격리 수준 확인하기', '`bank` 를 쓰는 서버의 **격리 수준(isolation level)** 은 트랜잭션끼리 서로의 변경이 어디까지 보이게 할지를 정하는 설정입니다. MariaDB 10.6 에서 이 값은 `tx_isolation` 변수에 들어 있습니다.\n\n지금 서버의 **전역(GLOBAL) 기본 격리 수준** 값을 `/tmp/iso.txt` 에 저장하세요. (값만)',
     '`SELECT @@global.변수이름;` 을 `mariadb -N -e` 로 실행해 `>` 로 저장합니다. 변수 이름은 `SHOW VARIABLES LIKE \'%isolation%\';` 로 찾을 수 있습니다.',
     "mariadb -N -e 'SELECT @@global.tx_isolation' > /tmp/iso.txt\ncat /tmp/iso.txt\n\n# InnoDB 의 기본값은 REPEATABLE-READ. 세션마다 바꿀 수 있다",
     ISO, [chk('파일이 있다', '[ -s /tmp/iso.txt ]'), chk('값이 REPEATABLE-READ 다', '[ "$(cat /tmp/iso.txt)" = REPEATABLE-READ ]')])
# 2
b.nt('READ COMMITTED: 같은 행을 두 번 읽으면 값이 바뀐다', '**첫 번째 세션**을 백그라운드로 띄워 `kim`(id 1) 의 잔액을 읽고, 12초 쉬었다가 다시 읽습니다. 쉬는 동안 **두 번째 세션**에서 `kim` 의 잔액을 **1500 으로 바꾸고 커밋**하세요. 첫 세션은 `READ COMMITTED` 수준입니다.\n\n`mariadb -N bank -e "SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION; SELECT balance FROM accounts WHERE id=1; SELECT SLEEP(12); SELECT balance FROM accounts WHERE id=1; COMMIT" > /tmp/rc.txt &`\n\n첫 세션이 끝나면(약 12초 뒤) `/tmp/rc.txt` 에 두 값이 들어 있어야 합니다. 두 번째 세션 명령은 첫 명령을 띄운 직후에 이어서 실행하세요. (끝나기를 기다리려면 `wait`)',
     '두 번째 세션은 평소처럼 `UPDATE` 한 문장이면 됩니다. autocommit 이 켜져 있어 그 문장이 끝나는 순간 커밋됩니다. 첫 세션이 쉬는 12초 안에 실행해야 합니다.',
     "mariadb -N bank -e 'SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION; SELECT balance FROM accounts WHERE id=1; SELECT SLEEP(12); SELECT balance FROM accounts WHERE id=1; COMMIT' > /tmp/rc.txt &\nsleep 1\nmariadb bank -e 'UPDATE accounts SET balance=1500 WHERE id=1'\nwait\ncat /tmp/rc.txt\n\n# READ COMMITTED 는 읽을 때마다 '그 순간 커밋된 최신 값'을 본다. 한 트랜잭션 안에서 1000 → 1500 으로 달라지는 현상이 반복 불가능 읽기(non-repeatable read)",
     ISO, [chk('첫 세션이 1000 과 1500 을 차례로 읽었다', f'[ "{VALS("/tmp/rc.txt")}" = "1000 1500 " ]'), chk('kim 잔액이 1500 으로 커밋됐다', f'[ "$({BAL})" = 1500 ]')])
# 3
b.nt('REPEATABLE READ: 같은 행을 두 번 읽어도 같은 값', '이번에는 **격리 수준을 바꾸지 않고**(기본 REPEATABLE READ) 같은 실험을 합니다. 첫 세션을 백그라운드로 띄우고, 쉬는 동안 두 번째 세션에서 `kim` 의 잔액을 **1500 으로 바꾸고 커밋**하세요.\n\n`mariadb -N bank -e "START TRANSACTION; SELECT balance FROM accounts WHERE id=1; SELECT SLEEP(12); SELECT balance FROM accounts WHERE id=1; COMMIT" > /tmp/rr.txt &`\n\n끝난 뒤 `/tmp/rr.txt` 의 두 값을 비교해 보세요. (기다리려면 `wait`)',
     '앞 문제와 같은 흐름입니다. 다른 점은 첫 세션에 `SET SESSION ...` 이 없다는 것뿐입니다. 결과 파일의 두 값이 같게 나오는지 봅니다.',
     "mariadb -N bank -e 'START TRANSACTION; SELECT balance FROM accounts WHERE id=1; SELECT SLEEP(12); SELECT balance FROM accounts WHERE id=1; COMMIT' > /tmp/rr.txt &\nsleep 1\nmariadb bank -e 'UPDATE accounts SET balance=1500 WHERE id=1'\nwait\ncat /tmp/rr.txt\n\n# REPEATABLE READ 는 트랜잭션의 첫 읽기 시점의 스냅샷을 끝까지 보여 준다(1000, 1000). 그 사이 다른 세션이 커밋해도 이 트랜잭션에는 안 보인다",
     ISO, [chk('첫 세션이 1000 을 두 번 읽었다', f'[ "{VALS("/tmp/rr.txt")}" = "1000 1000 " ]'), chk('kim 잔액이 1500 으로 커밋됐다', f'[ "$({BAL})" = 1500 ]')])
# 4
b.nt('READ UNCOMMITTED: 커밋 전 변경이 보인다', '**첫 세션**은 `kim` 의 잔액을 999 로 바꾸고 커밋하지 않은 채 20초 쉰 뒤 ROLLBACK 합니다.\n\n`mariadb bank -e "START TRANSACTION; UPDATE accounts SET balance=999 WHERE id=1; SELECT SLEEP(20); ROLLBACK" >/dev/null &`\n\n첫 세션이 쉬는 동안 **두 번째 세션**에서 다음 두 가지를 하세요.\n1. 격리 수준을 `READ UNCOMMITTED` 로 하고 `kim` 의 잔액을 읽어 `/tmp/dirty.txt` 에 저장\n2. 기본 격리 수준으로 `kim` 의 잔액을 읽어 `/tmp/clean.txt` 에 저장\n\n(값만 저장하려면 `-N`. 끝나기를 기다리려면 `wait`)',
     '격리 수준은 `SET SESSION TRANSACTION ISOLATION LEVEL ...;` 를 같은 `mariadb -e` 안에서 `SELECT` 앞에 적어 바꿉니다. 두 읽기는 모두 첫 세션이 쉬는 20초 안에 해야 합니다.',
     "mariadb bank -e 'START TRANSACTION; UPDATE accounts SET balance=999 WHERE id=1; SELECT SLEEP(20); ROLLBACK' >/dev/null &\nsleep 1\nmariadb -N bank -e 'SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; SELECT balance FROM accounts WHERE id=1' > /tmp/dirty.txt\nmariadb -N bank -e 'SELECT balance FROM accounts WHERE id=1' > /tmp/clean.txt\nwait\ncat /tmp/dirty.txt /tmp/clean.txt\n\n# 더티 리드: 롤백될 값(999)을 읽었다. READ UNCOMMITTED 는 커밋 전 변경까지 보여서 거의 쓰지 않는다",
     ISO, [chk('READ UNCOMMITTED 로 999 를 읽었다', '[ "$(cat /tmp/dirty.txt)" = 999 ]'), chk('기본 수준으로는 1000 을 읽었다', '[ "$(cat /tmp/clean.txt)" = 1000 ]'), chk('롤백되어 잔액이 1000 이다', f'[ "$({BAL})" = 1000 ]')])
# 5
b.nt('스냅샷 읽기와 현재 읽기(FOR UPDATE)', '`REPEATABLE READ` 트랜잭션에서 일반 `SELECT` 는 스냅샷을 보지만, `SELECT ... FOR UPDATE` 는 **지금 커밋된 최신 상태**를 읽습니다. 직접 확인합니다. 현재 `accounts` 에는 2행이 있습니다.\n\n첫 세션을 백그라운드로 띄우고, 쉬는 동안 두 번째 세션에서 `(3, \'park\', 300)` 행을 **INSERT** 하세요.\n\n`mariadb -N bank -e "START TRANSACTION; SELECT COUNT(*) FROM accounts; SELECT SLEEP(12); SELECT COUNT(*) FROM accounts; SELECT COUNT(*) FROM accounts FOR UPDATE; COMMIT" > /tmp/ph.txt &`\n\n끝난 뒤 `/tmp/ph.txt` 에는 세 개의 개수가 차례로 적힙니다. (기다리려면 `wait`)',
     '두 번째 세션은 `INSERT INTO accounts VALUES (3,\'park\',300)` 한 문장입니다. 결과 파일에서 같은 `COUNT(*)` 인데 마지막 값만 다른 이유를 생각해 보세요.',
     "mariadb -N bank -e 'START TRANSACTION; SELECT COUNT(*) FROM accounts; SELECT SLEEP(12); SELECT COUNT(*) FROM accounts; SELECT COUNT(*) FROM accounts FOR UPDATE; COMMIT' > /tmp/ph.txt &\nsleep 1\nmariadb bank -e \"INSERT INTO accounts VALUES (3,'park',300)\"\nwait\ncat /tmp/ph.txt\n\n# 결과 2, 2, 3. 일반 SELECT 는 스냅샷(2)이지만 FOR UPDATE 는 최신(3)을 읽는다. 이 차이를 모르면 '분명 안 보였는데 갱신은 된다' 같은 혼란이 생긴다",
     ISO, [chk('개수가 2, 2, 3 이다', f'[ "{VALS("/tmp/ph.txt")}" = "2 2 3 " ]'), chk('park 행이 들어 있다', '[ "$(mariadb -N bank -e "SELECT COUNT(*) FROM accounts WHERE id=3")" = 1 ]')])
# 6
b.nt('SERIALIZABLE: 읽기만 해도 쓰기가 막힌다', '`SERIALIZABLE` 수준에서는 일반 `SELECT` 도 읽은 행에 공유 락을 겁니다. 첫 세션이 `kim` 을 읽고 쉬는 동안, 두 번째 세션이 같은 행을 `UPDATE` 하면 기다리다 시간 초과가 납니다.\n\n`mariadb bank -e "SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; START TRANSACTION; SELECT balance FROM accounts WHERE id=1; SELECT SLEEP(8); COMMIT" >/dev/null &`\n\n첫 세션을 띄운 뒤, 두 번째 세션에서 `SET SESSION innodb_lock_wait_timeout=2;` 후 `kim` 의 잔액을 **1 로 UPDATE** 하고, 나온 **오류 메시지를 `/tmp/ser.txt`** 에 저장하세요. (기다리려면 `wait`)',
     '오류는 표준 에러로 나옵니다. `2> /tmp/ser.txt` 로 저장하세요. 대기 시간을 줄이는 SET 과 UPDATE 를 같은 `mariadb -e` 안에 적습니다.',
     "mariadb bank -e 'SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE; START TRANSACTION; SELECT balance FROM accounts WHERE id=1; SELECT SLEEP(8); COMMIT' >/dev/null &\nsleep 1\nmariadb bank -e 'SET SESSION innodb_lock_wait_timeout=2; UPDATE accounts SET balance=1 WHERE id=1' 2> /tmp/ser.txt\nwait\ncat /tmp/ser.txt\n\n# ERROR 1205 Lock wait timeout exceeded. SERIALIZABLE 은 읽기도 잠가서 안전하지만 동시성이 가장 낮다",
     ISO, [chk('오류 1205 가 기록됐다', 'grep -q "1205" /tmp/ser.txt'), chk('잔액이 바뀌지 않았다', f'[ "$({BAL})" = 1000 ]')])
# 7
b.nt('서버 기본 격리 수준을 READ COMMITTED 로', '서버 전체의 기본 격리 수준을 `READ COMMITTED` 로 바꿔, **새로 맺는 접속**이 별도 설정 없이 그 수준으로 시작하게 하세요. 서버를 재시작하지 않습니다. 바꾼 뒤 새 접속에서 값을 읽어 `/tmp/new.txt` 에 저장하세요. (값만)\n\n(`SET GLOBAL` 은 이미 열려 있는 세션에는 적용되지 않고, 재시작하면 사라집니다. 영구 설정은 설정 파일에 적습니다.)',
     '`SET GLOBAL 변수=값;` 입니다. 변수 이름은 1번 문제에서 쓴 것과 같고, 값 표기는 `SHOW VARIABLES` 로 보이는 형식을 따르세요.',
     "mariadb -e \"SET GLOBAL tx_isolation='READ-COMMITTED'\"\nmariadb -N -e 'SELECT @@tx_isolation' > /tmp/new.txt\ncat /tmp/new.txt\n\n# 새 접속부터 적용된다. 영구 적용은 my.cnf 의 [mysqld] 에 transaction-isolation=READ-COMMITTED",
     ISO, [chk('전역 값이 READ-COMMITTED 다', '[ "$(mariadb -N -e \'SELECT @@global.tx_isolation\')" = READ-COMMITTED ]'), chk('새 접속의 값이 READ-COMMITTED 다', '[ "$(cat /tmp/new.txt)" = READ-COMMITTED ]')])
# 8
b.choice('같은 행을 두 번 읽었더니 값이 달랐다', '한 트랜잭션 안에서 `SELECT balance FROM accounts WHERE id=1` 을 두 번 실행했더니, 그 사이 다른 세션이 커밋한 변경 때문에 값이 다르게 나왔습니다. 이 현상의 이름은 무엇인가요?', '커밋된 값을 읽었는지, 행의 개수가 달라졌는지, 같은 행의 값이 달라졌는지를 구분해 보세요.',
         ['반복 불가능 읽기', '더티 리드(커밋 전 변경을 읽음)', '팬텀 리드(행 개수가 달라짐)', '갱신 손실(두 쓰기 중 하나가 덮임)'], 0,
         '같은 행을 두 번 읽었는데 그 사이 **커밋된** 변경으로 값이 달라지는 것이 반복 불가능 읽기입니다. READ COMMITTED 에서 일어나고 REPEATABLE READ 부터는 막힙니다. 더티 리드는 **커밋되지 않은** 변경을 읽는 것, 팬텀은 같은 조건으로 읽었을 때 행의 개수(범위)가 달라지는 것입니다.')
# 9
b.choice('REPEATABLE READ 에서 값이 안 변하는 이유', 'InnoDB 의 REPEATABLE READ 트랜잭션은 다른 세션이 값을 커밋해도 같은 `SELECT` 결과가 계속 같게 나옵니다. 락을 걸어 막은 것이 아닌데, 이것은 어떻게 가능한가요?', '다른 세션의 UPDATE 가 기다리지 않고 바로 끝났던 것을 떠올려 보세요.',
         ['트랜잭션이 첫 읽기 때의 스냅샷(옛 버전)을 계속 읽는다', '읽은 모든 행에 배타 락을 걸어 다른 세션을 막는다', '서버가 SELECT 결과를 메모리에 저장해 두었다가 그대로 돌려준다', '다른 세션의 변경은 트랜잭션이 끝날 때까지 서버에 반영되지 않는다'], 0,
         'InnoDB 는 MVCC(다중 버전)로 행의 이전 버전을 보관하고, REPEATABLE READ 트랜잭션은 첫 일관된 읽기 때 만든 스냅샷을 끝까지 읽습니다. 그래서 다른 세션은 기다리지 않고 변경·커밋하지만, 이 트랜잭션에는 옛 버전이 보입니다. 읽기에 락을 거는 것은 SERIALIZABLE 이고, 다른 세션의 변경은 즉시 서버에 반영됩니다.')
# 10
b.fill('읽기도 잠그는 격리 수준', '네 가지 격리 수준 중, 일반 `SELECT` 도 읽은 행에 공유 락을 걸어 다른 세션의 쓰기를 기다리게 하는 수준을 채우세요.', '가장 엄격하고 동시성이 가장 낮은 수준입니다.',
       'SET SESSION TRANSACTION ISOLATION LEVEL {0};', ['READ UNCOMMITTED', 'READ COMMITTED', 'REPEATABLE READ', 'SERIALIZABLE'], [3],
       '`SERIALIZABLE` 은 autocommit 이 꺼진 트랜잭션 안의 일반 SELECT 를 `LOCK IN SHARE MODE` 처럼 취급합니다. 그래서 읽은 행을 다른 세션이 바꾸려 하면 기다립니다. 나머지 세 수준의 일반 SELECT 는 락 없이 읽습니다.')
# 11
b.order('두 번째 읽기에서 커밋된 값이 보이는지 실험하는 순서', 'READ COMMITTED 에서 "같은 행을 두 번 읽으면 값이 달라지는지"를 확인하는 실험입니다. 격리 수준은 **트랜잭션을 시작하기 전에** 정해 두어야 하고, 두 번째 읽기는 다른 세션이 커밋한 **뒤에** 합니다. 올바른 순서로 놓으세요.', '트랜잭션을 시작하기 전과 후에 각각 무엇이 정해져야 하는지 생각해 보세요.',
        ['첫 세션이 같은 SELECT 를 다시 실행해 값을 비교', '첫 세션이 START TRANSACTION 후 SELECT 로 첫 값을 읽음', '첫 세션이 COMMIT 으로 트랜잭션을 끝냄', '두 번째 세션이 UPDATE 를 실행해 커밋', '첫 세션이 격리 수준을 READ COMMITTED 로 설정'], [4, 1, 3, 0, 2],
        '격리 수준 설정은 다음 트랜잭션부터 적용되므로 START TRANSACTION 앞에 합니다. 그다음 첫 읽기, 다른 세션의 커밋, 두 번째 읽기, 비교 후 COMMIT 으로 끝냅니다. 두 번째 세션의 UPDATE 가 첫 읽기와 두 번째 읽기 사이에 있어야 값이 달라지는 것이 보입니다.')

if __name__ == '__main__':
    preview(b)
