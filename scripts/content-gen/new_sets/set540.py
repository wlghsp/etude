import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 540 방화벽과 SELinux 읽기: 허용 포트·컨텍스트·거부 로그. 명세: docs/specs/spec_gap_set540.md
# 샌드박스(Rocky 9 ubi-init 컨테이너)에는 firewall-cmd·getenforce·restorecon·semanage·ausearch·iptables 가 없고(직접 확인),
# dnf 로 깔아도 D-Bus·SELinux 커널이 없어 동작하지 않는다. 그래서 실제 명령 출력 형식 그대로의 샘플 파일(/srv/lab/...)을
# grep/awk/tr 로 읽는 실습과 읽기형 문제로 구성한다.

CLEAN = "rm -rf /srv/lab /tmp/*.txt; mkdir -p /srv/lab/fw /srv/lab/se"

LISTALL = r"""cat > /srv/lab/fw/list-all.txt <<'EOF'
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 8080/tcp 9090/tcp
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
EOF
"""
PORTS = r"""echo '8080/tcp 8443/tcp 9090/tcp' > /srv/lab/fw/runtime-ports.txt
echo '7000/tcp 8080/tcp 8443/tcp' > /srv/lab/fw/permanent-ports.txt
"""
SESTATUS = r"""cat > /srv/lab/se/sestatus.txt <<'EOF'
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
EOF
"""
LSZ = r"""cat > /srv/lab/se/ls-lZ.txt <<'EOF'
total 12
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 120 Nov 19 10:00 index.html
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0  80 Nov 19 10:00 about.html
-rw-r--r--. 1 root root unconfined_u:object_r:user_home_t:s0        300 Nov 19 10:02 report.html
-rw-r--r--. 1 root root unconfined_u:object_r:user_tmp_t:s0        4096 Nov 19 10:03 logo.png
EOF
"""
AUDIT = r"""cat > /srv/lab/se/audit.log <<'EOF'
type=AVC msg=audit(1763546400.101:301): avc:  denied  { read } for  pid=2210 comm="httpd" name="report.html" dev="vda1" ino=262500 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=0
type=SYSCALL msg=audit(1763546400.101:301): arch=c000003e syscall=257 success=no exit=-13 a0=ffffff9c a1=7f2c a2=0 a3=0 items=0 ppid=1 pid=2210 auid=4294967295 uid=48 gid=48 euid=48 suid=48 fsuid=48 egid=48 sgid=48 fsgid=48 tty=(none) ses=4294967295 comm="httpd" exe="/usr/sbin/httpd" subj=system_u:system_r:httpd_t:s0 key=(null)
type=USER_LOGIN msg=audit(1763546460.001:302): pid=2300 uid=0 auid=1000 ses=3 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=login id=1000 exe="/usr/sbin/sshd" hostname=? addr=192.0.2.10 terminal=ssh res=success'
type=AVC msg=audit(1763546520.455:303): avc:  denied  { name_bind } for  pid=2411 comm="nginx" src=8888 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=AVC msg=audit(1763546580.700:304): avc:  denied  { read } for  pid=2210 comm="httpd" name="logo.png" dev="vda1" ino=262501 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:user_tmp_t:s0 tclass=file permissive=0
EOF
"""
SETLINES = lambda f: f"tr -s ' \\n' '\\n' < {f} | grep -v '^$' | sort | tr '\\n' ' '"

b = SetBuilder(540, '방화벽과 SELinux 읽기: 허용 포트·컨텍스트·거부 로그',
               '서비스가 떴는데 접속이 안 될 때 먼저 보는 두 곳, firewalld 와 SELinux 의 출력을 읽는 법을 익힙니다. `firewall-cmd --list-all` 에서 존·서비스·포트를 뽑고, runtime 과 permanent 의 차이로 사라진 포트를 찾고, `getenforce`·`sestatus` 로 모드를, `ls -Z` 로 컨텍스트를, 감사 로그의 AVC 한 줄로 거부 원인을 읽습니다. 샌드박스에는 방화벽·SELinux 가 동작하지 않아 실제 명령 출력과 같은 모양의 샘플 파일을 `grep`·`awk` 로 읽습니다.',
               'linux-systemd', '리눅스', 59, 761, '🧱',
               [{"title": "Red Hat: firewalld 사용", "url": "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_networking/using-and-configuring-firewalld_configuring-and-managing-networking"},
                {"title": "Red Hat: SELinux 사용", "url": "https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/using_selinux/index"}], 3)

# 1 -------------------------------------------------------------
b.nt('firewall-cmd --list-all 읽기: 존과 허용 서비스', 'Rocky 서버에서 `firewall-cmd --list-all` 을 실행한 결과가 `/srv/lab/fw/list-all.txt` 에 저장돼 있습니다. (샌드박스에는 방화벽이 돌지 않아 출력 파일을 읽습니다.)\n\nfirewalld 는 네트워크 인터페이스를 **존(zone)** 에 묶고, 존마다 "어떤 서비스·포트를 들여보낼지"를 정합니다. 첫 줄 `public (active)` 가 지금 쓰이는 존입니다. `services:` 줄은 이름으로 허용한 서비스(`ssh` 는 22번 포트 묶음)입니다.\n\n허용된 **서비스 이름**을 한 줄에 하나씩 `/tmp/services.txt` 에 저장하세요.',
     '`services:` 줄에서 서비스 이름만 골라 한 줄에 하나씩 되도록 가공하세요. 비슷한 이름의 줄(`source-ports:` 등)에 주의하세요.',
     "cat /srv/lab/fw/list-all.txt\ngrep '^  services:' /srv/lab/fw/list-all.txt | cut -d: -f2 | tr -s ' ' '\\n' | grep -v '^$' > /tmp/services.txt\ncat /tmp/services.txt   # cockpit, dhcpv6-client, ssh",
     CLEAN + "; " + LISTALL,
     [chk('서비스 이름 3개가 정확히 저장돼 있다', '[ "$(' + SETLINES('/tmp/services.txt') + ')" = "cockpit dhcpv6-client ssh " ]')])
# 2 -------------------------------------------------------------
b.choice('runtime 과 permanent', '`firewall-cmd --add-port=9090/tcp` 로 포트를 열었더니 바로 접속이 됐습니다. 그런데 `firewall-cmd --reload`(또는 서버 재부팅) 뒤에는 다시 접속되지 않습니다. 가장 알맞은 원인은 무엇일까요?',
         'firewalld 에는 "지금 돌고 있는 설정"과 "디스크에 저장된 설정" 두 벌이 있습니다. 옵션 하나가 빠졌습니다.',
         ['`--permanent` 없이 실행해 runtime(지금 동작 중인) 설정에만 들어갔고, reload 가 저장된 설정으로 덮어썼다', '9090 은 시스템 예약 포트라 열 수 없다', '`--add-port` 는 원래 UDP 만 연다', 'reload 는 존 이름을 바꾼다'], 0,
         '`--permanent` 가 없으면 **runtime** 설정만 바뀌어 즉시 적용되지만 reload·재부팅 때 사라집니다. 반대로 `--permanent` 만 쓰면 저장만 되고 **지금은 적용되지 않아서** `firewall-cmd --reload` 로 읽어 들여야 합니다. 안전한 습관은 `--permanent` 로 저장 → `--reload` 로 적용 → `--list-all` 로 확인입니다. 포트 번호 9090 은 일반 포트이고 `/tcp` 를 붙였으니 TCP 입니다.')
# 3 -------------------------------------------------------------
b.nt('reload 하면 사라질 포트 찾기', '운영 중인 서버에서 두 명령의 결과를 파일로 남겼습니다.\n- `/srv/lab/fw/runtime-ports.txt` : `firewall-cmd --list-ports` (지금 열려 있는 포트)\n- `/srv/lab/fw/permanent-ports.txt` : `firewall-cmd --permanent --list-ports` (저장된 설정의 포트)\n\n**runtime 에는 있는데 permanent 에는 없는 포트**는 reload 하면 닫힙니다. 그런 포트를 한 줄에 하나씩 `/tmp/lost.txt` 에 저장하세요. (permanent 에만 있는 포트는 아직 적용 전이라 해당하지 않습니다.)',
     '두 목록을 한 줄에 하나씩 풀어 놓고, 한쪽에만 있는 항목을 가려내세요. 예를 들어 `for p in $(cat 파일)`; `grep -qx` 로 한 줄씩 비교하는 방법도 됩니다.',
     "cat /srv/lab/fw/runtime-ports.txt /srv/lab/fw/permanent-ports.txt\ntr ' ' '\\n' < /srv/lab/fw/runtime-ports.txt > /tmp/r.txt\ntr ' ' '\\n' < /srv/lab/fw/permanent-ports.txt > /tmp/p.txt\ngrep -vxFf /tmp/p.txt /tmp/r.txt > /tmp/lost.txt   # 9090/tcp 만 남는다\ncat /tmp/lost.txt",
     CLEAN + "; " + PORTS,
     [chk('reload 로 사라질 포트가 9090/tcp 하나다', '[ "$(' + SETLINES('/tmp/lost.txt') + ')" = "9090/tcp " ]')])
# 4 -------------------------------------------------------------
b.fill('저장한 설정을 지금 적용하기', '`firewall-cmd --permanent --add-port=8080/tcp` 로 포트를 **저장**했습니다. 아직 실행 중인 방화벽에는 반영되지 않았습니다. 저장된 설정을 읽어 지금 적용하는 명령의 빈칸을 채우세요.',
       '"다시 읽기"를 뜻하는 영어 단어입니다. 상태만 보여 주는 옵션은 적용하지 않습니다.',
       'firewall-cmd --{0}', ['reload', 'state', 'list-ports', 'get-default-zone'], [0],
       '`--reload` 는 저장된(permanent) 설정을 읽어 runtime 에 적용합니다. 연결된 세션은 유지됩니다. `--state` 는 방화벽이 도는지, `--list-ports` 는 열린 포트를, `--get-default-zone` 은 기본 존 이름을 보여 줄 뿐 설정을 적용하지 않습니다.')
# 5 -------------------------------------------------------------
b.choice('ufw·iptables 문서를 firewalld 로 옮기기', 'Ubuntu 용 가이드에 `ufw allow 8080/tcp` 라고 적혀 있습니다. Rocky(firewalld)에서 **재부팅 뒤에도 유지되게** 같은 일을 하는 올바른 명령 흐름은 무엇일까요?',
         'ufw 도 iptables 도 결국 커널의 패킷 필터를 다루는 도구입니다. Rocky 에서는 그 앞의 관리 도구가 firewalld 입니다.',
         ['`firewall-cmd --permanent --add-port=8080/tcp` 실행 후 `firewall-cmd --reload`', '`firewall-cmd --list-ports` 만 실행한다', '`getenforce 8080/tcp` 를 실행한다', '`iptables -L 8080` 을 실행한다'], 0,
         '`ufw`(Ubuntu), `firewall-cmd`(Rocky·RHEL 계열)는 모두 **규칙을 쉽게 쓰게 해 주는 관리 도구**이고, 바닥에서는 커널 필터(iptables/nftables)가 일합니다. 한 서버에서 firewalld 와 `iptables -A` 를 섞어 쓰면 서로의 규칙을 덮거나 어긋나므로 firewalld 를 쓰는 서버에서는 `firewall-cmd` 로 통일합니다. `--list-ports` 는 조회, `getenforce` 는 SELinux 모드 조회, `iptables -L` 은 포트 번호가 아니라 체인 목록을 봅니다.')
# 6 -------------------------------------------------------------
b.choice('setenforce 0 의 정체', '접속이 안 되는 원인이 SELinux 인지 가려내려고 `setenforce 0` 을 했더니 서비스가 정상 동작했고, `/var/log/audit/audit.log` 에는 AVC 줄이 계속 쌓입니다. 이 상태를 가장 정확히 설명한 것은 무엇일까요?',
         'SELinux 모드는 세 가지(Enforcing·Permissive·Disabled)입니다. 막는지, 기록하는지, 아예 끄는지를 구분해 보세요.',
         ['Permissive 로 바뀐 것이다. 정책 위반을 막지 않고 기록만 하며, 재부팅하면 `/etc/selinux/config` 의 값으로 돌아간다', 'Disabled 로 바뀐 것이다. SELinux 가 완전히 꺼져 로그도 남지 않는다', 'Enforcing 이 더 강해진 것이다', '문제가 해결된 것이므로 그대로 영구 설정해도 안전하다'], 0,
         'Enforcing 은 위반을 **막고 기록**, Permissive 는 **기록만**, Disabled 는 꺼짐입니다. `setenforce 0/1` 은 Permissive/Enforcing 을 임시 전환하며 재부팅하면 설정 파일 값으로 돌아갑니다(Disabled 로의 전환은 설정 파일 수정 후 재부팅이 필요). Permissive 에서 되는데 Enforcing 에서 안 되면 SELinux 가 원인이라는 **진단용**이지, 그대로 두는 해법이 아닙니다.')
# 7 -------------------------------------------------------------
b.nt('sestatus 읽기: 지금 모드와 설정 파일 모드', '`/srv/lab/se/sestatus.txt` 는 서버의 `sestatus` 출력입니다. `getenforce` 는 **현재 모드**만 한 단어(`Enforcing`)로 알려 주고, `sestatus` 는 설정 파일의 모드까지 함께 보여 줍니다.\n\n이 서버의 현재 모드를 `/tmp/current.txt` 에, 설정 파일에 적힌 모드를 `/tmp/config.txt` 에 각각 한 단어(소문자 그대로)로 저장하세요. 두 값이 왜 다른지 생각해 보세요.',
       '"Current mode:" 와 "Mode from config file:" 줄이 각각 있습니다. `awk` 로 마지막 칸(`$NF`)을 출력하면 값만 얻습니다.',
       "cat /srv/lab/se/sestatus.txt\nawk '/^Current mode/ {print $NF}' /srv/lab/se/sestatus.txt > /tmp/current.txt\nawk '/^Mode from config file/ {print $NF}' /srv/lab/se/sestatus.txt > /tmp/config.txt\n# 현재 permissive, 설정 enforcing: 누군가 setenforce 0 으로 임시 전환했다. 재부팅하면 enforcing 으로 돌아간다.",
       CLEAN + "; " + SESTATUS,
       [chk('현재 모드가 permissive 다', '[ "$(tr -d " \\n" < /tmp/current.txt)" = permissive ]'),
        chk('설정 파일 모드가 enforcing 이다', '[ "$(tr -d " \\n" < /tmp/config.txt)" = enforcing ]')])
# 8 -------------------------------------------------------------
b.nt('ls -Z 컨텍스트 읽기: 라벨이 다른 파일', '웹 서버(httpd)가 서비스하는 디렉터리에서 `ls -lZ` 를 실행한 결과가 `/srv/lab/se/ls-lZ.txt` 에 있습니다. 파일마다 `사용자:역할:타입:레벨` 형태의 **SELinux 컨텍스트**가 붙고, 그중 세 번째 **타입**이 접근 허용 여부를 정합니다. 웹 서버가 읽도록 허용된 타입은 `httpd_sys_content_t` 입니다. (모드 문자열 끝의 `.` 은 SELinux 컨텍스트가 있다는 표시입니다.)\n\n타입이 `httpd_sys_content_t` 가 **아닌** 파일의 이름을 한 줄에 하나씩 `/tmp/wrong.txt` 에 저장하세요.',
       '컨텍스트가 적힌 칸과 파일 이름이 적힌 칸을 찾아, 타입 부분이 기준과 다른 줄만 고르세요. 첫 줄 `total` 은 대상이 아닙니다.',
       "cat /srv/lab/se/ls-lZ.txt\nawk 'NR>1 && $5 !~ /httpd_sys_content_t/ {print $10}' /srv/lab/se/ls-lZ.txt > /tmp/wrong.txt\ncat /tmp/wrong.txt   # logo.png, report.html\n# user_home_t(홈에서 mv 한 파일), user_tmp_t(/tmp 에서 옮긴 파일)는 원래 위치의 라벨을 그대로 가져온 것",
       CLEAN + "; " + LSZ,
       [chk('라벨이 다른 파일 두 개가 저장돼 있다', '[ "$(' + SETLINES('/tmp/wrong.txt') + ')" = "logo.png report.html " ]')])
# 9 -------------------------------------------------------------
b.nt('감사 로그에서 거부된 프로세스 찾기', 'SELinux 거부는 `/var/log/audit/audit.log` 에 기록됩니다(`ausearch -m avc` 가 같은 줄을 뽑아 줍니다). 샘플이 `/srv/lab/se/audit.log` 에 있습니다. `type=AVC` 줄의 `denied` 는 정책이 막았다는 뜻이고, `comm="..."` 은 막힌 **프로세스 이름**입니다. 로그에는 `SYSCALL`·`USER_LOGIN` 같은 다른 종류의 줄도 섞여 있습니다.\n\n**거부(denied)된 AVC 줄에 나온 프로세스 이름**을 중복 없이 한 줄에 하나씩 `/tmp/denied.txt` 에 저장하세요. (따옴표는 빼고)',
       '먼저 거부(denied)된 줄만 고른 뒤, 그 줄에서 프로세스 이름이 적힌 부분만 뽑으세요. 같은 이름이 여러 번 나오면 한 번만 남깁니다.',
       "grep denied /srv/lab/se/audit.log\ngrep denied /srv/lab/se/audit.log | grep -o 'comm=\"[^\"]*\"' | cut -d'\"' -f2 | sort -u > /tmp/denied.txt\ncat /tmp/denied.txt   # httpd, nginx\n# SYSCALL 줄의 comm 은 denied 줄이 아니므로 제외된다",
       CLEAN + "; " + AUDIT,
       [chk('거부된 프로세스가 httpd, nginx 두 개다', '[ "$(' + SETLINES('/tmp/denied.txt') + ')" = "httpd nginx " ]')])
# 10 ------------------------------------------------------------
b.choice('AVC 한 줄 해석하고 고치는 방향 정하기', '감사 로그에 다음 줄이 찍혔습니다.\n\n`avc:  denied  { read } for  pid=2210 comm="httpd" name="report.html" scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=0`\n\n`scontext` 는 **행동하는 쪽(프로세스)**, `tcontext` 는 **당하는 쪽(파일)** 의 컨텍스트입니다. 가장 알맞은 해석과 조치는 무엇일까요?',
         '`{ read }` 가 거부된 동작, `tclass=file` 이 대상 종류입니다. 두 컨텍스트의 타입 부분(세 번째 칸)을 비교해 보세요.',
         ['httpd_t 프로세스가 user_home_t 라벨 파일을 읽으려다 막혔다. 파일이 웹 콘텐츠 위치에 맞는 라벨이 아니므로 `restorecon -Rv 경로` 로 기본 라벨을 복원한다', '파일 모드가 낮아서 막혔으므로 `chmod 777` 로 연다', 'httpd 계정이 없어서 막혔으므로 계정을 만든다', 'SELinux 가 고장 났으므로 `/etc/selinux/config` 를 `disabled` 로 영구 변경한다'], 0,
         '`permissive=0` 은 실제로 **막았다**는 뜻이고(`1` 이면 기록만), 타입 불일치(`httpd_t` 가 `user_home_t` 를 읽기)가 원인입니다. 홈 디렉터리 등에서 `mv` 한 파일은 원래 위치의 라벨을 들고 와서 이런 일이 생깁니다. `restorecon -Rv /경로` 는 정책에 정의된 그 위치의 기본 라벨로 되돌리고, `ls -Z` 로 확인합니다. 새 위치를 영구히 지정할 때는 `semanage fcontext` 로 규칙을 추가한 뒤 `restorecon` 합니다. `chmod` 는 SELinux 판정을 바꾸지 못하고, SELinux 를 끄는 것은 해결이 아니라 보호 해제입니다.')
# 11 ------------------------------------------------------------
b.choice('파일 라벨이 아니라 boolean 일 때', '웹 애플리케이션(httpd)이 외부 DB 서버(3306 포트)에 연결하지 못합니다. 감사 로그는 `avc:  denied  { name_connect } for  comm="httpd" ... scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:mysqld_port_t:s0 tclass=tcp_socket permissive=0` 입니다. 거부된 대상은 파일이 아니라 **네트워크 포트**입니다. 알맞은 조치는 무엇일까요?',
         '파일 라벨을 고치는 문제가 아닙니다. SELinux 정책에는 기능 단위로 켜고 끄는 스위치가 있고, `getsebool -a | grep httpd` 로 목록을 볼 수 있습니다.',
         ['`setsebool -P httpd_can_network_connect_db on` 으로 정책 스위치(boolean)를 켠다. `-P` 로 재부팅 후에도 유지된다', '`restorecon -Rv /var/www/html` 로 웹 파일 라벨을 복원한다', '`setenforce 0` 으로 두고 그대로 운영한다', '`chmod 777 /var/www/html` 로 연다'], 0,
         'SELinux 에는 파일 라벨 외에 **boolean** 이라는 정책 스위치가 있어, 웹 서버의 DB 접속 같은 흔한 허용을 켜고 끕니다. `getsebool 이름` 으로 현재 값을, `setsebool 이름 on` 으로 임시 변경, `-P` 를 붙이면 영구 저장입니다. AVC 의 `tclass` 가 `file` 이면 라벨(restorecon), `tcp_socket`·`name_connect`/`name_bind` 이면 boolean 또는 포트 라벨(`semanage port`)을 먼저 의심합니다.')
# 12 ------------------------------------------------------------
b.order('SELinux 때문인지 의심될 때 점검 순서', '서비스가 파일을 못 읽고 `Permission denied` 가 나는데, 소유자·모드는 올바릅니다. SELinux 를 의심할 때의 알맞은 순서로 카드를 놓으세요. (먼저 SELinux 가 막는 상태인지 확인하고, 감사 로그로 무엇이 막혔는지 읽은 **다음에** 대상 파일의 라벨을 확인해 고칩니다. 고친 뒤 서비스를 다시 시도합니다)',
        '각 카드가 증거를 모으는 일인지, 대상을 확인하는 일인지, 고치는 일인지 구분해 보세요. 증거 없이 고치기부터 하지 않습니다.',
        ['`ls -Z` 로 대상 파일의 타입이 서비스가 기대하는 타입과 다른지 비교한다', '서비스를 다시 시도해 접근이 되는지 확인한다', '`getenforce` 로 SELinux 가 Enforcing 인지 확인한다', '`restorecon -Rv 경로` 로 기본 컨텍스트를 복원한다', '`audit.log` 에서 `denied` AVC 줄을 찾아 프로세스·파일·타입을 읽는다'], [2, 4, 0, 3, 1],
        'Enforcing 인지 확인(`getenforce`) → 감사 로그의 `denied` 줄로 막힌 프로세스·대상·타입 읽기 → `ls -Z` 로 라벨 비교 → `restorecon` 으로 복원 → 서비스 재시도로 확인합니다. 로그를 읽기 전에 `restorecon` 부터 돌리면 원인이 라벨이 아닐 때(boolean·포트 라벨) 시간만 쓰게 됩니다.')

if __name__ == '__main__':
    preview(b)
