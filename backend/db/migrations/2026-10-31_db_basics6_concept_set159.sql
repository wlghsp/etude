-- 데이터베이스 세트 159. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set159.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 30, '데이터베이스', 'SQL 기초', 10 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 30);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 159, 'DB 기초 6 (개념): 데이터 바꾸기와 트랜잭션, INSERT·UPDATE·DELETE 안전하게', '데이터를 추가·수정·삭제하는 SQL 과 그 안전 습관을 한 개념씩 반복합니다. INSERT 의 열 목록과 ERROR 1136·1062·1364·1048, AUTO_INCREMENT 와 TRUNCATE, WHERE 없는 UPDATE·DELETE 의 위험, Rows matched 와 Changed 의 차이, sql_safe_updates 안전 모드, DELETE 와 TRUNCATE 의 차이, START TRANSACTION·COMMIT·ROLLBACK, 다른 세션에서 보이는 시점과 행 잠금, autocommit, DDL 의 암묵적 커밋을 짧은 객관식·빈칸·순서 문제로 익히고, 안전하게 값 바꾸기, WHERE 를 빠뜨렸을 때의 대응, 안전 모드, DDL 함정의 순서를 연습합니다.', 'quiz', '데이터베이스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 159);
UPDATE quest_set SET display_order = 539, unit_id = (SELECT id FROM unit WHERE id = 30), icon = '✍️' WHERE id = 159;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 1, 'INSERT 에 열 목록을 쓰는 이유', '`INSERT INTO c (name, city) VALUES (''kim'',''Seoul'')` 처럼 열 목록을 적는 가장 큰 이유는 무엇일까요?', '값이 어느 열로 들어가는지 분명해져요.', NULL, NULL, '[]', 'choice', '["적지 않으면 INSERT 가 항상 실패하기 때문이다", "열 목록을 적으면 더 빠르게 저장되기 때문이다", "값이 어느 열에 들어가는지 분명해지고 열 순서나 개수가 바뀌어도 안전하다 (개수가 맞지 않으면 `ERROR 1136`)", "열 목록은 문법상 필수가 아니라 아무 의미가 없다"]', 2, '열 목록 없이 `INSERT INTO c VALUES (...)` 로 쓰면 테이블의 모든 열을 순서대로 채워야 합니다. 개수가 하나라도 다르면 `Column count doesn''t match value count` 오류가 나요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 2, 'Duplicate entry 오류', '`ERROR 1062 (23000): Duplicate entry ''1'' for key ''PRIMARY''` 는 무슨 뜻일까요?', '같은 값이 이미 있어요.', NULL, NULL, '[]', 'choice', '["테이블이 존재하지 않는다", "기본키(또는 UNIQUE 키)가 이미 있는 값 `1` 이라서 같은 키의 행을 또 넣을 수 없다", "데이터 타입이 맞지 않는다", "권한이 없어서 거부되었다"]', 1, '이미 있는 행을 고치려면 `UPDATE`, 있으면 고치고 없으면 넣으려면 `INSERT ... ON DUPLICATE KEY UPDATE` 를 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 3, '1364 와 1048', 'NOT NULL 열 `name` 을 `INSERT` 에서 빠뜨렸을 때와 `NULL` 을 직접 넣었을 때의 오류로 알맞은 것은 무엇일까요?', '하나는 값이 없다는 오류, 하나는 NULL 이면 안 된다는 오류예요.', NULL, NULL, '[]', 'choice', '["빠뜨리면 `ERROR 1364 Field ''name'' doesn''t have a default value`, `NULL` 을 직접 넣으면 `ERROR 1048 Column ''name'' cannot be null`", "둘 다 `ERROR 1062` 이다", "빠뜨리면 성공하고 NULL 을 넣으면 오류가 난다", "둘 다 아무 오류 없이 빈 문자열로 들어간다"]', 0, '기본값이 없는 NOT NULL 열은 반드시 값을 줘야 합니다. 오류 번호를 알면 원인을 빨리 짚을 수 있어요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 4, 'AUTO_INCREMENT 와 삭제', 'id 가 1, 2, 3 인 테이블에서 마지막 행(id 3)을 지운 뒤 새 행을 넣으면 id 는 무엇이 될까요?', '번호는 한 번 쓰면 재사용하지 않아요.', NULL, NULL, '[]', 'choice', '["3 이 다시 사용된다", "항상 1 부터 다시 시작한다", "오류가 난다", "4 가 된다. 지운 번호를 재사용하지 않는다 (`DELETE` 로 전부 지워도 이어지고 `TRUNCATE` 만 1 로 초기화된다)"]', 3, '번호가 이어서 커지는 것은 정상입니다. 번호에 빈 곳이 있다고 해서 데이터가 사라진 것은 아니에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 5, 'WHERE 없는 UPDATE', '`UPDATE c SET city=''ALL''` 처럼 `WHERE` 없이 실행하면 어떻게 될까요?', '조건이 없으면 모든 행이 대상이에요.', NULL, NULL, '[]', 'choice', '["첫 번째 행만 바뀐다", "오류가 나면서 아무것도 바뀌지 않는다", "테이블의 모든 행이 바뀐다 (3행이 있으면 `Rows matched: 3  Changed: 3`)", "아무 행도 바뀌지 않는다"]', 2, '운영 DB 에서 가장 흔한 사고입니다. 실행하기 전에 같은 `WHERE` 로 먼저 `SELECT` 해서 대상 개수를 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 6, 'Changed 가 0 인 이유', '`UPDATE c SET city=''Daegu'' WHERE name=''lee''` 를 두 번째 실행했더니 `Rows matched: 1  Changed: 0` 입니다. 무슨 뜻일까요?', '찾은 행과 실제로 바뀐 행은 달라요.', NULL, NULL, '[]', 'choice', '["명령이 실패했다", "조건에 맞는 행은 1개 찾았지만, 이미 같은 값이라 실제로 바뀐 행은 없다", "행이 삭제되었다", "권한이 부족하다"]', 1, '`Rows matched` 는 조건에 맞은 행, `Changed` 는 값이 실제로 바뀐 행입니다. 둘이 다른 것은 오류가 아니에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 7, '바꾸기 전의 안전 습관', '운영 DB 의 데이터를 `UPDATE` 하기 전에 하면 좋은 안전한 습관은 무엇일까요?', '먼저 영향을 확인하고 되돌릴 방법을 만들어 둬요.', NULL, NULL, '[]', 'choice', '["같은 `WHERE` 로 먼저 `SELECT COUNT(*)` 를 해서 대상 개수를 확인하고, 트랜잭션 안에서 실행해 영향 행 수를 보고 `COMMIT` 한다", "바로 실행하고 틀렸으면 그때 고친다", "`WHERE` 를 최대한 짧게 쓴다", "다른 사람이 쓰지 않는 새벽에만 실행한다"]', 0, '`START TRANSACTION` 으로 시작해 영향 행 수가 예상과 같을 때만 `COMMIT` 하고, 다르면 `ROLLBACK` 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 8, 'sql_safe_updates', '`SET sql_safe_updates=1` 을 켠 세션에서 `UPDATE c SET city=''ALL''` 이나 `DELETE FROM c` 를 실행하면 어떻게 될까요?', '안전 모드가 막아 줘요.', NULL, NULL, '[]', 'choice', '["그대로 실행된다", "첫 번째 행만 바뀐다", "경고만 나오고 모든 행이 바뀐다", "`ERROR 1175 You are using safe update mode ...` 로 거부된다. 키 컬럼을 쓰는 `WHERE`(예: `WHERE id=1`)가 있어야 실행된다"]', 3, '키가 아닌 컬럼(`WHERE city=''Seoul''`)만 쓴 조건도 이 모드에서는 거부됩니다. 직접 SQL 을 치는 운영 계정에 켜 두면 사고를 크게 줄여요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 9, 'DELETE 와 TRUNCATE', '`DELETE FROM c` 와 `TRUNCATE TABLE c` 의 차이로 알맞은 것은 무엇일까요?', '하나는 행을 지우고, 하나는 테이블을 비워요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`TRUNCATE` 는 `ROLLBACK` 이 가능하고 `DELETE` 는 불가능하다", "`DELETE` 는 행 단위로 지우며 `WHERE` 를 쓸 수 있고 `ROLLBACK` 이 가능하다. `TRUNCATE` 는 테이블을 통째로 비우며 `WHERE` 를 쓸 수 없고 `ROLLBACK` 이 안 되고 `AUTO_INCREMENT` 가 초기화된다", "`DELETE` 가 항상 더 위험하다"]', 2, '`TRUNCATE` 는 모든 행을 지우는데도 `0 rows affected` 로 표시됩니다. 되돌릴 수 없으니 운영 DB 에서는 특히 조심하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 10, 'DELETE 가 0행일 때', '`DELETE FROM c WHERE id=99` 처럼 맞는 행이 없는 `DELETE` 를 실행하면 어떻게 될까요?', '조건에 맞는 것이 없다고 오류가 나는 것은 아니에요.', NULL, NULL, '[]', 'choice', '["항상 오류가 난다", "오류 없이 성공하며 `0 rows affected` 로 끝난다. 의도한 행이 지워졌는지 영향 행 수로 확인해야 한다", "테이블 전체가 삭제된다", "서버가 멈춘다"]', 1, '성공 메시지가 나와도 아무것도 지우지 못했을 수 있습니다. `rows affected` 숫자를 꼭 읽으세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 11, 'COMMIT 전의 변경', '세션 A 가 `START TRANSACTION` 으로 `UPDATE` 를 했지만 아직 `COMMIT` 하지 않았습니다. 세션 B 가 같은 행을 `SELECT` 하면 무엇이 보일까요?', '확정되지 않은 변경은 다른 세션에 보이지 않아요.', NULL, NULL, '[]', 'choice', '["세션 A 가 `COMMIT` 하기 전까지 B 는 변경 전의 옛 값을 본다. A 가 `ROLLBACK` 하면 영원히 보이지 않는다", "항상 새 값이 즉시 보인다", "오류가 나서 읽을 수 없다", "빈 값(NULL)이 보인다"]', 0, '`COMMIT` 한 뒤에야 다른 세션에 보입니다. 같은 행을 `UPDATE` 하려는 다른 세션은 A 가 끝날 때까지 기다리기도 해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 12, 'autocommit', '기본 설정(`@@autocommit = 1`)에서 `UPDATE` 한 문장을 실행하면 어떻게 될까요? 그리고 `SET autocommit=0` 후 `COMMIT` 없이 연결을 끊으면 어떻게 될까요?', '기본은 문장마다 바로 확정돼요.', NULL, NULL, '[]', 'choice', '["두 경우 모두 변경이 항상 남는다", "두 경우 모두 변경이 항상 사라진다", "기본에서는 `COMMIT` 하기 전에는 아무것도 반영되지 않는다", "기본에서는 문장 하나하나가 바로 `COMMIT` 되어 반영된다. `autocommit=0` 에서 `COMMIT` 없이 연결이 끊기면 변경은 사라진다"]', 3, '그래서 기본 설정에서는 실수로 실행한 `UPDATE` 를 `ROLLBACK` 할 수 없습니다. 위험한 작업은 `START TRANSACTION` 으로 시작하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 13, 'DDL 과 암묵적 커밋', '`START TRANSACTION` 으로 `INSERT` 한 뒤 같은 트랜잭션에서 `CREATE TABLE` 을 실행하고 `ROLLBACK` 했습니다. `INSERT` 한 행은 어떻게 될까요?', 'DDL 은 트랜잭션을 확정해 버려요.', NULL, NULL, '[]', 'choice', '["`ROLLBACK` 으로 `INSERT` 도 취소된다", "트랜잭션 전체가 오류로 취소된다", "`CREATE TABLE` 같은 DDL 이 앞의 변경을 자동으로 커밋해서 `ROLLBACK` 해도 `INSERT` 한 행은 남는다. `DROP TABLE` 도 `ROLLBACK` 할 수 없다", "`INSERT` 한 행이 NULL 로 바뀐다"]', 2, 'DDL 은 트랜잭션 밖에서 따로 실행하는 습관을 들이세요. 트랜잭션 안에 섞으면 되돌릴 수 있다고 착각하기 쉬워요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 14, '행 잠금과 기다림', '세션 A 가 `START TRANSACTION` 으로 `UPDATE ... WHERE id=1` 을 실행하고 아직 `COMMIT` 하지 않았습니다. 세션 B 가 같은 행 `id=1` 을 `UPDATE` 하면 어떻게 될까요?', '같은 행을 동시에 바꿀 수는 없어요.', NULL, NULL, '[]', 'choice', '["B 의 UPDATE 가 즉시 성공하고 A 의 변경은 사라진다", "A 가 `COMMIT` 이나 `ROLLBACK` 으로 끝낼 때까지 B 의 `UPDATE` 는 기다린다 (행 잠금). 그래서 오래 열려 있는 트랜잭션은 다른 작업을 막을 수 있다", "B 의 UPDATE 가 항상 오류로 즉시 실패한다", "서버가 자동으로 두 변경을 합쳐 준다"]', 1, '트랜잭션을 연 채 오래 두면 다른 사용자의 작업이 줄줄이 기다립니다. 작업을 마치면 바로 `COMMIT` 이나 `ROLLBACK` 하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 15, '값 목록 넣기', '`name`, `city` 열에 **값을 넣는** `INSERT` 문의 열 목록 부분을 채우세요.', '열 이름을 괄호로 묶어요.', NULL, NULL, '[]', 'fill', '["(name, city)", "[name, city]", "{name, city}", "name, city"]', NULL, '열 목록 뒤에 `VALUES` 를 쓰고, 값도 같은 개수와 순서로 괄호 안에 적습니다.', '[0]', 'INSERT INTO c {0} VALUES (''x'',''Seoul'')', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 16, '여러 행 한 번에', '행 여러 개를 한 번에 넣는 구문의 키워드를 채우세요.', '"값들"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["VALUES", "VALUE-LIST", "DATA", "SET"]', NULL, '여러 행은 괄호 묶음을 쉼표로 이어 씁니다. 결과에 `Records: 2` 처럼 넣은 개수가 나와요.', '[0]', 'INSERT INTO c (name) {0} (''a''), (''b'')', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 17, '바꿀 값 정하기', '`UPDATE` 에서 **바꿀 값을 정하는** 키워드를 채우세요.', '"정하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["SET", "TO", "VALUES", "CHANGE"]', NULL, '`SET 열=값` 으로 쓰고 여러 열은 쉼표로 이어요. `WHERE` 를 빠뜨리지 마세요.', '[0]', 'UPDATE c {0} city=''Daegu'' WHERE id=2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 18, '대상 조건 쓰기', '`UPDATE` 가 **대상 행을 고르는** 키워드를 채우세요. (빠뜨리면 모든 행이 바뀝니다)', '"~인 곳에서"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["WHERE", "HAVING", "IF", "ONLY"]', NULL, '`WHERE` 가 없으면 모든 행이 대상입니다. 실행 전에 같은 조건으로 `SELECT` 해서 확인하세요.', '[0]', 'UPDATE c SET city=''Daegu'' {0} id=2', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 19, '행 삭제', '`DELETE` 문에서 **어느 테이블에서 지울지** 정하는 키워드를 채우세요.', '"~로부터"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["FROM", "OF", "IN", "TABLE"]', NULL, '`DELETE FROM 테이블 WHERE 조건` 이 기본 모양입니다. `WHERE` 가 없으면 모든 행이 지워져요.', '[0]', 'DELETE {0} c WHERE id=3', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 20, '안전 모드 켜기', '`WHERE` 없는 `UPDATE`/`DELETE` 를 막는 세션 변수 이름을 채우세요.', '"안전한 갱신"을 뜻하는 이름이에요.', NULL, NULL, '[]', 'fill', '["sql_safe_updates", "safe_mode", "safe_updates_on", "protect_updates"]', NULL, '켠 세션에서는 `WHERE` 가 없거나 키 컬럼 조건이 없는 변경이 `ERROR 1175` 로 거부됩니다.', '[0]', 'SET {0}=1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 21, '트랜잭션 시작', '여러 문장을 한 묶음으로 처리하려고 **트랜잭션을 시작**하는 명령입니다. 빈칸을 채우세요.', '"거래, 처리"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["TRANSACTION", "TRAN", "SESSION", "TX"]', NULL, '`BEGIN` 으로도 시작할 수 있습니다. 시작한 뒤에는 반드시 `COMMIT` 이나 `ROLLBACK` 으로 끝내세요.', '[0]', 'START {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 22, '변경 확정하기', '트랜잭션의 변경을 **확정**하는 명령을 채우세요.', '"맡기다, 확정하다"를 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["COMMIT", "SAVE", "CONFIRM", "APPLY"]', NULL, '`COMMIT` 한 뒤에야 다른 세션에 변경이 보입니다. 되돌릴 수도 없어요.', '[0]', '{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 23, '변경 되돌리기', '트랜잭션의 변경을 **모두 취소**하는 명령을 채우세요.', '"뒤로 굴리다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["ROLLBACK", "UNDO", "REVERT", "CANCEL"]', NULL, '`COMMIT` 하기 전에만 쓸 수 있습니다. `TRUNCATE` 나 `DROP` 같은 DDL 은 되돌릴 수 없어요.', '[0]', '{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 24, '있으면 고치기', '넣으려는 키가 **이미 있으면 그 행을 고치는** 구문의 키워드를 채우세요.', '"고치다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["UPDATE", "REPLACE", "SET", "MODIFY"]', NULL, '이미 있던 행이 고쳐지면 `2 rows affected`, 새로 들어가면 `1 row affected` 로 표시됩니다.', '[0]', 'INSERT INTO c (id,name,city) VALUES (1,''a'',''X'') ON DUPLICATE KEY {0} city=VALUES(city)', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 25, '저장 지점까지 되돌리기', '`SAVEPOINT s1` 이후의 변경만 **취소하는** 구문의 빈칸을 채우세요.', '"~까지"라는 뜻의 아주 짧은 영어 단어예요.', NULL, NULL, '[]', 'fill', '["TO", "AT", "UNTIL", "BEFORE"]', NULL, '`s1` 이전의 변경은 그대로 남고 `COMMIT` 하면 확정됩니다. 긴 트랜잭션의 일부만 취소할 때 씁니다.', '[0]', 'ROLLBACK {0} s1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 26, '안전하게 값 바꾸기', '운영 DB 의 값을 안전하게 바꾸는 순서입니다. 순서에 맞게 놓아 보세요.', '대상 확인 → 트랜잭션 → 실행·확인 → 확정 순서예요.', NULL, NULL, '[]', 'order', '["같은 `WHERE` 로 `SELECT COUNT(*)` 를 먼저 해서 대상 개수를 본다", "`START TRANSACTION` 으로 트랜잭션을 시작한다", "`UPDATE ... WHERE ...` 를 실행하고 영향 행 수(`Rows matched`)가 예상과 같은지 본다", "예상과 같으면 `COMMIT`, 다르면 `ROLLBACK` 한다"]', NULL, '`ROLLBACK` 할 수 있는 것은 `COMMIT` 하기 전뿐입니다. 확인한 뒤에 확정하는 순서를 지키세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 27, 'WHERE 를 빠뜨려 전부 바꿨을 때', '`WHERE` 없이 `UPDATE` 를 실행해 버렸을 때의 대응 순서입니다. 순서에 맞게 놓아 보세요.', '상태 확인 → 되돌리기 → 범위 파악 → 복구 계획 순서예요.', NULL, NULL, '[]', 'order', '["`SELECT @@autocommit` 과 열려 있는 트랜잭션 여부로 지금 `ROLLBACK` 이 가능한지 확인한다", "트랜잭션 안이고 아직 `COMMIT` 하지 않았다면 즉시 `ROLLBACK` 한다", "이미 반영됐다면 `SELECT COUNT(*)` 로 영향 범위를 파악하고 추가 변경을 멈춘다", "백업(덤프)에서 복구할 계획을 세우고 담당자와 공유한다"]', NULL, '자동 커밋 상태에서 실행했다면 이미 반영된 것이라 `ROLLBACK` 으로는 되돌릴 수 없습니다. 그래서 위험한 작업은 처음부터 트랜잭션 안에서 해야 해요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 28, '안전 모드로 변경하기', '안전 모드를 켠 세션에서 변경하는 순서입니다. 순서에 맞게 놓아 보세요.', '켜기 → 막힘 확인 → 키 조건으로 다시 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`SET sql_safe_updates=1` 로 안전 모드를 켠다", "`UPDATE c SET city=''ALL''` 처럼 `WHERE` 없이 실행하면 `ERROR 1175` 로 막히는 것을 본다", "`WHERE id=1` 처럼 키 컬럼 조건을 붙여 다시 실행한다", "`Rows matched` 가 예상과 같은지 확인한다"]', NULL, '막히는 것은 불편이 아니라 안전장치입니다. 여러 행을 의도적으로 바꾸려면 세션에서 안전 모드를 끄고 신중히 실행하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 159, 29, 'DDL 이 낀 트랜잭션의 함정', '트랜잭션 안에 DDL 이 섞였을 때 벌어지는 일을 확인하는 순서입니다. 순서에 맞게 놓아 보세요.', '시작 → 변경 → DDL → 롤백 시도 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`START TRANSACTION` 후 `INSERT` 를 실행한다", "같은 트랜잭션에서 `CREATE TABLE` 을 실행한다 (앞의 변경이 자동으로 커밋된다)", "`ROLLBACK` 을 실행한다", "`SELECT` 로 `INSERT` 한 행이 그대로 남아 있는 것을 확인한다"]', NULL, 'DDL 은 트랜잭션 밖에서 따로 실행하는 습관을 들이면 이런 착각을 막을 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 159 AND order_index = 29);
