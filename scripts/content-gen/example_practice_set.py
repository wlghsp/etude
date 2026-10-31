# 예시 생성기: 세트 126 를 만든 스크립트. 이 파일을 그대로 실행하지 않는다 (02·05·06·08 파일과 마이그레이션에 같은 행이 중복으로 붙는다).
# 복사해서 SID, 제목, 설명, display_order, 문제를 바꾼 뒤 쓴다. 사용법: docs/ops/guide_new_pc_setup.md 의 "새 세트 만드는 법".
import json, os, re, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
SID = 126
assert SID != 126, '예시 세트 번호입니다. SID 를 새 번호로 바꾸세요'
DOC = json.dumps([{"title": "MariaDB 기본 SQL 문장", "url": "https://mariadb.com/kb/en/basic-sql-statements/"}], ensure_ascii=False)
UNIT_SQL = "INSERT INTO unit (id, category, title, display_order) SELECT 20, '미들웨어', '데이터베이스', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 20);\n"
def terminal(n, title, desc, hint, sol, setup, checks): return dict(n=n, kind='terminal', title=title, desc=desc, hint=hint, sol=sol, setup=setup, checks=checks)
def _choice(n, title, desc, hint, opts, ans, expl): return dict(n=n, kind='choice', title=title, desc=desc, hint=hint, opts=opts, ans=ans, expl=expl)
def chk(label, cmd): return dict(label=label, cmd=cmd)
POS = {n: (n*7+3) % 4 for n in range(1, 60)}
def choice(n, title, desc, hint, opts, ans, expl):
    pos = POS.get(n, ans)
    o = list(opts); right = o.pop(ans); o.insert(pos, right)
    return _choice(n, title, desc, hint, o, pos, expl)
def fill(n, title, desc, hint, tpl, chips, spec, expl): return dict(n=n, kind='fill', title=title, desc=desc, hint=hint, tpl=tpl, chips=chips, spec=spec, expl=expl)
GIT = "rm -f ~/.gitconfig; rm -rf /tmp/lab && mkdir -p /tmp/lab && cd /tmp/lab && git config --global user.name tester && git config --global user.email t@example.com"
P = '/tmp/lab/proj'
def order(n, title, desc, hint, pieces, spec, expl): return dict(n=n, kind='order', title=title, desc=desc, hint=hint, pieces=pieces, spec=spec, expl=expl)
Q = []
DBUP = "nohup mysqld_safe >/dev/null 2>&1 & for i in $(seq 1 60); do mariadb -e 'select 1' >/dev/null 2>&1 && break; sleep 0.5; done"
SEED = DBUP + """; mariadb -e 'DROP DATABASE IF EXISTS shop; CREATE DATABASE shop; USE shop; CREATE TABLE customers (id INT PRIMARY KEY, name VARCHAR(30) NOT NULL, email VARCHAR(50), city VARCHAR(20)); INSERT INTO customers VALUES (1,"kim","kim@example.com","Seoul"),(2,"lee","lee@example.com","Busan"),(3,"park","park@example.com","Seoul"),(4,"choi","choi@example.com","Daegu"),(5,"jung","jung@example.com","Busan"); CREATE TABLE orders (id INT PRIMARY KEY, customer_id INT, amount INT); INSERT INTO orders VALUES (1,1,12000),(2,1,5000),(3,3,30000);'; rm -f /tmp/*.txt"""
def nt(*a): Q.append(terminal(len(Q)+1, *a))
nt('데이터베이스 목록 저장하기', '서버에 있는 데이터베이스 **목록**을 `/tmp/dbs.txt` 에 저장하세요. `shop` 이 보여야 합니다.', '`mariadb -e \'SQL문\'` 으로 터미널에서 바로 SQL 을 실행할 수 있어요. 결과는 `>` 로 파일에 저장합니다.',
 "mariadb -e 'SHOW DATABASES;' > /tmp/dbs.txt\ncat /tmp/dbs.txt\n\n# mariadb -e 'SQL' 은 접속해서 문장 하나를 실행하고 나온다. 스크립트에서 자주 쓴다",
 SEED, [chk('파일이 있다', '[ -s /tmp/dbs.txt ]'), chk('shop 이 목록에 있다', 'grep -qx shop /tmp/dbs.txt')])
nt('shop 안의 테이블 목록', '`shop` 데이터베이스 안의 **테이블 목록**을 `/tmp/tables.txt` 에 저장하세요. `customers` 와 `orders` 가 보여야 합니다.', '데이터베이스를 지정하려면 `mariadb shop -e \'...\'` 처럼 이름을 먼저 씁니다.',
 "mariadb shop -e 'SHOW TABLES;' > /tmp/tables.txt\ncat /tmp/tables.txt\n\n# mariadb 데이터베이스이름 -e 'SQL' : USE 를 따로 안 써도 그 DB 에서 실행된다",
 SEED, [chk('customers 가 있다', 'grep -qx customers /tmp/tables.txt'), chk('orders 가 있다', 'grep -qx orders /tmp/tables.txt')])
nt('customers 의 구조 보기', '`customers` 테이블의 **컬럼 구조**를 `/tmp/desc.txt` 에 저장하세요. `email` 컬럼이 보여야 합니다.', '구조를 보는 명령은 `DESC 테이블;` 이에요.',
 "mariadb shop -e 'DESC customers;' > /tmp/desc.txt\ncat /tmp/desc.txt\n\n# Field(컬럼), Type(타입), Null(NULL 허용), Key(PRI=기본키)를 읽는다",
 SEED, [chk('파일이 있다', '[ -s /tmp/desc.txt ]'), chk('email 컬럼이 보인다', 'grep -q "^email" /tmp/desc.txt'), chk('id 가 기본 키(PRI)이다', 'grep -q "^id.*PRI" /tmp/desc.txt')])
nt('처음 3명만 보기', '`customers` 의 **모든 열, 처음 3행**을 `/tmp/first3.txt` 에 저장하세요. (제목 줄 1개 + 데이터 3줄이 됩니다)', '`SELECT * FROM customers LIMIT 3;`',
 "mariadb shop -e 'SELECT * FROM customers LIMIT 3;' > /tmp/first3.txt\ncat /tmp/first3.txt\n\n# 결과의 첫 줄은 컬럼 이름(제목)이다. LIMIT 3 이라 데이터는 3행이다",
 SEED, [chk('4줄이다 (제목 1 + 데이터 3)', '[ "$(wc -l < /tmp/first3.txt)" -eq 4 ]'), chk('제목에 city 가 있다', 'head -n 1 /tmp/first3.txt | grep -q city')])
nt('이름과 이메일만 보기', '`customers` 에서 **이름(`name`)과 이메일(`email`) 열만** 모든 행을 `/tmp/ne.txt` 에 저장하세요. `city` 열은 없어야 합니다.', '열 이름을 쉼표로 이어 적어요: `SELECT name, email FROM ...`',
 "mariadb shop -e 'SELECT name, email FROM customers;' > /tmp/ne.txt\ncat /tmp/ne.txt\n\n# 필요한 열만 고르면 결과가 읽기 쉽고 가져오는 양도 줄어든다",
 SEED, [chk('제목이 name 과 email 이다', '[ "$(head -n 1 /tmp/ne.txt | tr "\\t" ,)" = "name,email" ]'), chk('데이터가 5행이다', '[ "$(wc -l < /tmp/ne.txt)" -eq 6 ]'), chk('city 열이 없다', '! grep -q Seoul /tmp/ne.txt')])
nt('결과 열에 별명 붙이기', '`name` 열을 **`customer_name`** 이라는 별명으로 바꿔, 모든 행을 `/tmp/alias.txt` 에 저장하세요. (제목 줄이 `customer_name` 이 됩니다)', '`SELECT name AS customer_name FROM customers;`',
 "mariadb shop -e 'SELECT name AS customer_name FROM customers;' > /tmp/alias.txt\ncat /tmp/alias.txt\n\n# AS 는 결과에서 보이는 이름만 바꾼다. 테이블 컬럼 이름은 그대로다",
 SEED, [chk('제목이 customer_name 이다', '[ "$(head -n 1 /tmp/alias.txt)" = customer_name ]'), chk('데이터가 5행이다', '[ "$(wc -l < /tmp/alias.txt)" -eq 6 ]')])
nt('제목 줄 없이 값만 뽑기', '`customers` 의 이름 **2개만**, **제목 줄 없이** 값만 `/tmp/plain.txt` 에 저장하세요. (스크립트에서 값을 이어 쓸 때 편합니다)', '`mariadb` 에 제목 줄을 빼는 옵션 `-N`(skip-column-names)이 있어요.',
 "mariadb -N shop -e 'SELECT name FROM customers LIMIT 2;' > /tmp/plain.txt\ncat /tmp/plain.txt\n\n# -N 은 제목 줄을 뺀다. 결과를 다른 명령으로 넘기거나 변수에 담을 때 쓴다",
 SEED, [chk('2줄이다', '[ "$(wc -l < /tmp/plain.txt)" -eq 2 ]'), chk('제목(name)이 없다', '! grep -qx name /tmp/plain.txt')])
nt('지금 선택한 데이터베이스 확인하기', '`shop` 을 선택한 상태에서 **현재 데이터베이스 이름**을 보는 SQL 을 실행해 값만(제목 줄 없이) `/tmp/curdb.txt` 에 저장하세요.', '`SELECT DATABASE();` 를 `-N` 옵션과 함께 쓰세요.',
 "mariadb -N shop -e 'SELECT DATABASE();' > /tmp/curdb.txt\ncat /tmp/curdb.txt\n\n# 운영 서버에서 데이터를 바꾸기 전에 어느 DB 인지 확인하는 습관",
 SEED, [chk('값이 shop 이다', '[ "$(cat /tmp/curdb.txt)" = shop ]')])

def sq(s): return s.replace('\\', '\\\\').replace("'", "''")
def lit(s): return 'NULL' if s is None else "'" + sq(s) + "'"

def j(o): return json.dumps(o, ensure_ascii=False)
def sh(c): return ['sh', '-c', c]

rows = []; answers = {}
for q in Q:
    k = q['kind']
    if k == 'terminal':
        grade = ' && '.join(f'( {c["cmd"]} )' for c in q['checks'])
        answers[str(q['n'])] = q['sol']
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), lit(q['sol']), lit(j(sh(q['setup']))), lit(j(sh(grade))), "'terminal'", 'NULL','NULL','NULL','NULL','NULL', lit(j([dict(label=c['label'], cmd=sh(c['cmd'])) for c in q['checks']])), lit(DOC)]
    elif k == 'choice':
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL','NULL', "'[]'", "'choice'", lit(j(q['opts'])), str(q['ans']), lit(q['expl']), 'NULL','NULL','NULL', 'NULL']
    elif k == 'fill':
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL','NULL', "'[]'", "'fill'", lit(j(q['chips'])), 'NULL', lit(q['expl']), lit(j(q['spec'])), lit(q['tpl']), 'NULL', 'NULL']
    else:
        vals = [lit(q['title']), lit(q['desc']), lit(q['hint']), 'NULL','NULL', "'[]'", "'order'", lit(j(q['pieces'])), 'NULL', lit(q['expl']), lit(j(q['spec'])), 'NULL','NULL','NULL']
    rows.append(f"({SID}, {q['n']}, " + ', '.join(vals) + ')')

COLS = 'quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs'
TITLE = 'DB 기초 1 (실습): 직접 쳐 보며 구경하기'
DESC = 'MariaDB 에 접속해 데이터베이스와 테이블을 직접 구경해 봅니다. 데이터베이스·테이블 목록 저장, DESC 로 구조 읽기, SELECT 와 LIMIT, 필요한 열 고르기, 별명(AS), mariadb -N 으로 값만 뽑기, 현재 데이터베이스 확인을 작은 실습으로 다룹니다.'
body = f"-- 세트 {SID}: {TITLE}\n-- 기본기 사다리(docs/specs/spec_foundations_ladder.md). 정답·해설은 서버만 안다. 실습 문제의 grade_cmd 는 checks 의 조건을 && 로 이은 것과 같다.\nINSERT INTO quest ({COLS}) VALUES\n  " + ',\n  '.join(rows) + ';\n'
open(f'{ROOT}/backend/db/03_quest_set{SID}.sql','w').write(body)
json.dump(dict(setId=SID, answers=answers), open(f'{ROOT}/backend/verify/set{SID}.json','w'), ensure_ascii=False, indent=2)

setrow = f"  ({SID}, {lit(TITLE)}, {lit(DESC)}, 'linux-db', '미들웨어')"
p = f'{ROOT}/backend/db/02_quest_set.sql'
s = open(p).read().rstrip('\n')
assert s.endswith("');")
s = s[:-1] + ',\n' + setrow + ';\n'
open(p,'w').write(s)
open(f'{ROOT}/backend/db/05_display_order.sql','a').write(f'UPDATE quest_set SET display_order = 539 WHERE id = {SID};\n')
open(f'{ROOT}/backend/db/06_units.sql','a').write(UNIT_SQL + f'UPDATE quest_set SET unit_id = 20 WHERE id = {SID};\n')
open(f'{ROOT}/backend/db/08_set_icons.sql','a').write(f"UPDATE quest_set SET icon = '🔍' WHERE id = {SID};\n")

mig_unit = UNIT_SQL
mig = f"""-- 미들웨어 세트 {SID}. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set{SID}.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
{mig_unit}INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT {SID}, {lit(TITLE)}, {lit(DESC)}, 'linux-db', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = {SID});
UPDATE quest_set SET display_order = 539, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '🔍' WHERE id = {SID};
"""
for q, r in zip(Q, rows):
    mig += f"\nINSERT INTO quest ({COLS})\nSELECT {r[1:-1]}\nFROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = {SID} AND order_index = {q['n']});\n"
open(f'{ROOT}/backend/db/migrations/2026-10-31_db_basic1_practice_set{SID}.sql','w').write(mig)
print('ok', len(Q))
