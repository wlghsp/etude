-- 미들웨어 세트 99. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set99.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 99, 'Redis 접속과 키 관리: 조회, 삭제, 이름 짓기', 'redis-cli 로 서버를 점검하고 키를 안전하게 다루는 기본기를 익힙니다. PING·TYPE·TTL 확인, 자료형에 맞는 읽기, KEYS 대신 SCAN, DEL 과 UNLINK, FLUSHDB·FLUSHALL 의 위험, 키 이름 규칙, INFO keyspace 읽기, 비밀번호 인증과 DB 번호 선택을 문제와 실습으로 다룹니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 99);
UPDATE quest_set SET display_order = 546, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '🔑' WHERE id = 99;
UPDATE quest_set SET display_order = 547 WHERE id = 83;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 1, 'redis-cli 점검 명령 채우기', '`redis-cli` 로 ① **서버가 살아 있는지**, ② 키 `user:1` 의 **자료형**, ③ 키 `user:1` 의 **남은 만료 시간(초)** 을 확인하는 명령입니다. 빈칸을 채우세요.', '살아 있으면 PONG 이 돌아옵니다. 자료형과 남은 시간은 이름 그대로의 단어입니다.', NULL, NULL, '[]', 'fill', '["ping", "type", "ttl", "keys", "flushall", "info"]', NULL, '`PING` 은 `PONG` 으로 응답합니다(연결·인증 확인). `TYPE` 은 string/hash/list/set/zset 중 무엇인지 알려 주어, 그에 맞는 읽기 명령(GET/HGETALL/LRANGE/SMEMBERS/ZRANGE)을 고르게 합니다. `TTL` 은 남은 초이고 `-1` 은 만료 없음, `-2` 는 키가 없음을 뜻합니다.', '[0, 1, 2]', 'redis-cli {0}
redis-cli {1} user:1
redis-cli {2} user:1', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 2, '운영 Redis 에서 패턴 키를 안전하게 지우는 순서', '캐시 키 `cache:*` 를 정리해야 합니다. 실제 서비스가 쓰는 Redis 이므로 **안전하게** 진행하는 흐름을 **앞에서 뒤**로 놓으세요.', '먼저 대상이 맞는지 보고, 작게 시작하고, 확인합니다. 전체 삭제 명령은 쓰지 않습니다.', NULL, NULL, '[]', 'order', '["`redis-cli --scan --pattern \\"cache:*\\"` 로 지울 키 목록과 개수를 확인한다", "`TYPE` 과 `TTL` 로 몇 개를 샘플 확인한다 (서비스에 필요한 키가 섞였는지)", "`--scan` 결과를 `UNLINK` 로 넘겨 삭제한다", "`DBSIZE` 와 다시 한 번 scan 으로 정리 결과를 확인한다"]', NULL, '**scan 으로 대상 확인 → 샘플 점검 → UNLINK 삭제 → 결과 확인** 입니다. `KEYS`·`FLUSHALL` 은 서버를 멈추거나 모든 데이터를 지우기 때문에 운영에서는 피합니다.', '[0, 1, 2, 3]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 3, 'KEYS * 를 운영에서 피하는 이유', '운영 중인 Redis 에서 키 목록을 보려고 `KEYS *` 를 실행하면 안 되는 이유는 무엇일까요? 대안은 무엇일까요?', 'Redis 명령은 한 번에 하나씩 실행됩니다.', NULL, NULL, '[]', 'choice', '["`KEYS` 는 읽기 전용이라 안전하지만 결과가 정렬되지 않는다", "`KEYS` 는 키를 삭제한다", "`KEYS` 는 모든 키를 한 번에 훑는 동안 **다른 요청을 막아** 서비스 지연을 일으킬 수 있다. 대신 `SCAN`(`redis-cli --scan`)으로 조금씩 나눠 조회한다", "`KEYS` 는 Redis 7 부터 지원하지 않는다"]', 2, 'Redis 는 명령을 대체로 한 줄로 처리하므로 오래 걸리는 명령 하나가 전체를 지연시킵니다. `SCAN` 은 커서를 쓰며 조금씩 순회하므로 부담이 적습니다(순회 중 변경된 키는 놓치거나 중복될 수 있음).', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 4, 'DEL 과 UNLINK', '매우 큰 해시 하나(수백만 필드)를 지우는데 `DEL` 이 서비스를 잠깐 멈추게 합니다. 더 안전한 명령은 무엇일까요?', '메모리 해제를 어디서 하느냐의 차이입니다.', NULL, NULL, '[]', 'choice', '["`UNLINK` — 키를 먼저 목록에서 떼어 내고 실제 메모리 해제는 백그라운드에서 한다", "`FLUSHALL` — 한 번에 모두 지운다", "`RENAME` — 이름을 바꾸면 사라진다", "`EXPIRE 0` — 항상 더 빠르다"]', 0, '`DEL` 은 메모리 해제까지 메인 흐름에서 처리해 큰 키는 오래 걸립니다. `UNLINK` 는 같은 결과를 더 부드럽게 만듭니다. 작은 키라면 차이가 거의 없습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 5, 'FLUSHDB 와 FLUSHALL', '`FLUSHDB` 와 `FLUSHALL` 의 차이로 맞는 것은 무엇일까요?', '데이터베이스 번호(0~15)를 떠올려 보세요.', NULL, NULL, '[]', 'choice', '["`FLUSHDB` 는 디스크 데이터까지 복구한다", "`FLUSHDB` 는 현재 선택한 DB 의 키만, `FLUSHALL` 은 **모든 DB** 의 키를 지운다. 둘 다 되돌릴 수 없으므로 운영에서는 막아 두는 것이 안전하다", "둘은 완전히 같은 명령이다", "`FLUSHALL` 은 만료된 키만 지운다"]', 1, '실수로 실행하면 영속화(RDB/AOF) 파일에도 반영되어 복구가 어렵습니다. 운영에서는 `rename-command` 나 ACL 로 이런 명령을 막기도 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 6, '키 이름 짓기', '여러 서비스가 한 Redis 를 씁니다. 키 이름 규칙으로 가장 알맞은 것은 무엇일까요?', '무슨 키인지 이름만 봐도 알 수 있어야 합니다.', NULL, NULL, '[]', 'choice', '["`k1`, `k2` 처럼 짧은 번호만 쓴다", "한글과 공백을 섞어 설명처럼 쓴다", "모든 키를 대문자 한 글자로 쓴다", "`서비스:대상:식별자` 처럼 **콜론으로 구분한 네임스페이스**를 쓴다 (예: `shop:session:1001`)"]', 3, '이름 규칙이 있으면 `--scan --pattern "shop:session:*"` 로 일부만 골라 확인·정리할 수 있고 서비스 간 충돌도 막습니다. 너무 긴 키는 메모리를 더 쓰므로 의미가 드러나는 선에서 짧게 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 7, 'INFO keyspace 읽기', '`redis-cli info keyspace` 결과가 `db0:keys=1200,expires=300,avg_ttl=45000` 입니다. 올바른 해석은 무엇일까요?', 'expires 는 만료 시간이 설정된 키의 수입니다.', NULL, NULL, '[]', 'choice', '["0번 DB 에 키가 1200개 있고, 그중 300개에만 만료(TTL)가 설정되어 있다", "1200개 키가 모두 300초 뒤에 사라진다", "0번 DB 의 메모리가 1200MB 이다", "300개 키가 이미 만료되어 삭제됐다"]', 0, '`keys` 와 `expires` 의 차이가 크면 만료 없이 쌓이는 키가 많다는 신호입니다. 메모리 사용량은 `info memory` 의 `used_memory_human` 에서 봅니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 8, '자료형 확인하고 값 읽기', '키 `user:1` 에 사용자 정보가 저장되어 있는데 어떤 자료형인지 모릅니다. 자료형을 **`/tmp/type.txt`** 에 저장하고, 필드 `name` 의 값을 **`/tmp/name.txt`** 에 저장하세요.', '자료형은 `TYPE` 으로 확인합니다. 해시라면 필드 하나는 `HGET 키 필드` 로 읽습니다.\\n확인: `redis-cli type user:1`', 'redis-cli type user:1 > /tmp/type.txt
redis-cli hget user:1 name > /tmp/name.txt
cat /tmp/type.txt /tmp/name.txt

# 자료형에 맞는 명령을 써야 한다 (hash 는 HGET/HGETALL, string 은 GET)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && redis-cli hset user:1 name kim age 30 >/dev/null"]', '["sh", "-c", "( [ \\"$(cat /tmp/type.txt)\\" = hash ] ) && ( [ \\"$(cat /tmp/name.txt)\\" = kim ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "type.txt 가 hash 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/type.txt)\\" = hash ]"]}, {"label": "name.txt 가 kim 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/name.txt)\\" = kim ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 9, 'SCAN 으로 패턴 키 개수 세기', 'Redis 에 `cache:` 로 시작하는 캐시 키와 `user:` 키가 섞여 있습니다. `KEYS` 를 쓰지 않고 **`cache:*` 키의 개수**를 세어 **`/tmp/n.txt`** 에 저장하세요.', '`redis-cli --scan --pattern 패턴` 이 키를 한 줄씩 출력합니다. 줄 수는 `wc -l` 입니다.\\n확인: `redis-cli dbsize` (전체 키 수)', 'redis-cli --scan --pattern ''cache:*'' | wc -l | tr -d '' '' > /tmp/n.txt
cat /tmp/n.txt

# --scan 은 내부적으로 SCAN 을 반복 호출한다 (서비스를 막지 않는다)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && for i in $(seq 1 20); do redis-cli set cache:$i v >/dev/null; done && for i in 1 2 3 4 5; do redis-cli set user:$i v >/dev/null; done"]', '["sh", "-c", "( [ -s /tmp/n.txt ] ) && ( [ \\"$(cat /tmp/n.txt)\\" = 20 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/n.txt ]"]}, {"label": "개수가 20 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/n.txt)\\" = 20 ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 10, '캐시 키만 안전하게 지우기', '`cache:*` 키는 모두 지우되 **`user:*` 키는 그대로** 두어야 합니다. `FLUSHALL`·`FLUSHDB` 는 쓰지 말고, scan 결과를 넘겨 삭제하세요.', '`--scan --pattern` 의 출력을 `xargs` 로 `UNLINK`(또는 `DEL`)에 넘길 수 있습니다.\\n확인: `redis-cli dbsize`', 'redis-cli --scan --pattern ''cache:*'' | xargs redis-cli unlink
redis-cli dbsize

# 전체 삭제(FLUSH*) 대신 패턴으로 대상만 골라 지운다', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && for i in $(seq 1 20); do redis-cli set cache:$i v >/dev/null; done && for i in 1 2 3 4 5; do redis-cli set user:$i v >/dev/null; done"]', '["sh", "-c", "( [ \\"$(redis-cli --scan --pattern \\"cache:*\\" | wc -l)\\" -eq 0 ] ) && ( [ \\"$(redis-cli --scan --pattern \\"user:*\\" | wc -l)\\" -eq 5 ] ) && ( [ \\"$(redis-cli dbsize)\\" = 5 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "cache 키가 하나도 없다", "cmd": ["sh", "-c", "[ \\"$(redis-cli --scan --pattern \\"cache:*\\" | wc -l)\\" -eq 0 ]"]}, {"label": "user 키 5개가 남아 있다", "cmd": ["sh", "-c", "[ \\"$(redis-cli --scan --pattern \\"user:*\\" | wc -l)\\" -eq 5 ]"]}, {"label": "전체 키가 5개다", "cmd": ["sh", "-c", "[ \\"$(redis-cli dbsize)\\" = 5 ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 11, '비밀번호가 걸린 Redis 에 접속하기', '이 Redis 는 비밀번호(`s3cret`)가 설정되어 있어 `redis-cli get x` 가 **`NOAUTH Authentication required`** 로 실패합니다. 인증해서 키 `x` 의 값을 **`/tmp/x.txt`** 에 저장하세요.', '`-a 비밀번호` 옵션이 있고, 명령 이력에 비밀번호가 남는 것을 피하려면 환경 변수 `REDISCLI_AUTH` 를 쓸 수 있습니다.\\n확인: `redis-cli ping`', 'redis-cli get x
REDISCLI_AUTH=s3cret redis-cli get x > /tmp/x.txt
cat /tmp/x.txt

# 명령줄에 비밀번호(-a)를 쓰면 이력·프로세스 목록에 노출될 수 있어 환경 변수가 낫다', '["sh", "-c", "redis-server --daemonize yes --save '''' --requirepass s3cret >/dev/null && sleep 1 && redis-cli -a s3cret set x hello >/dev/null 2>&1"]', '["sh", "-c", "( [ -s /tmp/x.txt ] ) && ( [ \\"$(cat /tmp/x.txt)\\" = hello ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/x.txt ]"]}, {"label": "값이 hello 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/x.txt)\\" = hello ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 99, 12, '다른 DB 번호의 키 읽기', '애플리케이션이 Redis 의 **1번 DB** 에 플래그 `flag` 를 저장했습니다. 기본(0번) DB 에서는 보이지 않습니다. 1번 DB 에서 `flag` 의 값을 읽어 **`/tmp/flag.txt`** 에 저장하세요.', '`redis-cli -n 번호` 로 DB 를 선택합니다(대화형에서는 `SELECT 번호`).\\n확인: `redis-cli info keyspace`', 'redis-cli info keyspace
redis-cli -n 1 get flag > /tmp/flag.txt
cat /tmp/flag.txt

# Redis 는 DB 번호(기본 0~15)마다 키 공간이 분리된다', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && redis-cli -n 1 set flag on >/dev/null"]', '["sh", "-c", "( [ -s /tmp/flag.txt ] ) && ( [ \\"$(cat /tmp/flag.txt)\\" = on ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/flag.txt ]"]}, {"label": "값이 on 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/flag.txt)\\" = on ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 99 AND order_index = 12);
