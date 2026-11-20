import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 613: SR-IOV·PCI 패스스루. 명세: docs/specs/spec_gap_set613.md
# 샌드박스 linux(PCI 장치·IOMMU 없음). lspci 출력은 샘플로 읽고, sysfs 명령은 파일에 적는다.

S113 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/lspci.log <<'EOF'
00:1f.2 SATA controller: Example Chipset SATA Controller
03:00.0 Ethernet controller: Example NIC 25GbE
03:10.0 Ethernet controller: Example NIC 25GbE Virtual Function
03:10.1 Ethernet controller: Example NIC 25GbE Virtual Function
03:10.2 Ethernet controller: Example NIC 25GbE Virtual Function
04:00.0 VGA compatible controller: Example GPU
EOF
true"""

b = SetBuilder(613, 'SR-IOV 와 PCI 패스스루: 가상 NIC 의 한계, PF·VF, IOMMU, 패스스루의 대가',
               '가상 NIC 는 호스트 소프트웨어를 거치므로 한계가 있습니다. SR-IOV 는 물리 NIC 하나를 여러 가상 기능(VF)으로 나눠 VM 에 직접 주고, PCI 패스스루는 장치 전체를 한 VM 에 줍니다. lspci 출력에서 VF 를 찾고, VF 를 만드는 sysfs 명령을 적고, IOMMU·vfio 의 역할과 라이브 마이그레이션 제약 같은 대가를 정리하는 개념 세트입니다. 샌드박스에는 해당 장치가 없어 샘플로 읽습니다.',
               'linux', '가상화', 72, 873, '⚡',
               [{"title": "libvirt PCI 장치 할당", "url": "https://libvirt.org/formatdomain.html#pci-host-devices"}, {"title": "SR-IOV (커널 문서)", "url": "https://docs.kernel.org/PCI/pci-iov-howto.html"}], 13)

b.nt('VF 주소 찾기', '`/tmp/lspci.log` 는 `lspci` 의 출력입니다. SR-IOV 로 만들어진 **가상 기능(Virtual Function)** 장치의 PCI 주소(맨 앞 칸)를 주소순으로 한 줄에 하나씩 `/tmp/vfs.txt` 에 저장하세요. (주소만)',
     '장치 설명에 `Virtual Function` 이 들어 있는 줄입니다.',
     "cat /tmp/lspci.log\ngrep 'Virtual Function' /tmp/lspci.log | awk '{print $1}' | sort > /tmp/vfs.txt\ncat /tmp/vfs.txt\n\n# 03:00.0 이 물리 기능(PF), 03:10.x 가 VF 다. VF 하나를 VM 하나에 직접 줄 수 있다",
     S113, [chk('03:10.0 ~ 03:10.2 이다', '[ "$(tr "\\n" " " < /tmp/vfs.txt | xargs)" = "03:10.0 03:10.1 03:10.2" ]')])
b.nt('VF 만들기', '물리 NIC `eth1` 에서 VF 를 **4 개 만들려면** sysfs 의 `sriov_numvfs` 파일에 4 를 써야 합니다. 이 동작을 하는 명령 한 줄을 `/tmp/vf_create.txt` 에 적으세요. (실행하지 않습니다. 경로는 `/sys/class/net/eth1/device/` 아래입니다)',
     '문자열을 출력해 파일에 쓰는 일반 쉘 명령이면 됩니다.',
     "echo 'echo 4 > /sys/class/net/eth1/device/sriov_numvfs' > /tmp/vf_create.txt\ncat /tmp/vf_create.txt\n\n# 이미 0 이 아닌 값이면 먼저 0 으로 되돌린 뒤 바꿔야 한다. 장치·드라이버가 SR-IOV 를 지원해야 하고 BIOS 에서 켜져 있어야 한다",
     S113, [chk('sriov_numvfs 에 4 를 쓴다', 'grep -Eq "(echo|printf)[[:space:]]+[\\"\']?4[\\"\']?[[:space:]]*(>|\\\\|[[:space:]]*(sudo[[:space:]]+)?tee[[:space:]]+)[[:space:]]*/sys/class/net/eth1/device/sriov_numvfs([[:space:]]|$|[\\"\'])" /tmp/vf_create.txt')])
b.choice('SR-IOV 의 이점', '가상 NIC(virtio)와 비교해 SR-IOV VF 를 VM 에 직접 주는 방식의 주된 이점은?', '패킷이 호스트의 가상 스위치를 거치는지 생각해 보세요.',
         ['호스트 스위치를 거치지 않아 지연과 CPU 부담이 적다', 'VM 을 다른 호스트로 옮기기가 오히려 더 쉬워진다', '물리 NIC 가 없는 서버에서도 네트워크를 쓸 수 있다', '한 VF 하나를 여러 VM 이 동시에 나눠 쓸 수 있다'], 0,
         'VF 는 하드웨어가 직접 처리해 호스트의 브리지·가상 스위치를 건너뛰므로 지연과 CPU 사용이 줄어듭니다. 대신 VM 이동이 어렵고 VF 하나는 VM 하나에만 줄 수 있으며 물리 NIC 가 반드시 필요합니다.')
b.choice('패스스루의 대가', 'PCI 장치(VF 나 GPU)를 VM 에 패스스루로 할당한 뒤 가장 크게 달라지는 운영상 제약은?', '장치 상태는 물리 하드웨어 안에 있습니다.',
         ['실행 중에 다른 호스트로 라이브 마이그레이션하기 어렵다', 'VM 에게 메모리를 따로 할당해 줄 수 없게 된다', 'VM 을 정상적으로 종료하는 것이 불가능해진다', '호스트의 모든 VM 이 같은 장치를 자동으로 공유한다'], 0,
         '장치 상태가 하드웨어에 있어 일반적인 라이브 마이그레이션이 되지 않거나 매우 제한됩니다. 장치는 보통 한 VM 이 독점하며, 종료나 메모리 할당 같은 기본 동작은 그대로 가능합니다.')
b.choice('IOMMU 의 역할', 'PCI 패스스루에서 IOMMU 가 필요한 이유로 알맞은 것은?', 'VM 이 장치를 직접 다루면 장치가 DMA 로 메모리를 읽고 씁니다.',
         ['장치의 DMA 를 해당 VM 메모리로 제한해 호스트를 보호한다', '게스트에 맞는 장치 드라이버를 자동으로 내려받아 설치한다', 'VM 의 CPU 클럭을 올려 연산을 더 빠르게 처리한다', '장치를 지나는 네트워크 패킷을 모두 암호화해 준다'], 0,
         'IOMMU 는 장치의 DMA 주소를 변환·제한해 장치가 할당된 VM 의 메모리만 접근하게 합니다. 이것이 없으면 장치가 호스트 메모리를 읽거나 덮어쓸 수 있어 패스스루를 안전하게 쓸 수 없습니다.')
b.choice('vfio', '리눅스 호스트에서 `vfio-pci` 드라이버의 역할은?', '호스트 기본 드라이버 대신 장치를 사용자 공간(QEMU)에 넘기는 통로입니다.',
         ['장치를 호스트 드라이버에서 떼어 QEMU 가 직접 쓰게 넘긴다', '장치의 펌웨어를 최신 버전으로 자동 업데이트해 준다', 'VM 의 가상 디스크 이미지 전체를 암호화해 저장한다', '호스트와 VM 사이의 네트워크 속도를 주기적으로 측정한다'], 0,
         'vfio-pci 는 장치를 호스트 커널 드라이버에서 분리해 IOMMU 보호 아래 사용자 공간 프로그램(QEMU)이 직접 제어하게 합니다. libvirt 는 이를 `managed` 모드로 자동 처리하기도 합니다.')
b.fill('VF 개수 파일', 'VF 개수를 정하는 sysfs 파일 이름을 채우세요.', 'SR-IOV 와 VF 개수를 합친 이름입니다.',
       '/sys/class/net/eth1/device/{0}', ['sriov_numvfs', 'sriov_totalvfs', 'vf_count', 'numa_node'], [0],
       '`sriov_numvfs` 는 지금 만들 VF 수를 정하고, `sriov_totalvfs` 는 장치가 지원하는 최대 VF 수를 알려 줍니다. `numa_node` 는 장치가 속한 NUMA 노드입니다.')
b.order('패스스루로 GPU 주기', 'libvirt 의 자동 바인딩(managed)을 쓰지 않고 GPU 하나를 VM 에 패스스루로 주기 위한 순서입니다. 올바른 순서로 놓으세요.', '보호 장치가 먼저 켜져 있어야 장치를 넘길 수 있습니다.',
        ['VM 을 시작해 게스트에서 장치를 확인한다', '호스트에서 IOMMU 를 켠다', 'VM 설정에 해당 PCI 장치를 추가한다', '장치를 vfio-pci 에 수동으로 묶는다'], [1, 3, 2, 0],
        'IOMMU 를 켜고, 장치를 vfio-pci 에 묶고, VM 에 장치를 추가한 뒤 시작해서 게스트에서 확인합니다.')

if __name__ == '__main__':
    preview(b)
