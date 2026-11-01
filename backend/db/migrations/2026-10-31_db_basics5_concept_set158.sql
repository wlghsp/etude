-- 데이터베이스 세트 158. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set158.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 20, '데이터베이스', 'MariaDB 운영', 20 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 20);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 158, 'DB 기초 5 (개념): 운영자가 자주 쓰는 SQL, 세션·설정·권한·실행 계획', 'MariaDB 를 운영할 때 가장 먼저 쓰는 SQL 을 한 개념씩 반복합니다. SHOW PROCESSLIST 와 FULL, Time 열 읽기, KILL QUERY 와 KILL 의 차이(연결 유지 여부), SHOW VARIABLES 와 STATUS 의 차이, SET GLOBAL 이 재시작하면 사라지는 것, CREATE USER·GRANT·SHOW GRANTS·REVOKE 와 ERROR 1142, 계정 이름@위치와 USER()·CURRENT_USER(), information_schema 로 DB 크기 보기, EXPLAIN 의 type 과 인덱스를 못 쓰는 조건을 짧은 객관식·빈칸·순서 문제로 익히고, 느린 쿼리 중단, 앱 전용 계정 만들기, 권한 오류 풀기, 인덱스로 느린 조회 개선하기의 순서를 연습합니다.', 'quiz', '데이터베이스'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 158);
UPDATE quest_set SET display_order = 539, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '🧮' WHERE id = 158;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 1, 'PROCESSLIST 란', '`SHOW PROCESSLIST` 는 무엇을 보여 줄까요?', '지금 서버에 붙어 있는 사람들의 목록이에요.', NULL, NULL, '[]', 'choice', '["저장된 모든 테이블의 목록", "서버의 설정값 목록", "서버에 연결된 세션과 지금 실행 중인 쿼리 목록 (Id, User, Host, db, Command, Time, State, Info)", "지금까지 실행한 모든 쿼리의 기록"]', 2, '쿼리를 하지 않고 연결만 유지하는 세션은 `Command` 가 `Sleep` 으로 보입니다. 서버가 느릴 때 가장 먼저 보는 명령이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 2, 'Time 열 읽기', '`SHOW PROCESSLIST` 의 `Time` 열 값이 `1800` 인 `Query` 행이 있습니다. 무슨 뜻일까요?', '그 상태로 머문 시간이에요. 단위는 초예요.', NULL, NULL, '[]', 'choice', '["그 세션이 1800개의 쿼리를 실행했다", "그 쿼리가 약 1800초(30분) 동안 실행 중이라는 뜻이라 오래 걸리는 쿼리의 후보이다", "서버가 1800번 재시작했다", "1800번째 접속이다"]', 1, '`Info` 열의 쿼리 문장과 함께 보면 어떤 작업이 오래 걸리는지 알 수 있습니다. `State` 도 단서가 돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 3, 'Info 가 잘릴 때', '`SHOW PROCESSLIST` 의 `Info` 열에 긴 쿼리가 중간까지만 보입니다. 전체를 보려면 어떻게 할까요?', '목록 이름 앞에 한 단어를 더해요.', NULL, NULL, '[]', 'choice', '["`SHOW FULL PROCESSLIST` 를 쓴다 (기본은 100자까지만 보여 준다)", "`SHOW LONG PROCESSLIST` 를 쓴다", "`SHOW PROCESSLIST` 를 두 번 실행한다", "서버를 재시작한다"]', 0, '긴 쿼리가 100자에서 잘리면 어떤 쿼리인지 알기 어렵습니다. `FULL` 을 붙이면 전체 문장이 나와요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 4, 'KILL QUERY', '`KILL QUERY 12` 를 실행하면 12번 세션은 어떻게 될까요?', '문장만 끊고 연결은 둬요.', NULL, NULL, '[]', 'choice', '["연결이 끊기고 세션이 사라진다", "서버가 종료된다", "아무 일도 일어나지 않는다", "실행 중인 쿼리만 중단되고(`Query execution was interrupted`), 연결은 그대로 유지된다"]', 3, '같은 연결 번호(`CONNECTION_ID()`)로 다음 쿼리를 계속 실행할 수 있습니다. 앱의 연결 풀은 유지돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 5, 'KILL 과 KILL QUERY 의 차이', '`KILL 12` 와 `KILL QUERY 12` 의 차이로 알맞은 것은 무엇일까요?', '하나는 문장만, 하나는 연결 전체예요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`KILL QUERY` 가 연결을 끊고 `KILL` 은 쿼리만 중단한다", "`KILL 12` 는 연결 자체를 끊고(클라이언트는 `Lost connection` / `Server has gone away`), `KILL QUERY 12` 는 쿼리만 중단하고 연결은 유지한다", "둘 다 서버를 재시작한다"]', 2, '문제 있는 쿼리 하나만 멈추고 싶다면 `KILL QUERY` 가 더 부드럽습니다. 연결이 쓸모없어졌을 때만 `KILL` 을 쓰세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 6, 'VARIABLES 와 STATUS', '`SHOW VARIABLES` 와 `SHOW STATUS` 의 차이로 알맞은 것은 무엇일까요?', '하나는 설정, 하나는 현재 상태예요.', NULL, NULL, '[]', 'choice', '["둘은 완전히 같다", "`VARIABLES` 는 서버의 설정값(`max_connections` 등)을, `STATUS` 는 현재 상태와 통계(`Threads_connected`, `Uptime` 등)를 보여 준다", "`VARIABLES` 는 현재 상태, `STATUS` 는 설정값이다", "둘 다 테이블 목록을 보여 준다"]', 1, '`SHOW VARIABLES LIKE ''max_conn%''` 처럼 `LIKE` 로 이름을 걸러 보는 것이 편합니다. 현재 연결 수가 한도에 가까운지 두 값을 비교하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 7, 'SET GLOBAL 의 한계', '`SET GLOBAL max_connections = 300` 으로 값을 바꿨습니다. 서버를 재시작하면 어떻게 될까요?', '명령으로 바꾼 값은 메모리에만 있어요.', NULL, NULL, '[]', 'choice', '["재시작하면 원래 값(설정 파일의 값)으로 돌아간다. 유지하려면 설정 파일(`my.cnf` 등)에도 적어야 한다", "항상 300 이 유지된다", "서버가 시작되지 않는다", "값이 자동으로 파일에 저장된다"]', 0, '바로 적용되는 장점이 있지만 영구적이지 않습니다. 운영에서는 변경 내용을 설정 파일에도 남겨 두세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 8, 'CREATE USER 직후의 권한', '`CREATE USER ''app''@''%'' IDENTIFIED BY ''pw''` 만 실행한 계정의 권한은 어떨까요?', '계정을 만드는 것과 권한을 주는 것은 별개예요.', NULL, NULL, '[]', 'choice', '["모든 데이터베이스를 읽고 쓸 수 있다", "관리자 권한을 가진다", "계정이 만들어지지 않는다", "로그인만 가능하고 데이터에 대한 권한은 없다 (`SHOW GRANTS` 에 `GRANT USAGE ON *.*` 만 보인다)"]', 3, '필요한 권한은 `GRANT` 로 따로 줍니다. 처음에는 가장 적은 권한만 주고 필요할 때 늘리는 것이 안전해요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 9, 'GRANT SELECT 의 범위', '`GRANT SELECT ON shop.* TO ''app''@''%''` 를 받은 계정이 `shop.customers` 에 `DELETE` 를 실행하면 어떻게 될까요?', '읽기 권한만 줬어요.', NULL, NULL, '[]', 'choice', '["정상적으로 삭제된다", "SELECT 권한이 자동으로 취소된다", "`ERROR 1142 ... DELETE command denied ...` 로 거부된다. 권한은 GRANT 직후 바로 적용되며 `FLUSH PRIVILEGES` 는 필요 없다", "서버가 종료된다"]', 2, '`FLUSH PRIVILEGES` 는 `mysql` 시스템 테이블을 직접 고쳤을 때만 필요합니다. `GRANT`, `REVOKE` 는 곧바로 반영돼요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 10, '계정 이름의 두 부분', '`''app''@''%''` 에서 `app` 과 `%` 는 각각 무엇일까요? 그리고 `USER()` 와 `CURRENT_USER()` 의 차이는 무엇일까요?', '계정은 이름과 접속 위치의 짝이에요.', NULL, NULL, '[]', 'choice', '["`app` 은 비밀번호, `%` 는 데이터베이스 이름", "`app` 은 사용자 이름, `%` 는 접속을 허용하는 위치(모든 호스트). `USER()` 는 실제 접속한 출처, `CURRENT_USER()` 는 권한 판단에 쓰인 매칭된 계정이다", "둘은 항상 같은 값이다", "`%` 는 비밀번호가 없다는 뜻이다"]', 1, '같은 이름이라도 `''app''@''localhost''` 와 `''app''@''%''` 는 다른 계정입니다. 접속이 거부되면 호스트 부분이 맞는지 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 11, 'SHOW GRANTS 와 REVOKE', '계정 `''app''@''%''` 가 가진 권한을 보고, `UPDATE` 권한만 회수하려면 어떻게 할까요?', '보는 명령과 회수하는 명령이 따로 있어요.', NULL, NULL, '[]', 'choice', '["`SHOW GRANTS FOR ''app''@''%''` 로 보고, `REVOKE UPDATE ON shop.* FROM ''app''@''%''` 로 회수한다. 회수 뒤 `UPDATE` 는 `ERROR 1142` 로 거부된다", "`DROP USER` 만 가능하다", "`SHOW USERS` 와 `DELETE PRIVILEGE`", "권한은 한 번 주면 회수할 수 없다"]', 0, '권한 문제를 조사할 때는 먼저 `SHOW GRANTS` 로 현재 권한을 확인하세요. 모르는 계정의 권한을 함부로 바꾸지 마세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 12, 'DB 용량 알아내기', '데이터베이스마다 대략 몇 MB 를 쓰는지 SQL 로 알아보려면 어디를 조회할까요?', '서버가 모든 테이블의 정보를 모아 둔 곳이 있어요.', NULL, NULL, '[]', 'choice', '["`SHOW STATUS` 의 `Uptime`", "`mysql.user` 테이블", "`SHOW PROCESSLIST`", "`information_schema.tables` 의 `data_length + index_length` 를 `table_schema` 별로 합산한다"]', 3, '`SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024,2) MB FROM information_schema.tables GROUP BY table_schema` 같은 쿼리를 씁니다. 디스크가 부족할 때 어느 DB 가 큰지 찾는 첫걸음이에요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 13, 'EXPLAIN 의 type', '`EXPLAIN SELECT * FROM big WHERE city=''c7''` 결과에서 `type: ALL`, `key: NULL` 이면 무슨 뜻일까요?', 'type 은 테이블을 읽는 방식이에요.', NULL, NULL, '[]', 'choice', '["가장 빠른 조회 방식이다", "결과가 0건이라는 뜻이다", "인덱스를 쓰지 않고 테이블 전체를 훑는(전체 스캔) 방식이라 큰 테이블에서는 느리다. 인덱스를 만들면 `type: ref` 와 `key` 가 채워진다", "쿼리에 문법 오류가 있다는 뜻이다"]', 2, '`city` 에 인덱스를 만든 뒤에는 `type: ref`, `key: idx_city`, `rows` 가 크게 줄었습니다. `rows` 는 훑을 것으로 예상하는 행 수예요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 14, '인덱스를 못 쓰는 조건', '`city` 에 인덱스가 있을 때, `EXPLAIN` 에서 인덱스를 쓰지 못하고 `type: ALL` 이 되는 조건은 어느 것일까요?', '컬럼에 가공을 하거나 앞이 열려 있으면 인덱스로 찾기 어려워요.', NULL, NULL, '[]', 'choice', '["`WHERE city=''c7''`", "`WHERE UPPER(city)=''C7''` 처럼 컬럼에 함수를 씌우거나 `WHERE city LIKE ''%7''` 처럼 앞에 `%` 가 오는 조건", "`WHERE city LIKE ''c7%''`", "`WHERE id=5` (id 가 기본키인 경우)"]', 1, '`city=''c7''` 은 `type: ref`, `LIKE ''c7%''` 는 `type: range` 로 인덱스를 씁니다. 조건 모양이 인덱스를 쓸 수 있는지 `EXPLAIN` 으로 확인하세요.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 14);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 15, '접속 중인 세션 보기', '서버에 연결된 **세션과 실행 중인 쿼리**를 보는 명령입니다. 빈칸을 채우세요.', '"처리 목록"이라는 뜻의 단어예요.', NULL, NULL, '[]', 'fill', '["PROCESSLIST", "SESSIONS", "CONNECTIONS", "QUERIES"]', NULL, '`Id`, `User`, `Time`, `State`, `Info` 열로 어떤 쿼리가 오래 걸리는지 봅니다. 전체 문장은 `SHOW FULL PROCESSLIST` 로 보세요.', '[0]', 'SHOW {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 15);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 16, '쿼리만 중단하기', '12번 세션의 **쿼리만 중단**하는 명령어를 채우세요. (연결은 유지됩니다)', '"죽이다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["KILL", "STOP", "CANCEL", "ABORT"]', NULL, '`KILL 12` 는 연결 자체를 끊습니다. 쿼리만 멈추려면 `QUERY` 를 붙이세요.', '[0]', '{0} QUERY 12', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 16);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 17, '설정값 하나 보기', '서버의 **최대 연결 수 설정**만 걸러서 보는 쿼리입니다. 패턴을 채우세요.', '변수 이름을 따옴표로 감싸요.', NULL, NULL, '[]', 'fill', '["''max_connections''", "max_connections", "''max-connection''", "''maxconn''"]', NULL, '따옴표 없이 쓰면 문법 오류가 납니다. `''max_conn%''` 처럼 `%` 로 패턴을 줄 수도 있어요.', '[0]', 'SHOW VARIABLES LIKE {0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 17);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 18, '서버 전체 상태 보기', '세션이 아니라 **서버 전체의 현재 상태**를 보는 범위 키워드를 채우세요.', '"전역"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["GLOBAL", "WHOLE", "TOTAL", "ALL"]', NULL, '`SESSION` 은 내 세션만의 값입니다. 서버 전체 연결 수는 `GLOBAL` 로 봐요.', '[0]', 'SHOW {0} STATUS LIKE ''Threads_connected''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 18);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 19, '실행 중에 설정 바꾸기', '서버를 재시작하지 않고 **전체에 적용되는** 설정값을 바꾸는 키워드를 채우세요.', '"전역"을 뜻하는 영어 단어예요.', NULL, NULL, '[]', 'fill', '["GLOBAL", "SERVER", "SYSTEM", "FOREVER"]', NULL, '재시작하면 원래 값으로 돌아갑니다. 영구히 바꾸려면 설정 파일도 고치세요.', '[0]', 'SET {0} max_connections = 300', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 19);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 20, '계정 만들기', '비밀번호를 정해 **계정을 만드는** 구문의 빈칸을 채우세요.', '"식별되는"이라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["IDENTIFIED", "PASSWORD", "SECRET", "AUTH"]', NULL, '비밀번호는 서버에 해시로 저장됩니다. 실제 비밀번호를 명령 기록에 남기지 않도록 주의하세요.', '[0]', 'CREATE USER ''app''@''%'' {0} BY ''pw''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 20);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 21, '읽기 권한 주기', '`shop` 의 모든 테이블에 대한 **읽기 권한**을 주는 권한 이름을 채우세요.', '"고르다, 선택하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["SELECT", "READ", "VIEW", "GET"]', NULL, '`SELECT` 는 읽기, `INSERT` 는 추가, `UPDATE` 는 수정, `DELETE` 는 삭제 권한입니다. 필요한 것만 주세요.', '[0]', 'GRANT {0} ON shop.* TO ''app''@''%''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 21);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 22, '누구에게 줄지 정하기', '권한을 **그 계정에게 주는** 키워드를 채우세요.', '"~에게"라는 뜻의 짧은 영어 단어예요.', NULL, NULL, '[]', 'fill', '["TO", "FOR", "AT", "INTO"]', NULL, '`GRANT 권한 ON 대상 TO 계정` 이 기본 모양입니다. 회수할 때는 `TO` 가 `FROM` 으로 바뀌어요.', '[0]', 'GRANT SELECT ON shop.* {0} ''app''@''%''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 22);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 23, '계정의 권한 보기', '계정 `''app''@''%''` 의 **권한을 보는** 구문의 빈칸을 채우세요.', '"~의"라는 뜻으로 이어요.', NULL, NULL, '[]', 'fill', '["FOR", "OF", "ON", "TO"]', NULL, '`FOR` 없이 `SHOW GRANTS` 만 쓰면 지금 접속한 내 계정의 권한이 나옵니다.', '[0]', 'SHOW GRANTS {0} ''app''@''%''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 23);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 24, '권한 회수하기', '`UPDATE` 권한을 **회수하는** 구문의 빈칸을 채우세요.', '"~에서 떼어 내다"를 뜻해요.', NULL, NULL, '[]', 'fill', '["FROM", "TO", "OF", "OUT"]', NULL, '`GRANT` 는 `TO`, `REVOKE` 는 `FROM` 을 씁니다. 회수한 권한은 즉시 적용돼요.', '[0]', 'REVOKE UPDATE ON shop.* {0} ''app''@''%''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 24);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 25, '실행 계획 보기', '쿼리를 **실행하지 않고 어떻게 실행될지 계획**만 보는 키워드를 채우세요.', '"설명하다"라는 뜻의 영어 단어예요.', NULL, NULL, '[]', 'fill', '["EXPLAIN", "PLAN", "SHOWPLAN", "TRACE"]', NULL, '`type`, `key`, `rows` 를 먼저 읽으세요. `type: ALL` 이면 전체 스캔입니다.', '[0]', '{0} SELECT * FROM big WHERE city=''c7''', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 25);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 26, '오래 걸리는 쿼리 찾아 중단하기', '서버가 느릴 때 오래 걸리는 쿼리를 찾아 그 쿼리만 중단하는 순서입니다. 순서에 맞게 놓아 보세요.', '목록 → 의심 쿼리 → 중단 → 확인 순서예요.', NULL, NULL, '[]', 'order', '["`SHOW FULL PROCESSLIST` 로 세션 목록을 본다", "`Time` 이 큰 `Query` 행의 `Id` 와 `Info` 를 확인한다", "`KILL QUERY Id` 로 그 쿼리만 중단한다", "`SHOW PROCESSLIST` 로 그 쿼리가 사라졌는지 확인한다"]', NULL, '`KILL Id` 는 연결까지 끊으므로 앱 장애로 이어질 수 있습니다. 중단 전에 어떤 쿼리인지 `Info` 로 꼭 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 26);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 27, '앱 전용 계정 만들기', '읽기와 추가만 가능한 앱 전용 계정을 만드는 순서입니다. 순서에 맞게 놓아 보세요.', '계정 → 권한 → 확인 → 동작 시험 순서예요.', NULL, NULL, '[]', 'order', '["`CREATE USER ''app''@''%'' IDENTIFIED BY ''비밀번호''` 로 계정을 만든다", "`GRANT SELECT, INSERT ON shop.* TO ''app''@''%''` 로 필요한 권한만 준다", "`SHOW GRANTS FOR ''app''@''%''` 로 권한이 의도대로인지 본다", "`app` 계정으로 접속해 `SELECT` 는 되고 `DELETE` 는 거부되는지 시험한다"]', NULL, '시험 단계에서 거부되는 동작까지 확인하면 권한이 너무 넓게 주어지지 않았음을 알 수 있습니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 27);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 28, 'ERROR 1142 권한 오류 풀기', '앱이 `ERROR 1142 ... UPDATE command denied ...` 를 낼 때의 해결 순서입니다. 순서에 맞게 놓아 보세요.', '오류 읽기 → 현재 권한 → 필요한 권한만 → 재시도 순서예요.', NULL, NULL, '[]', 'order', '["오류 메시지에서 명령(`UPDATE`), 계정(`''app''@...`), 대상 테이블을 읽는다", "`SHOW GRANTS FOR` 로 그 계정의 현재 권한을 확인한다", "정말 필요하다면 `GRANT UPDATE ON 대상 TO 계정` 으로 필요한 권한만 추가한다", "앱에서 같은 동작을 다시 시도해 성공하는지 확인한다"]', NULL, '권한을 넓게 주는 것은 간단하지만 위험합니다. 필요한 테이블, 필요한 명령만 주세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 28);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 158, 29, '느린 조회를 인덱스로 개선하기', '특정 조회가 느릴 때 인덱스로 개선하는 순서입니다. 순서에 맞게 놓아 보세요.', '계획 확인 → 인덱스 확인 → 만들기 → 다시 확인 순서예요.', NULL, NULL, '[]', 'order', '["`EXPLAIN` 으로 `type: ALL`, `key: NULL` 인 것을 확인한다", "`SHOW INDEX FROM big` 으로 이미 있는 인덱스를 확인한다", "`CREATE INDEX idx_city ON big(city)` 로 인덱스를 만든다", "다시 `EXPLAIN` 으로 `type: ref`, `key: idx_city`, `rows` 감소를 확인한다"]', NULL, '인덱스는 읽기를 빠르게 하지만 쓰기를 조금 느리게 하고 공간을 씁니다. 컬럼에 함수를 씌우거나 앞에 `%` 를 붙이면 인덱스를 못 쓰니 조건 모양도 확인하세요.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 158 AND order_index = 29);
