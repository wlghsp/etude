import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 564: Redis 복제 직접 해 보기: REPLICAOF, INFO replication, 읽기 전용, 수동 승격(failover). 명세: docs/specs/spec_gap_set564.md
# 선행: 400(복제 개념), 563. 한 컨테이너에 redis-server 두 개(6379 primary, 6380 replica). 로컬에서 복제·승격·옛 primary 편입을 직접 확인했다.

STOPR = "pkill redis-server >/dev/null 2>&1; sleep 1; rm -f /tmp/*.txt"
PRIM = STOPR + "; redis-server --daemonize yes --save '' --bind 127.0.0.1 --port 6379 >/dev/null; sleep 1; redis-cli set greeting hello >/dev/null"
LINKED = PRIM + "; redis-server --daemonize yes --save '' --bind 127.0.0.1 --port 6380 --replicaof 127.0.0.1 6379 >/dev/null; for i in $(seq 1 30); do [ \"$(redis-cli -p 6380 get greeting)\" = hello ] && break; sleep 0.5; done"
DOWN = LINKED + "; redis-cli -p 6379 shutdown nosave >/dev/null 2>&1; sleep 1"
# 6380 이 새 primary 로 승격되어 new 키를 가졌고, 옛 primary 는 혼자 다시 떠서 old 키만 갖고 있다
FAILOVER = (DOWN + "; redis-cli -p 6380 replicaof no one >/dev/null; redis-cli -p 6380 set new 2 >/dev/null; "
            "redis-server --daemonize yes --save '' --bind 127.0.0.1 --port 6379 >/dev/null; sleep 1; redis-cli set old 1 >/dev/null")
INFO = lambda port, f: f"redis-cli -p {port} info replication | grep '^{f}:' | cut -d: -f2 | tr -d '\\r'"
WAITG = lambda port, key, val: f"for i in $(seq 1 30); do [ \"$(redis-cli -p {port} get {key})\" = {val} ] && break; sleep 0.5; done"

b = SetBuilder(564, 'Redis 복제 직접 해 보기: REPLICAOF·INFO replication·읽기 전용·수동 승격',
               'redis-server 두 개(6379 primary, 6380 replica)로 Redis 복제를 직접 다룹니다. replica 를 띄워 primary 를 따라가게 하기, INFO replication 으로 역할과 연결 상태 읽기, replica 에 쓰려 할 때의 READONLY 오류, primary 가 죽었을 때 master_link_status 읽기, REPLICAOF NO ONE 으로 승격하기, 돌아온 옛 primary 를 새 primary 의 replica 로 편입하기를 실습합니다.',
               'linux', '데이터베이스', 31, 824, '🔄',
               [{"title": "Redis 복제", "url": "https://redis.io/docs/latest/operate/oss_and_stack/management/replication/"}, {"title": "REPLICAOF 명령", "url": "https://redis.io/docs/latest/commands/replicaof/"}], 5)

# 1
b.nt('replica 를 띄워 primary 를 따라가게 하기', '포트 `6379` 의 Redis(primary)에 `greeting=hello` 키가 있습니다. **포트 `6380`** 에 새 Redis 를 띄워 6379 의 **복제본(replica)** 이 되게 하세요. 새 서버는 `redis-server` 옵션으로 만들며, 다음 조건을 지킵니다.\n- 백그라운드로 실행(`--daemonize yes`), 저장 안 함(`--save \'\'`), 접속 주소는 `127.0.0.1`\n- primary 의 주소와 포트를 지정해 시작과 동시에 복제 시작\n\n끝나면 6380 에서 `GET greeting` 이 `hello` 여야 합니다.',
     '복제 대상은 `--replicaof 호스트 포트` 옵션으로 지정합니다. 이미 떠 있는 서버라면 같은 이름의 명령 `REPLICAOF` 로도 할 수 있습니다.',
     "redis-server --daemonize yes --save '' --bind 127.0.0.1 --port 6380 --replicaof 127.0.0.1 6379\nsleep 2\nredis-cli -p 6380 get greeting\nredis-cli -p 6380 role | head -1\n\n# 시작하면 primary 에서 전체 데이터를 받고(전체 동기화) 그 뒤 변경을 계속 따라 받는다",
     PRIM, [chk('6380 에서 hello 를 읽는다', WAITG(6380, 'greeting', 'hello') + '; [ "$(redis-cli -p 6380 get greeting)" = hello ]'), chk('6380 의 역할이 replica 다', '[ "$(redis-cli -p 6380 role | head -1)" = slave ]'), chk('primary 가 6379 다', '[ "$(' + INFO(6380, 'master_port') + ')" = 6379 ]')])
# 2
b.nt('INFO replication 으로 역할과 연결 읽기', '복제가 연결된 상태입니다. **primary(6379)** 의 `INFO replication` 에서 아래 두 값을 저장하세요. (값만)\n- `/tmp/role.txt` : `role` (서버의 역할)\n- `/tmp/slaves.txt` : `connected_slaves` (연결된 replica 수)',
     '`redis-cli -p 6379 info replication` 은 `항목:값` 줄들을 돌려줍니다. `grep ^항목:` 과 `cut -d: -f2` 로 값을 뽑고, 줄 끝의 캐리지 리턴은 `tr -d \'\\r\'` 로 지웁니다.',
     INFO(6379, 'role') + " > /tmp/role.txt\n" + INFO(6379, 'connected_slaves') + " > /tmp/slaves.txt\ncat /tmp/role.txt /tmp/slaves.txt\n\n# role:master, connected_slaves:1. replica 쪽에서 보면 role:slave, master_link_status:up. 복제 점검의 첫 명령이다",
     LINKED, [chk('role 이 master 다', '[ "$(tr -d \'\\r\\n\' < /tmp/role.txt)" = master ]'), chk('연결된 replica 가 1 이다', '[ "$(tr -d \'\\r\\n\' < /tmp/slaves.txt)" = 1 ]')])
# 3
b.nt('replica 에는 쓸 수 없다', '복제 중인 **replica(6380)** 에 `SET mykey 1` 을 시도해 보세요. 나오는 **오류 메시지를 `/tmp/ro.txt`** 에 저장하세요. (`redis-cli -p 6380 ...`) replica 에 쓰면 안 되는 이유를 직접 확인합니다.',
     '출력 전체를 `>` 로 저장하면 됩니다. replica 는 primary 의 복사본이라 따로 쓰면 둘이 달라집니다. 서버가 어떻게 막는지 메시지를 읽어 보세요.',
     "redis-cli -p 6380 set mykey 1 > /tmp/ro.txt\ncat /tmp/ro.txt\n\n# READONLY You can't write against a read only replica. 쓰기는 항상 primary 로 보내야 한다(replica-read-only yes 가 기본값)",
     LINKED, [chk('READONLY 오류가 기록됐다', 'grep -q READONLY /tmp/ro.txt'), chk('키가 만들어지지 않았다', '[ "$(redis-cli -p 6380 exists mykey)" = 0 ]')])
# 4
b.nt('primary 가 죽었다: replica 의 연결 상태 읽기', 'primary(6379)가 갑자기 죽었습니다. 살아 있는 **replica(6380)** 의 `INFO replication` 에서 아래 두 값을 저장하세요. (값만)\n- `/tmp/link.txt` : `master_link_status` (primary 와의 연결 상태)\n- `/tmp/mport.txt` : `master_port` (따라가던 primary 의 포트)',
     '`redis-cli -p 6380 info replication` 의 `master_link_status` 와 `master_port` 줄입니다. 앞 문제처럼 `grep`·`cut`·`tr` 로 값만 뽑으세요.',
     INFO(6380, 'master_link_status') + " > /tmp/link.txt\n" + INFO(6380, 'master_port') + " > /tmp/mport.txt\ncat /tmp/link.txt /tmp/mport.txt\n\n# master_link_status:down. replica 는 primary 가 돌아오기를 기다리며 읽기는 계속 응답한다(데이터는 마지막 동기화 시점까지)",
     DOWN, [chk('연결이 down 이다', '[ "$(tr -d \'\\r\\n\' < /tmp/link.txt)" = down ]'), chk('master_port 가 6379 다', '[ "$(tr -d \'\\r\\n\' < /tmp/mport.txt)" = 6379 ]')])
# 5
b.nt('replica 를 새 primary 로 승격하기', 'primary 는 한동안 돌아오지 못합니다. **replica(6380)를 새 primary 로 승격**해서 서비스가 쓰기를 계속하게 하세요. 승격한 뒤에는 6380 의 역할이 `master` 이고, **쓰기가 가능**하며, 기존 데이터(`greeting`)가 그대로 있어야 합니다. 승격한 뒤 6380 에 `SET promoted yes` 를 실행해 두세요.',
     '복제 관계를 끊는 명령은 `REPLICAOF` 에 "아무도 따르지 않음"을 뜻하는 인자를 줍니다. 확인은 `redis-cli -p 6380 role`.',
     "redis-cli -p 6380 replicaof no one\nredis-cli -p 6380 role | head -1\nredis-cli -p 6380 set promoted yes\nredis-cli -p 6380 get greeting\n\n# REPLICAOF NO ONE: 복제를 끊고 스스로 primary 가 된다. 이후 앱의 접속 대상을 6380 으로 바꿔야 한다(수동 failover). 자동화는 Sentinel 이 해 준다",
     DOWN, [chk('6380 이 master 다', '[ "$(redis-cli -p 6380 role | head -1)" = master ]'), chk('쓰기가 된다', '[ "$(redis-cli -p 6380 get promoted)" = yes ]'), chk('기존 데이터가 있다', '[ "$(redis-cli -p 6380 get greeting)" = hello ]')])
# 6
b.nt('돌아온 옛 primary 를 새 primary 의 replica 로', '승격이 끝나 **6380 이 새 primary** 가 되었고 `new=2` 키를 가졌습니다. 그 사이 옛 primary(**6379**)가 다시 떠서 혼자(독립) 동작 중이며 `old=1` 키를 가지고 있습니다. 이대로 두면 두 서버가 각자 primary 라 데이터가 갈라집니다(split brain).\n\n**6379 가 6380 을 따라가는 replica** 가 되게 하세요. 완료 후 6379 에서 `new` 가 `2` 로 읽히고 `old` 는 사라져 있어야 합니다. (옛 primary 에만 있던 쓰기는 버려집니다.)',
     '이미 떠 있는 서버에서 `REPLICAOF 호스트 포트` 명령을 쓰면 됩니다. 연결 직후 전체 동기화를 하니 몇 초 기다렸다가 확인하세요.',
     "redis-cli -p 6379 replicaof 127.0.0.1 6380\nsleep 2\nredis-cli -p 6379 get new\nredis-cli -p 6379 get old\nredis-cli -p 6379 role | head -1\n\n# replica 가 되는 순간 새 primary 의 데이터로 통째로 덮어쓴다. 옛 primary 에만 있던 쓰기(old)는 유실되니, failover 전에 복제가 따라잡았는지가 중요하다",
     FAILOVER, [chk('6379 가 replica 다', WAITG(6379, 'new', '2') + '; [ "$(redis-cli -p 6379 role | head -1)" = slave ]'), chk('new 가 2 다', '[ "$(redis-cli -p 6379 get new)" = 2 ]'), chk('old 는 없다', '[ "$(redis-cli -p 6379 exists old)" = 0 ]'), chk('연결이 up 이다', '[ "$(' + INFO(6379, 'master_link_status') + ')" = up ]')])
# 7
b.choice('복제를 믿고 failover 할 때의 주의', 'Redis 복제는 기본적으로 **비동기**입니다. primary 가 갑자기 죽어 replica 를 승격하면 어떤 일이 생길 수 있나요?', '응답과 전달이 같은 시점인지 생각해 보세요.',
         ['최근에 응답한 쓰기가 replica 에 없어서 유실될 수 있다', '복제가 동기라서 유실은 전혀 없다', '승격하면 모든 키가 삭제된다', '승격이 replica 의 데이터 파일을 primary 와 교환한다'], 0,
         '비동기 복제에서는 primary 가 쓰기에 응답한 직후 죽으면 그 변경이 replica 에 전달되기 전일 수 있어 승격 후 유실됩니다. 필요하면 WAIT 명령으로 지정한 수의 replica 가 받았는지 확인하지만, 이것도 완전한 보장은 아닙니다.')
# 8
b.choice('replica 로 읽기를 보낼 때 주의', '읽기 부하를 줄이려고 앱의 조회를 replica 로 보냈습니다. 가장 알맞은 주의점은 무엇인가요?', '복제가 비동기라는 점과 직결됩니다.',
         ['방금 쓴 값이 replica 에서 잠시 안 보일 수 있다', 'replica 는 항상 primary 보다 최신 데이터를 가진다', 'replica 로 보낸 읽기는 primary 에 쓰기가 된다', 'replica 는 GET 명령을 지원하지 않는다'], 0,
         '복제 지연 때문에 replica 의 데이터는 primary 보다 조금 늦을 수 있습니다. 그래서 방금 쓴 값을 바로 읽어야 하는 곳은 primary 를 읽거나 지연을 허용해야 합니다. replica 는 읽기를 지원하고, 최신이 아닌 쪽이며, 읽기가 쓰기가 되지는 않습니다.')
# 9
b.fill('복제 관계 끊고 primary 로', 'replica 를 복제 관계에서 분리해 스스로 primary 가 되게 하는 명령의 빈칸을 채우세요.', '"아무도 따르지 않는다"는 뜻의 두 단어입니다.',
       'REPLICAOF {0}', ['NO ONE', '127.0.0.1 6379', 'ALL', 'NONE'], [0],
       '`REPLICAOF NO ONE` 은 복제를 끊고 해당 서버를 독립 primary 로 만듭니다. `REPLICAOF 호스트 포트` 는 그 서버를 따르게 하는 것입니다.')
# 10
b.order('수동 failover 순서', 'primary 가 죽어 replica 를 수동으로 승격하고 서비스를 복구하는 순서입니다. 옛 primary 는 맨 마지막에 정리합니다.', '새 primary 가 정해지기 전에 앱을 돌리면 어떻게 되는지 생각해 보세요.',
        ['옛 primary 가 복구되면 새 primary 를 따라가도록 REPLICAOF 설정', 'primary 가 정말 응답하지 않는지, replica 의 master_link_status 가 down 인지 확인', '앱의 Redis 접속 대상을 새 primary 로 변경', '승격할 replica 에서 REPLICAOF NO ONE 실행'], [1, 3, 2, 0],
        '먼저 primary 장애가 맞는지(그리고 replica 가 데이터를 가지고 있는지) 확인하고, 승격할 replica 에서 REPLICAOF NO ONE 으로 primary 로 만듭니다. 앱의 접속 대상을 새 primary 로 돌린 뒤, 옛 primary 는 복구되면 새 primary 의 replica 가 되도록 설정해 데이터가 갈라지지 않게 합니다.')

if __name__ == '__main__':
    preview(b)
