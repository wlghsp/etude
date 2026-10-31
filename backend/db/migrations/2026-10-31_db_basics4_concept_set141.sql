-- 데이터베이스 세트 141. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set141.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 30, '데이터베이스', 'SQL 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 30);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 141, 'DB 기초 4 (개념): JOIN 으로 두 테이블 이어서 보기', '두 테이블을 이어서 보는 JOIN 을 한 개념씩 쉬운 문제로 반복합니다. 테이블을 나누는 이유와 외래키, JOIN ... ON 으로 짝짓기, ON 을 빼먹으면 생기는 곱집합(15행), INNER JOIN 과 LEFT JOIN 의 결과 차이와 NULL 읽기, LEFT JOIN + IS NULL 로 짝 없는 행 찾기, 겹치는 컬럼의 ambiguous 오류와 테이블 별칭, JOIN + GROUP BY 합계, COUNT(*) 와 COUNT(o.id) 의 차이를 짧은 객관식·빈칸·순서 문제로 익히고, JOIN 쿼리 조립과 결과가 이상할 때의 점검 순서를 연습합니다.', 'quiz', '데이터베이스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 141);
UPDATE quest_set SET display_order = 539, unit_id = (SELECT id FROM unit WHERE id = 30), icon = '🔗' WHERE id = 141;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 1, '테이블을 왜 나눌까', '고객 정보(`customers`)와 주문 정보(`orders`)를 한 테이블에 합치지 않고 따로 두는 이유로 알맞은 것은 무엇일까요?', '고객 한 명이 주문을 여러 번 하면 어떻게 될지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["테이블이 많아야 데이터베이스가 빨라지기 때문이다", "한 테이블에는 컬럼을 5개까지만 둘 수 있기 때문이다", "고객 정보를 주문마다 반복해서 저장하지 않아 중복과 수정 실수를 줄일 수 있다", "SQL 이 테이블 하나만 읽을 수 있기 때문이다"]', 2, '고객의 이메일을 바꿀 때 `customers` 한 곳만 고치면 됩니다. 필요할 때 두 테이블을 이어서 보는 것이 `JOIN` 이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 2, '외래키는 무엇일까', '`orders` 의 `customer_id` 컬럼은 `customers` 의 `id` 를 가리킵니다. 이런 컬럼을 무엇이라고 부를까요?', '다른 테이블의 기본키를 가리켜요.', NULL, NULL, '[]', 'choice', '["기본키 (행을 구분하는 컬럼)", "외래키 (다른 테이블의 행을 가리키는 컬럼)", "인덱스 (검색을 빠르게 하는 장치)", "별칭 (임시 이름)"]', 1, '`orders.customer_id = 3` 은 "3번 고객의 주문"이라는 뜻입니다. `JOIN` 은 보통 이 외래키와 기본키를 짝지어 연결해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 3, 'INNER JOIN 의 결과', '`SELECT * FROM customers c JOIN orders o ON c.id = o.customer_id;` 는 몇 행을 보여 줄까요? (고객 5명, 주문 3건: 고객 1 이 2건, 고객 3 이 1건)', '양쪽에 짝이 있는 것만 나와요.', NULL, NULL, '[]', 'choice', '["3행 (kim 2건, park 1건)", "5행 (고객마다 한 줄)", "8행 (고객과 주문을 모두 더한 수)", "0행"]', 0, '`JOIN`(`INNER JOIN`)은 양쪽 모두 짝이 맞는 행만 보여 줍니다. 주문이 없는 고객은 결과에서 빠져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 4, 'ON 의 역할', '`JOIN orders o ON c.id = o.customer_id` 에서 `ON` 은 무엇을 정할까요?', '어떤 컬럼끼리 같을 때 짝으로 볼지 정해요.', NULL, NULL, '[]', 'choice', '["결과를 정렬하는 기준을 정한다", "결과의 개수를 제한한다", "테이블의 이름을 바꾼다", "두 테이블의 행을 어떤 컬럼 값이 같을 때 짝지을지 정한다"]', 3, '`ON` 을 잘못 쓰면 엉뚱한 짝이 이어집니다. 예를 들어 `c.id = o.id` 로 쓰면 3행이 나오긴 하지만 lee 가 5000 을 산 것처럼 틀린 결과가 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 5, 'ON 을 빼먹으면', '두 테이블을 조건 없이 이으면(`FROM customers, orders`) 몇 행이 나올까요? (고객 5명, 주문 3건)', '짝 조건이 없으면 모든 조합이 나와요.', NULL, NULL, '[]', 'choice', '["3행", "5행", "15행 (5 × 3, 모든 조합)", "8행"]', 2, '이런 결과를 곱집합(카르테시안 곱)이라고 합니다. 행 수가 갑자기 많이 나온다면 `ON` 을 빠뜨렸는지 먼저 의심하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 6, 'LEFT JOIN 의 결과', '`FROM customers c LEFT JOIN orders o ON c.id = o.customer_id` 는 몇 행을 보여 줄까요? (고객 5명, 주문 3건: 고객 1 이 2건, 고객 3 이 1건)', '왼쪽 테이블은 짝이 없어도 모두 나와요.', NULL, NULL, '[]', 'choice', '["3행", "6행 (kim 2건, park 1건, 주문 없는 lee·choi·jung 각 1줄)", "5행", "8행"]', 1, '`LEFT JOIN` 은 왼쪽(`customers`)의 모든 행을 남깁니다. 주문이 여러 건이면 그 고객은 여러 줄로 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 7, 'NULL 이 나왔다면', '`LEFT JOIN` 결과에서 lee 의 `amount` 칸이 `NULL` 입니다. 무슨 뜻일까요?', '오른쪽에서 짝을 찾지 못한 경우예요.', NULL, NULL, '[]', 'choice', '["lee 와 짝이 되는 주문이 `orders` 에 없다", "lee 의 주문 금액이 0 원이다", "쿼리에 오류가 있다", "lee 가 삭제되었다"]', 0, '짝이 없는 쪽의 칸은 NULL 로 채워집니다. 이 성질을 이용하면 "주문이 없는 고객" 같은 질문에 답할 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 8, '주문이 없는 고객 찾기', '주문이 한 건도 없는 고객을 찾는 방법으로 알맞은 것은 무엇일까요?', 'LEFT JOIN 에서 짝이 없으면 오른쪽 컬럼이 NULL 이에요.', NULL, NULL, '[]', 'choice', '["`INNER JOIN` 한 뒤 `WHERE o.id IS NULL` 로 거른다", "`ORDER BY o.id` 로 정렬해서 맨 위를 본다", "`COUNT(*)` 만 확인한다", "`LEFT JOIN` 한 뒤 `WHERE o.id IS NULL` 로 거른다"]', 3, '`INNER JOIN` 은 짝 없는 행이 이미 사라져서 이 방법이 안 통합니다. 결과는 lee, choi, jung 세 명이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 9, '열 이름이 겹칠 때', '`SELECT id FROM customers c JOIN orders o ON c.id = o.customer_id;` 를 실행하면 어떻게 될까요? (두 테이블 모두 `id` 컬럼이 있다)', '`id` 가 어느 테이블 것인지 알 수 없어요.', NULL, NULL, '[]', 'choice', '["customers 의 id 가 자동으로 나온다", "orders 의 id 가 자동으로 나온다", "`Column ''id'' in SELECT is ambiguous` 오류가 난다", "두 id 가 나란히 나온다"]', 2, '이름이 겹치는 컬럼은 `c.id`, `o.id` 처럼 테이블(별칭)을 앞에 붙여 구분합니다. 이 오류는 JOIN 에서 자주 만납니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 10, '테이블 별칭', '`FROM customers c JOIN orders o` 의 `c` 와 `o` 는 무엇일까요?', '쿼리 안에서만 쓰는 짧은 이름이에요.', NULL, NULL, '[]', 'choice', '["컬럼의 이름", "테이블에 붙인 별명 (쿼리 안에서만 쓰는 짧은 이름)", "테이블의 실제 이름이 바뀐 것", "데이터베이스의 이름"]', 1, '별칭을 쓰면 `customers.id` 대신 `c.id` 로 짧게 쓸 수 있습니다. 별칭은 그 쿼리가 끝나면 사라져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 11, 'INNER 와 LEFT 고르기', '"주문이 없는 고객도 목록에 함께 보고 싶다"면 어떤 JOIN 을 써야 할까요?', '짝이 없는 행도 남겨야 해요.', NULL, NULL, '[]', 'choice', '["`customers` 를 왼쪽에 두고 `LEFT JOIN` 을 쓴다", "`INNER JOIN` 을 쓴다", "`WHERE` 만 쓴다", "`DISTINCT` 를 쓴다"]', 0, '`INNER JOIN` 은 짝이 있는 행만, `LEFT JOIN` 은 왼쪽의 모든 행을 남깁니다. 보고 싶은 대상이 있는 테이블을 왼쪽에 두세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 12, 'JOIN 과 GROUP BY', '`SELECT c.name, SUM(o.amount) FROM customers c JOIN orders o ON c.id = o.customer_id GROUP BY c.name;` 의 결과는 무엇일까요? (kim 은 12000·5000, park 은 30000)', '이름마다 주문 금액을 더해요.', NULL, NULL, '[]', 'choice', '["kim 12000, park 30000 (2행)", "kim 17000, lee 0, park 30000, choi 0, jung 0 (5행)", "모든 고객이 47000", "kim 17000, park 30000 (2행)"]', 3, '`INNER JOIN` 이라 주문이 없는 고객은 나오지 않습니다. 모든 고객을 보려면 `LEFT JOIN` 으로 바꿔야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 13, 'COUNT(*) 와 COUNT(o.id)', '`LEFT JOIN` 후 고객별로 묶었을 때, 주문이 없는 lee 의 `COUNT(*)` 와 `COUNT(o.id)` 는 각각 얼마일까요?', '`COUNT(컬럼)` 은 NULL 을 세지 않아요.', NULL, NULL, '[]', 'choice', '["둘 다 0", "둘 다 1", "`COUNT(*)` 는 1, `COUNT(o.id)` 는 0", "`COUNT(*)` 는 0, `COUNT(o.id)` 는 1"]', 2, 'lee 는 NULL 인 줄이 1줄 있어서 `COUNT(*)` 는 1 이 됩니다. 주문 건수를 세려면 `COUNT(o.id)` 로 써야 정확해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 14, '왼쪽 테이블이 바뀌면', '`FROM orders o LEFT JOIN customers c ON c.id = o.customer_id` 는 몇 행을 보여 줄까요? (주문 3건, 모든 주문의 고객이 존재한다)', '이번에는 주문이 왼쪽이에요.', NULL, NULL, '[]', 'choice', '["5행", "3행 (주문이 왼쪽이라 주문 3건이 모두 나온다)", "6행", "15행"]', 1, '`LEFT JOIN` 은 "왼쪽 테이블 기준"입니다. 어느 테이블을 왼쪽에 두느냐에 따라 결과가 달라져요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 15, '두 테이블 잇기', 'customers 와 orders 를 **이어 붙이는** 키워드입니다. 빈칸을 채우세요.', '"합치다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["JOIN", "MERGE", "UNITE", "LINK"]', NULL, '`JOIN` 은 `ON` 과 짝으로 씁니다. 기본으로는 양쪽에 짝이 있는 행만 나와요.', '[0]', 'SELECT * FROM customers c {0} orders o ON c.id = o.customer_id;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 16, '이을 조건 쓰기', '두 테이블을 **어떤 조건으로 이을지** 적는 키워드입니다. 빈칸을 채우세요.', '"~위에서"를 뜻하는 아주 짧은 영어 단어예요.', NULL, NULL, '[]', 'fill', '["ON", "IF", "BY", "WITH"]', NULL, '`ON` 뒤에는 보통 `테이블A.기본키 = 테이블B.외래키` 가 옵니다.', '[0]', 'SELECT * FROM customers c JOIN orders o {0} c.id = o.customer_id;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 17, '왼쪽을 모두 남기기', '주문이 없는 고객도 **모두 남기도록** JOIN 의 종류를 채우세요.', '왼쪽을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["LEFT", "BOTH", "ALL", "FULL"]', NULL, '`LEFT JOIN` 은 왼쪽 테이블의 모든 행을 남깁니다. MariaDB 는 `FULL JOIN` 을 지원하지 않아 문법 오류가 나요.', '[0]', 'SELECT * FROM customers c {0} JOIN orders o ON c.id = o.customer_id;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 18, '고객 이름 뽑기', '고객 테이블(별칭 `c`)의 **이름 컬럼**을 가져오려고 합니다. 별칭을 채우세요.', '고객 테이블에 붙인 별칭이에요.', NULL, NULL, '[]', 'fill', '["c", "o", "customers.c", "name"]', NULL, '`name` 컬럼은 `customers` 에 있으니 별칭 `c` 를 앞에 붙입니다. 어느 테이블 컬럼인지 알 수 있어 읽기도 좋아요.', '[0]', 'SELECT {0}.name, o.amount FROM customers c JOIN orders o ON c.id = o.customer_id;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 19, '짝지을 컬럼', '주문의 **고객 번호 컬럼**과 고객 id 를 짝지으려 합니다. 빈칸을 채우세요.', '주문 테이블에서 고객을 가리키는 컬럼 이름이에요.', NULL, NULL, '[]', 'fill', '["customer_id", "orders", "id", "amount"]', NULL, '`o.id` 는 주문 자신의 번호라서 짝이 틀어집니다. 외래키(`customer_id`)와 기본키(`id`)를 짝지으세요.', '[0]', 'SELECT * FROM customers c JOIN orders o ON c.id = o.{0};', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 20, '주문 없는 고객 조건', '`LEFT JOIN` 후 **주문이 없는 고객만** 남기는 조건입니다. 빈칸을 채우세요.', 'NULL 은 `=` 로 비교하지 않아요.', NULL, NULL, '[]', 'fill', '["IS", "=", "==", "LIKE"]', NULL, '짝이 없으면 `o.id` 가 NULL 이 됩니다. `IS NULL` 로 찾으세요.', '[0]', 'SELECT c.name FROM customers c LEFT JOIN orders o ON c.id = o.customer_id WHERE o.id {0} NULL;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 21, '주문 금액 합계', '고객 이름별로 **주문 금액의 합계**를 구하려고 합니다. 함수를 채우세요.', '앞에서 배운 합계 함수예요.', NULL, NULL, '[]', 'fill', '["SUM", "JOIN", "ALL", "TOTAL"]', NULL, '`JOIN` 한 결과에도 `GROUP BY` 와 집계 함수를 그대로 쓸 수 있습니다.', '[0]', 'SELECT c.name, {0}(o.amount) AS total FROM customers c JOIN orders o ON c.id = o.customer_id GROUP BY c.name;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 22, '묶는 기준', '위 쿼리에서 **고객 이름마다 묶으려고** 합니다. 컬럼을 채우세요.', '고객 테이블(`c`)의 컬럼이에요.', NULL, NULL, '[]', 'fill', '["name", "total", "amount", "o.amount"]', NULL, '`SELECT` 에 쓴 일반 컬럼은 `GROUP BY` 에도 같이 씁니다. `total` 은 집계로 만든 별명이라 묶는 기준이 될 수 없어요.', '[0]', 'SELECT c.name, SUM(o.amount) FROM customers c JOIN orders o ON c.id = o.customer_id GROUP BY c.{0};', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 23, '주문 건수 세기', '고객별 **주문 건수**를 세려고 합니다(주문이 없으면 0). 별칭을 채우세요.', '주문 테이블의 별칭이에요.', NULL, NULL, '[]', 'fill', '["o", "c", "*", "name"]', NULL, '`COUNT(o.id)` 는 주문이 없어 NULL 이면 세지 않아 0 이 됩니다. `COUNT(c.id)` 로 쓰면 주문이 없어도 1 이 되어 틀려요.', '[0]', 'SELECT c.name, COUNT({0}.id) AS cnt FROM customers c LEFT JOIN orders o ON c.id = o.customer_id GROUP BY c.name;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 24, '주문 금액 큰 순', '주문 금액이 **큰 순서**로 보이도록 정렬하려고 합니다. 별칭을 채우세요.', 'amount 는 주문 테이블에 있어요.', NULL, NULL, '[]', 'fill', '["o", "c", "amount", "id"]', NULL, '정렬 기준에도 `테이블별칭.컬럼` 을 쓰면 명확합니다. 이름이 겹치지 않아도 습관으로 붙이는 것이 좋아요.', '[0]', 'SELECT c.name, o.amount FROM customers c JOIN orders o ON c.id = o.customer_id ORDER BY {0}.amount DESC;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 25, '테이블에 별명 붙이기', 'customers 테이블에 **짧은 별명 `c`** 를 붙이려고 합니다. 빈칸을 채우세요.', '테이블 이름 바로 뒤에 한 글자를 적어요.', NULL, NULL, '[]', 'fill', '["c", "c.id", "=c", "(c)"]', NULL, '테이블 이름 뒤에 공백을 두고 별칭을 적으면 됩니다(`AS c` 도 같은 뜻). 이후 쿼리에서는 `c.컬럼` 으로 불러요.', '[0]', 'SELECT c.name FROM customers {0} JOIN orders o ON c.id = o.customer_id;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 26, 'JOIN 쿼리 조립하기', '금액이 10000 이상인 주문의 고객 이름과 금액을 보는 SQL 입니다. 줄의 순서에 맞게 놓아 보세요.', '무엇을 → 어디서 → 이을 조건 → 거르기 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT c.name, o.amount`", "`FROM customers c`", "`JOIN orders o ON c.id = o.customer_id`", "`WHERE o.amount >= 10000;`"]', NULL, '`JOIN ... ON` 은 `FROM` 바로 뒤에 오고 `WHERE` 는 그 뒤에 옵니다. 결과는 kim(12000)과 park(30000) 이에요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 27, '주문 없는 고객 찾는 SQL', '주문이 없는 고객의 이름을 찾는 SQL 입니다. 줄의 순서에 맞게 놓아 보세요.', '무엇을 → 어디서 → 왼쪽 남기며 잇기 → 짝 없음 찾기 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT c.name`", "`FROM customers c`", "`LEFT JOIN orders o ON c.id = o.customer_id`", "`WHERE o.id IS NULL;`"]', NULL, '결과는 lee, choi, jung 입니다. `INNER JOIN` 이었다면 이 세 명이 이미 사라져 아무것도 나오지 않아요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 28, 'JOIN 결과가 이상할 때', 'JOIN 결과의 행 수가 예상과 다를 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '각각 확인 → 조건 확인 → 행 수 비교 → 고치기 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT * FROM customers;` 와 `SELECT * FROM orders;` 로 각 테이블의 데이터를 따로 본다", "`ON` 의 컬럼이 서로 짝이 맞는지(외래키와 기본키) 확인한다", "행 수를 예상과 비교한다 (곱집합이면 `ON` 이 빠졌을 가능성이 크다)", "고친 쿼리를 다시 실행해 결과를 눈으로 확인한다"]', NULL, 'JOIN 은 결과 행 수를 미리 어림해 보면 실수를 빨리 잡을 수 있습니다. 행 수가 갑자기 늘면 `ON` 부터 의심하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 141, 29, '새 JOIN 쿼리 만드는 순서', '처음 보는 두 테이블을 JOIN 해서 합계까지 구하는 순서입니다. 순서에 맞게 놓아 보세요.', '구조 확인 → JOIN 만 → 열과 조건 → 집계 순서예요.', NULL, NULL, '[]', 'order', '["`DESC orders;` 로 어떤 컬럼이 다른 테이블을 가리키는지 본다", "먼저 `JOIN ... ON` 만 쓰고 `SELECT *` 로 결과를 눈으로 본다", "필요한 열만 고르고 `WHERE` 조건을 더한다", "필요하면 `GROUP BY` 와 집계 함수로 요약한다"]', NULL, '한 번에 완성하려 하지 말고 단계마다 결과를 확인하세요. 문제가 생긴 단계를 바로 알 수 있어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 141 AND order_index = 29);
