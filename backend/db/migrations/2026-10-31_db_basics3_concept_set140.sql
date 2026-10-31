-- 데이터베이스 세트 140. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set140.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 30, '데이터베이스', 'SQL 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 30);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 140, 'DB 기초 3 (개념): 집계와 묶기로 숫자 요약하기', 'SQL 로 숫자를 요약하는 방법을 한 개념씩 쉬운 문제로 반복합니다. COUNT(*) 와 COUNT(컬럼)의 NULL 차이, SUM·AVG·MIN·MAX, GROUP BY 로 묶어 집계하기, WHERE 와 HAVING 의 차이, 조건에 맞는 행이 없을 때의 0 과 NULL, AS 별칭과 ORDER BY, COUNT(DISTINCT), SELECT 절의 쓰는 순서를 짧은 객관식·빈칸·순서 문제로 익히고, 도시별 고객 수, 합계가 큰 고객 찾기, 집계 결과 점검, Invalid use of group function 오류 풀기의 순서를 연습합니다.', 'quiz', '데이터베이스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 140);
UPDATE quest_set SET display_order = 539, unit_id = (SELECT id FROM unit WHERE id = 30), icon = '📊' WHERE id = 140;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 1, '집계 함수는 무엇일까', '`COUNT`, `SUM`, `AVG`, `MIN`, `MAX` 같은 집계 함수는 무엇을 할까요?', '여러 줄의 데이터를 한 줄로 요약해요.', NULL, NULL, '[]', 'choice', '["행을 한 줄씩 삭제한다", "테이블의 구조를 바꾼다", "여러 행의 값을 모아서 하나의 요약 값으로 계산한다", "결과를 정렬한다"]', 2, '"주문이 몇 건인가, 합계가 얼마인가" 같은 질문에 답할 때 씁니다. 결과가 한 줄로 줄어드는 것이 특징이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 2, 'COUNT(*) 는 무엇을 셀까', '`SELECT COUNT(*) FROM customers;` 의 결과는 얼마일까요? (customers 는 5행입니다)', '*(별표)는 "행 전체"를 뜻해요.', NULL, NULL, '[]', 'choice', '["1 (컬럼의 개수)", "5 (행의 개수)", "0", "4"]', 1, '`COUNT(*)` 는 NULL 이 섞여 있어도 행 자체를 셉니다. 테이블에 데이터가 몇 줄 있는지 볼 때 가장 먼저 쓰는 쿼리예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 3, 'COUNT(email) 은 다르다', 'customers 5행 중 2행의 email 이 NULL 일 때, `COUNT(*)` 와 `COUNT(email)` 의 결과는 각각 얼마일까요?', '컬럼 이름을 넣으면 그 컬럼이 NULL 이 아닌 행만 세요.', NULL, NULL, '[]', 'choice', '["`COUNT(*)` 는 5, `COUNT(email)` 은 3", "둘 다 5", "둘 다 3", "`COUNT(*)` 는 3, `COUNT(email)` 은 5"]', 0, '`COUNT(컬럼)` 은 NULL 을 건너뜁니다. 비어 있는 값을 찾을 때 이 차이를 이용해요(NULL 이 있는 컬럼에서 특히 중요합니다).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 4, 'SUM 의 결과', '`orders` 의 amount 는 12000, 5000, 30000 입니다. `SELECT SUM(amount) FROM orders;` 의 결과는 얼마일까요?', '세 값을 모두 더해 보세요.', NULL, NULL, '[]', 'choice', '["30000", "17000", "3", "47000"]', 3, '`SUM` 은 합계, 위 값을 더하면 47000 입니다. NULL 은 더하지 않고 건너뛰어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 5, 'AVG 의 결과', '`SELECT AVG(amount) FROM orders;` 의 결과에 가장 가까운 값은 무엇일까요? (amount 는 12000, 5000, 30000)', '합계 47000 을 행의 수 3 으로 나눠요.', NULL, NULL, '[]', 'choice', '["약 47000", "약 5000", "약 15666.67", "약 30000"]', 2, '평균은 `합계 ÷ 개수` 입니다. 소수점이 길게 나올 수 있어서 보기 좋게 하려면 `ROUND(AVG(amount), 0)` 처럼 둥글게 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 6, 'MIN 과 MAX', '`SELECT MIN(amount), MAX(amount) FROM orders;` 의 결과는 무엇일까요? (amount 는 12000, 5000, 30000)', '가장 작은 값과 가장 큰 값이에요.', NULL, NULL, '[]', 'choice', '["12000 과 30000", "5000 과 30000", "5000 과 12000", "47000 과 3"]', 1, '`MIN` 은 최솟값, `MAX` 는 최댓값입니다. 가장 최근 날짜나 가장 큰 번호를 찾을 때도 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 7, 'GROUP BY 는 무엇일까', '`GROUP BY city` 는 무엇을 할까요?', '같은 값끼리 모아서 따로 계산해요.', NULL, NULL, '[]', 'choice', '["city 값이 같은 행끼리 묶어서, 묶음마다 집계 함수를 계산한다", "city 가 같은 행을 하나만 남기고 삭제한다", "city 컬럼을 삭제한다", "city 를 알파벳 순서로 정렬만 한다"]', 0, '`GROUP BY` 없이 집계하면 전체에서 한 줄이 나오지만, `GROUP BY` 를 쓰면 묶음마다 한 줄이 나옵니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 8, '도시별 고객 수', '`SELECT city, COUNT(*) FROM customers GROUP BY city;` 는 몇 행을 보여 줄까요? (Seoul 2명, Busan 2명, Daegu 1명)', '도시의 종류만큼 한 줄씩 나와요.', NULL, NULL, '[]', 'choice', '["5행 (고객마다 한 줄)", "1행", "2행", "3행 (Seoul 2, Busan 2, Daegu 1)"]', 3, '그룹의 개수만큼 줄이 나옵니다. 어떤 도시가 먼저 나오는지는 `ORDER BY` 를 쓰지 않으면 보장되지 않아요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 9, '고객별 주문 합계', '`SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id;` 의 결과는 무엇일까요? (orders: 고객 1 이 12000·5000, 고객 3 이 30000)', '고객 번호마다 amount 를 더해요.', NULL, NULL, '[]', 'choice', '["고객 1 은 12000, 고객 3 은 30000", "모두 47000", "고객 1 은 17000, 고객 3 은 30000", "고객 1 은 5000, 고객 3 은 30000"]', 2, '고객 1 은 12000 + 5000 = 17000 입니다. "누가 얼마를 샀는가"처럼 묶어서 보는 질문에 `GROUP BY` 를 써요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 10, 'WHERE 와 HAVING', '`WHERE` 와 `HAVING` 의 차이로 알맞은 것은 무엇일까요?', '하나는 묶기 전, 하나는 묶은 뒤에 거를 때 써요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`WHERE` 는 묶기 전의 행을 거르고, `HAVING` 은 묶은 뒤의 집계 결과에 조건을 건다", "`WHERE` 는 집계 결과에, `HAVING` 은 일반 행에 쓴다", "`HAVING` 은 정렬하는 데 쓴다"]', 1, '"합계가 2만 이상인 고객"처럼 집계 결과에 조건을 걸려면 `HAVING SUM(amount) >= 20000` 이어야 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 11, 'HAVING 의 결과', '`GROUP BY customer_id HAVING SUM(amount) >= 20000` 에 남는 고객은 누구일까요? (고객 1 의 합계 17000, 고객 3 의 합계 30000)', '합계가 2만 이상인 그룹만 남아요.', NULL, NULL, '[]', 'choice', '["고객 3 한 명", "고객 1 한 명", "고객 1 과 고객 3 둘 다", "아무도 남지 않는다"]', 0, '고객 1 의 합계 17000 은 조건에 못 미쳐 그룹째 빠집니다. `HAVING` 은 그룹 단위로 걸러요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 12, '조건에 맞는 행이 없을 때', '`SELECT COUNT(*), SUM(amount) FROM orders WHERE amount > 99999;` 처럼 조건에 맞는 행이 없으면 결과는 어떨까요?', '개수는 0 이지만 합계는 "값 없음"이에요.', NULL, NULL, '[]', 'choice', '["둘 다 0", "둘 다 NULL", "오류가 난다", "`COUNT(*)` 는 0, `SUM(amount)` 는 NULL"]', 3, '`COUNT` 는 0 을 돌려주고, `SUM`, `AVG`, `MAX`, `MIN` 은 NULL 을 돌려줍니다. 화면에 NULL 이 보여도 오류가 아니에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 13, 'AS 별칭', '`SELECT COUNT(*) AS cnt FROM customers;` 에서 `AS cnt` 는 무엇을 할까요?', '결과의 제목을 정해 줘요.', NULL, NULL, '[]', 'choice', '["컬럼을 새로 만든다", "결과를 `cnt` 개로 제한한다", "결과 열의 이름을 `cnt` 로 붙인다 (뒤에서 `ORDER BY cnt` 처럼 쓸 수 있다)", "`customers` 테이블 이름을 바꾼다"]', 2, '`COUNT(*)` 처럼 긴 열 이름을 읽기 쉽게 바꾸고, 정렬할 때 이름으로 부르기 편해집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 14, '절 쓰는 순서', '집계를 쓰는 SELECT 문의 절은 어떤 순서로 쓸까요?', '묶기와 걸러 내기가 새로 들어가요.', NULL, NULL, '[]', 'choice', '["`SELECT` → `FROM` → `GROUP BY` → `WHERE` → `HAVING`", "`SELECT` → `FROM` → `WHERE` → `GROUP BY` → `HAVING` → `ORDER BY` → `LIMIT`", "`SELECT` → `HAVING` → `GROUP BY` → `FROM`", "`FROM` → `SELECT` → `ORDER BY` → `GROUP BY`"]', 1, '묶기 전에 `WHERE` 로 행을 거르고, 묶은 뒤에 `HAVING` 으로 그룹을 거르는 순서입니다. 순서가 틀리면 문법 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 15, '행의 개수 세기', 'customers 의 **행이 몇 개인지** 세는 함수입니다. 빈칸을 채우세요.', '"세다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["COUNT", "NUMBER", "TOTAL", "LENGTH"]', NULL, '`COUNT(*)` 는 행 전체의 개수를 셉니다. 데이터가 얼마나 있는지 확인할 때 가장 먼저 써요.', '[0]', 'SELECT {0}(*) FROM customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 16, '합계 구하기', 'orders 의 amount **합계**를 구하는 함수입니다. 빈칸을 채우세요.', '"합계"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["SUM", "PLUS", "ADD", "TOTAL"]', NULL, '`SUM` 은 숫자 컬럼에 씁니다. 문자 컬럼에 쓰면 의미 없는 값이 나오거나 오류가 날 수 있어요.', '[0]', 'SELECT {0}(amount) FROM orders;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 17, '평균 구하기', 'orders 의 amount **평균**을 구하는 함수입니다. 빈칸을 채우세요.', 'average 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["AVG", "MEAN", "AVERAGE", "MID"]', NULL, '`AVG` 는 NULL 을 제외하고 평균을 냅니다. 소수점이 길면 `ROUND` 로 둥글게 하세요.', '[0]', 'SELECT {0}(amount) FROM orders;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 18, '가장 큰 값', 'orders 의 amount 중 **가장 큰 값**을 구하는 함수입니다. 빈칸을 채우세요.', 'maximum 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["MAX", "TOP", "BIG", "HIGH"]', NULL, '`MAX` 는 최댓값입니다. 가장 최근 날짜나 가장 큰 번호를 찾을 때도 같이 써요.', '[0]', 'SELECT {0}(amount) FROM orders;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 19, '가장 작은 값', '고객별로 **가장 작은 주문 금액**을 구하려고 합니다. 함수를 채우세요.', 'minimum 의 줄임이에요.', NULL, NULL, '[]', 'fill', '["MIN", "LOW", "LESS", "SMALL"]', NULL, '`GROUP BY` 와 함께 쓰면 그룹마다 최솟값이 나옵니다. 고객 1 은 5000, 고객 3 은 30000 이에요.', '[0]', 'SELECT customer_id, {0}(amount) FROM orders GROUP BY customer_id;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 20, '도시별로 묶기', '도시마다 **묶어서** 고객 수를 세려고 합니다. 빈칸을 채우세요.', '"묶다"라는 뜻이 들어가요.', NULL, NULL, '[]', 'fill', '["GROUP BY", "ORDER BY", "SORT BY", "SET BY"]', NULL, '`GROUP BY` 의 컬럼은 `SELECT` 의 일반 컬럼과 같아야 합니다. `ORDER BY` 는 줄 세우기만 하고 묶지는 않아요.', '[0]', 'SELECT city, COUNT(*) FROM customers {0} city;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 21, '묶은 뒤에 조건 걸기', '고객별 합계가 **20000 이상인 그룹만** 남기려고 합니다. 빈칸을 채우세요.', '집계 결과에 거는 조건이에요.', NULL, NULL, '[]', 'fill', '["HAVING", "WHERE", "IF", "WHEN"]', NULL, '`WHERE` 에 `SUM(...)` 을 쓰면 `Invalid use of group function` 오류가 납니다. 집계 결과의 조건은 `HAVING` 입니다.', '[0]', 'SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id {0} SUM(amount) >= 20000;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 22, '열 이름 붙이기', '결과 열에 **`cnt` 라는 이름을 붙이려고** 합니다. 빈칸을 채우세요.', '앞에서 배운 별명 키워드예요.', NULL, NULL, '[]', 'fill', '["AS", "IS", "NAME", "TO"]', NULL, '`AS` 는 생략할 수도 있지만 쓰는 것이 읽기 쉽습니다. 별명에 공백이 필요하면 백틱으로 감싸요.', '[0]', 'SELECT COUNT(*) {0} cnt FROM customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 23, '종류만 세기', '고객이 사는 **도시의 종류가 몇 가지인지** 세려고 합니다. 빈칸을 채우세요.', '중복 없이 보는 키워드예요.', NULL, NULL, '[]', 'fill', '["DISTINCT", "UNIQUE", "ONLY", "EACH"]', NULL, '`COUNT(DISTINCT 컬럼)` 은 같은 값을 한 번만 셉니다. 여기서는 3(Seoul, Busan, Daegu)이에요.', '[0]', 'SELECT COUNT({0} city) FROM customers;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 24, '묶기 전에 거르기', 'id 가 1 보다 큰 고객만 **먼저 거른 뒤** 도시별로 세려고 합니다. 빈칸을 채우세요.', '묶기 전에는 일반 행에 조건을 걸어요.', NULL, NULL, '[]', 'fill', '["WHERE", "HAVING", "IF", "ONLY"]', NULL, '`WHERE` 는 `GROUP BY` 앞에 옵니다. 집계하기 전에 행을 줄이면 계산량도 줄어요.', '[0]', 'SELECT city, COUNT(*) FROM customers {0} id > 1 GROUP BY city;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 25, '많은 순서로 정렬', '도시별 고객 수를 **많은 도시부터** 보여 주려고 합니다. 정렬 기준에 쓸 별명을 채우세요.', '`AS` 로 붙인 이름이에요.', NULL, NULL, '[]', 'fill', '["cnt", "count", "number", "n"]', NULL, '집계 결과도 별명을 붙이면 `ORDER BY` 에서 이름으로 정렬할 수 있습니다. 별명을 쓰지 않으면 `COUNT(*)` 를 그대로 써야 해요.', '[0]', 'SELECT city, COUNT(*) AS cnt FROM customers GROUP BY city ORDER BY {0} DESC;', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 26, '도시별 고객 수를 많은 순으로', '도시별 고객 수를 많은 순서대로 보는 SQL 입니다. 줄의 순서에 맞게 놓아 보세요.', '무엇을 → 어디서 → 묶기 → 정렬 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT city, COUNT(*) AS cnt`", "`FROM customers`", "`GROUP BY city`", "`ORDER BY cnt DESC;`"]', NULL, '`GROUP BY` 는 `FROM` 뒤, `ORDER BY` 는 `GROUP BY` 뒤에 옵니다. 별명 `cnt` 로 정렬할 수 있어요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 27, '합계가 큰 고객만 보기', '고객별 주문 합계가 20000 이상인 고객을 보는 SQL 입니다. 줄의 순서에 맞게 놓아 보세요.', '무엇을 → 어디서 → 묶기 → 그룹 조건 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT customer_id, SUM(amount)`", "`FROM orders`", "`GROUP BY customer_id`", "`HAVING SUM(amount) >= 20000;`"]', NULL, '`HAVING` 은 `GROUP BY` 뒤에 옵니다. 결과로 고객 3 한 명이 나옵니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 28, '집계 결과가 이상할 때 점검', '집계 결과가 예상과 다를 때의 점검 순서입니다. 순서에 맞게 놓아 보세요.', '원본 → 조건 → NULL → 다시 집계 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT * FROM orders;` 로 원본 데이터를 먼저 본다", "`WHERE` 조건이 의도한 행만 남기는지 확인한다", "NULL 이 섞여 있어 `COUNT(컬럼)` 이나 `AVG` 가 달라지지 않았는지 본다", "고친 쿼리로 다시 집계해 값을 비교한다"]', NULL, '집계는 원본 데이터를 눈으로 본 뒤 검증해야 합니다. 먼저 몇 줄이 들어가는지부터 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 140, 29, 'Invalid use of group function 풀기', '`Invalid use of group function` 오류가 났을 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '오류 읽기 → 위치 짚기 → 옮기기 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["오류 메시지가 집계 함수를 잘못된 곳에 썼다는 뜻임을 파악한다", "`WHERE` 에 `SUM(...)` 같은 집계 함수를 쓰지 않았는지 찾는다", "집계 결과에 거는 조건이면 `GROUP BY` 뒤의 `HAVING` 으로 옮긴다", "다시 실행해 결과가 의도한 그룹인지 확인한다"]', NULL, '`WHERE` 는 묶기 전이라 아직 집계 값이 없습니다. 집계 값에 대한 조건은 반드시 `HAVING` 에 써요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 140 AND order_index = 29);
