-- 미들웨어 세트 125. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set125.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 20, '미들웨어', '데이터베이스', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 20);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 125, 'DB 기초 1 (개념): 데이터베이스와 테이블 구경하기', 'SQL 을 처음 만나는 사람을 위한 쉬운 문제 모음입니다. 행과 열, 데이터베이스·테이블 목록 보기(SHOW, USE), 테이블 구조 읽기(DESC, PRI, NULL), SELECT 의 기본 모양, 필요한 열만 고르기, LIMIT 로 맛보기, 별명(AS), 세미콜론과 주석, 운영 DB 에서 안전하게 구경하는 순서를 짧은 문제로 반복해서 익힙니다.', 'quiz', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 125);
UPDATE quest_set SET display_order = 538, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '🗂️' WHERE id = 125;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 1, '테이블 속 "한 줄"은 무엇일까', '고객 정보를 담은 `customers` 테이블이 있습니다. 고객 **한 명**의 정보(이름, 이메일, 도시)가 담긴 것은 테이블에서 무엇에 해당할까요?', '엑셀 시트에서 가로 한 줄을 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["열(column)", "데이터베이스", "행(row)", "인덱스"]', 2, '테이블은 엑셀 시트와 비슷합니다. **행(row)** 은 한 건의 데이터, **열(column)** 은 이름·이메일처럼 항목의 종류예요. 고객 100명이면 행이 100개입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 2, '열(컬럼)은 무엇일까', '`customers` 테이블의 `name`, `email`, `city` 는 테이블에서 무엇일까요?', '엑셀에서 세로 방향의 "제목이 붙은 칸"이에요.', NULL, NULL, '[]', 'choice', '["행(row): 한 건의 데이터", "열(column): 항목의 종류", "테이블: 데이터의 묶음", "서버: 컴퓨터 한 대"]', 1, '열은 "어떤 항목을 저장하는가"를 정합니다. 모든 행은 같은 열 구성을 가져요. 한 테이블의 모양(열 목록)을 **스키마**라고 부릅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 3, 'MariaDB 에 접속하기', '터미널에서 `root` 계정으로 MariaDB 에 접속하려 합니다. 비밀번호는 접속하면서 물어봅니다. 빈칸을 채우세요.', '사용자(user)를 지정하는 옵션이에요.', NULL, NULL, '[]', 'fill', '["u", "h", "e", "P"]', NULL, '`-u` 는 사용자 이름, `-p` 는 비밀번호 입력 요청입니다. 접속한 뒤에는 `MariaDB [(none)]>` 같은 프롬프트에서 SQL 을 입력해요. `-p` 바로 뒤에 비밀번호를 붙여 쓰면 기록에 남으니 피하세요.', '[0]', 'mariadb -{0} root -p', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 4, '데이터베이스 목록 보기와 고르기', '서버에 어떤 데이터베이스가 있는지 **목록을 보고**, 그중 `shop` 을 **작업 대상으로 선택**합니다. 빈칸을 채우세요.', '보여 줄 때는 SHOW, 고를 때는 USE 입니다.', NULL, NULL, '[]', 'fill', '["SHOW", "USE", "DROP", "SELECT"]', NULL, '`SHOW DATABASES;` 는 서버의 데이터베이스 목록, `USE shop;` 은 이후 명령이 `shop` 에서 실행되도록 선택합니다. 선택한 뒤 `SHOW TABLES;` 로 그 안의 테이블을 볼 수 있어요.', '[0, 1]', '{0} DATABASES;
{1} shop;
SHOW TABLES;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 5, 'USE 는 무엇을 할까', '`USE shop;` 을 실행하면 어떤 일이 일어날까요?', '"사용하다"라는 뜻 그대로예요.', NULL, NULL, '[]', 'choice', '["`shop` 데이터베이스를 삭제한다", "`shop` 데이터베이스를 새로 만든다", "`shop` 데이터베이스를 지금 작업 대상으로 선택한다", "`shop` 의 모든 테이블 내용을 출력한다"]', 2, '`USE` 는 선택일 뿐 아무것도 지우거나 만들지 않습니다. 선택하지 않고 테이블 이름만 쓰면 "No database selected" 오류가 나요. 또는 `shop.customers` 처럼 DB 이름을 앞에 붙여도 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 6, '세미콜론을 빼먹으면', '`SHOW TABLES` 를 입력하고 Enter 를 쳤는데 결과가 안 나오고 프롬프트가 `    ->` 로 바뀌었습니다. 무슨 일일까요?', '명령이 끝났다는 표시를 하지 않았어요.', NULL, NULL, '[]', 'choice', '["서버가 고장 났다", "세미콜론(`;`)이 없어 명령이 아직 끝나지 않은 줄 알고 계속 입력을 기다리는 중이다", "데이터가 삭제됐다", "권한이 없다"]', 1, 'SQL 문장은 `;` 로 끝납니다. `->` 는 "이어서 입력하세요"라는 뜻이니 `;` 를 입력하고 Enter 하면 실행돼요. 포기하려면 `\\c` 를 입력해 현재 입력을 취소할 수 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 7, '테이블 구조 보기', '`customers` 테이블에 **어떤 컬럼이 있고 타입이 무엇인지** 보는 명령입니다. 빈칸을 채우세요.', '"설명하다(describe)"의 줄임말이에요.', NULL, NULL, '[]', 'fill', '["DESC", "SHOW", "USE", "SELECT"]', NULL, '`DESC 테이블;` (또는 `DESCRIBE`)은 컬럼 이름, 타입, NULL 허용 여부, 키, 기본값을 보여 줍니다. 처음 보는 테이블은 데이터를 보기 전에 구조부터 보는 것이 좋아요.', '[0]', '{0} customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 8, 'Key 칸의 PRI', '`DESC customers;` 결과에서 `id` 컬럼의 Key 칸이 `PRI` 입니다. 무슨 뜻일까요?', 'PRI 는 primary(기본)의 줄임말이에요.', NULL, NULL, '[]', 'choice', '["그 컬럼에는 비밀번호가 저장된다", "그 컬럼은 읽기 전용이다", "그 컬럼은 비어 있다", "기본 키(Primary Key). 각 행을 하나씩 구분하는 고유한 값이다"]', 3, '기본 키는 행마다 달라서 "이 행"을 정확히 가리킬 수 있게 합니다. 보통 `id` 같은 번호를 씁니다. 중복되거나 비어 있을 수 없어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 9, 'Null 칸의 YES', '`DESC` 결과에서 `email` 컬럼의 Null 칸이 `YES` 입니다. 무슨 뜻일까요?', 'NULL 은 "값이 없음"이에요.', NULL, NULL, '[]', 'choice', '["그 컬럼은 반드시 값이 있어야 한다", "그 컬럼은 숫자만 저장한다", "그 컬럼은 값이 비어 있어도(NULL) 괜찮다", "그 컬럼은 삭제 예정이다"]', 2, '`Null: YES` 는 NULL(값 없음)을 허용한다는 뜻입니다. `NO` 면 반드시 값이 있어야 해요. NULL 은 빈 문자열(`''''`)이나 0 과 다른 "모름"에 가깝습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 10, '처음 보는 데이터베이스를 구경하는 순서', '처음 접속한 서버의 `shop` 데이터베이스를 구경합니다. 순서에 맞게 놓아 보세요.', '큰 것(DB 목록)에서 작은 것(행)으로 내려가요.', NULL, NULL, '[]', 'order', '["`SHOW DATABASES;`", "`USE shop;`", "`SHOW TABLES;`", "`DESC customers;`", "`SELECT * FROM customers LIMIT 5;`"]', NULL, '목록 → 선택 → 테이블 목록 → 구조 → 일부 데이터 순서로 좁혀 가면 길을 잃지 않습니다. 마지막에 데이터를 볼 때 `LIMIT` 로 양을 제한하는 습관이 중요해요.', '[0, 1, 2, 3, 4]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 11, '데이터 조회의 기본 모양', '`customers` 테이블의 **모든 열, 모든 행**을 보는 문장입니다. 어디서 가져올지 알려 주는 키워드를 채우세요.', '"~로부터"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["FROM", "WHERE", "INTO", "JOIN"]', NULL, '`SELECT 무엇을 FROM 어디서;` 가 조회의 기본 뼈대입니다. `WHERE` 는 조건, `INTO` 는 저장 위치, `JOIN` 은 테이블 연결이라 역할이 달라요.', '[0]', 'SELECT * {0} customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 12, 'SELECT * 의 별표', '`SELECT * FROM customers;` 에서 `*` 는 무엇을 뜻할까요?', '선택할 열을 일일이 적지 않고 한꺼번에 가리키는 기호예요.', NULL, NULL, '[]', 'choice', '["모든 행을 삭제", "곱하기", "주석", "모든 컬럼"]', 3, '`*` 는 "모든 컬럼"입니다. 편하지만 운영에서는 필요한 컬럼만 적는 것이 좋습니다. 불필요한 데이터를 가져오면 느려지고 화면도 지저분해져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 13, '필요한 열만 골라 보기', '고객의 **이름과 이메일만** 보려 합니다. 이메일 컬럼 이름을 넣어 빈칸을 채우세요.', '컬럼은 쉼표로 이어서 적어요.', NULL, NULL, '[]', 'fill', '["email", "*", "FROM", "city"]', NULL, '보고 싶은 컬럼을 쉼표(`,`)로 이어 적으면 그 열만 나옵니다. 열이 많은 테이블에서 필요한 것만 보면 화면도 읽기 쉽고, 개인정보 노출도 줄일 수 있어요.', '[0]', 'SELECT name, {0} FROM customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 14, '큰 테이블에 SELECT * 를 쓰면', '로그가 수백만 건 쌓인 `logs` 테이블에서 `SELECT * FROM logs;` 를 실행했습니다. 어떤 문제가 생길 수 있을까요?', '모든 행을 한꺼번에 보내라는 명령이에요.', NULL, NULL, '[]', 'choice', '["아무 문제 없다", "수백만 행을 전부 가져와 서버와 내 화면이 느려지거나 멈출 수 있다. 처음에는 `LIMIT` 로 일부만 본다", "데이터가 자동으로 정리된다", "테이블이 삭제된다"]', 1, '운영 서버에서 큰 테이블의 전체 조회는 서버 부하와 네트워크 부담을 만듭니다. 처음에는 `SELECT * FROM logs LIMIT 10;` 처럼 맛보기부터 하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 15, '결과 행 수 제한하기', '`logs` 테이블에서 **처음 10행만** 보려 합니다. MariaDB 에서 행 수를 제한하는 키워드를 채우세요.', '"한계, 제한"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["LIMIT", "TOP", "FIRST", "ONLY"]', NULL, 'MariaDB 와 MySQL 은 `LIMIT n` 을 씁니다. `TOP` 은 다른 데이터베이스(SQL Server)에서 쓰는 방식이라 MariaDB 에서는 오류가 나요.', '[0]', 'SELECT * FROM logs {0} 10;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 16, 'LIMIT 5 가 보장하는 것', '`SELECT * FROM customers LIMIT 5;` 의 결과는 무엇을 보장할까요?', '"어떤 5행"인지에 대해서는 따로 정한 것이 없어요.', NULL, NULL, '[]', 'choice', '["가장 최근의 5행을 항상 돌려준다", "이름순으로 5행을 돌려준다", "아이디가 가장 작은 5행을 항상 돌려준다", "최대 5행만 돌려준다. 어떤 5행인지는 정렬을 정하지 않으면 보장되지 않는다"]', 3, '`LIMIT` 은 개수만 제한합니다. 순서가 중요하면 `ORDER BY` 를 함께 써야 해요(다음 세트에서 배웁니다). "최근 5건"은 `ORDER BY 시간 DESC LIMIT 5` 로 만들어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 17, '결과 열에 별명 붙이기', '`name` 컬럼을 결과에서 `customer_name` 이라는 **별명**으로 보려 합니다. 별명을 붙이는 키워드를 채우세요.', '"~로서"를 뜻하는 두 글자 영어 단어예요.', NULL, NULL, '[]', 'fill', '["AS", "IS", "TO", "BY"]', NULL, '`AS` 는 결과 열의 이름을 바꿔 보여 줄 뿐 테이블은 바꾸지 않습니다. 계산식 결과에 이름을 붙일 때(`COUNT(*) AS total`) 자주 쓰여요.', '[0]', 'SELECT name {0} customer_name FROM customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 18, '백틱(`)은 무엇을 감쌀까', 'SQL 에서 `order` 같은 이름을 쓸 때 ``` `order` ``` 처럼 백틱(`)으로 감쌉니다. 백틱은 무엇을 감싸는 데 쓸까요?', '문자열 값이 아니라 "이름"을 감싸요.', NULL, NULL, '[]', 'choice', '["문자열 값", "테이블이나 컬럼 같은 이름(특히 예약어나 공백이 든 이름)", "주석", "숫자"]', 1, '문자열 값은 작은따옴표(`''kim''`)로, 이름은 백틱으로 감쌉니다. 예약어(`order`, `group`)를 이름으로 쓰면 백틱이 필요해요. 헷갈리지 않게 예약어를 이름으로 안 쓰는 것이 좋습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 19, 'SELECT 문 조립하기', '`customers` 테이블에서 이름과 이메일을 **5행만** 보는 문장입니다. 조각을 순서대로 놓아 보세요.', '무엇을 → 어디서 → 몇 행까지 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT name, email`", "`FROM customers`", "`LIMIT 5;`"]', NULL, '`SELECT`(무엇을) → `FROM`(어디서) → `LIMIT`(몇 행) 순서입니다. 키워드 순서가 바뀌면 문법 오류가 나요.', '[0, 1, 2]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 20, 'SHOW DATABASES 와 SHOW TABLES', '`SHOW DATABASES;` 와 `SHOW TABLES;` 의 차이로 알맞은 것은 무엇일까요?', '하나는 서버 전체, 하나는 선택한 데이터베이스 안이에요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같은 명령이다", "앞은 테이블 목록, 뒤는 데이터베이스 목록", "앞은 사용자 목록, 뒤는 권한 목록", "앞은 서버의 데이터베이스 목록, 뒤는 현재 선택한 데이터베이스 안의 테이블 목록"]', 3, '뒤의 `SHOW TABLES;` 는 먼저 `USE 데이터베이스;` 로 선택해야 합니다. 선택하지 않았다면 "No database selected" 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 21, '지금 어디에 있는지 확인하기', '실수로 다른 데이터베이스에서 작업하지 않도록, ① 지금 **선택한 데이터베이스**와 ② **서버 버전**을 확인하는 함수입니다. 빈칸을 채우세요.', '이름 그대로 DATABASE, VERSION 입니다.', NULL, NULL, '[]', 'fill', '["DATABASE", "VERSION", "NOW", "USER"]', NULL, '`SELECT DATABASE();` 는 현재 선택된 DB 이름을 보여 줍니다. 운영 서버에서 데이터를 바꾸기 전에 습관으로 확인하면 잘못된 DB 에 작업하는 사고를 줄일 수 있어요. `NOW()` 는 현재 시각, `USER()` 는 접속 계정입니다.', '[0, 1]', 'SELECT {0}();   -- 지금 선택한 데이터베이스
SELECT {1}();   -- 서버 버전', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 22, '-- 는 무엇일까', 'SQL 문장 뒤에 `-- 테스트 중`(대시 두 개와 공백)을 붙였습니다. 이것은 무엇일까요?', '실행되지 않고 사람이 읽는 메모예요.', NULL, NULL, '[]', 'choice', '["두 값을 뺀다는 계산", "주석: 그 줄의 나머지는 실행되지 않는다", "오류를 무시하라는 명령", "테이블 이름을 바꾸는 명령"]', 1, '`-- ` (뒤에 공백 필수) 는 한 줄 주석입니다. `/* ... */` 로 여러 줄 주석도 쓸 수 있어요. 스크립트에 이유를 남길 때 유용합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 125, 23, '처음 보는 DB 에서 안전하게 확인하는 순서', '운영 중인 DB 에서 처음 보는 테이블을 안전하게 확인하려 합니다. 순서에 맞게 놓아 보세요.', '어디인지 → 구조 → 일부 → 범위 넓히기 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT DATABASE();` 로 지금 어느 DB 인지 확인한다", "`DESC 테이블;` 로 구조를 본다", "`SELECT ... LIMIT 10;` 으로 일부만 본다", "필요한 조건을 더해 범위를 넓힌다"]', NULL, '운영 DB 에서는 "어디서 하는지, 얼마나 가져오는지"를 먼저 확인하는 습관이 사고를 막습니다. 조회라도 큰 범위는 서버에 부담이 될 수 있어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 125 AND order_index = 23);
