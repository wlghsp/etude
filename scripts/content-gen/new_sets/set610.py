import sys, os; sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..')); from gen_pilot_sets import *
# 세트 610: VM 이 느릴 때 보는 순서. 명세: docs/specs/spec_gap_set610.md
# 샌드박스 linux(libvirt 없음). 게스트 top 줄과 domstats 출력은 샘플 파일로 읽고, 호스트 명령은 파일에 적는다.

S110 = """rm -f /tmp/*.txt /tmp/*.log
cat > /tmp/top_one.log <<'EOF'
%Cpu(s): 12.0 us,  3.0 sy,  0.0 ni, 40.0 id,  5.0 wa,  0.0 hi,  2.0 si, 38.0 st
EOF
cat > /tmp/top_vms.log <<'EOF'
web01 %Cpu(s): 10.0 us,  2.0 sy,  0.0 ni, 85.0 id,  1.0 wa,  0.0 hi,  0.0 si,  2.0 st
web02 %Cpu(s): 15.0 us,  5.0 sy,  0.0 ni, 30.0 id,  2.0 wa,  0.0 hi,  0.0 si, 48.0 st
db01 %Cpu(s):  5.0 us,  3.0 sy,  0.0 ni, 40.0 id, 50.0 wa,  0.0 hi,  0.0 si,  2.0 st
EOF
cat > /tmp/balloon.log <<'EOF'
Domain: 'web01'
  balloon.current=2097152
  balloon.maximum=4194304
  balloon.swap_in=0
  balloon.swap_out=0
EOF
true"""

b = SetBuilder(610, 'VM 이 느릴 때 보는 순서: CPU 대기(steal), 디스크 대기(iowait), 메모리, 호스트 통계',
               '"VM 이 느리다"는 신고는 CPU, 디스크, 메모리, 네트워크 중 어디가 막혔는지부터 가려야 합니다. 게스트의 top 줄에서 steal 과 iowait 를 읽어 호스트 문제와 디스크 문제를 구분하고, 호스트에서 domstats 로 같은 VM 의 통계를 보고, 디스크 입출력을 제한하는 명령을 적어 봅니다. 샌드박스에는 libvirt 가 없어 명령은 파일에 적고 출력은 샘플로 읽습니다.',
               'linux', '가상화', 48, 870, '🐢',
               [{"title": "virsh domstats", "url": "https://libvirt.org/manpages/virsh.html#domstats"}, {"title": "top 매뉴얼", "url": "https://man7.org/linux/man-pages/man1/top.1.html"}], 10)

b.nt('steal 값 읽기', '`/tmp/top_one.log` 는 게스트 안에서 본 `top` 의 CPU 줄입니다. 맨 뒤의 `st`(steal)는 게스트가 CPU 를 쓰려 했지만 호스트가 다른 VM 에 주느라 기다린 시간의 비율입니다. **steal 값만** 숫자로 `/tmp/steal.txt` 에 저장하세요. (예: `1.5`)',
     '`st` 바로 앞의 숫자입니다. 줄을 쉼표로 쪼개 마지막 칸을 보세요.',
     "cat /tmp/top_one.log\nawk -F, '{print $NF}' /tmp/top_one.log | awk '{print $1}' > /tmp/steal.txt\ncat /tmp/steal.txt\n\n# steal 이 높으면 게스트 안의 프로세스 문제가 아니라 호스트가 CPU 를 모자라게 준 것이다(오버커밋)",
     S110, [chk('38 이다', 'awk "NR==1{v=\\$1+0} END{exit !(NR==1 && v==38)}" /tmp/steal.txt')])
b.nt('호스트 CPU 가 모자란 VM', '`/tmp/top_vms.log` 는 VM 이름과 각 게스트의 `top` CPU 줄입니다. **steal 이 10 이상인 VM 의 이름**을 한 줄에 하나씩 `/tmp/steal_vms.txt` 에 저장하세요. (이름만)',
     '줄의 맨 앞은 이름이고 마지막에서 둘째 칸이 steal 값입니다. 숫자 비교가 필요합니다.',
     "cat /tmp/top_vms.log\nawk '{ if ($(NF-1) >= 10) print $1 }' /tmp/top_vms.log > /tmp/steal_vms.txt\ncat /tmp/steal_vms.txt\n\n# 이런 VM 은 게스트를 손봐도 소용이 없다. 호스트의 vCPU 오버커밋을 줄이거나 VM 을 다른 호스트로 옮긴다",
     S110, [chk('web02 뿐이다', '[ "$(cat /tmp/steal_vms.txt)" = web02 ]')])
b.nt('디스크를 기다리는 VM', '같은 `/tmp/top_vms.log` 에서 **iowait(`wa`)가 20 이상인 VM 의 이름**을 한 줄에 하나씩 `/tmp/wa_vms.txt` 에 저장하세요. (이름만)',
     '`wa` 는 `us`·`sy` 와 같은 줄에 있습니다. 해당 칸의 위치를 세어 보세요.',
     "awk '{ if ($11 >= 20) print $1 }' /tmp/top_vms.log > /tmp/wa_vms.txt\ncat /tmp/wa_vms.txt\n\n# wa 가 높으면 CPU 가 일하지 않고 디스크 응답을 기다리는 것이다. 게스트 안의 디스크 사용량과 호스트 스토리지 지연을 함께 본다",
     S110, [chk('db01 뿐이다', '[ "$(cat /tmp/wa_vms.txt)" = db01 ]')])
b.nt('호스트에서 VM 의 디스크 통계', '호스트에서 VM `db01` 의 **블록 장치 통계**만 보는 `virsh domstats` 명령 한 줄을 `/tmp/domstats_block.txt` 에 적으세요. (실행하지 않습니다)',
     '통계 하위 명령에 보고 싶은 그룹을 옵션으로 줍니다. 그룹 이름은 장치 종류와 같습니다.',
     "echo 'virsh domstats db01 --block' > /tmp/domstats_block.txt\ncat /tmp/domstats_block.txt\n\n# CPU 는 --cpu-total, 메모리는 --balloon, 네트워크는 --interface 로 그룹을 바꿔 본다. 옵션 없이 쓰면 모든 그룹이 나온다",
     S110, [chk('domstats 를 쓴다', 'grep -Eq "virsh( (-c|--connect)[ =]?[^ ]+)? domstats( |$)" /tmp/domstats_block.txt'), chk('block 그룹이다', 'grep -Eq "(^|[[:space:]])--block([[:space:]]|$)" /tmp/domstats_block.txt'), chk('db01 이다', 'grep -Eq "(^|[[:space:]])db01([[:space:]]|$)" /tmp/domstats_block.txt')])
b.nt('디스크 입출력 제한', '`db01` 의 디스크 `vda` 가 호스트 스토리지를 독점하지 않도록 **초당 총 입출력 수를 500 으로 제한**하는 `virsh` 명령 한 줄을 `/tmp/iotune.txt` 에 적으세요.',
     '장치 입출력 튜닝 하위 명령이 있습니다. VM, 장치 이름 다음에 제한 종류와 값을 줍니다.',
     "echo 'virsh blkdeviotune db01 vda --total-iops-sec 500' > /tmp/iotune.txt\ncat /tmp/iotune.txt\n\n# 옵션 없이 쓰면 현재 제한을 보여 준다. 제한은 다른 VM 을 보호하는 장치지만 너무 낮으면 그 VM 이 느려진다. --live 와 --config 로 반영 범위를 정한다",
     S110, [chk('blkdeviotune 로 db01 에 건다', 'grep -Eq "virsh( (-c|--connect)[ =]?[^ ]+)? blkdeviotune db01( |$)" /tmp/iotune.txt'), chk('vda 장치다', 'grep -Eq "blkdeviotune db01( .*)? vda( |$)" /tmp/iotune.txt'), chk('총 IOPS 를 500 으로', 'grep -Eq -- "--total-iops-sec[ =]500( |$)" /tmp/iotune.txt')])
b.nt('balloon 현재 메모리', '`/tmp/balloon.log` 는 `virsh domstats --balloon` 의 출력입니다. 값의 단위는 KiB 입니다. **현재 VM 에 주어진 메모리(`balloon.current`)를 MiB 로** 환산해 숫자만 `/tmp/mem_mib.txt` 에 저장하세요.',
     '`=` 뒤의 숫자를 1024 로 나눕니다.',
     "grep 'balloon.current' /tmp/balloon.log | awk -F= '{print $2/1024}' > /tmp/mem_mib.txt\ncat /tmp/mem_mib.txt\n\n# maximum(4096 MiB)보다 current 가 작은 것은 balloon 이 호스트로 메모리를 돌려받은 상태다. 게스트 안에서 메모리가 빠듯해져 스왑이 늘면 느려진다",
     S110, [chk('2048 이다', '[ "$(awk "{print \\$1+0}" /tmp/mem_mib.txt)" = 2048 ]')])
b.choice('steal 이 높을 때', '게스트에서 `top` 을 보니 steal(`st`)이 40% 이고 게스트의 프로세스는 거의 아무것도 하지 않습니다. 가장 알맞은 조치는?', 'steal 은 게스트가 CPU 를 쓰고 싶어도 받지 못한 시간입니다.',
         ['호스트의 오버커밋을 줄이거나 VM 을 다른 호스트로 옮긴다', '게스트 안의 프로세스를 모두 종료하고 서비스를 다시 시작한다', '게스트 디스크를 더 큰 용량으로 확장한다', '게스트의 스왑 파일 크기를 두 배로 늘린다'], 0,
         'steal 은 호스트가 물리 CPU 를 다른 VM 에 주느라 이 VM 이 기다린 시간입니다. 게스트 안을 고쳐도 소용없고, 호스트에서 오버커밋을 줄이거나 VM 을 옮겨야 합니다.')
b.choice('iowait 가 높을 때', '게스트의 `top` 에서 `us`·`sy` 는 낮은데 `wa` 가 50% 입니다. 이 상태를 가장 바르게 해석한 것은?', 'wa 는 CPU 가 입출력 완료를 기다린 시간입니다.',
         ['CPU 는 놀고 디스크를 기다리는 중이라 스토리지 지연을 봐야 한다', 'CPU 가 부족하므로 vCPU 를 늘리면 바로 해결된다', '메모리가 부족해 balloon 이 곧바로 터진 상태다', '네트워크 대역이 가득 차서 패킷이 버려지고 있다'], 0,
         'iowait 가 높으면 병목은 CPU 가 아니라 디스크입니다. 게스트 안의 디스크 사용 패턴과 호스트 스토리지·공유 스토리지의 지연, 다른 VM 의 독점을 함께 확인하고, 필요하면 iotune 으로 제한합니다.')
b.choice('게스트 안만 봐서는', '신고된 VM 의 `top` 은 한가해 보이는데(`id` 높음) 사용자는 느리다고 합니다. 같은 호스트의 다른 VM 이 CPU 를 모두 쓰고 있을 수 있습니다. 원인을 가려내는 데 가장 알맞은 것은?', '게스트 안의 통계는 호스트 전체 상황을 보여 주지 못합니다.',
         ['호스트에서 VM 별 CPU 통계를 비교한다', '게스트를 재부팅한 뒤 같은 증상이 다시 나오는지 기다려 본다', '게스트 디스크 전체를 fsck 로 점검하고 결과를 기다린다', '게스트의 방화벽 규칙을 모두 지우고 다시 시도한다'], 0,
         '게스트 안만 봐서는 호스트가 CPU 를 어떻게 나눠 줬는지 알 수 없습니다. 호스트에서 VM 별 통계를 비교하고 게스트 steal 을 같이 보면 오버커밋이나 다른 VM 의 독점을 확인할 수 있습니다.')
b.fill('VM 통계 보기', '호스트에서 VM 한 대의 CPU·블록·네트워크 통계를 그룹별로 보는 하위 명령의 이름을 채우세요.', '"도메인 통계"를 줄인 이름입니다.',
       'virsh {0} web01 --cpu-total', ['domstats', 'dominfo', 'vcpuinfo', 'domstate'], [0],
       '`domstats` 는 도메인별 통계를 그룹 옵션(`--cpu-total`, `--block`, `--balloon`, `--interface`)으로 보여 줍니다. `dominfo` 는 요약 정보, `vcpuinfo` 는 vCPU 배치, `domstate` 는 상태만 보여 줍니다.')
b.order('느린 VM 대응', '"VM 이 느리다"는 신고를 받았습니다. 근거 없이 조치를 바꾸지 않고 진행하는 올바른 순서로 놓으세요.', '조치는 가설을 확인한 뒤에 하고, 효과는 같은 지표로 확인합니다.',
        ['같은 지표를 다시 측정해 좋아졌는지 확인한다', '제한을 조정하거나 VM 을 옮기는 조치를 한다', '호스트에서 해당 VM 과 다른 VM 의 통계를 비교한다', '게스트 안에서 증상을 수치(CPU·wa·st)로 확인한다'], [3, 2, 1, 0],
        '먼저 게스트 안에서 어떤 수치가 나쁜지 확인하고, 호스트에서 다른 VM 과 비교해 원인을 좁힌 뒤, 조치를 하고, 같은 지표로 효과를 확인합니다.')

if __name__ == '__main__':
    preview(b)
