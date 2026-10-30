-- Git 세트 83. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set83.sql, 05_display_order.sql, 06_units.sql, 08_set_icons.sql. docs/specs/spec_foundations_ladder.md
INSERT INTO unit (id, category, title, display_order) SELECT 20, '미들웨어', '데이터베이스', 40 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM unit WHERE id = 20);
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 83, 'Redis 심화: 원자성, 안전한 락 해제, 영속화와 메모리', 'Redis 가 명령 하나는 원자적이지만 여러 명령 사이에는 다른 클라이언트가 끼어들 수 있다는 점에서 출발해, MULTI/EXEC 와 Lua 스크립트의 차이, 남의 락을 지우지 않는 안전한 락 해제, 한도 안에서만 증가하는 카운터, TTL 해제(PERSIST), AOF 영속화와 메모리 한도(eviction) 설정을 실습합니다.', 'linux', '미들웨어'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 83);
UPDATE quest_set SET display_order = 546, unit_id = (SELECT id FROM unit WHERE id = 20), icon = '🧪' WHERE id = 83;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 1, '명령 하나와 여러 명령의 원자성', 'Redis 는 명령을 하나씩 차례로 처리합니다. 이 사실로부터 알 수 있는 것은 무엇일까요?', '"명령 하나"와 "명령 여러 개"를 구분하세요.', NULL, NULL, '[]', 'choice', '["여러 명령도 따로 보내면 항상 원자적이다", "다른 클라이언트의 명령은 절대 끼어들 수 없다", "명령 **하나**는 원자적이지만, GET → 판단 → SET 처럼 **여러 명령을 따로 보내면** 그 사이에 다른 클라이언트의 명령이 끼어들 수 있다", "Redis 는 동시에 여러 명령을 병렬로 처리한다"]', 2, 'INCR 같은 단일 명령은 읽고-더하고-쓰기를 한 번에 해서 안전합니다. 그러나 "읽고 조건 확인 후 갱신"을 개별 명령으로 나누면 레이스가 생깁니다. 이를 묶는 것이 MULTI/EXEC 와 Lua 스크립트입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 2, '남의 락을 지우는 사고', '프로세스 A 가 락을 잡고 작업하다가 TTL 이 만료되어 락이 풀렸고, B 가 새로 락을 잡았습니다. 뒤늦게 A 가 **`DEL lock`** 으로 해제하면 어떻게 될까요?', '그 키는 지금 누구의 것인가요?', NULL, NULL, '[]', 'choice', '["**B 의 락이 지워진다.** 그래서 해제는 \\"내가 건 락인지 값을 확인한 뒤에만\\" 지워야 한다", "A 의 락만 정확히 지워진다", "오류가 나서 아무것도 지워지지 않는다", "B 의 락이 자동으로 복구된다"]', 0, '락 값을 나만의 토큰(랜덤 값)으로 두고, 해제 시 "값이 내 토큰이면 지운다"를 **원자적으로** 해야 합니다. GET 후 DEL 을 따로 보내면 그 사이 끼어들 수 있어 Lua 로 묶습니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 3, 'MULTI/EXEC 와 Lua 의 차이', '"값을 읽어 **조건에 따라** 갱신한다"를 원자적으로 하려면 무엇을 써야 할까요?', '트랜잭션 안에서는 이전 명령의 결과를 보고 분기할 수 없습니다.', NULL, NULL, '[]', 'choice', '["MULTI/EXEC 만으로 충분하다", "단일 명령 두 개를 순서대로 보낸다", "TTL 을 길게 설정한다", "Lua 스크립트 (스크립트 안에서 `if` 같은 조건 분기가 가능하다)"]', 3, 'MULTI/EXEC 는 명령을 묶어 원자적으로 실행하지만 중간 결과로 분기할 수 없습니다. Lua 는 스크립트 안에서 분기가 되어 "조건부 갱신", 락 해제, rate limiting 에 쓰입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 4, 'Lua 스크립트의 주의점', 'Lua 스크립트 사용 시 가장 주의할 점은 무엇일까요?', 'Redis 는 싱글 스레드입니다.', NULL, NULL, '[]', 'choice', '["스크립트가 실행되는 동안 다른 클라이언트가 모두 대기하므로, 무거운 연산을 넣지 말고 **원자성이 꼭 필요한 짧은 로직**에만 쓴다", "스크립트는 길수록 좋다", "스크립트 중에도 다른 명령이 자유롭게 실행된다", "Lua 는 Redis 에서 쓸 수 없다"]', 1, '스크립트 실행 중에는 Redis 전체가 블록됩니다. 긴 반복문이나 큰 데이터 순회를 넣으면 그 시간만큼 서비스 전체가 느려집니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 5, 'RDB 와 AOF', 'Redis 의 영속화 방식 두 가지 설명으로 알맞은 것은 무엇일까요? (※ 이 항목은 노트에 없는 일반 Redis 지식)', '하나는 주기적 스냅샷, 하나는 쓰기 명령 로그입니다.', NULL, NULL, '[]', 'choice', '["RDB 는 일정 간격으로 메모리의 스냅샷을 파일로 저장하고, AOF 는 쓰기 명령을 로그로 계속 기록한다. 보통 AOF 가 유실이 적고 파일이 더 크다", "RDB 와 AOF 는 둘 다 읽기 명령을 기록한다", "AOF 는 스냅샷이고 RDB 는 명령 로그이다", "둘 다 저장하지 않고 메모리에만 둔다"]', 2, 'RDB 는 복구가 빠르고 파일이 작지만 마지막 스냅샷 이후 데이터를 잃을 수 있습니다. AOF 는 `appendfsync` 설정에 따라 유실을 거의 없앨 수 있습니다. 캐시 용도면 영속화를 끄기도 합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 6, 'TTL 만으로는 부족한 락', '락에 TTL 을 걸었는데 락을 잡은 프로세스가 **TTL 보다 오래** 작업하면 어떤 문제가 생길까요?', 'TTL 은 "프로세스가 죽었을 때"를 위한 안전장치입니다.', NULL, NULL, '[]', 'choice', '["TTL 이 만료되어 락이 풀리고, 다른 프로세스가 같은 자원에 **동시에 접근**하게 된다 (락 갱신이나 Redlock 같은 별도 기법이 필요)", "아무 문제 없다", "Redis 가 자동으로 TTL 을 늘려 준다", "프로세스가 자동으로 종료된다"]', 0, '작업 시간을 예측해 TTL 을 넉넉히 잡거나, 작업 중 주기적으로 TTL 을 갱신(watchdog)하는 방법을 씁니다. 여러 Redis 노드를 쓰는 Redlock 은 별도로 논의할 만큼 큰 주제입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 7, '메모리 한도와 eviction', '`maxmemory` 를 설정했는데 메모리가 가득 찼을 때 `noeviction` 정책이면 어떻게 될까요? (※ 일반 Redis 지식)', '정책 이름 그대로입니다.', NULL, NULL, '[]', 'choice', '["어떤 키도 쫓아내지 않으므로 **새 쓰기가 오류로 거부**된다. `allkeys-lru` 같은 정책이면 오래 안 쓴 키를 지워 공간을 만든다", "가장 오래된 키가 자동으로 삭제된다", "메모리가 무한히 늘어난다", "Redis 가 즉시 종료된다"]', 3, '캐시로 쓰면 `allkeys-lru` 처럼 지워도 되는 정책을, 지우면 안 되는 데이터(세션, 락 등)만 있다면 noeviction 으로 두고 용량을 감시합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 8, 'Sentinel 과 Cluster', 'Redis 의 **Sentinel** 과 **Cluster** 의 차이로 알맞은 것은 무엇일까요? (※ 일반 Redis 지식)', '하나는 가용성, 하나는 데이터를 나눠 저장하는 샤딩입니다.', NULL, NULL, '[]', 'choice', '["Sentinel 은 primary-replica 구성의 장애를 감시해 replica 를 승격(failover)시키는 고가용성 도구이고, Cluster 는 데이터를 여러 노드에 **샤딩**해 용량과 처리량을 늘린다", "둘은 같은 기능이다", "Sentinel 은 데이터를 샤딩하고 Cluster 는 백업만 한다", "둘 다 Redis 를 종료시킨다"]', 1, '데이터가 한 노드 메모리에 들어가고 가용성이 목표면 Sentinel, 한 노드에 안 들어갈 만큼 크거나 쓰기 처리량이 필요하면 Cluster 입니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 9, '안전하게 락 해제하기 (Lua)', '두 락이 있습니다: `lock:a` 는 토큰 `tokenA` 가, `lock:b` 는 토큰 `tokenB` 가 잡고 있습니다. 내 토큰은 **`tokenA`** 입니다. 두 키 모두에 대해 "값이 내 토큰이면 지운다"를 **Lua 스크립트(EVAL)** 로 시도하세요. 결과적으로 `lock:a` 만 지워지고 `lock:b` 는 남아야 합니다.', '`redis-cli EVAL "스크립트" 키개수 키 인자...` 형태입니다. 스크립트 안에서 `redis.call("GET", KEYS[1])` 로 값을 읽어 `ARGV[1]` 과 같으면 `redis.call("DEL", KEYS[1])` 합니다. 키마다 한 번씩 실행하세요.
확인: `redis-cli exists lock:a lock:b`', 'S=''if redis.call("GET", KEYS[1]) == ARGV[1] then return redis.call("DEL", KEYS[1]) else return 0 end''
redis-cli eval "$S" 1 lock:a tokenA
redis-cli eval "$S" 1 lock:b tokenA

# GET 과 DEL 을 하나의 원자적 연산으로 묶었다. lock:b 는 값이 달라 그대로 남는다', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && redis-cli set lock:a tokenA EX 600 >/dev/null && redis-cli set lock:b tokenB EX 600 >/dev/null"]', '["sh", "-c", "( [ \\"$(redis-cli exists lock:a)\\" = 0 ] ) && ( [ \\"$(redis-cli exists lock:b)\\" = 1 ] ) && ( [ \\"$(redis-cli get lock:b)\\" = \\"tokenB\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "lock:a 는 지워졌다", "cmd": ["sh", "-c", "[ \\"$(redis-cli exists lock:a)\\" = 0 ]"]}, {"label": "lock:b 는 남아 있다", "cmd": ["sh", "-c", "[ \\"$(redis-cli exists lock:b)\\" = 1 ]"]}, {"label": "lock:b 의 주인은 그대로 tokenB 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get lock:b)\\" = \\"tokenB\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 10, '여러 명령을 한 번에 실행하기 (MULTI/EXEC)', '`x` 를 `10`, `y` 를 `20` 으로 **한 트랜잭션**으로 설정하세요. (`MULTI` 로 시작해 `EXEC` 으로 끝냅니다)', '`redis-cli` 는 명령마다 연결을 끊으므로, 한 번의 입력에 여러 줄을 파이프로 넘기세요: `printf "MULTI
SET a 1
EXEC
" | redis-cli`
확인: `redis-cli mget x y`', 'printf "MULTI\\nSET x 10\\nSET y 20\\nEXEC\\n" | redis-cli
redis-cli mget x y

# EXEC 가 올 때까지 명령은 큐에 쌓이고, EXEC 으로 한꺼번에 실행된다', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli get x)\\" = \\"10\\" ] ) && ( [ \\"$(redis-cli get y)\\" = \\"20\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "x 가 10 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get x)\\" = \\"10\\" ]"]}, {"label": "y 가 20 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get y)\\" = \\"20\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 10);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 11, '한도 안에서만 증가시키기 (Lua rate limit)', '키 `req:u1` 은 요청 횟수입니다. **한도 3** 까지만 증가시키고, 한도를 넘으면 증가시키지 않고 `0`, 성공하면 `1` 을 돌려주는 Lua 스크립트를 만들어 **5번 실행**하고, 반환값을 한 줄씩 `/tmp/rl.txt` 에 저장하세요. (결과는 `1 1 1 0 0`)', '스크립트 안에서 현재 값을 읽어(`redis.call("GET", ...)`, 없으면 0) 한도와 비교하고, 한도 미만이면 `INCR` 후 `1`, 아니면 `0` 을 반환합니다. 읽기와 증가가 한 스크립트에 있어야 원자적입니다.
확인: `cat /tmp/rl.txt`', 'S=''local c = tonumber(redis.call("GET", KEYS[1]) or "0")
if c < tonumber(ARGV[1]) then redis.call("INCR", KEYS[1]) return 1 else return 0 end''
for i in 1 2 3 4 5; do redis-cli eval "$S" 1 req:u1 3; done > /tmp/rl.txt

# 읽기·비교·증가를 한 스크립트로 묶어 동시 요청이 와도 한도를 넘지 않는다', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ -s /tmp/rl.txt ] ) && ( [ \\"$(tr \\"\\\\n\\" \\" \\" < /tmp/rl.txt | sed \\"s/ *$//\\")\\" = \\"1 1 1 0 0\\" ] ) && ( [ \\"$(redis-cli get req:u1)\\" = \\"3\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "결과 파일이 있다", "cmd": ["sh", "-c", "[ -s /tmp/rl.txt ]"]}, {"label": "결과가 1 1 1 0 0 이다", "cmd": ["sh", "-c", "[ \\"$(tr \\"\\\\n\\" \\" \\" < /tmp/rl.txt | sed \\"s/ *$//\\")\\" = \\"1 1 1 0 0\\" ]"]}, {"label": "카운터는 한도 3 에서 멈췄다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get req:u1)\\" = \\"3\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 11);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 12, 'TTL 해제하기 (PERSIST)', '키 `session` 에는 TTL 이 걸려 있어서 곧 사라집니다. **만료되지 않게** TTL 을 없애세요.', '찾는 방법: `redis-cli command docs persist` 또는 공식 문서. TTL 을 제거하는 명령입니다.
확인: `redis-cli ttl session` (`-1` 이면 만료 없음)', 'redis-cli persist session
redis-cli ttl session

# ttl 값: -1 만료 없음, -2 키 없음', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1 && redis-cli set session abc EX 100 >/dev/null"]', '["sh", "-c", "( [ \\"$(redis-cli get session)\\" = \\"abc\\" ] ) && ( [ \\"$(redis-cli ttl session)\\" = \\"-1\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "값은 그대로다", "cmd": ["sh", "-c", "[ \\"$(redis-cli get session)\\" = \\"abc\\" ]"]}, {"label": "만료가 없다 (TTL -1)", "cmd": ["sh", "-c", "[ \\"$(redis-cli ttl session)\\" = \\"-1\\" ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 12);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 13, 'AOF 영속화 켜기', '실행 중인 Redis 에서 **AOF(`appendonly`)를 켜세요.** 설정 변경은 Redis 를 재시작하지 않고 명령으로 할 수 있습니다.', '찾는 방법: 런타임에 설정을 바꾸는 `CONFIG SET 항목 값` 명령.
확인: `redis-cli config get appendonly`', 'redis-cli config set appendonly yes
redis-cli config get appendonly

# 영구 반영하려면 redis.conf 에도 appendonly yes 를 적는다 (CONFIG REWRITE 로 저장 가능)', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli config get appendonly | tail -n 1)\\" = yes ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "appendonly 가 yes 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli config get appendonly | tail -n 1)\\" = yes ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 13);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 83, 14, '캐시용 메모리 한도 정하기', 'Redis 를 **캐시**로 쓰려고 합니다. 메모리 한도를 **`10mb`** 로, 가득 차면 **오래 쓰지 않은 키부터 모든 키 대상으로 지우는 정책(`allkeys-lru`)** 으로 설정하세요.', '`maxmemory` 와 `maxmemory-policy` 두 항목을 `CONFIG SET` 으로 바꿉니다.
확인: `redis-cli config get maxmemory` 와 `redis-cli config get maxmemory-policy`', 'redis-cli config set maxmemory 10mb
redis-cli config set maxmemory-policy allkeys-lru

# 지워도 되는 캐시는 allkeys-lru, 지우면 안 되면 noeviction', '["sh", "-c", "redis-server --daemonize yes --save '''' >/dev/null && sleep 1"]', '["sh", "-c", "( [ \\"$(redis-cli config get maxmemory | tail -n 1)\\" = 10485760 ] ) && ( [ \\"$(redis-cli config get maxmemory-policy | tail -n 1)\\" = allkeys-lru ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "maxmemory 가 10mb(10485760) 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli config get maxmemory | tail -n 1)\\" = 10485760 ]"]}, {"label": "정책이 allkeys-lru 이다", "cmd": ["sh", "-c", "[ \\"$(redis-cli config get maxmemory-policy | tail -n 1)\\" = allkeys-lru ]"]}]', '[{"title": "Redis 공식 문서", "url": "https://redis.io/docs/latest/commands/"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 83 AND order_index = 14);
