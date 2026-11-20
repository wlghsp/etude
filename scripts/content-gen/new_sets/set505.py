# 세트 505: 쿼리 튜닝 (1) EXPLAIN 읽기와 인덱스를 못 타는 이유. 명세: docs/specs/spec_gap_set505.md
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from gen_pilot_sets import *

TABLE = ('CREATE TABLE orders (id INT PRIMARY KEY, customer_id INT NOT NULL, phone VARCHAR(20) NOT NULL, email VARCHAR(60) NOT NULL, status VARCHAR(10) NOT NULL, amount INT NOT NULL, created_at DATETIME NOT NULL);'
         ' INSERT INTO orders SELECT seq, seq%500+1, CONCAT("010", LPAD(seq,8,"0")), CONCAT("user",seq,"@example.com"), ELT(seq%4+1,"paid","ready","shipped","done"), 1000+seq%90*100, DATE_ADD("2026-01-01", INTERVAL seq%300 DAY) FROM seq_1_to_20000;')


def SETUP(idx, files=''):
    """orders 20,000행 테이블. idx 는 이 문제에서 미리 걸어 둘 인덱스 SQL, files 는 /tmp 에 미리 둘 파일을 만드는 셸 명령."""
    return DBUP + "; mariadb -e 'DROP DATABASE IF EXISTS shop; CREATE DATABASE shop; USE shop; " + TABLE + ' ' + idx + " ANALYZE TABLE orders;' >/dev/null; " + CLEAN + (('; ' + files) if files else '')


EX = lambda q: f'mariadb -N shop -e "EXPLAIN {q}"'  # 한 줄짜리 EXPLAIN 결과 (제목 줄 없음). 열: 1 id,2 select_type,3 table,4 type,5 possible_keys,6 key,7 key_len,8 ref,9 rows,10 Extra
SQLFILE = lambda f: f'mariadb -N shop -e "EXPLAIN $(cat {f})"'

b = SetBuilder(505, '쿼리 튜닝 (1) EXPLAIN 읽기와 인덱스를 못 타는 이유',
               'EXPLAIN 결과의 type·key·rows·Extra 를 읽고, 인덱스가 있는데도 못 타는 흔한 이유(컬럼에 함수 씌우기, 문자열 컬럼을 숫자와 비교, 컬럼에 계산, 복합 인덱스의 선두 컬럼 빼먹기)를 직접 재현해 고칩니다. 커버링 인덱스(Using index), Using filesort, Using temporary 를 인덱스로 없애는 것까지 실습합니다.',
               'linux-db', '데이터베이스', 46, 726, '🔍',
               [{"title": "MariaDB EXPLAIN", "url": "https://mariadb.com/kb/en/explain/"}, {"title": "MariaDB 인덱스 사용 (ORDER BY 최적화)", "url": "https://mariadb.com/kb/en/order-by-optimization/"}], 1)

# 1 EXPLAIN 열 읽기
b.nt('EXPLAIN 표에서 key 와 rows 읽기',
     '**배경** — `shop` 데이터베이스의 `orders` 테이블(주문 20,000건)을 씁니다. 컬럼은 `id`(기본 키), `customer_id`(고객 번호, 1~500), `phone`(문자열), `email`, `status`, `amount`, `created_at` 이고, `customer_id` 에는 `idx_cust` 인덱스가 걸려 있습니다.\n\n쿼리 앞에 `EXPLAIN` 을 붙이면 쿼리를 실행하지 않고 **실행 계획**을 표로 보여 줍니다. 읽을 열은 다음과 같습니다.\n- `type`: 행을 찾는 방식. `ALL` 은 테이블 전체 훑기(가장 느림), `ref`·`range` 는 인덱스로 찾기, `const` 는 기본 키로 딱 한 행\n- `key`: 실제로 쓴 인덱스 (`NULL` 이면 인덱스를 못 씀)\n- `rows`: 읽어야 할 것으로 **예상**하는 행 수\n- `Extra`: 추가 정보\n\n**문제** — `SELECT * FROM orders WHERE customer_id = 77` 을 `EXPLAIN` 해서, 표의 **`key` 값**을 `/tmp/key.txt` 에, **`rows` 값**을 `/tmp/rows.txt` 에 저장하세요. (값만, 한 줄씩)',
     '`mariadb shop -e "EXPLAIN ..."` 를 먼저 눈으로 확인하세요. 값만 뽑으려면 `-N` 으로 제목 줄을 없앤 뒤 `cut -f 열번호` 를 쓰거나, 표를 보고 직접 적어도 됩니다.',
     "mariadb shop -e 'EXPLAIN SELECT * FROM orders WHERE customer_id = 77'\nmariadb -N shop -e 'EXPLAIN SELECT * FROM orders WHERE customer_id = 77' | cut -f6 > /tmp/key.txt\nmariadb -N shop -e 'EXPLAIN SELECT * FROM orders WHERE customer_id = 77' | cut -f9 > /tmp/rows.txt\ncat /tmp/key.txt /tmp/rows.txt\n\n# key 는 실제로 쓴 인덱스(idx_cust), rows 는 읽을 예상 행 수. 전체 20,000행 중 40행만 읽으면 된다",
     SETUP('CREATE INDEX idx_cust ON orders (customer_id);'),
     [chk('key 값이 idx_cust 이다', '[ "$(cat /tmp/key.txt)" = idx_cust ]'),
      chk('rows 값이 EXPLAIN 의 rows 와 같다', '[ "$(cat /tmp/rows.txt)" = "$(' + EX('SELECT * FROM orders WHERE customer_id = 77') + ' | cut -f9)" ]')])

# 2 컬럼에 함수
b.nt('컬럼에 함수를 씌우면 인덱스를 못 탄다',
     '`created_at` 에는 `idx_created` 인덱스가 있습니다. 그런데 `/tmp/q2.sql` 의 쿼리는 **2026년 3월 주문 수**를 `YEAR(created_at) = 2026 AND MONTH(created_at) = 3` 으로 세서, `EXPLAIN` 하면 `type: ALL`, `key: NULL` 입니다. 인덱스는 **컬럼 값 그대로** 정렬되어 있어서, 컬럼에 함수를 씌운 값으로는 찾을 수 없기 때문입니다.\n\n`/tmp/q2.sql` 를 **같은 결과(3월 주문 수)를 내면서 `idx_created` 를 타도록** 고치세요. (컬럼은 그대로 두고 값 쪽을 날짜 범위로 바꿉니다)',
     '`created_at` 이 3월 1일 이상, 4월 1일 **미만**인 범위로 쓰면 컬럼은 그대로 남습니다. 파일은 `cat > /tmp/q2.sql <<\'SQL\' ... SQL` 로 다시 써도 됩니다.',
     "cat > /tmp/q2.sql <<'SQL'\nSELECT COUNT(*) FROM orders WHERE created_at >= '2026-03-01' AND created_at < '2026-04-01';\nSQL\nmariadb shop -e \"EXPLAIN $(cat /tmp/q2.sql)\"\nmariadb -N shop < /tmp/q2.sql\n\n# 컬럼에는 손대지 않고 값 쪽 범위로 바꾸면 인덱스(range)를 탄다. 함수를 씌우면 모든 행에 함수를 적용해야 해서 전체를 훑는다",
     SETUP('CREATE INDEX idx_created ON orders (created_at);',
           "printf 'SELECT COUNT(*) FROM orders WHERE YEAR(created_at) = 2026 AND MONTH(created_at) = 3;\\n' > /tmp/q2.sql"),
     [chk('YEAR() 를 더 쓰지 않는다', '! grep -qi "year(" /tmp/q2.sql'),
      chk('idx_created 를 탄다', SQLFILE('/tmp/q2.sql') + ' | grep -q idx_created'),
      chk('3월 주문 수가 그대로다', '[ "$(mariadb -N shop < /tmp/q2.sql)" = "$(mariadb -N shop -e \'SELECT COUNT(*) FROM orders WHERE YEAR(created_at)=2026 AND MONTH(created_at)=3\')" ]')])

# 3 형변환
b.nt('문자열 컬럼을 숫자와 비교하면 인덱스를 못 탄다',
     '`phone` 은 **문자열**(`VARCHAR`) 컬럼이고 `idx_phone` 인덱스가 있습니다. `/tmp/q3.sql`(`SELECT * FROM orders WHERE phone = 1000000077`)은 `WHERE phone = 1000000077` 처럼 **따옴표 없는 숫자**로 비교하는데, `EXPLAIN` 의 `possible_keys` 에는 `idx_phone` 이 보이지만 `key` 는 `NULL` 입니다. 문자열과 숫자를 비교하면 DB 가 **컬럼 쪽을 모두 숫자로 바꿔** 비교해서 인덱스를 못 쓰기 때문입니다.\n\n`/tmp/q3.sql` 을 고쳐 **전화번호 `01000000077` 인 주문**을 찾으면서 `idx_phone` 을 타게 하세요.',
     '문자열 컬럼과는 문자열(따옴표로 감싼 값)로 비교합니다. 앞의 `0` 이 있는 값 그대로 적어야 합니다.',
     "cat > /tmp/q3.sql <<'SQL'\nSELECT * FROM orders WHERE phone = '01000000077';\nSQL\nmariadb shop -e \"EXPLAIN $(cat /tmp/q3.sql)\"\nmariadb -N shop < /tmp/q3.sql | cut -f1\n\n# 컬럼 타입과 같은 타입으로 비교한다. 문자열 컬럼은 따옴표를 붙인 문자열로 비교해야 컬럼이 변환되지 않아 인덱스를 탄다",
     SETUP('CREATE INDEX idx_phone ON orders (phone);',
           "printf 'SELECT * FROM orders WHERE phone = 1000000077;\\n' > /tmp/q3.sql"),
     [chk('idx_phone 을 탄다', SQLFILE('/tmp/q3.sql') + ' | cut -f4,6 | grep -qx "ref	idx_phone"'),
      chk('id 77 을 찾는다', '[ "$(mariadb -N shop < /tmp/q3.sql | cut -f1)" = 77 ]')])

# 4 컬럼에 계산
b.nt('컬럼에 계산을 하면 인덱스를 못 탄다',
     '`/tmp/q4.sql` 은 **고객 번호 77** 의 주문을 `WHERE customer_id + 1 = 78` 로 셉니다. `customer_id` 에 `idx_cust` 가 있는데도 컬럼에 `+ 1` 계산을 해서 전체를 훑습니다.\n\n`/tmp/q4.sql` 을 같은 결과를 내면서 `idx_cust` 를 타도록 고치세요. 계산은 **컬럼 쪽이 아니라 값 쪽**으로 옮깁니다.',
     '`customer_id + 1 = 78` 의 양쪽에서 1 을 빼 보세요. 컬럼이 혼자 있는 쪽이 인덱스를 탑니다.',
     "cat > /tmp/q4.sql <<'SQL'\nSELECT * FROM orders WHERE customer_id = 77;\nSQL\nmariadb shop -e \"EXPLAIN $(cat /tmp/q4.sql)\"\nmariadb -N shop < /tmp/q4.sql | wc -l\n\n# 컬럼은 가공하지 않고, 값 쪽에 계산을 둔다 (customer_id = 78 - 1 도 같은 효과)",
     SETUP('CREATE INDEX idx_cust ON orders (customer_id);',
           "printf 'SELECT * FROM orders WHERE customer_id + 1 = 78;\\n' > /tmp/q4.sql"),
     [chk('idx_cust 를 탄다', SQLFILE('/tmp/q4.sql') + ' | cut -f4,6 | grep -qx "ref	idx_cust"'),
      chk('고객 77 의 주문 40건을 그대로 찾는다', '[ "$(mariadb -N shop < /tmp/q4.sql | wc -l)" = 40 ]')])

# 5 객관식
b.choice('인덱스를 못 타는 조건 고르기',
         '`orders` 에는 `customer_id`·`created_at`·`phone`(문자열) 각각에 인덱스가 있습니다. 다음 조건 중 **인덱스를 탈 수 없는 것**은 무엇일까요?',
         '앞 문제에서 본 이유를 떠올려 보세요. 컬럼 자체가 가공되었는지를 봅니다.',
         ["WHERE DATE(created_at) = '2026-03-05'", "WHERE customer_id = 77", "WHERE created_at = '2026-03-05 00:00:00'", "WHERE phone = '01000000077'"], 0,
         "`DATE(created_at)` 는 컬럼에 함수를 씌운 것이라 인덱스를 쓸 수 없습니다(`created_at >= '2026-03-05' AND created_at < '2026-03-06'` 로 바꾸면 탑니다). 나머지는 컬럼을 그대로 두고 같은 타입의 값과 비교하므로 인덱스를 탑니다.")

# 6 복합 인덱스 선두
b.nt('복합 인덱스는 선두 컬럼부터 쓴다',
     '지금 `orders` 에는 `(customer_id, created_at)` 두 컬럼을 **이 순서로** 묶은 복합 인덱스 `idx_cust_created` 만 있습니다. `/tmp/q6.sql` 은 고객 번호 없이 **`created_at` 만으로** 조회합니다. `EXPLAIN` 하면 `key: NULL` 입니다. 복합 인덱스는 **맨 앞(선두) 컬럼부터** 순서대로 써야 하고, 선두 컬럼을 건너뛰면 쓸 수 없습니다.\n\n`created_at` **하나만** 건 인덱스 `idx_created` 를 추가해 `/tmp/q6.sql` 이 인덱스를 타게 하세요.',
     '`CREATE INDEX 이름 ON 테이블 (컬럼)` 형태입니다. 만든 뒤 `EXPLAIN` 의 `key` 를 확인하세요.',
     "mariadb shop -e 'CREATE INDEX idx_created ON orders (created_at)'\nmariadb shop -e \"EXPLAIN $(cat /tmp/q6.sql)\"\n\n# (customer_id, created_at) 인덱스는 created_at 만으로는 못 쓴다 (선두 컬럼 customer_id 가 없다). created_at 이 먼저인 인덱스가 따로 필요하다",
     SETUP('CREATE INDEX idx_cust_created ON orders (customer_id, created_at);',
           "printf \"SELECT * FROM orders WHERE created_at = '2026-03-05';\\n\" > /tmp/q6.sql"),
     [chk('idx_created 인덱스가 있다', '[ "$(mariadb -N shop -e "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=\'shop\' AND table_name=\'orders\' AND index_name=\'idx_created\' AND column_name=\'created_at\' AND seq_in_index=1")" = 1 ]'),
      chk('q6.sql 이 idx_created 를 탄다', SQLFILE('/tmp/q6.sql') + ' | cut -f6 | grep -qx idx_created')])

# 7 커버링
b.nt('인덱스만 읽고 끝내기: Using index',
     '`/tmp/q7.sql` 은 고객 번호 77 의 **주문 금액(`amount`)** 만 조회합니다: `SELECT customer_id, amount FROM orders WHERE customer_id = 77`. 지금은 `idx_cust` 로 행을 찾은 뒤 `amount` 를 읽으러 **테이블을 한 번 더** 갑니다.\n\n`(customer_id, amount)` 를 묶은 인덱스 **`idx_cust_amount`** 를 만드세요. 이 두 컬럼만 필요한 쿼리는 인덱스 안에서 답이 끝나서, `EXPLAIN` 의 `Extra` 에 **`Using index`** 가 나옵니다. (이런 인덱스를 **커버링 인덱스**라 부릅니다)',
     '`CREATE INDEX 이름 ON orders (컬럼1, 컬럼2)` 입니다. 쿼리가 필요로 하는 컬럼이 전부 인덱스에 들어 있어야 합니다.',
     "mariadb shop -e 'CREATE INDEX idx_cust_amount ON orders (customer_id, amount)'\nmariadb shop -e \"EXPLAIN $(cat /tmp/q7.sql)\"\n\n# 조회 컬럼 + 조건 컬럼이 모두 인덱스에 있으면 테이블을 읽지 않는다 → Extra: Using index",
     SETUP('CREATE INDEX idx_cust ON orders (customer_id);',
           "printf 'SELECT customer_id, amount FROM orders WHERE customer_id = 77;\\n' > /tmp/q7.sql"),
     [chk('idx_cust_amount 가 (customer_id, amount) 순서다', '[ "$(mariadb -N shop -e "SELECT GROUP_CONCAT(column_name ORDER BY seq_in_index) FROM information_schema.statistics WHERE table_schema=\'shop\' AND table_name=\'orders\' AND index_name=\'idx_cust_amount\'")" = customer_id,amount ]'),
      chk('Extra 에 Using index 가 나온다', SQLFILE('/tmp/q7.sql') + ' | cut -f10 | grep -q "Using index"')])

# 8 filesort
b.nt('Using filesort 없애기: 정렬까지 인덱스로',
     '`/tmp/q8.sql` 은 고객 번호 77 의 주문을 **`created_at` 순**으로 가져옵니다: `SELECT * FROM orders WHERE customer_id = 77 ORDER BY created_at`. 지금 `EXPLAIN` 의 `Extra` 에는 **`Using filesort`** 가 보입니다. 인덱스는 `customer_id` 로 행은 찾지만 그 안의 `created_at` 순서는 모르기 때문에, 찾은 행을 **따로 정렬**하는 작업입니다.\n\n`WHERE` 컬럼 뒤에 `ORDER BY` 컬럼을 이어 붙인 복합 인덱스 **`idx_cust_created`** `(customer_id, created_at)` 를 만들어 `Using filesort` 를 없애고, 그때의 `EXPLAIN` 출력을 **`/tmp/q8.txt`** 에 저장하세요.',
     '같은 고객 번호 안에서는 인덱스가 이미 `created_at` 순으로 정렬되어 있게 됩니다. 컬럼 순서는 `WHERE` 의 같음 조건 컬럼이 앞, 정렬 컬럼이 뒤입니다.',
     "mariadb shop -e 'CREATE INDEX idx_cust_created ON orders (customer_id, created_at)'\nmariadb shop -e \"EXPLAIN $(cat /tmp/q8.sql)\" > /tmp/q8.txt\ncat /tmp/q8.txt\n\n# 같음 조건 컬럼 → 정렬 컬럼 순으로 묶으면 인덱스가 이미 정렬되어 있어 filesort 가 필요 없다",
     SETUP('CREATE INDEX idx_cust ON orders (customer_id);',
           "printf 'SELECT * FROM orders WHERE customer_id = 77 ORDER BY created_at;\\n' > /tmp/q8.sql"),
     [chk('idx_cust_created 가 (customer_id, created_at) 순서다', '[ "$(mariadb -N shop -e "SELECT GROUP_CONCAT(column_name ORDER BY seq_in_index) FROM information_schema.statistics WHERE table_schema=\'shop\' AND table_name=\'orders\' AND index_name=\'idx_cust_created\'")" = customer_id,created_at ]'),
      chk('q8.txt 에 filesort 가 없다', '[ -s /tmp/q8.txt ] && ! grep -q filesort /tmp/q8.txt'),
      chk('지금 EXPLAIN 에도 filesort 가 없다', SQLFILE('/tmp/q8.sql') + ' | grep -vq filesort')])

# 9 temporary
b.nt('Using temporary 없애기: GROUP BY 에 인덱스',
     '`/tmp/q9.sql` 은 **상태별 주문 수**를 셉니다: `SELECT status, COUNT(*) FROM orders GROUP BY status`. `status` 에 인덱스가 없어 `EXPLAIN` 의 `Extra` 에 **`Using temporary; Using filesort`** 가 보입니다. 행을 묶으려고 **임시 테이블**을 만들고 정렬까지 하는 것입니다.\n\n`status` 에 인덱스 **`idx_status`** 를 만들어 `Using temporary` 가 사라지게 하세요. 인덱스가 이미 같은 값끼리 모아 둬서 바로 셀 수 있습니다.',
     '`GROUP BY` 하는 컬럼에 인덱스를 만들고 `EXPLAIN` 의 `Extra` 가 바뀌었는지 확인하세요.',
     "mariadb shop -e 'CREATE INDEX idx_status ON orders (status)'\nmariadb shop -e \"EXPLAIN $(cat /tmp/q9.sql)\"\n\n# GROUP BY 컬럼에 인덱스가 있으면 이미 값끼리 모여 있어 임시 테이블 없이 센다 (Extra: Using index)",
     SETUP('', "printf 'SELECT status, COUNT(*) FROM orders GROUP BY status;\\n' > /tmp/q9.sql"),
     [chk('idx_status 가 status 에 걸려 있다', '[ "$(mariadb -N shop -e "SELECT column_name FROM information_schema.statistics WHERE table_schema=\'shop\' AND table_name=\'orders\' AND index_name=\'idx_status\'")" = status ]'),
      chk('Using temporary 가 사라졌다', SQLFILE('/tmp/q9.sql') + ' | grep -vq temporary')])

# 10 빈칸
b.fill('인덱스만으로 답했다는 표시', '`EXPLAIN` 의 `Extra` 에 **테이블을 읽지 않고 인덱스만으로 답했다**는 표시로 나오는 값을 채우세요.', '커버링 인덱스를 만들었을 때 나온 값입니다.',
       'Extra: {0}', ['Using index', 'Using where', 'Using filesort', 'Using temporary'], [0],
       '`Using index` 는 필요한 컬럼이 모두 인덱스에 있어 테이블 본체를 읽지 않았다는 뜻입니다(커버링 인덱스). `Using where` 는 조건을 걸러낸다는 표시이고, `Using filesort`·`Using temporary` 는 따로 정렬하거나 임시 테이블을 쓴다는 경고입니다.')

# 11 객관식
b.choice('복합 인덱스를 잘 타는 쿼리',
         '`(customer_id, created_at)` 순서의 복합 인덱스가 있습니다. 다음 중 이 인덱스를 **가장 잘 활용하는** 쿼리는 무엇일까요?',
         '선두 컬럼이 가공 없이 조건에 쓰이는지, 그 다음 컬럼이 정렬·조건에 이어지는지 보세요.',
         ["WHERE customer_id = 77 ORDER BY created_at", "WHERE created_at = '2026-03-05'", "WHERE customer_id + 0 = 77 ORDER BY created_at", "WHERE YEAR(created_at) = 2026"], 0,
         "선두 컬럼 `customer_id` 를 그대로 같음 조건으로 쓰고 그다음 컬럼 `created_at` 으로 정렬해서 인덱스의 정렬 순서까지 활용합니다. `created_at` 만 쓰면 선두를 건너뛰고, `customer_id + 0` 과 `YEAR(created_at)` 은 컬럼을 가공해서 인덱스를 못 씁니다.")

# 12 순서
b.order('느린 쿼리 튜닝 점검 순서', '느린 쿼리 하나를 EXPLAIN 으로 개선하는 흐름입니다. 올바른 순서로 놓으세요.', '느린 것을 먼저 고르고, 계획을 읽어 원인을 찾은 뒤 고치고, 마지막에 확인합니다.',
        ['쿼리나 인덱스를 고친다', '다시 EXPLAIN 으로 type·key·rows 가 나아졌는지 확인한다', '느린 쿼리를 하나 고른다', 'EXPLAIN 으로 type·key·rows·Extra 를 읽는다', '인덱스를 못 타는 원인(함수·형변환·선두 컬럼 등)을 찾는다'], [2, 3, 4, 0, 1],
        '튜닝은 추측이 아니라 측정으로 합니다. 느린 쿼리를 고르고, EXPLAIN 으로 계획을 읽어 원인을 찾은 뒤, 쿼리나 인덱스를 고치고, 다시 EXPLAIN 으로 좋아졌는지 확인합니다.')

if __name__ == '__main__':
    preview(b)
