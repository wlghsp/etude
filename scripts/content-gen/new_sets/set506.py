# 세트 506: 쿼리 튜닝 (2) 슬로우 쿼리 개선 실전. docs/specs/spec_gap_set506.md
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from gen_pilot_sets import *

# 주문 20만 건. 고객 id 는 1~1800 에 고르게 퍼진다 (고객 2000명 중 200명은 주문이 없다)
def SHOP(idx_c=True, idx_coupon=False):
    keys = ', KEY idx_c (customer_id)' if idx_c else ''
    keys += ', KEY idx_coupon (coupon)' if idx_coupon else ''
    return (DBUP + """; mariadb -e 'DROP DATABASE IF EXISTS shop; CREATE DATABASE shop; USE shop;
CREATE TABLE customers (id INT PRIMARY KEY, name VARCHAR(20)) ENGINE=InnoDB;
INSERT INTO customers SELECT seq, CONCAT("user", seq) FROM seq_1_to_2000;
CREATE TABLE orders (id INT AUTO_INCREMENT PRIMARY KEY, customer_id INT, status VARCHAR(10), amount INT, created_at DATETIME, coupon VARCHAR(10)""" + keys + """) ENGINE=InnoDB;
INSERT INTO orders (customer_id,status,amount,created_at,coupon) SELECT 1+MOD(seq*7919,1800), ELT(1+MOD(seq,4),"PAID","SHIPPED","CANCEL","DONE"), 1000+MOD(seq,5000), DATE_ADD("2026-01-01", INTERVAL MOD(seq,300) DAY)+INTERVAL MOD(seq,86400) SECOND, IF(MOD(seq,50)=0,CONCAT("C",MOD(seq,7)),NULL) FROM seq_1_to_200000;'; """ + CLEAN)

# 어떤 열 개수를 처음 r_rows 로 읽는다 (ANALYZE FORMAT=JSON 출력에서 첫 번째 r_rows)
def RROWS(q): return f'mariadb shop -e "ANALYZE FORMAT=JSON {q}" | grep -o \'"r_rows": [0-9]*\' | head -1 | grep -o "[0-9]*$"'
def RFILE(f): return f"grep -o '\"r_rows\": [0-9]*' {f} | head -1 | grep -o '[0-9]*$'"

# 세트 setup: 슬로우 로그에 후보를 남겨 둔다 (모든 쿼리를 기록)
SLOWLOG = ("""; mariadb -e 'SET GLOBAL slow_query_log_file="/tmp/slow.log"; SET GLOBAL long_query_time=0; SET GLOBAL slow_query_log=1'; """
           """for i in 1 2 3 4 5; do mariadb shop -e "SELECT COUNT(*) FROM orders WHERE amount + 0 = $((2000 + i))" >/dev/null; done; """
           """for i in $(seq 1 30); do mariadb shop -e "SELECT * FROM orders WHERE id = $((i * 100))" >/dev/null; done; """
           """for i in $(seq 1 10); do mariadb shop -e "SELECT * FROM customers WHERE id = $i" >/dev/null; done; """
           """mariadb -e 'SET GLOBAL slow_query_log=0; SET GLOBAL long_query_time=10'""")

b = SetBuilder(506, '쿼리 튜닝 (2) 슬로우 쿼리 개선 실전: 후보 찾기, 전후 측정, 복합 인덱스, OR, JOIN, 키셋 페이징',
               '느린 쿼리를 찾아 실제로 고치는 흐름을 터미널에서 익힙니다. 슬로우 로그로 후보를 뽑고, ANALYZE 로 고치기 전·후의 실제 읽은 행 수와 시간을 재서 비교하며, 인덱스 추가, OR 조건 개선, 서브쿼리를 JOIN 으로 바꾸기, OFFSET 페이징을 키셋 페이징으로 바꾸기, ANALYZE TABLE 로 통계 갱신까지 직접 해 봅니다. EXPLAIN 열 읽는 법은 앞 세트에서 배운 것으로 전제합니다.',
               'linux-db', '데이터베이스', 46, 727, '🐢',
               [{"title": "ANALYZE 문", "url": "https://mariadb.com/kb/en/analyze-statement/"}, {"title": "슬로우 쿼리 로그", "url": "https://mariadb.com/kb/en/slow-query-log-overview/"}, {"title": "ANALYZE TABLE", "url": "https://mariadb.com/kb/en/analyze-table/"}], 0)

b.nt('슬로우 로그를 켜고 느린 쿼리 남기기',
     '`shop` 데이터베이스에 주문(`orders`) 20만 건이 있습니다. 느린 쿼리를 찾으려면 먼저 슬로우 로그가 켜져 있어야 합니다. 이번 실습에서는 **모든 쿼리가 기록되도록** 서버 설정을 바꾸세요.\n\n- 로그 파일: `/tmp/my_slow.log`\n- 기준 시간: 0초 (모든 쿼리 기록)\n- 로그 켜기\n\n설정한 **뒤에** 새로 접속해서 `SELECT COUNT(*) FROM orders WHERE amount + 0 = 2500;` 을 한 번 실행하면 그 쿼리가 파일에 남아야 합니다. (`SET GLOBAL` 로 바꾼 기준 시간은 **새로 연결한 세션**부터 적용됩니다.)',
     '변수 이름은 `slow_query_log`, `slow_query_log_file`, `long_query_time` 입니다. `SET GLOBAL 변수=값;` 으로 바꾸고, 쿼리는 `mariadb shop -e ...` 처럼 새 접속으로 실행합니다.',
     "mariadb -e 'SET GLOBAL slow_query_log_file=\"/tmp/my_slow.log\"; SET GLOBAL long_query_time=0; SET GLOBAL slow_query_log=1'\nmariadb shop -e 'SELECT COUNT(*) FROM orders WHERE amount + 0 = 2500'\ncat /tmp/my_slow.log\n\n# long_query_time=0 이면 모든 쿼리가 기록된다. 운영에서는 1~2초처럼 현실적인 값을 쓰고, 조사가 끝나면 끈다",
     SHOP(), [chk('슬로우 로그가 켜져 있다', '[ "$(mariadb -N -e "SELECT @@global.slow_query_log")" = 1 ]'), chk('로그 파일 위치가 맞다', '[ "$(mariadb -N -e "SELECT @@global.slow_query_log_file")" = /tmp/my_slow.log ]'),
              chk('로그에 쿼리가 남았다', 'grep -q "amount + 0 = 2500" /tmp/my_slow.log')])

b.nt('로그를 요약해 가장 오래 걸리는 후보 찾기',
     '슬로우 로그 `/tmp/slow.log` 에 쿼리 기록이 수십 건 쌓여 있습니다. 한 줄씩 읽을 수 없으니 **`mariadb-dumpslow`** 로 같은 모양의 쿼리끼리 묶어 요약하세요. **총 걸린 시간이 가장 큰 쿼리 하나**만 `/tmp/top.txt` 에 저장하면 됩니다.\n\n- `-s 정렬기준` : `t` 는 총 시간, `c` 는 실행 횟수, `at` 은 평균 시간(기본값)\n- `-t 개수` : 위에서 몇 개만 보여 줄지',
     '`mariadb-dumpslow -s 기준 -t 개수 로그파일` 형태입니다. 총 시간 기준 상위 1개를 뽑아 `>` 로 저장하세요. 출력에서 `N` 은 숫자, `S` 는 문자열 값을 가린 표시입니다.',
     "mariadb-dumpslow -s t -t 1 /tmp/slow.log > /tmp/top.txt\ncat /tmp/top.txt\n\n# 숫자·문자열 값은 N·S 로 가려 같은 모양끼리 묶는다. 총 시간이 큰 것이 서버를 가장 오래 붙잡은 후보다",
     SHOP() + SLOWLOG, [chk('파일이 있다', '[ -s /tmp/top.txt ]'), chk('후보가 amount 조건 쿼리다', 'grep -q "amount" /tmp/top.txt'), chk('기본키 조회 쿼리가 아니다', '! grep -q "WHERE id" /tmp/top.txt')])

b.nt('ANALYZE 로 고치기 전 실제 값 재기',
     '후보 쿼리 `SELECT * FROM orders WHERE customer_id = 777` 이 느립니다. 고치기 전에 **지금 상태를 숫자로 남겨** 두어야 나중에 좋아졌는지 비교할 수 있습니다.\n\n`EXPLAIN` 은 실행하지 않고 **예상** 값을 보여 주지만, **`ANALYZE`** 는 쿼리를 **실제로 실행하고** 실제로 읽은 행 수(`r_rows`)와 걸린 시간(`r_total_time_ms`)을 알려 줍니다. `ANALYZE FORMAT=JSON SELECT ...` 의 결과를 `/tmp/before.txt` 에 저장하세요.',
     '`mariadb shop -e "ANALYZE FORMAT=JSON SELECT ..."` 를 실행하고 `>` 로 저장합니다. 결과의 `access_type` 과 `r_rows` 를 확인해 보세요. (`r_` 로 시작하는 값이 실제로 잰 값입니다.)',
     "mariadb shop -e 'ANALYZE FORMAT=JSON SELECT * FROM orders WHERE customer_id = 777' > /tmp/before.txt\ncat /tmp/before.txt\n\n# 인덱스가 없어 access_type 이 ALL(전체 스캔)이고 r_rows 가 20만이다. 고치기 전 기준 값으로 남겨 둔다",
     SHOP(idx_c=False), [chk('결과 파일이 있다', '[ -s /tmp/before.txt ]'), chk('실제 걸린 시간이 있다', 'grep -q r_total_time_ms /tmp/before.txt'), chk('전체 스캔 상태를 담았다', 'grep -q \'"access_type": "ALL"\' /tmp/before.txt')])

b.nt('인덱스 추가 후 다시 재서 비교하기',
     '앞 단계에서 잰 **고치기 전 결과**가 `/tmp/before.txt` 에 있습니다. `orders` 에 **`customer_id` 인덱스**를 만들고, 같은 쿼리 `SELECT * FROM orders WHERE customer_id = 777` 을 `ANALYZE FORMAT=JSON` 으로 다시 재서 `/tmp/after.txt` 에 저장하세요. `after.txt` 의 `r_rows` 는 `before.txt` 보다 크게 줄어야 합니다.',
     '`CREATE INDEX 이름 ON 테이블(열);` 로 만듭니다. 만든 뒤 **같은 쿼리**를 같은 방식으로 재고, 두 파일의 `r_rows` 를 `grep r_rows` 로 비교해 보세요.',
     "mariadb shop -e 'CREATE INDEX idx_customer ON orders(customer_id)'\nmariadb shop -e 'ANALYZE FORMAT=JSON SELECT * FROM orders WHERE customer_id = 777' > /tmp/after.txt\ngrep r_rows /tmp/before.txt /tmp/after.txt\n\n# 같은 쿼리를 같은 방법으로 전후 비교한다. 전체 스캔(r_rows 20만)이 인덱스 조회(r_rows 100 안팎)로 바뀐다",
     SHOP(idx_c=False) + "; mariadb shop -e 'ANALYZE FORMAT=JSON SELECT * FROM orders WHERE customer_id = 777' > /tmp/before.txt",
     [chk('customer_id 인덱스가 있다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=\'shop\' AND table_name=\'orders\' AND column_name=\'customer_id\' AND seq_in_index=1")" -ge 1 ]'),
      chk('after.txt 가 인덱스를 탔다', 'grep -q \'"access_type": "ref"\' /tmp/after.txt'), chk('읽은 행이 1000 미만이다', f'[ "$({RFILE("/tmp/after.txt")})" -lt 1000 ]')])

b.nt('조건이 둘이면 복합 인덱스로',
     '`SELECT id FROM orders WHERE status = \'PAID\' AND created_at >= \'2026-09-01\'` 가 주문 테이블을 거의 다 읽습니다. 이 쿼리를 위한 **복합 인덱스**를 만들어 읽는 행 수를 **15000 행 미만**으로 줄이세요. 열 순서는 앞 세트에서 배운 대로 고르세요.\n\n(같다(`=`) 조건 열을 앞에, 범위(`>=`) 조건 열을 뒤에 두는 순서를 떠올려 보세요.)',
     '`CREATE INDEX 이름 ON orders(열1, 열2);` 입니다. 만든 뒤 `ANALYZE FORMAT=JSON` 으로 같은 쿼리를 재서 `r_rows` 가 줄었는지 확인하세요.',
     "mariadb shop -e 'CREATE INDEX idx_status_created ON orders(status, created_at)'\nmariadb shop -e \"ANALYZE FORMAT=JSON SELECT id FROM orders WHERE status='PAID' AND created_at >= '2026-09-01'\" | grep r_rows\n\n# = 조건 열(status)을 앞에, 범위 조건 열(created_at)을 뒤에 둔 복합 인덱스. 한 번에 좁혀 들어간다",
     SHOP(), [chk('status, created_at 순서의 복합 인덱스가 있다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.statistics a JOIN information_schema.statistics b ON a.table_schema=b.table_schema AND a.table_name=b.table_name AND a.index_name=b.index_name WHERE a.table_schema=\'shop\' AND a.table_name=\'orders\' AND a.column_name=\'status\' AND a.seq_in_index=1 AND b.column_name=\'created_at\' AND b.seq_in_index=2")" -ge 1 ]'),
              chk('읽는 행이 15000 미만이다', '[ "$(' + RROWS("SELECT id FROM orders WHERE status=\'PAID\' AND created_at >= \'2026-09-01\'") + ')" -lt 15000 ]')])

b.nt('OR 의 한쪽에 인덱스가 없을 때',
     '`SELECT * FROM orders WHERE customer_id = 5 OR coupon = \'C3\'` 가 느립니다. `customer_id` 에는 인덱스가 있지만 `coupon` 에는 없습니다. `OR` 는 **양쪽 조건 모두** 인덱스로 찾을 수 있어야 인덱스를 쓸 수 있어서, 한쪽이 없으면 테이블 전체를 읽게 됩니다.\n\n빠지는 인덱스를 만들어 이 쿼리가 읽는 행을 **2000 행 미만**으로 줄이세요. (인덱스가 양쪽에 있으면 MariaDB 가 두 결과를 합치는 `index_merge` 로 처리합니다. 조건마다 `UNION` 으로 나눠 쓴 것과 같은 효과입니다.)',
     '느린 쪽 조건의 열이 어느 것인지 보세요. 그 열에 `CREATE INDEX` 를 하고, `ANALYZE FORMAT=JSON` 으로 `r_rows` 를 확인합니다.',
     "mariadb shop -e 'CREATE INDEX idx_coupon ON orders(coupon)'\nmariadb shop -e \"ANALYZE FORMAT=JSON SELECT * FROM orders WHERE customer_id=5 OR coupon='C3'\" | grep r_rows\n\n# OR 는 양쪽 다 인덱스가 있어야 한다. 양쪽에 있으면 index_merge 로 각각 찾아 합친다",
     SHOP(), [chk('coupon 인덱스가 있다', '[ "$(mariadb -N -e "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=\'shop\' AND table_name=\'orders\' AND column_name=\'coupon\' AND seq_in_index=1")" -ge 1 ]'),
              chk('읽는 행이 2000 미만이다', '[ "$(' + RROWS("SELECT * FROM orders WHERE customer_id=5 OR coupon=\'C3\'") + ')" -lt 2000 ]')])

b.nt('상관 서브쿼리를 JOIN 으로 바꾸기',
     '`/tmp/slow.sql` 은 **자기 고객의 평균 금액보다 큰 주문 수**를 세는 쿼리입니다. 주문 한 건마다 서브쿼리가 다시 실행돼(상관 서브쿼리) 10초 넘게 걸립니다. (직접 실행하지 말고 파일 내용만 보세요.)\n\n같은 결과가 나오도록, **고객별 평균을 한 번만 계산해 JOIN** 하는 쿼리로 바꿔 `/tmp/fast.sql` 에 저장하고, 실행 결과(숫자 하나)를 `/tmp/cnt.txt` 에 저장하세요.',
     '`FROM orders o JOIN (SELECT customer_id, AVG(amount) av FROM orders GROUP BY customer_id) a ON a.customer_id = o.customer_id WHERE o.amount > a.av` 의 뼈대를 쓰되, 파일 내용에 맞게 `COUNT(*)` 로 세세요. `mariadb -N shop < 파일` 로 실행합니다.',
     "cat > /tmp/fast.sql <<'SQL'\nSELECT COUNT(*) FROM orders o\nJOIN (SELECT customer_id, AVG(amount) av FROM orders GROUP BY customer_id) a ON a.customer_id = o.customer_id\nWHERE o.amount > a.av;\nSQL\nmariadb -N shop < /tmp/fast.sql > /tmp/cnt.txt\ncat /tmp/cnt.txt\n\n# 고객별 평균을 GROUP BY 로 한 번만 구해 두고 JOIN 한다. 행마다 서브쿼리를 되풀이하지 않는다",
     SHOP() + """; printf 'SELECT COUNT(*) FROM orders o WHERE amount > (SELECT AVG(amount) FROM orders o2 WHERE o2.customer_id = o.customer_id);\\n' > /tmp/slow.sql""",
     [chk('fast.sql 이 JOIN 을 쓴다', 'grep -qi "join" /tmp/fast.sql'), chk('상관 서브쿼리가 아니다', '! grep -qiE "amount *> *\\( *select" /tmp/fast.sql'),
      chk('5초 안에 끝나고 결과가 같다', '[ "$(timeout 5 mariadb -N shop < /tmp/fast.sql)" = 99600 ]'), chk('cnt.txt 에 결과가 있다', '[ "$(cat /tmp/cnt.txt)" = 99600 ]')])

b.nt('OFFSET 페이징을 키셋 페이징으로',
     '게시판처럼 `ORDER BY id LIMIT 20 OFFSET 150000` 으로 페이지를 넘기면, 건너뛸 15만 행도 **전부 읽고 버려서** 뒤 페이지로 갈수록 느려집니다. 지금 화면의 마지막 행 id 가 **150020** 입니다.\n\n`OFFSET` 대신 **"마지막으로 본 id 보다 큰 것"** 을 조건으로 쓰는 **키셋(keyset) 방식**으로 다음 20건의 id 만 가져오는 쿼리를 `/tmp/next.sql` 에 쓰고, 실행 결과를 `/tmp/page.txt` 에 저장하세요. (정렬은 `id` 오름차순)',
     '`WHERE id > 마지막id ORDER BY id LIMIT 20` 형태입니다. `OFFSET` 은 쓰지 않습니다. `mariadb -N shop < /tmp/next.sql > /tmp/page.txt` 로 실행합니다.',
     "cat > /tmp/next.sql <<'SQL'\nSELECT id FROM orders WHERE id > 150020 ORDER BY id LIMIT 20;\nSQL\nmariadb -N shop < /tmp/next.sql > /tmp/page.txt\nhead -2 /tmp/page.txt; wc -l < /tmp/page.txt\n\n# 기본키 인덱스에서 150020 바로 뒤부터 20행만 읽는다. 건너뛸 행을 읽지 않으니 몇 번째 페이지든 일정하게 빠르다",
     SHOP(), [chk('OFFSET 을 쓰지 않았다', '[ -s /tmp/next.sql ] && ! grep -qi offset /tmp/next.sql'), chk('20건이다', '[ "$(wc -l < /tmp/page.txt)" = 20 ]'),
              chk('150021 부터 150040 까지다', '[ "$(head -1 /tmp/page.txt)" = 150021 ] && [ "$(tail -1 /tmp/page.txt)" = 150040 ]')])

b.nt('통계가 낡았을 때 ANALYZE TABLE',
     '`st.big` 테이블은 처음 100행일 때 통계를 만들어 두고 **자동 갱신이 꺼진 채** 10만 행을 더 넣은 상태입니다. 옵티마이저는 이 **통계**를 보고 실행 계획을 세우는데, 통계가 실제와 크게 다르면 엉뚱한 계획을 고를 수 있습니다. 저장된 통계의 행 수는 `mysql.innodb_table_stats` 의 `n_rows` 에서 볼 수 있습니다.\n\n통계를 **갱신**하고, 갱신된 `n_rows` 값만 `/tmp/nrows.txt` 에 저장하세요.',
     '`ANALYZE TABLE 데이터베이스.테이블;` 이 통계를 다시 계산합니다. 그 뒤 `SELECT n_rows FROM mysql.innodb_table_stats WHERE database_name=... AND table_name=...` 를 `mariadb -N -e` 로 조회합니다.',
     "mariadb -e 'ANALYZE TABLE st.big'\nmariadb -N -e \"SELECT n_rows FROM mysql.innodb_table_stats WHERE database_name='st' AND table_name='big'\" > /tmp/nrows.txt\ncat /tmp/nrows.txt\n\n# 데이터가 크게 바뀐 뒤 통계가 낡았다고 의심되면 ANALYZE TABLE. 실행 계획이 갑자기 이상해졌을 때 점검 항목 중 하나다",
     DBUP + """; mariadb -e 'DROP DATABASE IF EXISTS st; CREATE DATABASE st; USE st; CREATE TABLE big (id INT AUTO_INCREMENT PRIMARY KEY, v INT) ENGINE=InnoDB STATS_PERSISTENT=1 STATS_AUTO_RECALC=0; INSERT INTO big(v) SELECT seq FROM seq_1_to_100; ANALYZE TABLE big; INSERT INTO big(v) SELECT seq FROM seq_1_to_100000;'; """ + CLEAN,
     [chk('저장된 통계가 갱신됐다', '[ "$(mariadb -N -e "SELECT n_rows FROM mysql.innodb_table_stats WHERE database_name=\'st\' AND table_name=\'big\'")" -gt 50000 ]'), chk('nrows.txt 에 갱신된 값이 있다', '[ "$(cat /tmp/nrows.txt)" -gt 50000 ]')])

b.choice('OR 를 UNION 으로 나눌 때', '`WHERE customer_id = 5 OR coupon = \'C3\'` 를 `SELECT ... WHERE customer_id = 5` 와 `SELECT ... WHERE coupon = \'C3\'` 두 쿼리로 나눠 합치려 합니다. 두 조건에 **모두 해당하는 주문이 한 번만** 나와야 합니다. 어떻게 합쳐야 할까요?',
         '`UNION` 과 `UNION ALL` 의 차이를 떠올려 보세요. 겹치는 행을 어떻게 처리하나요?',
         ['`UNION` 으로 합친다 (중복 행을 제거한다)', '`UNION ALL` 로 합친다 (중복 행도 모두 남긴다)', '`JOIN` 으로 두 쿼리를 이어 붙인다', '`UNION` 대신 `OFFSET` 으로 나눠 읽는다'], 0,
         '`UNION` 은 합치면서 중복 행을 제거하고, `UNION ALL` 은 중복을 그대로 둡니다. 두 조건에 모두 해당하는 행은 두 쿼리에 모두 잡히므로 `UNION` 이 한 번만 보여 줍니다. 두 조건이 겹치지 않음이 확실할 때는 중복 제거 비용이 없는 `UNION ALL` 이 더 빠릅니다.')

b.fill('키셋 페이징의 조건', '마지막으로 본 id 가 150020 일 때, **그 다음 행부터** 20건을 가져오는 키셋 쿼리입니다. 빈칸을 채우세요.', '마지막으로 본 행은 이미 화면에 있습니다. 다음 페이지에 또 나오면 안 됩니다.',
       'SELECT id FROM orders WHERE id {0} 150020 ORDER BY id LIMIT 20;', ['>', '>=', '<', '<>'], [0],
       '`>` 는 150020 보다 큰 것만 가져와 다음 행부터 시작합니다. `>=` 는 마지막으로 본 150020 이 다음 페이지에 또 나오고, `<` 는 이전 방향이며, `<>` 는 정렬 방향과 무관하게 모든 행을 가져옵니다.')

# 정답 순서: 후보 → 전 측정 → 수정 → 후 측정 → 결과 확인
b.order('쿼리 튜닝의 순서', '느린 쿼리를 하나 개선하는 올바른 순서로 카드를 놓으세요.', '먼저 무엇을 고칠지 정하고, 고치기 전에 숫자를 남겨야 합니다. 고친 뒤에는 같은 방법으로 다시 재서 비교합니다.',
        ['같은 쿼리를 다시 ANALYZE 로 재서 전후를 비교한다', '원인 하나(인덱스 추가나 쿼리 재작성)만 고친다', '슬로우 로그에서 후보 쿼리를 고른다', '결과가 이전과 같은지 확인한다', 'ANALYZE 로 고치기 전 읽은 행 수와 시간을 잰다'], [2, 4, 1, 0, 3],
        '슬로우 로그로 후보를 고르고, 고치기 전 기준 값을 ANALYZE 로 잽니다. 한 번에 원인 하나만 고쳐야 무엇이 효과가 있었는지 알 수 있고, 같은 방법으로 다시 재어 전후를 비교합니다. 마지막으로 결과가 이전과 같은지 확인해야 합니다. 빠르지만 틀린 쿼리는 개선이 아닙니다.')

if __name__ == '__main__':
    preview(b)
