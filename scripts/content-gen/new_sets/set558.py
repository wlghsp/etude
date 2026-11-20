import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 558: 락 종류 직접 만나기 (공유 락·갭 락·메타데이터 락). 명세: docs/specs/spec_gap_set558.md
# 선행: 502(FOR UPDATE·락 대기 시간 초과·KILL), 557(격리 수준). 데드락은 502 에서 다뤘으므로 여기서는 다루지 않는다.

RESET58 = ("for id in $(mariadb -N -e \"SELECT id FROM information_schema.processlist WHERE id<>CONNECTION_ID()\"); do mariadb -e \"KILL $id\" >/dev/null 2>&1; done; "
           "mariadb -e \"SET GLOBAL tx_isolation='REPEATABLE-READ'\"")
SLOTS = (DBUP + "; " + RESET58 + """; mariadb -e 'DROP DATABASE IF EXISTS shop; CREATE DATABASE shop; USE shop; CREATE TABLE slots (id INT PRIMARY KEY, label VARCHAR(20)) ENGINE=InnoDB; INSERT INTO slots VALUES (10,"a"),(20,"b"),(30,"c");'; """ + CLEAN)
# 열린 트랜잭션 하나(SELECT 만 하고 600초 쉼) 뒤에 ALTER 가 줄 서서 기다리는 상황
MDLWAIT = (SLOTS + "; nohup mariadb shop -e 'START TRANSACTION; SELECT * FROM slots; SELECT SLEEP(600)' >/dev/null 2>&1 & sleep 1; "
           "nohup mariadb shop -e 'ALTER TABLE slots ADD COLUMN note VARCHAR(10)' >/dev/null 2>&1 & sleep 2")
LABEL = "mariadb -N shop -e 'SELECT label FROM slots WHERE id=10'"
HAS = lambda i: f"[ \"$(mariadb -N shop -e 'SELECT COUNT(*) FROM slots WHERE id={i}')\" = 1 ]"

b = SetBuilder(558, '락 종류 직접 만나기: 공유 락·갭 락·메타데이터 락',
               'SELECT 만 했는데 왜 다른 세션이 막힐까요? 공유 락(LOCK IN SHARE MODE)이 읽기는 허용하고 쓰기는 막는 것, 갭 락이 빈 범위에 INSERT 를 막는 것과 READ COMMITTED 에서 사라지는 것, 열린 트랜잭션이 ALTER TABLE 을 막고 뒤따르는 SELECT 까지 줄 세우는 메타데이터 락을 두 세션 실습으로 확인하고, 막은 트랜잭션을 찾아 KILL 하는 방법을 익힙니다.',
               'linux-db', '데이터베이스', 20, 818, '🚧',
               [{"title": "InnoDB 락 모드", "url": "https://mariadb.com/kb/en/innodb-lock-modes/"}, {"title": "메타데이터 락", "url": "https://mariadb.com/kb/en/metadata-locking/"}], 2)

# 1
b.nt('공유 락: 읽기는 같이 해도 된다', '`shop.slots` 테이블에 행이 셋(id 10·20·30) 있습니다. **공유 락(shared lock)** 은 "나도 읽는 중이니 바꾸지 말라"는 표시라, 다른 세션이 같이 읽는 것은 허용합니다. 첫 세션이 `id=10` 행에 공유 락을 걸고 쉽니다.\n\n`mariadb shop -e "START TRANSACTION; SELECT * FROM slots WHERE id=10 LOCK IN SHARE MODE; SELECT SLEEP(8); ROLLBACK" >/dev/null &`\n\n첫 세션이 쉬는 동안 **두 번째 세션**에서 같은 행을 `LOCK IN SHARE MODE` 로 읽어, 그 행의 `label` 값을 `/tmp/share.txt` 에 저장하세요. (트랜잭션 안에서 읽어야 락이 걸립니다. 값만 저장하려면 `-N`)',
     '두 번째 세션도 `START TRANSACTION; SELECT label ... LOCK IN SHARE MODE; ROLLBACK;` 순서로 한 번의 `mariadb -e` 안에 적습니다. 기다리지 않고 바로 값이 나오면 성공입니다.',
     "mariadb shop -e 'START TRANSACTION; SELECT * FROM slots WHERE id=10 LOCK IN SHARE MODE; SELECT SLEEP(8); ROLLBACK' >/dev/null &\nsleep 1\nmariadb -N shop -e 'START TRANSACTION; SELECT label FROM slots WHERE id=10 LOCK IN SHARE MODE; ROLLBACK' > /tmp/share.txt\ncat /tmp/share.txt\nwait\n\n# 공유 락끼리는 충돌하지 않는다. 읽기끼리는 함께 할 수 있다",
     SLOTS, [chk('두 번째 세션이 값을 읽었다', '[ "$(cat /tmp/share.txt)" = a ]')])
# 2
b.nt('공유 락: 쓰기는 기다린다', '앞 문제와 같은 상황입니다. 첫 세션이 `id=10` 행에 공유 락을 걸고 쉽니다.\n\n`mariadb shop -e "START TRANSACTION; SELECT * FROM slots WHERE id=10 LOCK IN SHARE MODE; SELECT SLEEP(8); ROLLBACK" >/dev/null &`\n\n두 번째 세션에서 대기 시간을 2초로 줄이고(`SET SESSION innodb_lock_wait_timeout=2;`) 그 행의 `label` 을 `x` 로 **UPDATE** 해 보세요. 나오는 **오류 메시지를 `/tmp/upd.txt`** 에 저장합니다. (끝나기를 기다리려면 `wait`)',
     '오류는 표준 에러로 나옵니다. `2> /tmp/upd.txt`. 같은 행에 걸린 공유 락과 UPDATE 가 필요로 하는 락의 관계를 생각해 보세요.',
     "mariadb shop -e 'START TRANSACTION; SELECT * FROM slots WHERE id=10 LOCK IN SHARE MODE; SELECT SLEEP(8); ROLLBACK' >/dev/null &\nsleep 1\nmariadb shop -e \"SET SESSION innodb_lock_wait_timeout=2; UPDATE slots SET label='x' WHERE id=10\" 2> /tmp/upd.txt\nwait\ncat /tmp/upd.txt\n\n# 공유 락이 걸린 행은 읽기만 허용하고 쓰기(배타 락 필요)는 기다리다 1205 가 난다",
     SLOTS, [chk('오류 1205 가 기록됐다', 'grep -q 1205 /tmp/upd.txt'), chk('값이 바뀌지 않았다', f'[ "$({LABEL})" = a ]')])
# 3
b.nt('갭 락: 비어 있는 범위에도 락이 걸린다', '`REPEATABLE READ` 에서 `id` 가 11~19 인 행을 `FOR UPDATE` 로 읽으면, **행이 하나도 없어도** InnoDB 는 그 사이(10 과 20 사이의 빈 구간)에 **갭 락(gap lock)** 을 겁니다. 다른 세션이 그 구간에 끼어드는 INSERT 를 막기 위해서입니다.\n\n`mariadb shop -e "START TRANSACTION; SELECT * FROM slots WHERE id BETWEEN 11 AND 19 FOR UPDATE; SELECT SLEEP(25); ROLLBACK" >/dev/null &`\n\n첫 세션이 쉬는 동안 두 번째 세션에서 대기 시간을 2초로 줄이고 아래 두 INSERT 를 **각각** 실행하세요.\n1. `(15, \'n\')` — 오류 메시지를 `/tmp/gap.txt` 에 저장\n2. `(25, \'n\')` — 20 과 30 사이의 다른 빈 구간\n\n(끝나기를 기다리려면 `wait`)',
     '각 INSERT 는 `SET SESSION innodb_lock_wait_timeout=2; INSERT ...` 를 한 번의 `mariadb -e` 로 실행합니다. 첫째는 `2> /tmp/gap.txt`. 어느 쪽이 막히고 어느 쪽이 통과하는지 직접 보세요.',
     "mariadb shop -e 'START TRANSACTION; SELECT * FROM slots WHERE id BETWEEN 11 AND 19 FOR UPDATE; SELECT SLEEP(25); ROLLBACK' >/dev/null &\nsleep 1\nmariadb shop -e \"SET SESSION innodb_lock_wait_timeout=2; INSERT INTO slots VALUES (15,'n')\" 2> /tmp/gap.txt\nmariadb shop -e \"SET SESSION innodb_lock_wait_timeout=2; INSERT INTO slots VALUES (25,'n')\"\nwait\ncat /tmp/gap.txt\n\n# 15 는 잠긴 구간(10~20)이라 1205, 25 는 잠기지 않은 구간(20~30)이라 통과한다",
     SLOTS, [chk('15 삽입이 1205 로 막혔다', 'grep -q 1205 /tmp/gap.txt'), chk('15 행이 없다', '! ' + HAS(15)), chk('25 행은 들어갔다', HAS(25))])
# 4
b.nt('READ COMMITTED 에서는 갭 락이 없다', '앞 문제의 실험을 **READ COMMITTED** 로 바꿔 봅니다. 이 수준에서는 InnoDB 가 갭 락을 거의 걸지 않습니다. 첫 세션은 아래와 같습니다.\n\n`mariadb shop -e "SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION; SELECT * FROM slots WHERE id BETWEEN 11 AND 19 FOR UPDATE; SELECT SLEEP(8); ROLLBACK" >/dev/null &`\n\n두 번째 세션에서 같은 `(15, \'n\')` 를 INSERT 해서 **막히지 않고 들어가게** 하세요. (대기 시간은 2초로 줄여 두세요. 기다리려면 `wait`)',
     '앞 문제와 같은 INSERT 입니다. 이번에는 오류 없이 끝나야 합니다. 첫 세션 명령에 격리 수준 설정이 들어 있는 것이 차이입니다.',
     "mariadb shop -e 'SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED; START TRANSACTION; SELECT * FROM slots WHERE id BETWEEN 11 AND 19 FOR UPDATE; SELECT SLEEP(8); ROLLBACK' >/dev/null &\nsleep 1\nmariadb shop -e \"SET SESSION innodb_lock_wait_timeout=2; INSERT INTO slots VALUES (15,'n')\"\nwait\n\n# READ COMMITTED 는 갭 락이 없어 INSERT 가 막히지 않는다. 대신 팬텀(범위 안 새 행)이 보일 수 있다. 락을 줄이려고 이 수준을 쓰는 서비스가 많다",
     SLOTS, [chk('15 행이 들어갔다', HAS(15))])
# 5
b.nt('ALTER 가 멈췄다: 기다리는 이유 읽기', '서비스 테이블 `shop.slots` 에 컬럼을 추가하는 `ALTER TABLE` 이 끝나지 않고 멈춰 있습니다. 어느 세션이 `ALTER` 인지, 무엇을 기다리는지 `PROCESSLIST` 로 확인하세요. 아래 두 가지를 저장합니다.\n- `/tmp/alter_id.txt` : `ALTER TABLE` 을 실행 중인 **세션 Id** (숫자만)\n- `/tmp/state.txt` : 그 세션의 **State** 열 값 (글자 그대로)',
     '`information_schema.processlist` 를 `info LIKE \'ALTER%\'` 로 걸러 `id` 와 `state` 를 각각 조회합니다. `-N` 은 제목 줄을 빼 줍니다.',
     "mariadb -e 'SHOW FULL PROCESSLIST'\nmariadb -N -e \"SELECT id FROM information_schema.processlist WHERE info LIKE 'ALTER%'\" > /tmp/alter_id.txt\nmariadb -N -e \"SELECT state FROM information_schema.processlist WHERE info LIKE 'ALTER%'\" > /tmp/state.txt\ncat /tmp/alter_id.txt /tmp/state.txt\n\n# State 가 'Waiting for table metadata lock' 이면 다른 세션이 이 테이블을 쓰는 중이라 ALTER 가 기다리는 것",
     MDLWAIT, [chk('ALTER 세션 Id 가 맞다', '[ "$(cat /tmp/alter_id.txt)" = "$(mariadb -N -e "SELECT id FROM information_schema.processlist WHERE info LIKE \'ALTER%\'")" ]'), chk('State 가 메타데이터 락 대기다', '[ "$(cat /tmp/state.txt)" = "Waiting for table metadata lock" ]')])
# 6
b.nt('범인 트랜잭션 찾아 KILL', '앞 문제와 같은 상황입니다. `ALTER TABLE` 이 **메타데이터 락(MDL)** 을 기다리는 것은, 어떤 세션이 `slots` 를 읽는 **트랜잭션을 열어 둔 채 끝내지 않았기** 때문입니다. 열려 있는 트랜잭션은 `information_schema.innodb_trx` 에서 볼 수 있고, `trx_mysql_thread_id` 가 세션 Id 입니다.\n\n그 세션을 찾아 `KILL` 해서 **`ALTER TABLE` 이 끝나게** 하세요. (끝나면 `slots` 에 `note` 컬럼이 생깁니다.)',
     '`SELECT trx_mysql_thread_id, trx_started FROM information_schema.innodb_trx;` 로 열린 트랜잭션을 봅니다. ALTER 세션이 아니라 그것을 막은 쪽을 끊어야 합니다.',
     "mariadb -e 'SELECT trx_mysql_thread_id, trx_started FROM information_schema.innodb_trx'\nmariadb -e \"KILL $(mariadb -N -e 'SELECT trx_mysql_thread_id FROM information_schema.innodb_trx')\"\nsleep 2\nmariadb shop -e 'DESC slots'\n\n# 열린 트랜잭션이 끝나(롤백되)면 MDL 이 풀리고 기다리던 ALTER 가 진행된다. ALTER 세션을 KILL 하면 변경 자체가 취소된다",
     MDLWAIT, [chk('note 컬럼이 생겼다', '[ "$(mariadb -N shop -e "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=\'shop\' AND table_name=\'slots\' AND column_name=\'note\'")" = 1 ]'), chk('열린 트랜잭션이 없다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.innodb_trx")" = 0 ]')])
# 7
b.nt('ALTER 뒤에 줄 선 SELECT 도 막힌다', '`ALTER TABLE` 이 MDL 을 기다리는 동안, **그 뒤에 오는 평범한 `SELECT`** 는 어떻게 될까요? 직접 확인합니다. 지금 `slots` 에는 열린 트랜잭션 하나와 대기 중인 `ALTER` 가 있습니다.\n\n새 세션에서 메타데이터 락 대기 시간을 2초로 줄이고(`SET SESSION lock_wait_timeout=2;`) `SELECT * FROM slots` 를 실행해, 나오는 **오류 메시지를 `/tmp/queue.txt`** 에 저장하세요.',
     '`SET` 과 `SELECT` 를 한 번의 `mariadb shop -e` 에 적고 `2> /tmp/queue.txt`. 평소에는 바로 끝나는 쿼리가 왜 기다리는지가 이 문제의 핵심입니다.',
     "mariadb shop -e 'SET SESSION lock_wait_timeout=2; SELECT * FROM slots' 2> /tmp/queue.txt\ncat /tmp/queue.txt\n\n# 대기 중인 ALTER 가 MDL 대기열 앞에 있어서, 뒤의 SELECT 도 줄을 서다 1205 가 난다. ALTER 하나가 서비스 전체를 멈추게 하는 이유",
     MDLWAIT, [chk('1205 오류가 기록됐다', 'grep -q 1205 /tmp/queue.txt')])
# 8
b.choice('갭 락은 왜 있을까', 'REPEATABLE READ 에서 `SELECT ... WHERE id BETWEEN 11 AND 19 FOR UPDATE` 는 행이 없어도 그 범위에 갭 락을 겁니다. 이 락의 목적은 무엇인가요?', '락이 막는 것은 "있는 행"이 아니라 "새로 생길 행"입니다.',
         ['빈 구간에 새 행이 끼어들지 못하게 한다', '범위 안의 기존 행을 읽지 못하게 한다', '테이블 구조(컬럼)가 바뀌지 않게 한다', '인덱스가 없을 때 쿼리를 거부하게 한다'], 0,
         '갭 락은 인덱스 레코드 사이의 빈 구간에 새 행이 INSERT 되는 것을 막아, 같은 트랜잭션이 같은 범위를 다시 읽을 때 새 행(팬텀 리드)이 보이지 않게 합니다. 기존 행을 읽지 못하게 하는 것이 아니고(읽기는 스냅샷), 테이블 구조 변경을 막는 것은 메타데이터 락의 일입니다.')
# 9
b.choice('운영 테이블 ALTER 전에 가장 먼저 할 일', '사용량이 많은 운영 테이블에 `ALTER TABLE` 을 하려고 합니다. 서비스를 멈추지 않으려면 실행 **전에** 무엇을 먼저 확인해야 하나요?', 'ALTER 가 실제로 무엇을 기다리는지 생각해 보세요.',
         ['오래 열려 있는 트랜잭션이 있는지 확인한다', '서버를 재시작해 모든 연결을 초기화한다', '테이블의 모든 인덱스를 먼저 삭제한다', '`max_connections` 를 최대로 올린다'], 0,
         '오래 열린 트랜잭션이 있으면 ALTER 가 MDL 대기열에서 막히고, 그 뒤의 모든 쿼리가 줄을 서서 서비스가 멈춥니다. `information_schema.innodb_trx` 와 PROCESSLIST 로 먼저 확인하고, 세션의 `lock_wait_timeout` 을 짧게 해서 실행하는 것이 안전합니다. 재시작이나 인덱스 삭제는 문제를 키웁니다.')
# 10
b.fill('메타데이터 락 대기 시간 변수', '메타데이터 락(MDL)을 기다리는 최대 시간을 정하는 서버 변수를 채우세요. (행 락 대기는 `innodb_lock_wait_timeout`)', '행 락이 아니라 테이블 구조 보호용 락의 대기 시간입니다.',
       'SET SESSION {0} = 2;', ['lock_wait_timeout', 'innodb_lock_wait_timeout', 'wait_timeout', 'net_read_timeout'], [0],
       '`lock_wait_timeout` 은 메타데이터 락을 기다리는 시간(기본 1년)입니다. `innodb_lock_wait_timeout` 은 InnoDB 행 락 대기, `wait_timeout` 은 유휴 접속을 끊는 시간, `net_read_timeout` 은 네트워크 읽기 제한입니다.')
# 11
b.order('운영 테이블 ALTER 를 안전하게 시도하는 순서', '서비스 중인 테이블에 컬럼을 추가하려는 순서입니다. 확인이 먼저이고, 안전장치는 ALTER 를 실행하기 전에 걸어야 합니다. 순서를 놓으세요.', 'ALTER 가 막히면 서비스 전체가 멈춘다는 점에서 출발하세요.',
        ['ALTER TABLE 실행', '시간 초과로 실패하면 한가한 때 다시 시도', '오래 열린 트랜잭션이 있는지 innodb_trx 로 확인', '세션의 lock_wait_timeout 을 짧게 설정'], [2, 3, 0, 1],
        '먼저 innodb_trx 로 오래 열린 트랜잭션이 있는지 확인하고, lock_wait_timeout 을 짧게 걸어 두면 ALTER 가 줄에서 오래 기다리며 서비스를 막는 일을 피합니다. 그다음 ALTER 를 실행하고, 시간 초과로 실패하면 서비스 영향 없이 물러났다가 한가한 때 다시 시도합니다.')

if __name__ == '__main__':
    preview(b)
