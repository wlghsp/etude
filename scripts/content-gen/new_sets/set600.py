import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 600: KVM 호스트 확인과 virsh 상태 읽기. 명세: docs/specs/spec_gap_set600.md
# 샌드박스 linux(libvirt·KVM 없음). lscpu·virt-host-validate·virsh 출력의 샘플을 읽는다.

S100 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/lscpu.log <<'EOF'
Architecture:        x86_64
CPU(s):              32
Thread(s) per core:  2
Core(s) per socket:  8
Socket(s):           2
Virtualization:      VT-x
EOF
cat > /tmp/validate.log <<'EOF'
  QEMU: Checking for hardware virtualization                                 : PASS
  QEMU: Checking if device /dev/kvm exists                                   : FAIL (Check that the 'kvm-intel' or 'kvm-amd' modules are loaded & the BIOS has enabled virtualization)
  QEMU: Checking if device /dev/kvm is accessible                            : FAIL (Check /dev/kvm permissions)
  QEMU: Checking for cgroup 'memory' controller support                      : PASS
EOF
cat > /tmp/dominfo.log <<'EOF'
Id:             7
Name:           web01
State:          running
CPU(s):         2
Max memory:     2097152 KiB
Used memory:    1048576 KiB
Persistent:     yes
Autostart:      disable
EOF
cat > /tmp/domblklist.log <<'EOF'
 Target   Source
---------------------------------------------
 vda      /var/lib/libvirt/images/web01.qcow2
 sda      -
EOF
cat > /tmp/domifaddr.log <<'EOF'
 Name       MAC address          Protocol     Address
-------------------------------------------------------------------------------
EOF
true"""

b = SetBuilder(600, 'KVM 호스트 확인과 VM 상태 읽기: lscpu·virt-host-validate, dominfo·domblklist·domifaddr',
               '서버에서 VM 을 돌릴 수 있는지 확인하고, 돌아가는 VM 의 상태를 읽는 연습입니다. lscpu 의 가상화 방식과 논리 CPU 수, virt-host-validate 의 실패 항목, virsh dominfo 의 상태와 최대·사용 메모리, domblklist 의 디스크 이미지 경로, domifaddr 가 비어 있을 때의 의미와 에이전트로 주소를 조회하는 명령을 샘플에서 읽습니다. 샌드박스에는 libvirt·KVM 이 없어 샘플 출력을 읽는 방식입니다.',
               'linux', '가상화', 48, 860, '🖥️',
               [{"title": "virt-host-validate 매뉴얼", "url": "https://libvirt.org/manpages/virt-host-validate.html"}, {"title": "virsh 매뉴얼", "url": "https://libvirt.org/manpages/virsh.html"}], 5)

b.nt('CPU 의 가상화 방식', '`/tmp/lscpu.log` 는 호스트의 `lscpu` 출력입니다. `Virtualization:` 줄은 CPU 가 지원하는 하드웨어 가상화 방식(Intel 은 VT-x, AMD 는 AMD-V)을 보여 줍니다. 이 호스트의 **가상화 방식 값**을 `/tmp/virt.txt` 에 저장하세요. (값만)',
     '`Virtualization:` 로 시작하는 줄의 콜론 뒤입니다.',
     "cat /tmp/lscpu.log\ngrep '^Virtualization:' /tmp/lscpu.log | awk '{print $2}' > /tmp/virt.txt\ncat /tmp/virt.txt\n\n# 이 줄이 없으면 CPU 가 지원하지 않거나 BIOS 에서 꺼져 있다. VM 안(중첩 가상화)에서는 다른 값이 보이기도 한다",
     S100, [chk('VT-x 다', '[ "$(cat /tmp/virt.txt)" = VT-x ]')])
b.nt('논리 CPU 수 계산', '같은 `lscpu` 출력에서 **소켓 수 × 소켓당 코어 수 × 코어당 스레드 수** 로 계산한 **논리 CPU 수**를 `/tmp/logical.txt` 에 저장하세요. (숫자만, `CPU(s):` 줄과 같아야 합니다)',
     '세 값을 각각 뽑아 곱하세요. 쉘 산술을 쓸 수 있습니다.',
     "S=$(grep '^Socket' /tmp/lscpu.log | awk '{print $2}')\nC=$(grep '^Core' /tmp/lscpu.log | awk '{print $4}')\nT=$(grep '^Thread' /tmp/lscpu.log | awk '{print $4}')\necho $((S * C * T)) > /tmp/logical.txt\ncat /tmp/logical.txt\n\n# 2 × 8 × 2 = 32. vCPU 를 물리 몇 배까지 줄지(오버커밋) 계산할 때 이 값이 기준이 된다",
     S100, [chk('32 다', '[ "$(cat /tmp/logical.txt)" = 32 ]')])
b.nt('호스트 점검의 실패 항목', '`/tmp/validate.log` 는 `virt-host-validate` 의 출력입니다. 각 줄 끝이 `PASS` 또는 `FAIL` 입니다. **실패(`FAIL`)한 항목의 개수**를 숫자만 `/tmp/fails.txt` 에 저장하세요.',
     '`FAIL` 이 들어간 줄의 수를 세세요.',
     "cat /tmp/validate.log\ngrep -c 'FAIL' /tmp/validate.log > /tmp/fails.txt\ncat /tmp/fails.txt\n\n# CPU 는 지원하는데 /dev/kvm 이 없다. 메시지처럼 kvm 모듈이 올라오지 않았거나 BIOS 에서 가상화가 꺼져 있는 경우가 많다. 모듈은 modprobe kvm_intel 로 올린다",
     S100, [chk('2 다', '[ "$(cat /tmp/fails.txt)" = 2 ]')])
b.nt('최대 메모리를 MiB 로', '`/tmp/dominfo.log` 는 `virsh dominfo web01` 의 출력입니다. `Max memory` 는 KiB 단위입니다. 이 VM 의 **최대 메모리를 MiB 로 환산**한 값(정수)을 `/tmp/max_mib.txt` 에, **현재 상태(`State`)** 를 `/tmp/state.txt` 에 저장하세요.',
     'KiB 를 1024 로 나누면 MiB 입니다. `State:` 줄은 콜론 뒤 한 단어입니다.',
     "cat /tmp/dominfo.log\nK=$(grep 'Max memory' /tmp/dominfo.log | awk '{print $3}')\necho $((K / 1024)) > /tmp/max_mib.txt\ngrep '^State:' /tmp/dominfo.log | awk '{print $2}' > /tmp/state.txt\ncat /tmp/max_mib.txt /tmp/state.txt\n\n# 최대 2048MiB 인데 사용 중(Used memory)은 1024MiB 다. 풍선(balloon) 드라이버로 게스트에 실제 준 메모리를 줄여 둔 상태일 수 있다",
     S100, [chk('2048 이다', '[ "$(cat /tmp/max_mib.txt)" = 2048 ]'), chk('running 이다', '[ "$(cat /tmp/state.txt)" = running ]')])
b.nt('디스크 이미지 경로', '`/tmp/domblklist.log` 는 `virsh domblklist web01` 의 출력입니다. 이 VM 에 **실제 이미지 파일이 연결된 디스크의 경로**(`Source` 열, `-` 는 비어 있음)를 `/tmp/image.txt` 에 저장하세요. (경로만)',
     '`Source` 열이 `-` 가 아닌 줄의 마지막 칸입니다.',
     "cat /tmp/domblklist.log\nawk 'NR>2 && $2 != \"-\" {print $2}' /tmp/domblklist.log > /tmp/image.txt\ncat /tmp/image.txt\n\n# sda 는 비어 있는 장치(CD-ROM 등)다. 이 경로의 파일이 지워지거나 권한이 바뀌면 VM 시작이 실패한다",
     S100, [chk('web01.qcow2 경로다', '[ "$(cat /tmp/image.txt)" = /var/lib/libvirt/images/web01.qcow2 ]')])
b.nt('IP 조회 비어 있음과 에이전트', '`/tmp/domifaddr.log` 는 VM 이 켜진 뒤 `virsh domifaddr web01` 의 출력으로 주소 항목이 **하나도 없습니다**. 게스트에 에이전트(qemu-guest-agent)가 있으면 **에이전트를 통해** 주소를 물어볼 수 있습니다. 그 `virsh` 명령 한 줄을 `/tmp/agent_cmd.txt` 에 적으세요. (샌드박스에는 libvirt 가 없어 실행하지 않습니다)',
     '`domifaddr` 에 주소를 얻는 출처를 정하는 옵션이 있습니다.',
     "cat /tmp/domifaddr.log\necho 'virsh domifaddr web01 --source agent' > /tmp/agent_cmd.txt\ncat /tmp/agent_cmd.txt\n\n# 기본은 DHCP 임대 목록(lease)에서 찾는다. 고정 IP 나 외부 브리지에 붙으면 목록에 없어 비어 보이므로 에이전트나 ARP 로 조회한다",
     S100, [chk('domifaddr 에이전트 명령이다', 'grep -Eq "^[[:space:]]*(sudo )?virsh( (-c|--connect)[ =]?[^ ]+)? domifaddr( .*)? web01( .*)?$" /tmp/agent_cmd.txt && grep -Eq -- "--source[= ]agent" /tmp/agent_cmd.txt')])
b.choice('shutdown, reboot, destroy', 'VM 을 정리하는 virsh 명령의 차이로 알맞은 것은?', '정상 종료 요청과 전원을 뽑는 것을 구분하세요.',
         ['shutdown 은 정상 종료를 요청하고 destroy 는 전원을 즉시 끊는다', 'shutdown 은 VM 을 삭제하고 destroy 는 정상 종료한다', 'reboot 은 VM 을 재시작하면서 정의까지 삭제한다', 'destroy 는 VM 정의와 디스크를 모두 삭제한다'], 0,
         '`shutdown` 은 게스트에 종료 신호(ACPI·에이전트)를 보내 정상 종료하고, `destroy` 는 전원을 뽑는 것과 같아 강제로 끕니다(정의와 디스크는 남음). 정의를 지우는 것은 `undefine` 입니다.')
b.choice('Used memory 가 Max 보다 작은 이유', 'dominfo 에서 `Max memory` 는 2097152 KiB 인데 `Used memory` 는 1048576 KiB 입니다. 가장 알맞은 해석은?', '게스트에 실제로 할당된 메모리와 허용 상한은 다를 수 있습니다.',
         ['풍선(balloon)으로 게스트 메모리를 줄여 둔 상태일 수 있다', '메모리 하나가 고장나서 절반이 사라진 것이다', '호스트가 VM 의 메모리를 두 배로 늘려 준 것이다', 'VM 이 곧 삭제될 예정이라 메모리를 줄인 것이다'], 0,
         'Max memory 는 허용 상한, Used memory(currentMemory)는 지금 게스트에 할당된 양입니다. balloon 으로 호스트가 회수해 가면 줄어 있고 setmem 으로 상한까지 올릴 수 있습니다.')
b.fill('VM 요약 보기', 'VM 의 이름·상태·CPU 수·메모리 요약을 보는 virsh 명령을 채우세요.', '정보(information) 요약이라는 뜻의 하위 명령입니다.',
       'virsh {0} web01', ['dominfo', 'domstats', 'list', 'version'], [0],
       '`dominfo` 는 도메인 한 개의 기본 정보를 요약합니다. `domstats` 는 통계(CPU·블록·네트워크), `list` 는 VM 목록, `version` 은 libvirt·하이퍼바이저 버전입니다.')
b.order('호스트에서 KVM 사용 가능 여부 확인', 'KVM 을 쓸 수 있는지 확인하려 합니다. 하드웨어에서 소프트웨어 쪽으로 한 칸씩 올라가며 확인하는 순서로 놓으세요.', '아래 계층이 안 되면 위 계층은 확인할 필요가 없습니다.',
        ['`virt-host-validate` 로 종합 점검한다', '`lsmod | grep kvm` 으로 KVM 모듈이 올라와 있는지 본다', '`/dev/kvm` 장치 파일이 있는지 본다', 'CPU 의 가상화 지원(vmx·svm)을 본다'], [3, 1, 2, 0],
        'CPU 지원 → 커널 모듈 → 장치 파일 → 종합 점검 순서로 확인합니다. 앞 단계에서 막히면(BIOS 에서 꺼짐, 모듈 없음) 뒤 단계도 실패합니다.')

if __name__ == '__main__':
    preview(b)
