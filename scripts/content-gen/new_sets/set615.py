import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 615: iperf3 로 성능 재기. 명세: docs/specs/spec_gap_set615.md
# 샌드박스 linux(iperf3 없음). 명령은 파일에 적고 결과는 샘플 출력으로 읽는다.

S115 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/tcp.log <<'EOF'
Connecting to host 192.0.2.10, port 5201
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  1.10 GBytes   945 Mbits/sec   12             sender
[  5]   0.00-10.00  sec  1.10 GBytes   941 Mbits/sec                  receiver
EOF
cat > /tmp/udp.log <<'EOF'
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-10.00  sec  11.9 MBytes  10.0 Mbits/sec  0.000 ms  0/8600 (0%)  sender
[  5]   0.00-10.00  sec  11.9 MBytes  9.95 Mbits/sec  0.045 ms  39/8600 (0.45%)  receiver
EOF
true"""

b = SetBuilder(615, 'iperf3 로 성능 재기: 서버·클라이언트, 병렬 연결, 방향, UDP 손실',
               '네트워크가 "느리다"는 말을 숫자로 바꾸려면 iperf3 로 처리량을 잽니다. 한쪽에서 서버를 띄우고 다른 쪽에서 클라이언트로 접속하며, 병렬 연결 수, 측정 시간, 방향 전환, UDP 목표 속도 같은 옵션을 조합합니다. TCP 결과에서 수신 측 속도를 읽고 UDP 결과에서 손실률을 읽는 법, 한 연결만 느린 이유를 연습합니다. 샌드박스에는 iperf3 가 없어 명령은 파일에 적고 결과는 샘플로 읽습니다.',
               'linux', '네트워크', 68, 875, '📶',
               [{"title": "iperf3 사용법", "url": "https://iperf.fr/iperf-doc.php"}, {"title": "iperf3 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/iperf3.1.html"}], 15)

b.nt('수신 측 속도 읽기', '`/tmp/tcp.log` 는 `iperf3 -c` 의 TCP 결과입니다. `sender` 줄은 보낸 쪽, `receiver` 줄은 받은 쪽이 잰 값입니다. 실제로 상대에게 도달한 속도인 **receiver 의 Mbits/sec 숫자**만 `/tmp/rx.txt` 에 저장하세요.',
     '`receiver` 라는 단어가 들어 있는 줄을 고르고, 속도 칸을 찾으세요.',
     "cat /tmp/tcp.log\ngrep receiver /tmp/tcp.log | grep -o '[0-9.]* Mbits/sec' | awk '{print $1}' > /tmp/rx.txt\ncat /tmp/rx.txt\n\n# sender 945 와 receiver 941 의 차이는 재전송(Retr 12)과 버퍼링 때문이다. 판단 기준은 받은 쪽 값이다",
     S115, [chk('941 이다', 'awk "NR==1{v=\\$1+0} END{exit !(NR==1 && v==941)}" /tmp/rx.txt')])
b.nt('UDP 손실률 읽기', '`/tmp/udp.log` 는 UDP 시험 결과입니다. `Lost/Total Datagrams` 칸 끝의 괄호에 손실률이 있습니다. **receiver 줄의 손실률 숫자**(퍼센트 기호 없이)를 `/tmp/loss.txt` 에 저장하세요.',
     '`receiver` 줄에서 손실률이 적힌 칸을 찾으세요.',
     "grep receiver /tmp/udp.log | grep -o '([0-9.]*%)' | tr -d '()%' > /tmp/loss.txt\ncat /tmp/loss.txt\n\n# TCP 는 손실을 재전송으로 감추지만 UDP 는 그대로 보여 준다. 손실률과 jitter 가 같이 높으면 경로의 혼잡이나 버퍼 부족을 의심한다",
     S115, [chk('0.45 이다', 'awk "NR==1{v=\\$1+0} END{exit !(NR==1 && v==0.45)}" /tmp/loss.txt')])
b.nt('클라이언트 명령 적기', '서버 `192.0.2.10`(기본 포트)을 **20초 동안, 4개의 병렬 연결로** 재는 `iperf3` 클라이언트 명령 한 줄을 `/tmp/client.txt` 에 적으세요. (실행하지 않습니다)',
     '접속할 서버 지정, 시간, 병렬 연결 수는 각각 다른 옵션입니다. 매뉴얼의 옵션 표를 보세요.',
     "echo 'iperf3 -c 192.0.2.10 -t 20 -P 4' > /tmp/client.txt\ncat /tmp/client.txt\n\n# 상대 서버에서는 iperf3 -s 로 먼저 서버를 띄워 둔다. -P 로 여러 연결을 쓰면 연결 하나의 한계(창 크기, 지연)를 넘어 회선 전체 처리량에 가깝게 잴 수 있다",
     S115, [chk('서버를 지정한다', 'grep -Eq "^[[:space:]]*(sudo[[:space:]]+)?iperf3[[:space:]]+(.*[[:space:]])?(-c|--client)[ =]?192\\.0\\.2\\.10([[:space:]]|$)" /tmp/client.txt'), chk('20초다', 'grep -Eq -- "(-t|--time)[ =]?20([[:space:]]|$)" /tmp/client.txt'), chk('병렬 4 다', 'grep -Eq -- "(-P|--parallel)[ =]?4([[:space:]]|$)" /tmp/client.txt')])
b.nt('UDP 시험 명령', '같은 서버 `192.0.2.10` 에 **UDP 로, 목표 속도 100Mbit/s** 로 재는 `iperf3` 클라이언트 명령 한 줄을 `/tmp/udp_cmd.txt` 에 적으세요.',
     'UDP 로 바꾸는 옵션과 목표 대역폭 옵션이 각각 있습니다. UDP 는 속도를 지정하지 않으면 매우 낮게 잡힙니다.',
     "echo 'iperf3 -c 192.0.2.10 -u -b 100M' > /tmp/udp_cmd.txt\ncat /tmp/udp_cmd.txt\n\n# UDP 는 보내는 속도를 정해 주고, 받는 쪽에서 얼마나 잃는지를 본다. 목표를 회선 속도보다 크게 잡으면 손실이 나는 것이 당연하다",
     S115, [chk('UDP 모드다', 'grep -Eq -- "(^|[[:space:]])(-u|--udp)([[:space:]]|$)" /tmp/udp_cmd.txt'), chk('100M 이다', 'grep -Eq -- "(-b|--bitrate)[ =]?100(M|m)([[:space:]]|$)" /tmp/udp_cmd.txt'), chk('서버를 지정한다', 'grep -Eq -- "(-c|--client)[ =]?192\\.0\\.2\\.10([[:space:]]|$)" /tmp/udp_cmd.txt'), chk('주석이 아닌 iperf3 명령이다', 'grep -Eq "^[[:space:]]*(sudo[[:space:]]+)?iperf3[[:space:]]" /tmp/udp_cmd.txt')])
b.nt('반대 방향 시험', '기본은 클라이언트에서 서버로 보내는 방향입니다. **서버에서 클라이언트로 보내는(내려받는) 방향**을 재는 `iperf3` 명령 한 줄을 `/tmp/reverse.txt` 에 적으세요. (서버는 `192.0.2.10`)',
     '방향을 바꾸는 옵션이 있습니다. 서버 쪽 명령은 바꿀 필요가 없습니다.',
     "echo 'iperf3 -c 192.0.2.10 -R' > /tmp/reverse.txt\ncat /tmp/reverse.txt\n\n# 업로드와 다운로드가 비대칭으로 나오면 한쪽 방향의 경로(방화벽, 대역 제한)를 의심한다. --bidir 로 양방향을 동시에 재기도 한다",
     S115, [chk('역방향 옵션이 있다', 'grep -Eq -- "(^|[[:space:]])(-R|--reverse)([[:space:]]|$)" /tmp/reverse.txt'), chk('서버를 지정한다', 'grep -Eq -- "(-c|--client)[ =]?192\\.0\\.2\\.10([[:space:]]|$)" /tmp/reverse.txt'), chk('주석이 아닌 iperf3 명령이다', 'grep -Eq "^[[:space:]]*(sudo[[:space:]]+)?iperf3[[:space:]]" /tmp/reverse.txt')])
b.choice('연결 하나만 느릴 때', '1Gbit/s 회선에서 `iperf3 -c` 한 연결은 300Mbit/s 가 나오는데 `-P 4` 로 하면 합계가 930Mbit/s 가 나옵니다. 가장 알맞은 해석은?', '한 연결과 여러 연결의 합계가 다른 이유를 연결 단위의 한계에서 찾아 보세요.',
         ['회선은 충분하지만 연결 하나는 창 크기·지연 때문에 한계에 걸린다', '회선이 고장 나서 속도가 일정하지 않다', 'iperf3 가 연결 수에 따라 임의로 속도를 늘려 보여 준다', '병렬 연결은 항상 속도를 4배로 만든다'], 0,
         'TCP 연결 하나의 속도는 대략 창 크기 ÷ 왕복 지연으로 제한됩니다. 병렬 연결로 합계가 회선 속도에 가까워지면 회선이 아니라 단일 연결 한계(창, 지연, 버퍼)가 원인입니다.')
b.choice('이상적인 TCP 결과', '1Gbit/s 이더넷에서 TCP 시험 결과가 receiver 기준 941Mbit/s 입니다. 이 결과를 가장 바르게 해석한 것은?', '헤더 같은 프로토콜 오버헤드가 있어 숫자가 정확히 1000 이 되지는 않습니다.',
         ['회선 속도에 거의 도달한 정상 결과다', '회선의 6% 가 손실되는 심각한 장애다', '링크가 100Mbit/s 로 협상된 상태다', '측정이 실패했다는 뜻이다'], 0,
         'TCP/IP·이더넷 헤더 오버헤드 때문에 1Gbit/s 링크의 TCP 처리량은 이론상 약 940Mbit/s 이므로 941 은 사실상 회선 한계입니다. 손실이나 협상 속도 문제라면 훨씬 낮게 나옵니다.')
b.choice('UDP 손실이 나올 때', 'UDP 로 100Mbit/s 링크에 1000Mbit/s 를 목표로 보냈더니 receiver 에서 큰 손실이 나옵니다. 가장 알맞은 판단은?', '목표 속도를 정한 것은 시험하는 사람입니다.',
         ['목표가 용량보다 커서 난 손실이니 목표를 낮춰 한계점을 찾는다', '무조건 중간 네트워크 장비가 고장 난 것이라고 판단한다', 'UDP 는 원래 항상 이 정도 손실이 나므로 정상이라고 본다', 'iperf3 의 버그이므로 이 결과는 모두 버리고 무시한다'], 0,
         'UDP 는 흐름 제어가 없어 용량을 넘기면 그대로 손실이 납니다. 목표 속도를 단계적으로 올리며 손실률이 오르기 시작하는 지점을 찾는 것이 올바른 해석입니다.')
b.fill('병렬 연결 옵션', '병렬 연결 수를 정하는 `iperf3` 옵션 글자를 채우세요. (대소문자 구분)', '옵션 이름은 매뉴얼의 옵션 표에서 찾아 보세요.',
       'iperf3 -c 192.0.2.10 -{0} 4', ['P', 'p', 't', 'b'], [0],
       '`-P` 는 병렬 스트림 수입니다. `-p` 는 포트, `-t` 는 시간, `-b` 는 목표 대역폭입니다.')
b.order('측정 절차', '두 서버 사이의 처리량을 재는 올바른 순서로 놓으세요.', '받는 쪽이 준비돼 있어야 보낼 수 있습니다.',
        ['조건을 하나만 바꿔 같은 시험을 다시 한다', '받는 쪽 서버에서 iperf3 를 서버 모드로 띄운다', '결과에서 받는 쪽 속도를 읽는다', '보내는 쪽에서 클라이언트로 접속해 시험한다'], [1, 3, 2, 0],
        '서버를 먼저 띄우고, 클라이언트로 시험하고, 받는 쪽 값을 읽은 뒤, 한 번에 조건 하나만 바꿔 비교합니다.')

if __name__ == '__main__':
    preview(b)
