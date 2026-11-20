import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 568: ping·traceroute·mtr 읽기. 명세: docs/specs/spec_gap_set568.md
# 샌드박스 linux(비특권). 외부 네트워크 상태가 환경마다 달라(문서용 주소 192.0.2.x 에도 응답하는 환경이 있다) 127.0.0.1 로 실행하는 문제와, 고정 샘플 출력 파일을 읽는 문제로 구성한다. mtr 는 이미지에 없어 샘플로만 다룬다.

S68 = """rm -f /tmp/*.txt
cat > /tmp/ping_sample.log <<'EOF'
PING example.com (192.0.2.10) 56(84) bytes of data.
64 bytes from 192.0.2.10: icmp_seq=1 ttl=57 time=12.4 ms
64 bytes from 192.0.2.10: icmp_seq=2 ttl=57 time=11.9 ms
64 bytes from 192.0.2.10: icmp_seq=4 ttl=57 time=13.1 ms
64 bytes from 192.0.2.10: icmp_seq=5 ttl=57 time=12.0 ms

--- example.com ping statistics ---
5 packets transmitted, 4 received, 20% packet loss, time 4006ms
rtt min/avg/max/mdev = 11.901/12.350/13.100/0.480 ms
EOF
cat > /tmp/trace_sample.log <<'EOF'
traceroute to 192.0.2.10 (192.0.2.10), 30 hops max, 60 byte packets
 1  192.168.0.1  0.5 ms  0.4 ms  0.4 ms
 2  198.51.100.1  1.8 ms  1.7 ms  1.9 ms
 3  203.0.113.5  2.4 ms  2.3 ms  2.5 ms
 4  * * *
 5  203.0.113.50  88.2 ms  87.9 ms  88.4 ms
 6  192.0.2.10  88.9 ms  88.7 ms  89.0 ms
EOF
cat > /tmp/mtr_sample.log <<'EOF'
HOST: web01                  Loss%   Snt   Last   Avg  Best  Wrst StDev
  1.|-- 192.168.0.1            0.0%    10    0.5   0.5   0.4   0.7   0.1
  2.|-- 198.51.100.1           0.0%    10    1.8   1.9   1.7   2.2   0.2
  3.|-- 203.0.113.5           50.0%    10    2.4   2.5   2.3   2.9   0.2
  4.|-- 203.0.113.9            0.0%    10    3.0   3.1   2.9   3.5   0.2
  5.|-- 203.0.113.50          30.0%    10   88.2  88.0  87.1  90.0   1.0
  6.|-- 192.0.2.10            30.0%    10   88.9  88.7  88.1  89.5   0.4
EOF
true"""

b = SetBuilder(568, 'ping·traceroute·mtr 읽기: TTL·손실·RTT, 홉, 진짜 손실 구간 찾기',
               '연결이 안 될 때 가장 먼저 치는 ping 과 경로를 보여 주는 traceroute·mtr 의 출력을 읽는 연습입니다. 응답의 TTL 값, 보낸 크기와 응답 크기의 관계, traceroute 한 줄(홉) 읽기, ping 요약에서 손실률과 평균 지연 뽑기, traceroute 의 * * * 와 지연이 튀는 구간 찾기, mtr 에서 일부 홉의 손실이 ICMP 응답 제한인지 진짜 손실인지 가려내기를 해 봅니다.',
               'linux', '네트워크', 47, 828, '📡',
               [{"title": "ping 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ping.8.html"}, {"title": "traceroute 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/traceroute.8.html"}], 5)

# 1
b.nt('ping 응답의 TTL 읽기', '`ping` 은 상대에게 작은 확인 메시지(ICMP echo)를 보내 응답이 오는지, 얼마나 걸리는지 봅니다. 응답 줄의 `ttl=` 은 패킷이 거칠 수 있는 남은 홉(라우터) 수입니다. 자기 자신(`127.0.0.1`)에게 **한 번만** 보내(`-c 1`) 응답의 **`ttl=` 값(숫자만)** 을 `/tmp/ttl.txt` 에 저장하세요.',
     '`ping -c 1 127.0.0.1` 의 응답 줄에서 `ttl=숫자` 를 `grep -o` 로 뽑고, 숫자만 남기도록 `cut -d= -f2` 를 쓰세요.',
     "ping -c 1 127.0.0.1\nping -c 1 127.0.0.1 | grep -o 'ttl=[0-9]*' | cut -d= -f2 > /tmp/ttl.txt\ncat /tmp/ttl.txt\n\n# 리눅스가 처음 정하는 TTL 은 보통 64. 라우터를 하나 지날 때마다 1 씩 줄어 0 이 되면 버려진다. 응답 TTL 로 상대까지의 홉 수를 대략 짐작한다",
     S68, [chk('TTL 이 64 다', '[ "$(cat /tmp/ttl.txt)" = 64 ]')])
# 2
b.nt('보낸 크기와 응답 크기', '`ping -s 바이트` 는 **데이터 부분의 크기**를 정합니다. 실제 응답 줄에는 거기에 ICMP 헤더 8바이트가 더해진 크기(`NNN bytes from ...`)가 나옵니다. `127.0.0.1` 에 데이터 크기 `1000` 으로 한 번 보내고(`-c 1 -s 1000`), 응답 줄에 나온 **바이트 수**를 `/tmp/bytes.txt` 에 저장하세요. (숫자만)',
     '응답 줄은 `NNN bytes from 127.0.0.1: ...` 로 시작합니다. `grep` 으로 그 줄을 고르고 첫 칸을 `cut -d" " -f1` 로 뽑으세요. 숫자가 1000 과 다른 이유를 확인해 보세요.',
     "ping -c 1 -s 1000 127.0.0.1\nping -c 1 -s 1000 127.0.0.1 | grep 'bytes from' | cut -d' ' -f1 > /tmp/bytes.txt\ncat /tmp/bytes.txt\n\n# 1008 = 데이터 1000 + ICMP 헤더 8. IP 헤더 20 까지 더하면 실제 패킷은 1028 바이트다. MTU 점검에서 이 계산이 쓰인다",
     S68, [chk('1008 이 저장됐다', '[ "$(cat /tmp/bytes.txt)" = 1008 ]')])
# 3
b.nt('traceroute 한 줄 읽기', '`traceroute` 는 목적지까지 **거치는 라우터(홉)를 한 줄에 하나씩** 보여 줍니다. 각 줄은 `번호  주소  시간1  시간2  시간3` 입니다. 자기 자신 `127.0.0.1` 로 `traceroute -n 127.0.0.1` 을 실행해(`-n` 은 이름 해석 없이 숫자로) **홉 줄(번호로 시작하는 줄)** 을 `/tmp/hop.txt` 에 저장하세요.',
     '첫 줄(`traceroute to ...`)은 설명이고, 번호로 시작하는 줄이 홉입니다. `grep` 으로 공백 뒤에 숫자로 시작하는 줄만 고르거나 `tail -n +2` 로 첫 줄을 빼세요.',
     "traceroute -n 127.0.0.1\ntraceroute -n 127.0.0.1 | tail -n +2 > /tmp/hop.txt\ncat /tmp/hop.txt\n\n# 자기 자신은 한 홉이다. 외부로 나가면 줄이 여러 개 생기며 각 줄이 라우터 하나(TTL 을 1,2,3... 로 늘려 가며 알아낸 것)다",
     S68, [chk('홉 줄이 하나 저장됐다', '[ "$(wc -l < /tmp/hop.txt)" -eq 1 ]'), chk('127.0.0.1 홉이다', 'grep -q "127.0.0.1" /tmp/hop.txt')])
# 4
b.nt('ping 요약에서 손실률과 평균 지연 뽑기', '`/tmp/ping_sample.log` 는 어떤 서버에 5번 ping 한 결과를 저장한 것입니다. 맨 아래 요약에서 아래 두 값을 저장하세요. (값만)\n- `/tmp/loss.txt` : **패킷 손실률** (`20%` 처럼 퍼센트 기호 포함)\n- `/tmp/avg.txt` : **평균 지연(avg, ms)** 숫자',
     '손실률은 `packet loss` 가 들어간 줄에서 `%` 가 붙은 단어를 뽑습니다. 평균은 `rtt min/avg/max/mdev` 줄에서 `/` 로 나눈 두 번째 값입니다. `grep -o` 와 `cut -d/` 를 쓰세요.',
     "grep -o '[0-9.]*% packet loss' /tmp/ping_sample.log | cut -d' ' -f1 > /tmp/loss.txt\ngrep '^rtt' /tmp/ping_sample.log | cut -d= -f2 | cut -d/ -f2 > /tmp/avg.txt\ncat /tmp/loss.txt /tmp/avg.txt\n\n# 20% 손실은 5개 중 1개 유실(icmp_seq=3 이 없다). 손실이 조금이라도 있으면 회선·장비 상태를 의심한다. 평균 12.350 ms",
     S68, [chk('손실률이 20% 다', '[ "$(cat /tmp/loss.txt)" = "20%" ]'), chk('평균이 12.35 다', 'awk \'NR==1{v=$1+0} END{exit !(NR==1 && v==12.35)}\' /tmp/avg.txt')])
# 5
b.nt('traceroute 에서 * * * 와 지연이 튀는 홉', '`/tmp/trace_sample.log` 는 어떤 서버까지의 traceroute 결과입니다. 줄의 `* * *` 는 그 홉이 응답하지 않았다는 뜻입니다(꼭 장애는 아닙니다). 아래 두 가지를 번호로 저장하세요. (번호만)\n- `/tmp/star_hop.txt` : `* * *` 로 나온 **홉 번호**\n- `/tmp/jump_hop.txt` : 앞 홉보다 응답 시간이 **크게 뛰기 시작한 홉 번호** (10 ms 이상 급증)',
     '첫 번째는 `grep` 으로 `* * *` 가 있는 줄의 첫 칸을 보면 됩니다. 두 번째는 줄마다 첫 번째 시간 값을 눈으로 비교해 처음 크게 늘어난 줄을 찾으세요.',
     "cat /tmp/trace_sample.log\ngrep '\\* \\* \\*' /tmp/trace_sample.log | awk '{print $1}' > /tmp/star_hop.txt\necho 5 > /tmp/jump_hop.txt\ncat /tmp/star_hop.txt /tmp/jump_hop.txt\n\n# 4번 홉은 응답을 안 줬지만 뒤 홉(5, 6)이 정상 응답하니 그 장비가 ICMP 응답만 막은 것이다. 지연은 4→5 구간에서 2 ms 대에서 88 ms 대로 뛴다(먼 거리 회선·구간 혼잡 의심)",
     S68, [chk('* * * 홉이 4 다', '[ "$(cat /tmp/star_hop.txt)" = 4 ]'), chk('지연이 뛴 홉이 5 다', '[ "$(cat /tmp/jump_hop.txt)" = 5 ]')])
# 6
b.nt('mtr: 진짜 손실이 시작되는 홉', '`/tmp/mtr_sample.log` 는 `mtr`(ping 과 traceroute 를 합친 도구)의 결과입니다. `Loss%` 는 각 홉에서의 손실률입니다. **3번 홉에 50% 손실**이 보이지만 그 뒤 4번 홉은 0% 입니다. 이럴 때 3번 장비는 자기에게 오는 ICMP 에 일부만 응답하도록 제한한 것(**응답 제한**)이지 실제 손실이 아닙니다. 진짜 손실은 **그 홉부터 목적지까지 계속 이어지는 손실**입니다.\n\n진짜 손실이 **시작되는 홉 번호**를 `/tmp/real_loss.txt` 에 저장하세요. (번호만)',
     '아래 홉들로 손실이 이어지는지를 보세요. 어떤 홉에서 손실이 있어도 그 뒤 홉이 0% 로 돌아오면 그 홉은 제외입니다. 마지막 홉(목적지)의 손실이 기준입니다.',
     "cat /tmp/mtr_sample.log\necho 5 > /tmp/real_loss.txt\ncat /tmp/real_loss.txt\n\n# 5번 홉부터 5, 6번이 계속 30% 손실이고 목적지(6)도 30% 이므로 5번 홉 구간에서 실제 유실이 시작된다. 3번(50%)은 뒤가 0% 라서 응답 제한",
     S68, [chk('홉 번호가 5 다', '[ "$(cat /tmp/real_loss.txt)" = 5 ]')])
# 7
b.choice('ping 응답의 TTL 로 알 수 있는 것', '리눅스 서버는 보통 TTL 64 로 패킷을 보냅니다. 외부 서버에 ping 했더니 응답이 `ttl=57` 입니다. 이 값으로 짐작할 수 있는 것은?', 'TTL 은 출발할 때 정해진 값에서 줄어듭니다.',
         ['응답이 약 7개 홉을 지나 왔다', '서버가 57번 응답한 횟수다', '57 ms 가 걸렸다는 뜻이다', '57 바이트를 보냈다는 뜻이다'], 0,
         'TTL 은 라우터를 지날 때마다 1 줄어듭니다. 상대가 64 로 시작했다고 보면 57 은 7 개 홉을 지난 것입니다(상대가 다른 초기값을 쓰면 달라질 수 있어 대략적인 짐작입니다). 지연은 time= 값이고, 크기는 bytes 입니다.')
# 8
b.choice('traceroute 의 * * * 의 의미', 'traceroute 결과 중간 홉이 `* * *` 로 나오는데 그 뒤 홉들은 정상 응답합니다. 가장 알맞은 해석은?', '뒤 홉이 응답한다는 것이 무엇을 뜻하는지 생각해 보세요.',
         ['그 장비가 응답만 막았고 패킷은 통과 중이다', '그 구간에서 모든 패킷이 유실되고 있는 것이다', '목적지 서버가 꺼져 있다는 뜻이다', '내 PC 의 네트워크 카드가 고장 났다는 뜻이다'], 0,
         '중간 장비는 TTL 이 0 이 되면 보내는 time-exceeded 응답을 방화벽·설정으로 막는 경우가 많습니다. 뒤 홉이 응답한다면 트래픽은 통과 중이라 문제가 아닙니다. 마지막 홉까지 * * * 가 이어질 때가 진짜 의심 대상입니다.')
# 9
b.fill('단편화를 금지하는 ping 옵션', 'MTU 문제를 확인하려고 **단편화를 금지(DF 비트를 켬, "조각내지 말라"는 표시)** 하고 큰 패킷을 보냅니다. 빈칸에 들어갈 옵션 값을 채우세요.', '단편화를 금지하는 값은 `ping -M` 의 모드 중 하나입니다. `man ping` 의 `-M` 항목을 찾아 보세요.',
       'ping -M {0} -s 1472 대상', ['do', 'dont', 'want', 'off'], [0],
       '`-M do` 는 단편화를 금지하고 DF 비트를 켭니다. 경로 중간에 더 작은 MTU 가 있으면 "Frag needed" 또는 "Message too long" 이 나와 MTU 문제를 확인할 수 있습니다. `dont` 는 DF 를 끄고, `want` 는 경로 MTU 에 따라 단편화를 허용합니다. `off` 는 옵션 값이 아닙니다.')
# 10
b.order('연결이 안 될 때 ping 점검 순서', '서버에서 외부 서비스에 접속이 안 됩니다. **내 쪽에서 먼 쪽으로** 한 단계씩 ping 으로 어디까지 되는지 확인하려 합니다. 경로(IP)가 되는지 확인한 뒤에야 이름 해석을 의심할 수 있습니다. 올바른 순서로 놓으세요.', '한 번에 새로 확인하는 것이 하나뿐이 되도록 놓으세요.',
        ['외부 서버 이름으로 ping (이름 해석까지 확인)', '게이트웨이(같은 서브넷의 라우터)에 ping', '자기 자신 127.0.0.1 에 ping (내 네트워크 스택 확인)', '외부 서버 IP 주소로 ping (경로 확인)'], [2, 1, 3, 0],
        '자기 자신 → 게이트웨이 → 외부 IP → 이름 순서로 확인하면 어느 단계에서 막히는지 가릴 수 있습니다. 외부 IP 는 되는데 이름만 안 되면 DNS 문제, 게이트웨이는 되는데 외부 IP 가 안 되면 경로·NAT·방화벽 문제입니다.')

if __name__ == '__main__':
    preview(b)
