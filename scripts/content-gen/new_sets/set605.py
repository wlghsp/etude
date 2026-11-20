import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 605: 브리지 네트워크로 VM 연결하기. 명세: docs/specs/spec_gap_set605.md
# 샌드박스 linux(NET_ADMIN·libvirt 없음). 브리지 구성은 명령을 파일에 적고 출력 샘플을 읽으며, NIC 가 브리지를 쓰도록 바꾸는 XML 은 일반 파일로 실제로 고친다.

S105 = """rm -f /tmp/*.txt /tmp/*.log /tmp/*.xml
cat > /tmp/vm_net.xml <<'EOF'
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
EOF
cat > /tmp/bridge_link.log <<'EOF'
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 100
5: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 100
6: vnet1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 100
EOF
cat > /tmp/ip_addr.log <<'EOF'
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP
br0              UP             192.0.2.50/24
vnet0            UNKNOWN
vnet1            UNKNOWN
EOF
true"""

b = SetBuilder(605, '브리지 네트워크로 VM 연결하기: 포트 읽기, 브리지 만들기, 물리 NIC 편입의 위험, XML 의 bridge 타입',
               'VM 이 서버와 같은 네트워크 대역에 직접 붙으려면 리눅스 브리지를 씁니다. bridge link 출력에서 브리지에 연결된 포트를 읽고, 브리지를 만들고 포트를 편입하는 명령을 적고, 물리 NIC 를 브리지에 넣을 때 IP 가 브리지로 옮겨 가야 한다는 점과 원격 접속이 끊길 위험, libvirt 의 iface-begin·commit·rollback 으로 안전하게 하는 법, VM 의 NIC XML 을 bridge 타입으로 바꾸는 법을 다룹니다. 샌드박스에는 네트워크 설정 권한이 없어 명령은 파일에 적고 XML 은 일반 파일로 고칩니다.',
               'linux', '가상화', 72, 865, '🌉',
               [{"title": "libvirt 네트워크 설정", "url": "https://libvirt.org/formatdomain.html#network-interfaces"}, {"title": "bridge 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/bridge.8.html"}], 5)

b.nt('브리지에 연결된 포트', '`/tmp/bridge_link.log` 는 `bridge link` 의 출력입니다. `master br0` 가 붙은 장치가 브리지 `br0` 의 포트입니다. **포트 장치 이름을 이름순으로 한 줄에 하나씩** `/tmp/ports.txt` 에 저장하세요. (이름만)',
     '각 줄의 둘째 칸에서 콜론을 떼세요.',
     "cat /tmp/bridge_link.log\nawk '{print $2}' /tmp/bridge_link.log | tr -d ':' | sort > /tmp/ports.txt\ncat /tmp/ports.txt\n\n# eth0 은 물리 NIC, vnet0·vnet1 은 VM 의 가상 NIC(tap)다. 브리지는 이 포트들을 하나의 L2 네트워크로 묶는 가상 스위치다",
     S105, [chk('eth0 vnet0 vnet1 이다', '[ "$(tr "\\n" " " < /tmp/ports.txt | xargs)" = "eth0 vnet0 vnet1" ]')])
b.nt('IP 가 붙은 인터페이스', '`/tmp/ip_addr.log` 는 `ip -br addr` 의 출력입니다. 물리 NIC 를 브리지에 넣으면 **서버의 IP 주소는 브리지로 옮겨 가야** 합니다. 이 서버에서 **IPv4 주소(예: `192.0.2.50/24`)가 붙어 있는 인터페이스 이름**을 `/tmp/ip_if.txt` 에 저장하세요. (이름만)',
     '`UP` 이후 칸에 주소가 있는 줄을 찾으세요. 루프백 `lo` 는 제외합니다.',
     "cat /tmp/ip_addr.log\ngrep -E '[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/' /tmp/ip_addr.log | grep -v '^lo' | awk '{print $1}' > /tmp/ip_if.txt\ncat /tmp/ip_if.txt\n\n# eth0 은 포트가 되어 주소를 잃고 br0 가 주소를 가진다. 이 이동을 하지 않으면 서버가 네트워크에서 사라져 원격 접속이 끊긴다",
     S105, [chk('br0 다', '[ "$(cat /tmp/ip_if.txt)" = br0 ]')])
b.nt('브리지 만들기 명령', '`ip` 명령으로 브리지 `br0` 를 **만들고 올리는(up)** 명령 두 줄을 `/tmp/br_create.txt` 에 한 줄에 하나씩 적으세요. (샌드박스에는 네트워크 설정 권한이 없어 실행하지 않습니다)',
     '링크를 추가할 때 종류(`type`)를 지정합니다. 올리는 것은 별도의 명령입니다.',
     "printf '%s\\n' 'ip link add br0 type bridge' 'ip link set br0 up' > /tmp/br_create.txt\ncat /tmp/br_create.txt\n\n# 이렇게 만든 브리지는 재부팅하면 사라진다. 영구 설정은 netplan·NetworkManager 에 적는다",
     S105, [chk('브리지를 만든다', 'grep -Eq "^[[:space:]]*(sudo )?ip( -4)? link add( name)? br0 type bridge[[:space:]]*$" /tmp/br_create.txt'), chk('br0 를 올린다', 'grep -Eq "^[[:space:]]*(sudo )?ip( -4)? link set( dev)? br0 up( .*)?$|^[[:space:]]*(sudo )?ip( -4)? link set up( dev)? br0( .*)?$" /tmp/br_create.txt')])
b.nt('포트를 브리지에 넣기 명령', '관리용 접속과 무관한 **두 번째 물리 NIC `eth1`** 을 브리지 `br0` 의 포트로 넣는 `ip` 명령 한 줄을 `/tmp/br_port.txt` 에 적으세요.',
     '링크 하위 명령에서 장치의 마스터(상위 장치)를 정하는 옵션이 있습니다.',
     "echo 'ip link set eth1 master br0' > /tmp/br_port.txt\ncat /tmp/br_port.txt\n\n# 서버로 접속 중인 NIC(eth0)를 이렇게 바로 넣으면 IP 가 사라져 접속이 끊긴다. 먼저 콘솔이나 두 번째 NIC 로 접속한 상태에서 하거나 iface-bridge 로 되돌릴 수 있게 한다",
     S105, [chk('eth1 을 br0 의 포트로 넣는다', 'grep -Eq "^[[:space:]]*(sudo )?ip( -4)? link set( dev)? eth1 master br0( up)?[[:space:]]*$" /tmp/br_port.txt')])
b.nt('VM 의 NIC 를 브리지로', '`/tmp/vm_net.xml` 은 VM 의 `<interface>` 부분입니다. 지금은 libvirt 의 `default` 네트워크(NAT)를 씁니다. 이 VM 이 **브리지 `br0` 에 직접** 붙도록 `type` 을 `bridge` 로 바꾸고 `<source>` 가 브리지를 가리키게 고치세요. (`<model type=\'virtio\'/>` 는 그대로)',
     '`interface` 의 `type` 속성과 `source` 요소의 속성 이름이 둘 다 바뀝니다. 네트워크 이름이 아니라 브리지 이름을 적습니다.',
     "sed -i \"s:<interface type='network'>:<interface type='bridge'>:; s:<source network='default'/>:<source bridge='br0'/>:\" /tmp/vm_net.xml\ncat /tmp/vm_net.xml\n\n# 이렇게 하면 VM 이 호스트와 같은 대역의 IP 를 받는다(외부 DHCP). NAT(default)와 달리 외부에서 VM 으로 직접 접속할 수 있다",
     S105, [chk('interface 타입이 bridge 다', 'grep -q "<interface type=.bridge.>" /tmp/vm_net.xml'), chk('source 가 br0 를 가리킨다', 'grep -q "<source bridge=.br0.\\s*/>" /tmp/vm_net.xml'), chk('virtio 모델이 유지됐다', 'grep -q "<model type=.virtio.\\s*/>" /tmp/vm_net.xml'), chk('default 네트워크가 남지 않았다', '! grep -q "network=.default." /tmp/vm_net.xml')])
b.nt('안전하게 NIC 를 브리지에 편입', '원격(SSH)으로 접속한 서버의 `eth0` 를 브리지 `br0` 에 편입하려 합니다. libvirt 는 변경을 시험하고 **문제가 생기면 되돌릴 수 있게** 하는 기능이 있습니다. 순서대로 **변경 시작 → `eth0` 를 `br0` 에 브리지로 구성 → 변경 확정** 하는 `virsh` 명령 세 줄을 `/tmp/iface.txt` 에 한 줄에 하나씩 적으세요.',
     '`virsh` 의 인터페이스 관련 하위 명령은 `iface-` 로 시작합니다. 시작, 브리지 구성, 확정에 각각 해당하는 이름이 있습니다.',
     "printf '%s\\n' 'virsh iface-begin' 'virsh iface-bridge eth0 br0' 'virsh iface-commit' > /tmp/iface.txt\ncat /tmp/iface.txt\n\n# iface-begin 은 현재 설정의 복구점을 만든다. 확정(commit) 전에는 iface-rollback 으로 이전 설정으로 돌릴 수 있다. 단 netcf 기반 인터페이스 드라이버가 있는 환경에서만 동작하며 최신 배포판에서는 netplan·NetworkManager 로 같은 구성을 한다",
     S105, [chk('세 명령이 모두 있다', r'''grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? iface-begin[[:space:]]*$" /tmp/iface.txt && grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? iface-bridge( --[a-z-]+)* eth0 br0( --[a-z-]+)*[[:space:]]*$" /tmp/iface.txt && grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? iface-commit[[:space:]]*$" /tmp/iface.txt'''), chk('begin → bridge → commit 순서다', 'B=$(grep -n "iface-begin" /tmp/iface.txt | head -1 | cut -d: -f1); G=$(grep -n "iface-bridge" /tmp/iface.txt | head -1 | cut -d: -f1); C=$(grep -n "iface-commit" /tmp/iface.txt | head -1 | cut -d: -f1); [ -n "$B" ] && [ -n "$G" ] && [ -n "$C" ] && [ "$B" -lt "$G" ] && [ "$G" -lt "$C" ]')])
b.choice('NAT 와 브리지', 'libvirt 의 `default` 네트워크(NAT)에 붙은 VM 과 브리지에 붙은 VM 의 차이로 알맞은 것은?', 'VM 이 어느 대역의 주소를 받는지와 외부에서 보이는지 생각해 보세요.',
         ['NAT 는 가상 대역, 브리지는 서버와 같은 대역에 직접 붙는다', 'NAT 는 서버와 같은 대역에 붙고 브리지는 가상 대역을 쓴다', '두 방식 모두 VM 의 IP 가 서버와 항상 같다', '브리지에 붙은 VM 은 외부와 통신할 수 없다'], 0,
         'NAT(default, virbr0)는 VM 이 가상 사설 대역에서 호스트를 거쳐 나가므로 외부에서 접속하기 어렵습니다. 브리지는 VM 이 호스트와 같은 L2 에 붙어 외부 DHCP 에서 같은 대역 IP 를 받고 직접 접속됩니다.')
b.choice('물리 NIC 편입 때 IP', 'SSH 로 접속한 서버의 유일한 NIC `eth0`(IP 가 설정됨)를 설정 이동 없이 `ip link set eth0 master br0` 로 브리지에 넣었습니다. 결과로 알맞은 것은?', '브리지의 포트가 된 NIC 는 자체 L3 주소를 쓰지 않습니다.',
         ['eth0 의 IP 가 무의미해져 서버 접속이 끊긴다', '아무 영향 없이 접속이 그대로 유지된다', '서버가 자동으로 재부팅되면서 복구된다', 'SSH 접속이 오히려 두 배로 빨라진다'], 0,
         '브리지의 포트가 된 NIC 는 L2 스위치 포트처럼 동작해 자기 IP 로 통신하지 않습니다. IP 를 br0 로 옮기지 않으면 서버가 네트워크에서 사라져 원격 접속이 끊깁니다. 콘솔 접근이나 iface-begin 같은 안전장치가 필요합니다.')
b.fill('브리지 포트 상태 보기', '브리지에 연결된 포트 목록과 상태(forwarding 등)를 보는 `bridge` 명령의 대상 이름을 채우세요.', '링크 포트라는 뜻의 한 단어입니다.',
       'bridge {0}', ['link', 'fdb', 'vlan', 'mdb'], [0],
       '`bridge link` 는 브리지 포트와 상태를 보여 줍니다. `fdb` 는 MAC 주소 테이블, `vlan` 은 VLAN 설정, `mdb` 는 멀티캐스트 그룹 정보입니다.')
b.order('브리지 네트워크 구성', '서버에 브리지를 만들고 VM 이 그 브리지로 통신하게 하려 합니다. 올바른 순서로 놓으세요. (서버 쪽 네트워크 구성을 모두 마친 뒤 VM 설정을 바꿉니다)', '브리지가 있어야 포트를 넣을 수 있고, VM NIC 는 그 브리지를 가리킵니다.',
        ['VM 에서 외부와 통신하는지 확인한다', '브리지를 만들고 올린다', 'VM 의 NIC 를 bridge 타입으로 바꿔 br0 를 가리키게 한다', '물리 NIC 를 포트로 넣고 서버 IP 를 브리지로 옮긴다'], [1, 3, 2, 0],
        '브리지를 만들고, 물리 NIC 를 포트로 넣으며 IP 를 브리지로 옮기고, VM NIC 가 브리지를 쓰도록 바꾼 뒤, 마지막으로 VM 의 외부 통신을 확인합니다.')

if __name__ == '__main__':
    preview(b)
