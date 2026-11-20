import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 575: 연결 장애 상황집(2) 방화벽·NAT·경로. 명세: docs/specs/spec_gap_set575.md
# 샌드박스 linux(비특권, NET_ADMIN·iptables·tcpdump 없음). 장애 현장에서 모은 출력(샘플)을 읽고 원인을 좁히는 상황집이다.

S75 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/curl.log <<'EOF'
$ curl -sS -m 5 http://192.0.2.20:8080/
curl: (7) Failed to connect to 192.0.2.20 port 8080 after 1 ms: Connection refused
$ curl -sS -m 5 http://192.0.2.20:8443/
curl: (28) Connection timed out after 5001 milliseconds
EOF
cat > /tmp/fw.log <<'EOF'
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination
1     5000  300K ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
2     900K  120M ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate RELATED,ESTABLISHED
3      420 25200 DROP       tcp  --  *      *       203.0.113.0/24       0.0.0.0/0            tcp dpt:8443
4       12   720 ACCEPT     tcp  --  *      *       192.0.2.0/24         0.0.0.0/0            tcp dpt:22
5        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:8443
EOF
cat > /tmp/conn.log <<'EOF'
tcp      6 118 SYN_SENT src=203.0.113.77 dst=203.0.113.10 sport=51000 dport=8443 [UNREPLIED] src=192.0.2.20 dst=203.0.113.77 sport=443 dport=51000 mark=0 use=1
tcp      6 431999 ESTABLISHED src=203.0.113.88 dst=203.0.113.10 sport=51111 dport=2222 src=192.0.2.21 dst=203.0.113.88 sport=22 dport=51111 [ASSURED] mark=0 use=1
tcp      6 117 SYN_SENT src=203.0.113.99 dst=203.0.113.10 sport=51222 dport=8443 [UNREPLIED] src=192.0.2.20 dst=203.0.113.99 sport=443 dport=51222 mark=0 use=1
EOF
cat > /tmp/route_err.log <<'EOF'
$ ip route
192.0.2.0/24 dev eth0 proto kernel scope link src 192.0.2.50
$ ip route get 203.0.113.50
RTNETLINK answers: Network is unreachable
EOF
cat > /tmp/sysctl.log <<'EOF'
net.ipv4.ip_forward = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
EOF
cat > /tmp/cap_eth0.log <<'EOF'
10:00:00.000100 IP 203.0.113.77.51000 > 192.0.2.20.443: Flags [S], seq 1, win 64240, length 0
10:00:01.000100 IP 203.0.113.77.51000 > 192.0.2.20.443: Flags [S], seq 1, win 64240, length 0
10:00:03.000100 IP 203.0.113.77.51000 > 192.0.2.20.443: Flags [S], seq 1, win 64240, length 0
EOF
: > /tmp/cap_eth1.log
true"""

b = SetBuilder(575, '연결 장애 상황집(2): 방화벽·NAT·경로 — 거부와 시간 초과, 규칙 순서, 응답 없는 DNAT, 경로 없음',
               '"접속이 안 된다"는 신고를 받고 방화벽·NAT·경로 중 어디가 원인인지 좁히는 상황집입니다. 현장에서 모은 출력(curl 결과, iptables 카운터, conntrack, ip route, sysctl, 인터페이스별 캡처)을 읽고 원인을 한 줄씩 짚어 냅니다. 샌드박스에는 방화벽·캡처 도구와 권한이 없어 모아 온 출력을 읽는 방식입니다.',
               'linux', '네트워크', 43, 835, '🚧',
               [{"title": "iptables 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/iptables.8.html"}, {"title": "ip-route 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ip-route.8.html"}], 5)

# 1
b.nt('거부와 시간 초과 가려내기', '서버 192.0.2.20 의 두 포트로 접속해 본 결과가 `/tmp/curl.log` 에 있습니다. 한쪽은 곧바로 거부되고, 다른 쪽은 응답 없이 시간 초과입니다. 아래를 저장하세요. (포트 번호만)\n- `/tmp/refused_port.txt` : 즉시 **거부(refused)** 된 포트\n- `/tmp/timeout_port.txt` : **시간 초과**된 포트 (패킷이 중간에서 버려지는 방화벽·경로 문제를 의심하는 쪽)',
     '오류 번호와 문구가 줄마다 다릅니다. 어느 포트 줄에 어떤 문구가 붙었는지 보세요.',
     "cat /tmp/curl.log\ngrep 'refused' /tmp/curl.log | grep -o 'port [0-9]*' | cut -d' ' -f2 > /tmp/refused_port.txt\ngrep -B1 'timed out' /tmp/curl.log | grep -o ':[0-9][0-9]*/' | tr -d ':/' > /tmp/timeout_port.txt\ncat /tmp/refused_port.txt /tmp/timeout_port.txt\n\n# 8080: 서버는 살아 있는데 그 포트에 듣는 프로세스가 없거나 REJECT. 8443: 응답이 아예 없어 DROP·경로·응답 경로 문제를 의심한다",
     S75, [chk('거부된 포트가 8080 이다', '[ "$(cat /tmp/refused_port.txt)" = 8080 ]'), chk('시간 초과 포트가 8443 이다', '[ "$(cat /tmp/timeout_port.txt)" = 8443 ]')])
# 2
b.nt('8443 을 막는 규칙 찾기', '8443 을 직접 듣는 이 서버에 `203.0.113.0/24` 대역의 클라이언트가 접속하면 시간 초과가 납니다. 서버의 방화벽 카운터 `/tmp/fw.log` 를 봅니다. 규칙은 **위에서부터 검사**되고, 걸린 규칙의 `pkts` 가 늘어납니다. 그 접속을 **실제로 막고 있는 규칙의 번호**를 `/tmp/block_rule.txt` 에 저장하세요. (번호만)',
     '8443 을 다루는 규칙이 둘 이상입니다. 어느 쪽 카운터가 올라가고 있는지, 어느 쪽이 먼저 검사되는지 함께 보세요.',
     "cat /tmp/fw.log\nawk '$1 ~ /^[0-9]+$/ && /DROP/ && /8443/ {print $1}' /tmp/fw.log > /tmp/block_rule.txt\ncat /tmp/block_rule.txt\n\n# 3번 DROP(203.0.113.0/24 의 8443)이 5번 ACCEPT 보다 먼저 걸려 420 패킷이 버려졌고 5번은 한 번도 쓰이지 않았다(0). 허용 규칙을 추가했는데도 안 될 때 위쪽 차단 규칙을 의심한다",
     S75, [chk('3 이다', '[ "$(cat /tmp/block_rule.txt)" = 3 ]')])
# 3
b.nt('응답이 안 오는 DNAT 연결', '외부에서 8443 포트포워딩 접속이 안 된다는 신고가 있어 NAT 장비의 연결 추적 테이블을 봤습니다(`/tmp/conn.log`). 요청은 변환되어 나갔지만 **응답이 한 번도 돌아오지 않은 연결**에는 `[UNREPLIED]` 가 붙습니다. 이런 연결이 **몇 개**인지 숫자만 `/tmp/unreplied.txt` 에 저장하세요.',
     '특정 표시가 들어간 줄의 개수를 세면 됩니다.',
     "grep -c UNREPLIED /tmp/conn.log > /tmp/unreplied.txt\ncat /tmp/unreplied.txt\n\n# 2 개. 내부 서버가 요청을 받았는데 응답이 NAT 장비로 돌아오지 않거나(응답 경로가 다름) 내부 서버 쪽 방화벽이 막은 경우가 많다. 같은 장비의 2222 연결은 정상(ESTABLISHED)이다",
     S75, [chk('2 이다', '[ "$(cat /tmp/unreplied.txt)" = 2 ]')])
# 4
b.nt('경로가 없을 때 고치기', '`/tmp/route_err.log` 는 한 서버에서 `ip route` 와 `ip route get 203.0.113.50` 을 실행한 결과입니다. 직접 연결된 대역 외에는 갈 곳이 없어 오류가 납니다. 게이트웨이 `192.0.2.1` 로 **기본 경로를 추가**하는 `ip route` 명령 한 줄을 `/tmp/fix_route.txt` 에 적으세요. (샌드박스에서는 실제로 적용하지 않습니다)',
     '`ip route get` 오류 문구가 무엇이 없다는 뜻인지 보고, 목적지 지정 없이 나머지 모두에 쓰이는 경로를 떠올려 보세요.',
     "cat /tmp/route_err.log\necho 'ip route add default via 192.0.2.1' > /tmp/fix_route.txt\ncat /tmp/fix_route.txt\n\n# 즉시 적용되지만 재부팅하면 사라지므로 netplan·NetworkManager 설정에도 넣어야 한다. 추가 후 ip route get 으로 선택을 확인한다",
     S75, [chk('기본 경로를 추가하는 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?ip( -4)? r(oute)? (a|add|replace|append|change) (default|0\\.0\\.0\\.0/0|0/0)( |$)" /tmp/fix_route.txt'), chk('게이트웨이가 192.0.2.1 이다', 'grep -Eq "via 192\\.0\\.2\\.1( |$)" /tmp/fix_route.txt')])
# 5
b.nt('전달이 꺼진 라우터', '서버 R 을 두 대역 사이의 라우터로 쓰는데 통신이 안 됩니다. R 의 커널 설정 일부가 `/tmp/sysctl.log` 에 있습니다. 라우터로 동작하지 못하게 하는 **설정 이름(키)** 을 `/tmp/key.txt` 에 저장하세요. (키 전체, 값은 제외)',
     '자기 앞이 아닌 패킷을 다른 곳으로 넘겨 주는 기능과 관련된 키를 찾으세요.',
     "cat /tmp/sysctl.log\ngrep 'ip_forward' /tmp/sysctl.log | awk '{print $1}' > /tmp/key.txt\ncat /tmp/key.txt\n\n# ip_forward=0 이면 라우터·NAT 장비로 쓸 수 없다. 켜려면 sysctl -w 또는 /etc/sysctl.d 에 net.ipv4.ip_forward = 1 을 둔다",
     S75, [chk('net.ipv4.ip_forward 다', '[ "$(cat /tmp/key.txt)" = net.ipv4.ip_forward ]')])
# 6
b.nt('패킷이 사라진 지점', '라우터 R 의 두 인터페이스에서 같은 시간에 캡처한 결과가 있습니다. 클라이언트 쪽 인터페이스 `eth0` 은 `/tmp/cap_eth0.log`, 서버 쪽 인터페이스 `eth1` 은 `/tmp/cap_eth1.log` 입니다. 클라이언트의 요청 패킷이 **보이는 인터페이스**의 이름을 `/tmp/seen_on.txt` 에 저장하세요. (이름만) 여기서 요청이 R 안에서 사라졌다고 판단할 수 있습니다.',
     '두 파일 중 내용이 있는 쪽을 찾으세요. 줄 수를 세 보면 됩니다.',
     "wc -l /tmp/cap_eth0.log /tmp/cap_eth1.log\necho eth0 > /tmp/seen_on.txt\ncat /tmp/seen_on.txt\n\n# eth0 에는 SYN 이 재전송되며 들어오는데 eth1 로는 나가지 않는다. 라우팅 결정(경로 없음)·ip_forward=0·FORWARD 체인 DROP 중 하나를 의심한다. 이렇게 인터페이스별로 캡처하면 사라진 지점을 좁힐 수 있다",
     S75, [chk('eth0 이다', '[ "$(cat /tmp/seen_on.txt)" = eth0 ]')])
# 7
b.choice('외부에서만 시간 초과', '서버 안에서 `curl localhost:8443` 은 되고 `ss -ltn` 에도 `0.0.0.0:8443` 이 LISTEN 으로 보입니다. 그런데 다른 대역의 클라이언트에서는 IP 주소로 접속해도 시간 초과가 납니다. 다음에 확인할 것으로 가장 알맞은 것은?', '서버 안에서의 결과와 바깥에서의 결과가 다른 이유를 생각해 보세요.',
         ['서버·중간 장비의 방화벽 규칙과 경로를 확인한다', '서버에서 해당 서비스를 다시 설치해 본다', '서버의 디스크와 메모리 여유를 확인한다', '클라이언트의 DNS 서버 설정을 확인한다'], 0,
         '서버 안에서는 되고 포트도 LISTEN 이면 애플리케이션은 정상입니다. 외부에서만 시간 초과가 나는 것은 패킷이 서버에 닿지 못하거나 응답이 돌아오지 못하는 것이므로 INPUT 규칙·카운터, 중간 방화벽, 경로를 차례로 확인합니다. IP 주소로 접속해도 시간 초과이므로 이름 해석과는 무관합니다.')
# 8
b.choice('UNREPLIED 가 쌓일 때의 의미', 'NAT 장비의 conntrack 에 `[UNREPLIED]` 상태의 연결이 계속 쌓입니다. 이 표시가 뜻하는 것으로 가장 알맞은 것은?', '요청과 응답 중 어느 쪽이 확인되지 않았는지 생각해 보세요.',
         ['요청은 전달됐지만 되돌아오는 응답을 아직 보지 못했다', '요청 패킷이 NAT 장비에 도착하지 못했다', '연결이 정상적으로 맺어져 데이터를 주고받고 있다', '연결이 정상적으로 종료되어 정리되고 있다'], 0,
         '`[UNREPLIED]` 는 한 방향(요청)만 본 상태입니다. 목적지가 응답하지 않거나, 응답이 NAT 장비를 거치지 않고 다른 길로 가거나, 중간에서 막힌 경우에 쌓입니다. 정상 연결은 `[ASSURED]` 가 붙고 양방향이 확인됩니다.')
# 9
b.fill('연결 시간 제한 옵션', '접속이 거부되는지 시간 초과인지 가리려면 **연결을 맺는 단계에서 최대 5초만** 기다리게 해야 합니다. 빈칸에 들어갈 curl 옵션을 채우세요.', 'TCP 를 맺는 단계의 제한 시간을 정하는 옵션을 찾아 보세요.',
       'curl -sS --{0} 5 http://192.0.2.20:8443/', ['connect-timeout', 'max-filesize', 'proxy-header', 'connect-to'], [0],
       '`--connect-timeout` 은 TCP 연결을 맺는 단계에 쓰는 최대 시간입니다. `--max-filesize` 는 받을 파일의 최대 크기, `--proxy-header` 는 프록시로 보낼 헤더, `--connect-to` 는 연결할 대상 주소를 바꾸는 옵션입니다. 짧게 제한해 두면 시간 초과를 빨리 확인할 수 있습니다.')
# 10
b.order('접속 불가 점검 순서', '클라이언트에서 서버 포트로 접속이 안 됩니다. 접속하는 쪽에서 확인하는 것에서 시작해 서버 안쪽 확인으로 좁혀 가려 합니다. 올바른 순서로 놓으세요. (`ping` 은 ICMP 가 허용된 환경을 전제하고, 서버 안쪽에서는 서비스가 듣고 있는지를 방화벽보다 먼저 봅니다. 듣고 있지 않으면 방화벽을 볼 이유가 없기 때문입니다.)', '서버에 로그인하지 않고 볼 수 있는 것부터 시작합니다.',
        ['서버에서 `ss -ltn` 으로 그 포트가 LISTEN 인지 확인한다', '클라이언트에서 `ping` 으로 서버까지 도달하는지 확인한다', '서버의 방화벽 규칙과 카운터를 확인한다', '클라이언트에서 `curl` 로 거부인지 시간 초과인지 확인한다'], [1, 3, 0, 2],
        'ICMP 로 서버까지 도달하는지 보고, curl 로 거부인지 시간 초과인지 구분합니다. 서버 안쪽에서는 포트가 LISTEN 인지 먼저 확인하고(듣고 있지 않으면 거부의 원인), 그다음에 방화벽 규칙을 봅니다.')

if __name__ == '__main__':
    preview(b)
