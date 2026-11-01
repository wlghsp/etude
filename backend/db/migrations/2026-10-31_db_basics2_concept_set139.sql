-- 데이터베이스 세트 139. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set139.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 30, '데이터베이스', 'SQL 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 30);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 139, 'DB 기초 2 (개념): 조건과 정렬로 원하는 행만 골라 보기', 'SQL 로 원하는 행만 골라 보는 방법을 한 개념씩 반복합니다. WHERE 의 역할과 문자열 따옴표(Unknown column 오류), =·<>·AND·OR·IN·LIKE·%·BETWEEN, NULL 은 IS NULL 로 찾기, ORDER BY 의 ASC·DESC, ORDER BY DESC LIMIT 1 로 최댓값 행 찾기, DISTINCT, SELECT 절의 쓰는 순서를 짧은 객관식·빈칸·순서 문제로 익히고, SELECT 조립과 조건을 하나씩 좁혀 가기, 오류 풀기의 순서를 연습합니다.', 'quiz', '데이터베이스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 139);
UPDATE quest_set SET display_order = 539, unit_id = (SELECT id FROM unit WHERE id = 30), icon = '🎯' WHERE id = 139;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 1, 'WHERE 는 무엇을 할까', '`SELECT * FROM customers WHERE city = ''Seoul'';` 에서 `WHERE` 는 무엇을 할까요?', '모든 행 중에서 걸러 내는 조건이에요.', NULL, NULL, '[]', 'choice', '["열(컬럼)의 이름을 바꾼다", "테이블을 삭제한다", "조건에 맞는 행만 골라서 보여 준다", "결과를 정렬한다"]', 2, '`WHERE` 가 없으면 테이블의 모든 행이 나옵니다. 큰 테이블에서는 조건으로 좁혀서 필요한 행만 가져오는 것이 기본이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 2, '몇 행이 나올까', '`customers` 에는 kim(Seoul), lee(Busan), park(Seoul), choi(Daegu), jung(Busan) 이 있습니다. `WHERE city = ''Seoul''` 의 결과는 몇 행일까요?', 'city 가 Seoul 인 사람을 세어 보세요.', NULL, NULL, '[]', 'choice', '["1행 (kim)", "2행 (kim, park)", "3행 (kim, park, choi)", "5행 (모두)"]', 1, '조건에 맞는 행이 모두 나옵니다. 하나만 나오는 것이 아니에요. 결과가 0행일 수도 있고, 그것도 정상 결과입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 3, '문자열은 따옴표로', '`SELECT * FROM customers WHERE city = Seoul;` 을 실행하면 어떻게 될까요?', '따옴표가 없으면 이름으로 읽혀요.', NULL, NULL, '[]', 'choice', '["`Seoul` 을 컬럼 이름으로 읽어서 `Unknown column` 오류가 난다", "정상적으로 Seoul 인 행이 나온다", "모든 행이 나온다", "아무 일도 일어나지 않는다"]', 0, '문자열 값은 작은따옴표로 감쌉니다(`''Seoul''`). 숫자는 `id = 3` 처럼 따옴표 없이 써요. `Unknown column` 오류의 흔한 원인이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 4, '같지 않음', 'SQL 에서 "같지 않다"를 뜻하는 올바른 연산자는 무엇일까요?', '프로그래밍 언어마다 모양이 조금씩 달라요.', NULL, NULL, '[]', 'choice', '["`=!`", "`!==`", "`NOT=`", "`<>` 또는 `!=`"]', 3, '같다는 `=` 하나만 씁니다(`==` 아님). 같지 않다는 `<>` 또는 `!=` 둘 다 됩니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 5, 'OR 의 결과', '`WHERE city = ''Seoul'' OR city = ''Busan''` 의 결과는 몇 행일까요? (kim·park 은 Seoul, lee·jung 은 Busan, choi 는 Daegu)', 'OR 는 둘 중 하나만 맞아도 포함해요.', NULL, NULL, '[]', 'choice', '["2행 (kim, park)", "0행", "4행 (kim, lee, park, jung)", "5행 (모두)"]', 2, '`OR` 는 하나라도 맞으면, `AND` 는 둘 다 맞아야 포함합니다. 같은 컬럼의 여러 값은 `IN (''Seoul'', ''Busan'')` 으로 줄여 쓸 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 6, 'AND 의 결과', '`WHERE city = ''Seoul'' AND id > 1` 에 맞는 사람은 누구일까요? (kim 은 id 1, park 은 id 3, 둘 다 Seoul)', 'AND 는 두 조건이 모두 맞아야 해요.', NULL, NULL, '[]', 'choice', '["kim 한 명", "park 한 명", "kim 과 park 둘 다", "아무도 없다"]', 1, 'kim 은 city 는 맞지만 `id > 1` 이 아니라서 빠집니다. AND 를 쓸수록 결과는 줄어들어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 7, 'IN 은 무엇일까', '`WHERE city IN (''Seoul'', ''Daegu'')` 는 어떤 행을 골라낼까요?', '목록 중 하나와 같으면 돼요.', NULL, NULL, '[]', 'choice', '["city 가 Seoul 이거나 Daegu 인 행 (kim, park, choi)", "city 가 Seoul 이면서 Daegu 인 행", "city 가 Seoul 과 Daegu 를 뺀 나머지 행", "city 가 두 글자인 행"]', 0, '`IN` 은 `OR` 를 여러 번 쓰는 것을 짧게 줄인 것입니다. 목록이 길수록 읽기 편해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 8, 'LIKE 와 %', '`WHERE name LIKE ''p%''` 의 `%` 는 무엇을 뜻할까요?', '와일드카드, 즉 "아무거나"를 뜻해요.', NULL, NULL, '[]', 'choice', '["글자 p 가 정확히 한 번 나온다", "퍼센트(%) 기호가 이름에 들어 있다", "p 가 이름의 끝에 온다", "아무 글자가 몇 개든 올 수 있다 (그래서 p 로 시작하는 이름을 찾는다)"]', 3, '`''p%''` 는 p 로 시작, `''%p''` 는 p 로 끝, `''%p%''` 는 어디든 p 포함입니다. 위치를 정확히 알 때 `_` 는 글자 하나를 뜻해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 9, 'NULL 은 특별하다', '`WHERE email = NULL` 로 이메일이 비어 있는 행을 찾으려 합니다. 결과는 어떨까요?', 'NULL 은 "값이 없음"이라 같다 다르다를 따질 수 없어요.', NULL, NULL, '[]', 'choice', '["이메일이 비어 있는 행이 정확히 나온다", "모든 행이 나온다", "비교가 항상 거짓이라 한 행도 나오지 않는다. `IS NULL` 을 써야 한다", "오류가 나면서 서버가 멈춘다"]', 2, 'NULL 은 `=` 로 비교할 수 없고 `IS NULL`, `IS NOT NULL` 로만 확인합니다. 값이 빈 문자열('''')인 것과도 다른 개념이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 10, 'BETWEEN 의 범위', '`WHERE amount BETWEEN 5000 AND 12000` 은 amount 가 5000 과 12000 인 행도 포함할까요? (orders 의 amount 는 12000, 5000, 30000)', '양쪽 끝을 어떻게 다루는지 기억해 두세요.', NULL, NULL, '[]', 'choice', '["둘 다 포함하지 않는다", "둘 다 포함한다 (5000, 12000 두 행이 나온다)", "5000 만 포함한다", "12000 만 포함한다"]', 1, '`BETWEEN` 은 양쪽 끝 값을 포함합니다(`>= 5000 AND <= 12000`). 끝을 빼고 싶다면 `>` 와 `<` 를 따로 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 11, 'ORDER BY 의 기본 방향', '`ORDER BY amount` 처럼 방향을 쓰지 않으면 어떻게 정렬될까요?', '작은 값부터인지 큰 값부터인지 기억해 보세요.', NULL, NULL, '[]', 'choice', '["작은 값부터 큰 값 순서 (오름차순, ASC)", "큰 값부터 작은 값 순서", "정렬하지 않고 저장된 순서대로", "무작위 순서"]', 0, '큰 것부터 보려면 `ORDER BY amount DESC` 를 씁니다. 정렬을 쓰지 않으면 결과의 순서는 보장되지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 12, '가장 큰 값 한 줄', '`SELECT * FROM orders ORDER BY amount DESC LIMIT 1;` 은 어떤 행을 보여 줄까요? (amount 는 12000, 5000, 30000)', '큰 순서로 줄 세워 맨 앞 한 줄만 가져와요.', NULL, NULL, '[]', 'choice', '["amount 가 가장 작은 5000 인 행", "가장 먼저 저장된 행", "모든 행", "amount 가 가장 큰 30000 인 행"]', 3, '`ORDER BY ... DESC LIMIT 1` 은 "최댓값을 가진 행"을 찾는 가장 쉬운 방법입니다. `ASC` 로 바꾸면 가장 작은 행이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 13, '쓰는 순서', 'SELECT 문의 절은 어떤 순서로 쓸까요?', '"무엇을, 어디서, 어떤 조건으로, 어떻게 정렬해서, 몇 개"의 순서예요.', NULL, NULL, '[]', 'choice', '["`SELECT` → `ORDER BY` → `WHERE` → `FROM`", "`FROM` → `LIMIT` → `SELECT` → `WHERE`", "`SELECT` → `FROM` → `WHERE` → `ORDER BY` → `LIMIT`", "순서는 자유롭다"]', 2, '순서를 바꾸면 문법 오류가 납니다. 조건으로 먼저 거르고, 그 결과를 정렬하고, 마지막에 개수를 자른다고 생각하면 외우기 쉬워요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 14, 'DISTINCT 는 무엇일까', '`SELECT DISTINCT city FROM customers;` 는 몇 행을 보여 줄까요? (city 는 Seoul, Busan, Seoul, Daegu, Busan)', '중복된 값은 한 번만 보여 줘요.', NULL, NULL, '[]', 'choice', '["5행 (모두)", "3행 (Seoul, Busan, Daegu)", "2행", "1행"]', 1, '`DISTINCT` 는 결과에서 같은 값을 한 번만 남깁니다. 어떤 값들이 있는지 훑어볼 때 편해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 15, '조건 걸기', 'customers 에서 **조건에 맞는 행만** 고르려고 합니다. 빈칸을 채우세요.', '"~인 곳에서"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["WHERE", "WHEN", "IF", "FILTER"]', NULL, '`WHERE` 는 `FROM` 바로 뒤에 옵니다. 조건이 맞는 행만 결과에 나와요.', '[0]', 'SELECT * FROM customers {0} city = ''Seoul'';', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 16, '같다 쓰기', 'city 가 `Seoul` 과 **같은** 행을 찾는 연산자입니다. 빈칸을 채우세요.', 'SQL 에서는 기호 하나만 써요.', NULL, NULL, '[]', 'fill', '["=", "==", "is", "equals"]', NULL, 'SQL 의 "같다"는 `=` 하나입니다. 다른 언어처럼 `==` 를 쓰면 오류가 나요.', '[0]', 'SELECT * FROM customers WHERE city {0} ''Seoul'';', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 17, '같지 않다 쓰기', 'city 가 `Seoul` 이 **아닌** 행을 찾는 연산자입니다. 빈칸을 채우세요.', '작다와 크다를 나란히 써요.', NULL, NULL, '[]', 'fill', '["<>", "=!", "!==", "not"]', NULL, '`<>` 는 "작거나 크다", 즉 같지 않다입니다. `!=` 도 같은 뜻으로 쓸 수 있어요.', '[0]', 'SELECT * FROM customers WHERE city {0} ''Seoul'';', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 18, '두 조건 모두', 'city 가 `Seoul` **이면서** id 가 1 보다 큰 행을 찾으려 합니다. 빈칸을 채우세요.', '"그리고"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["AND", "&&&", "THEN", "ALSO"]', NULL, '`AND` 는 두 조건이 모두 맞아야 포함합니다. 조건을 더할수록 결과가 줄어드는 것이 정상이에요.', '[0]', 'SELECT * FROM customers WHERE city = ''Seoul'' {0} id > 1;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 19, '목록 중 하나', 'city 가 `Seoul` 또는 `Daegu` **중 하나**인 행을 찾는 키워드입니다. 빈칸을 채우세요.', '"~안에 있는"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["IN", "HAS", "AMONG", "EACH"]', NULL, '`IN (목록)` 은 `OR` 를 여러 번 쓰는 것과 같은 뜻입니다. 목록은 괄호 안에 쉼표로 구분해요.', '[0]', 'SELECT * FROM customers WHERE city {0} (''Seoul'', ''Daegu'');', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 20, '패턴으로 찾기', 'name 이 `p` 로 **시작하는** 행을 찾는 키워드입니다. 빈칸을 채우세요.', '"~와 비슷한"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["LIKE", "HAS", "MATCH", "START"]', NULL, '`LIKE` 는 `%`(아무 글자 몇 개든)나 `_`(글자 하나)와 함께 씁니다. 패턴은 따옴표로 감싸요.', '[0]', 'SELECT * FROM customers WHERE name {0} ''p%'';', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 21, '비어 있는 값 찾기', 'email 이 **NULL(값 없음)** 인 행을 찾는 올바른 모양입니다. 빈칸을 채우세요.', 'NULL 은 `=` 로 비교하지 않아요.', NULL, NULL, '[]', 'fill', '["IS", "=", "==", "LIKE"]', NULL, '`IS NULL` 은 비어 있는 값을, `IS NOT NULL` 은 값이 있는 행을 찾습니다. `= NULL` 은 항상 거짓이라 아무것도 나오지 않아요.', '[0]', 'SELECT * FROM customers WHERE email {0} NULL;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 22, '범위로 찾기', 'amount 가 5000 이상 12000 이하인 행을 찾는 키워드입니다. 빈칸을 채우세요.', '"~사이"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["BETWEEN", "INSIDE", "WITHIN", "RANGE"]', NULL, '`BETWEEN A AND B` 는 A 와 B 를 모두 포함합니다. 여기서 AND 는 범위의 끝을 나타내는 짝이에요.', '[0]', 'SELECT * FROM orders WHERE amount {0} 5000 AND 12000;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 23, '큰 것부터 정렬', 'amount 가 **큰 것부터** 보이도록 정렬하는 키워드입니다. 빈칸을 채우세요.', '내림차순을 뜻하는 descending 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["DESC", "DOWN", "BIG", "REVERSE"]', NULL, '`ASC` 는 오름차순(기본), `DESC` 는 내림차순입니다. 최신순이나 금액 큰 순서를 볼 때 자주 써요.', '[0]', 'SELECT * FROM orders ORDER BY amount {0};', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 24, '중복 없이 보기', 'city 의 **값 종류만** 중복 없이 보려고 합니다. 빈칸을 채우세요.', '"뚜렷이 다른"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["DISTINCT", "UNIQUE", "ONLY", "SINGLE"]', NULL, '`DISTINCT` 는 `SELECT` 바로 뒤에 씁니다. 있는 값의 종류를 빠르게 파악할 때 좋아요.', '[0]', 'SELECT {0} city FROM customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 25, '개수 줄이기', '큰 amount 순으로 정렬한 뒤 **맨 위 한 행만** 가져오려고 합니다. 빈칸을 채우세요.', '앞에서 배운 키워드예요.', NULL, NULL, '[]', 'fill', '["LIMIT", "TOP", "FIRST", "HEAD"]', NULL, '`LIMIT` 은 맨 마지막에 옵니다. 정렬 없이 `LIMIT` 만 쓰면 어느 행이 나올지 보장되지 않아요.', '[0]', 'SELECT * FROM orders ORDER BY amount DESC {0} 1;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 26, 'SELECT 문 조립하기', '`Seoul` 에 사는 고객의 이름과 도시를 이름순으로 보는 SQL 입니다. 줄의 순서에 맞게 놓아 보세요.', '무엇을 → 어디서 → 조건 → 정렬 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT name, city`", "`FROM customers`", "`WHERE city = ''Seoul''`", "`ORDER BY name;`"]', NULL, '`WHERE` 는 `FROM` 뒤, `ORDER BY` 는 `WHERE` 뒤에 옵니다. 마지막 절 끝에만 세미콜론을 붙여요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 27, '가장 큰 주문 찾기', '가장 금액이 큰 주문 한 건을 찾는 SQL 입니다. 줄의 순서에 맞게 놓아 보세요.', '모두 가져와서 → 큰 순으로 줄 세우고 → 하나만 자르는 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT *`", "`FROM orders`", "`ORDER BY amount DESC`", "`LIMIT 1;`"]', NULL, '정렬 방향을 `DESC` 로 두어야 큰 값이 맨 위로 올라옵니다. `ASC` 로 하면 가장 작은 주문이 나와요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 28, '조건을 하나씩 좁혀 가기', '조건을 하나씩 더하며 원하는 행으로 좁혀 가는 순서입니다. 순서에 맞게 놓아 보세요.', '전체 → 조건 1 → 조건 2 → 정렬 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT * FROM customers;` 로 전체를 본다", "`WHERE city = ''Seoul''` 을 붙여 행을 줄인다", "`AND id > 1` 을 더해 더 줄인다", "`ORDER BY name` 을 붙여 정렬해서 확인한다"]', NULL, '한 번에 복잡한 조건을 쓰기보다 하나씩 더하며 결과를 확인하면 실수를 줄일 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 139, 29, 'Unknown column 오류 풀기', '`Unknown column ''Seoul''` 오류가 났을 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '메시지 읽기 → 원인 짚기 → 고치기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["오류 메시지에 나온 `Seoul` 이 컬럼 이름으로 읽혔다는 것을 파악한다", "문자열 값인데 따옴표로 감싸지 않았는지 확인한다", "`WHERE city = ''Seoul''` 처럼 작은따옴표를 붙여 다시 실행한다", "결과가 의도한 행인지 확인한다"]', NULL, '오류 메시지에 나온 이름이 단서입니다. 값인데 컬럼으로 읽힌 경우가 대부분이에요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 139 AND order_index = 29);
