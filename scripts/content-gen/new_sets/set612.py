import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 612: 가상 NIC 성능. 명세: docs/specs/spec_gap_set612.md
# 샌드박스 linux(libvirt·ethtool 설정 권한 없음). domiflist·ethtool -l 출력은 샘플로 읽고, 명령은 파일에 적고, NIC XML 은 일반 파일로 실제로 고친다.

S112 = """rm -f /tmp/*.txt /tmp/*.log /tmp/*.xml
cat > /tmp/domiflist.log <<'EOF'
 Interface   Type      Source    Model     MAC
-----------------------------------------------------------
 vnet0       bridge    br0       virtio    52:54:00:aa:00:01
 vnet1       bridge    br0       e1000     52:54:00:aa:00:02
 vnet2       network   default   rtl8139   52:54:00:aa:00:03
EOF
cat > /tmp/ethtool_l.log <<'EOF'
Channel parameters for eth0:
Pre-set maximums:
RX:		n/a
TX:		n/a
Other:		n/a
Combined:	4
Current hardware settings:
RX:		n/a
TX:		n/a
Other:		n/a
Combined:	1
EOF
cat > /tmp/vm_net.xml <<'EOF'
    <interface type='bridge'>
      <source bridge='br0'/>
      <model type='e1000'/>
    </interface>
EOF
true"""

b = SetBuilder(612, '가상 NIC 성능: virtio, vhost-net, 멀티큐, 패킷이 지나는 길',
               '가상 NIC 의 성능은 NIC 모델(에뮬레이션인가 virtio 인가), 패킷 처리 위치(vhost-net), 큐 개수(멀티큐)에 좌우됩니다. domiflist 출력에서 virtio 가 아닌 NIC 를 찾고, 게스트의 ethtool -l 출력에서 큐 수를 읽고, 멀티큐를 켜는 명령과 NIC XML 수정을 연습하고, 패킷이 게스트에서 물리 NIC 까지 지나는 길을 정리합니다. 샌드박스에는 libvirt 가 없어 명령은 파일에 적고 출력은 샘플로 읽습니다.',
               'linux', '가상화', 72, 872, '🚀',
               [{"title": "libvirt NIC 모델과 드라이버", "url": "https://libvirt.org/formatdomain.html#network-interfaces"}, {"title": "ethtool 매뉴얼", "url": "https://man7.org/linux/man-pages/man8/ethtool.8.html"}], 12)

b.nt('virtio 가 아닌 NIC', '`/tmp/domiflist.log` 는 `virsh domiflist` 의 출력입니다. 에뮬레이션 NIC(`e1000`, `rtl8139` 등)는 virtio 보다 느립니다. **모델이 `virtio` 가 아닌 인터페이스의 이름**을 이름순으로 한 줄에 하나씩 `/tmp/slow_nics.txt` 에 저장하세요. (이름만)',
     '표의 앞 두 줄은 제목입니다. 모델 칸을 조건으로 쓰세요.',
     "cat /tmp/domiflist.log\nawk 'NR>2 && $4!=\"virtio\" {print $1}' /tmp/domiflist.log | sort > /tmp/slow_nics.txt\ncat /tmp/slow_nics.txt\n\n# e1000 같은 에뮬레이션 모델은 실제 하드웨어를 흉내 내느라 호스트 CPU 를 더 쓴다. 게스트에 virtio 드라이버가 있으면 virtio 로 바꾼다(재부팅 필요)",
     S112, [chk('vnet1, vnet2 이다', '[ "$(tr "\\n" " " < /tmp/slow_nics.txt | xargs)" = "vnet1 vnet2" ]')])
b.nt('현재 큐 개수 읽기', '`/tmp/ethtool_l.log` 는 게스트에서 본 `ethtool -l eth0` 의 출력입니다. "Pre-set maximums" 는 NIC 가 지원하는 최대 큐 수이고 "Current hardware settings" 는 지금 쓰는 수입니다. **현재 쓰는 Combined 큐 수**를 숫자만 `/tmp/queues.txt` 에 저장하세요.',
     '`Combined` 줄이 두 번 나옵니다. 어느 쪽이 현재 값인지 구분하세요.',
     "cat /tmp/ethtool_l.log\nawk '/Combined/ {v=$2} END {print v}' /tmp/ethtool_l.log > /tmp/queues.txt\ncat /tmp/queues.txt\n\n# 최대 4 인데 1 만 쓰고 있다. vCPU 가 여러 개여도 큐가 1개면 수신 처리가 한 CPU 에 몰린다",
     S112, [chk('1 이다', '[ "$(tr -d " \\n" < /tmp/queues.txt)" = 1 ]')])
b.nt('게스트의 큐를 늘리는 명령', '게스트 안에서 `eth0` 의 Combined 큐 수를 **4 로 바꾸는** `ethtool` 명령 한 줄을 `/tmp/set_queues.txt` 에 적으세요. (실행하지 않습니다)',
     '큐(채널) 설정은 ethtool 매뉴얼의 Channel 항목에서 찾아 보세요.',
     "echo 'ethtool -L eth0 combined 4' > /tmp/set_queues.txt\ncat /tmp/set_queues.txt\n\n# 호스트에서 VM 의 NIC 에 queues 를 지정해 둬야 4 까지 올릴 수 있다. 재부팅하면 풀리므로 영구 설정은 네트워크 설정 파일에 넣는다",
     S112, [chk('ethtool -L 로 eth0 combined 4', 'grep -Eq "^[[:space:]]*(sudo )?ethtool( --set-channels| -L) eth0 combined 4[[:space:]]*$" /tmp/set_queues.txt')])
b.nt('NIC XML 을 virtio·멀티큐로', '`/tmp/vm_net.xml` 의 NIC 는 지금 에뮬레이션 모델입니다. **모델을 `virtio` 로 바꾸고**, `<model>` 줄 바로 아래에 **호스트 커널에서 패킷을 처리(vhost)하며 큐를 4개 쓰는** `<driver>` 요소를 추가하세요.',
     '`driver` 요소에는 이름과 큐 수 속성이 있습니다. 이름은 호스트 커널에서 패킷을 처리하는 모듈과 관련됩니다.',
     "sed -i \"s:<model type='e1000'/>:<model type='virtio'/>:\" /tmp/vm_net.xml\nsed -i \"/<model type='virtio'\\/>/a\\\\      <driver name='vhost' queues='4'/>\" /tmp/vm_net.xml\ncat /tmp/vm_net.xml\n\n# queues 를 쓰려면 모델이 virtio 여야 한다. 게스트는 ethtool -L 로 큐를 늘려야 실제로 쓴다",
     S112, [chk('모델이 virtio 다', 'grep -Eq "<model type=.virtio.\\s*/>" /tmp/vm_net.xml'), chk('e1000 이 남지 않았다', '! grep -q e1000 /tmp/vm_net.xml'), chk('driver 가 vhost, 큐 4 다', r'''grep -v '<!--' /tmp/vm_net.xml | grep -E '<driver' | grep -E "name=['\"]vhost['\"]" | grep -Eq "queues=['\"]4['\"]"'''), chk('driver 가 model 뒤에 있다', '[ "$(grep -n "<driver" /tmp/vm_net.xml | head -1 | cut -d: -f1)" -gt "$(grep -n "<model" /tmp/vm_net.xml | head -1 | cut -d: -f1)" ]')])
b.nt('vhost-net 확인', '호스트에서 커널 모듈 `vhost_net` 이 **올라와 있는지** 확인하는 명령 한 줄을 `/tmp/vhost_check.txt` 에 적으세요. (모듈 목록을 보는 명령과 이름 검색)',
     '모듈 목록을 보는 명령의 출력을 걸러 이름을 찾으세요.',
     "echo 'lsmod | grep vhost_net' > /tmp/vhost_check.txt\ncat /tmp/vhost_check.txt\n\n# 출력이 없으면 modprobe vhost_net 으로 올린다. /dev/vhost-net 장치가 있어야 libvirt 가 vhost 를 쓴다",
     S112, [chk('모듈 목록에서 vhost_net 을 찾는다', 'grep -Eq "(lsmod|/proc/modules)" /tmp/vhost_check.txt && grep -Eq "vhost_net" /tmp/vhost_check.txt && ! grep -Eq "grep[^|]* -[a-zA-Z]*[vc]" /tmp/vhost_check.txt')])
b.choice('e1000 와 virtio', 'VM 의 NIC 모델을 `e1000` 에서 `virtio` 로 바꾸면 보통 어떤 변화가 있나요?', '에뮬레이션은 실제 장치를 흉내 내느라 일을 더 합니다.',
         ['호스트 CPU 사용이 줄고 처리량이 늘지만 게스트에 드라이버가 필요하다', '성능은 같고 게스트에서 보이는 장치 이름만 달라질 뿐이다', '처리량은 늘지만 게스트 OS 를 반드시 새로 설치해야만 한다', '지연은 줄지만 라이브 마이그레이션이 더는 불가능해진다'], 0,
         'virtio 는 가상화에 맞춘 반가상화 장치라 에뮬레이션보다 오버헤드가 작습니다. 최신 리눅스 커널은 드라이버를 기본 포함하고 Windows 는 별도 드라이버가 필요합니다. 마이그레이션은 virtio 로도 문제없이 됩니다.')
b.choice('멀티큐가 도움이 되는 경우', '멀티큐(`queues=4`) 설정이 가장 효과가 큰 상황은?', '큐가 여러 개면 수신 처리를 여러 CPU 가 나눠 맡습니다.',
         ['vCPU 가 여러 개이고 패킷이 많은 서비스를 도는 VM', 'vCPU 1개로 가끔 SSH 접속만 하는 정도로 쓰는 VM', '디스크 입출력이 많고 네트워크는 거의 쓰지 않는 VM', '네트워크 장치가 전혀 연결되지 않은 상태의 VM'], 0,
         '멀티큐는 패킷 처리를 여러 vCPU 로 분산해 처리량이 높은 VM 에서 효과가 큽니다. vCPU 가 하나거나 트래픽이 적으면 이득이 거의 없고, 큐 수는 vCPU 수를 넘기지 않는 것이 일반적입니다.')
b.choice('vhost-net', 'vhost-net 을 쓰면 패킷 처리 경로가 어떻게 달라지나요?', '처리 위치가 사용자 공간 프로세스에서 어디로 옮겨 가는지 생각해 보세요.',
         ['QEMU 프로세스 대신 호스트 커널이 처리해 컨텍스트 전환이 줄어든다', '게스트 커널이 호스트 대신 물리 NIC 를 직접 구동한다', '패킷을 모두 디스크에 먼저 기록한 뒤 전달한다', '브리지를 거치지 않고 NIC 를 독점한다'], 0,
         'vhost-net 은 virtio 패킷 처리를 QEMU 사용자 공간에서 호스트 커널 스레드로 옮겨 컨텍스트 전환과 복사를 줄입니다. 물리 NIC 를 독점하는 것은 SR-IOV·패스스루입니다.')
b.fill('큐 개수 바꾸기', '게스트에서 NIC 의 큐(채널) 개수를 **바꾸는** `ethtool` 옵션을 채우세요. (대소문자를 구분합니다)', '조회 옵션과 설정 옵션은 서로 다른 글자입니다.',
       'ethtool -{0} eth0 combined 4', ['L', 'l', 'g', 'i'], [0],
       '`-L`(`--set-channels`)은 채널 수를 바꾸고 `-l` 은 조회합니다. `-g` 는 링 버퍼, `-i` 는 드라이버 정보를 봅니다.')
b.order('패킷이 지나는 길', '브리지 네트워크의 VM 이 외부로 패킷을 보낼 때 지나는 길입니다. 올바른 순서로 놓으세요.', '패킷이 가상 영역에서 물리 영역으로 나갑니다.',
        ['호스트의 브리지', '게스트 안의 virtio 드라이버', '호스트의 물리 NIC', '호스트의 tap 장치(vnet)'], [1, 3, 0, 2],
        '게스트의 virtio 드라이버에서 출발한 패킷은 호스트의 tap 장치(vnetX)로 넘어오고, 브리지가 이를 전달해 물리 NIC 로 나갑니다.')

if __name__ == '__main__':
    preview(b)
