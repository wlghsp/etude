-- 미들웨어 세트 109. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set109.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 109, 'MariaDB 백업과 복원: 덤프 뜨고, 되살리고, 검증하기', 'MariaDB 를 안전하게 백업하고 복원하는 필수 기본기를 실제로 해 봅니다. mysqldump 로 덤프(--single-transaction)와 압축 덤프, 삭제된 DB 복구, 전체 덤프에서 테이블 하나만 복구, 새 DB 에 복원해 행 수 검증, 논리 백업과 물리 백업의 차이, 사용자·권한은 따로 옮겨야 하는 이유를 문제와 실습으로 다룹니다.', 'linux-db', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 109);
UPDATE quest_set SET display_order = 549, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '💾' WHERE id = 109;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 1, '덤프 뜨고 복원하는 명령 채우기', '`shop` 데이터베이스를 **일관된 상태로 덤프**(InnoDB 를 잠그지 않고)해 `/tmp/shop.sql` 에 저장하고, 그 파일을 `shop` 에 **복원**하는 명령입니다. 빈칸을 채우세요.', '덤프는 `mysqldump 옵션 DB이름 > 파일`, 복원은 `mariadb DB이름 < 파일` 입니다.', NULL, NULL, '[]', 'fill', '["single-transaction", "shop", "no-data", "all-databases", "routines"]', NULL, '`mysqldump` 가 DB 를 SQL 문장(`CREATE TABLE`, `INSERT`)으로 바꿔 파일에 저장하고, `mariadb DB이름 < 파일` 이 그 문장을 다시 실행해 복원합니다. `--single-transaction` 은 InnoDB 테이블을 잠그지 않고 한 시점의 일관된 모습으로 덤프합니다.', '[0, 1]', 'mysqldump --{0} shop > /tmp/shop.sql
mariadb {1} < /tmp/shop.sql', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 2, '덤프 범위 옵션 짝 맞추기', '① 데이터 없이 **테이블 구조(스키마)만** 덤프, ② 서버의 **모든 데이터베이스**를 덤프하는 옵션입니다.', '"데이터 없음"과 "모든 데이터베이스"를 영어로 떠올려 보세요.', NULL, NULL, '[]', 'fill', '["no-data", "all-databases", "single-transaction", "routines"]', NULL, '`--no-data` 는 `CREATE TABLE` 만 담아 구조 백업이나 개발 환경 구성에 쓰고, `--all-databases` 는 모든 DB(사용자·권한이 든 `mysql` DB 포함)를 한 파일에 담습니다. 저장 프로시저는 `--routines` 로 함께 담습니다.', '[0, 1]', 'mysqldump --{0} shop
mysqldump --{1}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 3, '안전한 복원 순서', '덤프 파일로 복원해야 합니다. **실수를 줄이는 순서**를 앞에서 뒤로 놓아 보세요.', '파일을 믿기 전에 먼저 확인하고, 복원한 뒤에도 확인합니다.', NULL, NULL, '[]', 'order', '["복원된 테이블과 행 수가 원본 기준과 맞는지 확인한다", "`head` 와 `ls -l` 로 덤프 파일이 비어 있지 않고 SQL 이 맞는지 확인한다", "복원할 빈 데이터베이스를 만든다", "`mariadb DB이름 < 덤프파일` 로 복원한다"]', NULL, '**파일 확인 → 빈 DB 생성 → 복원 → 행 수 확인** 입니다. 덤프 파일이 잘렸거나 비어 있는 것을 복원한 뒤에야 알게 되면 늦습니다. 가능하면 운영 DB 가 아니라 **새 DB 에 먼저 복원해 보고** 검증하세요.', '[1, 2, 3, 0]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 4, '논리 백업과 물리 백업', '`mysqldump` 로 만든 `.sql` 백업은 어떤 특징이 있을까요?', 'SQL 문장이 든 텍스트 파일입니다.', NULL, NULL, '[]', 'choice', '["데이터 파일을 그대로 복사한 물리 백업이라 가장 빠르다", "바이너리 형식이라 열어 볼 수 없다", "SQL 문장(논리 백업)이라 읽고 일부만 골라 복원하기 쉽고 다른 버전에도 옮기기 좋지만, 아주 큰 DB 에서는 덤프·복원이 오래 걸린다", "서버를 반드시 중지해야 뜰 수 있다"]', 2, '큰 DB 는 데이터 파일 단위로 빠르게 백업하는 `mariabackup`(물리 백업)을 쓰기도 합니다. 규모가 작거나 이식성·부분 복원이 필요하면 `mysqldump` 가 편해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 5, '--single-transaction 을 쓰는 이유', '운영 중인 DB 를 덤프할 때 `--single-transaction` 을 쓰는 이유는 무엇일까요?', '덤프 동안 쓰기가 막히면 서비스가 멈춥니다.', NULL, NULL, '[]', 'choice', '["덤프 파일을 자동으로 압축한다", "덤프를 두 번 실행한다", "테이블 구조를 제외한다", "InnoDB 테이블을 잠그지 않고도 덤프 시작 시점의 **일관된 스냅샷**을 얻는다"]', 3, '옵션이 없으면 테이블별로 시점이 달라져 일관성이 깨지거나, `--lock-tables` 때문에 쓰기가 막힐 수 있어요. 단, MyISAM 같은 비트랜잭션 테이블에는 이 방식이 적용되지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 6, '운영 DB 에 바로 복원해도 될까?', '백업이 정상인지 확신이 없습니다. 장애 후 복원할 때 가장 안전한 접근은 무엇일까요?', '복원도 잘못하면 또 다른 사고가 됩니다.', NULL, NULL, '[]', 'choice', '["확인 없이 운영 DB 에 바로 덮어쓴다", "새 이름의 DB 에 먼저 복원해 테이블·행 수를 검증한 뒤, 확신이 서면 운영에 적용한다", "덤프 파일을 지우고 처음부터 다시 만든다", "서버를 재부팅한다"]', 1, '복원은 기존 데이터를 덮어쓸 수 있습니다. 먼저 다른 이름의 DB 에 복원해 눈으로 확인하는 습관이 가장 큰 보험이에요. 정기적으로 "복원 연습"을 해 두면 진짜 장애 때 당황하지 않습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 7, '덤프에 사용자와 권한도 들어 있을까?', '`mysqldump shop` 으로 만든 파일을 다른 서버에 복원했더니 애플리케이션 계정이 없어 접속이 안 됩니다. 이유는 무엇일까요?', '사용자 정보는 어느 데이터베이스에 저장될까요?', NULL, NULL, '[]', 'choice', '["덤프 파일이 깨져서", "비밀번호가 너무 길어서", "`shop` 덤프에는 `shop` 의 테이블만 있고, 사용자·권한은 `mysql` 데이터베이스(또는 `SHOW GRANTS`)에 따로 있어 함께 옮겨야 한다", "MariaDB 가 계정 이전을 지원하지 않아서"]', 2, '`--all-databases` 는 `mysql` DB 도 담지만, 버전이 다르면 그대로 복원하기 어렵습니다. 보통은 `SHOW GRANTS FOR 계정` 결과를 따로 보관해 새 서버에서 실행합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 8, 'shop 데이터베이스 덤프 뜨기', 'MariaDB 가 실행 중이고 `shop` 데이터베이스에 `orders` 테이블이 있습니다. **운영 중에도 일관되게**(`--single-transaction`) `shop` 을 덤프해 **`/tmp/shop.sql`** 에 저장하세요.', '`mysqldump` 에 옵션과 DB 이름을 주고 `>` 로 파일에 저장합니다. DB 가 올라오는 데 몇 초 걸릴 수 있어요.\\n확인: `grep -c INSERT /tmp/shop.sql`', 'mysqldump --single-transaction shop > /tmp/shop.sql
ls -l /tmp/shop.sql
grep -c INSERT /tmp/shop.sql

# 덤프는 SQL 문장(CREATE TABLE, INSERT)이 든 텍스트 파일이다', '["sh", "-c", "nohup mysqld_safe >/dev/null 2>&1 & for i in $(seq 1 60); do mariadb -e ''select 1'' >/dev/null 2>&1 && break; sleep 0.5; done; mariadb -e \\"create database shop; create table shop.orders(id int primary key, item varchar(20), qty int); insert into shop.orders values (1,''pen'',3),(2,''book'',1),(3,''cup'',2);\\""]', '["sh", "-c", "( [ -s /tmp/shop.sql ] ) && ( grep -q \\"CREATE TABLE .orders.\\" /tmp/shop.sql ) && ( grep -q \\"INSERT INTO .orders.\\" /tmp/shop.sql ) && ( grep -q \\"cup\\" /tmp/shop.sql )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "덤프 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/shop.sql ]"]}, {"label": "테이블 생성문이 있다", "cmd": ["sh", "-c", "grep -q \\"CREATE TABLE .orders.\\" /tmp/shop.sql"]}, {"label": "데이터 INSERT 가 있다", "cmd": ["sh", "-c", "grep -q \\"INSERT INTO .orders.\\" /tmp/shop.sql"]}, {"label": "데이터 3건이 들어 있다", "cmd": ["sh", "-c", "grep -q \\"cup\\" /tmp/shop.sql"]}]', '[{"title": "MariaDB 공식 문서", "url": "https://mariadb.com/kb/en/mariadb-dumpmysqldump/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 9, '압축해서 덤프 뜨기', '덤프 파일이 크면 디스크를 많이 씁니다. `shop` 을 덤프하면서 **바로 gzip 으로 압축**해 **`/tmp/shop.sql.gz`** 에 저장하세요. (임시 평문 파일을 만들지 않고 파이프로 연결합니다)', '`mysqldump … | gzip > 파일.gz` 처럼 파이프를 이어요. 확인은 `zcat 파일.gz | head`.', 'mysqldump --single-transaction shop | gzip > /tmp/shop.sql.gz
gzip -t /tmp/shop.sql.gz && echo ok
zcat /tmp/shop.sql.gz | grep -c INSERT

# 파이프로 연결하면 큰 평문 파일을 디스크에 만들지 않는다', '["sh", "-c", "nohup mysqld_safe >/dev/null 2>&1 & for i in $(seq 1 60); do mariadb -e ''select 1'' >/dev/null 2>&1 && break; sleep 0.5; done; mariadb -e \\"create database shop; create table shop.orders(id int primary key, item varchar(20), qty int); insert into shop.orders values (1,''pen'',3),(2,''book'',1),(3,''cup'',2);\\""]', '["sh", "-c", "( [ -s /tmp/shop.sql.gz ] ) && ( gzip -t /tmp/shop.sql.gz ) && ( zcat /tmp/shop.sql.gz | grep -q \\"INSERT INTO .orders.\\" ) && ( [ ! -e /tmp/shop.sql ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "압축 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/shop.sql.gz ]"]}, {"label": "올바른 gzip 파일이다", "cmd": ["sh", "-c", "gzip -t /tmp/shop.sql.gz"]}, {"label": "압축을 풀면 orders 데이터가 있다", "cmd": ["sh", "-c", "zcat /tmp/shop.sql.gz | grep -q \\"INSERT INTO .orders.\\""]}, {"label": "평문 덤프를 따로 만들지 않았다", "cmd": ["sh", "-c", "[ ! -e /tmp/shop.sql ]"]}]', '[{"title": "MariaDB 공식 문서", "url": "https://mariadb.com/kb/en/mariadb-dumpmysqldump/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 10, '삭제된 DB 를 덤프에서 복구하기', '누군가 `shop` 데이터베이스를 **통째로 삭제**했습니다. 다행히 백업 파일 `/tmp/backup.sql` 이 있습니다. `shop` 을 다시 만들고 백업으로 **복원**하세요. (`orders` 가 3건이어야 합니다)', '빈 DB 를 먼저 만들고(`create database`) 파일을 입력으로 넣습니다.\\n확인: `mariadb -e "select * from shop.orders"`', 'head -n 20 /tmp/backup.sql
mariadb -e ''create database shop''
mariadb shop < /tmp/backup.sql
mariadb -e ''select * from shop.orders''

# 복원 = 덤프 속 SQL 문장을 다시 실행하는 것', '["sh", "-c", "nohup mysqld_safe >/dev/null 2>&1 & for i in $(seq 1 60); do mariadb -e ''select 1'' >/dev/null 2>&1 && break; sleep 0.5; done; mariadb -e \\"create database shop; create table shop.orders(id int primary key, item varchar(20), qty int); insert into shop.orders values (1,''pen'',3),(2,''book'',1),(3,''cup'',2);\\" && mysqldump shop > /tmp/backup.sql && mariadb -e ''drop database shop''"]', '["sh", "-c", "( mariadb -N -e \\"show databases\\" | grep -qx shop ) && ( [ \\"$(mariadb -N -e \\"select count(*) from shop.orders\\")\\" = 3 ] ) && ( [ \\"$(mariadb -N -e \\"select item from shop.orders where id=3\\")\\" = cup ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "shop 데이터베이스가 있다", "cmd": ["sh", "-c", "mariadb -N -e \\"show databases\\" | grep -qx shop"]}, {"label": "orders 가 3건이다", "cmd": ["sh", "-c", "[ \\"$(mariadb -N -e \\"select count(*) from shop.orders\\")\\" = 3 ]"]}, {"label": "데이터가 원본과 같다", "cmd": ["sh", "-c", "[ \\"$(mariadb -N -e \\"select item from shop.orders where id=3\\")\\" = cup ]"]}]', '[{"title": "MariaDB 공식 문서", "url": "https://mariadb.com/kb/en/mariadb-dumpmysqldump/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 11, '전체 덤프에서 테이블 하나만 복구하기', '전체 덤프 `/tmp/full.sql` 이 있습니다. 실수로 **`customers` 테이블만 삭제**되었고 `orders` 는 멀쩡합니다. 전체를 다시 덮어쓰지 말고 **`customers` 테이블 부분만** 복구하세요. (`customers` 2건)', '덤프 파일에는 테이블마다 `-- Table structure for table `이름`` 주석이 있습니다. `sed -n ''/시작/,/끝/p''` 로 구간만 뽑아 `mariadb shop` 에 넣을 수 있어요.\\n확인: `grep -n "Table structure" /tmp/full.sql`', 'grep -n ''Table structure'' /tmp/full.sql
sed -n ''/Table structure for table `customers`/,/Table structure for table `orders`/p'' /tmp/full.sql | mariadb shop
mariadb -e ''select * from shop.customers''

# 구간을 잘라 필요한 테이블만 넣으면 다른 테이블은 건드리지 않는다', '["sh", "-c", "nohup mysqld_safe >/dev/null 2>&1 & for i in $(seq 1 60); do mariadb -e ''select 1'' >/dev/null 2>&1 && break; sleep 0.5; done; mariadb -e \\"create database shop; create table shop.orders(id int primary key, item varchar(20), qty int); insert into shop.orders values (1,''pen'',3),(2,''book'',1),(3,''cup'',2);\\" && mariadb -e \\"create table shop.customers(id int primary key, name varchar(20)); insert into shop.customers values (1,''kim''),(2,''lee'');\\" && mysqldump shop > /tmp/full.sql && mariadb -e ''drop table shop.customers'' && mariadb -e \\"update shop.orders set qty=9 where id=1\\""]', '["sh", "-c", "( [ \\"$(mariadb -N -e \\"select count(*) from shop.customers\\")\\" = 2 ] ) && ( [ \\"$(mariadb -N -e \\"select qty from shop.orders where id=1\\")\\" = 9 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "customers 테이블이 복구되었다", "cmd": ["sh", "-c", "[ \\"$(mariadb -N -e \\"select count(*) from shop.customers\\")\\" = 2 ]"]}, {"label": "orders 는 덮어쓰이지 않았다 (최신 값 유지)", "cmd": ["sh", "-c", "[ \\"$(mariadb -N -e \\"select qty from shop.orders where id=1\\")\\" = 9 ]"]}]', '[{"title": "MariaDB 공식 문서", "url": "https://mariadb.com/kb/en/mariadb-dumpmysqldump/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 109, 12, '새 DB 에 복원해 행 수 검증하기', '`/tmp/backup.sql` 은 `shop` 의 덤프입니다. 운영 `shop` 을 건드리지 않고 **`shop_check`** 라는 새 DB 에 복원한 뒤, `shop_check.orders` 의 **행 수**를 숫자만 **`/tmp/count.txt`** 에 저장하세요.', '`shop_check` 를 먼저 만들고 `mariadb shop_check < 파일` 로 복원합니다. 행 수는 `mariadb -N -e "select count(*) …"` 의 `-N`(제목 줄 없음)을 쓰면 숫자만 나옵니다.', 'mariadb -e ''create database shop_check''
mariadb shop_check < /tmp/backup.sql
mariadb -N -e ''select count(*) from shop_check.orders'' > /tmp/count.txt
cat /tmp/count.txt

# 운영 DB 와 분리된 이름에 복원해 검증하면 안전하다', '["sh", "-c", "nohup mysqld_safe >/dev/null 2>&1 & for i in $(seq 1 60); do mariadb -e ''select 1'' >/dev/null 2>&1 && break; sleep 0.5; done; mariadb -e \\"create database shop; create table shop.orders(id int primary key, item varchar(20), qty int); insert into shop.orders values (1,''pen'',3),(2,''book'',1),(3,''cup'',2);\\" && mysqldump shop > /tmp/backup.sql"]', '["sh", "-c", "( mariadb -N -e \\"show databases\\" | grep -qx shop_check ) && ( [ \\"$(cat /tmp/count.txt)\\" = 3 ] ) && ( [ \\"$(mariadb -N -e \\"select count(*) from shop.orders\\")\\" = 3 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "shop_check 가 있다", "cmd": ["sh", "-c", "mariadb -N -e \\"show databases\\" | grep -qx shop_check"]}, {"label": "행 수 3 이 저장되었다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/count.txt)\\" = 3 ]"]}, {"label": "운영 shop 은 그대로다", "cmd": ["sh", "-c", "[ \\"$(mariadb -N -e \\"select count(*) from shop.orders\\")\\" = 3 ]"]}]', '[{"title": "MariaDB 공식 문서", "url": "https://mariadb.com/kb/en/mariadb-dumpmysqldump/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 109 AND order_index = 12);
