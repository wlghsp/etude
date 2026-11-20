import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 611: Open vSwitch 입문. 명세: docs/specs/spec_gap_set611.md
# 샌드박스 linux(OVS·libvirt 없음). ovs-vsctl show 출력은 샘플로 읽고, 명령은 파일에 적고, NIC XML 은 일반 파일로 실제로 고친다.

S111 = """rm -f /tmp/*.txt /tmp/*.log /tmp/*.xml
cat > /tmp/ovs_show.log <<'EOF'
    00000000-0000-0000-0000-000000000000
    Bridge br-int
        Port vnet0
            Interface vnet0
        Port vnet1
            tag: 100
            Interface vnet1
        Port br-int
            Interface br-int
                type: internal
    Bridge br-ex
        Port eth1
            Interface eth1
        Port br-ex
            Interface br-ex
                type: internal
    ovs_version: "2.17.9"
EOF
cat > /tmp/vm_net.xml <<'EOF'
    <interface type='bridge'>
      <source bridge='br0'/>
      <model type='virtio'/>
    </interface>
EOF
true"""

b = SetBuilder(611, 'Open vSwitch 입문: 리눅스 브리지와 차이, 브리지·포트·VLAN 태그, VM 을 OVS 에 붙이기',
               'OpenStack 같은 사설 클라우드는 가상 스위치로 Open vSwitch(OVS)를 씁니다. ovs-vsctl show 출력에서 브리지와 VLAN 태그가 붙은 포트를 읽고, 브리지 만들기와 포트 추가, VLAN 태그 지정 명령을 적고, VM 의 NIC XML 을 OVS 브리지에 붙도록 고치고, 리눅스 브리지와의 차이를 정리합니다. 샌드박스에는 OVS 가 없어 명령은 파일에 적고 출력은 샘플로 읽습니다.',
               'linux', '가상화', 72, 871, '🔌',
               [{"title": "Open vSwitch 문서", "url": "https://docs.openvswitch.org/en/latest/"}, {"title": "libvirt 와 OVS", "url": "https://libvirt.org/formatdomain.html#bridge-to-lan"}], 11)

b.nt('VLAN 태그가 붙은 포트', '`/tmp/ovs_show.log` 는 `ovs-vsctl show` 의 출력입니다. 포트 아래에 `tag: 100` 처럼 VLAN 태그가 지정된 포트가 있습니다. **VLAN 태그가 지정된 포트의 이름**을 `/tmp/tagged.txt` 에 저장하세요. (이름만)',
     '`tag:` 줄은 자신이 속한 포트 줄의 바로 아래에 있습니다. 그 위의 포트 줄을 찾으세요.',
     "cat /tmp/ovs_show.log\nawk '$1==\"Port\" {p=$2} $1==\"tag:\" {print p}' /tmp/ovs_show.log > /tmp/tagged.txt\ncat /tmp/tagged.txt\n\n# 같은 브리지의 포트라도 태그가 다르면 서로 L2 로 통신하지 못한다. 태그가 없는 포트는 trunk 나 untagged 로 동작한다",
     S111, [chk('vnet1 이다', '[ "$(cat /tmp/tagged.txt)" = vnet1 ]')])
b.nt('브리지 이름 모으기', '같은 출력에서 **브리지의 이름**을 이름순으로 한 줄에 하나씩 `/tmp/bridges.txt` 에 저장하세요. (이름만)',
     '브리지 줄은 첫 칸이 `Bridge` 입니다.',
     "awk '$1==\"Bridge\" {print $2}' /tmp/ovs_show.log | sort > /tmp/bridges.txt\ncat /tmp/bridges.txt\n\n# br-int 는 VM 포트가 모이는 통합 브리지, br-ex 는 물리 NIC(eth1)로 외부와 이어지는 브리지다(OpenStack 의 관례)",
     S111, [chk('br-ex, br-int 이다', '[ "$(tr "\\n" " " < /tmp/bridges.txt | xargs)" = "br-ex br-int" ]')])
b.nt('브리지 만들고 포트 넣기', 'OVS 브리지 `br0` 를 만들고, 물리 NIC `eth1` 을 그 브리지의 포트로 추가하는 `ovs-vsctl` 명령 두 줄을 `/tmp/ovs_cmds.txt` 에 한 줄에 하나씩 적으세요. (실행하지 않습니다. 줄 순서는 브리지가 먼저여야 합니다)',
     '브리지 만들기와 포트 추가는 각각 `add-` 로 시작하는 하위 명령입니다.',
     "printf '%s\\n' 'ovs-vsctl add-br br0' 'ovs-vsctl add-port br0 eth1' > /tmp/ovs_cmds.txt\ncat /tmp/ovs_cmds.txt\n\n# ip link 로 만든 브리지와 달리 ovsdb 에 저장돼 재부팅 뒤에도 유지된다. 단 서버로 접속 중인 NIC 를 포트로 넣으면 IP 가 사라져 접속이 끊길 수 있다",
     S111, [chk('브리지를 만든다', 'grep -Eq "^[[:space:]]*(sudo )?ovs-vsctl( --may-exist)? add-br br0[[:space:]]*$" /tmp/ovs_cmds.txt'), chk('eth1 을 포트로 넣는다', 'grep -Eq "^[[:space:]]*(sudo )?ovs-vsctl( --may-exist)? add-port br0 eth1[[:space:]]*$" /tmp/ovs_cmds.txt'), chk('브리지가 먼저다', '[ "$(grep -n add-br /tmp/ovs_cmds.txt | head -1 | cut -d: -f1)" -lt "$(grep -n add-port /tmp/ovs_cmds.txt | head -1 | cut -d: -f1)" ]')])
b.nt('포트에 VLAN 태그 지정', '이미 있는 포트 `vnet0` 을 VLAN `200` 에 속하게 하는 `ovs-vsctl` 명령 한 줄을 `/tmp/vlan.txt` 에 적으세요.',
     '포트의 속성을 바꾸는 하위 명령이 있습니다. 대상 종류, 이름, `이름=값` 형태로 지정합니다.',
     "echo 'ovs-vsctl set port vnet0 tag=200' > /tmp/vlan.txt\ncat /tmp/vlan.txt\n\n# 태그 200 인 포트끼리만 서로 통신한다. 태그를 지우려면 ovs-vsctl remove port vnet0 tag 200 로 지운다",
     S111, [chk('vnet0 에 tag=200 을 건다', 'grep -Eq "^[[:space:]]*(sudo )?ovs-vsctl set (Port|port) vnet0 tag=200[[:space:]]*$" /tmp/vlan.txt')])
b.nt('VM 의 NIC 를 OVS 로', '`/tmp/vm_net.xml` 은 지금 리눅스 브리지 `br0` 를 쓰는 VM 의 `<interface>` 입니다. libvirt 가 이 NIC 를 **OVS 포트로 만들도록** `<source>` 줄 바로 아래에 NIC 가 붙는 스위치 종류를 `openvswitch` 로 지정하는 줄을 추가하세요. (기존 줄은 그대로)',
     'NIC 가 붙는 가상 스위치의 종류를 알려 주는 요소가 있습니다. 도메인 XML 문서의 `<interface>` 절에서 찾아 보세요.',
     "sed -i \"/<source bridge='br0'\\/>/a\\\\      <virtualport type='openvswitch'/>\" /tmp/vm_net.xml\ncat /tmp/vm_net.xml\n\n# br0 는 OVS 브리지여야 한다. virtualport 가 없으면 libvirt 가 리눅스 브리지로 보고 brctl 방식으로 붙인다",
     S111, [chk('virtualport 가 openvswitch 다', 'grep -Eq "<virtualport type=.openvswitch.\\s*/>" /tmp/vm_net.xml'), chk('source 가 br0 로 남았다', 'grep -Eq "<source bridge=.br0.\\s*/>" /tmp/vm_net.xml'), chk('virtualport 가 source 뒤에 있다', '[ "$(grep -n "<virtualport" /tmp/vm_net.xml | head -1 | cut -d: -f1)" -gt "$(grep -n "<source" /tmp/vm_net.xml | head -1 | cut -d: -f1)" ]'), chk('virtio 모델이 유지됐다', 'grep -Eq "<model type=.virtio.\\s*/>" /tmp/vm_net.xml')])
b.choice('리눅스 브리지와의 차이', 'OVS 를 리눅스 브리지 대신 쓰는 가장 큰 이유로 알맞은 것은?', '포트별 VLAN 과 터널, 외부에서 제어하는 규칙이 필요한 환경을 떠올려 보세요.',
         ['VLAN 태그, VXLAN·GRE 터널, 플로우 규칙 제어를 지원한다', '리눅스 브리지보다 설정이 언제나 훨씬 더 단순하다', '커널 모듈이 필요 없어서 별도 설치 없이 어디서나 동작한다', 'VM 간 통신 속도가 어떤 경우에도 두 배로 빨라진다'], 0,
         'OVS 는 프로그램 가능한 가상 스위치로 VLAN, VXLAN·GRE 터널, OpenFlow 규칙을 지원해 대규모 클라우드에 쓰입니다. 설정은 오히려 복잡하고, 소규모에서는 리눅스 브리지로 충분합니다.')
b.choice('br-int 와 br-ex', 'OpenStack 컴퓨트·네트워크 노드의 OVS 에서 `br-int` 와 `br-ex` 의 관례적 역할로 알맞은 것은?', '하나는 VM 쪽 포트가 모이는 안쪽, 다른 하나는 물리 NIC 와 이어지는 바깥쪽입니다.',
         ['br-int 는 VM 포트가 모이고 br-ex 는 물리 NIC 로 외부와 이어진다', 'br-int 는 외부 인터넷용이고 br-ex 는 VM 내부 통신용이다', '둘은 같은 역할이라 브리지를 하나만 만들어도 충분하다', 'br-int 는 데이터베이스용이고 br-ex 는 로그 저장용이다'], 0,
         '관례상 br-int 는 인스턴스(VM)의 포트가 붙는 통합 브리지이고, br-ex 는 물리 NIC 를 포트로 넣어 외부 네트워크와 연결합니다. 둘은 패치 포트로 이어집니다.')
b.choice('설정 유지', '`ovs-vsctl add-br br0` 로 만든 OVS 브리지와 `ip link add br0 type bridge` 로 만든 리눅스 브리지 중, 재부팅 뒤에도 별도 설정 없이 남는 쪽은?', 'OVS 는 설정을 자기 데이터베이스에 저장합니다.',
         ['OVS 브리지만 ovsdb 에 저장돼 남는다', '둘 다 재부팅해도 그대로 남아 있게 된다', '둘 다 재부팅하면 모두 사라지게 된다', '리눅스 브리지만 남고 OVS 는 사라진다'], 0,
         'ovs-vsctl 의 설정은 ovsdb 에 저장되어 서비스가 다시 뜰 때 복원됩니다. ip link 로 만든 브리지는 커널 상태일 뿐이라 netplan 같은 영구 설정이 없으면 재부팅에 사라집니다.')
b.fill('OVS 브리지 만들기', '`br0` 라는 OVS 브리지를 만드는 `ovs-vsctl` 하위 명령의 이름을 채우세요.', '브리지를 추가한다는 뜻입니다.',
       'ovs-vsctl {0} br0', ['add-br', 'add-port', 'del-br', 'list-br'], [0],
       '`add-br` 는 브리지를 추가합니다. `add-port` 는 포트 추가, `del-br` 는 브리지 삭제, `list-br` 는 브리지 목록 출력입니다.')
b.order('OVS 에 물리 NIC 연결', 'OVS 서버에서 새 브리지에 물리 NIC 를 연결하고 결과까지 확인하려 합니다. 올바른 순서로 놓으세요.', '먼저 사용할 수 있는 상태인지 보고, 대상이 있어야 그 안에 넣을 수 있습니다.',
        ['구성 결과를 목록으로 확인한다', '브리지를 만든다', 'OVS 서비스가 동작하는지 확인한다', '물리 NIC 를 포트로 추가한다'], [2, 1, 3, 0],
        '서비스 상태를 확인하고, 브리지를 만들고, NIC 를 포트로 넣고, 마지막에 ovs-vsctl show 같은 명령으로 결과를 확인합니다.')

if __name__ == '__main__':
    preview(b)
