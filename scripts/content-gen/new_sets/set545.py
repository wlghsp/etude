import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 545 네트워크 영구 설정: hostnamectl, ip 임시 vs 영구, nmcli, 정적 IP·게이트웨이·DNS, 검증 순서. 명세: docs/specs/spec_gap_set545.md
# 샌드박스 제약(직접 확인): linux(Ubuntu 22.04, 비특권 사용자)에는 nmcli·hostnamectl·NetworkManager 가 없고,
# `ip addr add` 는 NET_ADMIN 권한이 없어 "Operation not permitted" 로 실패한다. linux-systemd(Rocky 9)에도 nmcli·ip 가 없다.
# 그래서 실제 명령 출력·설정 파일과 같은 모양의 샘플 파일(/srv/lab/net/...)을 grep/awk/cut 으로 읽는 실습과 개념 문제로 구성한다.

CLEAN = "rm -rf /srv/lab /tmp/*.txt; mkdir -p /srv/lab/net"

HOSTNAMECTL = r"""cat > /srv/lab/net/hostnamectl.txt <<'EOF'
   Static hostname: web01.example.com
Transient hostname: web-tmp
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 0123456789abcdef0123456789abcdef
           Boot ID: fedcba9876543210fedcba9876543210
    Virtualization: kvm
  Operating System: Rocky Linux 9.4 (Blue Onyx)
       CPE OS Name: cpe:/o:rocky:rocky:9::baseos
            Kernel: Linux 5.14.0-427.el9.x86_64
      Architecture: x86-64
EOF
"""
CONNS = r"""cat > /srv/lab/net/nmcli-conn.txt <<'EOF'
NAME      UUID                                  TYPE      DEVICE
lan-main  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
lan-old   b3c1a2e4-7d5f-4c8a-9e21-0f6a8d4c1b77  ethernet  --
lo        1d2e3f40-5a6b-4c7d-8e9f-a0b1c2d3e4f5  loopback  lo
EOF
"""
PROFILE = r"""cat > /srv/lab/net/lan-main.nmconnection <<'EOF'
[connection]
id=lan-main
uuid=5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03
type=ethernet
interface-name=eth0

[ethernet]

[ipv4]
address1=192.0.2.10/24,192.0.2.1
dns=192.0.2.53;192.0.2.54;
method=manual

[ipv6]
addr-gen-mode=eui64
method=auto

[proxy]
EOF
"""
ROUTE = r"""cat > /srv/lab/net/ip-route.txt <<'EOF'
default via 192.0.2.254 dev eth0 proto dhcp src 192.0.2.57 metric 100
192.0.2.0/24 dev eth0 proto kernel scope link src 192.0.2.57 metric 100
EOF
"""
SETLINES = lambda f: f"tr -s ' \\n' '\\n' < {f} | grep -v '^$' | sort | tr '\\n' ' '"

b = SetBuilder(545, '네트워크 영구 설정: 호스트명·nmcli·정적 IP·게이트웨이·DNS',
               '`ip addr add` 로 바꾼 주소는 재부팅하면 사라집니다. 이 세트는 "임시 설정"과 "영구 설정"의 차이를 익히고, `hostnamectl` 로 서버 이름을, NetworkManager 의 `nmcli connection show`·`modify`·`up` 으로 정적 IP·게이트웨이·DNS 를 저장·적용하는 흐름과 설정 뒤 검증 순서(주소 → 경로 → 이름 풀이)를 배웁니다. 샌드박스에는 NetworkManager 가 없어 실제 출력·설정 파일과 같은 모양의 샘플 파일을 `grep`·`awk` 로 읽습니다.',
               'linux', '리눅스', 3, 804, '🌐',
               [{"title": "Red Hat: 네트워킹 구성 및 관리", "url": "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_networking/index"},
                {"title": "systemd: hostnamectl", "url": "https://www.freedesktop.org/software/systemd/man/latest/hostnamectl.html"}], 3)

# 1 -------------------------------------------------------------
b.nt('hostnamectl 읽기: 정적 호스트 이름', '서버에서 `hostnamectl` 을 실행한 결과가 `/srv/lab/net/hostnamectl.txt` 에 저장돼 있습니다. (샌드박스에는 hostnamectl 이 없어 출력 파일을 읽습니다.)\n\n호스트 이름은 두 가지로 나뉩니다. **Static hostname** 은 `/etc/hostname` 에 저장돼 재부팅해도 유지되는 이름이고, **Transient hostname** 은 지금 커널이 쓰고 있는 임시 이름입니다. 두 값이 다르면 서버의 "원래 이름"은 정적 이름입니다.\n\n이 서버의 **정적 호스트 이름**을 `/tmp/host.txt` 에 저장하세요.',
     '`Static hostname:` 이 적힌 줄에서 마지막 칸만 출력하면 됩니다. 비슷하게 생긴 다른 줄에 주의하세요.',
     "cat /srv/lab/net/hostnamectl.txt\nawk '/Static hostname/ {print $NF}' /srv/lab/net/hostnamectl.txt > /tmp/host.txt\ncat /tmp/host.txt   # web01.example.com",
     CLEAN + "; " + HOSTNAMECTL,
     [chk('정적 호스트 이름이 저장돼 있다', '[ "$(tr -d " \\n" < /tmp/host.txt)" = web01.example.com ]')])
# 2 -------------------------------------------------------------
b.choice('재부팅 뒤에도 유지되는 호스트 이름 변경', '서버 이름을 `web02` 로 바꾸려 합니다. **재부팅한 뒤에도 유지되는** 방법은 무엇일까요?',
         '이름이 어디에 저장되는지 생각해 보세요. 지금 커널의 값만 바꾸는 방법과, 파일에 남기는 방법이 있습니다.',
         ['`hostnamectl set-hostname web02` 로 정적 호스트 이름(`/etc/hostname`)에 저장한다', '`hostname web02` 로 현재 이름만 바꾼다', '`export HOSTNAME=web02` 로 환경 변수를 바꾼다', '`echo web02 > /proc/sys/kernel/hostname` 로 커널 값을 바꾼다'], 0,
         '`hostnamectl set-hostname` 은 `/etc/hostname` 에 저장하므로 재부팅해도 유지되고 곧바로 적용됩니다. `hostname 이름` 과 `/proc/sys/kernel/hostname` 쓰기는 **실행 중인 커널의 값만** 바꿔서 재부팅하면 사라집니다(그래서 Transient 와 Static 이 달라질 수 있습니다). `export HOSTNAME` 은 그 셸 안의 변수일 뿐 시스템 이름과 무관합니다. 바꾼 뒤에는 `hostnamectl` 의 Static hostname 으로 확인합니다.')
# 3 -------------------------------------------------------------
b.choice('ip addr add 는 영구일까', '서버에서 `ip addr add 192.0.2.10/24 dev eth0` 를 실행하자 `ip -br a` 에 주소가 보이고 통신도 됩니다. 이 설정에 대한 설명으로 알맞은 것은 무엇일까요?',
         '`ip` 명령은 커널이 지금 들고 있는 네트워크 상태를 바꿉니다. 그 상태가 디스크 어딘가에 저장되는지 생각해 보세요.',
         ['커널의 현재 상태에만 적용된 임시 설정이라 재부팅하면 사라진다. 영구히 하려면 NetworkManager 연결 프로필에 저장해야 한다', '자동으로 `/etc/hostname` 에 기록되어 재부팅 뒤에도 유지된다', '`ip` 명령으로 한 설정은 항상 영구 설정이다', '주소는 eth0 가 아니라 lo 에 추가된다'], 0,
         '`ip` 명령은 **지금 동작 중인 커널의 상태**를 바로 바꾸기 때문에 즉시 효과가 있지만 어디에도 저장되지 않아 재부팅하면 사라집니다. 급히 시험해 볼 때나 장애 대응 중 임시 조치에는 편하지만, 계속 써야 하는 주소는 부팅 때 설정을 읽어 주는 도구(Rocky·RHEL 계열은 NetworkManager, 연결 프로필)에 저장해야 합니다. `/etc/hostname` 은 호스트 이름 파일이지 IP 와 무관하고, 주소는 `dev eth0` 로 지정한 eth0 에 붙습니다.')
# 4 -------------------------------------------------------------
b.nt('nmcli connection show: 지금 쓰는 연결 찾기', 'NetworkManager 는 설정을 **연결(connection) 프로필**로 저장하고, 프로필을 네트워크 **장치(device)** 에 붙여 사용합니다. 이름은 서로 다를 수 있습니다. `nmcli connection show` 의 결과가 `/srv/lab/net/nmcli-conn.txt` 에 있습니다. `DEVICE` 칸이 `--` 인 프로필은 지금 어떤 장치에도 쓰이지 않는(비활성) 것입니다.\n\n장치 **eth0** 에 지금 붙어 사용 중인 **연결 프로필의 이름**을 `/tmp/conn.txt` 에 저장하세요.',
     '`DEVICE` 칸이 eth0 인 줄을 고른 뒤, 그 줄의 `NAME` 칸을 출력하면 됩니다.',
     "cat /srv/lab/net/nmcli-conn.txt\nawk '$4==\"eth0\" {print $1}' /srv/lab/net/nmcli-conn.txt > /tmp/conn.txt\ncat /tmp/conn.txt   # lan-main",
     CLEAN + "; " + CONNS,
     [chk('eth0 의 연결 이름이 저장돼 있다', '[ "$(tr -d " \\n" < /tmp/conn.txt)" = lan-main ]')])
# 5 -------------------------------------------------------------
b.nt('프로필 파일에서 정적 IP·게이트웨이 읽기', 'NetworkManager(Rocky 9)는 연결 프로필을 `/etc/NetworkManager/system-connections/이름.nmconnection` 파일로 저장합니다. 샘플이 `/srv/lab/net/lan-main.nmconnection` 에 있습니다. `[ipv4]` 구역에서 `method=manual` 은 정적 IP 를 뜻하고, `address1=` 줄은 `주소/접두사,게이트웨이` 형식입니다.\n\n이 프로필에 설정된 **IP 주소/접두사**를 `/tmp/ip.txt` 에, **게이트웨이**를 `/tmp/gw.txt` 에 저장하세요. (예: `203.0.113.5/24` 형태 그대로)',
     '`address1=` 로 시작하는 줄 하나에 두 값이 쉼표로 붙어 있습니다. `=` 와 `,` 로 나누면 각각 얻습니다.',
     "cat /srv/lab/net/lan-main.nmconnection\ngrep '^address1=' /srv/lab/net/lan-main.nmconnection | cut -d= -f2 | cut -d, -f1 > /tmp/ip.txt\ngrep '^address1=' /srv/lab/net/lan-main.nmconnection | cut -d, -f2 > /tmp/gw.txt\ncat /tmp/ip.txt /tmp/gw.txt   # 192.0.2.10/24, 192.0.2.1",
     CLEAN + "; " + PROFILE,
     [chk('IP 주소/접두사가 저장돼 있다', '[ "$(tr -d " \\n" < /tmp/ip.txt)" = 192.0.2.10/24 ]'),
      chk('게이트웨이가 저장돼 있다', '[ "$(tr -d " \\n" < /tmp/gw.txt)" = 192.0.2.1 ]')])
# 6 -------------------------------------------------------------
b.fill('이미 있는 연결의 IP 바꾸기', '이미 있는 연결 프로필 `lan-main` 의 IPv4 주소를 `192.0.2.10/24` 로 **고치려고** 합니다. 빈칸에 들어갈 nmcli 동사를 고르세요.\n\n`nmcli connection {빈칸} lan-main ipv4.addresses 192.0.2.10/24`',
       '이미 있는 프로필의 속성 하나를 바꾸는 동사입니다. 새로 만드는 동사나 단순 조회 동사가 아닙니다.',
       'nmcli connection {0} lan-main ipv4.addresses 192.0.2.10/24', ['modify', 'up', 'show', 'delete'], [0],
       '`nmcli connection modify 이름 속성 값` 이 기존 프로필의 속성을 고쳐 파일에 저장합니다. 정적 IP 로 쓰려면 보통 `ipv4.method manual`, `ipv4.addresses`, `ipv4.gateway`, `ipv4.dns` 를 함께 설정합니다. `up` 은 프로필을 적용(활성화), `show` 는 조회, `delete` 는 프로필 삭제입니다. 새 프로필은 `nmcli connection add type ethernet con-name 이름 ifname 장치 ...` 로 만듭니다.')
# 7 -------------------------------------------------------------
b.choice('modify 했는데 주소가 안 바뀌어요', '`nmcli connection modify lan-main ipv4.method manual ipv4.addresses 192.0.2.10/24` 를 실행하고 오류가 없었습니다. 프로필 파일에는 새 주소가 보이는데, `ip -br a` 에는 여전히 예전 주소가 나옵니다. 가장 알맞은 이유와 조치는 무엇일까요?',
         '`modify` 가 한 일과 "지금 장치에 붙이는 일"을 구분해 보세요.',
         ['`modify` 는 프로필(저장된 설정)만 바꾸고 장치에는 아직 적용하지 않았다. `nmcli connection up lan-main` 으로 다시 활성화한다', '`modify` 는 원래 아무것도 저장하지 않는다. `hostnamectl` 로 다시 저장한다', '`ip -br a` 는 항상 예전 주소만 보여 준다', '서버를 반드시 삭제 후 재설치해야 한다'], 0,
         '`nmcli connection modify` 는 **저장된 프로필**만 고치며, 이미 연결된 장치에는 자동으로 반영되지 않습니다. `nmcli connection up 이름`(또는 `nmcli device reapply 장치`)으로 다시 활성화해야 바뀝니다. 원격 접속 중 IP 를 바꾸면 `up` 하는 순간 내 세션이 끊길 수 있으니, 콘솔 접근이 가능한지 먼저 확인합니다. `ip -br a` 는 현재 상태를 정확히 보여 주므로 "프로필 ≠ 실제 상태"일 때 적용 안 됨을 알려 주는 증거입니다.')
# 8 -------------------------------------------------------------
b.nt('실제 기본 경로(게이트웨이) 확인', '앞 문제의 프로필(`lan-main`)에는 게이트웨이가 `192.0.2.1` 로 적혀 있는데, 서버가 실제로 쓰는 경로가 같은지 확인하려고 `ip route` 를 실행한 결과를 `/srv/lab/net/ip-route.txt` 에 남겼습니다. `default via 주소` 줄이 "다른 네트워크로 갈 때 거치는 문"(기본 게이트웨이)입니다.\n\n**지금 실제로 쓰이는 기본 게이트웨이 주소**를 `/tmp/run_gw.txt` 에 저장하세요. 프로필 값과 같은지도 비교해 보세요.',
     '`default` 로 시작하는 줄을 고르고, `via` 바로 다음 칸을 출력하세요. 프로필 파일에서 읽은 값이 아니라 `ip route` 결과 기준입니다.',
     "cat /srv/lab/net/ip-route.txt\nawk '$1==\"default\" {print $3}' /srv/lab/net/ip-route.txt > /tmp/run_gw.txt\ncat /tmp/run_gw.txt   # 192.0.2.254\n# 프로필은 192.0.2.1(manual), 실제는 192.0.2.254(proto dhcp): 변경이 아직 적용되지 않았다. nmcli connection up 이 필요하다",
     CLEAN + "; " + ROUTE,
     [chk('실제 기본 게이트웨이가 저장돼 있다', '[ "$(tr -d " \\n" < /tmp/run_gw.txt)" = 192.0.2.254 ]')])
# 9 -------------------------------------------------------------
b.choice('IP 로는 되는데 이름으로는 안 될 때', '정적 IP 설정을 끝낸 서버에서 다른 네트워크의 주소(`ping 198.51.100.10`)는 응답하는데, `ping example.com` 은 `Name or service not known` 으로 실패합니다. 가장 먼저 점검할 곳은 어디일까요?',
         '다른 네트워크까지 패킷이 나간다는 것은 어떤 설정이 이미 맞다는 뜻인지 생각해 보세요. 이름을 주소로 바꾸는 일은 누가 합니까?',
         ['DNS 서버 설정(`ipv4.dns`, `/etc/resolv.conf`)이 비었거나 틀렸는지 확인한다', '게이트웨이 주소를 다른 값으로 바꾼다', '서브넷 접두사를 `/8` 로 바꾼다', '호스트 이름을 `hostnamectl` 로 다시 정한다'], 0,
         '다른 네트워크 주소로 통신된다면 주소·접두사·게이트웨이는 제 역할을 하고 있다는 뜻입니다. **이름 → IP 변환**은 DNS 서버가 맡으므로 `nmcli connection show lan-main | grep ipv4.dns` 와 `/etc/resolv.conf` 의 `nameserver` 줄을 확인합니다(`getent hosts 이름` 으로 풀이 여부 확인). 게이트웨이·접두사를 건드리면 멀쩡한 부분을 망가뜨릴 수 있고, 내 서버의 호스트 이름은 남의 이름을 풀어 주는 일과 무관합니다.')
# 10 ------------------------------------------------------------
b.order('정적 IP 설정 뒤 적용·검증 순서', '이미 있는 연결 프로필을 정적 IP 로 바꾸고 제대로 됐는지 확인하려 합니다. 먼저 **저장 → 적용**을 하고, 확인은 네트워크의 **아래 단계에서 위 단계**(내 주소 → 길 → 이름 풀이) 순으로 합니다. 알맞은 순서로 카드를 놓으세요.',
        '변경은 저장한 뒤에야 적용할 수 있고, 확인은 앞 단계가 되어야 다음 단계가 의미 있습니다.',
        ['`ip route` 로 기본 경로의 게이트웨이가 설정한 값인지 확인한다', '`nmcli connection up 이름` 으로 변경을 적용한다', '`getent hosts example.com` 으로 이름 풀이가 되는지 확인한다', '`nmcli connection modify` 로 주소·게이트웨이·DNS 를 프로필에 저장한다', '`ip -br a` 로 새 주소가 장치에 붙었는지 확인한다'], [3, 1, 4, 0, 2],
        '저장(`modify`) → 적용(`up`) → 주소 확인(`ip -br a`) → 경로 확인(`ip route`) → 이름 풀이 확인(`getent hosts`) 순서입니다. 주소가 안 붙었는데 경로나 DNS 를 먼저 보면 헛수고가 됩니다. 원격에서 바꿀 때는 적용 후 연결이 끊길 수 있으니, 되돌릴 방법(콘솔·이전 설정 기록)을 미리 준비합니다.')

if __name__ == '__main__':
    preview(b)
