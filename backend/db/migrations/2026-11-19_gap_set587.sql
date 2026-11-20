-- 세트 587. 여러 번 실행해도 안전하다 (NOT EXISTS 가드). 원본: 02_quest_set.sql, 03_quest_set587.sql, 05·06·08. docs/specs/spec_pilot_gap_sets.md
INSERT INTO quest_set (id, title, description, sandbox_type, category)
SELECT 587, 'ip·ss 실전 점검: 주소·MTU 읽기, LISTEN·ESTAB 소켓, 프로세스 찾기', '장애 때 가장 먼저 치는 ip 와 ss 를 실제로 써 보는 실습입니다. ip -br 로 주소와 상태를 읽고, 링크의 MTU 를 확인하고, ss 로 LISTEN 중인 포트와 연결(ESTAB)을 보고, -p 로 포트를 쥔 프로세스를 찾습니다. 주소를 바꾸는 명령은 샌드박스에서 권한이 없어 명령을 파일에 적는 방식입니다.', 'linux', '네트워크'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest_set WHERE id = 587);
UPDATE quest_set SET display_order = 847, unit_id = (SELECT id FROM unit WHERE id = 68), icon = '🔧' WHERE id = 587;

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 1, 'ip -br 로 주소 읽기', '`ip -br addr` 은 인터페이스별 상태와 주소를 한 줄씩 보여 줍니다. **루프백(`lo`) 인터페이스의 IPv4 주소**(접두어 길이 포함, 예: `10.0.0.1/24` 모양)를 `/tmp/lo_ip.txt` 에 저장하세요. (IPv4 한 개만)', '`lo` 줄에는 IPv4 와 IPv6 주소가 함께 나옵니다. IPv4 쪽만 고르세요.', 'ip -br addr
ip -br addr show lo | tr '' '' ''\\n'' | grep -E ''^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/'' | head -1 > /tmp/lo_ip.txt
cat /tmp/lo_ip.txt

# 127.0.0.1/8 은 자기 자신용 주소다. -br 은 한 줄 요약, -c 는 색, -s 는 카운터를 붙인다', '["sh", "-c", "pkill -x nc 2>/dev/null; sleep 0.3\\nrm -f /tmp/*.txt\\nnohup nc -l -k 127.0.0.1 9101 >/dev/null 2>&1 &\\nnohup nc -l -k 127.0.0.1 9102 >/dev/null 2>&1 &\\nsleep 0.5\\ntrue"]', '["sh", "-c", "( [ \\"$(cat /tmp/lo_ip.txt)\\" = 127.0.0.1/8 ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "127.0.0.1/8 이다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/lo_ip.txt)\\" = 127.0.0.1/8 ]"]}]', '[{"title": "ip 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip.8.html"}, {"title": "ss 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 1);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 2, '링크의 MTU 읽기', '`ip link show lo` 의 첫 줄에는 인터페이스 상태와 `mtu 숫자` 가 있습니다. MTU 는 한 번에 보낼 수 있는 가장 큰 패킷 크기입니다. **`lo` 의 MTU 값**을 숫자만 `/tmp/mtu.txt` 에 저장하세요.', '첫 줄에서 `mtu` 바로 다음 칸입니다.', 'ip link show lo
ip link show lo | head -1 | grep -o ''mtu [0-9]*'' | cut -d'' '' -f2 > /tmp/mtu.txt
cat /tmp/mtu.txt

# 이더넷은 보통 1500, 터널·오버레이를 거치면 더 작아진다. MTU 불일치는 큰 패킷만 실패하는 증상을 만든다', '["sh", "-c", "pkill -x nc 2>/dev/null; sleep 0.3\\nrm -f /tmp/*.txt\\nnohup nc -l -k 127.0.0.1 9101 >/dev/null 2>&1 &\\nnohup nc -l -k 127.0.0.1 9102 >/dev/null 2>&1 &\\nsleep 0.5\\ntrue"]', '["sh", "-c", "( [ \\"$(cat /tmp/mtu.txt)\\" = \\"$(cat /sys/class/net/lo/mtu)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "실제 MTU 와 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/mtu.txt)\\" = \\"$(cat /sys/class/net/lo/mtu)\\" ]"]}]', '[{"title": "ip 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip.8.html"}, {"title": "ss 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 2);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 3, 'LISTEN 중인 포트 찾기', '이 서버에는 연습용 서버 두 개가 TCP 포트에서 연결을 기다리고(LISTEN) 있습니다. `ss` 로 **LISTEN 중인 TCP 포트 번호를 오름차순으로 한 줄에 하나씩** `/tmp/ports.txt` 에 저장하세요. (숫자만)', '`ss` 에는 LISTEN 소켓만(`-l`), TCP 만(`-t`), 숫자로(`-n`) 보는 옵션이 있습니다. 주소 칸에서 마지막 `:` 뒤가 포트입니다.', 'ss -ltn
ss -ltnH | awk ''{print $4}'' | awk -F: ''{print $NF}'' | sort -n > /tmp/ports.txt
cat /tmp/ports.txt

# 127.0.0.1:9101 처럼 주소와 포트가 함께 나온다. 0.0.0.0 이나 [::] 는 모든 주소에서 받는다는 뜻이다', '["sh", "-c", "pkill -x nc 2>/dev/null; sleep 0.3\\nrm -f /tmp/*.txt\\nnohup nc -l -k 127.0.0.1 9101 >/dev/null 2>&1 &\\nnohup nc -l -k 127.0.0.1 9102 >/dev/null 2>&1 &\\nsleep 0.5\\ntrue"]', '["sh", "-c", "( grep -qx 9101 /tmp/ports.txt && grep -qx 9102 /tmp/ports.txt ) && ( [ \\"$(cat /tmp/ports.txt)\\" = \\"$(ss -ltnH | awk ''{print $4}'' | awk -F: ''{print $NF}'' | sort -n)\\" ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "9101 과 9102 가 있다", "cmd": ["sh", "-c", "grep -qx 9101 /tmp/ports.txt && grep -qx 9102 /tmp/ports.txt"]}, {"label": "실제 LISTEN 포트와 같다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/ports.txt)\\" = \\"$(ss -ltnH | awk ''{print $4}'' | awk -F: ''{print $NF}'' | sort -n)\\" ]"]}]', '[{"title": "ip 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip.8.html"}, {"title": "ss 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 3);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 4, '연결 맺어 두기(ESTAB)', '9101 포트의 서버에 **연결을 맺은 채로 유지**하는 클라이언트를 백그라운드로 실행해 두세요. `ss` 에서 그 연결이 `ESTAB`(연결 수립) 상태로 보여야 합니다. (연결이 바로 끊기지 않도록 입력을 기다리게 둡니다)', '`nc` 는 표준 입력이 끝나면 연결을 닫습니다. 입력이 끝나지 않게 이어 주는 방법을 생각하고, 쉘에서 뒤로 보내는 `&` 를 쓰세요.', '(sleep 300 | nc 127.0.0.1 9101 >/dev/null 2>&1 &)
sleep 1
ss -tn state established

# 연결 한쪽이 클라이언트 임시 포트(예: 127.0.0.1:4xxxx), 다른 쪽이 9101 이다. 서버 쪽에서 보면 같은 연결이 반대로 보인다', '["sh", "-c", "pkill -x nc 2>/dev/null; sleep 0.3\\nrm -f /tmp/*.txt\\nnohup nc -l -k 127.0.0.1 9101 >/dev/null 2>&1 &\\nnohup nc -l -k 127.0.0.1 9102 >/dev/null 2>&1 &\\nsleep 0.5\\ntrue"]', '["sh", "-c", "( ss -tnH state established \\"( dport = :9101 )\\" | grep -q . )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "9101 로의 ESTAB 연결이 있다", "cmd": ["sh", "-c", "ss -tnH state established \\"( dport = :9101 )\\" | grep -q ."]}]', '[{"title": "ip 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip.8.html"}, {"title": "ss 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 4);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 5, '포트를 쥔 프로세스', '9102 포트를 **LISTEN 하는 프로세스의 이름**을 `ss` 로 찾아 이름만 `/tmp/proc.txt` 에 저장하세요. (예: 출력의 `users:(("이름",pid=...,fd=..))` 에서 이름)', '`ss` 에 프로세스 정보를 붙이는 옵션이 있습니다. 출력의 `users:` 부분에서 따옴표 안이 이름입니다.', 'ss -ltnp | grep '':9102''
ss -ltnp | grep '':9102'' | grep -o ''users:(("[^"]*"'' | cut -d''"'' -f2 > /tmp/proc.txt
cat /tmp/proc.txt

# 포트 충돌(Address already in use)이 날 때 누가 그 포트를 쥐고 있는지 찾는 기본 방법이다. 다른 사용자의 프로세스는 root 권한이 있어야 보인다', '["sh", "-c", "pkill -x nc 2>/dev/null; sleep 0.3\\nrm -f /tmp/*.txt\\nnohup nc -l -k 127.0.0.1 9101 >/dev/null 2>&1 &\\nnohup nc -l -k 127.0.0.1 9102 >/dev/null 2>&1 &\\nsleep 0.5\\ntrue"]', '["sh", "-c", "( [ \\"$(cat /tmp/proc.txt)\\" = nc ] )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "nc 다", "cmd": ["sh", "-c", "[ \\"$(cat /tmp/proc.txt)\\" = nc ]"]}]', '[{"title": "ip 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip.8.html"}, {"title": "ss 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 5);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 6, '주소 추가 명령 적기', '`lo` 인터페이스에 보조 주소 **`192.0.2.77/32`** 를 추가하려 합니다. 샌드박스에서는 주소를 바꿀 권한이 없으니 실행할 **`ip` 명령 한 줄**을 `/tmp/add_ip.txt` 에 적으세요.', '`ip addr` 의 하위 동작 중 추가하는 것을 고르고, 주소와 어느 인터페이스에 붙일지를 함께 적습니다.', 'echo ''ip addr add 192.0.2.77/32 dev lo'' > /tmp/add_ip.txt
cat /tmp/add_ip.txt

# 이 방법은 재부팅하면 사라진다. 영구 설정은 netplan·NetworkManager 에 적는다. 확인은 ip -br addr, 되돌리기는 ip addr del', '["sh", "-c", "pkill -x nc 2>/dev/null; sleep 0.3\\nrm -f /tmp/*.txt\\nnohup nc -l -k 127.0.0.1 9101 >/dev/null 2>&1 &\\nnohup nc -l -k 127.0.0.1 9102 >/dev/null 2>&1 &\\nsleep 0.5\\ntrue"]', '["sh", "-c", "( grep -Eq \\"^[[:space:]]*(sudo )?ip( -4)? a(d|dd|ddr|ddress)? (a|ad|add) (dev lo 192\\\\.0\\\\.2\\\\.77/32|192\\\\.0\\\\.2\\\\.77/32 dev lo)( .*)?$\\" /tmp/add_ip.txt )"]', 'terminal', NULL, NULL, NULL, NULL, NULL, '[{"label": "주소 추가 명령이다", "cmd": ["sh", "-c", "grep -Eq \\"^[[:space:]]*(sudo )?ip( -4)? a(d|dd|ddr|ddress)? (a|ad|add) (dev lo 192\\\\.0\\\\.2\\\\.77/32|192\\\\.0\\\\.2\\\\.77/32 dev lo)( .*)?$\\" /tmp/add_ip.txt"]}]', '[{"title": "ip 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip.8.html"}, {"title": "ss 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}]'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 6);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 7, 'ss -ltn 의 Send-Q', '`ss -ltn` 으로 LISTEN 소켓을 보면 `Recv-Q` 와 `Send-Q` 열이 있습니다. LISTEN 상태에서 이 두 열의 의미로 가장 알맞은 것은?', '연결 대기열과 관련된 값입니다.', NULL, NULL, '[]', 'choice', '["Recv-Q 는 받은 바이트 수, Send-Q 는 보낸 바이트 수의 누계다", "Recv-Q 는 서버의 CPU 사용률, Send-Q 는 메모리 사용량이다", "Recv-Q 는 대기열에 쌓인 연결 수, Send-Q 는 대기열의 최대 크기다", "두 열은 LISTEN 소켓에서는 언제나 0 이다"]', 2, 'LISTEN 소켓에서 Recv-Q 는 accept 되기를 기다리는 연결 수, Send-Q 는 backlog 한도입니다. Recv-Q 가 Send-Q 에 가까우면 서버가 연결을 받아 주지 못해 대기열이 넘치는 중입니다. ESTAB 소켓에서는 각각 아직 읽지 않은 바이트와 확인되지 않은 보낸 바이트를 뜻합니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 7);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 8, '원격에서 인터페이스를 내릴 때', 'SSH 로 접속한 서버에서 `ip link set dev eth0 down` 을 실행하려 합니다. 이 서버의 유일한 접속 경로가 eth0 입니다. 가장 알맞은 판단은?', '명령이 실행되는 순간 내 접속이 어떻게 되는지 생각해 보세요.', NULL, NULL, '[]', 'choice', '["명령이 곧바로 올라가므로 문제없이 그대로 실행해도 된다", "접속이 끊겨 되돌릴 수 없으니 콘솔 접근·자동 복구를 먼저 마련한다", "down 은 설정만 저장하고 실제로는 영향이 없다", "SSH 연결은 인터페이스 상태와 무관하게 유지된다"]', 1, '유일한 경로의 인터페이스를 내리면 SSH 접속이 끊겨 스스로 복구할 수 없습니다. 콘솔(IPMI·가상 콘솔) 접근을 확보하거나 `nohup sh -c "sleep 60; ip link set dev eth0 up" &` 처럼 접속과 분리된 복구 예약을 함께 걸어 둡니다.', NULL, NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 8);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 9, '프로세스까지 보는 ss 옵션', 'LISTEN 중인 TCP 포트를 숫자로 보면서 **그 포트를 쥔 프로세스**까지 함께 보려 합니다. 빈칸을 채우세요.', '`ss` 의 옵션 목록에서 프로세스와 관련된 글자를 찾아 보세요.', NULL, NULL, '[]', 'fill', '["p", "e", "o", "m"]', NULL, '`-p` 는 소켓을 쥔 프로세스를 보여 줍니다(다른 사용자의 프로세스는 root 권한 필요). `-e` 는 확장 정보(uid·inode), `-o` 는 타이머, `-m` 은 소켓 메모리를 보여 줍니다.', '[0]', 'ss -ltn{0}', NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 9);

INSERT INTO quest (quest_set_id, order_index, title, description, hint, solution, setup_cmd, grade_cmd, kind, choices, answer_index, explanation, answer_spec, template, checks, docs)
SELECT 587, 10, '서비스에 접속이 안 될 때 서버 안쪽 점검 순서', '클라이언트에서 서버의 한 포트로 접속이 안 됩니다. 서버에 로그인해서 서비스 자체에서 시작해 바깥 쪽으로 확인하려 합니다. 올바른 순서로 놓으세요.', '안쪽(서비스)에서 바깥(네트워크)으로 한 칸씩 넓혀 가세요.', NULL, NULL, '[]', 'order', '["LISTEN 주소가 127.0.0.1 인지 모든 주소(0.0.0.0)인지 확인한다", "방화벽·보안 그룹이 그 포트를 허용하는지 확인한다", "`ss -ltn` 으로 그 포트가 LISTEN 중인지 확인한다", "서비스 프로세스가 실행 중인지 확인한다"]', NULL, '프로세스가 떠 있고, 그 포트로 LISTEN 중이며, 외부에서 닿는 주소로 열려 있는지(127.0.0.1 에만 열려 있으면 바깥에서 못 들어옴) 확인한 뒤, 마지막으로 방화벽을 봅니다.', '[3, 2, 0, 1]', NULL, NULL, NULL
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM quest WHERE quest_set_id = 587 AND order_index = 10);
