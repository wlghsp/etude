import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 574: tcpdump 출력 읽기. 명세: docs/specs/spec_gap_set574.md
# 샌드박스 linux(비특권, tcpdump 없음). 캡처를 실제로 할 수 없어 tcpdump -nn 출력 샘플을 읽는 문제와, 캡처 명령을 파일에 적는 문제로 구성한다.

S74 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/cap_http.log <<'EOF'
10:00:00.000100 IP 192.0.2.50.51000 > 203.0.113.10.80: Flags [S], seq 100, win 64240, length 0
10:00:00.012000 IP 203.0.113.10.80 > 192.0.2.50.51000: Flags [S.], seq 500, ack 101, win 65160, length 0
10:00:00.012100 IP 192.0.2.50.51000 > 203.0.113.10.80: Flags [.], ack 1, win 502, length 0
10:00:00.012500 IP 192.0.2.50.51000 > 203.0.113.10.80: Flags [P.], seq 1:80, ack 1, win 502, length 79: HTTP: GET / HTTP/1.1
10:00:00.030000 IP 203.0.113.10.80 > 192.0.2.50.51000: Flags [P.], seq 1:200, ack 80, win 509, length 199: HTTP: HTTP/1.1 200 OK
10:00:00.030100 IP 192.0.2.50.51000 > 203.0.113.10.80: Flags [F.], seq 80, ack 200, win 502, length 0
EOF
cat > /tmp/cap_syn.log <<'EOF'
10:00:01.000000 IP 192.0.2.50.52000 > 203.0.113.20.8080: Flags [S], seq 1, win 64240, length 0
10:00:02.000000 IP 192.0.2.50.52000 > 203.0.113.20.8080: Flags [S], seq 1, win 64240, length 0
10:00:04.000000 IP 192.0.2.50.52000 > 203.0.113.20.8080: Flags [S], seq 1, win 64240, length 0
10:00:08.000000 IP 192.0.2.50.52000 > 203.0.113.20.8080: Flags [S], seq 1, win 64240, length 0
EOF
cat > /tmp/cap_rst.log <<'EOF'
10:00:03.000000 IP 192.0.2.50.52100 > 203.0.113.30.9090: Flags [S], seq 1, win 64240, length 0
10:00:03.000800 IP 203.0.113.30.9090 > 192.0.2.50.52100: Flags [R.], seq 0, ack 2, win 0, length 0
EOF
cat > /tmp/cap_dns.log <<'EOF'
10:00:05.000000 IP 192.0.2.50.41000 > 192.0.2.53.53: 12345+ A? www.example.com. (33)
10:00:05.001500 IP 192.0.2.53.53 > 192.0.2.50.41000: 12345 2/0/0 A 192.0.2.10, A 192.0.2.11 (65)
10:00:05.002000 IP 192.0.2.50.41001 > 192.0.2.53.53: 12346+ A? missing.example.com. (37)
10:00:05.004000 IP 192.0.2.53.53 > 192.0.2.50.41001: 12346 NXDomain 0/1/0 (112)
EOF
true"""

b = SetBuilder(574, 'tcpdump 출력 읽기: 핸드셰이크·플래그·SYN 재전송·RST·DNS',
               'tcpdump 가 보여 주는 패킷 한 줄을 읽는 연습입니다. 누가 누구에게 어느 포트로 보냈는지, Flags 의 S·S.·P.·F.·R. 가 무엇인지, 응답이 오지 않고 SYN 만 재전송되는 모습과 RST 로 거부되는 모습, DNS 질의와 응답의 짝을 샘플에서 읽고, 캡처 명령을 직접 적어 봅니다. 샌드박스에는 캡처 도구와 권한이 없어 샘플 출력을 읽는 방식입니다.',
               'linux', '네트워크', 68, 834, '🔬',
               [{"title": "tcpdump 매뉴얼", "url": "https://www.tcpdump.org/manpages/tcpdump.1.html"}, {"title": "pcap-filter 매뉴얼", "url": "https://www.tcpdump.org/manpages/pcap-filter.7.html"}], 5)

# 1
b.nt('접속을 시작한 쪽', '`/tmp/cap_http.log` 는 `tcpdump -nn` 으로 캡처한 한 번의 HTTP 접속입니다. 한 줄은 `시각 IP 출발지.포트 > 목적지.포트: Flags [...]` 모양입니다. 첫 패킷(`Flags [S]`, 연결 요청)을 보낸 **출발지 주소와 포트**(`주소.포트` 그대로)를 `/tmp/client.txt` 에 저장하세요. (값만)',
     '첫 줄의 `IP` 다음 칸입니다. 마지막 점 뒤가 포트입니다.',
     "cat /tmp/cap_http.log\nhead -1 /tmp/cap_http.log | awk '{print $3}' > /tmp/client.txt\ncat /tmp/client.txt\n\n# 요청을 처음 보낸 쪽이 클라이언트다. 클라이언트 포트(51000)는 임시 포트이고 서버 포트(80)는 서비스 포트다",
     S74, [chk('192.0.2.50.51000 이다', '[ "$(cat /tmp/client.txt)" = 192.0.2.50.51000 ]')])
# 2
b.nt('HTTP 응답의 크기', '`/tmp/cap_http.log` 에서 서버가 돌려준 HTTP 응답 패킷의 **페이로드 길이**(`length` 다음 숫자)를 `/tmp/resp_len.txt` 에 저장하세요. (숫자만) 응답 패킷은 서버(203.0.113.10)가 보낸 데이터 패킷(`P.`)입니다.',
     '서버에서 클라이언트로 가는 줄 중 길이가 0 이 아닌 줄을 찾으세요.',
     "grep '^[0-9:.]* IP 203.0.113.10.80 >' /tmp/cap_http.log | grep 'length [1-9]' | grep -o 'length [0-9]*' | awk '{print $2}' > /tmp/resp_len.txt\ncat /tmp/resp_len.txt\n\n# 길이 0 패킷은 ACK 같은 제어 패킷이다. 실제 데이터가 오가는 것은 P(push) 패킷이다",
     S74, [chk('199 다', '[ "$(cat /tmp/resp_len.txt)" = 199 ]')])
# 3
b.nt('SYN 재전송 횟수', '`/tmp/cap_syn.log` 는 8080 포트로 접속을 시도한 캡처입니다. 같은 연결 요청(`Flags [S]`)이 **처음 한 번 뒤에 몇 번 더 재전송**됐는지 세어 숫자만 `/tmp/retrans.txt` 에 저장하세요.',
     '같은 요청이 몇 번 나타나는지 센 뒤, 그중 재전송이 몇 개인지 따져 보세요.',
     "cat /tmp/cap_syn.log\nN=$(grep -c 'Flags \\[S\\]' /tmp/cap_syn.log)\necho $((N - 1)) > /tmp/retrans.txt\ncat /tmp/retrans.txt\n\n# 간격이 1, 2, 4 초로 두 배씩 늘어난다(지수 백오프). 응답(SYN-ACK 나 RST)이 전혀 없는 것이 특징이고 접속하는 쪽은 결국 시간 초과를 본다",
     S74, [chk('3 이다', '[ "$(cat /tmp/retrans.txt)" = 3 ]')])
# 4
b.nt('RST 를 보낸 쪽', '`/tmp/cap_rst.log` 는 9090 포트로 접속을 시도한 캡처입니다. 연결을 **거부(`Flags [R.]`)한 쪽의 주소**(포트 제외)를 `/tmp/rst_from.txt` 에 저장하세요. (주소만)',
     '`R` 이 들어 있는 줄의 출발지입니다. 포트를 떼어 내려면 마지막 점을 기준으로 자르세요.',
     "cat /tmp/cap_rst.log\ngrep 'Flags \\[R' /tmp/cap_rst.log | awk '{print $3}' | sed 's/\\.[0-9]*$//' > /tmp/rst_from.txt\ncat /tmp/rst_from.txt\n\n# SYN 에 RST 가 즉시 돌아오면 그 서버는 살아 있지만 그 포트에 듣는 프로세스가 없거나 방화벽이 REJECT 한 것이다. 재전송만 반복되는 경우와 구별된다",
     S74, [chk('203.0.113.30 이다', '[ "$(cat /tmp/rst_from.txt)" = 203.0.113.30 ]')])
# 5
b.nt('DNS 질의와 응답의 짝', '`/tmp/cap_dns.log` 에는 DNS 질의 두 건이 있습니다. 질의(`12345+ A? 이름.`)와 응답(`12345 ...`)은 같은 **번호(ID)** 로 짝을 이룹니다. 응답이 `NXDomain`(이름 없음)으로 끝난 질의의 **이름**을 `/tmp/nx_name.txt` 에 저장하세요. (이름만, 끝의 점은 있어도 됩니다)',
     '응답이 `NXDomain` 인 줄의 번호를 찾고, 같은 번호로 보낸 질의에서 이름을 읽으세요.',
     "cat /tmp/cap_dns.log\nID=$(grep NXDomain /tmp/cap_dns.log | grep -o '> [0-9.]*: [0-9]*' | awk '{print $3}')\ngrep \"$ID+\" /tmp/cap_dns.log | grep -o 'A? [^ ]*' | awk '{print $2}' > /tmp/nx_name.txt\ncat /tmp/nx_name.txt\n\n# + 는 재귀 질의를 요청했다는 표시다. 응답의 숫자 2/0/0 은 답·권한·추가 레코드 수이고, NXDomain 응답의 0/1/0 은 답이 없고 권한(SOA) 레코드만 있다는 뜻이다",
     S74, [chk('missing.example.com 이다', 'grep -q "^missing\\.example\\.com\\.\\?$" /tmp/nx_name.txt')])
# 6
b.nt('캡처 명령 적기', '`192.0.2.50` 호스트와 주고받는 **TCP 8080 포트** 패킷만, 이름 해석 없이 숫자로, **10개만** 잡아 `/tmp/cap.pcap` 파일에 저장하려 합니다. 샌드박스에는 캡처 도구가 없으니 실행할 **`tcpdump` 명령 한 줄**을 `/tmp/cmd.txt` 에 적으세요.',
     '이름 해석 끄기, 개수 제한, 파일로 저장하는 옵션과 호스트·포트를 고르는 필터 표현식이 필요합니다. 필터 문법은 `man pcap-filter` 에 있습니다.',
     "echo 'tcpdump -nn -i any -c 10 -w /tmp/cap.pcap host 192.0.2.50 and tcp port 8080' > /tmp/cmd.txt\ncat /tmp/cmd.txt\n\n# 필터 없이 전체를 잡으면 양이 너무 많고 서버에 부담이 된다. 반드시 호스트·포트로 좁히고 -c 나 시간 제한을 둔다. 저장한 파일은 tcpdump -r 로 읽는다",
     S74, [chk('tcpdump 명령이다', 'grep -q "^tcpdump " /tmp/cmd.txt'), chk('이름 해석을 끄는 -nn 이 있다', 'grep -Eq -- " -[a-zA-Z]*nn| -n -n" /tmp/cmd.txt'), chk('10개로 제한했다', 'grep -Eq -- "-c 10( |$)" /tmp/cmd.txt'), chk('/tmp/cap.pcap 에 저장한다', 'grep -Eq -- "-w /tmp/cap.pcap" /tmp/cmd.txt'), chk('호스트와 TCP 포트 필터가 있다', 'grep -q "192.0.2.50" /tmp/cmd.txt && grep -Eq "port 8080" /tmp/cmd.txt && grep -Eq "(^| )tcp( |$)" /tmp/cmd.txt')])
# 7
b.choice('SYN 만 반복되는 캡처', 'tcpdump 에 클라이언트가 보낸 `Flags [S]` 패킷만 1초, 2초, 4초 간격으로 늘려 가며 반복해서 보이고 서버가 보낸 패킷은 하나도 없습니다. 가장 알맞은 해석은?', '응답이 아예 없다는 것과 거부 응답이 왔다는 것의 차이를 생각해 보세요.',
         ['패킷이 중간에서 버려지거나 응답이 돌아오지 못한다', '서버 포트가 닫혀 있어 즉시 거부당하고 있다', '연결은 성공했고 데이터를 기다리고 있다', '클라이언트가 접속을 취소하고 연결을 끊었다'], 0,
         '응답이 전혀 없고 SYN 이 지수 백오프로 재전송되는 것은 방화벽 DROP·경로 문제 등으로 요청이 닿지 않거나 응답이 돌아오지 못할 때의 전형적인 모습입니다. 포트가 닫혀 있다면 RST 가 즉시 돌아오고, 연결이 성공했다면 SYN-ACK 이 보입니다.')
# 8
b.choice('Flags [P.] 읽기', '캡처 한 줄에 `Flags [P.]` 가 있습니다. 이 표시가 뜻하는 것으로 가장 알맞은 것은?', '`P` 와 `.` 이 각각 무엇을 뜻하는지 `man tcpdump` 의 Flags 항목에서 찾아보세요.',
         ['데이터를 즉시 전달하라는 표시와 함께 ACK 도 담은 패킷이다', '연결을 요청하면서 상대의 요청에 응답하는 패킷이다', '연결을 끊으면서 마지막 ACK 를 보내는 패킷이다', '오류가 나서 연결을 강제로 거부하는 패킷이다'], 0,
         'P 는 PSH(받은 데이터를 바로 애플리케이션에 넘기라는 표시), `.` 은 ACK 입니다. 그래서 `[P.]` 는 실제 데이터를 실은 패킷입니다. 연결 요청은 `[S]`·`[S.]`, 종료는 `[F.]`, 강제 거부·중단은 `[R]`·`[R.]` 입니다.')
# 9
b.fill('저장한 캡처 읽기', '앞에서 `-w` 로 저장한 캡처 파일(`/tmp/cap.pcap`)을 다시 열어 내용을 읽는 옵션을 채우세요.', '파일에 쓰는 옵션(`-w`)과 짝이 되는 옵션입니다.',
       'tcpdump -nn -{0} /tmp/cap.pcap', ['r', 'i', 'c', 'e'], [0],
       '`-r` 은 저장된 캡처 파일을 읽어 출력합니다. `-i` 는 캡처할 인터페이스, `-c` 는 잡을 패킷 개수, `-e` 는 링크 계층(MAC) 헤더 출력입니다. 파일로 저장해 두면 장애 시점의 패킷을 나중에 천천히 분석할 수 있습니다.')
# 10
b.order('연결 장애를 캡처로 확인하는 순서', '클라이언트에서 특정 서버 포트로 접속이 안 되는 원인을 서버 쪽 캡처로 확인하려 합니다. 올바른 순서로 놓으세요.', '캡처를 걸어 둔 뒤에 문제를 재현해야 합니다.',
        ['저장된 캡처 파일을 열어 SYN 만 반복되는지, SYN-ACK 나 RST 가 오는지 읽는다', '대상 호스트와 포트로 좁힌 필터로 `-w` 파일에 저장하면서 캡처를 시작한다', '캡처를 멈춘다', '클라이언트에서 같은 접속을 한 번 시도해 재현한다'], [1, 3, 2, 0],
        '필터를 좁혀 캡처를 먼저 걸고, 그 상태에서 접속을 재현하면 해당 패킷만 남습니다. 재현이 끝나면 캡처를 멈추고, 쌓인 패킷에서 요청과 응답(SYN-ACK 또는 RST)이 있는지 읽어 원인을 가립니다.')

if __name__ == '__main__':
    preview(b)
