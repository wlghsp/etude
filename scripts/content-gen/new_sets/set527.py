import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 527: Redis 캐시 패턴 입문 (Cache-Aside). 명세: docs/specs/spec_gap_set527.md

R = "redis-server --daemonize yes --save '' >/dev/null && sleep 1 && redis-cli flushall >/dev/null; rm -f /tmp/*.txt"

b = SetBuilder(527, 'Redis 캐시 패턴 입문: Cache-Aside, TTL 설계, 무효화, 스탬피드, 세션 저장',
               'Redis 를 DB 앞의 캐시로 쓰는 가장 흔한 방법(Cache-Aside)을 익힙니다. 캐시 확인 → 원본 조회 → 캐시 저장의 읽기 순서, TTL 로 만료 주기 정하기, 원본이 바뀔 때 캐시 지우기, 한꺼번에 만료될 때의 폭주(스탬피드)와 방어, 세션 저장, 큰 키 찾기를 redis-cli 로 직접 따라 합니다.',
               'linux', '데이터베이스', 31, 748, '🗃️',
               [{"title": "Redis 를 캐시로 쓰기", "url": "https://redis.io/docs/latest/develop/use/client-side-caching/"}, {"title": "Redis SET 명령", "url": "https://redis.io/docs/latest/commands/set/"}, {"title": "Redis MEMORY USAGE", "url": "https://redis.io/docs/latest/commands/memory-usage/"}], 3)

b.choice('캐시는 누가 채울까', '웹 서비스가 느린 원본 DB 앞에 Redis 를 캐시로 둡니다. **Cache-Aside** 방식에서는 캐시에 값이 없을 때(미스) 누가 원본에서 값을 가져와 Redis 에 넣을까요?',
         '`GET` 으로 물으면 Redis 는 있는지 없는지만 답합니다. Redis 가 다른 DB 에 접속할 방법이 있는지 생각해 보세요.',
         ['애플리케이션 코드가 원본 DB 에서 읽어 와서 Redis 에 `SET` 한다', 'Redis 가 알아서 원본 DB 를 조회해 채운다', '원본 DB 가 값이 바뀔 때마다 Redis 에 자동으로 밀어 넣는다', '사용자의 브라우저가 Redis 에 직접 넣는다'], 0,
         'Cache-Aside(옆에 두는 캐시) 방식에서 캐시는 단순한 저장소이고, "없으면 원본에서 가져와 채우는" 일은 애플리케이션이 합니다. Redis 는 원본 DB 의 존재를 모릅니다. 그래서 읽기 코드에 "확인 → 미스면 조회 → 저장" 흐름을 직접 적어야 합니다.')
b.nt('캐시 미스 흐름 손으로 따라하기', '`/tmp/origin_user1.txt` 는 **원본 DB 역할**을 하는 파일이고, 사용자 1번의 이름이 들어 있습니다. Redis 에는 아직 `user:1` 이 없습니다. Cache-Aside 읽기를 손으로 재현하세요. (1) `GET user:1` 로 캐시를 확인해 비어 있음(미스)을 보고, (2) 원본 파일의 값을 읽어, (3) 그 값을 `user:1` 에 **300초 만료**(`EX 300`)로 저장합니다. 마지막에 `GET user:1` 을 한 번 더 하면 이제 적중(히트)입니다.',
     '값은 `cat` 으로 읽어 `$(...)` 로 `SET` 에 넣을 수 있습니다. 만료는 `SET` 의 옵션으로 함께 지정합니다.',
     "redis-cli get user:1                       # 비어 있음 (미스)\nv=$(cat /tmp/origin_user1.txt)             # 원본 조회\nredis-cli set user:1 \"$v\" ex 300           # 캐시에 저장 (300초 뒤 자동 삭제)\nredis-cli get user:1                       # 이제 히트\n\n# 확인 -> 미스면 원본 조회 -> TTL 과 함께 저장. 이 세 단계가 Cache-Aside 읽기",
     R + " && echo kim > /tmp/origin_user1.txt",
     [chk('캐시 값이 원본과 같다', '[ "$(redis-cli get user:1)" = "$(cat /tmp/origin_user1.txt)" ]'), chk('300초 이하의 만료가 걸려 있다', 't=$(redis-cli ttl user:1); [ "$t" -gt 0 ] && [ "$t" -le 300 ]')])
b.order('Cache-Aside 읽기 순서', '캐시에 값이 **없는 경우(미스)** 의 읽기 흐름입니다. 응답은 맨 마지막에 돌려준다고 할 때, 일어나는 순서대로 놓으세요.', '요청자가 기다리는 동안 캐시와 원본 중 어느 쪽을 먼저 확인해야 비용이 적은지 생각해 보세요.',
        ['원본 DB 에서 값을 조회한다', '요청자에게 값을 응답한다', '조회한 값을 TTL 과 함께 캐시에 저장한다', '캐시에서 `GET` 으로 값을 찾는다 (없음)'], [3, 0, 2, 1],
        '먼저 캐시를 확인하고, 없을 때만 원본 DB 를 조회합니다. 조회한 값은 TTL 과 함께 캐시에 저장해 다음 요청이 히트하게 만든 뒤 응답합니다. 값이 캐시에 있었다면(히트) 첫 단계에서 바로 응답하고 끝납니다.')
b.fill('값과 만료를 한 번에', '가격 `1500` 을 **300초 만료**로 `price:7` 키에 저장하는 명령입니다. `SET` 과 `EXPIRE` 두 명령을 따로 치는 대신, 값과 만료를 한 번에 정하는 명령(키, 초, 값 순서)으로 빈칸을 채우세요.', '보기의 이름에서 저장과 만료를 모두 뜻하는 것을 찾으세요.',
       'redis-cli {0} price:7 300 1500', ['SETEX', 'SETNX', 'GETEX', 'PERSIST'], [0],
       '`SETEX 키 초 값` 은 저장과 만료 설정을 하나의 명령으로 처리합니다(`SET 키 값 EX 초` 와 같은 효과). `SETNX` 는 키가 없을 때만 저장, `GETEX` 는 읽으면서 만료를 바꾸는 명령, `PERSIST` 는 만료를 없애는 명령이라 이 문장에 맞지 않습니다.')
b.nt('값을 바꿔도 만료는 유지하기', '`price:7` 에 가격 `1000` 이 **300초 만료**로 캐시되어 있습니다. 원본 가격이 `1500` 으로 바뀌어 캐시 값을 갱신하려 합니다. 주의: 옵션 없이 그냥 `SET` 하면 **기존 만료가 사라져** TTL 이 `-1`(영원히 남음)이 되어, 이 키는 갱신 후 계속 쌓이게 됩니다. 값은 `1500` 으로 바꾸되 **만료가 남아 있게**(0초 초과 300초 이하) 하세요.',
     '`SET` 에는 기존 만료를 그대로 두는 옵션(KEEPTTL)이 있습니다. 또는 `EX` 로 만료를 다시 지정해도 됩니다. 끝나면 `TTL price:7` 로 확인하세요.',
     "redis-cli set price:7 1500 keepttl\nredis-cli get price:7\nredis-cli ttl price:7\n\n# 옵션 없는 SET 은 TTL 을 지운다(-1). KEEPTTL 이나 EX 를 붙여 만료를 유지한다",
     R + " && redis-cli set price:7 1000 ex 300 >/dev/null",
     [chk('값이 1500 이다', '[ "$(redis-cli get price:7)" = 1500 ]'), chk('만료가 남아 있다 (1~300초)', 't=$(redis-cli ttl price:7); [ "$t" -gt 0 ] && [ "$t" -le 300 ]')])
b.choice('원본이 바뀌었을 때 캐시 지우기', '상품 가격을 원본 DB 에서 수정했습니다. 변경 직후부터 **옛 가격이 보이지 않게** 하고, 다른 상품의 캐시는 건드리지 않으려 합니다. 요청은 계속 동시에 들어오고, 캐시가 비는 순간 다른 요청이 원본을 읽어 캐시를 다시 채울 수 있습니다. 가장 알맞은 방법은 무엇일까요?',
         '다음 읽기가 새 값을 가져오게 하려면 캐시에 무엇이 남아 있어야 하는지 생각해 보세요.',
         ['원본 DB 를 갱신한 뒤 해당 상품의 캐시 키만 `DEL` 한다', 'TTL 이 끝날 때까지 기다린다 (그동안 옛 값이 나갈 수 있다)', '`FLUSHALL` 로 캐시 전체를 비운다', '캐시 키를 먼저 `DEL` 하고 그 다음에 원본 DB 를 갱신한다'], 0,
         '갱신 후 해당 키만 `DEL` 하면 다음 읽기가 미스가 되어 원본의 새 값을 채웁니다. 기다리기만 하면 TTL 동안 옛 값이 나가고, `FLUSHALL` 은 모든 캐시를 날려 원본에 부하를 줍니다. 순서를 거꾸로(캐시 삭제 → DB 갱신) 하면, 그 사이에 다른 요청이 옛 값을 다시 캐시에 채워 버릴 수 있습니다.')
b.choice('인기 키가 만료되는 순간', '초당 수천 번 읽히는 인기 상품 캐시의 TTL 이 끝났습니다. 그 순간 들어온 수천 개의 요청이 **모두 동시에 캐시 미스**를 만나 각자 원본 DB 를 조회하는 바람에 DB 가 멈췄습니다. 이 현상을 무엇이라 부를까요?',
         '캐시가 "한 번에 비는" 순간 원본으로 몰려드는 무리를 떠올려 보세요.',
         ['캐시 스탬피드(thundering herd)', '캐시 히트율 상승', 'eviction (메모리 부족으로 인한 키 제거)', '복제 지연'], 0,
         '캐시 스탬피드(또는 thundering herd)는 인기 키가 만료되는 순간 많은 요청이 동시에 미스가 되어 원본에 몰리는 현상입니다. 방어는 크게 두 가지로, 한 요청만 재생성하게 막거나(락), 만료 시각이 한꺼번에 몰리지 않게 흩뜨립니다.')
b.nt('한 명만 재생성하기 (SET NX)', '스탬피드를 막으려면 **재생성하는 요청을 한 명으로** 제한합니다. 먼저 `lock:hot` 키를 `SET ... NX EX 10` 으로 잡습니다(`NX`: 없을 때만 저장, 10초 뒤 자동 해제). 락을 잡았을 때만 `/tmp/origin_report.txt`(원본)의 값을 `hot:report` 에 **60초 만료**로 저장하고, 락은 `DEL` 로 해제합니다. 락 시도 결과(성공 시 `OK`)는 `/tmp/got.txt` 에 저장하세요.',
     '`$(...)` 로 `SET ... NX` 의 출력을 변수에 담으면 락 성공 여부(`OK`)를 확인할 수 있습니다. `if [ "$r" = OK ]; then ...; fi` 로 성공했을 때만 재생성합니다.',
     "r=$(redis-cli set lock:hot me nx ex 10)     # 성공하면 OK, 이미 있으면 빈 값(nil)\necho \"$r\" > /tmp/got.txt\nif [ \"$r\" = OK ]; then\n  redis-cli set hot:report \"$(cat /tmp/origin_report.txt)\" ex 60   # 원본 조회 후 캐시 채우기\n  redis-cli del lock:hot                                          # 락 해제\nfi\n\n# 락을 못 잡은 요청은 원본에 가지 않고 잠깐 기다렸다 캐시를 다시 읽는다",
     R + " && echo report-v2 > /tmp/origin_report.txt",
     [chk('락을 잡았다 (OK)', '[ "$(cat /tmp/got.txt)" = OK ]'), chk('캐시가 원본 값으로 채워졌다', '[ "$(redis-cli get hot:report)" = "$(cat /tmp/origin_report.txt)" ]'), chk('캐시에 60초 이하 만료가 있다', 't=$(redis-cli ttl hot:report); [ "$t" -gt 0 ] && [ "$t" -le 60 ]'), chk('락이 해제되었다', '[ "$(redis-cli exists lock:hot)" = 0 ]')])
b.choice('같은 시각에 한꺼번에 만료되는 키들', '서버를 재시작한 직후 캐시 키 수만 개를 모두 `EX 3600` 으로 채웠습니다. 정확히 1시간 뒤 이 키들이 **거의 동시에 만료**되어 원본 DB 가 폭주할 것이 걱정됩니다. 캐시 효과는 유지하면서 가장 효과적인 방어는?',
         '만료 시각이 한 점에 몰리는 것이 문제입니다. 시각을 퍼뜨릴 방법을 찾아 보세요.',
         ['TTL 에 무작위 편차를 더해(예: 3600 + 0~300초) 만료 시각을 흩뜨린다', '모든 키의 TTL 을 더 길게 통일한다', '캐시를 쓰지 않고 항상 원본을 조회한다', '`maxmemory` 를 줄인다'], 0,
         'TTL 에 무작위 값을 더하면(지터) 키마다 만료 시각이 달라져 재생성 요청이 시간에 걸쳐 퍼집니다. TTL 을 길게 통일해도 만료 시각이 한 점에 몰리는 것은 그대로입니다. 원본만 조회하면 캐시의 의미가 없고, 메모리 한도를 줄이면 오히려 키가 제거될 수 있습니다.')
b.nt('세션 정보를 Hash 에 저장하기', '로그인한 사용자의 세션을 Redis 에 저장합니다. `sess:abc123` 이라는 **Hash** 키에 `user` 필드는 `kim`, `role` 필드는 `admin` 을 넣고, 30분(**1800초**) 뒤 자동으로 사라지게 만드세요. 세션은 만료 시각이 지나면 저절로 로그아웃되는 것과 같습니다.',
     'Hash 는 `HSET 키 필드 값 [필드 값 ...]` 으로 저장합니다. 만료는 키 단위(`EXPIRE 키 초`)로 겁니다. 끝나면 `TYPE`, `HGETALL`, `TTL` 로 확인하세요.',
     "redis-cli hset sess:abc123 user kim role admin\nredis-cli expire sess:abc123 1800\nredis-cli hgetall sess:abc123\nredis-cli ttl sess:abc123\n\n# 세션은 필드가 여럿이라 Hash 가 편하다. 만료는 필드가 아니라 키 전체에 건다",
     R,
     [chk('Hash 타입이다', '[ "$(redis-cli type sess:abc123)" = hash ]'), chk('user 는 kim, role 은 admin 이다', '[ "$(redis-cli hget sess:abc123 user)" = kim ] && [ "$(redis-cli hget sess:abc123 role)" = admin ]'), chk('만료가 걸려 있다 (1~1800초)', 't=$(redis-cli ttl sess:abc123); [ "$t" -gt 0 ] && [ "$t" -le 1800 ]')])
b.nt('가장 메모리를 많이 쓰는 키 찾기', '캐시 메모리가 빠르게 늘고 있습니다. Redis 에는 작은 키 `u:1` ~ `u:50` 과 세션 해시 `sess:x`, 그리고 종류와 크기가 다른 키 몇 개가 더 있습니다. `MEMORY USAGE 키` 는 키 하나가 쓰는 바이트 수를 알려 줍니다. 키를 돌며 **가장 큰 키의 이름**을 `/tmp/big.txt` 에 저장하고, 그 키를 `UNLINK` 로 지우세요. 다른 키는 그대로 남아야 합니다.',
     '`redis-cli --scan` 은 모든 키 이름을 한 줄씩 보여 줍니다. 키 이름을 하나씩 순회해 `MEMORY USAGE` 값과 이름을 짝지어 가장 큰 것을 고릅니다. (`redis-cli --bigkeys` 도 참고용으로 쓸 수 있습니다.)',
     "for k in $(redis-cli --scan); do echo \"$(redis-cli memory usage $k) $k\"; done | sort -rn | head -1 | awk '{print $2}' > /tmp/big.txt\ncat /tmp/big.txt\nredis-cli unlink $(cat /tmp/big.txt)\n\n# --bigkeys 는 자료형별로 가장 큰 키를 보여 주고, MEMORY USAGE 는 키 하나의 실제 바이트 수를 잰다",
     R + " && redis-cli eval \"for i=1,50 do redis.call('set','u:'..i,'v') end; redis.call('hset','sess:x','a',1,'b',2,'c',3); for i=1,5000 do redis.call('rpush','cart:7','item'..i) end\" 0 >/dev/null",
     [chk('가장 큰 키 이름이 저장되었다', '[ "$(cat /tmp/big.txt)" = cart:7 ]'), chk('큰 키가 삭제되었다', '[ "$(redis-cli exists cart:7)" = 0 ]'), chk('나머지 51개 키가 남아 있다', '[ "$(redis-cli dbsize)" = 51 ]')])
b.choice('--hotkeys 가 에러를 낼 때', '특정 키에 요청이 몰리는 hot key 를 찾으려고 `redis-cli --hotkeys` 를 실행했더니 "An LFU maxmemory policy is not selected" 라는 에러가 났습니다. 어떻게 해석할까요?',
         '메시지에 나온 LFU 가 무엇의 약자인지, 어느 설정과 관련 있는지 읽어 보세요.',
         ['접근 빈도를 기록하는 LFU 계열 `maxmemory-policy`(예: `allkeys-lfu`)일 때만 `--hotkeys` 를 쓸 수 있다', 'Redis 서버가 꺼져 있다', '`--hotkeys` 는 읽기 전용 계정에서만 동작한다', '키가 하나도 없어서 나는 에러다'], 0,
         '`--hotkeys` 는 키별 접근 빈도를 이용하므로 `maxmemory-policy` 가 `allkeys-lfu` 나 `volatile-lfu` 일 때만 동작합니다. 정책을 바꾸기 어려우면 `--bigkeys`·`MEMORY USAGE`·`SLOWLOG` 같은 다른 단서나 애플리케이션 쪽 호출 통계로 대신합니다. 서버가 꺼져 있으면 "Connection refused" 가 나옵니다.')

if __name__ == '__main__':
    preview(b)
