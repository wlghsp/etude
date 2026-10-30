-- Git 세트 60. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set60.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 20, '미들웨어', '데이터베이스', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 20);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 60, 'Redis 익히기: 자료구조와 만료, 카운터, 분산 락', '메모리 기반 key-value 저장소 Redis 를 `redis-cli` 로 직접 다뤄 봅니다. 값 저장과 만료(TTL), 원자적 카운터(INCR), 해시·리스트·집합·정렬된 집합 자료구조, 그리고 `SET NX EX` 로 분산 락을 잡는 기본을 연습합니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 60);
UPDATE quest_set SET display_order = 545, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '🔴' WHERE id = 60;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 1, 'Redis 가 어떤 DB 인지 알기', 'Redis 의 특징으로 알맞은 것은 무엇일까요?', 'Redis 의 이름은 "REmote DIctionary Server" 입니다. 데이터는 어디에 두고 쓸까요?', NULL, NULL, '[]', 'choice', '["데이터를 주로 **메모리**에 두고 key-value 로 매우 빠르게 읽고 쓰는 인메모리 저장소이다 (캐시·세션·락·큐 등에 많이 쓴다)", "디스크에서만 동작하는 관계형 데이터베이스이다", "SQL 로 JOIN 을 하는 데 특화되어 있다", "로그 파일을 압축해 저장하는 도구이다"]', 0, 'Redis 는 **인메모리 key-value 저장소**입니다. 문자열뿐 아니라 해시, 리스트, 집합, 정렬된 집합 같은 **자료구조**를 제공하고, 만료 시간(TTL)을 줄 수 있어서 캐시, 세션, 순위, 분산 락, 간단한 큐에 자주 쓰입니다. 디스크에 저장(RDB/AOF)하는 영속화 옵션도 있습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 2, 'INCR 이 필요한 이유 알기', '조회수를 올리려고 `GET views` 로 값을 읽어 1 을 더해 `SET views` 로 저장하면, 여러 클라이언트가 동시에 실행할 때 **숫자가 누락**될 수 있습니다. Redis 의 해결책은 무엇일까요?', '읽고-계산하고-쓰는 3단계가 한 번에 일어나면 어떨까요?', NULL, NULL, '[]', 'choice', '["`SET views` 를 두 번 실행한다", "`INCR views` — 읽기·증가·쓰기를 **서버에서 한 번에(원자적으로)** 처리하므로 동시 요청에도 누락이 없다", "`EXPIRE views 0` 으로 초기화한다", "클라이언트를 한 대만 쓴다"]', 1, '`INCR`, `INCRBY`, `HINCRBY` 같은 명령은 **원자적(atomic)** 입니다. Redis 는 명령을 하나씩 순서대로 처리(싱글 스레드로 명령 실행)하기 때문에, 한 명령 안에서의 읽고-쓰기는 끼어들 수 없습니다. 여러 명령을 묶어 원자적으로 실행해야 하면 Lua 스크립트나 트랜잭션(MULTI/EXEC)을 씁니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 3, '분산 락의 기본 명령 알기', '여러 서버가 같은 작업을 동시에 하지 않도록 **락**을 잡으려고 합니다. 락 키가 **없을 때만** 만들고, 락을 잡은 서버가 죽어도 락이 **영원히 남지 않게** 하려면 어떻게 해야 할까요?', '"없을 때만 만든다(NX)" 와 "만료 시간(EX)" 을 한 명령에 함께 씁니다.', NULL, NULL, '[]', 'choice', '["`SET lock:job worker1` (이미 있으면 덮어쓴다)", "`GET lock:job` 으로 비어 있는지 보고 `SET` 으로 만든다 (두 명령으로 나눔)", "`SET lock:job worker1 NX EX 30` (키가 없을 때만 설정하고 30초 뒤 자동 만료)", "`DEL lock:job` 으로 먼저 지운 뒤 만든다"]', 2, '`SET key value NX EX 초` 는 "없을 때만 설정 + 만료"를 **한 번에(원자적으로)** 합니다. `GET` 으로 확인한 뒤 `SET` 하면 그 사이에 다른 서버가 끼어들 수 있고, 만료가 없으면 락을 잡은 서버가 죽었을 때 영원히 잠깁니다. (락을 푸는 쪽도 자기 값인지 확인하고 지워야 하며, 이를 원자적으로 하려고 Lua 스크립트를 씁니다.)', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 4, '값 저장하고 읽기 (SET, GET)', 'Redis 가 이미 실행 중입니다. 키 **`greeting`** 에 값 **`hello`** 를 저장하세요. (`redis-cli` 로 명령을 보냅니다)', '`redis-cli 명령 인자...` 형태로 한 줄씩 실행하거나, 인자 없이 `redis-cli` 를 실행해 대화형으로 쓸 수 있습니다. (나올 때는 `exit`)
확인: `redis-cli get greeting`', 'redis-cli set greeting hello
redis-cli get greeting

# SET 키 값 : 저장, GET 키 : 읽기', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli get greeting)\\" = \\"hello\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "greeting 값이 hello 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get greeting)\\" = \\"hello\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 5, '자동으로 사라지는 값 만들기 (TTL)', '로그인 세션처럼 **60초 뒤 자동으로 사라지는** 값을 만드세요. 키 `session` 에 값 `abc` 를 저장하고 만료 시간을 60초로 하세요.', '찾는 방법: `SET` 에 만료를 한 번에 주는 옵션, 또는 `EXPIRE 키 초` 명령. 남은 시간은 `TTL 키` 로 봅니다. (`-1` 은 만료 없음, `-2` 는 키 없음)
확인: `redis-cli ttl session` (60 이하의 양수)', 'redis-cli set session abc EX 60
redis-cli ttl session

# EX 60 : 60초 뒤 자동 삭제 (또는 set 후 expire session 60)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli get session)\\" = \\"abc\\" ] ) && ( [ \\"$(redis-cli ttl session)\\" -ge 1 ] && [ \\"$(redis-cli ttl session)\\" -le 60 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "session 값이 abc 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get session)\\" = \\"abc\\" ]"]}, {"label": "만료 시간(TTL)이 1~60초로 설정되어 있다", "cmd": ["sh", "-c", "[ \\"$(redis-cli ttl session)\\" -ge 1 ] && [ \\"$(redis-cli ttl session)\\" -le 60 ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 6, '카운터 올리기 (INCR)', '`visits` 는 방문자 수를 세는 카운터이고 지금 값은 `0` 입니다. **원자적인 증가 명령**으로 값이 **5** 가 되게 하세요.', '찾는 방법: `INCR`, `INCRBY` 명령. `GET` 으로 읽고 `SET` 으로 쓰는 방식은 쓰지 마세요.
확인: `redis-cli get visits`', 'redis-cli incrby visits 5   # 또는 redis-cli incr visits 를 5번
redis-cli get visits

# INCR : 1 증가, INCRBY 키 n : n 증가 (둘 다 원자적)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && redis-cli set visits 0 >/dev/null"]', '["sh", "-c", "( [ \\"$(redis-cli get visits)\\" = \\"5\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "visits 가 5 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get visits)\\" = \\"5\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 7, '해시로 사용자 정보 저장하기 (HSET)', '키 **`user:1`** 에 필드 **`name=kim`**, **`age=30`** 을 가진 **해시**로 사용자 정보를 저장하세요.', '찾는 방법: 해시 명령은 `H` 로 시작합니다 (`HSET`, `HGET`, `HGETALL`).
확인: `redis-cli hgetall user:1`', 'redis-cli hset user:1 name kim age 30
redis-cli hgetall user:1

# HSET 키 필드 값 [필드 값 ...] : 해시에 저장', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli hget user:1 name)\\" = \\"kim\\" ] ) && ( [ \\"$(redis-cli hget user:1 age)\\" = \\"30\\" ] ) && ( [ \\"$(redis-cli type user:1)\\" = \\"hash\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "name 이 kim 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli hget user:1 name)\\" = \\"kim\\" ]"]}, {"label": "age 가 30 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli hget user:1 age)\\" = \\"30\\" ]"]}, {"label": "user:1 이 해시 타입이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli type user:1)\\" = \\"hash\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 8, '리스트로 간단한 작업 큐 만들기 (RPUSH, LPOP)', '키 **`jobs`** 리스트의 **뒤에** 작업 `a`, `b`, `c` 를 차례로 넣고, **앞에서 하나를 꺼내** 그 값을 `/tmp/job.txt` 에 저장하세요. (먼저 넣은 것이 먼저 나오는 큐입니다) 꺼낸 뒤 리스트에는 2개가 남아야 합니다.', '뒤에 넣기는 `RPUSH`, 앞에서 꺼내기는 `LPOP` 입니다. 꺼낸 값은 `>` 로 저장하세요.
확인: `cat /tmp/job.txt` 와 `redis-cli llen jobs`', 'redis-cli rpush jobs a b c
redis-cli lpop jobs > /tmp/job.txt

# RPUSH : 뒤에 추가, LPOP : 앞에서 꺼내기 (FIFO 큐)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ -s /tmp/job.txt ] ) && ( [ \\"$(cat /tmp/job.txt)\\" = ''a'' ] ) && ( [ \\"$(redis-cli llen jobs)\\" = \\"2\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/job.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/job.txt ]"]}, {"label": "먼저 넣은 a 가 꺼내졌다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/job.txt)\\" = ''a'' ]"]}, {"label": "리스트에 2개가 남았다", "cmd": ["sh", "-c", "[ \\"$(redis-cli llen jobs)\\" = \\"2\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 9, '중복 없는 모음 만들기 (SET 자료구조)', '키 **`tags`** 에 태그 `a`, `b`, `a`, `c` 를 모두 넣으세요. 같은 값은 한 번만 저장되므로 **서로 다른 태그 3개**만 남아야 합니다.', '집합 명령은 `S` 로 시작합니다 (`SADD`, `SMEMBERS`, `SCARD`). 개수는 `SCARD` 로 봅니다.
확인: `redis-cli smembers tags`', 'redis-cli sadd tags a b a c
redis-cli scard tags

# SADD : 집합에 추가 (중복은 무시)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli scard tags)\\" = \\"3\\" ] ) && ( [ \\"$(redis-cli type tags)\\" = \\"set\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "태그가 3개다", "cmd": ["sh", "-c", "[ \\"$(redis-cli scard tags)\\" = \\"3\\" ]"]}, {"label": "집합 타입이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli type tags)\\" = \\"set\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 10, '순위표에서 1등 찾기 (정렬된 집합)', '`ranking` 은 **점수가 있는 정렬된 집합**(sorted set)이고 `kim`(50점), `lee`(90점), `park`(70점)이 들어 있습니다. **점수가 가장 높은 사람 한 명의 이름**을 `/tmp/top.txt` 에 저장하세요.', '정렬된 집합 명령은 `Z` 로 시작합니다. 점수가 **높은 순**으로 범위를 읽는 명령(`ZREVRANGE` 또는 `ZRANGE ... REV`)에서 0번째만 가져오세요.
확인: `cat /tmp/top.txt`', 'redis-cli zrevrange ranking 0 0 > /tmp/top.txt

# ZREVRANGE 키 0 0 : 점수 높은 순으로 첫 번째만', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && redis-cli zadd ranking 50 kim 90 lee 70 park >/dev/null"]', '["sh", "-c", "( [ -s /tmp/top.txt ] ) && ( [ \\"$(cat /tmp/top.txt)\\" = ''lee'' ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일 /tmp/top.txt 가 있다", "cmd": ["sh", "-c", "[ -s /tmp/top.txt ]"]}, {"label": "1등 lee 가 저장되었다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/top.txt)\\" = ''lee'' ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 60, 11, '합쳐서 쓰기: 분산 락 잡고, 다른 작업자는 못 잡게 하기', '작업자 `worker1` 이 락 `lock:job` 을 **30초 만료**로 잡으세요. 그다음 `worker2` 가 **같은 락을 잡으려 시도**하고(이미 잡혀 있으므로 실패해야 합니다), 그 시도의 **결과 출력**을 `/tmp/w2.txt` 에 저장하세요. 마지막에 락의 주인은 `worker1` 이어야 합니다.', '"없을 때만 설정"(NX)과 "만료"(EX)를 한 명령에 함께 씁니다. 이미 있으면 설정하지 않고 **빈 응답(nil)** 이 돌아옵니다.
확인: `redis-cli get lock:job` 과 `redis-cli ttl lock:job`', 'redis-cli set lock:job worker1 NX EX 30
redis-cli set lock:job worker2 NX EX 30 > /tmp/w2.txt

# 두 번째는 이미 키가 있어 설정되지 않는다 (결과 nil → 빈 출력)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli get lock:job)\\" = \\"worker1\\" ] ) && ( [ \\"$(redis-cli ttl lock:job)\\" -ge 1 ] && [ \\"$(redis-cli ttl lock:job)\\" -le 30 ] ) && ( [ -e /tmp/w2.txt ] && ! grep -q OK /tmp/w2.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "락의 주인이 worker1 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get lock:job)\\" = \\"worker1\\" ]"]}, {"label": "락에 만료 시간이 걸려 있다 (1~30초)", "cmd": ["sh", "-c", "[ \\"$(redis-cli ttl lock:job)\\" -ge 1 ] && [ \\"$(redis-cli ttl lock:job)\\" -le 30 ]"]}, {"label": "worker2 의 시도 결과가 저장되었고 성공(OK)이 아니다", "cmd": ["sh", "-c", "[ -e /tmp/w2.txt ] && ! grep -q OK /tmp/w2.txt"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 60 AND order_index = 11);
