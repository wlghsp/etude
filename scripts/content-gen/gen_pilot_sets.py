# 빈틈 보강 파일럿 세트 502·503·504 생성기 (docs/specs/spec_pilot_gap_sets.md). 한 번만 실행한다 (02·05·06·08 파일과 마이그레이션에 행이 붙는다).
# 다시 만들려면 붙은 줄(02 마지막 행, 05·06·08 의 `WHERE id = N;` 줄)과 마이그레이션·03·verify 파일을 지우고 DB 행도 지운 뒤 실행한다.
import json, os, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SETS = []


def sq(s): return s.replace('\\', '\\\\').replace("'", "''")
def lit(s): return 'NULL' if s is None else "'" + sq(s) + "'"
def j(o): return json.dumps(o, ensure_ascii=False)
def sh(c): return ['sh', '-c', c]
def chk(label, cmd): return dict(label=label, cmd=cmd)


class SetBuilder:
    def __init__(self, sid, title, desc, sandbox, category, unit_id, display_order, icon, docs, pos_seed):
        self.sid, self.title, self.desc, self.sandbox, self.category = sid, title, desc, sandbox, category
        self.unit_id, self.display_order, self.icon, self.docs, self.pos_seed = unit_id, display_order, icon, docs, pos_seed
        self.Q = []

    def nt(self, title, desc, hint, sol, setup, checks):
        self.Q.append(dict(n=len(self.Q) + 1, kind='terminal', title=title, desc=desc, hint=hint, sol=sol, setup=setup, checks=checks))

    def choice(self, title, desc, hint, opts, ans, expl):
        n = len(self.Q) + 1
        pos = (n * 7 + self.pos_seed) % 4  # 정답 위치 분산. ans 는 opts 에서의 원래 정답 위치
        o = list(opts); right = o.pop(ans); o.insert(pos, right)
        self.Q.append(dict(n=n, kind='choice', title=title, desc=desc, hint=hint, opts=o, ans=pos, expl=expl))

    def fill(self, title, desc, hint, tpl, chips, spec, expl):
        self.Q.append(dict(n=len(self.Q) + 1, kind='fill', title=title, desc=desc, hint=hint, tpl=tpl, chips=chips, spec=spec, expl=expl))

    def order(self, title, desc, hint, pieces, spec, expl):
        self.Q.append(dict(n=len(self.Q) + 1, kind='order', title=title, desc=desc, hint=hint, pieces=pieces, spec=spec, expl=expl))


COLS = 'quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs'


def rows_of(b):
    rows, answers = [], {}
    doc = j(b.docs)
    for q in b.Q:
        k = q['kind']
        if k == 'terminal':
            grade = ' && '.join(f'( {c["cmd"]} )' for c in q['checks'])
            answers[str(q['n'])] = q['sol']
            vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), lit(q['sol']), lit(j(sh(q['setup']))), lit(j(sh(grade))), "'terminal'", 'NULL', 'NULL', 'NULL', 'NULL', 'NULL',
                    lit(j([dict(label=c['label'], cmd=sh(c['cmd'])) for c in q['checks']])), lit(doc)]
        elif k == 'choice':
            vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL', 'NULL', "'[]'", "'choice'", lit(j(q['opts'])), str(q['ans']), lit(q['expl']), 'NULL', 'NULL', 'NULL', 'NULL']
        elif k == 'fill':
            vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL', 'NULL', "'[]'", "'fill'", lit(j(q['chips'])), 'NULL', lit(q['expl']), lit(j(q['spec'])), lit(q['tpl']), 'NULL', 'NULL']
        else:
            vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL', 'NULL', "'[]'", "'order'", lit(j(q['pieces'])), 'NULL', lit(q['expl']), lit(j(q['spec'])), 'NULL', 'NULL', 'NULL']
        rows.append(f"({b.sid}, {q['n']}, " + ', '.join(vals) + ')')
    return rows, answers


def mig_sql(b, rows):
    sid = b.sid
    mig = f"""-- 세트 {sid}. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set{sid}.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT {sid}, {lit(b.title)}, {lit(b.desc)}, '{b.sandbox}', '{b.category}'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = {sid});
UPDATE quest_set SET display_order = {b.display_order}, unit_id = (SELECT id FROM unit WHERE id = {b.unit_id}), icon = '{b.icon}' WHERE id = {sid};
"""
    for q, r in zip(b.Q, rows):
        mig += f"\nINSERT INTO quest ({COLS})\nSELECT {r[1:-1]}\nFROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = {sid} AND order_index = {q['n']});\n"
    return mig


def preview(b):
    """로컬 DB 에만 세트를 넣는다 (검증용). 공유 파일(02·05·06·08)과 저장소는 건드리지 않는다. 같은 세트 번호는 지우고 다시 넣는다."""
    import subprocess
    rows, _ = rows_of(b)
    sql = f"DELETE FROM quest WHERE quest_set_id = {b.sid};\nDELETE FROM quest_set WHERE id = {b.sid};\n" + mig_sql(b, rows)
    r = subprocess.run(['docker', 'exec', '-i', 'etude-db', 'mariadb', '-h127.0.0.1', '-uroot', '-proot', 'etude'], input=sql, text=True, capture_output=True)
    assert r.returncode == 0, r.stderr
    rows2, answers = rows_of(b)
    json.dump(dict(setId=b.sid, answers=answers), open(f'{ROOT}/backend/verify/set{b.sid}.json', 'w'), ensure_ascii=False, indent=2)
    print('preview ok', b.sid, len(b.Q))


def emit(b, mig_name):
    rows, answers = rows_of(b)
    sid = b.sid
    kinds = {q['kind'] for q in b.Q}
    assert len(kinds) >= 3, f'세트 {sid}: 형식 3종 이상이어야 한다'
    body = f"-- 세트 {sid}: {b.title}\n-- 빈틈 보강 파일럿(docs/specs/spec_pilot_gap_sets.md). 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다.\nINSERT INTO quest ({COLS}) VALUES\n  " + ',\n  '.join(rows) + ';\n'
    open(f'{ROOT}/backend/db/03_quest_set{sid}.sql', 'w').write(body)
    json.dump(dict(setId=sid, answers=answers), open(f'{ROOT}/backend/verify/set{sid}.json', 'w'), ensure_ascii=False, indent=2)
    setrow = f"  ({sid}, {lit(b.title)}, {lit(b.desc)}, '{b.sandbox}', '{b.category}')"
    p = f'{ROOT}/backend/db/02_quest_set.sql'
    s = open(p).read().rstrip('\n')
    assert s.endswith(');')
    open(p, 'w').write(s[:-1] + ',\n' + setrow + ';\n')
    open(f'{ROOT}/backend/db/05_display_order.sql', 'a').write(f'UPDATE quest_set SET display_order = {b.display_order} WHERE id = {sid};\n')
    open(f'{ROOT}/backend/db/06_units.sql', 'a').write(f'UPDATE quest_set SET unit_id = {b.unit_id} WHERE id = {sid};\n')
    open(f'{ROOT}/backend/db/08_set_icons.sql', 'a').write(f"UPDATE quest_set SET icon = '{b.icon}' WHERE id = {sid};\n")
    mig = mig_sql(b, rows)
    open(f'{ROOT}/backend/db/migrations/{mig_name}', 'w').write(mig)
    print('ok', sid, len(b.Q), sorted(kinds))


# ---------------------------------------------------------------- 공통 DB 준비
DBUP = "nohup mysqld_safe >/dev/null 2>&1 & for i in $(seq 1 60); do mariadb -e 'select 1' >/dev/null 2>&1 && break; sleep 0.5; done"
CLEAN = "rm -f /tmp/*.txt /tmp/*.sh /tmp/*.sql /tmp/*.cnf"
# ---------------------------------------------------------------- 세트 502: 트랜잭션과 락
BANK = DBUP + """; mariadb -e 'DROP DATABASE IF EXISTS bank; CREATE DATABASE bank; USE bank; CREATE TABLE accounts (id INT PRIMARY KEY, owner VARCHAR(20), balance INT) ENGINE=InnoDB; INSERT INTO accounts VALUES (1,"kim",1000),(2,"lee",500);'; """ + CLEAN
# 오래 열려 있는 트랜잭션 하나를 백그라운드로 띄운다 (600초)
HOLD = "; nohup mariadb bank -e 'START TRANSACTION; UPDATE accounts SET balance = balance WHERE id = 1; SELECT SLEEP(600);' >/dev/null 2>&1 & sleep 1"
BALANCE = lambda i: f"mariadb -N bank -e 'SELECT balance FROM accounts WHERE id={i}'"

b = SetBuilder(502, '트랜잭션과 락 직접 만들어 보기: 롤백, 락 대기, KILL, 데드락',
               'MariaDB 에서 트랜잭션을 직접 열고 닫아 봅니다. autocommit, ROLLBACK 과 COMMIT, SAVEPOINT, 다른 세션에서 커밋 전 변경이 안 보이는 것, SELECT ... FOR UPDATE 와 락 대기 시간 초과, information_schema.innodb_trx 로 열린 트랜잭션 찾기, KILL, 데드락 재현을 터미널 하나에서 백그라운드 세션으로 실습합니다.',
               'linux-db', '데이터베이스', 20, 723, '🔒',
               [{"title": "MariaDB 트랜잭션", "url": "https://mariadb.com/kb/en/transactions/"}, {"title": "InnoDB 락 모드", "url": "https://mariadb.com/kb/en/innodb-lock-modes/"}], 3)
b.nt('autocommit 값 확인하기', '`bank` 데이터베이스를 쓰는 서버의 **`autocommit` 설정값**을 `/tmp/ac.txt` 에 저장하세요. (제목 줄 없이 값만)',
     '`SELECT @@autocommit;` 를 `mariadb -N -e` 로 실행하고 `>` 로 저장합니다. 켜져 있으면 1, 꺼져 있으면 0 으로 나옵니다.',
     "mariadb -N -e 'SELECT @@autocommit' > /tmp/ac.txt\ncat /tmp/ac.txt\n\n# 1 = 문장 하나가 끝날 때마다 자동으로 COMMIT. 트랜잭션으로 묶으려면 START TRANSACTION 으로 시작한다",
     BANK, [chk('파일이 있다', '[ -s /tmp/ac.txt ]'), chk('값이 1 이다', '[ "$(cat /tmp/ac.txt)" = 1 ]')])
b.nt('변경했다가 ROLLBACK 으로 되돌리기', '`kim`(id 1) 계좌의 잔액을 **0 으로 바꾼 뒤 ROLLBACK** 하세요. 한 번의 `mariadb -e` 안에서 `START TRANSACTION; UPDATE ...; SELECT ...; ROLLBACK;` 순서로 실행하고, 바꾼 직후의 값을 `/tmp/during.txt`, 롤백한 뒤 다시 조회한 값을 `/tmp/after.txt` 에 저장하세요.',
     '변경 직후 값은 트랜잭션 안에서 `SELECT balance ...` 로 읽고 `-N` 으로 값만 저장합니다. 롤백 후 값은 새 `mariadb` 로 다시 조회합니다.',
     "mariadb -N bank -e 'START TRANSACTION; UPDATE accounts SET balance=0 WHERE id=1; SELECT balance FROM accounts WHERE id=1; ROLLBACK;' > /tmp/during.txt\nmariadb -N bank -e 'SELECT balance FROM accounts WHERE id=1' > /tmp/after.txt\ncat /tmp/during.txt /tmp/after.txt\n\n# 트랜잭션 안에서는 바뀐 값(0)이 보이지만 ROLLBACK 하면 원래 값(1000)으로 돌아온다",
     BANK, [chk('트랜잭션 안에서는 0 이었다', '[ "$(cat /tmp/during.txt)" = 0 ]'), chk('롤백 후 1000 으로 돌아왔다', '[ "$(cat /tmp/after.txt)" = 1000 ]')])
b.nt('이체를 한 트랜잭션으로 묶어 COMMIT', '`kim` 계좌에서 **300 을 빼고** `lee` 계좌에 **300 을 더하는** 이체를 한 트랜잭션으로 묶어 `COMMIT` 하세요. 끝나면 `kim` 은 700, `lee` 는 800 이어야 합니다.',
     '`START TRANSACTION; UPDATE ...; UPDATE ...; COMMIT;` 를 한 번의 `mariadb -e` 에 이어 적습니다.',
     "mariadb bank -e 'START TRANSACTION; UPDATE accounts SET balance=balance-300 WHERE id=1; UPDATE accounts SET balance=balance+300 WHERE id=2; COMMIT;'\nmariadb bank -e 'SELECT * FROM accounts'\n\n# 둘 다 성공해야 의미가 있는 작업은 한 트랜잭션으로 묶는다. 중간에 실패하면 ROLLBACK 으로 둘 다 취소한다",
     BANK, [chk('kim 이 700 이다', f'[ "$({BALANCE(1)})" = 700 ]'), chk('lee 가 800 이다', f'[ "$({BALANCE(2)})" = 800 ]')])
b.nt('SAVEPOINT 까지만 되돌리기', '한 트랜잭션에서 `kim` 의 잔액을 **100 줄이고**(첫 번째 UPDATE), `SAVEPOINT sp1;` 을 만든 뒤 `lee` 의 잔액을 **999 늘렸다가**(두 번째 UPDATE), `ROLLBACK TO sp1;` 로 두 번째 변경만 취소하고 `COMMIT` 하세요. 결과는 `kim` 900, `lee` 500 입니다.',
     '`SAVEPOINT 이름;` 으로 표시를 남기고 `ROLLBACK TO 이름;` 으로 그 지점까지만 되돌립니다. 그 앞의 변경은 남아 있어 `COMMIT` 으로 확정됩니다.',
     "mariadb bank -e 'START TRANSACTION; UPDATE accounts SET balance=balance-100 WHERE id=1; SAVEPOINT sp1; UPDATE accounts SET balance=balance+999 WHERE id=2; ROLLBACK TO sp1; COMMIT;'\nmariadb bank -e 'SELECT * FROM accounts'\n\n# ROLLBACK TO 는 트랜잭션을 끝내지 않는다. 마지막에 COMMIT 을 해야 남은 변경이 확정된다",
     BANK, [chk('kim 이 900 이다', f'[ "$({BALANCE(1)})" = 900 ]'), chk('lee 는 500 그대로다', f'[ "$({BALANCE(2)})" = 500 ]')])
b.nt('커밋 전 변경은 다른 세션에 안 보인다', '다른 세션이 `kim` 의 잔액을 **999 로 바꿨지만 아직 COMMIT 하지 않은 상태**를 만들어 봅니다. 아래 **첫 번째 세션**을 백그라운드로 띄우고(끝에 `&`), 바로 이어서 **두 번째 세션**에서 `kim` 의 잔액을 읽어 `/tmp/seen.txt` 에 저장하세요.\n\n`mariadb bank -e "START TRANSACTION; UPDATE accounts SET balance=999 WHERE id=1; SELECT SLEEP(20); ROLLBACK;" &`',
     '첫 세션이 `SLEEP(8)` 로 기다리는 동안(커밋 전) 읽어야 합니다. 읽은 값이 999 가 아니라 원래 값이면 격리가 잘 동작하는 것입니다.',
     "mariadb bank -e 'START TRANSACTION; UPDATE accounts SET balance=999 WHERE id=1; SELECT SLEEP(8); ROLLBACK;' >/dev/null 2>&1 &\nsleep 1\nmariadb -N bank -e 'SELECT balance FROM accounts WHERE id=1' > /tmp/seen.txt\ncat /tmp/seen.txt\nwait\n\n# 커밋 전 변경은 변경한 세션에서만 보인다. 두 번째 세션은 원래 값 1000 을 읽는다",
     BANK, [chk('읽은 값이 원래 값 1000 이다', '[ "$(cat /tmp/seen.txt)" = 1000 ]')])
b.nt('SELECT ... FOR UPDATE 가 만든 락 대기', '한 세션이 `kim`(id 1) 행을 `SELECT ... FOR UPDATE` 로 잠근 상태에서, 다른 세션이 같은 행을 `UPDATE` 하면 기다리다 **시간 초과**가 납니다. 잠금 세션을 백그라운드로 띄우고, 두 번째 세션에서 `SET SESSION innodb_lock_wait_timeout=2;` 후 `UPDATE` 를 실행해 **오류 메시지를 `/tmp/lock.txt`** 에 저장하세요.\n\n`mariadb bank -e "START TRANSACTION; SELECT * FROM accounts WHERE id=1 FOR UPDATE; SELECT SLEEP(20); ROLLBACK;" &`',
     '오류 메시지는 표준 에러로 나옵니다. `2> /tmp/lock.txt` 로 저장하세요. `ERROR 1205 ... Lock wait timeout exceeded` 가 보여야 합니다.',
     "mariadb bank -e 'START TRANSACTION; SELECT * FROM accounts WHERE id=1 FOR UPDATE; SELECT SLEEP(8); ROLLBACK;' >/dev/null 2>&1 &\nsleep 1\nmariadb bank -e 'SET SESSION innodb_lock_wait_timeout=2; UPDATE accounts SET balance=1 WHERE id=1;' 2> /tmp/lock.txt\ncat /tmp/lock.txt\nwait\n\n# 행을 잡고 있는 세션이 끝나기 전에는 같은 행 변경이 대기한다. 기다림 한도(innodb_lock_wait_timeout)를 넘으면 1205 오류",
     BANK, [chk('오류 번호 1205 가 있다', 'grep -q "ERROR 1205" /tmp/lock.txt'), chk('Lock wait timeout 메시지가 있다', 'grep -q "Lock wait timeout exceeded" /tmp/lock.txt')])
b.nt('열려 있는 트랜잭션 찾기', '지금 서버에는 누군가 **COMMIT 하지 않고 오래 열어 둔 트랜잭션**이 있습니다. `information_schema.innodb_trx` 에서 **트랜잭션 상태(`trx_state`)와 세션 번호(`trx_mysql_thread_id`)** 두 열을 조회해 `/tmp/trx.txt` 에 저장하세요.',
     '`SELECT trx_state, trx_mysql_thread_id FROM information_schema.innodb_trx;` 를 `mariadb -e` 로 실행합니다.',
     "mariadb -e 'SELECT trx_state, trx_mysql_thread_id FROM information_schema.innodb_trx' > /tmp/trx.txt\ncat /tmp/trx.txt\n\n# innodb_trx 에는 지금 열려 있는 InnoDB 트랜잭션이 한 줄씩 나온다. trx_mysql_thread_id 가 KILL 할 때 쓰는 세션 번호",
     BANK + HOLD, [chk('제목에 trx_state 가 있다', 'grep -q trx_state /tmp/trx.txt'), chk('RUNNING 트랜잭션이 보인다', 'grep -q RUNNING /tmp/trx.txt')])
b.nt('오래 열린 세션 KILL 하기', '`innodb_trx` 에 보이는 **오래 열린 트랜잭션의 세션**이 락을 쥐고 있습니다. 세션 번호를 찾아 `KILL` 로 종료해, 열려 있는 트랜잭션이 **0개**가 되게 하세요.',
     '세션 번호는 `trx_mysql_thread_id` 입니다. `KILL 번호;` 로 종료하면 그 세션의 미커밋 변경은 롤백됩니다.',
     "ID=$(mariadb -N -e 'SELECT trx_mysql_thread_id FROM information_schema.innodb_trx LIMIT 1')\nmariadb -e \"KILL $ID\"\nsleep 1\nmariadb -N -e 'SELECT COUNT(*) FROM information_schema.innodb_trx'\n\n# KILL 은 세션을 끊고 미커밋 변경을 롤백한다. 운영에서는 무엇을 끊는지 확인하고 실행한다",
     BANK + HOLD, [chk('열린 트랜잭션이 0개다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.innodb_trx")" = 0 ]')])
b.nt('데드락 만들어 보기', '두 세션이 **서로 반대 순서로** 두 행을 갱신하면 데드락이 납니다. 세션 A 는 id 1 → id 2, 세션 B 는 id 2 → id 1 순서로 갱신하게 해서, 각 세션의 오류 출력을 `/tmp/a.txt`, `/tmp/b.txt` 에 저장하세요. (한쪽에는 `Deadlock found` 오류가 나옵니다.)\n\n세션 A: `START TRANSACTION; UPDATE accounts SET balance=balance+1 WHERE id=1; SELECT SLEEP(2); UPDATE accounts SET balance=balance+1 WHERE id=2; COMMIT;`',
     '두 세션 모두 `&` 로 백그라운드에서 띄우고 `wait` 로 기다립니다. 각 세션을 `2> /tmp/a.txt`, `2> /tmp/b.txt` 로 나눠 저장하세요. 중간 `SELECT SLEEP(2)` 가 서로 첫 행을 쥔 뒤 상대 행을 요구하게 만듭니다. 두 명령을 연달아 한 번에 붙여넣어야 2초 안에 겹칩니다.',
     "mariadb bank -e 'START TRANSACTION; UPDATE accounts SET balance=balance+1 WHERE id=1; SELECT SLEEP(2); UPDATE accounts SET balance=balance+1 WHERE id=2; COMMIT;' >/dev/null 2>/tmp/a.txt &\nmariadb bank -e 'START TRANSACTION; UPDATE accounts SET balance=balance+1 WHERE id=2; SELECT SLEEP(2); UPDATE accounts SET balance=balance+1 WHERE id=1; COMMIT;' >/dev/null 2>/tmp/b.txt &\nwait\ncat /tmp/a.txt /tmp/b.txt\n\n# 서로 상대가 쥔 행을 기다리면 InnoDB 가 한쪽을 희생자로 골라 롤백한다 (ERROR 1213). 그 세션은 다시 시도한다",
     BANK, [chk('두 파일이 있다', '[ -e /tmp/a.txt ] && [ -e /tmp/b.txt ]'), chk('한쪽에 Deadlock found 가 있다', 'cat /tmp/a.txt /tmp/b.txt | grep -q "Deadlock found"')])
b.choice('데드락을 줄이는 방법', '여러 행을 갱신하는 트랜잭션이 **서로 얽혀 데드락**이 자주 납니다. 가장 효과적인 예방 방법은 무엇인가요?', '데드락은 서로 상대가 쥔 것을 기다리는 고리입니다. 그 고리가 생기지 않게 하려면 락을 잡는 순서를 어떻게 해야 할지 생각해 보세요.',
         ['모든 트랜잭션이 행을 같은 순서(예: id 오름차순)로 갱신한다', '트랜잭션을 가능한 한 오래 열어 둔다', '`innodb_lock_wait_timeout` 을 아주 크게 늘린다', 'autocommit 을 끄고 COMMIT 을 미룬다'], 0,
         '데드락은 서로 반대 순서로 락을 잡을 때 생깁니다. 모두 같은 순서로 접근하면 서로를 기다리는 고리가 생기지 않습니다. 트랜잭션을 길게 열거나 COMMIT 을 미루면 락을 오래 쥐어 오히려 나빠지고, 대기 시간을 늘리는 것은 데드락과 무관합니다.')
b.fill('행을 잠그며 읽기', '이체 전에 `kim`(id 1) 행을 **다른 세션이 못 바꾸게 잠그며 읽는** 문장입니다. 빈칸을 채우세요.', '행 락을 거는 읽기 구문입니다.',
       'SELECT * FROM accounts WHERE id = 1 {0};', ['FOR UPDATE', 'WITH LOCK', 'HOLD ROW', 'LOCK ROW'], [0],
       '`SELECT ... FOR UPDATE` 는 읽은 행에 쓰기 락을 걸어, 트랜잭션이 끝날 때까지 다른 세션이 그 행을 바꾸지 못하게 합니다. 나머지는 MariaDB 구문이 아닙니다.')
b.order('SAVEPOINT 를 쓰는 트랜잭션 순서', '아래 카드를 SAVEPOINT 로 **일부만 되돌리고 확정하는** 트랜잭션의 실행 순서로 놓으세요.', '트랜잭션을 연 뒤 변경하고, 되돌릴 지점을 표시합니다. 그 이후 변경만 취소하고 마지막에 확정하는 흐름을 떠올려 보세요.',
        ['ROLLBACK TO sp1', 'START TRANSACTION', 'COMMIT', '두 번째 UPDATE', 'SAVEPOINT sp1', '첫 번째 UPDATE'], [1, 5, 4, 3, 0, 2],
        '트랜잭션을 시작하고 첫 변경을 한 뒤 SAVEPOINT 로 지점을 표시합니다. 두 번째 변경 후 ROLLBACK TO sp1 으로 표시한 지점까지만 되돌리고, 마지막에 COMMIT 으로 남은 변경(첫 번째 UPDATE)을 확정합니다.')
SETS.append((b, '2026-11-19_gap_pilot_set502.sql'))

# ---------------------------------------------------------------- 세트 503: MariaDB 상황집
SHOP = DBUP + """; mariadb -e 'DROP DATABASE IF EXISTS shop; CREATE DATABASE shop; USE shop; CREATE TABLE items (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(30) NOT NULL, price INT); INSERT INTO items VALUES (1,"apple",1000),(2,"pear",2000),(3,"grape",3000),(4,"peach",4000),(5,"plum",5000); DROP USER IF EXISTS "app"@"localhost"; CREATE USER "app"@"localhost" IDENTIFIED BY "S3cret"; GRANT ALL ON shop.* TO "app"@"localhost"; FLUSH PRIVILEGES;'; """ + CLEAN
b = SetBuilder(503, 'MariaDB 문제 해결 상황집: 접속 거부, 없는 DB·테이블, 중복 키, 접속 가득, 락 대기',
               'MariaDB 에서 자주 만나는 오류 메시지를 읽고 원인을 찾아 고칩니다. Access denied(1045), Unknown database(1049), Table doesn\'t exist(1146), Duplicate entry(1062), Too many connections(1040), Lock wait timeout(1205)을 직접 재현된 상황에서 해결합니다.',
               'linux-db', '데이터베이스', 20, 724, '🚑',
               [{"title": "MariaDB 오류 코드", "url": "https://mariadb.com/kb/en/mariadb-error-codes/"}], 1)
b.nt('ERROR 1045: 비밀번호가 틀렸다', '앱이 쓰는 설정 파일 `/tmp/app.cnf` 로 접속하면 `ERROR 1045 (28000): Access denied for user \'app\'@\'localhost\' (using password: YES)` 가 납니다. 배포 문서에 적힌 올바른 비밀번호는 **`S3cret`** 입니다. 설정 파일을 고쳐, 접속해 `SELECT 1` 한 결과(`1`)를 `/tmp/ok.txt` 에 저장하세요.',
     '먼저 `mariadb --defaults-file=/tmp/app.cnf -e "SELECT 1"` 로 오류를 확인하세요. 접속 정보는 `[client]` 아래 `password=` 줄에 있습니다.',
     "sed -i 's/^password=.*/password=S3cret/' /tmp/app.cnf\nmariadb --defaults-file=/tmp/app.cnf -N -e 'SELECT 1' > /tmp/ok.txt\ncat /tmp/ok.txt\n\n# 1045 = 계정은 있는데 비밀번호(또는 접속 호스트)가 맞지 않음. 먼저 설정 파일의 값이 맞는지 본다",
     SHOP + "; printf '[client]\\nuser=app\\npassword=wrong\\n' > /tmp/app.cnf",
     [chk('설정 파일로 접속된다', 'mariadb --defaults-file=/tmp/app.cnf -N -e "SELECT 1" | grep -qx 1'), chk('결과를 저장했다', '[ "$(cat /tmp/ok.txt)" = 1 ]')])
b.nt('ERROR 1049: 없는 데이터베이스', '`/tmp/report.sh` 를 실행하면 `ERROR 1049 (42000): Unknown database \'shopp\'` 가 납니다. 스크립트를 고쳐 **상품 수**를 `/tmp/count.txt` 에 저장하세요. (값은 5)',
     '오류 메시지에 나온 데이터베이스 이름과 실제 이름(`SHOW DATABASES;`)을 비교해 보세요. 스크립트 안의 이름을 고칩니다.',
     "sed -i 's/shopp/shop/' /tmp/report.sh\nsh /tmp/report.sh > /tmp/count.txt\ncat /tmp/count.txt\n\n# 1049 = 이름에 해당하는 데이터베이스가 없다. 보통 오타이거나 다른 서버를 보고 있다",
     SHOP + "; printf '#!/bin/sh\\nmariadb -N shopp -e \"SELECT COUNT(*) FROM items\"\\n' > /tmp/report.sh",
     [chk('count.txt 가 5 이다', '[ "$(cat /tmp/count.txt)" = 5 ]'), chk('스크립트에서 오타가 사라졌다', '! grep -q shopp /tmp/report.sh')])
b.nt('ERROR 1146: 없는 테이블', '`/tmp/report.sh` 를 실행하면 `ERROR 1146 (42S02): Table \'shop.item\' doesn\'t exist` 가 납니다. 메시지에 **어느 데이터베이스의 어느 테이블**이 없다고 나오는지 읽고, 스크립트를 고쳐 **가장 비싼 상품의 가격**을 `/tmp/max.txt` 에 저장하세요. (값은 5000)',
     '`mariadb shop -e "SHOW TABLES;"` 로 실제 테이블 이름을 확인하세요. 오류 메시지의 `shop.item` 은 `데이터베이스.테이블` 입니다.',
     "sed -i 's/FROM item /FROM items /' /tmp/report.sh\nsh /tmp/report.sh > /tmp/max.txt\ncat /tmp/max.txt\n\n# 1146 메시지는 '데이터베이스.테이블' 로 알려 준다. 테이블 이름 오타인지, 데이터베이스를 잘못 골랐는지 가른다",
     SHOP + "; printf '#!/bin/sh\\nmariadb -N shop -e \"SELECT MAX(price) FROM item \"\\n' > /tmp/report.sh",
     [chk('max.txt 가 5000 이다', '[ "$(cat /tmp/max.txt)" = 5000 ]'), chk('스크립트가 items 를 본다', 'grep -q "FROM items" /tmp/report.sh')])
b.nt('ERROR 1062: 중복된 키', '`/tmp/add.sql` 로 새 상품 `melon`(3500원)을 넣으면 `ERROR 1062 (23000): Duplicate entry \'3\' for key \'PRIMARY\'` 가 납니다. 이미 있는 id 3(`grape`)은 **그대로 두고**, 스크립트를 고쳐 `melon` 이 **새 행으로** 들어가게 한 뒤 `mariadb shop < /tmp/add.sql` 로 실행하세요.',
     '`id` 는 `AUTO_INCREMENT` 기본 키입니다. 값을 직접 정하지 않으면 새 번호가 자동으로 붙습니다.',
     "cat > /tmp/add.sql <<'SQL'\nINSERT INTO items (name, price) VALUES ('melon', 3500);\nSQL\nmariadb shop < /tmp/add.sql\nmariadb shop -e 'SELECT * FROM items'\n\n# 1062 = 기본 키·UNIQUE 값이 이미 있다. 기존 행을 덮어쓰는 게 아니라면 id 를 지정하지 않거나 다른 값을 쓴다",
     SHOP + "; printf \"INSERT INTO items (id, name, price) VALUES (3, 'melon', 3500);\\n\" > /tmp/add.sql",
     [chk('melon 이 들어갔다', '[ "$(mariadb -N shop -e "SELECT COUNT(*) FROM items WHERE name=\'melon\'")" = 1 ]'), chk('id 3 은 grape 그대로다', '[ "$(mariadb -N shop -e "SELECT name FROM items WHERE id=3")" = grape ]'), chk('모두 6행이다', '[ "$(mariadb -N shop -e "SELECT COUNT(*) FROM items")" = 6 ]')])
b.nt('Too many connections: 접속이 가득 찼다', '앱 계정 `app`(비밀번호 `S3cret`)으로 접속하면 `ERROR 1040 (HY000): Too many connections` 가 납니다. 서버(root)로 접속해 **원인을 찾아 해결**한 뒤, `app` 계정으로 접속해 `SELECT 1` 한 결과(`1`)를 `/tmp/app_ok.txt` 에 저장하세요.\n\n(root 는 이 상황에서도 접속할 수 있습니다.)',
     '`SHOW PROCESSLIST;` 로 누가 접속을 차지했는지, `SHOW VARIABLES LIKE \'max_connections\';` 로 한도를 보세요. 오래 붙은 세션을 `KILL` 하거나 한도를 올리면 됩니다.',
     "for id in $(mariadb -N -e \"SELECT id FROM information_schema.processlist WHERE user='app'\"); do mariadb -e \"KILL $id\"; done\nsleep 1\nmariadb -uapp -pS3cret -N -e 'SELECT 1' > /tmp/app_ok.txt\ncat /tmp/app_ok.txt\n\n# 한도(max_connections)가 작거나 유휴 세션이 접속을 점유하면 1040. 원인 세션을 정리하고, 반복되면 한도·앱 접속 풀을 점검한다",
     SHOP + "; mariadb -e 'SET GLOBAL max_connections=4'; for i in 1 2 3 4; do nohup mariadb -uapp -pS3cret -e 'SELECT SLEEP(600)' >/dev/null 2>&1 & done; sleep 2",
     [chk('app 으로 접속된다', 'mariadb -uapp -pS3cret -N -e "SELECT 1" | grep -qx 1'), chk('결과를 저장했다', '[ "$(cat /tmp/app_ok.txt)" = 1 ]')])
b.nt('Lock wait timeout: 막고 있는 세션 찾기', '`UPDATE items SET price=1500 WHERE id=1` 가 오래 멈췄다가 `ERROR 1205 ... Lock wait timeout exceeded` 로 실패합니다. 누군가 **COMMIT 하지 않은 트랜잭션**이 id 1 행을 쥐고 있습니다. 원인 세션을 찾아 `KILL` 한 뒤 그 `UPDATE` 를 성공시키세요.',
     '`information_schema.innodb_trx` 의 `trx_mysql_thread_id` 가 세션 번호입니다. 먼저 KILL 로 푼 뒤 UPDATE 를 실행합니다.',
     "ID=$(mariadb -N -e 'SELECT trx_mysql_thread_id FROM information_schema.innodb_trx LIMIT 1')\nmariadb -e \"KILL $ID\"\nsleep 1\nmariadb shop -e 'UPDATE items SET price=1500 WHERE id=1'\nmariadb -N shop -e 'SELECT price FROM items WHERE id=1'\n\n# 1205 의 원인은 대개 오래 열린 트랜잭션. innodb_trx 로 찾고, 업무 영향 확인 후 KILL 한다",
     SHOP + "; nohup mariadb shop -e 'START TRANSACTION; UPDATE items SET price = price WHERE id = 1; SELECT SLEEP(600);' >/dev/null 2>&1 & sleep 1",
     [chk('가격이 1500 이다', '[ "$(mariadb -N shop -e "SELECT price FROM items WHERE id=1")" = 1500 ]'), chk('열린 트랜잭션이 없다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.innodb_trx")" = 0 ]')])
b.choice('1205 를 만났을 때 가장 먼저 할 일', '`ERROR 1205: Lock wait timeout exceeded; try restarting transaction` 을 만났습니다. **가장 먼저** 해야 할 일은 무엇인가요?', '이 오류는 내 쿼리가 아니라 다른 쪽 때문에 생기는 경우가 많습니다. 원인을 확인하기 전에 설정이나 서버를 건드리지 마세요.',
         ['막고 있는 트랜잭션을 찾는다 (information_schema.innodb_trx)', '서버를 재시작한다', '`max_connections` 를 두 배로 늘린다', '테이블을 삭제하고 다시 만든다'], 0,
         '1205 는 락 대기가 한도를 넘었다는 뜻입니다. 락을 쥔 트랜잭션을 찾아 원인을 보고 필요하면 그 세션을 KILL 합니다. 재시작이나 테이블 재생성은 과한 조치이고, max_connections 는 접속 수 한도라 관계가 없습니다.')
b.fill('현재 열린 접속 수 보기', '지금 서버에 **열려 있는 접속 수**를 보는 문장입니다. 빈칸을 채우세요.', '지금 이 순간의 값이 필요합니다. 서버 시작 이후의 최고치가 아닙니다.',
       "SHOW STATUS LIKE '{0}';", ['Threads_connected', 'Max_used_connections', 'Connection_errors', 'Open_tables'], [0],
       '`Threads_connected` 는 지금 열려 있는 접속 수입니다. `Max_used_connections` 는 서버 시작 이후의 최고치이고, 이 값이 `max_connections` 에 닿았다면 1040 이 난 적이 있다는 뜻입니다.')
b.order('Too many connections 해결 순서', '`app` 접속이 `Too many connections` 로 거절될 때 조치 순서대로 놓으세요.', '문제를 알아챈 뒤, 접속 수 한도와 상관없이 들어갈 수 있는 계정으로 원인을 살펴보고 정리하세요. 해결됐는지는 마지막에 확인합니다.',
        ['SHOW PROCESSLIST 로 접속을 차지한 세션 보기', '불필요한 세션을 KILL 하기', 'app 계정으로 다시 접속해 보기', 'app 접속이 1040 으로 거절됨을 확인', 'root 로 서버에 접속하기'], [3, 4, 0, 1, 2],
        '먼저 오류를 확인하고, 한도와 무관하게 들어갈 수 있는 관리자 계정으로 접속합니다. PROCESSLIST 로 점유한 세션을 보고 불필요한 것을 KILL 한 뒤, 같은 계정으로 다시 접속해 해결됐는지 확인합니다.')
SETS.append((b, '2026-11-19_gap_pilot_set503.sql'))

# ---------------------------------------------------------------- 세트 504: Git 인증·접근
LAB = "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab"
KEY = LAB + " && ssh-keygen -q -t ed25519 -N '' -C demo@example.com -f /tmp/lab/id_demo"
b = SetBuilder(504, 'Git 인증·접근: SSH 키 만들기, 권한, 원격 주소, 자격 증명 저장',
               'Git 서버에 접속하는 두 방식(https 와 ssh)을 이해하고, SSH 키 쌍(개인키·공개키)을 만들어 권한을 맞추고, 서버에 등록할 공개키를 구분하고, 원격 주소를 https 에서 ssh 형식으로 바꾸고, credential.helper 와 core.sshCommand 를 설정합니다. 실제 서버 없이 키 파일과 설정만으로 연습합니다.',
               'linux', 'Git', 15, 725, '🔑',
               [{"title": "SSH 공개키 만들기 (Pro Git)", "url": "https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key"}, {"title": "git-credential-store", "url": "https://git-scm.com/docs/git-credential-store"}], 2)
b.nt('SSH 키 쌍 만들기', '`/tmp/lab/id_demo` 라는 이름으로 **ed25519 방식의 SSH 키 쌍**을 만드세요. 비밀번호(passphrase)는 비워 둡니다. 개인키 `id_demo` 와 공개키 `id_demo.pub` 두 파일이 생겨야 합니다.',
     '`ssh-keygen -t 방식 -f 파일경로 -N 비밀번호` 형태입니다. `-N \'\'` 는 비밀번호 없음입니다.',
     "ssh-keygen -q -t ed25519 -N '' -f /tmp/lab/id_demo\nls -l /tmp/lab\n\n# ssh-keygen 은 개인키(id_demo)와 공개키(id_demo.pub) 한 쌍을 만든다. 개인키는 내 컴퓨터에만 둔다",
     LAB, [chk('개인키가 있다', '[ -f /tmp/lab/id_demo ]'), chk('공개키가 있다', '[ -f /tmp/lab/id_demo.pub ]'), chk('ed25519 방식이다', 'grep -q "^ssh-ed25519 " /tmp/lab/id_demo.pub')])
b.nt('개인키 권한을 600 으로', '개인키 파일 `/tmp/lab/id_demo` 의 권한이 너무 열려 있어(`644`), ssh 가 `UNPROTECTED PRIVATE KEY FILE!` 경고를 내며 키를 **거부**합니다. **나만 읽고 쓸 수 있는 권한**으로 바꾸세요.',
     '`chmod` 로 권한을 숫자로 줍니다. 읽기=4, 쓰기=2, 실행=1 을 더해 소유자/그룹/기타 순서로 적습니다. 소유자만 읽기·쓰기이면 어떤 숫자일까요?',
     "chmod 600 /tmp/lab/id_demo\nstat -c '%a' /tmp/lab/id_demo\n\n# 개인키는 소유자만 읽을 수 있어야 한다(600). 다른 사람이 읽을 수 있으면 ssh 가 키 사용을 거부한다",
     KEY + " && chmod 644 /tmp/lab/id_demo", [chk('권한이 600 이다', '[ "$(stat -c %a /tmp/lab/id_demo)" = 600 ]'), chk('공개키는 그대로다', '[ -f /tmp/lab/id_demo.pub ]')])
b.nt('서버에 등록할 공개키 꺼내기', 'Git 서비스에 SSH 키를 등록할 때 붙여 넣는 것은 **공개키** 입니다. 공개키 파일의 내용을 `/tmp/lab/register.txt` 에 저장하세요. (개인키는 절대 넣지 않습니다)',
     '`.pub` 으로 끝나는 파일입니다. `cat 파일 > 새파일` 로 복사할 수 있어요.',
     "cat /tmp/lab/id_demo.pub > /tmp/lab/register.txt\ncat /tmp/lab/register.txt\n\n# 서버에는 공개키(.pub)만 등록한다. 개인키가 유출되면 누구나 내 계정으로 접속할 수 있다",
     KEY, [chk('공개키와 내용이 같다', 'cmp -s /tmp/lab/register.txt /tmp/lab/id_demo.pub'), chk('개인키 내용이 섞이지 않았다', '! grep -q "PRIVATE KEY" /tmp/lab/register.txt')])
b.nt('원격 주소를 https 에서 ssh 로', '`/tmp/lab/proj` 저장소의 `origin` 이 `https://git.example.com/team/app.git` 입니다. SSH 키로 접속하도록 **ssh 형식 주소 `git@git.example.com:team/app.git`** 로 바꾸세요.',
     '`git remote set-url 원격이름 새주소` 로 바꿉니다. 확인은 `git remote -v`.',
     "cd /tmp/lab/proj\ngit remote set-url origin git@git.example.com:team/app.git\ngit remote -v\n\n# https 는 토큰·비밀번호로, ssh 는 키로 인증한다. 주소 형식도 다르다 (https://호스트/경로 ↔ git@호스트:경로)",
     LAB + " && git init -q proj && cd proj && git remote add origin https://git.example.com/team/app.git",
     [chk('origin 이 ssh 주소다', '[ "$(git -C /tmp/lab/proj remote get-url origin)" = git@git.example.com:team/app.git ]')])
b.nt('자격 증명을 저장하는 도우미 켜기', 'https 주소를 쓸 때는 push 할 때마다 사용자 이름과 토큰을 물어봅니다. 한 번 입력한 값을 **파일에 저장해 다시 묻지 않게** 하는 `credential.helper` 를 `store` 로 전역(`--global`) 설정하세요.',
     '`git config --global credential.helper 값` 입니다. `store` 는 평문 파일(~/.git-credentials)에 저장합니다.',
     "git config --global credential.helper store\ngit config --global credential.helper\n\n# store 는 ~/.git-credentials 에 평문 저장(공용 PC 에서는 위험). cache 는 메모리에 잠시만 둔다",
     LAB, [chk('credential.helper 가 store 다', '[ "$(git config --global credential.helper)" = store ]')])
b.nt('이 저장소만 특정 키로 접속하기', '`/tmp/lab/proj` 저장소만 **`/tmp/lab/id_demo` 키**로 ssh 접속하게 만드세요. 저장소 설정 `core.sshCommand` 에 `ssh -i /tmp/lab/id_demo` 를 넣습니다. (전역이 아니라 이 저장소에만 적용)',
     '`git config core.sshCommand "ssh -i 키경로"` 를 저장소 안에서 실행합니다. `--global` 을 쓰지 마세요.',
     "cd /tmp/lab/proj\ngit config core.sshCommand 'ssh -i /tmp/lab/id_demo'\ngit config core.sshCommand\n\n# 계정이 여러 개일 때 저장소마다 다른 키를 쓰게 한다. -i 는 사용할 개인키 파일을 지정한다",
     KEY + " && git init -q proj", [chk('저장소 설정에 값이 있다', '[ "$(git -C /tmp/lab/proj config --local core.sshCommand)" = "ssh -i /tmp/lab/id_demo" ]'), chk('전역에는 설정하지 않았다', '[ -z "$(git config --global core.sshCommand)" ]')])
b.choice('Permission denied (publickey)', '`git push` 가 `Permission denied (publickey).` 로 실패했습니다. 이 오류의 **가장 흔한 원인**은 무엇인가요?', '이 방식은 서버가 "내가 아는 공개키인가"를 보고 허락합니다.',
         ['서버에 내 공개키가 등록되어 있지 않거나, 다른 키로 접속하고 있다', '커밋 메시지가 너무 길다', '브랜치 이름에 한글이 들어 있다', '저장소 크기가 너무 크다'], 0,
         'ssh 인증은 서버에 등록된 공개키와 내가 가진 개인키가 짝이 맞는지로 판단합니다. 공개키를 등록하지 않았거나 다른 키 파일이 쓰이면 publickey 거부가 납니다. 나머지는 인증과 관계없습니다.')
b.fill('서버에 등록하는 파일', '서버에 등록할 **공개키 파일**을 출력하는 명령입니다. 빈칸을 채우세요. (키 파일 이름은 `id_ed25519`)', '공개키 파일에는 특별한 확장자가 붙습니다.',
       'cat ~/.ssh/id_ed25519{0}', ['.pub', '.key', '.pem', '.public'], [0],
       'ssh-keygen 은 개인키 `id_ed25519` 와 공개키 `id_ed25519.pub` 를 만듭니다. 서버에는 `.pub` 의 내용만 등록합니다.')
b.order('SSH 키로 첫 push 까지', '새 컴퓨터에서 SSH 키로 Git 서버에 **처음 push** 하기까지의 순서대로 놓으세요. (원격 주소는 이미 ssh 형식)', '서버가 나를 알아보려면 무엇이 먼저 있어야 하는지 생각해 보세요. push 는 접속이 확인된 뒤의 마지막 단계입니다.',
        ['git push', '공개키(.pub)를 Git 서비스에 등록', 'ssh-keygen 으로 키 쌍 만들기', 'ssh -T 로 접속 확인'], [2, 1, 3, 0],
        '키 쌍을 만든 뒤 공개키를 서버에 등록해야 서버가 나를 알아봅니다. ssh 로 접속이 되는지 확인한 다음 push 합니다. (`ssh -T git@호스트` 는 접속·인증만 확인하는 명령입니다.)')
SETS.append((b, '2026-11-19_gap_pilot_set504.sql'))

if __name__ == '__main__':
    for sb, mig in SETS:
        emit(sb, mig)
