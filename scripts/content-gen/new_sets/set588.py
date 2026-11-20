import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 588: nftables·firewalld·conntrack 읽기. 명세: docs/specs/spec_gap_set588.md
# 샌드박스 linux(비특권, nft·firewall-cmd·conntrack 없음). 샘플 출력을 읽고 명령을 파일에 적는다.

S88 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/nft.log <<'EOF'
table inet filter {
        chain input {
                type filter hook input priority filter; policy drop;
                iif "lo" accept
                ct state established,related accept
                tcp dport 22 accept
                tcp dport { 80, 443 } accept
                ip saddr 198.51.100.7 drop
        }
        chain forward {
                type filter hook forward priority filter; policy drop;
        }
}
EOF
cat > /tmp/firewalld.log <<'EOF'
public (active)
  target: default
  interfaces: eth0
  services: dhcpv6-client http ssh
  ports: 8080/tcp 5432/tcp
  masquerade: no
EOF
cat > /tmp/ct.log <<'EOF'
net.netfilter.nf_conntrack_count = 65000
net.netfilter.nf_conntrack_max = 65536
EOF
true"""

b = SetBuilder(588, 'nftables·firewalld·conntrack 읽기: 규칙 목록, zone 과 영구 설정, 연결 추적 테이블',
               '배포판마다 다른 방화벽 도구를 읽는 연습입니다. nft list ruleset 에서 기본 정책과 허용 포트를, firewall-cmd 출력에서 zone 의 서비스와 포트를 읽고, 임시 설정과 영구 설정의 차이를 짚고, 연결 추적 테이블의 사용률을 계산합니다. 샌드박스에는 해당 도구가 없어 샘플 출력을 읽고 명령을 적는 방식입니다.',
               'linux', '네트워크', 47, 848, '🔥',
               [{"title": "nftables 위키", "url": "https://wiki.nftables.org/wiki-nftables/index.php/Main_Page"}, {"title": "firewalld 문서", "url": "https://firewalld.org/documentation/"}], 5)

# 1
b.nt('nftables 입력 체인의 기본 정책', '`/tmp/nft.log` 는 `nft list ruleset` 의 출력입니다. `chain input` 선언의 `policy` 는 어느 규칙에도 걸리지 않은 패킷의 기본 처리입니다. **input 체인의 기본 정책**(accept 나 drop)을 `/tmp/policy.txt` 에 저장하세요. (값만)',
     '체인 선언 줄에서 `policy` 다음 단어입니다. 체인이 둘이니 input 쪽을 고르세요.',
     "cat /tmp/nft.log\nawk '/chain input/{f=1} f && /policy/{print; exit}' /tmp/nft.log | grep -o 'policy [a-z]*' | cut -d' ' -f2 > /tmp/policy.txt\ncat /tmp/policy.txt\n\n# nftables 는 iptables 의 후속이며 테이블·체인·규칙 구조는 비슷하다. 기본 정책이 drop 이면 허용 규칙에 걸린 것만 들어온다",
     S88, [chk('drop 이다', '[ "$(cat /tmp/policy.txt)" = drop ]')])
# 2
b.nt('허용된 포트 모으기', '`/tmp/nft.log` 의 input 체인에서 **`accept` 로 허용하는 TCP 목적지 포트**를 모두 모아 **숫자 오름차순으로 한 줄에 하나씩** `/tmp/ports.txt` 에 저장하세요. (`{ 80, 443 }` 처럼 묶인 것도 풀어서)',
     '`tcp dport` 가 들어간 줄에서 포트 부분만 뽑고, 중괄호와 쉼표를 정리한 뒤 숫자 정렬하세요.',
     "grep 'tcp dport' /tmp/nft.log | grep accept | sed 's/.*dport//; s/accept//' | tr -d '{},' | tr -s ' ' '\\n' | grep -E '^[0-9]+$' | sort -n > /tmp/ports.txt\ncat /tmp/ports.txt\n\n# 22 80 443. 집합 표기 { 80, 443 } 가 한 규칙에 여러 포트를 묶는 nftables 의 장점이다",
     S88, [chk('22 80 443 이다', '[ "$(tr "\\n" " " < /tmp/ports.txt | xargs)" = "22 80 443" ]')])
# 3
b.nt('firewalld zone 읽기', '`/tmp/firewalld.log` 는 `firewall-cmd --list-all` 의 출력입니다. 현재 활성 zone `public` 에서 **열려 있는 포트**(`ports:` 줄, `번호/프로토콜` 형태)를 **한 줄에 하나씩** `/tmp/open_ports.txt` 에 저장하세요.',
     '`ports:` 줄에서 값만 남기고 공백을 줄바꿈으로 바꾸세요. `services:` 줄과 헷갈리지 마세요.',
     "cat /tmp/firewalld.log\ngrep '^  ports:' /tmp/firewalld.log | cut -d: -f2 | tr -s ' ' '\\n' | grep -v '^$' > /tmp/open_ports.txt\ncat /tmp/open_ports.txt\n\n# services 는 이름(ssh·http)으로 열고 ports 는 번호로 연다. 서비스 이름이 가리키는 포트는 /usr/lib/firewalld/services/ 에 정의돼 있다",
     S88, [chk('5432/tcp 와 8080/tcp 다', '[ "$(sort /tmp/open_ports.txt | tr "\\n" " " | xargs)" = "5432/tcp 8080/tcp" ]')])
# 4
b.nt('연결 추적 테이블 사용률', '`/tmp/ct.log` 는 연결 추적 테이블의 현재 항목 수(`nf_conntrack_count`)와 최대 항목 수(`nf_conntrack_max`)입니다. 테이블이 가득 차면 새 연결이 버려집니다. **사용률(%)** 을 **소수점 이하를 버린 정수**로 `/tmp/ct_pct.txt` 에 저장하세요.',
     '두 값을 뽑아 쉘 정수 산술로 계산하세요. 정수 나눗셈은 소수점을 버리니 나누기 전에 단위를 맞추세요.',
     "cat /tmp/ct.log\nC=$(grep count /tmp/ct.log | awk '{print $3}')\nM=$(grep max /tmp/ct.log | awk '{print $3}')\necho $((C * 100 / M)) > /tmp/ct_pct.txt\ncat /tmp/ct_pct.txt\n\n# 99%. 한계에 가까우면 nf_conntrack: table full, dropping packet 로그가 나오고 새 연결이 실패한다. 한도를 늘리거나 타임아웃을 줄인다",
     S88, [chk('99 다', '[ "$(cat /tmp/ct_pct.txt)" = 99 ]')])
# 5
b.nt('영구 설정으로 포트 열기', 'firewalld 에서 **8443/tcp** 를 **재부팅 후에도 유지되도록** 열려 합니다. 영구 설정은 바로 적용되지 않아 설정을 다시 읽어야 합니다. 샌드박스에는 firewalld 가 없으니 실행할 `firewall-cmd` 명령 **두 줄**(영구 설정, 다시 읽기)을 `/tmp/fw_fix.txt` 에 한 줄에 하나씩 적으세요.',
     '영구 설정을 붙이는 옵션이 있고, 설정을 디스크에서 다시 읽는 옵션이 따로 있습니다.',
     "printf '%s\\n' 'firewall-cmd --permanent --add-port=8443/tcp' 'firewall-cmd --reload' > /tmp/fw_fix.txt\ncat /tmp/fw_fix.txt\n\n# 옵션 없이 --add-port 만 하면 즉시 적용되지만 재부팅하면 사라진다(런타임). --permanent 는 저장만 하고 적용은 --reload 가 한다",
     S88, [chk('영구 포트 추가가 있다', 'grep -E "^[[:space:]]*(sudo )?firewall-cmd " /tmp/fw_fix.txt | grep -- "--permanent" | grep -Eq -- "--add-port[= ]8443/tcp([[:space:]]|$)"'), chk('reload 가 영구 설정 뒤에 있다', 'P=$(grep -n -- "--permanent" /tmp/fw_fix.txt | head -1 | cut -d: -f1); R=$(grep -nE -- "--reload" /tmp/fw_fix.txt | head -1 | cut -d: -f1); [ -n "$P" ] && [ -n "$R" ] && [ "$R" -gt "$P" ]')])
# 6
b.nt('nft 규칙 추가 명령 적기', '`inet` 패밀리의 `filter` 테이블 `input` 체인에 **TCP 3306 포트를 허용(accept)** 하는 규칙을 추가하는 `nft` 명령 한 줄을 `/tmp/nft_add.txt` 에 적으세요. (샌드박스에는 nft 가 없어 실행하지 않습니다)',
     '`nft add rule 패밀리 테이블 체인 규칙` 형태입니다. 체인에 이미 있는 허용 규칙의 모양을 참고하세요.',
     "echo 'nft add rule inet filter input tcp dport 3306 accept' > /tmp/nft_add.txt\ncat /tmp/nft_add.txt\n\n# add 는 체인 끝에, insert 는 맨 앞에 넣는다. 순서가 중요하니 앞의 drop 규칙보다 뒤에 오는지 확인한다. 영구 반영은 /etc/nftables.conf 에도 적는다",
     S88, [chk('nft 규칙 추가 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?nft .?(-a )?(add|insert) rule inet filter input .*tcp dport (3306|[{] *3306 *[}]) .*accept.?[[:space:]]*$" /tmp/nft_add.txt')])
# 7
b.choice('firewalld 의 임시와 영구', '`firewall-cmd --add-port=9000/tcp` 를 옵션 없이 실행했습니다. 서버를 재부팅한 뒤 이 포트는?', '옵션 없이 실행한 설정이 저장되는지 생각해 보세요.',
         ['런타임 설정이라 재부팅하면 사라진다', '자동으로 영구 저장되어 계속 열려 있다', '재부팅하면 모든 포트가 열린다', '재부팅 뒤 firewalld 가 삭제된다'], 0,
         'firewalld 는 런타임 설정과 영구 설정을 분리합니다. 옵션 없이 추가하면 즉시 적용되지만 저장되지 않아 재부팅이나 reload 로 사라집니다. 영구로 하려면 `--permanent` 를 붙이고 `--reload` 하거나, 런타임 설정을 `--runtime-to-permanent` 로 저장합니다.')
# 8
b.choice('연결 추적 테이블이 가득 찼을 때', '`nf_conntrack: table full, dropping packet` 로그가 나오고 새 연결이 간헐적으로 실패합니다. 가장 알맞은 해석과 대응은?', '추적 테이블은 연결마다 항목을 하나씩 씁니다.',
         ['항목이 한도에 도달해 새 연결이 버려지니 한도를 늘린다', '네트워크 카드가 고장 났으므로 새 카드로 교체한다', 'DNS 서버가 응답하지 않으므로 DNS 서버를 바꾼다', '디스크가 가득 찼으므로 오래된 로그를 지운다'], 0,
         'conntrack 은 NAT·상태 기반 방화벽을 위해 연결마다 항목을 만들고 한도(nf_conntrack_max)가 있습니다. 가득 차면 새 연결을 버려 간헐적 실패가 납니다. 한도를 늘리고, 불필요한 추적 제외(NOTRACK)나 타임아웃 조정으로 항목 수를 줄입니다.')
# 9
b.fill('규칙을 다시 읽기', 'firewalld 에서 `--permanent` 로 저장한 설정을 **현재 동작에 반영**하려면 어떤 옵션을 줘야 할까요? 빈칸을 채우세요.', '저장된 설정을 읽어 들여 적용하는 옵션입니다.',
       'firewall-cmd --{0}', ['reload', 'list-all', 'state', 'panic-on'], [0],
       '`--reload` 는 영구 설정을 다시 읽어 적용합니다(런타임 설정은 사라짐). `--list-all` 은 현재 설정 보기, `--state` 는 데몬 상태 확인, `--panic-on` 은 모든 트래픽 차단(비상용)입니다.')
# 10
b.order('원격 서버에서 firewalld 설정 바꾸기', 'SSH 로 접속한 서버에서 firewalld 에 새 포트를 영구로 열려 합니다. 접속이 끊기지 않고 결과를 확인하는 순서로 놓으세요.', '저장하는 것과 적용하는 것은 다른 단계입니다.',
        ['`--reload` 로 설정을 적용한다', '적용 뒤 `--list-all` 로 새 포트가 열렸는지 확인한다', '`--permanent --add-port` 로 영구 설정에 추가한다', '변경 전에 `--list-all` 로 현재 zone 의 상태를 기록해 둔다'], [3, 2, 0, 1],
        '변경 전 현재 상태를 보고, 영구 설정에 추가하고, reload 로 적용한 뒤, 목록에서 포트가 열렸는지 확인합니다. 22번(SSH)이 열려 있는 상태를 유지하며 변경해야 접속이 끊기지 않습니다.')

if __name__ == '__main__':
    preview(b)
