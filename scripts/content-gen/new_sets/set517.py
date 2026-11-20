import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 517 접근이 막힐 때 상황집: 권한 거부 vs 접속 거부 vs 시간 초과. 명세: docs/specs/spec_gap_set517.md
# 샌드박스(linux)는 root 로 들어가므로 "일반 계정(nobody)이 해 보면 어떻게 되나"를 `runuser -u nobody -- 명령` 으로 재현한다.
# getfacl/setfacl·iptables 는 없다. ACL·방화벽(timed out)은 개념 문제로 다루고, 접속 거부는 로컬 perl 서버(/opt/lab/web.pl)로 재현한다.

WEBPL = r"""mkdir -p /opt/lab; cat > /opt/lab/web.pl <<'EOF'
use IO::Socket::INET;
my ($a, $p) = @ARGV;
my $s = IO::Socket::INET->new(LocalAddr => $a, LocalPort => $p, Listen => 5, ReuseAddr => 1) or die "bind: $!";
while (my $c = $s->accept) { my $l = <$c>; my $m = "web-ok:$p\n"; print $c "HTTP/1.0 200 OK\r\nContent-Length: " . length($m) . "\r\n\r\n$m"; close $c; }
EOF
"""
CLEAN = "pkill -x perl; rm -rf /srv/lab /tmp/*.txt /tmp/cases; " + WEBPL + "groupdel dev 2>/dev/null; groupadd dev"
START = lambda addr, port: f"nohup perl /opt/lab/web.pl {addr} {port} >/dev/null 2>&1 & for i in $(seq 1 20); do ss -ltn | grep -q ':{port} ' && break; sleep 0.2; done"
NOBODY_CAT = lambda f: f'runuser -u nobody -- cat {f} >/dev/null 2>&1'
IP = "$(hostname -I | awk '{print $1}')"

b = SetBuilder(517, '접근이 막힐 때 상황집: 권한 거부 vs 접속 거부 vs 시간 초과',
               '`Permission denied` 가 나면 소유자·그룹, 모드, 상위 디렉터리의 실행 권한 순으로 직접 따져 고치고, `Connection refused` 와 `timed out` 의 차이를 구분합니다. 서비스를 내렸다 올리고, 127.0.0.1 로만 듣는 서비스를 0.0.0.0 으로 바꾸고, 틀린 포트를 `ss` 로 찾아 접속을 복구합니다. ACL 의 `+` 표시와 시간 초과의 원인(방화벽이 패킷을 버림)은 문제로 익힙니다.',
               'linux', '리눅스', 4, 738, '🚧',
               [{"title": "Linux man page: namei", "url": "https://man7.org/linux/man-pages/man1/namei.1.html"}, {"title": "Linux man page: ss", "url": "https://man7.org/linux/man-pages/man8/ss.8.html"}], 7)

# 1 -------------------------------------------------------------
b.nt('Permission denied ① 소유자가 달라서', '일반 계정 `nobody` 가 읽어야 하는 비밀 설정 파일 `/srv/lab/own/token.txt` 가 있는데 `Permission denied` 가 납니다. 이 계정으로 직접 해 보려면 `runuser -u nobody -- 명령` 을 씁니다. 예: `runuser -u nobody -- cat /srv/lab/own/token.txt`\n\n먼저 `ls -l` 로 파일의 소유자와 모드를 읽어 보세요. 이 파일은 **소유자만 읽고 쓰는 비밀 파일(모드 `600`)이라 모드는 그대로 두어야 합니다**. 모드는 건드리지 말고 `nobody` 가 읽을 수 있게 고치세요.',
     '`ls -l` 의 세 번째 열이 소유자입니다. 모드를 그대로 두고 풀려면 "누구의 파일인가"를 바꿔야 합니다. 소유자를 바꾸는 명령을 떠올려 보세요.',
     "runuser -u nobody -- cat /srv/lab/own/token.txt   # Permission denied 확인\nls -l /srv/lab/own/token.txt                        # 소유자 root, 모드 -rw------- 확인\nchown nobody /srv/lab/own/token.txt                 # 소유자를 nobody 로\nrunuser -u nobody -- cat /srv/lab/own/token.txt   # 읽힌다",
     CLEAN + "; mkdir -p /srv/lab/own && echo secret-token > /srv/lab/own/token.txt && chmod 755 /srv/lab /srv/lab/own && chmod 600 /srv/lab/own/token.txt",
     [chk('nobody 가 파일을 읽을 수 있다', NOBODY_CAT('/srv/lab/own/token.txt')),
      chk('모드는 600 그대로다', '[ "$(stat -c %a /srv/lab/own/token.txt)" = 600 ]'),
      chk('소유자가 nobody 다', '[ "$(stat -c %U /srv/lab/own/token.txt)" = nobody ]')])
# 2 -------------------------------------------------------------
b.nt('Permission denied ② 모드에 읽기 권한이 없어서', '`/srv/lab/mode/report.txt` 를 `nobody` 가 읽으려는데 또 `Permission denied` 입니다. 이번 파일의 소유자는 `root` 로 올바르고, 소유자·그룹 모두 `nobody` 와 상관없습니다. `ls -l` 로 모드를 읽고, **누구나 읽기만 가능하게** 고치세요. (소유자는 그대로 `root`, 아무나 쓸 수 있게 열면 안 됩니다.)',
     '모드 문자열은 소유자·그룹·그 외 사용자 순서의 세 묶음입니다. nobody 는 세 번째 묶음에 해당합니다. 그 묶음에 읽기만 더하세요.',
     "runuser -u nobody -- cat /srv/lab/mode/report.txt   # Permission denied\nls -l /srv/lab/mode/report.txt                         # -rw-r----- : 그 외 사용자 칸이 ---\nchmod o+r /srv/lab/mode/report.txt                     # 그 외 사용자에게 읽기만 추가\nrunuser -u nobody -- cat /srv/lab/mode/report.txt",
     CLEAN + "; mkdir -p /srv/lab/mode && echo quarterly-report > /srv/lab/mode/report.txt && chmod 755 /srv/lab /srv/lab/mode && chmod 640 /srv/lab/mode/report.txt",
     [chk('nobody 가 읽을 수 있다', NOBODY_CAT('/srv/lab/mode/report.txt')),
      chk('소유자는 root 그대로다', '[ "$(stat -c %U /srv/lab/mode/report.txt)" = root ]'),
      chk('다른 사용자는 쓰기 권한이 없다', '[ "$(stat -c %A /srv/lab/mode/report.txt | cut -c9)" = - ]')])
# 3 -------------------------------------------------------------
b.nt('Permission denied ③ 그룹에 속해 있지 않아서', '`/srv/lab/grp/team.txt` 는 그룹 `dev` 가 읽도록 되어 있고(모드 `640`) 그 외 사용자는 아무 권한이 없습니다. 그런데 `nobody` 가 읽으려면 `Permission denied` 입니다. 이 파일은 팀원만 봐야 해서 **그 외 사용자에게 읽기를 열어서는 안 됩니다**. 모드는 그대로 두고 `nobody` 가 읽을 수 있게 고치세요.\n\n(계정이 어느 그룹에 속했는지는 `id 계정명` 으로 볼 수 있습니다.)',
     '`id nobody` 로 소속 그룹을 보고, 파일의 그룹과 비교하세요. 파일 쪽이 아니라 계정 쪽을 바꾸는 방법이 있습니다.',
     "id nobody                       # 소속 그룹에 dev 가 없다\nls -l /srv/lab/grp/team.txt     # 그룹이 dev, 모드 -rw-r-----\nusermod -aG dev nobody          # nobody 를 dev 그룹에 추가 (-a: 기존 그룹 유지)\nrunuser -u nobody -- cat /srv/lab/grp/team.txt",
     CLEAN + "; mkdir -p /srv/lab/grp && echo team-notes > /srv/lab/grp/team.txt && chgrp dev /srv/lab/grp/team.txt && chmod 755 /srv/lab /srv/lab/grp && chmod 640 /srv/lab/grp/team.txt",
     [chk('nobody 가 읽을 수 있다', NOBODY_CAT('/srv/lab/grp/team.txt')),
      chk('그 외 사용자 권한은 그대로 없다', '[ "$(stat -c %a /srv/lab/grp/team.txt | cut -c3)" = 0 ]'),
      chk('파일의 그룹은 dev 다', '[ "$(stat -c %G /srv/lab/grp/team.txt)" = dev ]')])
# 4 -------------------------------------------------------------
b.nt('Permission denied ④ 파일은 멀쩡한데 윗길이 막혀서', '`/srv/lab/up/public/info.txt` 는 누구나 읽을 수 있는 모드(`644`)입니다. 그런데 `nobody` 가 읽으면 `Permission denied` 입니다. 파일 권한은 문제가 없는데 왜일까요? 파일에 도달하는 **길(상위 디렉터리)** 의 권한을 확인하세요. 원인이 되는 디렉터리를 고쳐 `nobody` 가 읽게 하되, **파일의 모드(`644`)는 바꾸지 말고** 다른 사용자가 디렉터리에 쓰게 열지도 마세요.',
     '디렉터리를 통과하려면 그 디렉터리에 "실행(x)" 권한이 필요합니다. 경로의 각 칸을 한 줄씩 권한과 함께 보여 주는 명령(`namei`)이 있습니다. 옵션은 `man namei` 로 찾아 보세요.',
     "runuser -u nobody -- cat /srv/lab/up/public/info.txt   # Permission denied\nnamei -l /srv/lab/up/public/info.txt                    # up 디렉터리가 drwx------ 임을 찾는다\nchmod o+x /srv/lab/up                                   # 그 외 사용자에게 통과(실행) 권한만 추가\nrunuser -u nobody -- cat /srv/lab/up/public/info.txt",
     CLEAN + "; mkdir -p /srv/lab/up/public && echo open-info > /srv/lab/up/public/info.txt && chmod 755 /srv/lab /srv/lab/up/public && chmod 700 /srv/lab/up && chmod 644 /srv/lab/up/public/info.txt",
     [chk('nobody 가 읽을 수 있다', NOBODY_CAT('/srv/lab/up/public/info.txt')),
      chk('파일 모드는 644 그대로다', '[ "$(stat -c %a /srv/lab/up/public/info.txt)" = 644 ]'),
      chk('윗 디렉터리를 다른 사용자가 쓰지 못한다', '[ "$(stat -c %A /srv/lab/up | cut -c9)" != w ]')])
# 5 -------------------------------------------------------------
b.nt('Connection refused ① 서비스가 안 떠 있다', '이번에는 권한이 아니라 **접속** 문제입니다. 간단한 웹 서비스(`/opt/lab/web.pl`, 사용법 `perl /opt/lab/web.pl 주소 포트`)가 `8080` 포트에서 응답해야 하는데 접속이 되지 않습니다.\n\n`curl http://127.0.0.1:8080` 을 해 보면 `Connection refused` 입니다. 이 메시지는 "그 주소·포트에 **받아 줄 프로세스가 없다**"는 뜻입니다. 8080 을 듣고 있는 프로세스가 있는지 `ss` 로 확인한 뒤, 서비스를 **`127.0.0.1` 주소의 8080 포트**로 백그라운드로 시작하고, 응답을 `/tmp/out.txt` 에 저장하세요.',
     '`ss -ltn` 은 듣고 있는(LISTEN) TCP 포트를 보여 줍니다. 서비스는 계속 떠 있어야 하므로 뒤에 `&` 를 붙여 백그라운드로 실행하고, 뜰 때까지 잠깐 기다린 뒤 `curl -s` 의 출력을 `>` 로 저장하세요.',
     "curl -s http://127.0.0.1:8080; echo rc=$?           # Connection refused\nss -ltn | grep 8080                                   # 아무것도 안 나옴: 듣는 프로세스 없음\nnohup perl /opt/lab/web.pl 127.0.0.1 8080 >/dev/null 2>&1 &\nsleep 1\ncurl -s http://127.0.0.1:8080 > /tmp/out.txt\ncat /tmp/out.txt",
     CLEAN,
     [chk('8080 포트를 듣고 있다', 'ss -ltn | grep -q ":8080 "'),
      chk('응답이 파일에 저장돼 있다', 'grep -q web-ok:8080 /tmp/out.txt')])
# 6 -------------------------------------------------------------
b.nt('Connection refused ② 127.0.0.1 로만 듣고 있다', '서비스는 떠 있습니다(8080). 서버 안에서 `curl http://127.0.0.1:8080` 은 잘 됩니다. 그런데 **이 서버 자신의 네트워크 주소**(`hostname -I` 의 첫 번째 값)로 접속하면 `Connection refused` 입니다. 다른 컴퓨터가 접속할 때와 같은 상황입니다.\n\n`ss -ltn` 의 **Local Address** 열을 읽어 원인을 찾고, 서비스를 **모든 주소(`0.0.0.0`)** 로 듣게 다시 시작해서 서버의 네트워크 주소로도 접속되게 하세요. (이전 서비스는 먼저 종료해야 포트가 비어요. 종료할 프로세스 번호는 `ss -ltnp` 에 나옵니다.)',
     '`127.0.0.1:8080` 은 "이 서버 안에서만", `0.0.0.0:8080` 은 "모든 주소로" 듣는다는 뜻입니다. 같은 포트로 두 개를 띄울 수 없으니 기존 프로세스를 `kill` 한 뒤 다시 시작하세요.',
     "ss -ltnp | grep 8080                                 # 127.0.0.1:8080 만 듣고 있고 pid 가 보인다\npkill -x perl                                          # 기존 서비스 종료 (또는 kill <pid>)\nnohup perl /opt/lab/web.pl 0.0.0.0 8080 >/dev/null 2>&1 &\nsleep 1\ncurl -s http://$(hostname -I | awk '{print $1}'):8080  # 서버 주소로도 응답",
     CLEAN + "; " + START('127.0.0.1', 8080),
     [chk('모든 주소(0.0.0.0)로 8080 을 듣는다', 'ss -ltn | grep -q "0.0.0.0:8080 "'),
      chk('서버 주소로 접속하면 응답이 온다', f'curl -s -m 3 http://{IP}:8080 | grep -q web-ok:8080')])
# 7 -------------------------------------------------------------
b.nt('Connection refused ③ 포트를 잘못 알고 있다', '같은 서비스를 쓰려는데 문서에 적힌 `8080` 으로 접속하면 `Connection refused` 입니다. 서비스는 **다른 포트**에서 정상으로 떠 있습니다(포트가 바뀌었다고 가정합니다). 서버가 실제로 듣고 있는 포트를 `ss` 로 찾아서 그 포트로 접속하고, 응답을 `/tmp/out.txt` 에 저장하세요.',
     '`ss -ltn` 에서 LISTEN 목록의 Local Address 끝 숫자가 포트입니다. 환경 기본 서비스 외에 perl 이 쓰는 포트를 찾으려면 `-p` 를 붙여 프로세스 이름을 보세요.',
     "curl -s http://127.0.0.1:8080; echo rc=$?     # Connection refused (8080 은 아무도 안 듣는다)\nss -ltnp                                       # perl 이 9091 을 듣고 있다\ncurl -s http://127.0.0.1:9091 > /tmp/out.txt\ncat /tmp/out.txt",
     CLEAN + "; " + START('127.0.0.1', 9091),
     [chk('실제 서비스의 응답이 저장돼 있다', 'grep -q web-ok:9091 /tmp/out.txt')])
# 8 -------------------------------------------------------------
b.nt('refused 와 timed out 가려내기', '장애 접수 로그 5개가 `/tmp/cases/` 에 있습니다(`a.log` ~ `e.log`). 한 줄씩 접속 실패 메시지입니다. 두 메시지는 원인이 완전히 다릅니다.\n- `Connection refused` : 상대 서버가 "그 포트는 안 듣는다"고 **바로 답함** → 서비스 문제\n- `timed out` : 아무 답이 없음 → 중간에서 패킷이 **버려지고 있을** 가능성(방화벽 등)\n\n파일을 읽고 아래 두 파일을 만드세요. (한 줄에 파일 이름 하나, 경로는 있어도 없어도 됩니다)\n- `/tmp/refused.txt` : `refused` 가 적힌 로그 파일 이름\n- `/tmp/timeout.txt` : `timed out` 이 적힌 로그 파일 이름',
     '`grep -l 찾을문자열 파일들` 은 일치하는 파일의 **이름만** 출력합니다. 출력 방향은 `>` 로 바꿉니다. `timed out` 은 띄어쓰기가 있으니 따옴표로 감싸세요.',
     "cat /tmp/cases/*.log\ngrep -l 'refused' /tmp/cases/*.log > /tmp/refused.txt\ngrep -l 'timed out' /tmp/cases/*.log > /tmp/timeout.txt\n\n# refused → 서비스가 안 떠 있거나 주소·포트가 틀림 (서버 쪽을 본다)\n# timed out → 방화벽·보안 그룹·경로 문제 (중간 경로를 본다)\n# e.log 는 이름을 못 찾는 DNS 문제라 둘 다 아니다",
     CLEAN + """; mkdir -p /tmp/cases; cd /tmp/cases
echo 'curl: (7) Failed to connect to app.example.com port 8080 after 2 ms: Connection refused' > a.log
echo 'curl: (28) Connection timed out after 5001 milliseconds' > b.log
echo 'ssh: connect to host 192.0.2.20 port 22: Connection refused' > c.log
echo 'ssh: connect to host 192.0.2.21 port 22: Connection timed out' > d.log
echo 'curl: (6) Could not resolve host: api.example.com' > e.log""",
     [chk('refused 목록이 a.log, c.log 다', '[ "$(sed "s#.*/##" /tmp/refused.txt | sort | tr "\\n" " ")" = "a.log c.log " ]'),
      chk('timed out 목록이 b.log, d.log 다', '[ "$(sed "s#.*/##" /tmp/timeout.txt | sort | tr "\\n" " ")" = "b.log d.log " ]')])
# 9 -------------------------------------------------------------
b.choice('모드는 맞는데 거부될 때: ls -l 끝의 +', '`nobody` 가 읽을 수 있어야 하는 파일의 `ls -l` 결과가 `-rw-r-----+ 1 root dev 20 Nov 19 10:00 team.txt` 입니다. 모드 문자열 맨 끝의 `+` 는 무엇을 뜻할까요? (이 샌드박스에는 `getfacl`·`setfacl` 이 없어서 개념으로 풉니다.)',
         '`ls -l` 은 소유자·그룹·그 외 세 묶음만 보여 줍니다. 그 묶음만으로 설명되지 않는 추가 규칙이 있다는 표시입니다.',
         ['ACL(개별 사용자·그룹별 추가 권한)이 붙어 있어서 `getfacl` 로 확인해야 한다', '파일 내용이 압축되어 있다', '하드 링크가 둘 이상 걸려 있다', '실행 중에만 잠기는 파일이다'], 0,
         '`+` 는 모드 비트 말고 **ACL** 항목이 더 붙어 있다는 표시입니다. 모드(`r--` 등)만 보고 판단하면 틀릴 수 있어서, 소유권 → 모드 → `+` 가 있으면 `getfacl` 로 ACL 까지 확인합니다. 그래도 설명이 안 되면 파일이 아니라 상위 디렉터리의 실행 권한을 봅니다. 압축, 하드 링크 수, 잠금은 `+` 와 관련이 없습니다(하드 링크 수는 모드 문자열 뒤의 숫자 열입니다).')
# 10 ------------------------------------------------------------
b.choice('timed out 이 나는 가장 흔한 원인', '다른 서버의 8443 포트로 접속하는데 `curl` 이 오래 기다리다 `Connection timed out` 으로 끝났습니다. 서비스는 분명 떠 있습니다. 가장 가능성이 높은 원인은 무엇일까요?',
         '"바로 거절"이 아니라 "아무 답이 없음"입니다. 서버 프로세스가 직접 답하지 못하는 상황을 생각해 보세요.',
         ['중간의 방화벽이나 보안 그룹이 그 포트의 패킷을 조용히 버리고 있다', '서비스 프로세스가 죽어 있다', '서비스가 127.0.0.1 로만 듣고 있다', '대상 파일의 모드가 `600` 이다'], 0,
         '패킷이 버려지면 서버가 아무 답도 하지 못해 클라이언트는 시간 초과까지 기다립니다. 서비스가 죽었거나 포트를 틀렸거나 127.0.0.1 로만 듣는 경우는 **서버가 RST 로 바로 거절**해서 `Connection refused` 가 됩니다. 파일 모드는 `Permission denied` 쪽 문제입니다. 그래서 refused 는 서버를, timed out 은 방화벽·보안 그룹·라우팅을 먼저 봅니다.')
# 11 ------------------------------------------------------------
b.fill('포트가 열렸는지만 확인하는 nc 옵션', '`nc` 로 데이터를 보내지 않고 **포트가 열렸는지만** 확인하려고 합니다. 5초 안에 연결되는지 보는 명령의 빈칸을 채우세요. (`-w 5` 는 5초 대기)',
       '데이터를 보내지 않고 연결만 해 보고 끝내는 "스캔" 모드를 `man nc` 에서 찾아 보세요.',
       'nc -{0} -w 5 127.0.0.1 8080', ['z', 'l', 'k', 'u'], [0],
       '`-z` 는 데이터를 보내지 않고 연결만 시도합니다(열렸는지 확인). 열려 있으면 성공, 안 떠 있으면 `Connection refused`, 필터링되면 대기하다 `timed out` 입니다. `-l` 은 직접 듣는 서버가 되고, `-k` 는 듣는 모드에서 연결이 끝나도 계속 듣게 하며, `-u` 는 UDP 를 씁니다.')
# 12 ------------------------------------------------------------
b.order('Connection refused 점검 순서', '서비스에 접속하는데 `Connection refused` 가 납니다. 알맞은 점검·복구 순서로 카드를 놓으세요.',
        '먼저 증상 메시지를 해석하고, 서버 쪽 상태를 확인한 뒤, 고치고, 마지막에 확인하는 순서입니다. 가까운 곳(서버 안)에서 먼 곳(바깥)으로 갑니다.',
        ['서버 안에서 `curl 127.0.0.1:포트` 로 응답이 오는지 확인한다', '오류 메시지가 `Connection refused` 인지 읽어 서비스 쪽 문제로 좁힌다', '서버의 주소로 다시 접속해 바인드 주소 문제가 없는지 확인한다', '듣고 있지 않으면 서비스를 시작한다', '서버에서 `ss -ltn` 으로 그 포트가 LISTEN 중인지 본다'], [1, 4, 3, 0, 2],
        '`refused` 를 읽으면 방화벽보다 서비스 쪽을 먼저 봅니다. `ss -ltn` 으로 그 포트를 듣는 프로세스가 있는지 보고, 없으면 서비스를 시작합니다. 시작한 뒤 서버 안에서 `127.0.0.1` 로 응답을 확인하고, 마지막으로 서버의 주소로 접속해 `127.0.0.1` 로만 듣고 있지 않은지 확인합니다.')

if __name__ == '__main__':
    preview(b)
